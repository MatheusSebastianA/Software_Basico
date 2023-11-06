#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "mallocTrab.h"

void *topoInicialHeap, *fimHeap, *inicioBloco = NULL;

void iniciaAlocador(){
    topoInicialHeap = sbrk(0);
    fimHeap = topoInicialHeap;
    printf("Valor do topo %p\n", topoInicialHeap);

    return;
}

void finalizaAlocador(){
    printf("Vou liberar o alocador do endereço %p\n", topoInicialHeap);

    if(topoInicialHeap){
        if(topoInicialHeap - fimHeap == 0)
            printf("Liberou\n");
        else
            fimHeap = sbrk(-(*(long*)(fimHeap)));
    }

    else
        printf("Topo da heap não foi iniciado\n");

    return;
}

int liberaMem(void* bloco){
    if(topoInicialHeap == fimHeap){
        printf("Tudo ok, heap voltou ao tamanho inicial");
        return 0;
    }

    void *aux = topoInicialHeap;

    while(aux + *(long*)aux + 2*sizeof(long) < bloco - 2*sizeof(long)){ 
        aux = aux + *(long*)(aux) + 2*sizeof(long);
    }

    //Juntando com um bloco vazio anterior
    if(*(long*)(aux + sizeof(long)) == 0){
        *(long*)(aux) += *(long*) (bloco - (2*sizeof(long))) + 2*sizeof(long);
        bloco = aux + 2*sizeof(long);   
        printf("O anterior tava vazio e juntei, novo end: %p com tamanho: %ld\n", bloco,   *(long*)(bloco - 2*sizeof(long)));
    }

    //Juntando com um bloco vazio que está na frente
    if(bloco + *(long*)(bloco - (2*sizeof(long))) + sizeof(long) != NULL && *(long*)(bloco + *(long*) (bloco - (2*sizeof(long))) + sizeof(long)) == 0 && bloco + *(long*)(bloco - (2*sizeof(long))) != fimHeap){
        *(long*)(bloco - 2*sizeof(long)) += *(long*)(bloco + *(long*) (bloco - (2*sizeof(long)))) + 2*sizeof(long);
        *(long*)(bloco - sizeof(long)) = 0;
        printf("Juntando com um bloco vazio que está na frente, end: %p com tamanho: %ld\n", bloco, *(long*)(bloco - 2*sizeof(long)));
    }
    else{
        printf("Só liberando um bloco normal com endereço: %p\n", bloco);
        *(long*)(bloco - sizeof(long)) = 0;
    }

    return 1;
}

//arrumar caso de bloco liberado
void* alocaMem(int numBytes){
    void *aux = topoInicialHeap;
    while(aux != NULL){
        if(fimHeap == topoInicialHeap){
            printf("Caso de heap vazia\n");
            inicioBloco = topoInicialHeap + 2*sizeof(long);
            fimHeap = inicioBloco + numBytes;
            *(long*)topoInicialHeap =  numBytes;
            *(long*)(topoInicialHeap + sizeof(long)) = 1;
            return inicioBloco;
        }
        else{ 
            if(*(long*)(aux + sizeof(long)) == 0 && *(long*)(aux) >= numBytes){
                printf("Caso de heap não estar vazia e encontrar um bloco liberado maior que o espaço necessário \n");
                inicioBloco = aux + 2*sizeof(long);
                *(long*)(aux + sizeof(long)) = 1;
                return inicioBloco;
            }   
            else if(aux == fimHeap){
                printf("Caso de heap não estar vazia e ter que criar um novo bloco\n");
                inicioBloco = fimHeap + 2*sizeof(long);
                fimHeap = inicioBloco + numBytes;
                *(long*)(inicioBloco - 2*sizeof(long)) =  numBytes;
                *(long*)(inicioBloco - sizeof(long)) = 1;
                return inicioBloco;
            }
        }
        aux = aux + *(long*)aux + 2*sizeof(long);
    }
    return inicioBloco;
}

