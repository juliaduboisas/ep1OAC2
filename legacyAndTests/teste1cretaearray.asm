	.data
array:  .word 1, 2, 3, 4, 5, 6, 15, 10   #Exemplo de array de entrada
w:      .word 3  
h:      .word 1
n:      .word 8 #tamanho do array de entrada (futuramente será a quantidade de pontos do input)
saida: .space 400  
  
        .text
        .global main 
        
lw $t2, n 
lw $a3, w        # parametro w     
lw $t4, h
la $a1, array    #inicio do array de entrada
la $a2, saida

add $t5, $a3, $t4
subi $t5, $t5, 1
move $s4, $t5
sub $s3, $t2, $s4 

li $t6, 0
li $t7, 0
li $t8, 0 
li $s1, 0


createarray:
beq $s1, $s3, impressao

sll $t6, $t5, 2
add $t6, $t6, $a1
lw  $t7, 0($t6)

sll $t9, $t8, 2
add $t9, $t9, $a2
sw $t7, 0($t9)

addi $t5, $t5, 1
addi $t8, $t8, 1
addi $s1, $s1, 1
j createarray 


impressao:
    li $t1, 0
                    
impressao_loop:
    lw $a0, 0($a2)           # Carrega o valor de saída
    li $v0, 1                # Código da syscall para imprimir inteiro
    syscall                  # Imprime o número

    addi $t1, $t1, 1         # Incrementa o contador de elementos
    addi $a2, $a2, 4   
          # Avança para o próximo valor do array (saída)
            
    beq $t1, $s3, fim_impressao
    
    # Para impressão, podemos colocar uma quebra de linha entre os valores
    li $v0, 11               # Código da syscall para imprimir caractere
    li $a0, 10               # Código ASCII de '\n' (nova linha)
    syscall                  # Imprime a quebra de linha
    j impressao_loop         # Continua o loop de impressão

fim_impressao:
    li $v0, 10               # Código da syscall para terminar o programa
    syscall                  # Finaliza o programa







