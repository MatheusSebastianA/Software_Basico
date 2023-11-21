CC = gcc
AS = as 
CFLAGS = -g -no-pie

avalia: avalia.o meuAlocador.o
	$(CC) $(CFLAGS) -o avalia avalia.o meuAlocador.o

meuAlocador.o: meuAlocador.s
	$(AS) $(CFLAGS) -c meuAlocador.s -o meuAlocador.o

avalia.o: avalia.c meuAlocador.h
	$(CC) $(CFLAGS) -c avalia.c -o avalia.o

clean:
	rm -rf ./*.o
	rm -rf avalia