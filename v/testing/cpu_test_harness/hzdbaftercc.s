lli $1, 4
lui $1, 0
lli $2, 4
lui $2, 0
sub $3, $1, $2
beq END
START:
b START
END:

