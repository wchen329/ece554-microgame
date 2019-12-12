#This test is to verify that the memory read/writes are working correctly.  
	#$3 = x store
	#$4 = y store
	#$5 = color to store
	#$6 = x loacation to store
	#$7 = y location to store
	#$8 = color loacation to store
	#$9 = x read
	#$10 = y read
	#$11 = color read
	#$20 = current time
	#$21 = time to wait until
	
	ls %1, 0, RED

	#initialize to 0
	andi $1, $1, 0

	#seed rng
	addi $2, $1, hdead
	sr $2
	
START:
	
	#generate random x y coordinates
	r $3
	r $4
	
	#set color
	addi $5, $1, hdead
	
	#generate random locations to store
	r $6
	r $7
	r $8
	
	#mask location to be a valid address
	andi $6, $6, h01ff
	andi $7, $7, h01ff
	andi $8, $8, h01ff
	
	#store x y and color at random location
	swo $3, 0($6)
	swo $4, 0($7)
	swo $5, 0($7)
	
	#read x y coordinates from store location
	lwo $9, 0($6)
	lwo $10, 0($7)
	lwo $11, 0($8)
	
	#draw to screen at x y coordinates
	ds %1,$9, $10 
	dfb
	
	#wait
	tim $21
	addi $21, $21, h0018
LOOP:
	tim $20
	sub $20, $21, $20
	bgt LOOP
	
	#repeat
	b START
