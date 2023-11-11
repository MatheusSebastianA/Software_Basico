.section .data
    A: .quad 0
    B: .quad 0

.section .text
.global _start

_start:
    movq $6, (A)       # Armazena 6 em A
    movq $5, (B)       # Armazena 5 em B

    movq (A), %rax     # Carrega o valor de A em %rax
    movq (B), %rbx     # Carrega o valor de B em %rbx

    addq %rax, %rbx    # Soma %rax e %rbx

    # Converta o valor para uma string (ascii)
    movq %rbx, %rdi
    movq $10, %rax     # Base 10
    movq $buf, %rbx    # Buffer para armazenar a string
    call int_to_str    # Chamada de função para converter o inteiro para string

    # Escreve a string no terminal
    movq $1, %rax      # syscall write
    movq $1, %rdi      # file descriptor (stdout)
    movq $buf, %rsi    # ponteiro para a string
    movq $20, %rdx     # comprimento da string (ajuste conforme necessário)
    syscall

    # Saída do programa
    movq $60, %rax
    xorq %rdi, %rdi
    syscall
