# allinst.s
# Shows all the instructions
# required.

BEGIN:
addi $2, $3, 50 #08860032
add $1, $2, $3 #00443000
sub $4, $2, $7 #11047000
and $5, $2, $4 #19444000
andi $6, $2, 111 #2184006F
or $7, $6, $5 #29CC5000
ori $8, $6, 8055 #320C1F77
xor $9, $7, $8 # 3AE48000
sll $10, $1, $2
srl $11, $1, $3
sra $12, $1, $5
lli $13, -1
lui $14, -1
sw $15, 100
lw $16, 100
lwo $17, 20($15)
swo $18, 25($16)
swo $19, 300($16)

# Branch Instructions
beq BEGIN
ble BEGIN
bge BEGIN
bne BEGIN
bgt AFTER
blt AFTER
bov AFTER
b BEGIN

# Branch "and Link" Instructions
bleq BEGIN
blle BEGIN
blge AFTER
blne AFTER
blgt AFTER
bllt AFTER
blov BEGIN
bl BEGIN

AFTER:
ret
lk $20
wfb $21, $22
dfb
ls %3, 2, 300
ds %1, $21, $22
cs $23, $24
rs %2, 3
sat $26
dc $27, $28
tim $29
r $30
sr $31
