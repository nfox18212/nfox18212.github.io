clc .macro
	push	{r0}
	mov		r0, #clear	; form feed
	bl	output_character
	pop		{r0}
	.endm

newl .macro				; print a newline
	push 	{r0}
	mov		r0, #return
	bl		output_character
	mov		r0, #newline
	bl		output_character
	pop		{r0}
	.endm

calculate_offset .macro xpos, ypos, offset
	; leaf macro,  offset = 22*ypos + xpos
	push	{r4,r5}
	mov		r5, #22
	mul		r4, ypos, r5
	add		offset, r4, xpos
	pop		{r4,r5}
	.endm

add3 .macro P1, P2, P3, ADDRP ; debug macro
	ADD ADDRP, P1, P2
	ADD ADDRP, ADDRP, P3
	.endm


	.data

	.global prompt
	.global mydata



board:
	.string " ------------------ ", 0xD, 0xA

scoreStr:
	.string "Score = "	; intentionally not including a null terminator

scoreVal:
	.string "   ", 0x0	; this can fit into a single register and will be where we write the score

teststr:		.cstring "testing testing"

pause: 			.byte 	0x0		; if 1, then game is paused
tick:			.byte 	0x0		; if 1, then a tick has occured
xpos:			.byte 	0x0		; represents the x position on the board
ypos:			.byte	0x0 	; represents the y position on the board
xnew:			.byte	0x0		; represents the x position cursor will move to
ynew:			.byte	0x0		; represents the y position cursor will move to
nextMovement:	.byte	0x0		; character that represents the user input for what direction cursor will move next
score:			.byte 	0x0

seeddata:		.word	0x0		; will be the initial seed we generate from the timer
createSeed:		.byte	0x1 	; this configures wether or not we increment the counter for the seed and have the timer interrupt 1000 times per second
gameTime:		.word	0x0 	; time the game has been going since starting
playerdata:		.half	0x16F	; upper byte will have the color, lower byte contains the cell id of where the player is currently

	.global seeddata
	.global	playerdata

	.text

	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global init
	.global UART0_Handler
	.global Switch_Handler
	;.global GameTimer_Handler			; This is needed for Lab #6
	;.global SeedTimer_Handler
	.global Timer_Handler
	.global simple_read_character
	.global read_character
	.global output_character		; This is from your Lab #4 Library
	.global read_string				; This is from your Lab #4 Library
	.global output_string			; This is from your Lab #4 Library
	.global uart_init				; This is from your Lab #4 Library
	.global lab7
	.global set_color
	.global get_color
	.global get_cell
	.global extract_cid
	.global new_o
	.global crash
	.global	seed

xpos_ptr:			.word xpos
ypos_ptr:			.word ypos
xnew_ptr:			.word xnew
ynew_ptr:			.word ynew
board_ptr:			.word board
move_ptr:			.word nextMovement
tickp:				.word tick
pause_ptr:			.word pause
score_ptr:			.word score
scoreStr_ptr:		.word scoreStr
scoreVal_ptr:		.word scoreVal

seeddatap:			.word seeddata
createSeedp:		.word createSeed
gameTimep:			.word gameTime
playerdatap:		.word playerdata

teststrp:			.word teststr


sw1mask:	.equ	0xEF	; bitmask to mask out for SW1, pin 4
sw1write:	.equ 	0x10	; bitmasks to write a 1 for SW1, pin 4
uartwrite:	.equ	0x20
clear:		.equ	0xC		; form feed, new page
newline:	.equ	0xA
return:		.equ	0xD		; carriage return
star:		.equ	0x2A	; * - the asterisk

lab7:							; This is your main routine which is called from
; your C wrapper.
	push 	{r4-r12,lr}   		; Preserve registers to adhere to the AAPCS
	bl 		init
	clc							; clear screen

poll:							; temporary label
	ldr		r4, createSeedp
	ldrb	r5, [r4, #0]
	cmp		r5, #1				; will be used to indicate to we should create the seed
	beq		poll				; will wait for uart interrupt to happen and resolve
	
	bl		seed
	nop

	pop		{r4-r12,lr}
	mov		pc, lr









detect_collision:

	push	{r4-r12, lr}


	ldr		r5, board_ptr
	ldrb	r4, [r5, r0]	; r2 contains the offset from what we want
	; passed in as an argument

	; look for a *
	cmp		r4, #star
	ite		eq
	moveq	r2, #1			; if there's a * it means there's a collision.  return 1 in r2
	movne	r2, #0			; if there isn't, then no collision has occured.  return 0 in r2

	pop		{r4-r12, lr}
	mov		pc, lr

change_ypos:
	; grabs current y position and adds whatever is in r0 to it.  returns ypos in r1
	push	{r4-r12, lr}

	ldr		r4, ypos_ptr
	ldrb	r1, [r4, #0]	; grab current y position
	add		r1, r1, r0		; the modifier is passed in r0, so add it
	strb	r1, [r4, #0]	; store it again

	pop		{r4-r12, lr}
	mov		pc, lr

change_xpos:
	; grabs current y position and adds whatever is in r0 to it. returns xpos in r0
	push	{r4-r12, lr}

	ldr		r4, xpos_ptr	; literally just look at the change_ypos subroutine
	ldrb	r1, [r4, #0]
	add		r1, r1, r0
	mov		r1, r0

	pop		{r4-r12, lr}
	mov		pc, lr

UART0_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	push	{r4-r11,lr}

	; before interrupts are re-enabled, if this is the first interrupt, change timer using createSeedp
	ldr		r1, createSeedp
	ldrb	r0, [r1, #0]
	cmp		r0, #1
	it		eq
	bleq	change_timer

	; handle all the other stuff

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

	;		if its not wasd then exit handler
	b		exit_uart_handler

cont_uart:

	; now we store r0 into nextMovement
	ldr		r4, move_ptr
	strb	r0, [r4, #0]

	; we're done so exit

exit_uart_handler:
	pop		{r4-r11,lr}
	bx		lr       				; Return


Switch_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	push	{r4-r11,lr}

	; re-enable interrupts
	mov		r4, #0xE000
	movt	r4, #0xE000
	ldr		r5, [r4, #0x100]		; store 1 at E000E100
	mov		r6, #0x0				; this is to set pin 30 to 1 to enable port F to interrupt
	movt	r6, #0x4000
	orr		r5, r5, r6				; set to 1
	str		r5, [r4, #0x100]

	; if we hit sw1, pause the game
	ldr		r4, pause_ptr
	ldrb	r5, [r4, #0]			; check pause bit
	eor		r5, r5, #1				; flip bit - if its a 1, game is paused if its a 0, game is unpaused
	; two option - blocking loop w/ pause screen in handler or blocking loop after handler.  we do blocking loop out of handler first
	strb	r5, [r4, #0]			; store the bit

	pop		{r4-r11,lr}
	bx		lr       	; Return


; GameTimer_Handler:
Timer_Handler:

	; this timer is the game timer, and will tick two times per second after the game starts.  this handler will be used to control movement, ending the game, and time passed

	push	{r4-r11, lr}

	ldr		r5, gameTimep
	ldr		r6, [r5, #0]
	add		r6, r6, #1
	str 	r6, [r5, #0]

	ldr		r7, tickp
	ldrb	r8, [r7, #0]
	add		r8, r8, #1		; make the timer tick
	strb	r8, [r7, #0]

	; depending on settings inputted on main menu, if the timer passed a certain value, end the game.  will implement later

	; re-enable interrupt
	mov		r4, #0x0000
	movt	r4, #0x4003
	ldr		r5, [r4, #0x18]
	orr		r5, r5, #0x1
	str		r5, [r4, #0x18]

	pop		{r4-r11, lr}
	bx  	lr     ; Return

change_timer:
	push	{r4-r11, lr}

	; This subroutine should be called once per execution.  This will disable the seed timer, and stop it from interrupting.
	sub		r0, r0, #1
	strb	r0, [r1, #0]

	mov		r4, #0x1000
	movt	r4, #0x4003
	ldr		r5, [r4, #0xC]
	mov		r6, #0xFFFE
	movt	r6, #0xFFFF
	and		r5, r6, r5 ; mask out the very last bit
	str		r5, [r4, #0xC]


	pop		{r4-r11, lr}
	mov		pc, lr


SeedTimer_Handler:
	push	{r4-r11, lr}

	; increment seed value
	ldr		r6, seeddatap
	ldr		r7, [r6, #0]
	add		r7, r7, #1
	str		r7, [r6, #0]

	; re-enable timer 1
	mov		r4, #0x1000
	movt	r4, #0x4003
	ldr		r5, [r4, #0]
	orr		r5, r5, #0x1
	str		r5, [r4, #0]

	pop		{r4-r11,lr}
	bx		lr



exit:
	push	{r4-r11, lr}



	pop		{r4-r11, lr}
	mov		pc, lr


	.end

