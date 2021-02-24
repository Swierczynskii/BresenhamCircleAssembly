#################################################################################################
#			Jan Œwierczyñski  26.05.2020						#
#################################################################################################
	.data 	
prompt:
	.asciiz "\nEnter the real value of diameter (less than 896): "
radius:
	.asciiz "\nYour radius is: "
next_line:
	.asciiz "\n"		### for debugging purposes
	
	.text 

main:
	
	# prompt the user to enter diameter.
	li $v0, 4
	la $a0, prompt
	syscall
	
	# get the diameter 
	li $v0, 5
	syscall
	
	# storing 'condition numbers' for input diameter
	addiu $t0, $zero, 1
	addiu $t2, $zero, 896
	move $t1, $v0 		# storing in $t1 inputed diameter 
	slt $s0, $t1, $t2 	# $s0 storing logical value, after checking if diameter is less than 1024
	beq $s0, $zero, main	# end of the if statement
	slti $s1, $t1, 0	# $s1 stroring logical value, after checking if diameter is negative 
	beq $s1, $t0, main 	# end of the second if statement
	beq $t1, $zero, main 	# checking if diameter is nonzero
	
	# creating radius out of diameter in $t0 by shifting the register
	srl  $t0, $t1, 1
	
	# printing "radius: "\nYour radius is: ""
	li $v0, 4
	la $a0, radius
	syscall
	
	# print radius' value 
	li $v0, 1
	move $a0, $t0
	syscall
	
	# 'Setting' the middle point on the bitmap display
	li $a1, 512 		# height of the middle point 
	
	
	# allocating memory for the image
	mulu $t7, $t1, $t1	# allocating a 'square' for a circle
	la $a0, ($t7)		# 
	li $v0, 9			
	syscall
	move $t7, $v0		# $t7 storing adress to the allocated memory
	
	#Bresenham initial values
	move $t2, $t0 		# storing radius value in $t2
	addiu $s1, $zero, 3	# $s1 storing integer 3
	subu $s1, $s1, $t1 	# $s1 storing now d = 3-(2*R)
				# $t2 hold in y0's value = given diameter/2 = R  
	addiu $t1, $zero, 0 	# x0 = 0
	li $t3, 0xFFFFFF 	# white colour 
	
	jal middle_point

	jal Point_loop 		# displaying middle point 
	
Bresenham_circle:
	# (x,y)			# First point
	jal middle_point	# initial start
	subu $s7, $s7, $t2	# y0+y # y above middle point 
	sll $t4, $t1, 2		# scaling x values for pixels
	addu $t6, $t6, $t4	# x0+x
	jal Point_loop 		# displaying first point above middle point
	
	# (x,-y)		# Second point
	jal middle_point
	addu $s7, $a1, $t2	# y0-y
	sll $t4, $t1, 2
	addu $t6, $t6, $t4	# x0+x
	jal Point_loop 		
	
	# (-x,y)		# Third point
	jal middle_point
	subu $s7, $a1, $t2	# y0+y
	sll $t4, $t1, 2
	subu $t6, $t6, $t4	# x0-x
	jal Point_loop 		
	
	# (x,-y)		# Fourth point
	jal middle_point
	addu $s7, $a1, $t2	# y0-y
	sll $t4, $t1, 2
	subu $t6, $t6, $t4	# x0-x
	jal Point_loop 
	
	# (y,x)			# Fifth point
	jal middle_point
	subu $s7, $a1, $t1
	sll $t4, $t2, 2
	addu $t6, $t6, $t4
	jal Point_loop 		

	# (-y,x)		# Sixth point
	jal middle_point
	addu $s7, $a1, $t1
	sll $t4, $t2, 2
	addu $t6, $t6, $t4
	jal Point_loop 	
		
	# (y,-x)		# Seventh point
	jal middle_point
	subu $s7, $a1, $t1
	sll $t4, $t2, 2
	subu $t6, $t6, $t4
	jal Point_loop 		
	
	# (-y,-x)		# Eighth point
	jal middle_point
	addu $s7, $a1, $t1
	sll $t4, $t2, 2
	subu $t6, $t6, $t4
	jal Point_loop 	
	
	#going on
	addiu $t1, $t1, 1 	# x++
	bgtz  $s1, d_change	# d > 0
	
	# else
	sll $t5, $t1, 2		# 4*x
	addu $s1, $s1, $zero	# d = d+4*x
	addu $s1, $s1, $t5	# d = d+4*x
	addiu $s1, $s1, 6	# d = d+4*x+3

	j Bresenham_circle
	#bge $t2, $t1, Bresenham_circle
	
exit:
	li $v0, 10
	syscall
	
Point_loop:			#moving y values to the middle

	addiu $t6, $t6, 4096	# length (width) of the whole row -> going to another one
	addiu $s7, $s7, -1	# counter 
	bnez $s7, Point_loop		
	sw $t3, ($t6)
	jr $ra


d_change: 			# changing d parameter (from algorithm)

	subiu $t2, $t2, 1	# y--
	subu $t5, $t1, $t2	# x-y
	bgtz $t5, exit
	sll $t5, $t5, 2		# 4*(x-y)
	addu $s1, $s1, $t5	# d = d+4*(x-y)
	addiu $s1, $s1, 5	# d = d+4(x-y)+10

	j Bresenham_circle	
	
middle_point:	
	move $s7, $a1		
	addu $t6, $t7, $zero 	
	addiu $t6, $t6, 2048	# moving x values to the middle of the bitmap
	jr $ra
