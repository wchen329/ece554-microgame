lli $1, 49
lui $1, 49
sr $1
r $2
sr $1
r $3
sub $0, $2, $1
bne FAIL
b SUCCESS
FAIL:
b FAIL
SUCCESS:
