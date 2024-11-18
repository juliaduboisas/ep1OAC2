# Este arquivo executa o algoritmo knn em um xtrain, xteste e ytrain prontos
# Por simplicidade, estes 3 estarão prontos na seção data
# As entradas assumem w = 3 e h = 1

.data
################## PARAMETROS DE LEITURA E ESCRITA
	# caminhos dos arquivos
	pathXTrain: .asciiz "data/Xtrain.txt"
	pathXTest: .asciiz "data/Xtest.txt"
	
	# buffer
	buffer: .space 10000
	
	spaceX: .space 10000
	
	# floats necessarios para os calculos
	fp1: .double 48.00
	fp2: .double 10.00
	fp3: .double 1.00
	
	
################## PARAMETROS DA GABI

#######  PARÂMETROS PARA GERAR A MATRIZ DO XTRAIN O YTRAIN DA GABI

	xtrain: .double 4.99, 5.67, 9.134, 5.67, 9.134, 7.567, 9.134, 7.567, 8.547, 7.567, 8.547, 9.88, 8.547, 9.88, 5.32, 9.88, 5.32, 6.12, 5.32, 6.12, 9.44
	ntrain: .word 21      #tamanho do array de entrada (futuramente será a quantidade de pontos do input)
	xtrain1: .space 400    #aloca espaço para os array de saida da matriz     $t6
	ytrain: .space 400

#######  ENTRADAS PARA GERAR MATRIZ DO XTEST DA GABI 
	xtest: .double 7.567, 8.547, 9.88, 10.00, 10.768, 11.4356, 4.99, 5.67, 9.134, 7.567, 8.547, 9.88, 5.32, 6.12, 9.44
	ntest:  .word 15
	xtest1: .space 400                                                      # $t9


#######  PARAMETROS GERAIS DA GABI 
	w:      .word 3      #parametro utilizado para criar a matriz
	h:      .word 1      #parametro de previsao

	zerof: .double 0.0

#PARAMETROS USADOS NO KNN
	newline: .asciiz "\n"
	space: .asciiz " "
	interArray: .asciiz "Intermediate array:\n"
	interArraySorted: .asciiz "Sorted intermediate array:\n"
	ytest: .asciiz "Y-TEST:"
	separation: .asciiz "///////////////////////////////////////////////////////////////////////////\n"
.text

# PARAMETROS USADOS NA LEITURA E ESCRITA DE ARQUIVOS


#ANOTACOES
## PARA LEITURA DOS TXT:
### A1: XTRAIN
### E DEPOIS A1: XTEST

### MATRIZES DOS X FICAM ARMAZENADAS EM T8 (XTRAIN) E T9 (XTEST) 

################################################### LEITURA DO XTRAIN1 ####################################################
leituraXTrain:
	# Carregar xtest
	la $a0, pathXTrain # descobre qual arquivo abrir
	la $t6, buffer  # carrega o tamanho do buffer onde guardar o conteudo
	li $a3, 0 # carrega 0 no registrador a3
	j carregaParaMatrizXTrain
	
carregaParaMatrizXTrain:
	descobreNumLinhasXTrain:
		li $a1, 0 # determina modo leitura
		li $v0, 13 # syscall para ler 
		syscall
	
		move $t5, $v0 # salva o endereço do descritor em $t5 para fechar o arquivo posteriormente
	
		move $a0, $t5 # salva o endereço do descritor em $a0 para quando for abrir o arquivo novamente
		# PRECISAMOS TER O ENDEREÇO DO DESCRITOR SALVO NOS DOIS ARQUIVOS!!!
		li $v0, 14 # ler conteúdo do arquivo referenciado por $a0
		la $a1, spaceX # buffer que armazena o conteudo do arquivo
		add $a2, $a2, $t6 # tamanho do buffer
		syscall # leitura realizada
		
		#li $v0, 4
		#move $a0, $a1 # como imprime o que esta em $a0 precisa mover o conteudo que esta em $a1
		#syscall´
		
		move $t0, $a1 # salva onde fica o buffer
		
		loopContaLinhasXTrain:
			lb $t1, 0($a1)		
			beq $t1, 46, maisLinhaXTrain
			beq $t1, $zero, fimNumLinhasXTrain
			bne $t1, $zero, proxLinhaXTrain

			
		 	
		fimNumLinhasXTrain:
			li $v0, 16
			move $a0, $t5 # bota o endereco do descritor de volta em a0
			syscall
			
			li $v0, 1
			move $t2, $a3
			move $a0, $a3
			syscall
			move $a0, $t5
			
			j transformaEmArrayXTrain
			
			
		maisLinhaXTrain:
				add $a3, $a3, 1
				j proxLinhaXTrain
				
		proxLinhaXTrain:
				add $a1, $a1, 1
				j loopContaLinhasXTrain

	transformaEmArrayXTrain:
		move $a1, $t0 # volta a1 para o inicio do buffer
		
		# ALOCANDO ESPACO DO ARRAY
		mul $t4, $a3, 8 # t4 = numeroDeLinhas (ou seja, de numeros) * sizeof(double)
		li $v0, 9 # chamada ao sistema para malloc
		move $t5, $a0
		move $a0, $t4 # colocando o tamanho necessario em a0 para a syscall
		syscall	# ESPACO DO ARRAY ALOCADO
		
		move $s0, $v0 # SALVANDO PONTEIRO
		move $s1, $s0 # PONTEIRO QUE VOU USAR PARA ANDAR NO ARRAY
		move $a0, $t5 # recolocando o valor de $a0
		
		li $t3, 1 # estou usando 1 para primeiro inteiro, 2 para outros inteiros, 3 pra primeiro decimal, 4 para outros decimais, 5 para o ultimo numero do array
		
		l.d $f6, fp1
		l.d $f8, fp2
		l.d $f14, fp3
		
		l.d $f2, zerof # uso pra armazenar inteiro
		l.d $f4, zerof # uso pra armazenar decimal
		l.d $f10, zerof # uso como temporario
		
		loopTransformaCharXTrain:
			lb $t1, 0($t0)
			l.d $f0, 0($s1) # NAO SEI SE POSSO FAZER
			l.d $f10, zerof
			
			beq $t1, 10, proxNumeroXTrain # checa se chegou no fim da linha
			beq $t1, 13, proxNumeroXTrain # checa se chegou no fim da linha
			beq $t1, $zero, fimTransformacaoXTrain # checa se chegou no fim do arquivo
			beq $t1, 3, fimTransformacaoXTrain # checa se chegou no fim do arquivo
			beq $t1, 46, marcaDecimalXTrain # checa se chegou no "."
			beq $t3, 1, inteiroXTrain # t3 marca que tipo de numero adicionar
			beq $t3, 2, inteiroLoopXTrain
			beq $t3, 3, decimalXTrain
			beq $t3, 4, decimalLoopXTrain
			blt $t1, 48, pulaCharXTrain
			bgt $t1, 58, pulaCharXTrain
			
			pulaCharXTrain:
				l.d $f2, zerof # uso pra armazenar inteiro
				l.d $f4, zerof # uso pra armazenar decimal
				li $t3, 1 # avisa que o proximo e inicio de um inteiro
				add $t0, $t0, 1
				
				j loopTransformaCharXTrain
			
			inteiroXTrain:
				bgt $t3, 1, inteiroLoopXTrain # se nao for o primeiro inteiro para pro prox loop de inteiros
				sub $t1, $t1, '0' # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mov.d $f2, $f10 # bota no registrador que estou usando para guardar um inteiro
				add $t0, $t0, 1 # passa para o prox numero
				li $t3, 2 # avisa que o proximo e pelo menos segundo de um inteiro
				j loopTransformaCharXTrain
			
			inteiroLoopXTrain:
				bgt $t3, 2, decimalXTrain # se nao for inteiro passa pro loop de decimal
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mul.d $f2, $f2, $f8 # multiplica o antigo por 10.00
				add.d $f2, $f2, $f10 # soma o valor atual com o valor antigo
				add $t0, $t0, 1
				j loopTransformaCharXTrain
			
			marcaDecimalXTrain:
				bgt $t3, 2, decimalXTrain
				li $t3, 3 # marca que o proximo e pelo menos o primeiro decimal
				add $t0, $t0, 1 # passa para o prox numero
				j loopTransformaCharXTrain
			
			decimalXTrain:
				bgt $t3, 3, decimalLoopXTrain
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mov.d $f4, $f10 # bota no registrador que estou usando para guardar um decimal
				add $t0, $t0, 1 # passa para o prox numero
				li $t3, 4
				j loopTransformaCharXTrain
				
			decimalLoopXTrain:
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mul.d $f4, $f4, $f8 # multiplica o antigo por 10.00
				add.d $f4, $f4, $f10 # soma o valor atual com o valor antigo
				add $t0, $t0, 1 # passa para o prox numero
				j loopTransformaCharXTrain
				
			proxNumeroXTrain:
				# CALCULO DO NUMERO
				# transforma o decimal em um numero menor que 1
				c.lt.d $f4, $f14
				bc1f 0, loopTransformaDecimalXTrain
				
				# adiciona a parte inteira com a parte decimal e guarda em f0 (no array)
				l.d $f10, zerof
				add.d $f10, $f2, $f4 
				s.d $f10, ($s1)
				
				# depois de guardar o numero
				l.d $f2, zerof # uso pra armazenar inteiro
				l.d $f4, zerof # uso pra armazenar decimal
				li $t3, 1 # avisa que o proximo e inicio de um inteiro
				add $t0, $t0, 1
				add $s1, $s1, 8
				
				j loopTransformaCharXTrain
			
			loopTransformaDecimalXTrain:
				div.d $f4, $f4, $f8 # divide o valor em $f4 por 10
				c.lt.d $f4, $f14 # se for UM, $f4 eh decimal; se for 0, $f4 ainda tem parte inteira e precisa ser dividido de novo
				bc1f 0, loopTransformaDecimalXTrain
				bc1t 0, proxNumeroXTrain
			
			fimTransformacaoXTrain:
				li $t3, 5
				
				# NUMERO DE LINHAS NO $a3
				# INICIO DO ARRAY DE ENTRADA NO $s0
				j m1
######################################################### XTRAIN1 #########################################################
m1:      
move $t2, $a3 
lw $a2, w        # parametro w     
lw $t3, h
move $a1, $s0    #inicio do array de entrada
la $t8, xtrain1

la  $a3, zerof

inicializacao: 

li $t1, 0  #iterador 1 anda pelo array de entrada de 1 em 1 
li $s1, 0  #contador confere se é para parar de andar pelo array (vai ate ser igual a t4)

li $t6, 0  #contador  2, quando for igual a w, reinicia
li $t7, 0  #iterador 2


sub  $t4, $t2, $a2  #(n-w)
sub  $t4, $t4, $t3  #(n-w-h)
addi $t4, $t4, 2

li $t5, 0

######    Alocando espaço para o array de retorno 
mul $t3, $t4, $a2

mul $s3, $t3, 8
li $v0, 9 
move $a0, $s3
syscall
move $t8, $v0

j criacao

atualizacao: 
addi $a1, $a1, 8  #proximo elemento do array de entrada
addi $s1, $s1, 1  #incrementa o contador 1

li $t7, 0  #zera iterador 2
sub $t6, $t6, $t6  #zera o contador 2 


criacao:
beq $s1, $t4, leituraXTest  # se temos que para de andar para o array: fi  
beq $t6, $a2, atualizacao # se ja pegamos todos os elementos da linha da matriz: atualizamos

sll $s4, $t7, 3
add $s4, $s4, $a1
l.d $f0, 0($s4)  #carregamos primeiro elemento 

mul $s2, $t5, 8
add $s2, $s2, $t8
sdc1 $f0, 0($s2)  #armazenamos primeiro elemento 


addi $t5, $t5, 1   #apontamos pro proximo endereço pra matriz 
addi $t7, $t7, 1   #apontamos pro proximo elemento do array de entrada
addi $t6, $t6, 1   #atualizamos o contador 2
j criacao

#################################################### IMPRIME XTRAIN 1 ##################################################

# Fim da criação, começa a impressão
impressao:
    li $t1, 0                # Zera o iterador para a impressão

impressao_loop:
    l.d $f12, 0($a3)  
    li $v0, 3               # Código da syscall para imprimir inteiro
    l.d $f12, 0($t8)           # Carrega o valor de saída
    syscall                  # Imprime o número

    addi $t1, $t1, 1         # Incrementa o contador de elementos
    addi $t8, $t8, 8         # Avança para o próximo valor do array (saída)

    # Condição de parada: se terminou de imprimir todos os elementos
    #mul $t3, $t4, $a2
    #li $t3, $t4                # Recarrega o tamanho do array de entrada
    beq $t1, $t3, m2

    # Para impressão, podemos colocar uma quebra de linha entre os valores
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    j impressao_loop         # Continua o loop de impressão

fim_impressao:
    li $v0, 10               # Código da syscall para terminar o programa
    syscall                  # Finaliza o programa




################################################### LEITURA DO XTEST1 ####################################################

leituraXTest:

		# Carregar xtest
	la $a0, pathXTest # descobre qual arquivo abrir
	la $t6, buffer  # carrega o tamanho do buffer onde guardar o conteudo
	li $a3, 0 # carrega 0 no registrador a3
	j carregaParaMatrizXTest
	
carregaParaMatrizXTest:
	descobreNumLinhasXtest:
		li $a1, 0 # determina modo leitura
		li $v0, 13 # syscall para ler 
		syscall
	
		move $t5, $v0 # salva o endereço do descritor em $t5 para fechar o arquivo posteriormente
	
		move $a0, $t5 # salva o endereço do descritor em $a0 para quando for abrir o arquivo novamente
		# PRECISAMOS TER O ENDEREÇO DO DESCRITOR SALVO NOS DOIS ARQUIVOS!!!
		li $v0, 14 # ler conteúdo do arquivo referenciado por $a0
		la $a1, spaceX # buffer que armazena o conteudo do arquivo
		add $a2, $a2, $t6 # tamanho do buffer
		syscall # leitura realizada
		
		#li $v0, 4
		#move $a0, $a1 # como imprime o que esta em $a0 precisa mover o conteudo que esta em $a1
		#syscall´
		
		move $t0, $a1 # salva onde fica o buffer
		
		loopContaLinhasXTest:
			lb $t1, 0($a1)		
			beq $t1, 46, maisLinhaXTest
			beq $t1, $zero, fimNumLinhasXTest
			bne $t1, $zero, proxLinhaXTest

			
		 	
		fimNumLinhasXTest:
			li $v0, 16
			move $a0, $t5 # bota o endereco do descritor de volta em a0
			syscall
			
			li $v0, 1
			move $t5, $a0
			move $t2, $a3
			move $a0, $a3
			syscall
			move $a0, $t5
			
			j transformaEmArrayXTest
			
			
		maisLinhaXTest:
				add $a3, $a3, 1
				j proxLinhaXTest
				
		proxLinhaXTest:
				add $a1, $a1, 1
				j loopContaLinhasXTest

	transformaEmArrayXTest:
		move $a1, $t0 # volta a1 para o inicio do buffer
		
		# ALOCANDO ESPACO DO ARRAY
		mul $t4, $a3, 8 # t4 = numeroDeLinhas (ou seja, de numeros) * sizeof(double)
		li $v0, 9 # chamada ao sistema para malloc
		move $t5, $a0
		move $a0, $t4 # colocando o tamanho necessario em a0 para a syscall
		syscall	# ESPACO DO ARRAY ALOCADO
		
		move $s0, $v0 # SALVANDO PONTEIRO
		move $s1, $s0 # PONTEIRO QUE VOU USAR PARA ANDAR NO ARRAY
		move $a0, $t5 # recolocando o valor de $a0
		
		li $s6, 1 # estou usando 1 para primeiro inteiro, 2 para outros inteiros, 3 pra primeiro decimal, 4 para outros decimais, 5 para o ultimo numero do array
		
		l.d $f6, fp1
		l.d $f8, fp2
		l.d $f14, fp3
		
		l.d $f2, zerof # uso pra armazenar inteiro
		l.d $f4, zerof # uso pra armazenar decimal
		l.d $f10, zerof # uso como temporario
		
		loopTransformaCharXTest:
			lb $t1, 0($t0)
			l.d $f0, 0($s1) # NAO SEI SE POSSO FAZER
			l.d $f10, zerof
			
			beq $t1, 10, proxNumeroXTest # checa se chegou no fim da linha
			beq $t1, 13, proxNumeroXTest # checa se chegou no fim da linha
			beq $t1, $zero, fimTransformacaoXTest # checa se chegou no fim do arquivo
			beq $t1, 3, fimTransformacaoXTest # checa se chegou no fim do arquivo
			beq $t1, 46, marcaDecimalXTest # checa se chegou no "."
			beq $s6, 1, inteiroXTest # s6 marca que tipo de numero adicionar
			beq $s6, 2, inteiroLoopXTest
			beq $s6, 3, decimalXTest
			beq $s6, 4, decimalLoopXTest
			blt $t1, 48, pulaCharXTest
			bgt $t1, 58, pulaCharXTest
			
			pulaCharXTest:
				l.d $f2, zerof # uso pra armazenar inteiro
				l.d $f4, zerof # uso pra armazenar decimal
				li $s6, 1 # avisa que o proximo e inicio de um inteiro
				add $t0, $t0, 1
				
				j loopTransformaCharXTest
			
			inteiroXTest:
				bgt $s6, 1, inteiroLoopXTest # se nao for o primeiro inteiro para pro prox loop de inteiros
				sub $t1, $t1, '0' # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mov.d $f2, $f10 # bota no registrador que estou usando para guardar um inteiro
				add $t0, $t0, 1 # passa para o prox numero
				li $s6, 2 # avisa que o proximo e pelo menos segundo de um inteiro
				j loopTransformaCharXTest
			
			inteiroLoopXTest:
				bgt $s6, 2, decimalXTest # se nao for inteiro passa pro loop de decimal
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mul.d $f2, $f2, $f8 # multiplica o antigo por 10.00
				add.d $f2, $f2, $f10 # soma o valor atual com o valor antigo
				add $t0, $t0, 1
				j loopTransformaCharXTest
			
			marcaDecimalXTest:
				bgt $s6, 2, decimalXTest
				li $s6, 3 # marca que o proximo e pelo menos o primeiro decimal
				add $t0, $t0, 1 # passa para o prox numero
				j loopTransformaCharXTest
			
			decimalXTest:
				bgt $s6, 3, decimalLoopXTest
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mov.d $f4, $f10 # bota no registrador que estou usando para guardar um decimal
				add $t0, $t0, 1 # passa para o prox numero
				li $s6, 4
				j loopTransformaCharXTest
				
			decimalLoopXTest:
				sub $t1, $t1, 48 # NAO SEI SE VAI FUNCIONAR
				mtc1 $t1, $f10 # bota o conteudo de $t1 em $f10 (que uso como registrador temporario)
				cvt.d.w $f10, $f10 # deixa como double
				mul.d $f4, $f4, $f8 # multiplica o antigo por 10.00
				add.d $f4, $f4, $f10 # soma o valor atual com o valor antigo
				add $t0, $t0, 1 # passa para o prox numero
				j loopTransformaCharXTest
				
			proxNumeroXTest:
				# CALCULO DO NUMERO
				# transforma o decimal em um numero menor que 1
				c.lt.d $f4, $f14
				bc1f 0, loopTransformaDecimalXTest
				
				# adiciona a parte inteira com a parte decimal e guarda em f0 (no array)
				l.d $f10, zerof
				add.d $f10, $f2, $f4 
				s.d $f10, ($s1)
				
				# depois de guardar o numero
				l.d $f2, zerof # uso pra armazenar inteiro
				l.d $f4, zerof # uso pra armazenar decimal
				li $s6, 1 # avisa que o proximo e inicio de um inteiro
				add $t0, $t0, 1
				add $s1, $s1, 8
				
				j loopTransformaCharXTest
			
			loopTransformaDecimalXTest:
				div.d $f4, $f4, $f8 # divide o valor em $f4 por 10
				c.lt.d $f4, $f14 # se for UM, $f4 eh decimal; se for 0, $f4 ainda tem parte inteira e precisa ser dividido de novo
				bc1f 0, loopTransformaDecimalXTest
				bc1t 0, proxNumeroXTest
			
			fimTransformacaoXTest:
				li $s6, 5
				
				# NUMERO DE LINHAS NO $a3
				# INICIO DO ARRAY NO $s0
				
				jal m2

###################################################### XTEST1 ########################################

m2:
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    

move $t2, $a3 # numero de linhas
lw $a2, w        # parametro w     
la  $a3, zerof
lw $a3, h
move $a1, $s0    #inicio do array de entrada
la $t9, xtest1


inicializacao1: 

li $t1, 0  #iterador 1 anda pelo array de entrada de 1 em 1 
li $s1, 0  #contador confere se é para parar de andar pelo array (vai ate ser igual a t4)

li $t5, 0
li $t1, 0  #contador  2, quando for igual a w, reinicia
li $t7, 0  #iterador 2
li $t4, 0
li $s4, 0

sub  $t4, $t2, $a2  #(n-w)
sub  $t4, $t4, $a3  #(n-w-h)
addi $t4, $t4, 2

li $t5, 0
mul $t2, $t4, $a2

mul $s3, $t2, 8
li $v0, 9 
move $a0, $s3
syscall
move $t9, $v0

j criacao1

atualizacao1: 
addi $a1, $a1, 8  #proximo elemento do array de entrada
addi $s1, $s1, 1  #incrementa o contador 1

li $t7, 0  #zera iterador 2
sub $t1, $t1, $t1  #zera o contador 2 


criacao1:
beq $s1, $t4, arrayy  # se temos que para de andar para o array: fi 
beq $t1, $a2, atualizacao1 # se ja pegamos todos os elementos da linha da matriz: atualizamos

sll $s4, $t7, 3 
add $s4, $s4, $a1
l.d  $f14, 0($s4)  #carregamos primeiro elemento 

mul $s5, $t5, 8
add $s5, $s5, $t9
sdc1 $f14, 0($s5)  #armazenamos primeiro elemento 


addi $t5, $t5, 1   #apontamos pro proximo endereço pra matriz 
addi $t7, $t7, 1   #apontamos pro proximo elemento do array de entrada
addi $t1, $t1, 1   #atualizamos o contador 2
j criacao1

################################################# IMRPIME O XTEST1 #############################################

# Fim da criação, começa a impressão
impressao1:
    li $t1, 0                # Zera o iterador para a impressão
    la  $a3, zerof
impressao_loop1:

    l.d $f12, 0($a3)  
    li $v0, 3               # Código da syscall para imprimir inteiro
    l.d $f12, 0($t9)           # Carrega o valor de saída
    syscall                  # Imprime o número

    addi $t1, $t1, 1         # Incrementa o contador de elementos
    addi $t9, $t9, 8         # Avança para o próximo valor do array (saída)

    # Condição de parada: se terminou de imprimir todos os elementos
    #mul $t3, $t4, $a2
    #li $t3, $t4                # Recarrega o tamanho do array de entrada
    beq $t1, $t2, arrayy

    # Para impressão, podemos colocar uma quebra de linha entre os valores
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    j impressao_loop1         # Continua o loop de impressão

fim_impressao1:
    li $v0, 10               # Código da syscall para terminar o programa
    syscall                  # Finaliza o programa

################################################## YTEST OBRIGADA DEUS  ##############################################
arrayy:
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    
    la  $s5, zerof
    lw $s5, ntrain
    lw $a3, w        # parametro w     
    lw $t4, h
    la $a1, xtrain    #inicio do array de entrada
    la $a2, ytrain    #inicio do array de saída

    add $t5, $a3, $t4
    subi $t5, $t5, 1
    move $s4, $t5
    sub $s7, $s5, $s4 

    li $t6, 0
    li $t7, 0
    li $t1, 0 
    li $s1, 0

    ####### Aloca espaço para o retorno final 

    mul $s3, $s7, 8      # Multiplica o número de elementos por 8 (pois cada double tem 8 bytes)
    li $v0, 9            # Chama o serviço de alocação dinâmica
    move $a0, $s3        # Passa o tamanho do espaço
    syscall
    move $a2, $v0        # Armazena o ponteiro de alocação em $a2

createarray:
    beq $s1, $s7, main

    # Calcular o índice no array de entrada xtrain
    sll $t6, $t5, 3             # Multiplica o índice por 8 para acessar o double (8 bytes)
    add $t6, $t6, $a1           # Adiciona o endereço base de xtrain
    l.d  $f12, 0($t6)           # Carrega o valor do double de xtrain para $f12

    # Calcular o índice no array de saída ytrain
    mul $t7, $t1, 8             # Multiplica o índice da saída por 8 (pois cada double tem 8 bytes)
    add $t7, $t7, $a2           # Adiciona o endereço base de ytrain
    sdc1 $f12, 0($t7)           # Armazena o valor em ytrain

    # Atualiza os índices
    addi $t5, $t5, 1            # Avança o índice do array xtrain
    addi $t1, $t1, 1            # Avança o índice do array ytrain
    addi $s1, $s1, 1            # Incrementa o contador
    j createarray

impressao2:
    li $t1, 0                    # Inicializa contador para impressão

impressao_loop2:
    l.d $f12, 0($a2)             # Carrega o próximo valor de ytrain
    li $v0, 3                    # Syscall para imprimir double
    syscall

    addi $t1, $t1, 1             # Incrementa contador de elementos
    addi $a2, $a2, 8             # Avança o ponteiro para o próximo double

    # Verifica se todos os elementos foram impressos
    beq $t1, $s7, main
    
    # Imprime nova linha para separação dos números
    li $v0, 11                   # Código da syscall para imprimir caractere
    li $a0, 10                   # Código ASCII de '\n' (nova linha)
    syscall

    j impressao_loop2            # Continua o loop de impressão

fim_impressao2:
    li $v0, 10                   # Código da syscall para terminar o programa
    syscall                      # Finaliza o programa


########## registrador do xtrain1       $t8
########## tamanho do xtrain1           $t3 (considerando o "0")
########## registrador do xtest1        $t9
########## tamanho do xtest1            $t2 (considerando o "0")
########## registrador do ytrain        $a2
########## tamanho do ytrain             $s7
########## último reg que o W foi alocado $a3


main:
	la  $s5, zerof
	addi $k0, $0, 2		# $k0 será o k
	add $k1, $0, $a3		# $k1 será o m
	
	# ZERA ALGUNS REGS
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $a1, 0
	li $a0, 0
	li $t0, 0 
	li $t1, 0 
	l.s $f12, 0($s5)  
	l.s $f0, 0($s5)  
	l.s $f4, 0($s5)  
	
	# ALOCA INPUTS 
	move $s1, $t8     ####end de xtrain1 
	move $s2, $t9     ####end de xtest1
	move $s3, $a2     ####end de ytrain
	
	# TAMANHOS DOS ARRAYS
	add $t0, $0, $t2	        # tamanho de xtest
	add $t1, $0, $t3               # tamanho de xtrain
	add $t2, $0, $s7		# tamanho de ytrain
	
	div $t3, $t0, $k1		# tamanho de ytest (xtest / m)

	# ALOCA ARRAY INT. E YTEST
	jal adjustsp
	div $t4, $t1, $k1
	mul $t4, $t4, 16	# o tamanho do array a ser alocado precisa ser do tamanho xtrain/m * 16, seria 12 mas é preciso ser divisivel por 8
	add $s4, $0, $sp	# $s4 será o array intermediário, de tamanho $t4
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
	la, $a0, ytest #ytest
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
					
					
