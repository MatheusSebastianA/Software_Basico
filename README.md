# Software_Basico
Compilar código
as meuAlocador.s -o meuAlocador.o
gcc exemplo.c -o exemplo.o
 ld meuAlocador.o -o meuAlocador -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2  /usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o  /usr/lib/x86_64-linux-gnu/crtn.o -lc 
