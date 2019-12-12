# Dodger
# A game where you randomly dodge rocks being thrown at you
#
# Usage of registers:
# $1  - spaceship x
# $2  - spaceship y
# $3  - rock x
# $4  - rock y
# $5  - input
# $6+ - gp/test
# $28 - time curr
# $29 - time end

# set up
ls %0, 0, SHIP
ls %1, 0, ROCK
addi $1, $zero, 128
addi $2, $zero, 240
bl GEN_ROCK
b GAME

SET_LEFT:
	addi $1, $1, -2
	ret

SET_RIGHT:
	addi $1, $1, 2
	ret

GEN_ROCK:
	r $3
	andi $3, $3, hFF
	andi $4, $4, 0
	ret

DETECT_COL:
	# ship
	# get x loc for coll
	addi $6, $zero, 24
	sll $6, $1, $6
	# get y loc for coll
	addi $7, $zero, 20
	sll $7, $2, $7
	or $6, $6, $6
	# get w for coll
	addi $6, $6, h800
	# get h for coll
	addi $6, $6, h8

	# rock
	# get x loc for coll
	addi $7, $zero, 24
	sll $7, $3, $7
	# get y loc for coll
	addi $8, $zero, 20
	sll $8, $4, $8
	or $7, $7, $7
	# get w for coll
	addi $7, $7, h800
	# get h for coll
	addi $7, $7, h8

	dc $6, $7
	beq END

	ret

GAME:
	# get time so we know when this frame should end
	tim $29
	# addi $29, $29, hc8
	addi $29, $29, h1

	cs $1, $2
	cs $3, $4

	# move ship
	lk $5

	andi $6, $5, h10
	blne SET_LEFT

	andi $6, $5, h04
	blne SET_RIGHT

	# move rock
	addi $4, $4, 2
	addi $6, $4, -250
	blgt GEN_ROCK

	# draw new positions
	ds %0, $1, $2
	ds %1, $3, $4

	# check coll
	addi $6, $4, -230
	blgt DETECT_COL

	dfb

	#wait
	tim $29
	addi $29, $29, h0018

	WAIT:
	 	tim $28
	 	sub $0, $29, $28
	 	bgt WAIT

	b GAME

END:
	b END