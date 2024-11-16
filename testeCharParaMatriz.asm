.eqv LARGE_BUFFER 10000

.data
	# Caminhos dos arquivos
	pathXTrain: .asciiz "data/bb.txt"
	
	# Buffer
	buffer: .space 10000
	
	spaceX: .space LARGE_BUFFER
	
	# Floats needed
	fp1: .double 48.00
	fp2: .double 10.00
	fp3: .double 1.00
.text

.globl main
main:
	# Carregar xtest
	la $a0, pathXTrain # descobre qual arquivo abrir
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
		la $a1, spaceX # buffer que armazena o conteudo do arquivo
		add $a2, $a2, $t6 # tamanho do buffer
		syscall # leitura realizada
		
		#li $v0, 4
		#move $a0, $a1 # como imprime o que esta em $a0 precisa mover o conteudo que esta em $a1
		#syscall
		
		loopContaLinhas:
			lb $t1, 0($a1)		
			beq $t1, 46, maisLinha
			beq $t1, $zero, fimNumLinhas
			bne $t1, $zero, proxLinha

			
		 	
		fimNumLinhas:
			li $v0, 16
			move $a0, $t8 # bota o endereco do descritor de volta em a0
			syscall
			
			li $v0, 1
			move $t8, $a0
			move $a0, $a3
			syscall
			move $a0, $t8
			
			jal transformaEmMatriz
			
			
		maisLinha:
				add $a3, $a3, 1
				jal proxLinha
				
		proxLinha:
				add $a1, $a1, 1
				jal loopContaLinhas

	transformaEmMatriz:
		sub $a1, $a1, $a3 # volta a1 para o inicio do buffer
		
		# ALOCANDO ESPACO DO ARRAY
		mul $t4, $a3, 8 # t4 = numeroDeLinhas * sizeof(double)
		li $v0, 9 # chamada ao sistema para malloc
		move $t8, $a0
		move $a0, $t4 # colocando o tamanho necessario em a0 para a syscall
		syscall	# ESPACO DO ARRAY ALOCADO
		
		move $s0, $v0 # SALVANDO PONTEIRO
		move $s1, $s0 # PONTEIRO QUE VOU USAR PARA ANDAR NO ARRAY
		move $a0, $t8 # recolocando o valor de $a0
		
		li $t3, 1 # estou usando 1 para primeiro inteiro, 2 para outros inteiros, 3 pra primeiro decimal, 4 para outros decimais (???)
		
		l.d $f6, fp1
		l.d $f8, fp2
		l.d $f12, fp3
		
		l.d $f2, 0.00 # uso pra armazenar inteiro
		l.d $f4, 0.00 # uso pra armazenar decimal
		
		loopTransformaChar:
			lb $t1, 0($a1)
			l.d $f0, 0($s1) # NAO SEI SE POSSO FAZER
			
			beq $t1, 10, proxNumero # checa se chegou no fim da linha
			beq $t1, $zero, fimTranformacao # checa se chegou no fim do arquivo
			beq $t3, 1, inteiro # t3 marca que tipo de numero adicionar
			beq $t1, 46, marcaDecimal # checa se chegou no "."
			beq $t3, 2, inteiroLoop
			beq $t3, 3, decimal
			beq $t3, 4, decimalLoop
			
			inteiro:
				bgt $t3, 1, inteiroLoop
				move $f2, $t1 # NAO SEI SE VAI FUNCIONAR
				sub.d $f2, $f2, $f6 # guarda o inteiro em $f2 depois de transformar
				add $a1, $a1, 1 # passa para o prox numero
				li $t3, 2 # avisa que o proximo e pelo menos segundo de um inteiro
				jal loopTransformaChar
			
			inteiroLoop:
				bgt $t3, 2, marcaDecimal # se nao for inteiro passa pro loop de decimal
				move $f10, $t1 # USANDO $F10 COMO TEMPORARIO
				mul.d $f2, $f2, $f8 # multiplica o antigo por 10.00
				add.d $f2, $f2, $f10 # soma o valor atual com o valor antigo
				add $a1, $a1, 1
				jal loopTransformaChar
			
			marcaDecimal:
				li $t3, 3 # marca que o proximo e pelo menos o primeiro decimal
				add $a1, $a1, 1 # passa para o prox numero
				jal loopTransformaChar
			
			decimal:
				bgt $t3, 3, decimalLoop
				move $f4, $t1
				sub.d $f4, $f4, $f6 # guarda o inteiro em $f4 depois de transformar
				add $a1, $a1, 1 # passa para o prox numero
				li $t3, 4
				jal loopTransformaChar
				
			decimalLoop:
				bgt $t3, 2, marcaDecimal # se nao for inteiro passa pro loop de decimal
				move $f10, $t1 # USANDO $F10 COMO TEMPORARIO
				mul.d $f4, $f4, $f8 # multiplica o antigo por 10.00
				add.d $f4, $f4, $f10 # soma o valor atual com o valor antigo
				add $a1, $a1, 1 # passa para o prox numero
				jal loopTransformaChar
				
			proxNumero:
				# CALCULO DO NUMERO
				# transforma o decimal em um numero menor que 1
				c.le.d $f12, $f4
				beq $31, 1, loopTransformaChar
					
				# adiciona a parte inteira com a parte decimal e guarda em f0 (no array)
				l.d $f10, $f2
				add.d $f10, $f10, $f4 
				l.d $f0, $f10
				
				# depois de guardar o numero
				l.d $f2, 0.00 # uso pra armazenar inteiro
				l.d $f4, 0.00 # uso pra armazenar decimal
				li $t3, 1 # avisa que o proximo e inicio de um inteiro
				add $s1, $s1, 8
				
				jal loopTransformaChar
			
			fimTransformacao:
				# TRATA O ULTIMO NUMERO
					# CALCULO DO NUMERO
					# transforma o decimal em um numero menor que 1
					bgt $f4, 1, loopTransformaDecimal
		
					# adiciona a parte inteira com a parte decimal e guarda em f0 (no array)
					l.d $f10, $f2
					add.d $f10, $f10, $f4 
					l.d $f0, $f10
				
				move $t8, $a0
				li $v0, 2
				move $a0, $s0
				syscall
				move $a0, $t8
				
				li $v0, 10
				syscall
			
			loopTransformaDecimal:
				div.d $f4, $f4, $f8 # divide o valor em $f4 por 10
				c.le.d $f12, $f4
				beq $31, 1, loopTransformaChar
				beq $31, 0, proxNumero