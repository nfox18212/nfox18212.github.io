
    .data

colorlist:
			.byte 0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1
			.byte 0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2
			.byte 0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3
			.byte 0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4
			.byte 0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x5
			.byte 0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6

	.global seeddata

    .text

colorlistp:    .word    colorlist

    .global seed
    .global set_color
    .global get_cell


seeddatap:	.word 	seeddata

seed:
    push    {r4-r12, lr}

    ldr     r4, seeddatap
    ldr     r7, [r4, #0]        ; this is the initial seed
    mov     r10, #1000          ; r10 will be the number of iterations
	ldr		r6, colorlistp		; pointer to color list

rngloop:
	; r0, r1 - contains index1 and colorlist[index1]
	; r2, r3 - contains index2 and colorlist[index2]
    and     r0, r7, #6      ; look for last 6 bits - this is index 1
    bl      reduce          ; make sure its less than 54
	push	{r0}			; backup r0
    ror     r0, r0, #29   	; shuffle those bits around - this is index 2
	bl		reduce			; make sure its less than 54
	mov		r2, r0			; make sure index 2 is in r2
	pop		{r0}			; get index 1
	ldrb	r1, [r6, r0]	; load colorlist[index1]
	ldrb	r3, [r6, r2]	; load colorlist[index2]
	strb	r3, [r6, r0]	; store colorlist[index2] into colorlist[index1] - swap the bytes
	strb	r1, [r6, r2]

	; make seed more "random" using xorshift psuedo-random number generation
	; seed is in r7
	lsr		r8, r7, #7
	eor		r7, r8, r7		; seed ^= seed >> 7
	lsl		r8, r7, #13
	eor		r7, r8, r7		; seed ^= seed << 13
	lsr		r8, r7, #5
	eor		r7, r8, r7		; seed ^= seed >> 5
	lsr		r8, r7, #9
	eor		r7, r8, r7		; seed ^= seed << 9
	; since its just in one register, it'll automatically be 32 bits
	
	sub 	r10, r10, #1	; decrement number of iterations
	cmp		r10, #0
	bne		rngloop			; if we've hit zero, return

    pop     {r4-r12, lr}
    mov     pc, lr


reduce: ; can't be a macro bc of loop
    cmp    	r0, #54
    ittte  	ge
    eorge  	r0, r0, #0x33
    lsrge  	r0, #1
    bge    	reduce
    blt    	goback

goback:     ; this exists only to get around the limitation that you can't modify the pc in a it block
    mov     pc, lr
