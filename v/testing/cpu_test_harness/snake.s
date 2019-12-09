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

# food begins in random location on screen
bl RANDOM_FOOD

START:
TICK:

	# get time so we know when this frame should end
	tim $1
	add $29, $1, $2

	# draw snake
	ds %0, $3, $4

	# draw food
	ds %2, $0, $0

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
	andi $5, $7, h00f8

	ret
