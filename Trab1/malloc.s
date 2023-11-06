.section .data
    topoInicialHeap: .quad 0
    fimHeap: .quad 0
    inicioBloco: .quad 0
.section .text
.globl _start

iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp
    movq $12, %rax
    movq $0, %rdi
    syscall
    movq %rax, topoInicialHeap
    movq %rax, fimHeap
    popq %rbp

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp
    movq $12, %rax
    movq topoInicialHeap, %rbx
    

liberaMem:
    pushq %rbp
    movq %rsp, %rbp

alocaMem:
    pushq %rbp
    movq %rsp, %rbp
    subq $8, %rsp #variavel local = aux


    movq topoInicialHeap, %rax #rax = topoInicialHeap
    movq fimHeap, %rbx #rbx = fimHeap
    movq 16(%rbp), %rcx #rcx = num_bytes
    movq inicioBloco, %rdi #rdi = inicioBloco que sera retornado
    movq topoInicialHeap, -8(%rbp) #aux = topoInicialHeap

while:

    cmpq $0, -8(%rbp)
    je fim_while
    
        cmpq %rax, %rbx
        jne else_NV
        movq %rax, %rdi #inicio bloco = topoInicialHeap
        addq $16, %rdi #inicio bloco = topoInicialHeap + 16
        movq %rdi, %rbx #fimHeap = inicioBloco
        addq %rcx, %rbx #fimHeap = inicioBloco + num_bytes

        movq %rax, %rdx #rdx = topoInicialHeap

        movq (%rax), %rax #rax = *(topoInicialHeap)
        addq %rcx, %rax #*(topoInicialHeap) = num_bytes

        addq $8, %rdx #rdx = topoInicialHeap + 8
        movq (%rdx), %rdx #rdx = *(topoInicialHeap + 8)
        movq $1, %rdx #*(topoInicialHeap + 8) = 1

        addq $8, %rsp
        popq %rbp
        ret

    else_NV: #caso de heap nao estar vazia e ter um bloco vazio que tem uma quantidade suficiente de bytes
        #*(long*)(aux + sizeof(long)) == 0 && *(long*)(aux) >= numBytes
        movq -8(%rbp), %rex #rex = aux
        movq (%rex), %rex #aux = *(long*)topoInicialHeap
        cmpq %rcx, %rex
        jl else_NB

        movq -8(%rbp), %rex #rex = aux
        addq $8, %rex #aux = topoInicialHeap + 8
        movq (%rex), %rex #aux = *(long*)(topoInicialHeap + 8)
        cmpq $0, %rex 
        jne else_NB

        movq -8(%rbp), %rdi #inicioBloco = aux 
        addq $16, %rdi #inicioBloco = aux + 16
        movq $1, %rex #rex = 1 (*(long*)(aux + 8) = 1)
        addq $8, %rsp
        popq %rbp
        ret

    else_NB: #caso que tem que criar um novo bloco e nao passou por todos os blocos
        cmpq -8(%rbp), %rbx #if(aux == fimHeap)
        jne while_iteracao

        addq %rbx, %rdi #inicioBloco = fimHeap
        addq $16, %rdi #inicioBloco = fimHeap + 2*sizeof(long);

        addq %rdi, %rbx #fimHeap = inicioBloco
        addq %rcx, %rbx #fimHeap = inicioBloco + num_bytes

        movq %rdi, %rex #rex = inicioBloco
        subq $16, %rex #rex = inicioBloco - 2*sizeof(long)
        movq (%rex), %rex #rex = *(long*)(inicioBloco - 2*sizeof(long))
        movq %rcx, %rex

        movq %rdi, %rex #rex = inicioBloco
        subq $8, %rex #rex = inicioBloco - sizeof(long)
        movq (%rex), %rex #rex = *(long*)(inicioBloco - sizeof(long))
        movq $1, %rex

        addq $8, %rsp
        popq %rbp
        ret

    while_iteracao:
        movq (-8(%rbp)), %rex #rex = *aux
        addq %rex, -8(%rbp) #aux = aux + *(long*)aux
        addq $16, -8(%rbp) #aux = aux + *(long*)aux + 2*sizeof(long)
        jmp while


fim_while:
    movq $0, %rdi
    addq $8, %rsp
    popq %rbp
    ret


_start:
    call iniciaAlocador


    movq $60, %rax
    syscall
