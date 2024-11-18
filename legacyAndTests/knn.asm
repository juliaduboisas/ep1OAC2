# Este arquivo executa o algoritmo knn em um xtrain, xteste e ytrain prontos
# Por simplicidade, estes 3 estarão prontos na seção data
# As entradas assumem w = 3 e h = 1

.data
	xtrain: .double 4.99, 5.67, 9.134, 7.567, 8.547, 9.88, 5.32, 6.12, 9.44
	xtest: .double 4.99, 5.67, 9.134, 5.67, 9.134, 7.567, 9.134, 7.567, 8.547, 7.567, 8.547, 9.88, 8.547, 9.88, 5.32, 9.88, 5.32, 6.12, 5.32, 6.12, 9.44
	ytrain: .double 7.567, 8.547, 9.88, 10.00, 10.768, 11.4356
	newline: .asciiz "\n"
	space: .asciiz " "
	interArray: .asciiz "Intermediate array:\n"
	interArraySorted: .asciiz "Sorted intermediate array:\n"
	ytest: .asciiz "Y-TEST:"
	separation: .asciiz "///////////////////////////////////////////////////////////////////////////\n"
.text
main:
	addi $k0, $0, 3		# $k0 será o k
	addi $k1, $0, 3		# $k1 será o m
	la $s1, xtrain
	la $s2, xtest
	la $s3, ytrain
	
	# TAMANHOS DOS ARRAYS
	addi $t0, $0, 21	# tamanho de xtest
	addi $t1, $0, 9		# tamanho de xtrain
	addi $t2, $0, 6		# tamanho de ytrain
	addi $t3, $0, 7		# tamanho de ytest (xtest / m)

	# ALOCA ARRAY INT. E YTEST
	jal adjustsp
	div $t4, $t1, $k1
	mul $t4, $t4, 16	# o tamanho do array a ser alocado precisa ser do tamanho xtrain/m * 16, seria 12 mas é preciso ser divisivel por 8
	add $s4, $s0, $sp	# $s4 será o array intermediário, de tamanho $t4
	sub $sp, $sp, $t4
	div $t4, $t4, 16
	
	sll $t7, $t3, 2
	add $s5, $0, $sp	# $s5 será o ytest
	sub $sp, $sp, $t7
	
	
	
	# INICIO DO PROCESSAMENTO
	add $t7, $0, $s5 	# ponteiro auxiliar para ytest
loopXtest:
	
	add $t5, $0, $0 	# índice para o loop xtrain
	add $t6, $0, $s1	# ponteiro auxiliar para loop xtrain
	add $t8, $0, $s4	# ponteiro auxiliar para array intermediario
loopXtrain:

	# parâmetros para pegaDistVetor
	add $a2, $0, $k1	# recupera m para processar os vetores
	add $a0, $t6, $0
	add $a1, $s2, $0
	mtc1 $0, $f30		# reseta double em $f30
	mtc1 $0, $f31
	jal pegaDistVetor
	
	# coloca o valor calculado e indice no intermediário
	s.d $f30, ($t8)
	subi $t8, $t8, 8
	div $s6, $t5, $k1
	sw $s6, ($t8)
	subi $t8, $t8, 8			
	
	mul $s0, $k1, 8
	add $t6, $t6, $s0
	add $t5, $t5, $k1
	
	blt $t5, $t1, loopXtrain
	
	la $a0, separation
	addi $v0, $0, 4
	syscall
	
	# Verifica array intermediário
	la $a0, interArray
	addi $v0, $0, 4
	syscall
	add $a1, $0, $s4
	jal loopCheckIntermediate
	
	# Ordena array intermediário
	add $a1, $0, $s4
	
	add $a2, $0, $t4
	jal bubble_sort
	
	la $a0, newline
	li $v0, 4
	syscall
	
	# Verifica array intermediário ordenado
	la $a0, interArraySorted
	addi $v0, $0, 4
	syscall
	add $a1, $0, $s4
	mul $t8, $t4, 16
	sub $t8, $s4, $t8
	jal loopCheckIntermediate
	
	la $a0, separation
	addi $v0, $0, 4
	syscall
	
	
	# Verifica os indices dos k menores, faz a média de tais indices do ytrain e coloca no ytest
	add $a0, $0, $s3
	add $a1, $0, $s4
	add $a2, $0, $k0
	mtc1 $0, $f30
	mtc1 $0, $f31
	mtc1 $k1, $f2		# coloca m em $f2 para fazer a média
	mtc1 $0, $f3
	cvt.d.w $f2, $f2
	jal getYtrainAvg
	s.d $f30, ($t7)		# coloca a média calculada em ytest
	mul $s6, $k1, 8		# deslocamento do xtest = m * 8
	subi $t7, $t7, 8
	sub $s2, $s2, $s6
	sub $t0, $t0, $k1
	
	
	bgt $t0, $0, loopXtest
	
	# IMPRIME YTEST
	la $a0, newline
	li $v0, 4
	syscall
	la $a0, ytest
	li $v0, 4
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	
loopYtest:
	l.d $f12, ($s5)
	addi $v0, $0, 3
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	subi $s5, $s5, 8
	subi $t3, $t3, 1
	bgt $t3, $0, loopYtest
	
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
	
			
loopCheckIntermediate:
	l.d $f12, ($a1)	
	li $v0, 3
	syscall
	subi $a1, $a1, 8
	
	la $a0, space
	li $v0, 4
	syscall
	
	lw $a0, ($a1)
	li $v0, 1
	syscall
	subi $a1, $a1, 8
	
	la $a0, newline
	li $v0, 4
	syscall
	
	bgt $a1, $t8, loopCheckIntermediate
	
	jr $ra
	
# $a0 = ytrain
# $a1 = intermediário
# $a2 = k				
getYtrainAvg:
	lw $s0, -8($a1)		# carrega o indice
	mul $s0, $s0, 8											
	add $a0, $a0, $s0	
	l.d $f0, ($a0)
	add.d $f30, $f30, $f0
	subi $a2, $a2, 1
	subi $a1, $a1, 16
	sub $a0, $a0, $s0
	bgt $a2, $0, getYtrainAvg
	div.d $f30, $f30, $f2	# faz a média dos valores selecionados em ytrain
	jr $ra
				
# ALGORITMO DE ORDENAMENTO PARA ARR INTERMEDIÁRIO														
# Função: bubble_sort
# Entrada: 
#   $a1 - endereço inicial do array no stack ($sp + offset inicial)
#   $a2 - tamanho do array (número de elementos)

bubble_sort:
    addi $t5, $zero, 0      # i = 0 (índice externo)
outer_loop:
    add $t8, $zero, $a2     # t8 = tamanho do array
    sub $t8, $t8, $t5       # t8 = tamanho - i - 1
    addi $t8, $t8, -1       # t8 = tamanho - i - 2
    blez $t8, end_outer     # Se t8 <= 0, terminar loop externo

    move $t9, $zero         # j = 0 (índice interno)
inner_loop:
    mul $s7, $t9, 16        # Offset = j * 16 (cada elemento ocupa 16 bytes)
    sub $t6, $a1, $s7       # Endereço do elemento[j] (posição atual)
    
    ldc1 $f0, 0($t6)        # Carregar os primeiros 8 bytes de array[j] em $f0
    ldc1 $f2, -16($t6)      # Carregar os primeiros 8 bytes de array[j+1] em $f2
    
    c.le.d $f2, $f0         # Verificar se array[j+1] < array[j]
    bc1f skip_swap          # Se falso, não faz swap
    
    # Swap completo de 16 bytes entre array[j] e array[j+1]
    move $s0, $t6           # Salvar endereço de array[j]
    addi $t6, $t6, -16      # Calcular endereço de array[j+1]
    
    # Trocar os primeiros 8 bytes
    ldc1 $f4, 0($s0)        # Carregar os primeiros 8 bytes de array[j] em $f4
    ldc1 $f6, 0($t6)        # Carregar os primeiros 8 bytes de array[j+1] em $f6
    s.d $f6, 0($s0)         # Escrever os primeiros 8 bytes de array[j+1] em array[j]
    s.d $f4, 0($t6)         # Escrever os primeiros 8 bytes de array[j] em array[j+1]
    
    # Trocar os últimos 8 bytes
    lw $s7, -8($s0)        # Carregar os últimos 8 bytes de array[j] em $f8
    lw $s6, -8($t6)       # Carregar os últimos 8 bytes de array[j+1] em $f10
    sw $s6, -8($s0)        # Escrever os últimos 8 bytes de array[j+1] em array[j]
    sw $s7, -8($t6)         # Escrever os últimos 8 bytes de array[j] em array[j+1]

skip_swap:
    addi $t9, $t9, 1        # j++
    blt $t9, $t8, inner_loop # Enquanto j < tamanho - i - 2, repetir

    addi $t5, $t5, 1        # i++
    j outer_loop            # Volta para o loop externo

end_outer:
    jr $ra                  # Retorna para o chamador


# ajusta $sp para ser divisivel por 8
adjustsp:	
	add $t4, $0, 8			
	div $sp, $t4
	mfhi $t7
	sub $sp, $sp, $t7
	jr $ra
						
										
			
end:
	addi $v0, $v0, 10
	syscall			
					
					