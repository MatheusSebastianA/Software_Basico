.section .data
    topoInicialHeap: .quad 0
    fimHeap: .quad 0
    inicioBloco: .quad 0

    stringGerencial: .string "################"
    charLivre: .string "-"
    charOcupado: .string "+"
    charQuebraLinha: .string "\n"

.section .text
.globl _start

iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax                              #código de chamada de sistema para brk
    movq $0, %rdi                               #retorno do endereço atual da heap em %rax
    syscall

    movq %rax, topoInicialHeap                  #topoInicialHeap = endereço inicial da heap
    movq %rax, fimHeap                          #fimHeap = endereço inicial da heap

    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax                              #código de chamada de sistema para brk
    movq topoInicialHeap, %rbx                  #restaura a heap para seu endereço inicial
    syscall

    popq %rbp
    ret
    

liberaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq fimHeap, %rbx                          #%rbx = fimHeap
    movq topoInicialHeap, %rcx                  #%rcx = topoInicialHeap
    movq 16(%rbp), %rdx                         #rdx = bloco (endereço do bloco a ser liberado)
    subq $16, %rdx                              #rdx = rdx - 16 (endereço gerencial de ocupado)

    cmpq %rbx, %rcx                             #(topoInicialHeap == fimHeap)
    jne else1
        movq $0, %rax                           #return 0

        popq %rbp                               
        ret
    
    else1:
    movq 8(%rcx), %rbx                          #rbx = *(rcx+8) (rbx = num_bytes do bloco)
    addq $16, %rbx                              #rbx = *(rcx+8) + 16
    movq %rcx, %rsi
    addq %rbx, %rcx                             #rcx = rcx + *(rcx+8) + 16
    
    while: 
    cmpq %rdx, %rcx                             #rcx + *(rcx + 8) + 16 < bloco - 2*sizeof(long)
    jge fim_while_bloco_anterior    
        movq 8(%rcx), %rbx                      #rbx = tamanho do bloco
        movq %rcx, %rsi
        addq $16, %rcx                          #rcx = rcx + 16
        addq %rbx, %rcx                         #rcx = rcx + 16 + tamanho do bloco
        jmp while 
    
    fim_while_bloco_anterior:                   
    movq (%rsi), %rbx                           #rbx = *(%rsi) (rbx = 0 ou 1)
    movq %rsi, %rcx

    cmpq $0, %rbx                               #rbx == 0?
    jne else_if
        movq %rcx, %rbx                         #rbx = rcx (endereço da parte gerencial do bloco anterior)
        addq $8, %rbx                           #rbx = rcx + 8
        movq (%rbx), %rbx                       #rbx = *(rcx + 8) (tamano do bloco anterior)

        movq 16(%rbp), %rdx                     #rdx = parâmetro (endereço do bloco)
        subq $8, %rdx                           #rdx = parâmetro - 8 (endereço do tamanho do bloco)
        movq (%rdx), %rdx                       #rdx = *(rdx) (rdx = tamanho)

        addq $16, %rdx                          #rdx = tamanho + 16
        addq %rbx, %rdx                         #rdx = tamanho + 16 + tamanho bloco anterior
        movq %rdx, 8(%rcx)                      #*(rcx + 8) = (tamanho + 16 + tamanho bloco anterior)
        addq $16, %rsi                          #rsi = endereço gerencial do bloco + 16
        movq %rsi, 16(%rbp)                     #bloco = endereço gerencial do bloco anterior + 16
       

    else_if:
    movq fimHeap, %rbx                          #rbx = fimHeap
    movq 16(%rbp), %rdx                         #rdx = bloco (endereço do bloco a ser liberado)
    movq -8(%rdx), %rcx                         #rcx = tamanho do bloco
    addq %rdx, %rcx                             #rcx = endereço do bloco + tamanho do bloco

    cmpq %rbx, %rcx
    je libera_bloco
        movq (%rcx), %rdx                       #rdx = valor de ocupado do próximo bloco
        cmpq $0, %rdx
        jne libera_bloco
            movq 8(%rcx), %rbx                  #rbx = tamanho do próximo bloco
            addq $16, %rbx                      #rbx = tamanho do próximo bloco + 16
            movq 16(%rbp), %rcx                 #rcx = endereço do bloco
            subq $8, %rcx                       #rcx = endereço do bloco - 8

            movq (%rcx), %rcx                   #rcx = *(rcx - 8)
            addq %rbx, %rcx                     #rcx = tamanho do bloco + tamanho do próximo bloco + 16
            movq 16(%rbp), %rbx                 #rbx = endereço do bloco
            subq $8, %rbx                       #rbx = endereço do bloco - 8 
            movq %rcx, (%rbx)                   #*(endereço do bloco - 8) = (tamanho do bloco + tamanho do próximo bloco + 16)
                        
    libera_bloco:
    movq 16(%rbp), %rbx
    subq $16, %rbx
    movq $0, (%rbx)

    popq %rbp                               
    ret



alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq fimHeap, %rbx                          #%rbx = fimHeap
    movq topoInicialHeap, %rcx                  #%rcx = topoInicialHeap

    #while para passar por todos os blocos
    while_tem_bloco:
    cmpq %rbx, %rcx                             #(while (topoInicialHeap < fimHeap))
    jge fim_while
        movq (%rcx), %rdx                       #rdx = *(rcx) // rdx = bit_ocupado
            
        cmpq $0, %rdx                           #rdx == 0? Se não for, o bloco está ocupado e é necessário incrementar %rcx para o inicio do próximo bloco
        jne while_it1
            movq 8(%rcx), %rdx                  #rdx =  *(rcx+8), //  rdx = tamanho do bloco
            cmpq 16(%rbp), %rdx                 #tamanho do bloco - num_bytes > 0 (tem espaço suficiente nesse bloco vazio)
            jl while_it1
                movq $1, (%rcx)                 #*(rcx) = 1 // *(rcx) = ocupado
                movq 8(%rcx), %rdx              #rdx = tam_bloco
                subq $16, %rdx                  #rdx = tam_bloco - 16
                subq 16(%rbp), %rdx             #rdx = tam_bloco - 16 - num_bytes (quantidade de bytes livres para dados, sem contar os 16 gerenciais)
                    
                cmpq $1, %rdx                   #verifica se a quantidade de bytes que tinha no bloco - (16 + num_bytes) é suficiente para criar um novo bloco (se sobrar 1 byte é porque tem mais de 16 bytes livres)
                jl else
                    movq 16(%rbp), %rbx         #rbx = num_bytes
                    movq %rbx, 8(%rcx)          #*(rcx+8) = num_bytes

                    addq $16, %rcx              #rcx = rcx + 16
                    addq 16(%rbp), %rcx         #rcx = rcx + 16 + num_bytes
                    movq $0, (%rcx)             #*(rcx + 16 + num_bytes) = 0
                    addq $8, %rcx               #rcx = rcx + 16 + num_bytes + 8
                    movq %rdx, (%rcx)           #*(rcx + 24 + num_bytes) = %rdx (resto dos bytes - 16)

                    subq $8, %rcx               #rcx = rcx - 8 (voltando para o endereço gerencial do novo bloco)
                    subq 16(%rbp), %rcx         #rcx = rcx - num_bytes (voltando para o inicio do bloco)

                    movq %rcx, %rbx             #rbx = rcx
                    addq $16, %rbx              #rbx = rcx + 16
                    movq %rbx, inicioBloco      #inicioBloco = rcx + 16

                    movq %rbx, %rax             #%rax = %rbx (endereço do bloco)

                    popq %rbp
                    ret


                else:
                movq %rcx, %rbx                 #rbx = rcx
                addq $16, %rbx                  #rbx = rcx + 16
                movq %rbx, inicioBloco          #inicioBloco = rcx + 16

                movq %rbx, %rax                 #%rax = %rbx (endereço do bloco)


                popq %rbp
                ret

        while_it1:                              #iterador para rcx receber o endereço gerencial do próximo bloco
        movq 8(%rcx), %rdx                      #rdx = tamanho do bloco
        addq $16, %rcx                          #rcx = rcx + 16
        addq %rdx, %rcx                         #rcx = rcx + 16 + tamanho do bloco
        jmp while_tem_bloco
            
            
    #criação de um bloco novo (passou por todos os blocos e nenhum tinha espaço suficiente)
    fim_while:
    movq fimHeap, %rdx                          #%rdx = fimHeap (último bloco alocado)
    movq inicioBloco, %rcx                      #%rcx = inicioBloco (topo dos bytes alocados na heap)

    movq 16(%rbp), %rbx                         #%rbx = num_bytes (parâmetro)

    addq $16, %rbx                              #%rbx = num_bytes + 16
    subq %rdx, %rcx                             #%rcx = inicioBloco - fimHeap 
    subq %rcx, %rbx                             #%rbx = num_bytes + 16 - (inicioBloco - fimHeap)
    addq %rbx, inicioBloco                      #inicioBloco += rbx

    movq inicioBloco, %rdi                      #%rdi = inicioBloco
    movq $12, %rax                              #código de chamada de sistema para brk
    syscall                                     #chama brk para aumentar o tamanho da heap para o novo endereço passado em %rdi

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

    subq $8, %rsp                               #aloca espaço para variável local (iterador)
    
    movq fimHeap, %rbx                          #%rbx = fimHeap
    movq %rbx, -8(%rbp)                         #iterador = fimHeap

    movq topoInicialHeap, %rbx                  #rbx = topoInicialHeap
    
    while_bloco:
    cmpq -8(%rbp), %rbx                         #-8(%rbp) (iterador) >= %rcx (fimHeap)
    jge fim_while_bloco                         #se for maior ou igual, significa que os blocos acabaram
        movq $1, %rax                           #código de chamada de sistema para write 
        movq $1, %rdi                           #primeiro argumento do write: descritor de arquivo (1 é stdout)
        movq $stringGerencial, %rsi             #segundo argumento do write: ponteiro para a mensagem a ser escrita
        movq $16, %rdx                          #terceiro argumento do write: tamanho da mensagem
        syscall                                 #chama o sistema write
        
        movq (%rbx), %r10                       #%r10 = *(rbx) (valor ocupado/desocupado)
        movq 8(%rbx), %r12                      #%r12 = *(rbx + 8) (valor do tamanho do bloco)
        movq $0, %r13                           #%r13 (iterador) = 0

        while_imprime:
        cmpq %r12, %r13                         #while (r13 (iterador) < r12 (tamanho do bloco))
        jge fim_while_imprime
            movq $1, %rax                       #código de chamada de sistema para write 
            movq $1, %rdi                       #primeiro argumento do write: descritor de arquivo (1 é stdout)
            movq $1, %rdx                       #tamanho da string (1, será escrito "+" se ocupado ou "-" se desocupado)

            cmpq $0, %r10                       #if (r10 (bit_ocupado) == 0)
            jne imprime_else        
                movq $charLivre, %rsi           #imprime charLivre "-"
                jmp fim_imprime_if              #fim imprime_if    

            imprime_else:                       #if (r10 (bit_ocupado) == 1)
                movq $charOcupado, %rsi         #imprime charOcupado "+"

            fim_imprime_if:
            syscall
            addq $1, %r13                       #r13 (iterador)++
            jmp while_imprime                   #volta para imprimir os bytes restantes do bloco
            
        fim_while_imprime:
        addq $16, %rbx                          #rbx = rbx (endereço iterador) + 16 (informações gerenciais)
        addq %r12, %rbx                         #rbx = rbx (endereço iterador) + r12 (tamanho)
        jmp while_bloco                         #volta para o laço para verificar se rbx (endereço iterador) já é maior que fimHeap
        
    fim_while_bloco:
    movq $charQuebraLinha, %rsi                 #rsi = "\n"

    movq $1, %rax                               #código de chamada de sistema para write 
    movq $1, %rdi                               #primeiro argumento do write: descritor de arquivo (1 é stdout)
    movq $1, %rdx                               #tamanho da string (1, será escrito "\n")
    syscall

    addq $8, %rsp
    popq %rbp
    ret


_start:
    pushq %rbp
    movq %rsp, %rbp

    subq $32, %rsp                          #x1 = -8(%rbp), x2 = -16(%rbp), x3 = -24(%rbp), x4 = -32(%rbp)

    call iniciaAlocador                     #chama a função inicializaAlocador

    movq $4, %rbx                           #coloca num_bytes em %rbx
    pushq %rbx                              #empilha num_bytes (parâmetro)
    call alocaMem                           #chama a função alocaMem
    addq $8, %rsp                           #desempilha o parâmetro
    movq %rax, -8(%rbp)                     #x1 = %rax

    movq $12, %rax                          #código de chamada de sistema para brk
    movq $0, %rdi                           #retorna endereço atual da heap em %rax
    syscall

    movq $4, %rbx                           #coloca num_bytes em %rbx
    pushq %rbx                              #empilha num_bytes (parâmetro)
    call alocaMem                           #chama a função alocaMem
    addq $8, %rsp                           #desempilha o parâmetro
    movq %rax, -16(%rbp)                    #x2 = %rax

    movq $12, %rax                          #código da syscall para o brk
    movq $0, %rdi                           #retorna endereço atual da heap em %rax
    syscall

    movq $4, %rbx                           #coloca num_bytes em %rbx
    pushq %rbx                              #empilha num_bytes (parâmetro)
    call alocaMem                           #chama a função alocaMem
    addq $8, %rsp                           #desempilha o parâmetro
    movq %rax, -24(%rbp)                    #x3 = %rax


    movq -24(%rbp), %rbx                    #coloca x3 (ponteiro para algum bloco da heap) em %rbx
    pushq %rbx                              #empilha x3 (parâmetro)
    call liberaMem                          #chama a função liberaMem
    addq $8, %rsp                           #desempilha o parâmetro

    movq -16(%rbp), %rbx                    #coloca x2 (ponteiro para algum bloco da heap) em %rbx
    pushq %rbx                              #empilha (parâmetro)
    call liberaMem                          #chama a função liberaMem
    addq $8, %rsp                           #desempilha o parâmetro

    movq $4, %rbx                           #coloca num_bytes em %rbx
    pushq %rbx                              #empilha num_bytes (parâmetro)
    call alocaMem                           #chama a função alocaMem
    addq $8, %rsp                           #desempilha o parâmetro
    movq %rax, -32(%rbp)                    #x4 = %rax

    call imprimeMapa
    call finalizaAlocador

    movq $0, %rdi
    movq $60, %rax                          #encerra o programa
    syscall
