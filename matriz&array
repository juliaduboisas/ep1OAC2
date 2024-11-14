	.data
array:  .float 4.99, 5.67, 9.134, 7.567, 8.547, 9.88, 5.32, 6.12, 9.44  #Exemplo de array de entrada
w:      .word 3      #parametro utilizado para criar a matriz
h:      .word 1      #parametro de previsao
n:      .word 9      #tamanho do array de entrada (futuramente será a quantidade de pontos do input)
saida1: .space 400    #aloca espaço para os array de saida da matriz
saida2: .space 400
zerof: .float 0.0
  
        .text
        .global main  
        

la  $a3, zerof
l.s $f12, 0($a3)        

lw $t2, n 
lw $a2, w        # parametro w     
lw $t3, h
la $a1, array    #inicio do array de entrada
la $t6, saida1

inicializacao: 

li $t1, 0  #iterador 1 anda pelo array de entrada de 1 em 1 
li $s1, 0  #contador confere se é para parar de andar pelo array (vai ate ser igual a t4)

li $t8, 0  #contador  2, quando for igual a w, reinicia
li $t7, 0  #iterador 2

sub  $t4, $t2, $a2  #(n-w)
sub  $t4, $t4, $t3  #(n-w-h)
addi $t4, $t4, 2

li $t5, 0

j criacao

atualizacao: 
addi $a1, $a1, 4  #proximo elemento do array de entrada
addi $s1, $s1, 1  #incrementa o contador 1

li $t7, 0  #zera iterador 2
sub $t8, $t8, $t8  #zera o contador 2 


criacao:
beq $s1, $t4, impressao  # se temos que para de andar para o array: fi  
beq $t8, $a2, atualizacao # se ja pegamos todos os elementos da linha da matriz: atualizamos

sll $s4, $t7, 2 
add $s4, $s4, $a1
lw  $s3, 0($s4)  #carregamos primeiro elemento 

sll $s5, $t5, 2
add $s5, $s5, $t6
sw  $s3, 0($s5)  #armazenamos primeiro elemento 


addi $t5, $t5, 1   #apontamos pro proximo endereço pra matriz 
addi $t7, $t7, 1   #apontamos pro proximo elemento do array de entrada
addi $t8, $t8, 1   #atualizamos o contador 2
j criacao


#-------------------------------------------TESTE PARA A MATRIZ--------------------------


impressao:
    li $t1, 0                # Zera o iterador para a impressão

impressao_loop:
    l.s $f12, 0($a3)  
    li $v0, 2                # Código da syscall para imprimir inteiro
    l.s $f12, 0($t6)           # Carrega o valor de saída
    syscall                  # Imprime o número

    addi $t1, $t1, 1         # Incrementa o contador de elementos
    addi $t6, $t6, 4         # Avança para o próximo valor do array (saída)

    # Condição de parada: se terminou de imprimir todos os elementos
    mul $t3, $t4, $a2
    #li $t3, $t4                # Recarrega o tamanho do array de entrada
    beq $t1, $t3, fazarray

    # Para impressão, podemos colocar uma quebra de linha entre os valores
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    j impressao_loop         # Continua o loop de impressão
    
    
fazarray:
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
la  $s5, zerof
        
lw $t2, n 
lw $a3, w        # parametro w     
lw $t4, h
la $a1, array    #inicio do array de entrada
la $a2, saida2


add $t5, $a3, $t4
subi $t5, $t5, 1  #calculo do numero do elemento o qual vai ser o inicio do array de saida ($t5)
move $s4, $t5
sub $s3, $t2, $s4 #calculo do numero do elemento final ate onde o loop vai rodar

li $t6, 0
li $t7, 0
li $t8, 0 
li $s1, 0


createarray:
beq $s1, $s3, impressao2

#carrega elementos do array de entrada
sll $t6, $t5, 2
add $t6, $t6, $a1
l.s  $f0, 0($t6)

#aloca elementos no array de saida
sll $t9, $t8, 2
add $t9, $t9, $a2
s.s $f0, 0($t9)

#atualiza iteradores
addi $t5, $t5, 1
addi $t8, $t8, 1
addi $s1, $s1, 1
j createarray 

#---------------------------------------TESTE PARA ARRAY---------------------------------
impressao2:
    li $t1, 0
                    
impressao_loop2:
    l.s $f12, 0($s5)  
    li $v0, 2                # Código da syscall para imprimir inteiro
    l.s $f12, 0($a2)           # Carrega o valor de saída
    syscall                  # Imprime o número

    addi $t1, $t1, 1         # Incrementa o contador de elementos
    addi $a2, $a2, 4   
          # Avança para o próximo valor do array (saída)
            
    beq $t1, $s3, fim_impressao
    
    # Para impressão, podemos colocar uma quebra de linha entre os valores
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    j impressao_loop2         # Continua o loop de impressão

fim_impressao:
    li $v0, 10               # Código da syscall para terminar o programa
    syscall                  # Finaliza o programa

  
    
      
          
