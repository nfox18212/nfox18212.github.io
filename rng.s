	.cdecls C,NOLIST,"debug.h"
    .data

colorlist:	.word 0x01010101 ; 4 1s
			.word 0x01010101 ; 8 1s
			.word 0x01020202 ; 9 1s, 3 2s
			.word 0x02020202 ; 7 2s
			.word 0x02020303 ; 9 2s, 2 3s
			.word 0x03030303 ; 6 3s
			.word 0x03030304 ; 9 3s, 1 4
			.word 0x04040404 ; 5 4s
			.word 0x04040404 ; 9 4s
			.word 0x05050505 ; 4 5s
			.word 0x05050505 ; 8 5s
			.word 0x05060606 ; 9 5s, 3 6s
			.word 0x06060606 ; 7 6s
			.word 0x06060000 ; 9 6s and null termination

idxstr:		.cstring "    "

	.global seeddata
	.global	colorlist
	.global cells
    .text
dbg:			.set	1
colorlistp:    .word    colorlist

    .global seed
    .global set_color
    .global get_cell
    .if dbg=1
    .global output_string
    .global output_character
    .global int2string
    .endif


seeddatap:	.word 	seeddata
cellp:		.word 	cells
idxstrp:	.word 	idxstr


seed:
    push    {r4-r12, lr}

    ldr     r4, seeddatap
    ldr     r7, [r4, #0]        ; this is the initial seed
    mov     r10, #1000          ; r10 will be the number of iterations
	ldr		r6, colorlistp		; pointer to color list

rngloop:
	; TODO: Fix the color swapping in this subroutine
	; r0, r1 - contains index1 and colorlist[index1]
	; r2, r3 - contains index2 and colorlist[index2]
    and     r0, r7, #6      ; look for last 6 bits - this is index 1
    bl      reduce          ; make sure its less than 54

    .if dbg=1
    push	{r0-r4}
    ; for debug: print idx contents
    mov		r1, r0
    ldr		r0, idxstrp
    bl		int2string
    bl		output_string
    mov		r0, #0x20
    bl		output_character
    pop		{r0-r4}
    .endif

	push	{r0}			; backup r0 to preserve index 1
    ror     r0, r0, #29   	; shuffle those bits around - this is index 2
	bl		reduce			; make sure its less than 54
	mov		r2, r0			; make sure index 2 is in r2

	.if dbg=1
	push	{r0-r4}
	ldr		r0, idxstrp
	mov		r1, r2
	bl		int2string
	bl		output_string
	pop		{r0-r4}
	.endif

	pop		{r0}			; get index 1
	ldrb	r1, [r6, r0]	; load colorlist[index1]
	ldrb	r3, [r6, r2]	; load colorlist[index2]
	strb	r3, [r6, r0]	; store colorlist[index2] into colorlist[index1] - swap the bytes
	strb	r1, [r6, r2]

	; make seed more "random" using xorshift psuedo-random number generation
	; seed is in r7
	lsr		r8, r7, #7
	sub		r8, r8, #7		; just to make sure the last bit is changed
	eor		r7, r8, r7		; seed ^= (seed >> 7)-7
	lsl		r8, r7, #13
	add		r8, r8, #13
	eor		r7, r8, r7		; seed ^= (seed << 13) + 13
	lsr		r8, r7, #5
	sub		r8, r8, #5
	eor		r7, r8, r7		; seed ^= (seed >> 5) - 5
	lsr		r8, r7, #9
	add		r8, r8, #9
	eor		r7, r8, r7		; seed ^= (seed << 9) + 9
	; since its just in one register, it'll automatically be 32 bits
	
	sub 	r10, r10, #1	; decrement number of iterations
	cmp		r10, #0
	bne		rngloop			; if we've hit zero, fill the alist with the colors

	mov		r2, r6			; move colorlist addr to r0 to easily iterate through it
	ldr		r3, cellp
	bl		fill_alist

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
	push	{r4-r12, lr}
	mov		r4, #0xFF		; stop byte
fill_alist_L:
	; actually iterates through the color_list to put the colors into it
	ldrb	r1, [r2], #1	; post-indexed by 1 byte to iterate through the color list for each color
	ldrb	r0, [r2], #2	; post indexed by 2 to iterate through cell list
	cmp		r0, r4			; make sure its not the end of the cell list
	it		ne
	blne	set_color		; set the color from the color list
	bne		fill_alist_L
	; exit if we hit lr
	pop		{r4-r12, lr}
	mov		pc, lr			; if we hit the 0xFFFF byte, return

	
