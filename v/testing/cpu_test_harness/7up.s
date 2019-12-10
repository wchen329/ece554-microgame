ls %2, 0, TEST
rs %2, 3
lli $31, hcccc
lui $31, h00cc
lli $4, 31
wfb $4, $4
ds %2, $4, $4
cs $4, $4
dfb
