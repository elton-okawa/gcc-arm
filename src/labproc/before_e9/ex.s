	.text
    .globl main
    
main:
	@	4 = word, 2 = half-word, 1 = byte
	LDR	 	r0, =1
	LDR		r1, =-1
	BL      func1
    SWI		0x123456

func1:
	CMP		r0, #4 		@ r0 - 4 (verifica se é word)
	STREQ	r1, [r13], r0

	CMP		r0, #2		@ r0 - 2 (verifica se é half-word)
	STREQH	r1, [r13], r0	
	
	CMP		r0, #1		@ r0 - 1 (verifica se é byte)
	STREQB	r1, [r13], r0
	MOV		pc, lr
