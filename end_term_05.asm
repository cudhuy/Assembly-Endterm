.eqv KEY_CODE 0xFFFF0004 # ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 # =1 if has a new keycode ?
			  # Auto clear after lw
.eqv DISPLAY_CODE 0xFFFF000C # ASCII code to show, 1 byte
.eqv DISPLAY_READY 0xFFFF0008 # =1 if the display has already to do
			      # Auto clear after sw
.data
	arr: .word 0:4
	arr2: .float 0:4
	et: .asciiz ""
	mes: .asciiz "\n"
.text

 	li $k0, KEY_CODE
 	li $k1, KEY_READY
 	li $s0, DISPLAY_CODE
 	li $s1, DISPLAY_READY
	la $t3,arr		#t3: address of array
 	la $t5,arr2		#stack
 	addi $s3,$s3,-1
 	addi $t7,$t7,0
 	
 	mtc1 $zero,$f31		#f3 = 0.0
 	cvt.s.w $f31,$f31	
 	swc1 $f31,($t5)
 	swc1 $f31,4($t5)
init:
	li $t4,0
	li $s7,0
loop: 
	nop
 
WaitForKey: 
	lw $t1, 0($k1) # $t1 = [$k1] = KEY_READY
 	beq $t1, $zero, WaitForKey # if $t1 == 0 then Polling

ReadKey: 
	lw $t0, 0($k0) # $t0 = [$k0] = KEY_CODE
	beq $t0, 0x0A, end
WaitForDis: 
	lw $t2, 0($s1) # $t2 = [$s1] = DISPLAY_READY
	nop
	beq $t2, $zero, WaitForDis # if $t2 == 0 then Polling
ShowKey: 
	beq $t0,0x28,case1	#(
	beq $t0,0x29,case2	#)
	beq $t0,0x2A,case3	#*
	beq $t0,0x2B,case4	#+
	beq $t0,0x2D,case4	#-
	beq $t0,0x2F,case3	#/
	blt $t0,0x2F,loop
	bge $t0,0x3A,loop
	addi $s7,$s7,1
	sw $t0, 0($s0) 		#if number show key
	
	jal chartoint
	beq $s7,2,plus
	
	add $t4,$zero,$s2
#------------------------------------------------
#FLOATING PIOINT NUMBER
	add $t6,$zero,$s2
	mtc1 $t6,$f0
	cvt.s.w $f0,$f0
	
	jal pushnum
#--------------------------------------------------	
	nop
	j loop
plus:
	jal popnum
	sub $s7,$s7,1
	mul $t4,$t4,10
	add $t4,$t4,$s2
	
	add $t6,$zero,$t4
	mtc1 $t6,$f0
	cvt.s.w $f0,$f0
	
	jal pushnum
	j loop

exit:
	li $v0,4
	la $a0,mes
	syscall
	
	jal getadrnum
	lwc1 $f0,($t8)
	li $v0,2
	mov.s $f12,$f0
	syscall
	
	li $v0,4
	la $a0,mes
	syscall
	
	li $v0,57
	mov.s $f12,$f0
	syscall
	
	sw $t0,0($s0)
	#li $v0, 10
	#syscall
	swc1 $f31,($t5)
	swc1 $f31,4($t5)
	swc1 $f31,8($t5)
	swc1 $f31,12($t5)
	j init
#------------------------------------------------------------
#	NUMBER
#	$s2: temporary value
#	$t5: stack of number
#	$t7: index
#	$t9 = i*4
#	$t8 = address at index i
#------------------------------------------------------------
getadrnum:
	sll $t9,$t7,2
	add $t8,$t5,$t9
	jr $ra
pushnum:
	addi $t7,$t7,1
	sll $t9,$t7,2
	add $t8,$t5,$t9
	swc1 $f0,($t8)
	jr $ra
popnum:
	sll $t9,$t7,2
	add $t8,$t5,$t9
	subi $t7,$t7,1
	jr $ra
#-------------------------------------------------------------
#	CREATE STACK FOR OPERATOR
#	$t0: input value// push value
#	$t3: address of array
#	$s3: index i
#	$s4: temporary = i*4
#	$s5: address at index i
#	$s6: value at index i  = arr[i]// pop value
#
#-------------------------------------------------------------
getadr:
	sll $s4,$s3,2		#s4 = i*4
	add $s5,$t3,$s4		#s5 = address of array
	jr $ra
push:
	addi $s3,$s3,1
	sll $s4,$s3,2		#s4 = i*4
	add $s5,$t3,$s4		#s5 = address of array
	sw $t0,0($s5)
	jr $ra
pop:
	sll $s4,$s3,2		#s4 = i*4
	add $s5,$t3,$s4		#s5 = address of array
	lw $s6,0($s5)
	
	sll $t9,$t7,2
	add $t8,$t5,$t9
	lwc1 $f1,($t8)
	subi $t7,$t7,1
	sll $t9,$t7,2
	add $t8,$t5,$t9
	lwc1 $f2,($t8)
	subi $t7,$t7,1
	
	beq $s6,0x2A,nhan	#*
	beq $s6,0x2B,cong	#+
	beq $s6,0x2D,tru	#-
	beq $s6,0x2F,chia	#/
		nhan:
			mul.s $f0,$f1,$f2
			addi $t7,$t7,1
			sll $t9,$t7,2
			add $t8,$t5,$t9
			swc1 $f0,($t8)
			subi $s3,$s3,1
			jr $ra
		chia:
			div.s $f0,$f2,$f1
			addi $t7,$t7,1
			sll $t9,$t7,2
			add $t8,$t5,$t9
			swc1 $f0,($t8)
			subi $s3,$s3,1
			jr $ra
		cong:
			add.s $f0,$f1,$f2
			addi $t7,$t7,1
			sll $t9,$t7,2
			add $t8,$t5,$t9
			swc1 $f0,($t8)
			subi $s3,$s3,1
			jr $ra
		tru:
			sub.s $f0,$f2,$f1
			addi $t7,$t7,1
			sll $t9,$t7,2
			add $t8,$t5,$t9
			swc1 $f0,($t8)
			subi $s3,$s3,1
			jr $ra
	subi $s3,$s3,1
	jr $ra
#-------------------------------------------------------------
case31:
	jal pop
	sw $s6,0($s0)
	sw $t6,0($s0)
	jal push
	j loop
case41:
	jal push
	j loop
end:
	jal pop
	sw $s6,0($s0)
	beq $s3,-1,exit
	j end
#-------------------------------------------------------------
case1: #(
	jal push		#push '(' into array
	j loop
case2:#)
	jal getadr
	lw $s6,0($s5)
	#beq $s6,0x28,loop
	seq $t9,$s6,0x28
	beq $t9,1,case22
	jal pop
	seq $t9,$s6,0x28
	beq $t9,1,case22
	sw $s6,0($s0)		#show value
	j case2
case22:
	subi $s3,$s3,1
	j loop
case3:#*,/
	#beq $s3,0,case41
	subi $s7,$s7,1
	jal getadr
	lw $s6,0($s5)
	beq $s6,0x2A,case31
	beq $s6,0x2F,case31
	jal push
	j loop
case4:#+,-
	#beq $s3,0,case41
	subi $s7,$s7,1
	jal getadr
	lw $s6,0($s5)
	beq $s6,0x28,case41
	beq $s6,0x00,case41
	jal pop
	sw $s6,0($s0)
	jal push
	j loop
#-----------------------------------------------------
chartoint:
	beq $t0,48,n0
	beq $t0,49,n1
	beq $t0,50,n2
	beq $t0,51,n3
	beq $t0,52,n4
	beq $t0,53,n5
	beq $t0,54,n6
	beq $t0,55,n7
	beq $t0,56,n8
	beq $t0,57,n9
	n0:	addi	$s2,$zero,0
		jr $ra
	n1:	addi	$s2,$zero,1
		jr $ra
	n2:	addi	$s2,$zero,2
		jr $ra
	n3:	addi	$s2,$zero,3
		jr $ra
	n4:	addi	$s2,$zero,4
		jr $ra
	n5:	addi	$s2,$zero,5
		jr $ra
	n6:	addi	$s2,$zero,6
		jr $ra
	n7:	addi	$s2,$zero,7
		jr $ra
	n8:	addi	$s2,$zero,8
		jr $ra
	n9:	addi	$s2,$zero,9
		jr $ra

