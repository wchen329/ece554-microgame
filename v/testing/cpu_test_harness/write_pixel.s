lli $2, 32
lui $2, 0
lli $31, hffff
lui $31, h0000
wfb $2, $2
dfb
LOOP:
b LOOP
