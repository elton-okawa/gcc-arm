    .text
	.globl main
	
main:
	LDR 	r1, =20			@ r1 = n = 20
	BL		firstfunc
	SWI     0x123456

firstfunc:
	LDR 	r2, =0			@ r2 = 0 = fib[i-2]
	LDR 	r3, =1			@ r3 = 1 = fib[i-1]
	LDR 	r4, =2			@ r4 = 2 = i
loop:
	ADD		r0, r2, r3		@ r0 = r2 + r3 = fib[i-2] + fib[i-1]
	ADD		r4, r4, #1		@ i++
	CMP		r4, r1			@ compara i com n
	MOV		r2, r3			@ r2 = r3 (fib[i-2] = fib[i-1], considerando o i da iteração atual (antes de i++))
	MOV		r3, r0			@ r3 = r0 (fib[i-1] = fib[i], considerando o i da iteração atual (antes de i++))
	BLE		loop			@ continua o loop se i <= n
	MOV		pc, lr

