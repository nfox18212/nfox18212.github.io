
    .data

colorlist:	.byte 0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1,0x1
			.byte 0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2,0x2
			.byte 0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3
			.byte 0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4,0x4
			.byte 0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x5
			.byte 0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6, 0x0 ; null terminated

	.global seeddata
	.global	colorlist
	.global cells
    .text

colorlistp:    .word    colorlist

    .global seed
    .global set_color
    .global get_cell


seeddatap:	.word 	seeddata
cellp:		.word 	cells

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
	bne		rngloop			; if we've hit zero, fill the alist with the colors

	mov		r2, r6			; move colorlist addr to r0 to easily iterate through it
	ldr		r3, cellp
	push	{r4-r12,lr} 	; not *exactly* ahdering to the standard, but sort of
	bl		fill_alist
	; popped when returned

    pop     {r4-r12, lr}
    mov     pc, lr


reduce: ; can't be a macro bc of loop
    cmp    	r0, #54
    ittte  	ge
    eorge  	r0, r0, #0x33
    lsrge  	r0, #1
    bge    	reduce
	movlt	pc, lr


fill_alist:
	; actually iterates through the color_list to put the colors into it
	ldrb	r1, [r2], #1	; post-indexed by 1 byte to iterate through the color list for each color
	ldrh	r0, [r2], #2	; post indexed by 2 to iterate through cell list
	mov		r4, #0xFFFF		; stop byte
	cmp		r0, r4		; make sure its not the end of the cell list
	ite	ne
	blne	set_color		; set the color from the color list
	moveq	pc, lr			; if we hit the 0xFFFF byte, return
	bne		fill_alist		; loop - yes this looks weird but this can execute due to the moveq not executing because of the it block
	
