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
	it		eq
	ldreq	r0, losestrp	; tell the user they lost
	cmp		r5, #2			; this means they won
	itt		eq
	ldreq	r0, winstrp		; tell the user they won
	blneq	led_dance
	bl		output_string
	; find out what the user wants to do

	

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



