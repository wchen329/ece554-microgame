# Microgame Assembler
# MAKEFILE
# wchen329
VPATH=src
CC=g++
OBJS=entry.o env.o format_chk.o interpret.o microgame.o mtsstream.o primitives.o shell.o syms_table.o

.SUFFIXES: .cpp .o

.cpp.o:
	$(CC) -g -c $<

mgassemble: $(OBJS)
	$(CC) $(OBJS) -o mgassemble

clean:
	@echo "Cleaning..."
	@if rm *.o ;\
		then echo "Successfully cleaned build intermediates.";\
	else echo "No intermediates found. Skipping...";\
	fi
	@if rm mgassemble ;\
		then echo "Successfully cleaned assembler executable.";\
	else echo "No executable found. Skipping...";\
	fi

test: mgassemble
	./mgassemble -i tests/allinst.s -f hl -o test.hl # -g tests/testspmap.st
	$(CC) tests/testpkg.cpp -o testmgassemble
	./testmgassemble

demo: mgassemble
	cd demos; $(MAKE)
