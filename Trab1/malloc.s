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

    movq $12, %rax                              #Código de chamada para brk
    movq $0, %rdi                               #Retorno do endereço atual da heap em %rax
    syscall

    movq %rax, topoInicialHeap                  #topoInicialHeap = endereço inicial da heap
    movq %rax, fimHeap                          #fimHeap = endereço inicial da heap
    movq %rax, topoInicialHeap                  #topoInicialHeap = endereço inicial da heap

    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax                              #Código de chamada para brk
    movq topoInicialHeap, %rbx                  #Restaura a heap para seu endereço inicial
    syscall

    popq %rbp
    ret
    

liberaMem:
    pushq %rbp
    movq %rsp, %rbp





alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq fimHeap, %rbx                          #%rbx = fimHeap
    movq topoInicialHeap, %rcx                  #%rcx = topoInicialHeap

    #While para passar por todos os blocos
    while:
        cmpq %rbx, %rcx                         #(while (topoInicialHeap < fimHeap))
        jge fim_while
            movq (%rcx), %rdx                   #rdx = *(rcx) // rdx = bit_ocupado
            
            cmpq $0, %rdx                       #rdx == 0? Se não for, o bloco está ocupado e é necessário incrementar %rcx para o inicio do próximo bloco
            jne while_iterador
                movq 8(%rcx), %rdx              #rdx =  *(rcx+8), //  rdx = tamanho do bloco
                cmpq 16(%rbp), %rdx             #tamanho do bloco - num_bytes > 0 (tem espaço suficiente nesse bloco vazio)
                jl while_iterador
                    movq $1, (%rcx)             #*(rcx) = 1 // *(rcx) = ocupado
                    movq 8(%rcx), %rdx          #rdx = tam_bloco
                    subq $16, %rdx              #rdx = tam_bloco - 16
                    subq 16(%rbp), %rdx         #rdx = tam_bloco - 16 - num_bytes
                    
                    cmpq $16, %rdx              #verifica se a quantidade de bytes que tinha no bloco - (16 + num_bytes) é suficiente para criar um novo bloco
                    jl else
                        movq 16(%rbp), %rbx     #rbx = num_bytes
                        movq %rbx, 8(%rcx)      #*(rcx+8) = num_bytes

                        addq $16, %rcx          #rcx = rcx + 16
                        addq 16(%rbp), %rcx     #rcx = rcx + 16 + num_bytes
                        movq $0, (%rcx)         #*(rcx + 16 + num_bytes) = 0
                        addq $8, %rcx           #rcx = rcx + 16 + num_bytes + 8
                        movq %rdx, (%rcx)       #*(rcx + 24 + num_bytes) = %rdx (resto dos bytes - 16)

                        subq $8, %rcx           #rcx = rcx - 8 (voltando para o endereço gerencial do novo bloco)
                        subq 16(%rbp), %rcx     #rcx = rcx - num_bytes (voltando para o inicio do bloco)

                        movq %rcx, %rbx         #rbx = rcx
                        addq $16, %rbx          #rbx = rcx + 16
                        movq %rbx, inicioBloco  #inicioBloco = rcx + 16

                        movq %rbx, %rax         #%rax = %rbx (endereço do bloco)

                        popq %rbp
                        ret


                    else:
                    movq %rcx, %rbx             #rbx = rcx
                    addq $16, %rbx              #rbx = rcx + 16
                    movq %rbx, inicioBloco      #inicioBloco = rcx + 16

                    movq %rbx, %rax             #%rax = %rbx (endereço do bloco)

                    popq %rbp
                    ret

        while_iterador:
        movq 8(%rcx), %rdx                      #rdx = tamanho do bloco
        addq $16, %rcx                          #rcx = rcx + 16
        addq %rdx, %rcx                         #rcx = rcx + 16 + tamanho do bloco
        jmp while
            
            
    #Criação de um bloco novo (passou por todos os blocos e nenhum tinha espaço suficiente)
    fim_while:
    movq fimHeap, %rdx                          #%rdx = fimHeap (último bloco alocado)
    movq inicioBloco, %rcx                      #%rcx = inicioBloco (topo dos bytes alocados na heap)

    movq 16(%rbp), %rbx                         #%rbx = num_bytes (parâmetro)

    addq $16, %rbx                              #%rbx = num_bytes + 16
    subq %rdx, %rcx                             #%rcx = inicioBloco - fimHeap 
    subq %rcx, %rbx                             #%rbx = num_bytes + 16 - (inicioBloco - fimHeap)
    addq %rbx, inicioBloco                      #inicioBloco += rbx

    movq inicioBloco, %rdi                      #%rdi = inicioBloco
    movq $12, %rax                              #Código de chamada de sistema para o brk
    syscall                                     #Chama brk para aumentar o tamanho da heap para o novo endereço passado em %rdi

    movq fimHeap, %rbx                          #%rbx = fimHeap
    movq 16(%rbp), %rcx                         #%rcx = num_bytes (parâmetro)
    movq $1, (%rbx)                             #*(%rbx) = 1 (bit_ocupado)
    movq %rcx, 8(%rbx)                          #*(%rbx + 8) = num_bytes (parâmetro)

    addq $16, fimHeap                           #fimHeap += 16
    addq %rcx, fimHeap                          #fimHeap += num_bytes (parâmetro)
    addq $16, %rbx                              #%rbx = %rbx + 16

    movq %rbx, %rax                             #%rax = %rbx (endereço do bloco)

    popq %rbp
    ret




        
imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp

    subq $8, %rsp                           #aloca espaço para variável local
    movq fimHeap, %r10                      #%r10 = fimHeap
    movq %r10, -8(%rbp)                     #iterador_bloco = fimHeap

    movq topoInicialHeap, %r12
    while_bloco:
    cmpq -8(%rbp), %r12                             #-8(%rbp) (iterador_bloco) >= %rcx (fimHeap) ==> fim_while_bloco
    jge fim_while_bloco
        movq $strGerencial, %rsi                #segundo argumento do write: ponteiro para a mensagem a ser escrita
        movq $16, %rdx                          #terceiro argumento do write: tamanho da mensagem
        movq $1, %rax                           #número do sistema para write (1)
        movq $1, %rdi                           #primeiro argumento do write: descritor de arquivo (1 é stdout)
        syscall                                 #chama o sistema write
        
        movq (%r12), %r13                       #%r13 (bit_ocupado) = M[%rcx]
        movq 8(%r12), %r14                      #%r14 (tamanho) = M[%rcx + 8]
        movq $0, %r15                           #%r15 (iterador) = 0
        while_imprime:
        cmpq %r14, %r15                         #r15 (i) >= r14 (tamanho) ==> fim_while_imprime 
        jge fim_while_imprime
            movq $1, %rdi                       #argumentos para o write
            movq $1, %rdx
            movq $1, %rax
            cmpq $0, %r13                       #r13 (bit_ocupado) == 0 ==> imprime_else
            jne imprime_else        
                movq $charLivre, %rsi                   #imprime charLivre "-"
                jmp fim_imprime_if                      #fim imprime_if             
            imprime_else:
                movq $charOcupado, %rsi                 #imprime charOcupado "+"
            fim_imprime_if:
            syscall
            addq $1, %r15                               #r15 (i)++
            jmp while_imprime                           #volta para o while_imprime
            
        fim_while_imprime:
        addq $16, %r12                                  #r12 (iterador_bloco) += 16 (informações gerenciais)
        addq %r14, %r12                                 #r12 (iterador_bloco) += r14 (tamanho)
        jmp while_bloco
        
    fim_while_bloco:
    movq $charLinha, %rsi
    movq $1, %rdx
    movq $1, %rax
    movq $1, %rdi
    syscall

    addq $8, %rsp
    popq %rbp
    ret


_start:
    pushq %rbp
    movq %rsp, %rbp

    subq $16, %rsp                          #x = -8(%rbp), x2 = -16(%rbp)

    call iniciaAlocador                     #chama a função inicializaAlocador

    movq $4, %rbx                           #coloca num_bytes em %rbx
    pushq %rbx                              #empilha num_bytes (parâmetro)
    call alocaMem                           #chama a função alocaMem
    addq $8, %rsp                           #desempilha o parâmetro
    movq %rax, -8(%rbp)                     #x = %rax

    movq $12, %rax                          #código da syscall para o brk
    movq $0, %rdi                           #retorna endereço atual da heap em %rax
    syscall

    movq $8, %rbx                           #coloca num_bytes em %rbx
    pushq %rbx                              #empilha num_bytes (parâmetro)
    call alocaMem                           #chama a função alocaMem
    addq $8, %rsp                           #desempilha o parâmetro
    movq %rax, -16(%rbp)                    #x1 = %rax

    movq $12, %rax                          #código da syscall para o brk
    movq $0, %rdi                           #retorna endereço atual da heap em %rax
    syscall

    call imprimeMapa

    movq $0, %rdi
    movq $60, %rax                          #encerra o programa
    syscall
