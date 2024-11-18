### SIMPLE ARRAY

.data
$vetor: .asciiz "BCDEF"
$zerar: .asciiz "A"

.text
.globl main
main:
	la $a0, $vetor		
	li $v0, 4
	syscall
	
	li $a0, 0		# inicializa a0 com 0
	la $t2, 0		# inicia o contador
	la $t3, $zerar
loop:
	ld $t4, ($a0)	    	# carrega o valor apontado pelo t3 para a3	
	ld $t4, $zerar		# zera
	addi $a0, $a0, 4	# aumenta o apontador
	addi $t2, $t2, 1	# aumenta o contador
	blt $t2, 5, loop	# verifica se terminou e faz o loop
	li $v0, 4		# imprime o resultado
	syscall
	li $v0, 10		# termina
	syscall

