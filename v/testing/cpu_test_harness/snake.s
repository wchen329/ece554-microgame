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

# init draw snake
ds %0, $3, $4
lli $7, 8
sll $7, $3, $7
or $7, $7, $4
sw $7, 0

# intital snake direction is 0 (up)
lli $8, 0

# $7 and $15 are temp regs also $18 and $19

# initial snake length
lli $16, 1
# initial snake tail index
lli $17, 0
lui $17, 0
# initial snake head index
lli $20, 0
lui $20, 0

# food begins in random location on screen
bl RANDOM_FOOD

START:
TICK:

	# get time so we know when this frame should end
	tim $29
	add $29, $29, $2

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

	bl UPDATE_SNAKE_HEAD

	bl HANDLE_POSSIBLE_EAT

	# draw snake
	ds %0, $3, $4
	lli $7, 8
	lui $7, 0
	sll $7, $3, $7
	and $7, $7, $4
	swo $7, 0($20)

	addi $20, $20, 1
	sub $0, $16, $20
	bne PASS
	andi $20, $20, 0

	PASS:

	# draw food
	ds %1, $5, $6

	# refresh screen
	dfb

	WAIT:

	# wait until end of tick
	tim $28
	sub $0, $29, $28
	bgt WAIT
	b TICK

HANDLE_POSSIBLE_EAT:

	# check if snake head is actually on top of food
	sub $0, $3, $5
	bne NO_EAT
	sub $0, $4, $6
	bne NO_EAT

	# snake ate the food, place new food
	r $7
	andi $5, $7, h00f8
	r $7
	andi $6, $7, h00f8

	# grow the snake
	addi $16, $16, 1

	# we don't remove tail here
	ret

	NO_EAT:
	
	# remove tail
	lwo $15, 0($17)
	andi $19, $15, h00FF
	andi $18, $15, hFF00
	lli $15, 8
	lui $15, 0
	srl $18, $18, $15
	andi $18, $18, h00FF
	cs $18, $19
	
	# increment tail address
	addi $17, $17, 1
	sub $0, $16, $17
	beq BACK_TO_TAIL
	ret

	BACK_TO_TAIL:

	andi $17, $17, 0

	ret

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
