	.text
    .globl main
    
main:
    BL      firstfunc
    SWI		0x123456

firstfunc:
	ADR     r0, array       @ r0 = &array[0]
	ADR 	r8, stackOut	@ r8 = &stackOut[0]
	ADR		r9, stackAux	@ r9 = &stackAux[0]

    LDR    	r1, [r0], #4    @ r1 = mem[r0] = size(array); r0++

    LDMIA	r0, {r2-r7}		@ copia o conteúdo da memória para a pilha
    STMIA	r9!, {r2-r7}
loop:	
	STMFD r13!, {lr}
	BL 	transfer_stack
	LDMFD r13!, {lr}
	
    SUBS	r1, r1, #1 		@ size(array)--
    CMP		r1, #1
    BLE 	end				@ size(array) <= 1

    MOV		r4, #1			@ r4 = j = 1 (varre de 2 em 2)
bubble:
	CMP		r4, r1			@ j - size(array) 
	BGE		loop			@ terminou de propagar a primeira bolha se j >= size(array)

	LDMDB	r8!, {r2, r3}	@ desempilha 2

	CMP		r2, r3			@ r2 - r3

	STRGT	r2, [r8], #4	@ empilha no stackOut o maior elemento
	STRGT	r3, [r9], #4	@ empilha no stackAux o menor elemento

	STRLE	r3, [r8], #4		 
	STRLE	r2, [r9], #4

	ADD		r4, r4, #1		@ j++
	B 		bubble			@ pula para o início

end:		
    MOV     pc, lr

transfer_stack:
	STMFD	r13!, {r0-r7}	@ armazena os outros regs
loop_ts:	
	CMP		r1, #0			@ verifica o size(array) - 0 - Garantia para a primeira iteração
	BLE 	back			@ termina se size(array) <= 0
	LDR		r2, [r9, #-4]!	@ r2 = stackAux.pop()
	STR 	r2, [r8], #4	@ stackOut.push(r2)
	SUBS 	r1, r1, #1 	@ size(array)--
	B loop_ts

back:
	LDMFD	r13!, {r0-r7}
	MOV		pc, lr

array:
	.word 0x6, 0x5, 0x2, 0x4, 0x3, 0x1, 0x8, 0x9 	@ o primeiro elemento é o tamanho do array

stackOut:
	.space 32

stackAux:
	.space 32
