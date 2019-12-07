# Painting Program
# By Bradley S. and Winor C.
#
# --------
# 8 colors
# --------
# x - $s0
# y - $s1

# Cache Sprites
ls %0, 0, MAGENTA
ls %1, 0, RED
ls %2, 0, GREEN
ls %3, 0, BLUE
ls %4, 0, BLACK
ls %5, 0, WHITE
ls %6, 0, BROWN
ls %7, 0, YELLOW
b GAME

CYCLE_COLOR:
	addi $7, $7, 1
	ret

SET_LEFT:
	addi $s0, $s0, -8
	ret

SET_RIGHT:
	addi $s0, $s0, 8
	ret

SET_UP:
	addi $s1, $s1, -8
	ret

SET_DOWN:
	addi $s1, $s1, 8
	ret

WRITE_MAGENTA:
	ds %0, $s0, $s1
	ret

WRITE_RED:
	ds %1, $s0, $s1
	ret

WRITE_GREEN:
	ds %2, $s0, $s1
	ret

WRITE_BLUE:
	ds %3, $s0, $s1
	ret

WRITE_BLACK:
	ds %4, $s0, $s1
	ret

WRITE_WHITE:
	ds %5, $s0, $s1
	ret

WRITE_BROWN:
	ds %6, $s0, $s1
	ret

WRITE_YELLOW:
	ds %7, $s0, $s1
	ret


GAME:
	# Load Keyboard Input
	lk $1 # Get last keystroke

	# Set up comparisons, move cursor or change color to draw
	andi $2, $1, b00001  # LEFT
	beq SET_LEFT

	andi $3, $1, b00010  # RIGHT
	beq SET_RIGHT

	andi $4, $1, b01000  # DOWN
	beq SET_DOWN

	andi $5, $1, b00100  # UP
	beq SET_UP

	andi $6, $1, b10000 # SPACE (RANDOM)
	beq CYCLE_COLOR

	# Write Sprite
	sub $10, $7, $2
	bleq SET_LEFT

	sub $10, $7, $3
	bleq SET_RIGHT

	sub $10, $7, $4
	bleq SET_DOWN

	sub $10, $7, $5
	bleq SET_UP

	sub $10, $7, $6
	bleq CYCLE_COLOR

	# Change color
	andi $8, $7, 7

	addi $11, $8, 0
	bleq WRITE_MAGENTA

	addi $11, $8, -1
	bleq WRITE_RED

	addi $11, $8, -2
	bleq WRITE_GREEN

	addi $11, $8, -3
	bleq WRITE_BLUE

	addi $11, $8, -4
	bleq WRITE_BLACK

	addi $11, $8, -5
	bleq WRITE_WHITE

	addi $11, $8, -6
	bleq WRITE_BROWN

	addi $11, $8, -7
	bleq WRITE_YELLOW
	
	# Show our write to the screen
	dfb

	# Loop back
	b GAME 
