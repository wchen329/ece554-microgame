# Dodger
# A game where you randomly dodge rocks being thrown at you
#
# Usage of registers:
# $1 max amount of rocks in play
# $2 working x of a rock
# $3 working y of a rock
# $10 working x of a spaceship
# $11 working y of a spaaceship
# $12 move spaceship tmp
# $13 score register
# $14 rock index
# $15 temporary register
# $16 The number 16
# $22 - $29 temporary registers
# $20 user input register (LK)
# $21 setup completed bit

addi $1, $zero, 20 # The amount of rocks concurrently in play
ls %0, 0, SHIP	# Cache sprites
ls %1, 0, ROCK
ori $16, $zero, 16 # Load a shift by 16
bl INIT_ROCKS
addi $10, $zero, 128 # Set beginning position of space ship
addi $11, $zero, 240 # Set beginning position of space ship

GAME:
	# Black out previous positions of rocks
	bl ERASE_ROCKS

	# Black out previous position of space ship
	ds %2, $10, $11

	# Draw rocks
	bl DRAW_ROCKS
	ds %0, $10, $11 # Redraw space ship

	# Move spaceship if needed
	bl MOVE_SPACESHIP

	# Move rocks, reinitialize if needed
	bl MOVE_ROCKS

	# Detect collisions
	bl DETECT_COLLISIONS

	ori $21, $zero, 1
	b GAME

MOVE_SPACESHIP:
	# Get user keystrokes
	lk $20

	# Start comparing
	andi $12, $20, b00001 # LEFT
	beq MOVE_RIGHT # if this is zero, then LEFT wasn't received, skip

	MOVE_LEFT:
		addi $10, $10, -1

	MOVE_RIGHT:
		andi $12, $20, b00010 # RIGHT
		beq EXIT_MS # Skip if RIGHT wasn't received
		addi $10, $10, 1
	EXIT_MS:
		ret

INIT_ROCKS:
		# Init count register
		ori $14, $1, 0
		beq EXIT_INIT_ROCKS # If no rocks don't init anything
		INIT_ONE_ROCK:

			# Stores rocks as
			# top 16 bits [X] (only lower 8 used)
			# lower 16 bits [Y] (only lower 8 used)

			r $2 # Get random number for x
			lli $2, h0000 # Initialize y at 0 (top)
			swo $2, 0($14) # Store the rock in memory
			addi $14, $14, -1
			bge INIT_ONE_ROCK
		EXIT_INIT_ROCKS:
			ret

DRAW_ROCKS:
		# Init count register
		ori $14, $1, 0
		beq EXIT_DRAW_ROCKS
		DRAW_ONE_ROCK:
			lwo $15, 0($14) # Get the x and y for a rock	
			andi $3, $15, hFFFF # Set y: lower 16	
			srl $2, $15, $16 # Set x: higher 16
			ds %1, $2, $3 # Draw a rock at x and y
			addi $14, $14, -1
			bge DRAW_ONE_ROCK
		EXIT_DRAW_ROCKS:
			ret

ERASE_ROCKS:
		# Init count register
		ori $14, $1, 0
		beq EXIT_ERASE_ROCKS
		ERASE_ONE_ROCK:
			lwo $15, 0($14) # Get the x and y for a rock	
			andi $3, $15, hFFFF # Set y: lower 16	
			srl $2, $15, $16 # Set x: higher 16
			ds %2, $2, $3 # Draw an empty at x and y
			addi $14, $14, -1
			bge ERASE_ONE_ROCK
		EXIT_ERASE_ROCKS:
			ret

MOVE_ROCKS:
		# Init count register
		ori $14, $1, 0
		beq EXIT_MOVE_ROCKS # If no rocks don't init anything
		MOVE_ONE_ROCK:

			# Stores rocks as
			# top 16 bits [X] (only lower 8 used)
			# lower 16 bits [Y] (only lower 8 used)
			lwo $15, 0($14) # Get the x and y for a rock	
			andi $3, $15, hFFFF # Set y: lower 16	
			
			# If the y == 255 - 8 or 247. make it appear at the top
			addi $16, $3, 247
			beq REINIT_ROCK

			MOVE_DOWN_ONE_ROCK:
				addi $15, $15, -1
				swo $15, 0($14) # Store rock in memory
				b MOVE_ONE_ROCK_CONTINUE
			REINIT_ROCK:
				r $2 # Get random number for x
				lli $2, h0000 # Initialize y at 0 (top)
				swo $15, 0($14) # Store rock in memory
			MOVE_ONE_ROCK_CONTINUE:
				addi $14, $14, -1
				bge MOVE_ONE_ROCK
		EXIT_MOVE_ROCKS:
			ret

DETECT_COLLISIONS:
	# Init count register
	ori $14, $1, 0
	lli $22, 8 # the value 8

	# Prepare the x and y for the space ship
	# Insert in the x value
	ori $24, $10, 0

	# Insert in the y value
	andi $26, $11, hFF
	sll $24, $24, $22 # Shift by 8
	or $24, $24, $26 # Or in the y value

	# Insert in the 8 width and 8 height
	sll $24, $24, $22
	or $24, $24, $22
	sll $24, $24, $22
	or $24, $24, $22 # can optimize slightly by using one LLI

	beq EXIT_DETECT_COLLISIONS
	TEST_ONE_ROCK:
		lwo $15, 0($14) # Get the x and y for a rock	
		andi $3, $15, hFF # Set y: lower 8
		srl $2, $15, $16 # Set x: higher 16 (the 8 lower of those)

		# $23 encoded rock compare code
		# $24 encoded space ship compare code
		
		# Insert in the x value
		ori $23, $2, 0

		# Insert in the y value
		sll $23, $23, $22 # Shift by 8
		or $23, $23, $3 # Or in the y value

		# Insert in the 8 width and 8 height
		sll $23, $23, $22
		or $23, $23, $22
		sll $23, $23, $22
		or $23, $23, $22 # can optimize slightly by using one LLI


		# If collision was detected, game is over
		dc $23, $24
		beq FIN
		
		addi $14, $14, -1
		bge TEST_ONE_ROCK
	EXIT_DETECT_COLLISIONS:
		ret
FIN:
	# Write GAME OVER

	# Write SCORE: below it
	tim $14
END:
	b END
