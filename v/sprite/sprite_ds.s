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

dfb