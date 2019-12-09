# draw inside border
# draw blue top left
lli $31, hFF
lui $31, 0
lli $1, 8
lli $2, 8
wfb $1, $2
# draw green top right
lli $31, hFF00
lli $1, 248
wfb $1, $2
# draw blue bot right
lli $31, hFF00
lli $2, 248
wfb $1, $2
# draw white bot left
lli $31, hFFFF
lui $31, hFF
lli $1, 8
wfb $1, $2

# draw at edge of screen
# draw blue top left
lli $31, hFF
lui $31, 0
lli $1, 0
lli $2, 0
wfb $1, $2
# draw green top right
lli $31, hFF00
lli $1, 255
wfb $1, $2
# draw blue bot right
lli $31, hFF00
lli $2, 255
wfb $1, $2
# draw white bot left
lli $31, hFFFF
lui $31, hFF
lli $1, 0
wfb $1, $2

dfb

# draw sprites inside border
# draw rotated 0
ls %0, 0, SPRITE
ls %1, 0, SQ_SPRITE
lli $1, 20
lli $2, 10
ds %1, $1, $2
# draw rotated 1
rs %1, 1
lli $1, 30
lli $2, 20
ds %1, $1, $2
# draw rotated 2
rs %1, 2
lli $1, 20
lli $2, 30
ds %1, $1, $2
# draw rotated 3
rs %1, 3
lli $1, 10
lli $2, 20
ds %1, $1, $2

dfb

# draw sprites at edge of screen
# draw rotated 0
rs %0, 0
lli $1, 124
lli $2, 0
ds %0, $1, $2
# draw rotated 1
rs %0, 1
lli $1, 248
lli $2, 124
ds %0, $1, $2
# draw rotated 2
rs %0, 2
lli $1, 124
lli $2, 248
ds %0, $1, $2
# draw rotated 3
rs %0, 3
lli $1, 0
lli $2, 124
ds %0, $1, $2

dfb

cs $1, $2
dfb

LOOP:
andi $1, $1, 0
beq LOOP
