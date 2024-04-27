	.cdecls C,NOLIST,"debug.h"

clc .macro
	push	{r0}
	mov		r0, #clear	; form feed
	bl	output_character
	pop		{r0}
	.endm

newl .macro				; print a newline
	push 	{r0}
	mov		r0, #carreturn
	bl		output_character
	mov		r0, #newline
	bl		output_character
	pop		{r0}
	.endm

	.data

dopause: 		.byte 	0x0		; if 1, then game is paused
tick:			.byte 	0x0		; if 1, then a tick has occured
nextMovement:	.byte	0x0		; character that represents the user input for what direction cursor will move next

	.global dopause
	.global tick
	.global nextMovement
	.global	playerdata
	.global seeddata
	.global gameTime
	.global timeset
	.global createSeed
	.global playerdata
	.global endgame

	.text
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler
	.global read_character
	.global output_character		; This is from your Lab #4 Library
	.global read_string				; This is from your Lab #4 Library
	.global output_string			; This is from your Lab #4 Library
	.global	move
	.global swap
	.global rcd


tickp:			.word 	tick
movp:			.word	nextMovement
pause_ptr:		.word	dopause
seeddatap:		.word	seeddata
gametimep:		.word 	gameTime
createSeedp:	.word 	createSeed
timesetp:		.word	timeset
playerdatap:	.word 	playerdata
endgamep:		.word 	endgame

UART0_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	push	{r4-r11,lr}

	; re-enable interrupt
	mov 	r1, #0xE000
	movt 	r1, #0xE000
	ldr 	r0, [r1, #0x100]
	orr 	r0, r0, #uartwrite
	str		r0, [r1, #0x100]

	bl		read_character			; grab current character and store it in r0
	; validate r0, make sure its w, a, s or d
	; if its not, just exit handler

	; w == 0x77
	cmp		r0, #0x77
	beq		cont_uart

	; a == 0x61
	cmp		r0, #0x61
	beq		cont_uart

	; s == 0x73
	cmp		r0, #0x73
	beq		cont_uart

	; d == 0x64
	cmp		r0, #0x64
	beq		cont_uart

	; if a space was inputted
	cmp		r0, #0x20
	it		eq
	bleq	swap
	beq		exit_uart_handler

	;		if its not wasd then exit handler
	b		exit_uart_handler

cont_uart:
	.if debug=1
	; print it - will remove in final game
	bl		output_character
	newl
	.endif
	; change the relative direction dir to absolute - we need orientation form playerdata
	ldr		r6, playerdatap
	ldr		r7, [r6, #0]
	mov		r10, #0
	movt	r10, #0xFF00	; filter for orientation
	and		r1, r7, r10		; r1 contains the orientation
	lsr		r1, r1, #24		; shove it back so its the smallest two bytes
	; need to swap r0 and r1
	mov		r12, r1			; DANCE!
	mov		r1, r0
	mov		r0, r12
	bl		rcd				; convert the relative wasd to NSEW
	; now we store r0 into nextMovement
	ldr		r4, movp

	strb	r0, [r4, #0]

	; set the seed
	ldr		r1, createSeedp
	ldrb	r0, [r1, #0]
	cmp		r0, #1
	it		eq
	bleq	change_timer


	; we're done so exit

exit_uart_handler:
	pop		{r4-r11,lr}
	bx		lr       				; Return


Switch_Handler:
	push	{r4-r11,lr}

	; re-enable interrupts
	mov		r4, #0xE000E000
	ldr		r5, [r4, #0x100]		; store 1 at E000E100
	mov		r6, #0x0000				; this is to set pin 30 to 1 to enable port F to interrupt
	movt	r6, #0x4000
	orr		r5, r5, r6				; set to 1
	str		r5, [r4, #0x100]

	; handle pausing
	; if we haven't initialized how long to play for (meaning we're in game), the program will exit

	; check to see if sw1 has been pushed
	mov		r9, #0x5000
	movt	r9, #0x4002
	ldr		r10, [r9, #0x3FC]
	and		r10, #16
	beq		pause

	; otherwise, exit
	b		exit_gpio

pause:
	; if we hit sw1, pause the game

	ldr		r4, pause_ptr
	ldrb	r5, [r4, #0]			; check pause bit
	eor		r5, r5, #1				; flip bit - if its a 1, game is paused if its a 0, game is unpaused
	; two option - blocking loop w/ pause screen in handler or blocking loop after handler.  we do blocking loop out of handler first
	strb	r5, [r4, #0]			; store the bit
	b		exit_gpio

exit_gpio:

	pop		{r4-r11,lr}
	bx		lr       	; Return


; GameTimer_Handler:
Timer_Handler:

	; this timer is the game timer, and will tick two times per second after the game starts.  this handler will be used to control movement, ending the game, and time passed

	push	{r4-r11, lr}

	; re-enable interrupt
	mov		r4, #0x0000
	movt	r4, #0x4003
	ldr		r5, [r4, #0x24]
	orr		r5, r5, #0x1
	str		r5, [r4, #0x24]

	; increase game time
	ldr		r5, gametimep
	ldr		r6, [r5, #0]
	add		r6, r6, #1
	str 	r6, [r5, #0]

	ldr		r7, tickp
	ldrb	r8, [r7, #0]
	mov		r8, #1		; make the timer tick
	strb	r8, [r7, #0]

	; depending on settings inputted on main menu, if the timer passed a certain value, end the game.
	ldr		r7, timesetp
	ldr		r8, [r7, #0]	; the amount of time to run the game for
	cmp		r6, r8			; check to see if they're equal.  if they are, end the game.
	it		eq
	bleq	set_end

	; commit the movement
	bl		move

	; check if paused
halt:
	ldr		r4, pause_ptr
	ldr		r5, [r4, #0]
	cmp		r5, #1
	beq		halt		; stop execution if paused - don't do anything and just poll

	pop		{r4-r11, lr}
	bx  	lr     ; Return

set_end:
	push 	{r4-r5}
	ldr		r4, endgamep
	mov		r5, #1			; endgame being 1 means the user ran out of time
	strb	r5, [r4, #0]
	pop		{r4-r5}
	bx		lr

change_timer:
	push	{r4-r11, lr}

	; This subroutine should be called once per execution.  This will disable the seed timer, and stop it from interrupting.
	sub		r0, r0, #1
	strb	r0, [r1, #0]

	; disable timer 1
	mov		r4, #0x1000
	movt	r4, #0x4003
	ldr		r5, [r4, #0xC]
	mov		r6, #0xFFFE
	movt	r6, #0xFFFF
	and		r5, r6, r5 ; mask out the very last bit
	str		r5, [r4, #0xC]

	; nab the timer value of TAV - offset #0x50
	ldr		r5, [r4, #0x50]
	; nab the seeddata pointer
	ldr		r6, seeddatap
	str		r5, [r6, #0]	; store the timer value in the seeddata

	pop		{r4-r11, lr}
	mov		pc, lr



