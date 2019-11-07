BEGIN:
addi $2, $0, 50
add $1, $2, $3
sub $4, $2, $0
and $5, $2, $4
andi $6, $2, 111
or $7, $6, $5
ori $8, $6, 8055
xor $9, $7, $8
sll $10, $1, $2
srl $11, $1, $3
sra $12, $1, $5
lli $13, -1
lui $14, -1
sw $15, 0
lw $16, 0
lwo $17, 20($15)
swo $18, 25($16)
swo $19, 300($16)
beq BEGIN
bne BEGIN
bgt AFTER
bleq BEGIN
bne BEGIN
bgt AFTER
AFTER:
ret
lk $20
wfb $21, $22
dfb
ls %3, 200
ds %1, $21, $22
cs $23, $24
rs %2, 2
sat $26
dc $27, $28
tim $29
r $30
sr $31
