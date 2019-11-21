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
ls %0, 0, 0
lli $1, 20
lli $2, 10
ds %0, $1, $2
# draw rotated 1
rs %0, 1
lli $1, 30
lli $2, 20
ds %0, $1, $2
# draw rotated 2
rs %0, 2
lli $1, 20
lli $2, 30
ds %0, $1, $2
# draw rotated 3
rs %0, 3
lli $1, 10
lli $2, 20
ds %0, $1, $2

dfb

# draw sprites at edge of screen
# draw rotated 0
rs %0, 0
lli $1, 124
lli $2, 0
ds %0, $1, $2
# draw rotated 1
rs %0, 1
lli $1, 255
lli $2, 124
ds %0, $1, $2
# draw rotated 2
rs %0, 2
lli $1, 124
lli $2, 255
ds %0, $1, $2
# draw rotated 3
rs %0, 3
lli $1, 0
lli $2, 124
ds %0, $1, $2

dfb

# clear sprites inside screen
lli $1, 20
lli $2, 10
cs $1, $2
# draw rotated 1
lli $1, 30
lli $2, 20
cs $1, $2
# draw rotated 2
lli $1, 20
lli $2, 30
cs $1, $2
# draw rotated 3
lli $1, 10
lli $2, 20
cs $1, $2

dfb

# clear sprites at edge of screen
lli $1, 124
lli $2, 0
cs $1, $2
# draw rotated 1
lli $1, 255
lli $2, 124
cs $1, $2
# draw rotated 2
lli $1, 124
lli $2, 255
cs $1, $2
# draw rotated 3
lli $1, 0
lli $2, 124
cs $1, $2
