.data

B:		.float  0.0		# First Operand	($f1)
C:		.float  0.0		# Second Operand ($f2)

OPT:		.word	0		# Operation Code ($s0)

#Strings for console feedback

CON_QRY:	.asciiz ">> "
OPT_MENU:	.asciiz	"\nChoose the operation (Single Precision):\n"
OPT_ADD:	.asciiz "0. ADD\n"
OPT_MULT:	.asciiz "1. MULT\n"
OPT_RPT:	.asciiz "\nRepeat? (0. Yes / 1. No)\n"
OPR_A:		.asciiz "\nType First Operand:\n"
OPR_B:		.asciiz "\nType Second Operand:\n"
RES:		.asciiz "\nResult: "


.text
main:

menu:
li	$v0, 4			# Print string v0 code

la	$a0, OPT_MENU		# Print MENU Text
syscall
la	$a0, OPT_ADD		# Print ADD Text
syscall
la	$a0, OPT_MULT		# Print SIGN Text
syscall
la	$a0, CON_QRY		# Print Console Query
syscall

li	$v0, 5			# Read integer v0 code
syscall				# Reading OPT (Operation Code) 
sw	$v0, OPT

read_operands:
li	$v0, 4			# Print string v0 code
la	$a0, OPR_A		# Print "First operand"
syscall
la	$a0, CON_QRY		# Print console query
syscall

li	$v0, 6			# Read float v0 code
syscall
swc1 	$f0, B			# Save first operand

li	$v0, 4			# Print string v0 code
la	$a0, OPR_B		# Print "Second operand"
syscall
la	$a0, CON_QRY		# Print console query
syscall

li	$v0, 6			# Read float v0 code
syscall
swc1 	$f0, C			# Save second operand

#Choosing between operations (ADD or MULT)
lw	$s0, OPT
beq	$s0, $zero, opt_add
j	opt_mult		

opt_add:
lwc1	$f1, B
lwc1	$f2, C
add.s	$f12, $f1, $f2
j	display_result

opt_mult:
lwc1	$f1, B
lwc1	$f2, C
mul.s	$f12, $f1, $f2

display_result:
li	$v0, 4			# Print string v0 code
la	$a0, RES		# Load "result"
syscall
li	$v0, 2			# Print float v0 code
syscall

repeat:
li	$v0, 4			# Print string v0 code
la	$a0, OPT_RPT		# Print Repeat option
syscall
la	$a0, CON_QRY		# Print console query
syscall
li	$v0, 5			# Read integer v0 code
syscall				# Reading integer 
beq	$v0, $zero, main	# Repeating if 0 

end_prog:
li	$v0, 10			# Call to finish program 
syscall
