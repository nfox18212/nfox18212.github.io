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

peightyspaces .macro
	push	{r0}
	ldr		r0, ptr_to_eightyspaces
	bl		output_string
	pop		{r0}
	.endm

psixtyspaces .macro
	push	{r0}
	ldr		r0, ptr_to_sixtyspaces
	bl		output_string
	pop		{r0}
	.endm
; these macros exist to print whitespace out.  Exactly 60 and 80 spaces, and they both preserve r0
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

moves:			.word	0x0
moveStr:		.string "Moves: " ; no null terminator
moveVal:		.string "       ", 0xD, 0xA, 0x0
timeStr:		.string "Time: "
timeVal:		.string "       ", 0xD, 0xA, 0x0
scoreStr:		.string "Score = "	; intentionally not including a null terminator
scoreVal: 		.string "   ", 0x0	

teststr:		.string "testing testing", 0xA, 0xD, 0x0

dopause: 		.byte 	0x0		; if 1, then game is paused
tick:			.byte 	0x0		; if 1, then a tick has occured
nextMovement:	.byte	0x0		; character that represents the user input for what direction cursor will move next
score:			.byte 	0x0

; menu information
menustr:		.string "Welcome to NaFoxari Video Cube!  To start, choose a length of time to play for and push w, a, s, or d.  Then you can start playing!  WASD to move, Space to swap, SW1 to pause.", 0xD, 0xA, 0x0
lengthstr:		.string "How long would you like to play the game?  Push SW5 for a 100 second game, SW4 for 200 seconds, SW3 for 300 seconds and SW2 for no time limit.", 0xD, 0xA, 0x0
timeset:		.byte 	0x0		; time the game will go on for

seeddata:		.word	  0x0		      ; will be the initial seed we generate from the timer
createSeed:	.byte	  0x1 	      ; this configures wether or not we increment the counter for the seed and have the timer interrupt 1000 times per second
gameTime:		.word	  0x0 	      ; time the game has been going since starting
playerdata:	.word	  0x0006006F	; from largest byte to smallest: byte 0: orientation, byte 1: player color, byte 2 and byte 3: current cell.  starting cell is 111 and color is blue
endgame:		.byte 	0x0
atype:      .byte   0x0         ; describes the last type of action.  1 for movement in-face, 2 for movement onto a new face, 3 for a color swap

  .global atype
  .global seeddata
	.global	playerdata

	.text

include_debug:		.set 1

	.global init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler
	.global read_character
	.global output_character		; This is from your Lab #4 Library
	.global read_string				; This is from your Lab #4 Library
	.global output_string			; This is from your Lab #4 Library
	.global lab7
	.global set_color
	.global get_color
	.global get_cell
	.global dirindex
	.global rcd
	.global extract_cid
	.global new_o
	.if include_debug=1
	.global crash
	.endif
	.global	seed


movp: 				  .word nextMovement
movesp:				  .word moves
movestrp:			  .word moveStr
movevalp:			  .word moveVal
timestrp:			  .word timeStr
timevalp:			  .word timeVal
timesetp:			  .word timeset
tickp:	  	  		.word tick
pause_ptr:			.word dopause
score_ptr:			.word score
scoreStr_ptr:		.word scoreStr
scoreVal_ptr:		.word scoreVal
endgamep:			  .word endgame
lstrp:				  .word lengthstr
menup:				  .word menustr
atypep:         .word atype

seeddatap:			.word seeddata
createSeedp:		.word createSeed
gametimep:			.word gameTime
playerdatap:		.word playerdata

teststrp:			  .word teststr


sw1mask:	.equ	0xEF	; bitmask to mask out for SW1, pin 4
sw1write:	.equ 	0x10	; bitmasks to write a 1 for SW1, pin 4
uartwrite:	.equ	0x20
star:		.equ	0x2A	; asterisk - *

lab7:							; This is your main routine which is called from your C wrapper.
	push 	{r4-r12,lr}   		; Preserve registers to adhere to the AAPCS
	bl 		init
	clc							; clear screen

	; print menu information
	ldr		r0, menup
	bl		output_string
	ldr		r0, lstrp
	bl		output_string

	.if portdpoll=1
poll1:
	; grab port d information
	mov		r4, #0x7000
	movt	r4, #0x4000
	ldr		r5, [r4, #0x3FC] ; grab GPIOD_DATA

	; look for how long to play the game for
	and		r8, r5, #1		; SW2
	cmp		r8, #1
	beq		unlimited

	and		r8, r5, #2 	; SW3
	cmp		r8, #2
	beq		threehundred

	and		r8, r5, #4 	; SW4
	cmp		r8, #4
	beq		twohundred

	and		r8, r5, #8		; SW5
	cmp		r8, #8
	beq		onehundred

onehundred:

	mov		r12, #100		; we hit switch 1 so store 100
	str		r12, [r4, #0]
  b     poll2

twohundred:

	mov		r12, #100		; we hit switch 2 so store 200
	str		r12, [r4, #0]
  b     poll2

threehundred:

	mov		r12, #300		; we hit switch 3 so store 300
	str		r12, [r4, #0]
  b     poll2

unlimited:

	; no time limit, store stupid big number (2,147,483,647 ticks)
	mov		r12, #0xFFFF
	movt	r12, #0x7FFF
  	b     poll2





poll2:							; temporary label
	ldr		r4, createSeedp
	ldrb	r5, [r4, #0]
	cmp		r5, #1				; will be used to indicate to we should create the seed
	beq		poll2				; will wait for uart interrupt to happen and resolve
	bl		seed

  ; figre out the main routine here



	pop		{r4-r12,lr}
	mov		pc, lr


detect_collision:

	push	{r4-r12, lr}
	; r0 - new cell
	; r1 - player's color
	; r2 - returns 1 or 0 
	; need to make new collision detection routine

	mov		r5, r1		; copy r1 to back it up

	bl		get_color

	cmp		r0, r5		; check to see if the colors are the same
	ite		eq
	moveq	r2, #1 		; if they are return 1, collision detected
	movne	r2, #0		; if not, return 0 - no collision

	pop		{r4-r12, lr}
	mov		pc, lr



move:
	; does not take input, does not need it
	push	{r4-r12, lr}

	ldr		r4, playerdatap
	ldr		r5, [r4, #0] 	; get playerdata

	mov		r7, #0x0FFF		; the bit filter for grabbing position
	and		r6, r5, r7		; get just position

	
	mov		r7, #0xFF000000		; bit filer for orientation
	and		r7, r7, r5		; get the current orientation

	ldr		r12, movp
	ldrb	r0, [r12, #0]	; get the next movement - it is absolute since next_movement only stores absolute movement

	; movement is stored as a character, convert to number
	bl		dirindex
	; now the movement is 0,1,2,3
	mov		r1, r0			; move direction to r1
	mov		r0, r6			; put old cell into r0 for get_cell subroutine
	mov   r12, r1     ; backup r1

  push  {r0-r2}     ; backup so we can extract cid
  bl    extract_cid
  mov   r11, r0     ; put face into r11
  pop   {r0-r2}     ; restore

  push  {r8-r9}
  ; now we have the two face ids, old in r10 and new in r11
  ldr   r8, atypep
  cmp   r10, r11
  ite   eq
  moveq r9, #1  ; if faces are equal we haven't changed faces, so just put 1 in action type
  movne r9, #2  ; if faces are inequal we have changed faces, so put 2 in atype
  ldrb  r9, [r8, #0]
  pop   {r8-r9}

	bl		get_cell
	mov		r1, r12			; restore r1 being direction
	; r0 has the new cell and r1 is direction
  push  {r0-r2}     ; backup new cell and direction and orientation 
  ; while r0 is the newcell, extract the cid
  bl    extract_cid
  mov   r10, r0     ; backup new cell's face
  pop   {r0-r2}

	; now we need to determine the new orientation
	bl		new_o
	; now r2 contains the new orientation

	push	{r0-r2}			; preserve new cell, direction, and orientation in that order
	mov		r1, r0			; put new cell into r1
	mov		r0, r6			; put old cell into r0
	; detect for collision
	; detect_collision will return 0 or 1 in r2.  if 1, there's a collision so reject movement
	bl		detect_collision

	; see if there's a collision
	cmp		r2, #1
	; balance the stack
	pop		{r0-r2}
	beq		move_exit ; if there is, exit - don't allow the move

	; if we are here, the movement is valid
	; since the movement is valid, store it in playerdata

	; r0 has new cell, r1 has direction of movement, r2 has orientation, r5 has playerdata

	; clear out old cell id
	lsr		r5, #12
	lsl		r5, #12

	orr		r5, r5, r0		; set the new cell id

	; get rid of old orientation
	mov		r3, #0xFFFF
	movt	r3, #0x00FF
	and		r5, r3, r5	

	lsl		r2, r2, #24		; shift to easily be able to set new orientation
	orr		r5, r2, r5		; set the bits to write playerdata
	
	str		r5, [r4, #0] 	; store the new playerdata

move_exit:
	; return from move subroutine
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

	; if a space was inputted
	cmp		r0, #0x20
	it		eq
	bleq	swap
	beq		exit_uart_handler

	;		if its not wasd then exit handler
	b		exit_uart_handler

cont_uart:
	; print it - will remove in final game
	bl		output_character
	newl
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

	.if portdpoll=0
	mov		r9, #0x7000		; gpio port D
	movt	r9, #0x4000
	ldrb	r10, [r9, #0x3FC]
	; check conditions
	ldr		r4, timesetp
	ldr		r12, [r4, #0]
	; if its 0, we haven't set it.  otherwise, the switch that was pressed's number will be stored
	cmp		r0, #0
	it		eq
	bleq	init_gameduration
	beq		exit_gpio	; this is an initial setup thing, so exit gpio
	.endif


	; handle pausing
	; if we haven't initialized how long to play for (meaning we're in game), the program will exit

	; check to see if sw1 has been pushed
	mov		r9, #0x5000
	movt	r9, #0x4002
	ldr		r10, [r9, #0x3FC]
	and		r10, #16
	beq		pause

	; if neither case is true, exit
	b		exit_gpio

init_gameduration:

	push	{r4-r12, lr}

	.if portdpoll=0
	; we're going to abuse the fact that we know the contents of r4-r12.  so we can't touch r4 or preserve it if we do.
	; look for how long to play the game for
	and		r8, r10, #1		; SW2
	cmp		r8, #1
	beq		unlimited

	and		r8, r10, #2 	; SW3
	cmp		r8, #2
	beq		threehundred

	and		r8, r10, #4 	; SW4
	cmp		r8, #4
	beq		twohundred

	and		r8, r10, #8		; SW5
	cmp		r8, #8
	beq		onehundred
	; should probably crash here or something but i'm lazy

  
onehundred:

	mov		r12, #100		; we hit switch 1 so store 100
	str		r12, [r4, #0]
	pop		{r4-r12, lr}
	bx		lr



twohundred:

	mov		r12, #100		; we hit switch 2 so store 200
	str		r12, [r4, #0]
	pop		{r4-r12, lr}
	bx		lr


threehundred:

	mov		r12, #300		; we hit switch 3 so store 300
	str		r12, [r4, #0]
	pop		{r4-r12, lr}
	bx		lr

unlimited:

	; no time limit, store stupid big number (2,147,483,647 ticks)
	mov		r12, #0xFFFF
	movt	r12, #0x7FFF
	pop		{r4-r12, lr}
	bx		lr

	.endif

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

	ldr		r5, gametimep
	ldr		r6, [r5, #0]
	add		r6, r6, #1
	str 	r6, [r5, #0]



	ldr		r7, tickp
	ldrb	r8, [r7, #0]
	add		r8, r8, #1		; make the timer tick
	strb	r8, [r7, #0]



	; depending on settings inputted on main menu, if the timer passed a certain value, end the game.



	pop		{r4-r11, lr}
	bx  	lr     ; Return

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

swap:	; routine to swap player's color with current cell's color
	push	{r4-r11, lr}

	ldr		r4, playerdatap
	ldr		r5, [r4, #0]	; get the player data
	mov		r6, #0xFF0000	; filter for color data
	and		r7, r6, r5		; player color is now in r7
	sub		r5, r5, r7 		; remove color from playerdata
	lsr		r7, r7, #16		; shift color to be one byte
	
	mov		r6, #0xFFFF		; filter for cell id
	push	{r0}			; preserve r0 just in case
	and		r0, r6, r5		; store cid in r0
	bl		get_color		; get the color

	; swap player color and cell color
	; put new color into player data
	add		r5, r5, r0, lsl #16
	str		r5, [r4, #0]	; store it

	pop		{r0}			; get cid back
	mov		r1, r7			; store color in r1
	bl		set_color


	pop		{r4-r11, lr}
	bx		lr



exit:
	push	{r4-r11, lr}



	pop		{r4-r11, lr}
	mov		pc, lr


	.end

