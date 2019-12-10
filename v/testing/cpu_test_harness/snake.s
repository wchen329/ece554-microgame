# initialization

ls %0, 0, SNAKE
ls %1, 0, FOOD
ls %2, 0, TEST

# constant for number of ms in frame (200)
lli $2, h00c8
lui $2, 0

# snake starts in center of screen
# x
lli $3, 120
# y
lli $4, 120

# intital snake direction is 0 (up)
lli $8, 0

# one is stored in $15

# food begins in random location on screen
bl RANDOM_FOOD

START:
TICK:

	# get time so we know when this frame should end
	tim $29
	add $29, $29, $2

	# clear previous snake location
	cs $3, $4

	# get new direction
	lk $7
	# up
	andi $11, $7, h0002
	lli $15, 1
	lui $15, 0
	srl $11, $11, $15
	# right
	andi $12, $7, h0004
	addi $15, $15, 1
	srl $12, $12, $15
	# down
	andi $13, $7, h0008
	addi $15, $15, 1
	srl $13, $13, $15
	# left
	andi $14, $7, h0010
	addi $15, $15, 1
	srl $14, $14, $15

UP_DOWN:

	and $7, $11, $13
	# both held means we do nothing
	bgt LEFT_RIGHT

	addi $11, $11, 0
	beq DOWN
	lli $8, 0
	b INPUT_DONE	

DOWN:

	addi $13, $13, 0
	beq LEFT_RIGHT
	lli $8, 2
	b INPUT_DONE

LEFT_RIGHT:

	and $7, $12, $14
	# both held means we do nothing
	bgt INPUT_DONE

	addi $12, $12, 0
	beq LEFT
	lli $8, 1
	b INPUT_DONE

LEFT:

	addi $14, $14, 0
	beq INPUT_DONE
	lli $8, 3

INPUT_DONE:

	# for debugging
	addi $1, $8, 0

	bl UPDATE_SNAKE_HEAD

	# draw snake
	ds %0, $3, $4

	# draw food
	ds %2, $5, $6

	# refresh screen
	dfb

WAIT:

	# wait until end of tick
	tim $28
	sub $0, $29, $28
	bgt WAIT
	b TICK

RANDOM_FOOD:
	
	# places new x and y grid locales in $5, $6 for new food
	
	r $7
	# x
	andi $5, $7, h00f8
	r $7
	#y
	andi $6, $7, h00f8

	ret

UPDATE_SNAKE_HEAD:

	# snake is $3, $4 with $8 as direction

	USH_UP:

		addi $0, $8, 0
		bne USH_RIGHT
		addi $4, $4, -8
		blt USH_FIX_UP
		ret

		USH_FIX_UP:

			andi $4, $4, 0
			ret

	USH_RIGHT:

		addi $0, $8, -1
		bne USH_DOWN
		addi $3, $3, 8
		addi $0, $3, -256
		beq USH_FIX_RIGHT
		ret

		USH_FIX_RIGHT:

			lli $3, 248
			lui $3, 0
			ret

	USH_DOWN:

		addi $0, $8, -2
		bne USH_LEFT
		addi $4, $4, 8
		addi $0, $4, -256
		beq USH_FIX_DOWN
		ret

		USH_FIX_DOWN:
		
			lli $4, 248,
			lui $4, 0
			ret

	USH_LEFT:

		addi $3, $3, -8
		blt USH_FIX_LEFT
		ret
	
		USH_FIX_LEFT:
	
			andi $3, $3, 0
			ret
