.eqv LARGE_BUFFER 10000

.data
	# Caminhos dos arquivos
	pathXTrain: .asciiz "data/bb.txt"
	
	# Buffer
	buffer: .space 10000
	
	spaceX: .space LARGE_BUFFER
	
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
		
		l.d $f4, 48.00
		l.d $f5, 10.00
		
		loopTransformaChar:
			lb $t1, 0($a1)
			ld $f1, 0($s0) # NAO SEI SE POSSO FAZER
			ld $f2, 0 # uso pra armazenar inteiro
			ld $f3, 0 # uso pra armazenar decimal
			beq $t1, 46, decimal
			beq $t1, 10, proxNumero
			beq $t1, $zero, fimTranformacao
			
			proxNumero:
				
				li $t3, 1 # avisa que o proximo e inicio de um inteiro
				add $s0, $s0, 8
			
			inteiro:
				bgt $t3, 1, inteiroLoop
				move $f2, $t1
				sub.d $f2, $f2, $f4 # guarda o inteiro em $f2 depois de transformar
				add $a1, $a1, 1
				li $t3, 2 # avisa que o proximo e pelo menos segundo de um inteiro
				jal loopTransformaChar
			
			inteiroLoop:
				bgt $t3, 2, decimal
			
			decimal:
				bgt $t3, 3, decimalLoop