CC=gcc
CFLAGS=-m64

ASM=nasm
AFLAGS=-f elf64

all:main

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -lalleg

func.o: func.s
	$(ASM) $(AFLAGS) func.s	

main: main.o func.o
	$(CC) $(CFLAGS) main.o func.o -o wynik -lalleg
clean:
	rm *.o

