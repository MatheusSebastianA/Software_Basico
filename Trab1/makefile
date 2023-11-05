CFLAGS = -Wall  # flags de compilacao

CC = gcc

# arquivos-objeto
	objects = mallocTeste.o mallocTrab.o
     
mallocTeste: mallocTeste.o mallocTrab.o
	$(CC) -o mallocTeste mallocTeste.o mallocTrab.o

mallocTrab.o: mallocTrab.c
	$(CC) -c $(CFLAGS) mallocTrab.c

mallocTeste.o: mallocTeste.c
	$(CC) -c $(CFLAGS) mallocTeste.c

clean:
	rm -f $(objects) 

purge:
	rm -f mallocTeste
