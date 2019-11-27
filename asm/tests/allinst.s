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
xor $9, $7, $8 #3A4E8000
sll $10, $1, $2 #42822000
srl $11, $1, $3 #4AC23000
sra $12, $1, $5 #53025000
lli $13, -1 #5B40FFFF
lui $14, -1 #6380FFFF
sw $15, 100 #73C00064
lw $16, 100 #6C000064
lwo $17, 20($15) #7C5E0014
swo $18, 25($16) #84A00019

# Branch Instructions
beq BEGIN # 8900FFEE
ble BEGIN # 8D00FFED
bge BEGIN # 8C00FFEC
bne BEGIN # 8800FFEB
bgt AFTER # 8A00000B
blt AFTER # 8B00000A
bov AFTER # 8E000009
b BEGIN # 8F00FFE7

# Branch "and Link" Instructions
bleq BEGIN # 9100FFE6
blle BEGIN # 9500FFE5
blge AFTER # 94000005
blne AFTER # 90000004
blgt AFTER # 92000003
bllt AFTER # 93000002
blov BEGIN # 9600FFE0
bl BEGIN # 9700FFDF

AFTER:
ret # 98000000
lk $20 # A5000000
wfb $21, $22 # A82B6000
dfb # B0000000
ls %3, 2, hFFFF # BB80FFFF
ds %1, $21, $22 # C12B6000
cs $23, $24 # C82F8000
rs %2, 3 # D2C00000
sat $26 # DE800000
dc $27, $28 # E6F80000
tim $29 # EF400000
r $30 # F7800000
sr $31 # FFC00000
