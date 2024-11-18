.eqv LARGE_BUFFER 10000

.data
	# Caminhos dos arquivos
	pathXTrain: .asciiz "legacyAndTests/cc.txt"
	contMatriz: .asciiz "tentativa"
	
	# Buffer
	buffer: .space 10000
	
	spaceX: .space LARGE_BUFFER
	
.text

.globl main
main:	
escreverYTest: # NESSE TESTE ESCREVE SIMPLESMENTE O CONTEÚDO DO ARQUIVO bb.txt
	la $a0, pathXTrain # path do arquivo
	li $a1, 1 # modo escrita
	li $v0, 13
	syscall
	
	move $s2, $v0
	
	li $v0, 16
	move $a0, $s0
	syscall
	
	# escrevendo a string
	li $v0, 15
	move $a0, $s2
	la $a1, contMatriz
	li $a2, 9
	syscall
	
	li $v0, 10
	syscall
