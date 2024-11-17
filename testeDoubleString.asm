.data
	# Matriz
	num: .double 123.45600
	
	# aux
	
	dezDouble: .double 10.00
	zeroDouble: .double 0.00

.text

.globl main
main:
	li $a0, 6
	li $v0, 9
	syscall # aloca espaco para o array
	
	move $s2, $v0 # ARRAY ESTA EM S2
	
	l.d $f0, num
	l.d $f2, dezDouble
	l.d $f4, zeroDouble
	
	li $t0, 0	
	
	jal arrumaNum
arrumaNum:
	cvt.w.d $f6, $f0 # converte float para int
	
	mfc1 $a1, $f6 # guarda em um registrador
	mtc1 $a1,$f8 # bota o pedaco inteiro em um coprocessador
	
	cvt.d.w $f8, $f8 # converte o pedaco inteiro em float para poder fazer operacoes
	
	sub.d $f8, $f0, $f8 # pega so a parte decimal
	
	mul.d $f8, $f8, $f2 # multiplica por 10 para acessar a primeira casa decimal
	mul.d $f8, $f8, $f2 # multiplica por 10 para acessar as duas primeiras casas decimais
	
	cvt.w.d $f8, $f8 # converte os decimais para int
	mfc1 $a2, $f8 # coloca em um registrador
	
	# FUNCIONANDO ATE AQUI
	# EM A1 TEMOS A PARTE INTEIRA E EM A2 TEMOS A PARTE DECIMAL
	
	move $a3, $a1 # bota a parte inteira em a3 para descobrir o char
	li $t3, 10 # para usar na divisao
	li $t5, 0
	li $t7, 1
	
	descobreChar:
		blt $a3, 10, colocaChar
		div $a3, $t3
		mflo $a3 # quociente (aka numero da vez)
		mfhi $t6
		mul $t6, $t6, $t7 # multiplica o resto pela 10 ^ numDeCiclos
		mul $t7, $t7, 10 # atualiza potencia do num de ciclos
		add $t5, $t5, $t6 # soma com o decimal anterior
		jal descobreChar
			
	colocaChar:
		add $a0, $a3, 48
		li $v0, 11
		syscall
		move $a3, $t5
		li $t5, 0
		li $t7, 1
		beq $a3, 0, terminaInt
		jal descobreChar

	terminaInt:
		beq $a2, 0, terminaNumero
		li $a0, '.'
		li $v0, 11
		syscall
		move $a3, $a2
		li $a2, 0
		jal descobreChar
		
	terminaNumero:
		li $v0, 10
		syscall