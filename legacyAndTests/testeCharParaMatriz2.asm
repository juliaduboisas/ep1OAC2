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
	zeroDouble: .double 0.00
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
carrega:
	li $a1, 0
	li $v0, 13 
	syscall
  
  	move $t8, $v0 #salva o endere�o do descritor em $t7 para fechar o arquivo posteriormente
  
  	move $a0, $t8
  	li $v0, 14 
  	move $a1, $t5
  	add $a2, $a2, $t6
  	syscall
  
	li $t4, 1
  	move $t0, $a1 #possui a string
  	lwc1 $f0, zeroDouble
  	lwc1 $f1, fp1 #multiplicador/divisor
  	move $a0, $s0 #$a0 deve conter o vetor que est� em $t7
  	
  	aloca:
    		lb $t1, ($t0) #o valor do primeiro caractere da string 1 $t1 = 49
    		lwc1 $f2, zero
    		lwc1 $f3, zero
    		lwc1 $f4, zero
    		lwc1 $f5, zero
    		lwc1 $f6, zero
  	analisa:
    		beq $t1, 10, quebraLinha
    		beq $t1, 46, decimal
    		beq $t1, 44, proximo
    		beq $t1, $zero, fim
    		beq $t1, 3, fim
    		beq $t1, 13, quebraLinha
    		sub $t1, $t1, 48
    		mtc1 $t1, $f2
    		cvt.s.w $f2, $f2 # o valor est� em float
  	continua:
      		addi $t0, $t0, 1
      		lb $t1, ($t0)
      		beq $t1, 10, proximo
      		beq $t1, 44, proximo
      		beq $t1, 13, proximo
      		beq $t1, 46, decimal
      		beq $t1, 0, fim
      		beq $t1, 3, fim
      		sub $t1, $t1, 48
      		mtc1 $t1, $f3
      		cvt.s.w $f3, $f3 # o valor est� em float
      		mul.s $f2, $f2, $f1
      		add.s $f2, $f2, $f3
      		j continua
  
  
	decimal:
    		li $t7, 1 #contador de casas decimais
    		addi $t0, $t0, 1
    		lb $t1, ($t0)
    		beq $t1, 44, proximo
    		beq $t1, 10, proximo
    		sub $t1, $t1, 48
    		mtc1 $t1, $f4
    		cvt.s.w $f4, $f4
    		div.s $f4, $f4, $f1
    
    	loop_decimal:
      		addi $t0, $t0, 1
      		lb $t1, ($t0)
      		beq $t1, 44, proximo
      		beq $t1, 10, proximo
      		li $t9, 0 #vezes que o loop de divisao deve iteragir
      		addi $t7, $t7, 1
      		sub $t1, $t1, 48
      		mtc1 $t1, $f5
      		cvt.s.w $f5, $f5
      	
      	loop_divisao:
        	beq $t9, $t7, continua_decimal
        	div.s $f5, $f5, $f1
        	addi $t9, $t9, 1  
        	j loop_divisao
      	
      	continua_decimal:
      		add.s $f4, $f4, $f5
      		j loop_decimal
      
  	quebraLinha:
  		addi $t0, $t0, 1
  		j aloca
  
  	proximo: # +1 linha
    		add.s $f7, $f2, $f4
    		li $t1, 4
    		div $a0, $t1
    		mfhi $t1
    		sub $a0, $a0, $t1
    		addi $t4, $t4, 1
  	aligned:

    		s.s $f7, 0($a0)
    		l.s $f13, 0($a0)
    
    		addi $a0, $a0, 4
    		addi $t0, $t0, 1
    
    		j aloca
  
  	fim:
    		addi $t4, $t4, 1
    		add.d $f7, $f2, $f4
    		li $t1, 8
  		# Armazenar o valor convertido em vetXTrain
    		s.d $f7, 0($a0)
  		# Carregar o valor de vetXTrain para $f13
    		div $t4, $t1
    		mflo $t4
    		li $v0, 16
    		move $a0, $t8
    		syscall
    		li $v0, 2
    		move $f12, $f13
    		jr $ra
