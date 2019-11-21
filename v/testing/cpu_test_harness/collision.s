# cd reg is {x, y, w, h}
lui $1, h0000
lli $1, h0404
lui $2, h0101
lli $2, h0202
dc $1, $2
bne ERROR
lui $1, h0000
lli $1, h0404
lui $2, h0404
lli $2, h0202
dc $1, $2
bne ERROR
lui $1, h0000
lli $1, h0404
lui $2, h0004
lli $2, h0404
dc $1, $2
bne ERROR
lui $1, h0000
lli $1, h0404
lui $2, h0005
lli $2, h0404
dc $1, $2
beq ERROR

DONE:
andi $3, $3, 0
beq DONE

ERROR:
andi $4, $4, 0
beq ERROR