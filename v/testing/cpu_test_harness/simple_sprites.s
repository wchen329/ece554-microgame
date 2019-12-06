ls %2, 0, SPRITE
lli $1, 128
lli $2, 128
ds %2, $1, $2
LOOP:
dfb
b LOOP
