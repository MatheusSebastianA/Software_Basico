CC = gcc
AS = as 
CFLAGS = -g -no-pie

main: main.o memalloc.o
  $(CC) $(CFLAGS) -o main main.o memalloc.o

memalloc.o: memalloc.s
  $(AS) $(CFLAGS) -c memalloc.s -o memalloc.o

main.o: main.c memalloc.h
  $(CC) $(CFLAGS) -c main.c -o main.o

clean:
  rm -rf ./*.o

purge:
  clean
  rm -rf main
