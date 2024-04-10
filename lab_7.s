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
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string "|                  |", 0xD, 0xA
	.string " ------------------ ", 0xD, 0xA

scoreStr:
	.string "Score = "	; intentionally not including a null terminator

scoreVal:
	.string "   ", 0x0	; this can fit into a single register and will be where we write the score

pause: 			.byte 	0x0		; if 1, then game is paused
tick:			.byte 	0x0		; if 1, then a tick has occured
xpos:			.byte 	0x0		; represents the x position on the board
ypos:			.byte	0x0 	; represents the y position on the board
xnew:			.byte	0x0		; represents the x position cursor will move to
ynew:			.byte	0x0		; represents the y position cursor will move to
nextMovement:	.byte	0x0		; character that represents the user input for what direction cursor will move next
score:			.byte 	0x0

prompt:			.cstring	"prompt"
mydata:			.byte		0x20	; This is where you can store data.
									; The .byte assembler directive stores a byte
									; (initialized to 0x20) at the label mydata.
									; Halfwords & Words can be stored using the
									; directives .half & .word

	.text

	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler			; This is needed for Lab #6
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

ptr_to_prompt:		.word prompt
ptr_to_mydata:		.word mydata
xpos_ptr:			.word xpos
ypos_ptr:			.word ypos
xnew_ptr:			.word xnew
ynew_ptr:			.word ynew
board_ptr:			.word board
move_ptr:			.word nextMovement
tick_ptr:			.word tick
pause_ptr:			.word pause
score_ptr:			.word score
scoreStr_ptr:		.word scoreStr
scoreVal_ptr:		.word scoreVal




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
	; test get_cell
	mov		r0, #312			
	mov		r1, #2				; specify color two and 
	bl		get_cell			; should set color and return the new cell in r0
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


Timer_Handler:

	; Your code for your Timer handler goes here.  It is not needed for
	; Lab #5, but will be used in Lab #6.  It is referenced here because
	; the interrupt enabled startup code has declared Timer_Handler.
	; This will allow you to not have to redownload startup code for
	; Lab #6.  Instead, you can use the same startup code as for Lab #5.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler.
	ldr		r0, tick_ptr
	ldrb	r1, [r0, #0]
	orr		r1, r1, #1			; this signifies that a tick has occured
	strb	r1, [r0, #0]
	bx  	lr     ; Return






exit:
	push	{r4-r11, lr}



	pop		{r4-r11, lr}
	mov		pc, lr


	.end

