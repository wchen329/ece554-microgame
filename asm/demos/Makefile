MGA=../mgassemble

all: dodger.mif paint.mif

paint.mif: paint/paint.s
	@if $(MGA) -i paint/paint.s -o paint.mif -g paint/paint.st; then echo "Paint built."; else rm paint.mif; fi 
	

dodger.mif: dodger/dodger.s
	@if $(MGA) -i dodger/dodger.s -o dodger.mif -g dodger/dodger.st; then echo "Dodger built."; else rm dodger.mif; fi
