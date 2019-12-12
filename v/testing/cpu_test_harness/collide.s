addi $4, $0, h0304
addi $1, $0, h0102
addi $2, $0, 16
sll $1, $1, $2
or $4, $4, $1
dc $4, $4
beq SUCCESS
FAIL:
add $0, $0, $0
b FAIL
SUCCESS:
addi $0, $0, 0
b SUCCESS
