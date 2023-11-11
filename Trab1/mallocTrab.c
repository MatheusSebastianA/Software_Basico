#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "mallocTrab.h"

void *topoInicialHeap, *fimHeap, *inicioBloco = NULL;

void iniciaAlocador(){
    topoInicialHeap = sbrk(0);
    fimHeap = topoInicialHeap;

    return;
}

void finalizaAlocador(){
    brk(topoInicialHeap);
    return;
}

int liberaMem(void* bloco){
    if(topoInicialHeap == fimHeap) 
        return 0;

    void *aux = topoInicialHeap;

    while(aux + *(long*)(aux+sizeof(long)) + 2*sizeof(long) < bloco - 2*sizeof(long)){
        aux = aux + *(long*)(aux+sizeof(long)) + 2*sizeof(long);
    }

    //Juntando com um bloco vazio anterior
    if(*(long*)aux == 0){
        *(long*)(aux+sizeof(long)) += *(long*) (bloco - (sizeof(long))) + 2*sizeof(long);
        bloco = aux + 2*sizeof(long);  
    }

    //Juntando com um bloco vazio que está na frente
    if(bloco + *(long*)(bloco - (sizeof(long))) != fimHeap && *(long*)(bloco + *(long*)(bloco - sizeof(long))) == 0 ){
        *(long*)(bloco - sizeof(long)) += *(long*)(bloco + *(long*)(bloco - (sizeof(long))) + sizeof(long)) + 2*sizeof(long);
        *(long*)(bloco - 2*sizeof(long)) = 0;
    }
    else{
        *(long*)(bloco - 2*sizeof(long)) = 0;
    }

    return 1;
}

//arrumar caso de bloco liberado
void* alocaMem(int numBytes){
    void *aux = topoInicialHeap;
    while(aux != NULL){
        if(fimHeap == topoInicialHeap){
            topoInicialHeap = sbrk(16);
            inicioBloco = sbrk(numBytes);
            fimHeap = inicioBloco + numBytes;
            *(long*)topoInicialHeap =  1;
            *(long*)(topoInicialHeap + sizeof(long)) = numBytes;
            return inicioBloco;
        }
        else{
            if(*(long*)(aux) == 0 && *(long*)(aux + sizeof(long)) >= numBytes){
                long tam = *(long*)(aux + sizeof(long)) - 16 - numBytes;
                printf("Tam = %ld + 16 + %ld\n",  *(long*)(aux + sizeof(long)), numBytes);
                inicioBloco = aux + 2*sizeof(long);
                *(long*)(aux) = 1;
                if (tam > 16){
                    *(long*)(aux + sizeof(long)) = numBytes;
                    *(long*)(aux + numBytes + 2*sizeof(long)) = 0;
                    *(long*)(aux + numBytes + 3*sizeof(long)) = tam;
                }
                return inicioBloco;
            }   
            else if(aux == fimHeap){
                inicioBloco = sbrk(16);
                inicioBloco = sbrk(numBytes);
                fimHeap = inicioBloco + numBytes;
                *(long*)(inicioBloco - sizeof(long)) =  numBytes;
                *(long*)(inicioBloco - 2*sizeof(long)) = 1;
                return inicioBloco;
            }
        }
        aux = aux + *(long*)(aux+sizeof(long)) + 2*sizeof(long);
    }
    return inicioBloco;
}

void imprimeMapa(){
    void *aux = topoInicialHeap;
    long tam, ocup = 0;
    while(aux < fimHeap){
        printf("Endereço: %p\n", aux);
        ocup = *(long*)aux;
        tam = *(long*)(aux+8);
        printf("################");
        if (ocup == 1){
            for(int i = 0; i < tam; i++)
                printf("+");
        }
        else{
            for(int i = 0; i < tam; i++)
                printf("+");
        }
        printf("\n");
        aux = aux + *(long*)(aux+sizeof(long)) + 2*sizeof(long);
    }
}