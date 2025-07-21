# Simple Makefile example
CC = gcc
CFLAGS = -Wall -O2

OBJS = main.o utils.o

program: $(OBJS)
	$(CC) -o program $(OBJS)

main.o: main.c utils.h
	$(CC) $(CFLAGS) -c main.c

utils.o: utils.c utils.h
	$(CC) $(CFLAGS) -c utils.c