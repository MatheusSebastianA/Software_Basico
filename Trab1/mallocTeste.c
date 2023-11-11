#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "mallocTrab.h"

int main(){
    iniciaAlocador();
    int *teste1 = alocaMem(sizeof(int));   
    int *teste2 = alocaMem(sizeof(int));
    int *teste3 = alocaMem(sizeof(int));
    int *teste4 = alocaMem(sizeof(int)); 
    
    *teste1 = 8;
    *teste2 = 30;
    *teste3 = 50;
    *teste4 = 55;
    
    printf("End: %p t1: %d e End: %p t2: %d\n", teste1, *teste1, teste2, *teste2);
    printf("End: %p t3: %d e End: %p t4: %d\n", teste3, *teste3, teste4, *teste4);
    liberaMem(teste2);
    liberaMem(teste4);
    liberaMem(teste3);
    
    int *teste5 = alocaMem(sizeof(int));
    *teste5 = 777;

    printf("End: %p t5: %d\n", teste5, *teste5);

    imprimeMapa();
    finalizaAlocador();

    

    return 0;
}