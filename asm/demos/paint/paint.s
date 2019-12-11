# Painting Program
# By Bradley S. and Winor C.
#
# --------
# 8 colors
# --------
# $1  - input
# $2  - input test
# $3  - x
# $4  - y
# $7  - color
# $8  - color[2:0]
# $9  - color test
# $28 - time curr
# $29 - time end

# Cache Sprites
ls %0, 0, MAGENTA
ls %1, 0, RED
ls %2, 0, GREEN
ls %3, 0, BLUE
ls %4, 0, BLACK
ls %5, 0, WHITE
ls %6, 0, BROWN
ls %7, 0, YELLOW

lli $3, 120
lli $4, 120
b GAME

CYCLE_COLOR:
	addi $7, $7, 1
	ret

SET_LEFT:
	addi $3, $3, -8
	ret

SET_RIGHT:
	addi $3, $3, 8
	ret

SET_UP:
	addi $4, $4, -8
	ret

SET_DOWN:
	addi $4, $4, 8
	ret

WRITE_MAGENTA:
	ds %0, $3, $4
	ret

WRITE_RED:
	ds %1, $3, $4
	ret

WRITE_GREEN:
	ds %2, $3, $4
	ret

WRITE_BLUE:
	ds %3, $3, $4
	ret

WRITE_BLACK:
	ds %4, $3, $4
	ret

WRITE_WHITE:
	ds %5, $3, $4
	ret

WRITE_BROWN:
	ds %6, $3, $4
	ret

WRITE_YELLOW:
	ds %7, $3, $4
	ret


GAME:
TICK:
	# get time so we know when this frame should end
	tim $29
	addi $29, $29, h0018

	# Load Keyboard Input
	andi $1, $1, 0
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

	# Change color
	andi $8, $7, 7

	addi $9, $8, 0
	bleq WRITE_MAGENTA

	addi $9, $8, -1
	bleq WRITE_RED

	addi $9, $8, -2
	bleq WRITE_GREEN

	addi $9, $8, -3
	bleq WRITE_BLUE

	addi $9, $8, -4
	bleq WRITE_BLACK

	addi $9, $8, -5
	bleq WRITE_WHITE

	addi $9, $8, -6
	bleq WRITE_BROWN

	addi $9, $8, -7
	bleq WRITE_YELLOW
	
	# Show our write to the screen
	dfb

	WAIT:
	 	tim $28
	 	sub $0, $29, $28
	 	bgt WAIT
	 	b TICK

	# Loop back
	b GAME 