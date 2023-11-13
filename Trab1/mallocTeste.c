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

    liberaMem(teste2);
    liberaMem(teste3);
    int *teste4 = alocaMem(sizeof(int)); 
    
    
    imprimeMapa();
    finalizaAlocador();

    

    return 0;
}