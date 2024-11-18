    .data
array:  .word 1, 2, 3, 4, 5,                           # Exemplo de array de entrada
n:      .word 2                                         # Parâmetro (número de elementos por linha)
output: .space 400                                      # Reservar espaço para a matriz
prompt: .asciiz "Matriz final:\n"                       # Mensagem de prompt

    .text
    .globl main

main:
    la $a0, array                                        # Endereço do array de entrada
    lw $a1, n                                            # Carregar o parâmetro (número de elementos por linha)
    la $a2, output                                       # Endereço da matriz de saída
    jal generate_matrix                                   # Chamar a função generate_matrix

    # Imprimir a matriz
    li $v0, 4                                            # Código de serviço para imprimir string
    la $a0, prompt                                       # Carregar a mensagem de prompt
    syscall

    li $t0, 0                                            # Inicializar contador de linhas
    li $t1, 4                                            # Total de pares possíveis (5 elementos => 4 pares)

print_matrix:
    # Calcular o endereço do elemento na matriz
    sll $t2, $t0, 3                                      # Multiplicar o índice da linha por 8 (2 elementos * 4 bytes cada)
    add $t3, $a2, $t2                                    # Endereço do início da linha

    # Imprimir o primeiro elemento da linha
    lw $t4, 0($t3)                                       # Carregar o primeiro elemento
    li $v0, 1                                            # Código de serviço para imprimir inteiro
    move $a0, $t4                                        # Mover o inteiro para $a0
    syscall

    # Imprimir o segundo elemento da linha
    lw $t4, 4($t3)                                       # Carregar o segundo elemento
    move $a0, $t4                                        # Mover o inteiro para $a0
    syscall

    # Imprimir nova linha
    li $v0, 11                                           # Código de serviço para imprimir caractere
    li $a0, 10                                           # Código ASCII para nova linha
    syscall

    # Avançar para a próxima linha
    addi $t0, $t0, 1                                     # Incrementar contador de linhas
    bne $t0, $t1, print_matrix                           # Continuar até imprimir todos os pares

    # Encerrar o programa
    li $v0, 10                                           # Código de serviço para encerrar o programa
    syscall

# Função: generate_matrix
# Parâmetros:
#   $a0: endereço do array de entrada
#   $a1: número de elementos por linha
#   $a2: endereço da matriz de saída

generate_matrix:
    li $t0, 0                                            # Inicializar índice da matriz (linha)
    li $t3, 0                                            # Inicializar índice do array de entrada

loop:
    lw $t1, n                                            # Carregar número de elementos por linha
    lw $t2, array + 16                                   # Carregar o tamanho do array (5)
    bge $t3, $t2, end                                    # Se o índice do array for maior ou igual ao tamanho, sair

    # Calcular o endereço na matriz de saída
    sll $t4, $t0, 3                                      # Multiplicar índice da linha por 8 (2 elementos * 4 bytes cada)
    add $t6, $a2, $t4                                    # Endereço da linha na matriz

    # Preencher os elementos da linha
    lw $t5, 0($a0)                                       # Carregar o elemento atual do array
    sw $t5, 0($t6)                                       # Armazenar o primeiro elemento
    addi $a0, $a0, 4                                     # Avançar para o próximo elemento do array
    lw $t5, 0($a0)                                       # Carregar o próximo elemento
    sw $t5, 4($t6)                                       # Armazenar o segundo elemento

    addi $t0, $t0, 1                                     # Incrementar o índice da matriz
    addi $t3, $t3, 1                                     # Incrementar o índice do array (2 elementos)
    j loop                                               # Repetir o loop

end:
    jr $ra                                               # Retornar da função
