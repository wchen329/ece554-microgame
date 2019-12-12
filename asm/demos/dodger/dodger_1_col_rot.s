# Dodger
# A game where you randomly dodge rocks being thrown at you
#
# Usage of registers:
# $1  - spaceship x
# $2  - spaceship y
# $3  - rock x
# $4  - rock y
# $5  - rock rot
# $6  - input
# $10+ - gp/test
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

ROT_0:
	rs %1, 0
	ret

ROT_1:
	rs %1, 1
	ret

ROT_2:
	rs %1, 2
	ret

ROT_3:
	rs %1, 3
	ret

DETECT_COL:
	# ship
	# get x loc for coll
	addi $10, $zero, 24
	sll $10, $1, $10
	# get y loc for coll
	addi $11, $zero, 16
	sll $11, $2, $11
	or $10, $10, $11
	# get w,h for coll
	addi $10, $10, h0808

	# rock
	# get x loc for coll
	addi $11, $zero, 24
	sll $11, $3, $11
	# get y loc for coll
	addi $12, $zero, 16
	sll $12, $4, $12
	or $11, $11, $12
	# get w,h for coll
	addi $11, $11, h0808

	dc $10, $11
	beq END

	ret

GAME:
	# get time so we know when this frame should end
	tim $29
	# addi $29, $29, hc8
	addi $29, $29, h1

	# check coll
	# addi $10, $4, -230
	# blgt DETECT_COL
	bl DETECT_COL

	cs $1, $2
	cs $3, $4

	# move ship
	lk $6

	andi $10, $6, h10
	blne SET_LEFT

	andi $10, $6, h04
	blne SET_RIGHT

	# move rock
	addi $4, $4, 2
	addi $10, $4, -250
	blgt GEN_ROCK

	# rotate rock
	addi $5, $5, 1
	andi $5, $5, 3

	addi $10, $5, 0
	bleq ROT_0

	addi $10, $5, -1
	bleq ROT_1

	addi $10, $5, -2
	bleq ROT_2

	addi $10, $5, -3
	bleq ROT_3

	# draw new positions
	ds %0, $1, $2
	ds %1, $3, $4

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