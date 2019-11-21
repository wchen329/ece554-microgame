lli $1, 16
lui $1, 0
lli $2, 48
lui $2, 0
lli $3, 64
lui $3, 0
add $4, $1, $2
blt FAIL
beq FAIL
addi $4, $3, -64
bne FAIL
sub $4, $2, $2
bne FAIL
and $4, $2, $1
beq FAIL
andi $4, $2, 0
bne FAIL
or $4, $1, $2
beq FAIL
ori $4, $0, 0
bne FAIL
xor $4, $2, $2
bne FAIL
lli $5, 2
lui $5, 0
sll $4, $1, $5
sub $4, $4, $3
bne FAIL
b SUCCESS
FAIL:
b FAIL
SUCCESS:
