# Painting Px Program
#
# --------
# Random colors
# --------
# $1  - input
# $2  - input test
# $3  - x
# $4  - y
# $28 - time curr
# $29 - time end

# set up
lli $3, 127
lli $4, 127
lli $31, hFFFF
lui $31, hFF
b GAME

CYCLE_COLOR:
	addi $31, $31, 0
	beq GET_RNG
	andi $31, $31, 0
	ret

GET_RNG:
	r $31
	ret

SET_LEFT:
	addi $3, $3, -1
	ret

SET_RIGHT:
	addi $3, $3, 1
	ret

SET_UP:
	addi $4, $4, -1
	ret

SET_DOWN:
	addi $4, $4, 1
	ret

GAME:
	# get time so we know when this frame should end
	tim $29
	addi $29, $29, h01

	# Load Keyboard Input
	lk $1 # Get last keystroke

	# Set up comparisons, move cursor or change color to draw
	andi $2, $1, h10  # LEFT
	blne SET_LEFT

	andi $2, $1, h04  # RIGHT
	blne SET_RIGHT

	andi $2, $1, h08  # DOWN
	blne SET_DOWN

	andi $2, $1, h02  # UP
	blne SET_UP

	andi $2, $1, h01 # SPACE (RANDOM)
	blne CYCLE_COLOR

	wfb $3, $4

	# Show our write to the screen
	dfb

	WAIT:
	 	tim $28
	 	sub $0, $29, $28
	 	bgt WAIT

	# Loop back
	b GAME
