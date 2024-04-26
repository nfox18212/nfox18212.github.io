	.cdecls C,NOLIST,"debug.h"


	.data

winstr:		.string 	"Congratulations!  You have filled all six sides of the cube and have won!  Would you like to play again? [Y/n]", 0xD, 0xA, 0x0
losestr:	.string 	"Unfortunate!  You ran out of time before you filled all six sides of the cube.  Would you like to play again? [Y/n]", 0xD, 0xA, 0x0
inputstr:	.cstring	"        "
badin:		.string		"That is not a [y]es or a [n]o.  Please input y or n and enter.", 0xD, 0xA, 0x0
stringthing:.string		"          ", 0x0

	.global endgame
	.global	seeddata

	.text
	.global end_game
	.global read_string
	.global illuminate_LEDs
	.global output_string
	.global div_and_mod

endgamep:	.word	endgame
winstrp:	.word	winstr
losestrp:	.word	losestr
instrp:		.word	inputstr
badinp:		.word 	badin
seeddatap:	.word 	seeddata
stringp:	.word 	stringthing

end_game:
	push	{r4-r12, lr}

	.if test_new_int2str=0
	; determine cause of ending the game
	ldr		r4, endgamep
	ldrb	r5, [r4, #0]
	; test loss first
	.if 	debug=1
	mov		r5, #1
	.endif
	; test winning
	.if		debug=2
	mov		r5, #2
	.endif
	cmp		r5, #1			; this means the user lost and ran out of time
	itee	eq
	ldreq	r0, losestrp	; tell the user they lost
	ldrne	r0, winstrp		; tell the user they won
	blne	led_dance
	bl		output_string
	; find out what the user wants to do
	.endif

	.if test_new_int2str=1
	ldr		r0, stringp
	mov		r1, #0x0405
	bl		int2string
	.endif
	

rpoll:
	ldr		r0, instrp
	bl		read_string
	; string should be filled now, validate input
	ldr		r6, [r0, #0]	; check the first character
	cmp		r6, #0x79
	beq		skip
	cmp		r6, #0x6E
	bne		yell


yell:

	ldr		r0, badinp
	bl		output_string	; they didn't say yes or no, yell at them

skip:

	; return from subrouine
	mov		r0, r6			; copy the character the user gave into r0 to return to main
	bl		output_string
	pop		{r0}
	pop		{r4-r12, lr}
	bx		lr				; return


exp:	; exponent
	push	{r4, lr}
	mov		r4, r0		; init r4 to be equal to r0
expl:
	; takes in base in r0, exponent in r1, result in r2
	muls	r4, r0, r4
	sub		r1, r1, #1		; r1 -= 1
	cmp		r1, #0
	bne		expl
	mov		r2, r4		; use r2 as return reg
	pop		{r4, lr}
	bx		lr

int2string:
	; takes string location in r0, and number to convert in r1
	push	{r4-r12}
	
	mov		r10,r0 
	mov		r11, r1	; backup registers
	mov		r9, r10	; copy r10

	; start by diving by 10^8 - support up to 8 digits
	mov		r0, #10
	mov		r1, #8
	mov		r8, r1	; copy into r8
convloop:
	mov		r1, r8
	bl		exp
	; now we have 1^8 in r2
	mov		r1, r2
	mov		r0, r10		; divmod(num, 1^10)
	bl		div_and_mod
	cmp		r0, #0		; to ignore leading zeros, as long as we haven't hit a nonzero number, ignore any zeros we encounter
	; but as soon as we encounter a nonzero number, copy a 
	; one into r12.  this will signify that the zero is not actually leading
	it		ne
	movne	r12, #1

	cmp		r12, #1
	itt		eq ; str address is in r10
	addeq	r0, r0, #0x30	; convert to character
	streq	r0, [r9], #1	; post-index store

	sub		r8, r8, #-1		; subtract 1 from the exponent
	cmp		r8, #0			; see if the exponent is 0 or not.  if it is, we're done
	bne		convloop

	pop		{r4-r12, lr}
	bx		lr


led_dance:
	push	{r0-r12, lr}
	; randomly make leds dance, so get the seed
	ldr		r4, seeddatap
	ldr		r5, [r4, #0]
	.if		debug=2
	mov		r5, #0x59DF
	movt	r7, #0x5F37
	.endif
	mov		r10, #200		; do 200 iterations
	; we have the seed, so extract one byte from it and write to LEDs

ledloop:

	sub		r10, r10, #1
	and		r0, r5, #0xF	; get a byte and store it in r0
	bl		illuminate_LEDs	; light up the LEDs
	; randomize seed
	lsl		r6, r5, #13
	eor		r5, r6, r5
	lsr		r6, r5, #7
	eor		r5, r6, r5
	lsl		r6, r5, #15
	eor		r5, r6, r5
	lsr		r6, r5, #17
	eor		r5, r6, r5

	cmp		r10, #0
	bne		ledloop

	; return
	pop		{r4-r12, lr}
	bx		lr



