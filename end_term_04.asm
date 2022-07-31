# Marsbot in final exam 4
.eqv HEADING 0xffff8010    # Integer: An angle between 0 and 359
# 0 : North (up)
# 90: East (right)
# 180: South (down)
# 270: West (left) 
.eqv MOVING 0xffff8050   # Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020    # Boolean (0 or non-0)
# whether or not to leave a track
.eqv WHEREX 0xffff8030   #Integer: Current x-location of MarsBot
.eqv WHEREY 0xffff8040   #Integer: Current y-location of MarsBot
# Key matrix
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012    #used to command row number of hexadecimal keyboard.
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014   #used to receive row and column number of the key pressed

.data
# structure: (rotate,time,0=untrack // 1=track;)
# postscript: DCE <=> 0
postscript1: .asciiz "90,2000,0;180,3000,0;180,5785,1;80,500,1;70,500,1;60,500,1;50,500,1;40,500,1;30,500,1;20,500,1;10,500,1;0,500,1;350,500,1;340,500,1;330,500,1;320,500,1;310,500,1;300,500,1;290,500,1;280,500,1;90,7600,0;270,550,1;260,500,1;250,500,1;240,500,1;230,500,1;220,500,1;210,500,1;200,500,1;190,500,1;180,500,1;170,500,1;160,500,1;150,500,1;140,500,1;130,500,1;120,500,1;110,500,1;100,500,1;90,800,1;90,4200,0;270,2400,1;0,5785,1;90,2400,1;180,2895,0;270,2400,1;180,4000,0;"
# postscript: ICT <=> 4
postscript2: .asciiz "90,3000,0;180,3000,0;270,1500,0;90,3000,1;270,1500,0;180,5785,1;270,1500,0;90,3000,1;90,4800,0;270,600,1;280,500,1;290,500,1;300,500,1;310,500,1;320,500,1;330,500,1;340,500,1;350,500,1;0,500,1;10,500,1;20,500,1;30,500,1;40,500,1;50,500,1;60,500,1;70,500,1;80,500,1;90,500,1;90,3700,0;180,5780,1;0,5780,0;270,2400,0;90,4800,1;90,1000,0;"
# postscript: HUY <=> 8
postscript3: .asciiz "90,2000,0;180,3000,0;180,5785,1;0,2895,1;90,2700,1;0,2890,0;180,5785,1;0,5785,0;90,2700,0;180,4900,1;160,300,1;140,300,1;120,300,1;100,300,1;90,1650,1;70,300,1;50,300,1;30,300,1;15,300,1;0,4900,1;90,2600,0;150,2700,1;30,2700,1;210,2700,0;180,3100,1;90,1000,0;"
# postscript: TU <=> c
postscript4: .asciiz "90,5000,0;180,3000,0;180,5780,1;0,5780,0;270,2500,0;90,5000,1;90,2600,0;180,4900,1;160,300,1;140,300,1;120,300,1;100,300,1;90,1800,1;70,300,1;45,300,1;20,300,1;0,4900,1;90,1000,0;"
.text

# -------------solving on keymatrix--------------
	li $t2, IN_ADRESS_HEXA_KEYBOARD    #0xFFFF0012
	li $t3, OUT_ADRESS_HEXA_KEYBOARD   #0xFFFF0014
Polling: 
	li $t4, 0x01 # row number 1
	sb $t4, 0($t2) 
	lb $a0, 0($t3) 
	bne $a0, 0x11, NOT_NUM_0
	la $a1, postscript1
	j START
	NOT_NUM_0:
	li $t4, 0x02 # row number 2
	sb $t4, 0($t2)
	lb $a0, 0($t3)
	bne $a0, 0x12, NOT_NUM_4
	la $a1, postscript2
	j START
	NOT_NUM_4:
	li $t4, 0X04 # row number 4
	sb $t4, 0($t2)
	lb $a0, 0($t3)
	bne $a0, 0x14, NOT_NUM_8
	la $a1, postscript3
	j START
	NOT_NUM_8:
	li $t4, 0X08 # row number 8
	sb $t4, 0($t2)
	lb $a0, 0($t3)
	bne $a0, 0x18, Back_to_polling
	la $a1, postscript4
	j START
Back_to_polling: j Polling # khi cac ki tu 0,4,8,c khong duoc chon thi back de doc tiep

#------------------solving---------------------
START:	
	li $t6, 0  #so bit da dich
	jal GO
READ_POSTSCRIPT: 
	li $t0, 0 # reset gia tri rotate
	li $t1, 0 # reset gia tri time
	
 	SOLVE_ROTATE:  #doc goc chuyen dong
 	add $t5, $a1, $t6  # dich bit    
	lb $t4, 0($t5)   # doc cac ki tu cua postscript
	seq $t7, $t4, 0
	beq $t7, 1, END  # end postscript khi gap ki tu null
	seq $t7, $t4, 44
 	beq $t7, 1, SOLVE_TIME  # khi gap ki tu , xuong read time
 	mul $t0, $t0, 10 #0  
 	subi $t4, $t4, 48  # So 0 trong bang ascii.  t4 57-48=9
 	add $t0, $t0, $t4   # cong cac chu so lai voi nhau va luu o t0 
 	addi $t6, $t6, 1  # tang so bit can dich chuyen len 1  
 	j SOLVE_ROTATE
 	
 	SOLVE_TIME: # doc thoi gian chuyen dong.
 	add $a0, $t0, $0  # lay gia tri cho a0
	jal ROTATE
 	addi $t6, $t6, 1  # tang so bit can dich chuyen len 1
 	add $t5, $a1, $t6  # dich bit
	lb $t4, 0($t5)   # tiep tuc doc cac ki tu cua postscript
	seq $t7, $t4, 44
	beq $t7, 1, SOLVE_TRACK  #khi gap ki tu , xuong read track
	mul $t1, $t1, 10 #x10
 	subi $t4, $t4, 48  # So 0 trong bang ascii.
 	add $t1, $t1, $t4
 	j SOLVE_TIME 
 	
 	SOLVE_TRACK:  # track or not
 	li $v0, 32  # giữ cho marsbot hoạt động bằng cách ngủ với thời gian = $t1
 	add $a0, $0, $t1  #lay gia tri cho a0
 	addi $t6, $t6, 1  # tang so bit can dich chuyen len 1
 	add $t5, $a1, $t6  # dich bit
	lb $t4, 0($t5)   # doc cac ki tu cua postscript
 	subi $t4, $t4, 48  # So 0 trong bang ascii.
 	beq $t4, 0, CHECK_UNTRACK  # track or untrack
 	jal UNTRACK
	jal TRACK
	j INCREASE_2_BIT
	
CHECK_UNTRACK:
	jal UNTRACK
	
INCREASE_2_BIT:   # bo qua dau ;
 	addi $t6, $t6, 2 # dich 2 bit
 	syscall
 	j READ_POSTSCRIPT  # quay lai tu dau
END_MAIN:	

#-----------------------------------------------------
GO: 
 	li $at, MOVING  # change MOVING port
 	addi $k0, $0,1  # to logic 1,
 	sb $k0, 0($at)  # to start running
 	nop
 	jr $ra
 	nop

STOP: 
	li $at, MOVING  # change MOVING port to 0
 	sb $0, 0($at)   # to stop
 	nop
 	jr $ra
 	nop

TRACK: 
	li $at, LEAVETRACK   # change LEAVETRACK port
 	addi $k0, $0,1       # to logic 1,
	sb $k0, 0($at)       # to start tracking
	nop
 	jr $ra
 	nop

UNTRACK:
	li $at, LEAVETRACK   # change LEAVETRACK port to 0
 	sb $0, 0($at)        # to stop drawing tail
 	nop
 	jr $ra
 	nop

ROTATE: 
	li $at, HEADING      # change HEADING port
 	sw $a0, 0($at)       # to rotate robot
 	nop
 	jr $ra
 	nop
 	
END:
	jal STOP
	li $v0, 10    # end chuong trinh
	syscall
	j Polling
#-----------------end------------------