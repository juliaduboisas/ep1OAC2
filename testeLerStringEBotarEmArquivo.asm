.eqv LARGE_BUFFER 10000

.data
	# Caminhos dos arquivos
	pathXTrain: .asciiz "data/bb.txt"
	pathYTest: .asciiz "data/cc.txt"
	
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
		
	li $a2, 0
	
	move $t5, $a1 # guardando a posicao inicial do buffer
	
	loopContaChar:
		lb $t1, 0($a1) # pega o char da vez
		beq $t1, $zero, escreverYTest
		add $a2, $a2, 1
		add $a1, $a1, 1
		
escreverYTest: # NESSE TESTE ESCREVE SIMPLESMENTE O CONTEÚDO DO ARQUIVO bb.txt
	move $t8, $a0
	
	la $a0, pathYTest # path do arquivo
	li $a1, 1 # modo escrita
	li $v0, 13
	syscall
	
	move $s2, $v0
	
	li $v0, 16
	move $a0, $s0
	syscall
	
	# escrevendo a string
	li $v0, 15
	move $a0, $s2 # string que quero escrever no arquivo
	move $a1, $t5
	# $a2 ja esta com o tamanho do arquivo
	syscall
	
	li $v0, 10
	syscall
