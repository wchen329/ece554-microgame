# Microgame Assembler
# MAKEFILE
# wchen329
VPATH=src
CC=g++
OBJS=entry.o env.o format_chk.o interpret.o microgame.o mtsstream.o primitives.o shell.o syms_table.o

.SUFFIXES: .cpp .o

.cpp.o:
	$(CC) -c $<

all: $(OBJS)
	$(CC) $(OBJS) -o mgs

clean:
	@echo "Cleaning..."
	@if rm *.o ;\
		then echo "Successfully cleaned build intermediates.";\
	else echo "No intermediates found. Skipping...";\
	fi
	@if rm mgs ;\
		then echo "Successfully cleaned assembler executable.";\
	else echo "No executable found. Skipping...";\
	fi
