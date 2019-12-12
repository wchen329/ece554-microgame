MAIN:

	INIT:

		ls %0, 0, SNAKE
		ls %1, 0, FOOD

		# snake location is $1, $2
		lli $1, 124
		lui $1, 0
		lli $2, 124
		lui $2, 0

		# food location is $3, $4
		# randomized
		bl NEW_FOOD

		# track number of ticks since game start in $5
		lli $5, 0
		lui $5, 0

		# food orientation is tracked in $6
		lli $6, 0
		lui $6, 0

		# snake movement direction is tracked in $7
		# initially moving upwards (0)
		lli $7, 1
		lui $7, 0

		# temp regs:
		# $29, $28, $27, $26

	TICK:
		
		tim $30
		# calculate time for this frame to end
		addi $30, $30, h64

		# clear all sprites
		# snake
		cs $1, $2
		# food
		cs $3, $4

		# food orientation changes every 8 frames
		addi $29, $0, 3
		srl $29, $5, $29
		andi $29, $29, h0001
		add $6, $6, $29

		ROTATE_FOOD:

			ROTATE_FOOD_0:

			addi $0, $6, 0
			bne ROTATE_FOOD_1
			rs %1, 0
			b END_ROTATE_FOOD

			ROTATE_FOOD_1:

			addi $0, $6, -1
			bne ROTATE_FOOD_2
			rs %1, 1
			b END_ROTATE_FOOD

			ROTATE_FOOD_2:

			addi $0, $6, -2
			bne ROTATE_FOOD_3
			rs %1, 2
			b END_ROTATE_FOOD

			ROTATE_FOOD_3:
			
			rs %1, 3

		END_ROTATE_FOOD:	

		# draw all sprites
		# snake
		ds %0, $1, $2
		# food
		ds %1, $3, $4

	WAIT:

		# wait til we reach tick end time
		tim $29
		sub $0, $30, $29
		addi $5, $5, 1
		blt TICK
		b WAIT



NEW_FOOD:

		r $3
		andi $3, $3, h00FF
		r $4
		andi $4, $4, h00FF
		ret



MOVE_SNAKE:
	
		# snake is in $1, $2, and moves based on keys
		# snake movement direction is tracked in $7
		lk $29
		lli $28, 1
		lui $28, 0
		
		srl $29, $29, $28
		




