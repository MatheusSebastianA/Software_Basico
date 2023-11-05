#ifndef mallocTrab
#define mallocTrab
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*  Executa syscall brk para obter o endereço do topo corrente da heap e o armazena em uma
variável global, topoInicialHeap
*/
void iniciaAlocador();

/*  Executa syscall brk para restaurar o valor original da heap contido em topoInicialHeap.
*/
void finalizaAlocador();

/*   Indica que o bloco está livre.
*/
int liberaMem(void* bloco);

/*  Procura um bloco livre com tamanho maior ou igual à num_bytes.
    Se encontrar, indica que o bloco está ocupado e retorna o endereço inicial do bloco;
    Se não encontrar, abre espaço para um novo bloco usando a syscall brk, indica que o bloco está ocupado e
retorna o endereço inicial do bloco.
*/
void* alocaMem(int numBytes);

#endif /* mallocTrab.h*/

