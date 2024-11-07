	.data
array:  .word 1, 2, 3, 4, 5, 6, 15, 10, 40, 70 , 23, 10    #Exemplo de array de entrada
w:      .word 3  
h:      .word 1
n:      .word 12 #tamanho do array de entrada (futuramente será a quantidade de pontos do input)
saida: .space 400  
  
        .text
        .global main  
        
          
lw $t2, n 
lw $a2, w        # parametro w     
lw $t3, h
la $a1, array    #inicio do array de entrada
la $t6, saida

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



# Fim da criação, começa a impressão
impressao:
    li $t1, 0                # Zera o iterador para a impressão

impressao_loop:
    lw $a0, 0($t6)           # Carrega o valor de saída
    li $v0, 1                # Código da syscall para imprimir inteiro
    syscall                  # Imprime o número

    addi $t1, $t1, 1         # Incrementa o contador de elementos
    addi $t6, $t6, 4         # Avança para o próximo valor do array (saída)

    # Condição de parada: se terminou de imprimir todos os elementos
    mul $t3, $t4, $a2
    #li $t3, $t4                # Recarrega o tamanho do array de entrada
    beq $t1, $t3, fim_impressao

    # Para impressão, podemos colocar uma quebra de linha entre os valores
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    j impressao_loop         # Continua o loop de impressão

fim_impressao:
    li $v0, 10               # Código da syscall para terminar o programa
    syscall                  # Finaliza o programa
