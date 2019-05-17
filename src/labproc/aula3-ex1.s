	.text
	.globl main
main:
	MOV	r0, #2		
	MOV	r1, #2
	BL	firstfunc				
	SWI	0x123456		
firstfunc:
	SUB	r11, r12, r3, LSL #31
	MOV	pc, lr	
