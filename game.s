	.cdecls C,NOLIST,"debug.h"


	.data

winstr:		.string 	"Congratulations!  You have filled all six sides of the cube and have won!  Would you like to play again? [Y/n]", 0xD, 0xA, 0x0
losestr:	.string 	"Unfortunate!  You ran out of time before you filled all six sides of the cube.  Would you like to play again? [Y/n]", 0xD, 0xA, 0x0
inputstr:	.cstring	"        "
badin:		.string		"That is not a [y]es or a [n]o.  Please input y or n and enter.", 0xD, 0xA, 0x0

	.global endgame
	.global	seeddata

	.text
	.global end_game
	.global read_string
	.global illuminate_LEDs
	.global output_string

endgamep:	.word	endgame
winstrp:	.word	winstr
losestrp:	.word	losestr
instrp:		.word	inputstr
badinp:		.word 	badin
seeddatap:	.word 	seeddata

end_game:
	push	{r4-r12, lr}
	; determine cause of ending the game
	ldr		r4, endgamep
	ldr		r5, [r5, #0]
	cmp		r5, #1			; this means the user lost and ran out of time
	itee	eq
	ldreq	r4, losestrp	; tell the user they lost
	ldrne	r4, winstrp		; tell the user they won
	blne	led_dance
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
	pop		{r4-r12, lr}
	bx		lr				; return


led_dance:
	push	{r0-r12, lr}
	; randomly make leds dance, so get the seed
	ldr		r4, seeddatap
	ldr		r5, [r4, #0]
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



