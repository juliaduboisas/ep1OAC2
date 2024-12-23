	.data
	
#######  PARÂMETROS PARA GERAR A MATRIZ DO XTRAIN O YTRAIN

xtrain: .double 4.74, 5.0, 9.0, 7.0, 8.0
ntrain: .word 5      #tamanho do array de entrada (futuramente será a quantidade de pontos do input)
xtrain1: .space 800  #aloca espaço para os array de saida da matriz     $t6
ytrain: .space 400 

#######  ENTRADAS PARA GERAR MATRIZ DO XTEST
xtest: .double 4.9, 5.6, 9.1, 5.6, 9.1 
ntest:  .word 5
xtest1: .space 800                                                   # $t9


#######  PARAMETROS GERAIS
w:      .word 3      #parametro utilizado para criar a matriz
h:      .word 1      #parametro de previsao

zerof: .double 0.0
  
  
        .text 

#########################################  CRIA A MERDA DO XTRAIN1 #########################################################
m1:
la  $a3, zerof
      
lw $t2, ntrain 
lw $a2, w        # parametro w     
lw $t3, h
la $a1, xtrain    #inicio do array de entrada
la $t8, xtrain1

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
beq $s1, $t4, impressao  # se temos que para de andar para o array: fi  
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

############################################## IMPRIME A MERDA DO XTRAIN 1 ##################################################

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




#############################################CRIA A DISGRAÇA DO XTEST1 ########################################

m2:
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    
    
la  $a3, zerof
      
lw $t2, ntest
lw $a2, w        # parametro w     
lw $t3, h
la $a1, xtest    #inicio do array de entrada
la $t9, xtest1

inicializacao1: 

li $t1, 0  #iterador 1 anda pelo array de entrada de 1 em 1 
li $s1, 0  #contador confere se é para parar de andar pelo array (vai ate ser igual a t4)

li $t5, 0
li $t8, 0  #contador  2, quando for igual a w, reinicia
li $t7, 0  #iterador 2
li $t4, 0
li $s4, 0

sub  $t4, $t2, $a2  #(n-w)
sub  $t4, $t4, $t3  #(n-w-h)
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
sub $t8, $t8, $t8  #zera o contador 2 


criacao1:
beq $s1, $t4, impressao1  # se temos que para de andar para o array: fi  
beq $t8, $a2, atualizacao1 # se ja pegamos todos os elementos da linha da matriz: atualizamos

sll $s4, $t7, 3 
add $s4, $s4, $a1
l.d  $f14, 0($s4)  #carregamos primeiro elemento 

mul $s5, $t5, 8
add $s5, $s5, $t9
sdc1 $f14, 0($s5)  #armazenamos primeiro elemento 


addi $t5, $t5, 1   #apontamos pro proximo endereço pra matriz 
addi $t7, $t7, 1   #apontamos pro proximo elemento do array de entrada
addi $t8, $t8, 1   #atualizamos o contador 2
j criacao1

########################################## IMRPIME O XTEST1 CERTO SE DEUS QUISER################################

# Fim da criação, começa a impressão
impressao1:
    li $t1, 0                # Zera o iterador para a impressão

impressao_loop1:
    l.d $f12, 0($a3)  
    li $v0, 3               # Código da syscall para imprimir inteiro
    l.d $f12, 0($t9)           # Carrega o valor de saída
    syscall                  # Imprime o número

    addi $t1, $t1, 1         # Incrementa o contador de elementos
    addi $t9, $t9, 8         # Avança para o próximo valor do array (saída)

    # Condição de parada: se terminou de imprimir todos os elementos
    mul $t3, $t4, $a2
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


#########################################FAZ O YTEST OBRIGADA DEUS##############################################
arrayy:
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    
    la  $s5, zerof
    lw $t2, ntrain
    lw $a3, w        # parametro w     
    lw $t4, h
    la $a1, xtrain    #inicio do array de entrada
    la $a2, ytrain    #inicio do array de saída

    add $t5, $a3, $t4
    subi $t5, $t5, 1
    move $s4, $t5
    sub $s7, $t2, $s4 

    li $t6, 0
    li $t7, 0
    li $t8, 0 
    li $s1, 0

    ####### Aloca espaço para o retorno final 

    mul $s3, $s7, 8      # Multiplica o número de elementos por 8 (pois cada double tem 8 bytes)
    li $v0, 9            # Chama o serviço de alocação dinâmica
    move $a0, $s3        # Passa o tamanho do espaço
    syscall
    move $a2, $v0        # Armazena o ponteiro de alocação em $a2

createarray:
    beq $s1, $s7, impressao2

    # Calcular o índice no array de entrada xtrain
    sll $t6, $t5, 3             # Multiplica o índice por 8 para acessar o double (8 bytes)
    add $t6, $t6, $a1           # Adiciona o endereço base de xtrain
    l.d  $f12, 0($t6)           # Carrega o valor do double de xtrain para $f12

    # Calcular o índice no array de saída ytrain
    mul $t9, $t8, 8             # Multiplica o índice da saída por 8 (pois cada double tem 8 bytes)
    add $t9, $t9, $a2           # Adiciona o endereço base de ytrain
    sdc1 $f12, 0($t9)           # Armazena o valor em ytrain

    # Atualiza os índices
    addi $t5, $t5, 1            # Avança o índice do array xtrain
    addi $t8, $t8, 1            # Avança o índice do array ytrain
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
    beq $t1, $s7, fim_impressao2
    
    # Imprime nova linha para separação dos números
    li $v0, 11                   # Código da syscall para imprimir caractere
    li $a0, 10                   # Código ASCII de '\n' (nova linha)
    syscall

    j impressao_loop2            # Continua o loop de impressão

fim_impressao2:
    li $v0, 10                   # Código da syscall para terminar o programa
    syscall                      # Finaliza o programa
