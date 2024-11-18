.eqv LARGE_BUFFER 10000

.data
	# Caminhos dos arquivos
	pathXTrain: .asciiz "data/Xtrain.txt"
	pathXTest: .asciiz "data/Xtest.txt"
	
	# Buffer
	buffer: .space 10000
	
	spaceX: .space LARGE_BUFFER
	
	# floats necessarios para os calculos
	fp1: .double 48.00
	fp2: .double 10.00
	fp3: .double 1.00
	
	zeroDouble: 0.00
	
	newLine: .asciiz "\n"
.text

.globl main
main:
	# Carregar xtest
	la $a0, pathXTrain # descobre qual arquivo abrir
	la $t5, spaceX # carrega o tamanho da string do conteudo do arquivo
	la $t6, buffer  # carrega o tamanho do buffer onde guardar o conteudo
	li $a3, 0 # carrega 0 no registrador a3
	jal carregaParaMatriz
	
carregaParaMatriz:
	descobreNumLinhas:
		li $a1, 0 # determina modo leitura
		li $v0, 13 # syscall para ler 
		syscall
	
		move $t8, $v0 # salva o endereço do descritor em $t8 para fechar o arquivo posteriormente
	
		move $a0, $t8 # salva o endereço do descritor em $a0 para quando for abrir o arquivo novamente
		# PRECISAMOS TER O ENDEREÇO DO DESCRITOR SALVO NOS DOIS ARQUIVOS!!!
		li $v0, 14 # ler conteúdo do arquivo referenciado por $a0
		move $a1, $t5 # buffer que armazena o conteudo do arquivo
		add $a2, $a2, $t6 # tamanho do buffer
		syscall # leitura realizada
		
		loopContaLinhas:
			lb $t1, 0($a1) # pega o char da vez
			beq $t1, 46, maisLinha # conta mais uma linha se for "." 
			beq $t1, $zero, fimNumLinhas
			bne $t1, $zero, proxLinha # se nao for nulo passa pra proxima linha

		fimNumLinhas: # NUMERO DE LINHAS FINAL ESTA NO REGISTRADOR $a3
			li $v0, 1
			move $a0, $a3
			syscall
			
			li $v0, 16
			move $a0, $t8 # bota o endereco do descritor de volta em a0
			syscall
			
			jal transformaEmMatriz
			
			
		maisLinha:
				add $a3, $a3, 1
				jal proxLinha
				
		proxLinha:
				add $a1, $a1, 1
				jal loopContaLinhas
	transformaEmMatriz:
		move $a1, $t0 # volta a1 para o inicio do buffer
		
		# ALOCANDO ESPACO DO ARRAY
		mul $t4, $a3, 8 # t4 = numeroDeLinhas (ou seja, de numeros) * sizeof(double)
		li $v0, 9 # chamada ao sistema para malloc
		move $t8, $a0
		move $a0, $t4 # colocando o tamanho necessario em a0 para a syscall
		syscall	# ESPACO DO ARRAY ALOCADO
		
		move $s0, $v0 # SALVANDO PONTEIRO
		move $s1, $s0 # PONTEIRO QUE VOU USAR PARA ANDAR NO ARRAY
		move $a0, $t8 # recolocando o valor de $a0
		
		li $t3, 1 # estou usando 1 para primeiro inteiro, 2 para outros inteiros, 3 pra primeiro decimal, 4 para outros decimais, 5 para o ultimo numero do array
		
		l.d $f6, fp1
		l.d $f8, fp2
		l.d $f14, fp3
		
		l.d $f2, zeroDouble # uso pra armazenar inteiro
		l.d $f4, zeroDouble # uso pra armazenar decimal
		l.d $f10, zeroDouble # uso como temporario
		
		loopTransformaChar:
			lb $t1, 0($t0)
			l.d $f0, 0($s1) # NAO SEI SE POSSO FAZER
			l.d $f10, zeroDouble
			
			beq $t1, 10, proxNumero # checa se chegou no fim da linha
			beq $t1, 13, proxNumero # checa se chegou no fim da linha
			beq $t1, $zero, fimTransformacao # checa se chegou no fim do arquivo
			beq $t1, 3, fimTransformacao # checa se chegou no fim do arquivo
			beq $t1, 46, marcaDecimal # checa se chegou no "."
			beq $t3, 1, inteiro # t3 marca que tipo de numero adicionar
			beq $t3, 2, inteiroLoop
			beq $t3, 3, decimal
			beq $t3, 4, decimalLoop
			blt $t1, 48, pulaChar
			bgt $t1, 58, pulaChar
			
			pulaChar:
				l.d $f2, zeroDouble # uso pra armazenar inteiro
				l.d $f4, zeroDouble # uso pra armazenar decimal
				li $t3, 1 # avisa que o proximo e inicio de um inteiro
				add $t0, $t0, 1
				
				jal loopTransformaChar
			
			inteiro:
				bgt $t3, 1, inteiroLoop # se nao for o primeiro inteiro para pro prox loop de inteiros
				sub $t1, $t1, '0' # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mov.d $f2, $f10 # bota no registrador que estou usando para guardar um inteiro
				add $t0, $t0, 1 # passa para o prox numero
				li $t3, 2 # avisa que o proximo e pelo menos segundo de um inteiro
				jal loopTransformaChar
			
			inteiroLoop:
				bgt $t3, 2, decimal # se nao for inteiro passa pro loop de decimal
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mul.d $f2, $f2, $f8 # multiplica o antigo por 10.00
				add.d $f2, $f2, $f10 # soma o valor atual com o valor antigo
				add $t0, $t0, 1
				jal loopTransformaChar
			
			marcaDecimal:
				bgt $t3, 2, decimal
				li $t3, 3 # marca que o proximo e pelo menos o primeiro decimal
				add $t0, $t0, 1 # passa para o prox numero
				jal loopTransformaChar
			
			decimal:
				bgt $t3, 3, decimalLoop
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mov.d $f4, $f10 # bota no registrador que estou usando para guardar um decimal
				add $t0, $t0, 1 # passa para o prox numero
				li $t3, 4
				jal loopTransformaChar
				
			decimalLoop:
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mul.d $f4, $f4, $f8 # multiplica o antigo por 10.00
				add.d $f4, $f4, $f10 # soma o valor atual com o valor antigo
				add $t0, $t0, 1 # passa para o prox numero
				jal loopTransformaChar
				
			proxNumero:
				# CALCULO DO NUMERO
				# transforma o decimal em um numero menor que 1
				c.lt.d $f4, $f14
				bc1f 0, loopTransformaDecimal
				
				# adiciona a parte inteira com a parte decimal e guarda em f0 (no array)
				l.d $f10, zeroDouble
				add.d $f10, $f2, $f4 
				s.d $f10, ($s1)
				
				# depois de guardar o numero
				l.d $f2, zeroDouble # uso pra armazenar inteiro
				l.d $f4, zeroDouble # uso pra armazenar decimal
				li $t3, 1 # avisa que o proximo e inicio de um inteiro
				add $t0, $t0, 1
				add $s1, $s1, 8
				
				jal loopTransformaChar
			
			fimTransformacao:
				li $t3, 5
				
				move $s1, $s0
				li $t1, 0
				move $t8, $a0
				la $a0, newLine
				loopImprimeArray:
					l.d $f12, ($s1)
					li $v0, 3
					syscall
					add $s1, $s1, 8
					add $t1, $t1, 1
					blt $t1, $a3, loopImprimeArray
				
				move $a0, $t8
				
				li $v0, 10
				syscall
			
			loopTransformaDecimal:
				div.d $f4, $f4, $f8 # divide o valor em $f4 por 10
				c.lt.d $f4, $f14 # se for UM, $f4 eh decimal; se for 0, $f4 ainda tem parte inteira e precisa ser dividido de novo
				bc1f 0, loopTransformaDecimal
				bc1t 0, proxNumero
