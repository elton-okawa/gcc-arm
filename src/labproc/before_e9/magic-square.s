    .text
  .globl main
main:    
  LDR    r1, =3                   @ r1 = N. N é o tamanho da matriz
  LDR    r9, =1                   @ r9 = 1. Se r9 = 1, matriz é magic square. Se r9 = 0, matriz não é magic square
  ADR    r0, matrix               @ ponteiro para o início da matriz
  ADR    r2, unique
  BL     checkUniqueness          @ verifica se os valores da matrix são diferentes
  BL     calcValue                @ armazena em r10 o valor de N(N^2 + 1)/2
  BL     checkRows                @ verifica se as linhas satisfazem condição para ser magic square
  BL     checkColumns             @ verifica se as colunas satisfazem condição para ser magic square
  BL     checkMainDiagonal        @ verifica se diagonal principal satisfaz condição para ser magic square
  BL     checkSecDiagonal         @ verifica se diagonal secundária satisfaz condição para ser magic square

end:
  SWI        0x123456        

checkUniqueness:
  LDR  r5, =1          @ r5 = 1 para marcar o check como lido
  MUL  r6, r1, r1      @ r6 = N * N (tamanho da matrix para ser avaliada)
  MOV  r7, r0          @ r7 = r0 - r7 aponta para o começo da matrix
loopUniqueness:
  LDRB  r3, [r7], #1    @ r3 = matrix[r0]
  LDRB  r4, [r2, r3]    @ r4 = check[r3]
  CMP  r4, #1           @ r4 - 1
  BEQ  notMagic
  STRB  r5, [r2, r3]    @ check[r3] = 1
  SUB  r6, r6, #1      @ r6--
  CMP  r6, #0
  BGT  loopUniqueness
  MOV pc, lr

calcValue:
  LDR r10, =0           @ r10 = 0
  MUL r10, r1, r1       @ r10 = N * N
  ADD r10, r10, #1      @ r10++
  MUL r11, r10, r1      @ r11 = r10 * N
  MOV r10, r11          @ r10 = r11 = N(N^2 + 1)
  MOV r10, r10, LSR #1  @ r10 >> 1. Divisao de r10 por 2
 
  MOV pc, lr



checkRows:
  LDR r2, =0            @ r2 = i = 0
  LDR r3, =0            @ r3 = j = 0
  MOV r4, r0            @ r4 = r0 = ponteiro para início da matriz

loopRows:
  LDR r5, =0            @ r5 = 0 = soma dos elementos da linha
  LDR r3, =0            @ j = 0

loopElemInRow:
  LDRB  r6, [r4], #1    @ r6 = próximo elemento da linha. A cada leitura r4 aponta para o próximo elemento
  ADD   r5, r5, r6      @ r5 += r6

  ADD r3, r3, #1        @ j++
  CMP r3, r1            @ compara j com N
  BLT loopElemInRow     @ desvia para loopElemInRow se j < N
 
  CMP r5, r10           @ compara r5 com r10
  LDRNE r9, =0          @ caso soma da linha seja diferente do valor esperado, clear em r9

  ADD r2, r2, #1        @ i++
  CMP r2, r1            @ compara i com N
  BLT loopRows          @ desvia para loopRows se i < N

  MOV pc, lr



checkColumns:
  LDR r2, =0            @ r2 = i = 0
  LDR r3, =0            @ r3 = j = 0

loopColumns:
  MOV r4, r0            @ r4 = r0 = ponteiro para início da matriz
  ADD r4, r4, r3        @ r4 += j. Alinha o elemento a ser lido com a coluna atual sendo avaliada
  LDR r5, =0            @ r5 = 0 = soma dos elementos da coluna
  LDR r2, =0            @ i = 0

loopElemInColumn:
  LDRB  r6, [r4], r1    @ r6 = próximo elemento da coluna. A cada leitura r4 aponta para o próximo elemento
  ADD   r5, r5, r6      @ r5 += r6

  ADD r2, r2, #1        @ i++
  CMP r2, r1            @ compara i com N
  BLT loopElemInColumn  @ desvia para loopElemInColumn se i < N
 
  CMP r5, r10           @ compara r5 com r10
  LDRNE r9, =0          @ caso soma da linha seja diferente do valor esperado, clear em r9

  ADD r3, r3, #1        @ j++
  CMP r3, r1            @ compara j com N
  BLT loopColumns       @ desvia para loopColumns se j < N

  MOV pc, lr



checkMainDiagonal:
  LDR r2, =0            @ r2 = i = 0
  ADD r3, r1, #1        @ r3 = N + 1
  LDR r5, =0            @ r5 = 0 = soma dos elementos da diagonal
  MOV r4, r0            @ r4 = r0 = ponteiro para início da matriz

loopRowsMD:
  LDRB  r6, [r4], r3    @ r6 = próximo elemento da diagonal. A cada leitura r4 aponta para o próximo elemento
  ADD r5, r5, r6        @ r5 += r6

  ADD r2, r2, #1        @ i++
  CMP r2, r1            @ compara i com N
  BLT loopRowsMD        @ desvia para loopRowsMD se i < N

  CMP r5, r10           @ compara r5 com r10
  LDRNE r9, =0          @ caso soma da linha seja diferente do valor esperado, clear em r9

  MOV pc, lr


checkSecDiagonal:
  LDR r2, =0            @ r2 = i = 0
  SUB r3, r1, #1        @ r3 = N - 1
  LDR r5, =0            @ r5 = 0 = soma dos elementos da diagonal
  MOV r4, r0            @ r4 = r0 = ponteiro para início da matriz
  ADD r4, r4, r3        @ r4 += r3. Aponta para o primeiro elemento da diagonal secundaria

loopRowsSD:
  LDRB  r6, [r4], r3    @ r6 = próximo elemento da diagonal. A cada leitura r4 aponta para o próximo elemento
  ADD r5, r5, r6        @ r5 += r6

  ADD r2, r2, #1        @ i++
  CMP r2, r1            @ compara i com N
  BLT loopRowsSD          @ desvia para loopRowsSD se i < N

  CMP r5, r10           @ compara r5 com r10
  LDRNE r9, =0          @ caso soma da linha seja diferente do valor esperado, clear em r9

  MOV pc, lr

notMagic:
  MOV r9, #0
  B   end

matrix:
  .byte 2, 7, 6, 9, 5, 1, 4, 3, 8

  .align
unique: 
  .skip 10
