lli $1, 12
lui $1, 0
lw $2, 12
lwo $3, 24($1)
sub $4, $3, $3
bne FAIL
bne FAIL
bne FAIL
addi $5, $1, 12
sw $5, 24
b SUCCESS
FAIL:
b FAIL
SUCCESS:
