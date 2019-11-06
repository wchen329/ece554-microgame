BEGIN:
ASM:
	r $t0
	beq BEGIN
	blt ASM
	addi $t2, $t3, 500
TRY:
	dc $s0, $s1
	tim $s2
	#ds $s3, $a0, #5
	bov TRY 
MLTI:
	
	bl TRY
