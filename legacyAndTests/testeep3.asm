.data
array:  .word 1, 2, 3, 4, 5,                           # Exemplo de array de entrada
n:      .word 3                                     # Parâmetro (número de elementos por linha)
size:   .word 5                                     # Tamanho do array de entrada
output: .space 400                                  # Reservar espaço para a matriz
prompt: .asciiz "Matriz final:\n"                   # Mensagem de prompt

.text
.globl main

main:
    la $a0, array                                    # Endereço do array de entrada
    lw $a1, n                                        # Carregar o número de elementos por linha
    la $a2, output                                   # Endereço da matriz de saída
    lw $a3, size                                     # Carregar o tamanho do array
    jal generate_matrix                               # Chamar a função generate_matrix

    # Imprimir a matriz
    li $v0, 4                                        # Código de serviço para imprimir string
    la $a0, prompt                                   # Carregar a mensagem de prompt
    syscall

    li $t0, 0                                        # Inicializar contador de linhas

print_matrix:
    mul $t1, $t0, $a1                                 # Calcular o endereço da linha
    sll $t2, $t1, 2                                   # Multiplicar por 4 (tamanho de um word)
    add $t3, $a2, $t2                                 # Endereço do início da linha

    li $t4, 0                                        # Inicializar contador de elementos na linha

print_elements:
    bge $t4, $a1, new_line                           # Se já imprimiu todos os elementos da linha, pular para nova linha
    lw $t5, 0($t3)                                   # Carregar o elemento atual
    li $v0, 1                                        # Código de serviço para imprimir inteiro
    move $a0, $t5                                    # Mover o inteiro para $a0
    syscall

    addi $t3, $t3, 4                                 # Avançar para o próximo elemento
    addi $t4, $t4, 1                                 # Incrementar contador de elementos na linha
    j print_elements                                  # Repetir para imprimir todos os elementos da linha

new_line:
    li $v0, 11                                       # Código de serviço para imprimir caractere
    li $a0, 10                                       # Código ASCII para nova linha
    syscall

    addi $t0, $t0, 1                                 # Incrementar contador de linhas
    bge $t0, $a3, end_program                        # Se já imprimiu todas as linhas, encerrar
    j print_matrix                                    # Continuar imprimindo a matriz

end_program:
    li $v0, 10                                       # Código de serviço para encerrar o programa
    syscall

# Função: generate_matrix
# Parâmetros:
#   $a0: endereço do array de entrada
#   $a1: número de elementos por linha
#   $a2: endereço da matriz de saída
#   $a3: tamanho do array

generate_matrix:
    li $t0, 0                                        # Inicializar índice da matriz (linha)
    li $t4, 0                                        # Inicializar índice do array de entrada

loop:
    lw $t1, n                                        # Carregar número de elementos por linha
    lw $t2, size                                     # Carregar o tamanho do array
    addi $t2, $t2, -1                                # Ajustar para zero-based
    bge $t4, $t2, end_generate                       # Se o índice do array for maior ou igual ao tamanho, sair

    # Verificar se há pelo menos n elementos restantes
    add $t8, $t4, $t1                                # Verificar o índice do array + n
    bgt $t8, $t2, end_generate                        # Se exceder, sair

    # Calcular o endereço na matriz de saída
    mul $t3, $t0, $t1                                 # Multiplicar índice da linha pelo número de elementos por linha
    sll $t5, $t3, 2                                   # Multiplicar por 4 (tamanho de um word)
    add $t6, $a2, $t5                                 # Endereço da linha na matriz

    # Preencher os elementos da linha
    li $t2, 0                                        # Zerar contador de elementos na linha

fill_elements:
    bge $t2, $t1, end_generate                                     # Se já preencheu todos os elementos da linha, sair
    lw $t7, 0($a0)                                   # Carregar o elemento atual do array
    sw $t7, 0($t6)                                   # Armazenar o elemento na matriz
    addi $a0, $a0, 4                                 # Avançar para o próximo elemento do array
    addi $t6, $t6, 4                                 # Avançar para o próximo espaço na matriz
    addi $t2, $t2, 1                                 # Incrementar contador de elementos na linha
    j fill_elements                                   # Repetir para preencher a linha

    add $t4, $t4, $t1                               # Avançar no índice do array de entrada (avança pelo número de elementos que foram adicionados)
    addi $t0, $t0, 1                                 # Incrementar índice da matriz (linha)
    j loop                                           # Repetir o loop

end_generate:
    jr $ra                                           # Retornar da função
