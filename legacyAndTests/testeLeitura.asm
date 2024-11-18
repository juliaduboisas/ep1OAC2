.eqv LARGE_BUFFER 10000

.data
	# Caminhos dos arquivos
	pathXTrain: .asciiz "data/Xtrain.txt"
	
	# Buffer
	buffer: .space 10000
	
	spaceX: .space LARGE_BUFFER
	
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
		
		li $v0, 4
		move $a0, $a1 # como imprime o que esta em $a0 precisa mover o conteudo que esta em $a1
		syscall
		
		loopContaLinhas:
			lb $t1, 0($a1)		
			beq $t1, 46, maisLinha
			bne $t1, $zero, proxLinha

			
		 	
		fim:
			li $v0, 16
			move $a0, $t8 # bota o endereco do descritor de volta em a0
			syscall
			
			li $v0, 1
			move $a0, $a3
			syscall
			
			li $v0, 10
			syscall
			
			
		maisLinha:
				add $a3, $a3, 1
				jal proxLinha
				
		proxLinha:
				add $a1, $a1, 1
				jal loopContaLinhas