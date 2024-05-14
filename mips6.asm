.data
# ler um arquivo, transforma em int, ordena de forma crescente, e printa no console.

buffer: .space 500   # Espaço para ler o arquivo, assumindo que não exceda 500 caracteres
filename: .asciiz "C:\\Users\\anna lara\\Desktop\\Faculdade\\Arquitetura de comp\\lista.txt" # Nome do arquivo
numbers: .word 0:100  # Array para armazenar 100 números inteiros
space: .asciiz " "    # Espaço para separar os números
newline: .asciiz "\n" # Nova linha

.text
.globl main
main:
    # Abrir arquivo para leitura
    li $v0, 13        # syscall para abrir arquivo
    la $a0, filename  # endereço do nome do arquivo
    li $a1, 0         # flag para modo leitura
    li $a2, 0
    syscall
    move $s6, $v0     # salvar descritor do arquivo em $s6

    # Ler dados do arquivo para buffer
    li $v0, 14        # syscall para ler do arquivo
    move $a0, $s6     # descritor do arquivo
    la $a1, buffer    # endereço do buffer
    li $a2, 500       # número de bytes para ler
    syscall

    # Fechar o arquivo
    li $v0, 16        # syscall para fechar arquivo
    move $a0, $s6     # descritor do arquivo
    syscall

    # Converter string para inteiros e armazenar no vetor
    la $a0, buffer    # endereço inicial da string
    la $a1, numbers   # endereço inicial do array de inteiros
    jal parse_numbers # chamar função para parse e armazenamento

    # Ordenar os números no vetor
    jal sort_numbers  # chamar função de ordenação

    # Imprimir os números no vetor
    la $t0, numbers   # endereço inicial do vetor
    li $t1, 100       # número de inteiros para imprimir

print_loop:
    beqz $t1, end_print # se $t1 for 0, terminar
    lw $a0, 0($t0)      # carregar o número atual
    li $v0, 1           # syscall para imprimir inteiro
    syscall

    # Imprimir espaço
    li $v0, 4           # syscall para imprimir string
    la $a0, space
    syscall

    addi $t0, $t0, 4    # avançar para o próximo número no vetor
    subi $t1, $t1, 1    # decrementar contador
    j print_loop        # repetir o loop

end_print:
    # Imprimir nova linha
    li $v0, 4           # syscall para imprimir string
    la $a0, newline
    syscall

    # Terminar programa
    li $v0, 10        # syscall para terminar execução
    syscall

# Função para parsear números e armazenar no vetor
# $a0: endereço inicial da string, $a1: endereço inicial do vetor
parse_numbers:
    li $t0, 0         # índice do vetor
    li $t1, 0         # índice de caracteres na string
    li $t6, 0         # acumulador do número
    li $t7, 1         # sinal do número

parse_loop:
    lb $t2, 0($a0)    # carregar byte atual da string em $t2
    beq $t2, 0, done  # se for o final da string, terminar
    beq $t2, ',', store_number  # se for vírgula, armazenar número acumulado
    beq $t2, '-', set_negative  # se for '-', definir número negativo
    b process_digit    # processar caractere

process_digit:
    sub $t2, $t2, '0' # converter de ASCII para inteiro
    mul $t6, $t6, 10  # multiplicar acumulador por 10
    add $t6, $t6, $t2 # adicionar dígito ao acumulador
    addi $a0, $a0, 1  # avançar na string
    j parse_loop      # continuar o loop

set_negative:
    li $t7, -1        # definir sinal como negativo
    addi $a0, $a0, 1  # avançar na string
    j parse_loop      # continuar o loop

store_number:
    mul $t6, $t6, $t7 # aplicar sinal ao número
    sw $t6, 0($a1)    # armazenar número no vetor
    addi $a1, $a1, 4  # avançar para o próximo espaço no vetor
    li $t6, 0         # resetar acumulador do número
    li $t7, 1         # resetar sinal do número
    addi $a0, $a0, 1  # avançar na string
    j parse_loop      # continuar o loop

done:
    jr $ra            # retornar para a função principal

# Função para ordenar os números no vetor usando Bubble Sort
sort_numbers:
    la $s7, numbers                                # Carrega o endereço do array 'numbers' em $s7

    li $s0, 0                                      # Inicializa o contador do loop externo
    li $s6, 99                                     # Define n-1, onde n é o tamanho do array

    li $s1, 0                                      # Inicializa o contador do loop interno

loop:
    sll $t7, $s1, 2                                # Multiplica $s1 por 4 (tamanho de uma palavra) e coloca em $t7
    add $t7, $s7, $t7                              # Adiciona o endereço de 'numbers' a $t7

    lw $t0, 0($t7)                                 # Carrega numbers[j]
    lw $t1, 4($t7)                                 # Carrega numbers[j+1]

    slt $t2, $t0, $t1                              # Verifica se t0 < t1
    bne $t2, $zero, incremento                     # Pula a troca se já estiver na ordem

    sw $t1, 0($t7)                                 # Troca os elementos
    sw $t0, 4($t7)

incremento:
    addi $s1, $s1, 1                               # Incrementa $s1
    sub $s5, $s6, $s0                              # Subtrai $s0 de $s6

    bne $s1, $s5, loop                             # Se $s1 não é igual a (n-1)-$s0, continua o loop
    addi $s0, $s0, 1                               # Caso contrário, incrementa $s0
    li $s1, 0                                      # Reinicia $s1

    bne $s0, $s6, loop                             # Se $s0 não é igual a $s6, continua o loop externo

    jr $ra                                         # Retorna para a função principal
