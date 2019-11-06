BEGIN:
ASM:
	r $0
	beq BEGIN
	blt ASM
	addi $20, $30, 500
	addi $20, $30, 500
	dc $15, $17
	tim $5
	ds $10, $10, #5
	bov 200
	ret
