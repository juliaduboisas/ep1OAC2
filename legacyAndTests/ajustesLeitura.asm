.data
	pathXTest: .asciiz "data/xtest.txt"
	
	# Buffer
	buffer: .space 10000
	
	spaceX: .space 10000
	
	# Floats needed
	fp1: .double 48.00
	fp2: .double 10.00
	fp3: .double 1.00
	zerof: .double 0.00
	
	# Chars needed
	newline: .asciiz "\n"
	
.text
	# Carregar xtest
	la $a0, pathXTest # descobre qual arquivo abrir
	la $t6, buffer  # carrega o tamanho do buffer onde guardar o conteudo
	li $a3, 0 # carrega 0 no registrador a3
	j carregaParaMatrizXTest
	
carregaParaMatrizXTest:
	descobreNumLinhasXtest:
		li $a1, 0 # determina modo leitura
		li $v0, 13 # syscall para ler 
		syscall
	
		move $t5, $v0 # salva o endereço do descritor em $t5 para fechar o arquivo posteriormente
	
		move $a0, $t5 # salva o endereço do descritor em $a0 para quando for abrir o arquivo novamente
		# PRECISAMOS TER O ENDEREÇO DO DESCRITOR SALVO NOS DOIS ARQUIVOS!!!
		li $v0, 14 # ler conteúdo do arquivo referenciado por $a0
		la $a1, spaceX # buffer que armazena o conteudo do arquivo
		add $a2, $a2, $t6 # tamanho do buffer
		syscall # leitura realizada
		
		#li $v0, 4
		#move $a0, $a1 # como imprime o que esta em $a0 precisa mover o conteudo que esta em $a1
		#syscall´
		
		move $t0, $a1 # salva onde fica o buffer
		
		loopContaLinhasXTest:
			lb $t1, 0($a1)		
			beq $t1, 46, maisLinhaXTest
			beq $t1, $zero, fimNumLinhasXTest
			bne $t1, $zero, proxLinhaXTest

			
		 	
		fimNumLinhasXTest:
			li $v0, 16
			move $a0, $t5 # bota o endereco do descritor de volta em a0
			syscall
			
			li $v0, 1
			move $t5, $a0
			move $t2, $a3
			move $a0, $a3
			syscall
			move $a0, $t5
			
			j transformaEmArrayXTest
			
			
		maisLinhaXTest:
				add $a3, $a3, 1
				j proxLinhaXTest
				
		proxLinhaXTest:
				add $a1, $a1, 1
				j loopContaLinhasXTest

	transformaEmArrayXTest:
		move $a1, $t0 # volta a1 para o inicio do buffer
		
		# ALOCANDO ESPACO DO ARRAY
		mul $t4, $a3, 8 # t4 = numeroDeLinhas (ou seja, de numeros) * sizeof(double)
		li $v0, 9 # chamada ao sistema para malloc
		move $t5, $a0
		move $a0, $t4 # colocando o tamanho necessario em a0 para a syscall
		syscall	# ESPACO DO ARRAY ALOCADO
		
		move $s0, $v0 # SALVANDO PONTEIRO
		move $s1, $s0 # PONTEIRO QUE VOU USAR PARA ANDAR NO ARRAY
		move $a0, $t5 # recolocando o valor de $a0
		
		li $s6, 1 # estou usando 1 para primeiro inteiro, 2 para outros inteiros, 3 pra primeiro decimal, 4 para outros decimais, 5 para o ultimo numero do array
		
		l.d $f6, fp1
		l.d $f8, fp2
		l.d $f14, fp3
		
		l.d $f2, zerof # uso pra armazenar inteiro
		l.d $f4, zerof # uso pra armazenar decimal
		l.d $f10, zerof # uso como temporario
		
		loopTransformaCharXTest:
			lb $t1, 0($t0)
			l.d $f0, 0($s1) # NAO SEI SE POSSO FAZER
			l.d $f10, zerof
			
			beq $t1, 10, proxNumeroXTest # checa se chegou no fim da linha
			beq $t1, 13, proxNumeroXTest # checa se chegou no fim da linha
			beq $t1, $zero, fimTransformacaoXTest # checa se chegou no fim do arquivo
			beq $t1, 3, fimTransformacaoXTest # checa se chegou no fim do arquivo
			beq $t1, 46, marcaDecimalXTest # checa se chegou no "."
			beq $s6, 1, inteiroXTest # s6 marca que tipo de numero adicionar
			beq $s6, 2, inteiroLoopXTest
			beq $s6, 3, decimalXTest
			beq $s6, 4, decimalLoopXTest
			blt $t1, 48, pulaCharXTest
			bgt $t1, 58, pulaCharXTest
			
			pulaCharXTest:
				l.d $f2, zerof # uso pra armazenar inteiro
				l.d $f4, zerof # uso pra armazenar decimal
				li $s6, 1 # avisa que o proximo e inicio de um inteiro
				add $t0, $t0, 1
				
				j loopTransformaCharXTest
			
			inteiroXTest:
				bgt $s6, 1, inteiroLoopXTest # se nao for o primeiro inteiro para pro prox loop de inteiros
				sub $t1, $t1, '0' # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mov.d $f2, $f10 # bota no registrador que estou usando para guardar um inteiro
				add $t0, $t0, 1 # passa para o prox numero
				li $s6, 2 # avisa que o proximo e pelo menos segundo de um inteiro
				j loopTransformaCharXTest
			
			inteiroLoopXTest:
				bgt $s6, 2, decimalXTest # se nao for inteiro passa pro loop de decimal
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mul.d $f2, $f2, $f8 # multiplica o antigo por 10.00
				add.d $f2, $f2, $f10 # soma o valor atual com o valor antigo
				add $t0, $t0, 1
				j loopTransformaCharXTest
			
			marcaDecimalXTest:
				bgt $s6, 2, decimalXTest
				li $s6, 3 # marca que o proximo e pelo menos o primeiro decimal
				add $t0, $t0, 1 # passa para o prox numero
				j loopTransformaCharXTest
			
			decimalXTest:
				bgt $s6, 3, decimalLoopXTest
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mov.d $f4, $f10 # bota no registrador que estou usando para guardar um decimal
				add $t0, $t0, 1 # passa para o prox numero
				li $s6, 4
				j loopTransformaCharXTest
				
			decimalLoopXTest:
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mul.d $f4, $f4, $f8 # multiplica o antigo por 10.00
				add.d $f4, $f4, $f10 # soma o valor atual com o valor antigo
				add $t0, $t0, 1 # passa para o prox numero
				j loopTransformaCharXTest
				
			proxNumeroXTest:
				# CALCULO DO NUMERO
				# transforma o decimal em um numero menor que 1
				c.lt.d $f4, $f14
				bc1f 0, loopTransformaDecimalXTest
				
				# adiciona a parte inteira com a parte decimal e guarda em f0 (no array)
				l.d $f10, zerof
				add.d $f10, $f2, $f4 
				s.d $f10, ($s1)
				
				# depois de guardar o numero
				l.d $f2, zerof # uso pra armazenar inteiro
				l.d $f4, zerof # uso pra armazenar decimal
				li $s6, 1 # avisa que o proximo e inicio de um inteiro
				add $t0, $t0, 1
				add $s1, $s1, 8
				
				j loopTransformaCharXTest
			
			loopTransformaDecimalXTest:
				div.d $f4, $f4, $f8 # divide o valor em $f4 por 10
				c.lt.d $f4, $f14 # se for UM, $f4 eh decimal; se for 0, $f4 ainda tem parte inteira e precisa ser dividido de novo
				bc1f 0, loopTransformaDecimalXTest
				bc1t 0, proxNumeroXTest
			
			fimTransformacaoXTest:
				li $s6, 5
				
				# NUMERO DE LINHAS NO $a3
				# INICIO DO ARRAY NO $s0
				
				jal m2