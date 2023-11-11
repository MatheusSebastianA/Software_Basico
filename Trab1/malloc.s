.section .data
    topoInicialHeap: .quad 0
    fimHeap: .quad 0
    inicioBloco: .quad 0

    strGerencial: .string "################"
    charLivre: .string "-"
    charOcupado: .string "+"
    charLinha: .string "\n"

.section .text
.globl _start

iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax                  #Código de chamada para brk
    movq $0, %rdi                   #Retorno do endereço atual da heap em %rax
    syscall

    movq %rax, topoInicialHeap      #topoInicialHeap = endereço inicial da heap
    movq %rax, fimHeap              #fimHeap = endereço inicial da heap

    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax                  #Código de chamada para brk
    movq topoInicialHeap, %rbx      #Restaura a heap para seu endereço inicial
    syscall

    popq %rbp
    ret
    

liberaMem:
    pushq %rbp
    movq %rsp, %rbp

alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq TOPO_HEAP, %rbx            #%rbx = fimHeap
    movq INICIO_HEAP, %rcx          #%rcx = topoInicialHeap

    while:
        

_start:
    pushq %rbp
    movq %rsp, %rbp

    subq $8, %rsp              # x = -8(%rbp), y = -16(%rbp)

    call inicializaAlocador     # chama a função inicializaAlocador

    movq $20, %rbx              # coloca num_bytes em %rbx
    pushq %rbx                  # empilha num_bytes (parâmetro)
    call alocaMem               # chama a função alocaMem
    addq $8, %rsp               # desempilha o parâmetro
    movq %rax, -8(%rbp)         # x <-- %rax