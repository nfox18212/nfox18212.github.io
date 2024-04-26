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


score:			.byte 	0x0

; menu information
menustr:		.string "Welcome to NaFoxari Video Cube!  To start, choose a length of time to play for and push w, a, s, or d.", 0xD, 0xA,  "Then you can start playing!  WASD to move, Space to swap, SW1 to pause.", 0xD, 0xA, 0x0
lengthstr:		.string "How long would you like to play the game?", 0xD, 0xA, "Push SW5 for a 100 second game, SW4 for 200 seconds, SW3 for 300 seconds and SW2 for no time limit.", 0xD, 0xA, 0x0
timeset:		.word 	0x0			; time the game will go on for

seeddata:		.word	0x0		    ; will be the initial seed we generate from the timer
createSeed:		.byte	0x1 	    ; this configures wether or not we increment the counter for the seed and have the timer interrupt 1000 times per second
gameTime:		.word	0x0 	    ; time the game has been going since starting
playerdata:		.word	0x0006006F	; from largest byte to smallest: byte 0: orientation, byte 1: player color, byte 2 and byte 3: current cell.  starting cell is 111 and color is blue
endgame:		.byte 	0x0			; describes if/how we should end the game
atype:      	.byte   0x0         ; describes the last type of action.  1 for movement in-face, 2 for movement onto a new face, 3 for a color swap

	.global atype
  	.global seeddata
	.global	playerdata
	.global endgame
	.global dopause
	.global tick
	.global nextMovement
	.global	gameTime
	.global createSeed
	.global timeset

	.text



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
	.global check_board_state
	.if include_debug=1
	.global crash
	.endif
	.global	seed
	.global swap

	.global update
	.global end_game
	.global	move


movp: 			.word nextMovement
movesp:			.word moves
movestrp:		.word moveStr
movevalp:		.word moveVal
timestrp:		.word timeStr
timevalp:	  	.word timeVal
timesetp:		.word timeset
tickp:			.word tick
pause_ptr:		.word dopause
score_ptr:		.word score
scoreStr_ptr:	.word scoreStr
scoreVal_ptr:	.word scoreVal
endgamep:		.word endgame
lstrp:			.word lengthstr
menup:			.word menustr
atypep:		    .word atype

seeddatap:		.word seeddata
createSeedp:	.word createSeed
gametimep:		.word gameTime
playerdatap:	.word playerdata

teststrp:		.word teststr

lab7:							; This is your main routine which is called from your C wrapper.
	push 	{r4-r12,lr}   		; Preserve registers to adhere to the AAPCS
	bl 		init

resetgame:
	clc							; clear screen

	; print menu information
	ldr		r0, menup
	bl		output_string
	ldr		r0, lstrp
	bl		output_string



poll1:
	; grab port d information
	mov		r4, #0x7000
	movt	r4, #0x4000
	ldr		r5, [r4, #0x3FC] ; grab GPIOD_DATA

	.if debug!=0
	mov		r5, #8
	.endif

	; look for how long to play the game for
	and		r8, r5, #8		; SW2
	cmp		r8, #8
	beq		unlimited

	and		r8, r5, #4 		; SW3
	cmp		r8, #4
	beq		threehundred

	and		r8, r5, #2 		; SW4
	cmp		r8, #2
	beq		twohundred

	and		r8, r5, #1		; SW5
	cmp		r8, #1
	beq		onehundred

	; if it wasn't any of the above, poll
	b		poll1

onehundred:

	mov		r12, #100		; we hit switch 1 so store 100
	str		r12, [r4, #0]
  	b	    poll2

twohundred:

	mov		r12, #200		; we hit switch 2 so store 200
	str		r12, [r4, #0]
  	b	    poll2

threehundred:

	mov		r12, #300		; we hit switch 3 so store 300
	str		r12, [r4, #0]
 	b     	poll2

unlimited:

	; no time limit, store stupid big number (2,147,483,647 ticks which is ~34 years )
	mov		r12, #0xFFFF
	movt	r12, #0x7FFF
	str		r12, [r4, #0]
  	b    	poll2

poll2:							; temporary label
	ldr		r4, createSeedp
	ldrb	r5, [r4, #0]
	.if		debug=1
	mov		r5, #0
	.endif
	cmp		r5, #1				; will be used to indicate to we should create the seed
	beq		poll2				; will wait for uart interrupt to happen and resolve
	bl		seed
	; set up addresses that will be used
	ldr		r4, tickp
	ldr		r8, endgamep

mainloop:
  	; figure out the main routine here

	ldrb	r5, [r4, #0]		; check to see if a tick has occured
	cmp		r5, #0
	beq		mainloop
	mov		r5, #0				; reset tick
	strb	r5, [r4, #0]
	bl		update				; render the board and any changes
	bl		check_board_state	; check the board state to see if any/how many faces are completed, and if we should end the game
	; check to see if we should end the game
	ldrb	r9, [r8, #0]
	.if 	debug=1
	mov		r9, #1
	.endif
	cmp		r9, #0				; if its 0 we continue the game
	ite		eq
	beq		mainloop
	blne	end_game

	cmp		r0, #0x79			; end_game will return y if the user wants to reset
	; reached if user wants to return
	beq		resetgame

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

	cmp		r0, #0			; make sure there next is a next movement
	it		ne
	; movement is stored as a character, convert to number
	blne	dirindex
	beq		move_exit		; if there's no movement, skip to end
	; now the movement is 0,1,2,3
	mov		r1, r0			; move direction to r1
	mov		r0, r6			; put old cell into r0 for get_cell subroutine
	mov   	r12, r1    		; backup r1

  	push  	{r0-r2}     		; backup so we can extract cid
  	bl    	extract_cid
  	mov   	r11, r0   	  	; put face into r11
  	pop   	{r0-r2}    		; restore

  	push  {r8-r9}
  	; now we have the two face ids, old in r10 and new in r11
  	ldr   	r8, atypep
  	cmp   	r10, r11
  	ite   	eq
  	moveq 	r9, #1  ; if faces are equal we haven't changed faces, so just put 1 in action type
	movne 	r9, #2  ; if faces are inequal we have changed faces, so put 2 in atype
  	ldrb  	r9, [r8, #0]
  	pop   	{r8-r9}

	bl		get_cell
	mov		r1, r12			; restore r1 being direction
	; r0 has the new cell and r1 is direction
	push  	{r0-r2}     ; backup new cell and direction and orientation
 	; while r0 is the newcell, extract the cid
  	bl    	extract_cid
  	mov	   	r10, r0     ; backup new cell's face
  	pop 	{r0-r2}

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
	; clean up
	ldr		r12, movp		; set no next movement so if the user doesn't input anything, there's no movement of the character
	mov		r11, #0
	strb	r11, [r12, #0]
	; return
	pop		{r4-r12, lr}
	mov		pc, lr


swap:	; routine to swap player's color with current cell's color
	push	{r4-r11, lr}

	; set last action type to be a swap
	ldr		r4, atypep
	mov		r5, #3
	strb	r5, [r4, #0]

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


	.end

