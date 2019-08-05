	.text
    .globl main
    
main:
    BL      firstfunc
    SWI		0x123456

firstfunc:
	ADR     r0, array       @ r0 = &array[-1]
    LDR    r1, [r0], #4    	@ r1 = mem[r0] = size(array); r0 + 1
loop:	
    SUBS	r1, r1, #1 		@ size(array)--
    BLE 	end				@ size(array) <= 1
    MOV 	r6, r0			@ r6 = &array[0]
    MOV		r4, #0			@ r4 = j = 0 
bubble:
	CMP		r4, r1			@ j - size(array)
	BGE		loop			@ terminou de propagar a primeira bolha se j >= size(array)
	
	LDMIA	r6, {r2, r3}	@ r2 = array[r6]; r3 = array[r6 + 1]
	CMP		r2, r3			@ r2 - r3

	MOVGT	r7, r2			@ swap r2 e r3 se r2 > r3
	MOVGT	r2, r3
	MOVGT	r3, r7

	STMIA	r6, {r2, r3}	@ armazena

	ADD		r4, r4, #1		@ j++
	ADD		r6, r6, #4		@ r6++ (4 porque é word)
	B 		bubble			@ pula para o início

end:		
    MOV     pc, lr

array:
	.word 0x7, 0x5, 0x2, 0x4, 0x3, 0x1, 0x0, 0x6 	@ o primeiro elemento é o tamanho do array
