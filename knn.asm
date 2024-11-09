# Este arquivo executa o algoritmo knn em um xtrain, xteste e ytrain prontos
# Por simplicidade, estes 3 estarão prontos na seção data
# As entradas assumem w = 3 e h = 1

.data
	xtrain: .double 4.99, 5.67, 9.134, 7.567, 8.547, 9.88, 10.00, 10.768, 11.4356
	xtest: .double 4.99, 5.67, 9.134, 5.67, 9.134, 7.567, 9.134, 7.567, 8.547, 7.567, 8.547, 9.88, 8.547, 9.88, 10.00, 9.88, 10.00, 10.768, 10.00, 10.768, 11.4356
	ytrain: .double 7.567, 8.547, 9.88, 10.00, 10.768, 11.4356

.text
main:
	addi $s0, $0, 3		# $s0 será o k
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
	

	