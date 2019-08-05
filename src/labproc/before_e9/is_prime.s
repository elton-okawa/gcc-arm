        .text
    	.globl main
main:
    	LDR     r0, =1                 @ r0 = saida primo (1) ou nao (0)
        LDR     r1, =337                @ r1 = numero sendo testado
        BL      isPrime
    	SWI 	0x123456


isPrime:
        LDR     r2, =2                  @ r2 = divisor

loopPrime:
        CMP     r2, r1                  @ compara se divisor >= dividendo 
        BGE     endPrime

        STMFD   r13!, {r3, r4, r5, lr}      @ salva os registradores
        BL      startDivisao
        MOV     r7, r3                  @ copia quociente
        MOV     r8, r5                  @ copia o resto
        LDMFD   r13!, {r3, r4, r5, lr}      @ restaura os registradores

        CMP     r8, #0                  @ verifica se o resto é zero
        BEQ     notPrime                

        ADD     r2, r2, #1              @ incrementa o divisor
        B       loopPrime

notPrime:
        MOV     r0, #0
        B       endPrime

endPrime:
        MOV     pc, lr
@ ----------------------------------------------------------
startDivisao:

    	LDR 	r3, =0              	@ r3 = quociente
    	MOV 	r5, r1              	@ r5 = resto = dividendo
    	MOV 	r4, r2              	@ r4 = divisor deslocado = r2

desloca:
    	MOVS	r4, r4, LSL#1       	@ divisor deslocado = divisor deslocado << 1
    	CMP 	r1, r4              	@ compara dividendo com divisor deslocado
    	BGE 	desloca             	@ volta para desloca caso dividendo >= divisor deslocado

    	MOV 	r4, r4, LSR#1       	@ divisor deslocado = divisor deslocado >> 1

divide:
    	CMP 	r5, r4              	@ compara resto com divisor
    	BLT 	else                	@ desvia para o else caso resto < divisor
    	SUB 	r5, r5, r4          	@ resto -= divisor
    	MOV 	r3, r3, LSL#1       	@ quociente = quociente << 1
    	ADD 	r3, r3, #1          	@ quociente ++
    	B   	movdesl             	@ pula o else   

else:
    	MOV 	r3, r3, LSL#1       	@ quociente = quociente << 1

movdesl:
    	MOV 	r4, r4, LSR#1       	@ divisor deslocado = divisor deslocado >> 1

    	CMP 	r4, r2              	@ compara divisor deslocado com divisor original
    	BGE 	divide              	@ caso divisor deslocado >= divisor original, continua dividindo
    	BLT 	fim                 	@ caso divisor deslocado < divisor original, a divisao acabou
    	CMP 	r5, r4              	@ compara resto com divisor deslocado
    	BGE 	divide              	@ caso resto >= divisor deslocado, continua dividindo

fim:	MOV 	pc, lr
