# Este arquivo executa o algoritmo knn em um xtrain, xteste e ytrain prontos
# Por simplicidade, estes 3 estarão prontos na seção data
# As entradas assumem w = 3 e h = 1

.data
	xtrain: .double 4.99, 5.67, 9.134, 7.567, 8.547, 9.88, 10.00, 10.768, 11.4356
	xtest: .double 4.99, 5.67, 9.134, 5.67, 9.134, 7.567, 9.134, 7.567, 8.547, 7.567, 8.547, 9.88, 8.547, 9.88, 10.00, 9.88, 10.00, 10.768, 10.00, 10.768, 11.4356
	ytrain: .double 7.567, 8.547, 9.88, 10.00, 10.768, 11.4356
	newline: .asciiz "\n"

.text
main:
	addi $s0, $0, 3		# $s0 será o k
	addi $s6, $0, 3		# $s6 será o m
	la $s1, xtrain
	la $s2, xtest
	la $s3, ytrain
	
	# TAMANHOS DOS ARRAYS
	addi $t0, $0, 21	# tamanho de xtest
	addi $t1, $0, 9		# tamanho de xtrain
	addi $t2, $0, 6		# tamanho de ytrain
	addi $t3, $0, 7		# tamanho de ytest (xtest / 3)

	# ALOCA ARRAY INT. E YTEST	
	mul $t4, $t0, 12	# o tamanho do array a ser alocado precisa ser do tamanho xteste * 12, pois é para double, precisa armazenar o índice, e cada posição tem 4 bytes
	add $s4, $s0, $sp	# $s4 será o array intermediário
	sub $sp, $sp, $t4
	
	sll $t7, $t3, 2
	add $s5, $s0, $sp	# $s5 será o ytest
	sub $sp, $sp, $t7
	
	
	# INICIO DO PROCESSAMENTO
loopXtest:

	add $t5, $0, $0 	# índice para o loop xtrain
	add $t6, $0, $s1	# ponteiro auxiliar para loop xtrain
loopXtrain:
	

	# parâmetros para pegaDistVetor
	add $a2, $0, $s6 	# recupera m para processar os vetores
	add $v0, $0, $0
	add $a0, $t6, $0
	add $a1, $s2, $0
	jal pegaDistVetor
	
	mov.d $f12, $f30
	li $v0, 3
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	
	addi $t6, $t6, 8
	addi $t5, $t5, 1
	
	blt $t5, $t1, loopXtrain
	
	j end
	
	
	
	
pegaDistVetor:			# pega a distância entre dois vetores $a1 e $a0  de tamanho $a2 (retorno será em $f30)
	l.d $f0, ($a0)
	l.d $f2, ($a1)
	sub.d $f0, $f0, $f2
	mul.d $f0, $f0, $f0
	add.d $f30, $f30, $f0
	subi $a2, $a2, 1
	addi $a0, $a0, 8	
	addi $a1, $a1, 8
	bgt $a2, $zero, pegaDistVetor
	jr $ra
	
			
				
					
						
	
		
			
				
					
						
							
								
									
										
												
	
	
	# TESTE PARA MEXER COM DOUBLE
	
	add $t7, $t1, $0
loop:
	l.d $f2, ($s1) 
	l.d $f0, ($s2)
	add.d $f12, $f0, $f2
	addi $v0, $zero, 3
	syscall
	addi $v0, $zero, 4
	la $a0, newline
	syscall
	subi $t7, $t7, 1
	addi $s2, $s2, 8
	addi $s1, $s1, 8
	bgt $t7, $0, loop
end:	
	addi $v0, $zero, 10
	syscall