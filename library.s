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

	.global numPrompt
	.global demPrompt
	.global dividend
	.global divisor
	.global quotient
	.global remainder

numPrompt:		.cstring "Give me a divisor:  "
demPrompt:		.cstring "Give me a dividend: "
dividend:		.cstring "        " ; also numerator
divisor:		.cstring "        " ; also denominator
quotient:		.cstring "        "
remainder:		.cstring "        "
quoreturn:		.cstring "Quotient =  "
sixtyspaces:	.cstring "                                                            "
remreturn:		.cstring "Remainder =  "
eightyspaces:	.cstring "                                                                                "
space1:			.space 8
space2:			.space 8

yellatuser:		.cstring "The color 0b110x is invalid, pick a different one dummy."
lab4prompt		.cstring "Enter a number 1-4: "
introdummy		.cstring "I said 1-4, dummy. Press enter and try again. "
restartprompt	.cstring "Would you like to restart? y or n: "


; okay so these space labels are admittedly REALLY hacky.  This is just so that it'll allow me to store string length metadata because
; i don't feel like rewriting the entire algorithm of string2int to not need to use string length
; good practice? nope, but good practice can suck my balls i need this lab done

negFlag:  .byte 0

ptr_to_nprompt:			.word numPrompt
ptr_to_dprompt:			.word demPrompt
ptr_to_numerator:		.word dividend
ptr_to_denominator:		.word divisor
ptr_to_quotient:		.word quotient
ptr_to_remainder:		.word remainder
ptr_to_remreturn:		.word remreturn
ptr_to_quoreturn:		.word quoreturn
ptr_to_negFlag:			.word negFlag
ptr_to_space1:			.word space1
ptr_to_space2:			.word space2
ptr_to_eightyspaces:	.word eightyspaces
ptr_to_sixtyspaces:		.word sixtyspaces ; for use with a 80 character wide terminal
ptr_to_yellatuser:		.word yellatuser
ptr_to_lab4prompt:		.word lab4prompt
ptr_to_introdummy:		.word introdummy
ptr_to_restart:			.word restartprompt

globals:	.word 0x0

	.text
	
	.global uart_init
	.global init
	.global output_character
	.global read_character
	.global read_string
	.global output_string
	.global read_from_push_btns
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global read_tiva_push_button
	.global div_and_mod
	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global goback
	.global crash

sw1mask:	.equ	0xEF	; bitmask to mask out for SW1, pin 4
sw1write:	.equ 	0x10	; bitmasks to write a 1 for SW1, pin 4
uartwrite:	.equ	0x20
clear:		.equ	0xC		; form feed, new page
newline:	.equ	0xA
return:		.equ	0xD		; carriage return
star:		.equ	0x2A	; * - the asterisk

init:
	push	{r4-r12,lr}
	bl		uart_init			; initalize uart
	bl		gpio_init			; init gpio
	bl		uart_interrupt_init ; init interrupts for uart
	bl		gpio_interrupt_init
	bl		timer_init
	pop		{r4-r12,lr}
	mov		pc, lr				; return


uart_init:
	PUSH {r4-r12,lr}	; Spill registers to stack

	;(*((volatile uint32_t *)(0x400FE618))) = 1;
	;Provide clock to UART0
	mov r0, #0xE618
	movt r0, #0x400F
	mov r1, #1
	str r1, [r0]

	;Enable clock to PortA
    ;(*((volatile uint32_t *)(0x400FE608))) = 1;
	mov r0, #0xE608
	movt r0, #0x400F
	str r1, [r0]

	;Disable UART0 Control
    ;(*((volatile uint32_t *)(0x4000C030))) = 0;
	mov r0, #0xC030
	movt r0, #0x4000
	mov r1, #0
	str r1, [r0]

	;Set UART0_IBRD_R for 115,200 baud
    ;(*((volatile uint32_t *)(0x4000C024))) = 8;
	mov r0, #0xC024
	movt r0, #0x4000
	mov r1, #8
	str r1, [r0]

	;Set UART0_FBRD_R for 115,200 baud
    ;(*((volatile uint32_t *)(0x4000C028))) = 44;
	add r0, r0, #0x4
	mov r1, #44
	str r1, [r0]

	;Use System Clock
    ;(*((volatile uint32_t *)(0x4000CFC8))) = 0;
	mov r0, #0xCFC8
	movt r0, #0x4000
	mov r1, #0
	str r1, [r0]

	;Use 8-bit word length, 1 stop bit, no parity
    ;(*((volatile uint32_t *)(0x4000C02C))) = #0x60;
	mov r0, #0xC02C
	movt r0, #0x4000
	mov r1, #0x60
	str r1, [r0]

	;Enable UART0 Control
    ;(*((volatile uint32_t *)(0x4000C030))) = #0x301;
	add r0, r0, #0x4
	mov r1, #0x301
	str r1, [r0]

	;Make PA0 and PA1 as Digital Ports
    ;(*((volatile uint32_t *)(0x4000451C))) |= #0x03;
	mov r0, #0x451C
	movt r0, #0x4000
	ldr r1, [r0]
	orr r1, r1, #0x03
	str r1, [r0]

	;Change PA0,PA1 to Use an Alternate Function
    ;(*((volatile uint32_t *)(0x40004420))) |= #0x03;
	mov r0, #0x4420
	movt r0, #0x4000
	ldr r1, [r0]
	orr r1, r1, #0x03
	str r1, [r0]

	;Configure PA0 and PA1 for UART
    ;(*((volatile uint32_t *)(0x4000452C))) |= #0x11;
	mov r0, #0x452C
	movt r0, #0x4000
	ldr r1, [r0]
	orr r1, r1, #0x11
	str r1, [r0]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

timer_init:
	push	{r4-r12, lr}
	; connect clock to timer 0 and 1
	mov		r4, #0xe604
	movt	r4, #0x400f
	ldr		r5, [r4, #0]
	orr		r5, r5, #3
	str		r5, [r4, #0]

	; disable timer 0
	mov		r4, #0x0000
	movt	r4, #0x4003
	; base badaddr or timer 1
	add		r8, r4, #0x1000

	ldr		r5, [r4, #0xC]
	mov		r6, #0xFFFE
	movt	r6, #0xFFFF
	and		r5, r6, r5
	str		r5, [r4, #0xC]

	; disable timer 1
	ldr		r5, [r8, #0xC]
	mov		r6, #0xFFFE
	movt	r6, #0xFFFF
	and		r5, r6, r5
	str		r5, [r8, #0xC]

	; set timer to 32 bit mode
	ldr		r5, [r4, #0]
	mov		r6, #0xFFF8
	movt	r6, #0xFFFF
	and		r5, r6, r5	
	str		r4, [r4, #0]

	ldr		r5, [r8, #0]
	mov		r6, #0xFFF8
	movt	r6, #0xFFFF
	and		r5, r6, r5	
	str		r4, [r8, #0]

	; set to periodic mode
	ldr		r5, [r4, #0x4]
	mov		r6, #0xFFFC
	movt	r6, #0xFFFF
	and		r5, r6, r5
	orr		r5, r5, #2
	str		r5, [r4, #0x4]

	ldr		r5, [r8, #0x4]
	mov		r6, #0xFFFC
	movt	r6, #0xFFFF
	and		r5, r6, r5
	orr		r5, r5, #2
	str		r5, [r8, #0x4]


	; set period to 8M ticks, so twice per second
	; mov		r5, #0x2400
	; movt	r5, #0x007A
	mov		r5, #0xFF00
	movt	r5, #0xFF00
	; make period to interrupt stupidly big
	str		r5, [r4, #0x28]

	; timer 1 frequency is 1000 ticks per second, move 16000 or 0x3E80
	; if we want it to interrupt, we should have the frequency be very big.  if we want to just read the TAV register with the free-running timer-value, we should have it be very big
	; mov		r5, #0x3E80
	mov		r5, #0xFFEE
	movt	r5, #0xFFFF
	str		r5, [r8, #0x28]

	; setup to interrupt

	; for NOW we are not interrupting on timer 1 period
	ldr		r5, [r4, #0x18]
	orr		r5, r5, #0x1
	str		r5, [r4, #0x18]
	
	mov		r6, #0xE100
	movt	r6, #0xE000
	ldr		r5, [r6, #0x0]
	mov		r7, #0x0000
	movt	r7, #0x0008
	orr		r5, r7, r5
	str		r5, [r6, #0]


	; re-enable timer
	ldr		r5, [r4, #0xC]
	orr		r5, r5, #1
	str		r5, [r4, #0xC]

	ldr		r5, [r8, #0xC]
	orr		r5, r5, #1
	str		r5, [r8, #0xC]

	pop		{r4-r12, lr}
	mov		pc, lr

gpio_init:
	PUSH {r4-r12,lr}	; Spill registers to stack

         						; Your code is placed here
    mov 	r0, #0xE000			; this is for initializing clock
	movt 	r0, #0x400F		 	; Base address
	ldrb	r1, [r0, #0x608]	; load clock address into r1
	orr		r1, r1, #0x2A		; Flags to enable Ports F,D,B
	strb	r1, [r0, #0x608] 	; Offset, effective address is #0x4000FE608
	; we're using port F here
	mov		r0, #0x5000
	movt	r0, #0x4002
	ldrb	r1, [r0, #0x400]
	and		r1, r1, #0xEF		; writing to pin 4, so write a 0.  Leave other bits alone with F
	orr		r1, r1, #0x0E		; reading from pins 1, 2, 3, so they need to be 1
	strb	r1, [r0, #0x400]	; store directions to port f data direction reg

	ldrb	r1, [r0, #0x510]
	orr		r1, r1, #0x1E		; to set pins 1234 to dig, 0b0001 1110 == #0x1E
	strb	r1, [r0, #0x510]	; #0x510 is the gpio pull-up select register, enable the same 3
	strb	r1, [r0, #0x51C]	; enable pins for digital i/o

	; this is using port D, for the 4 buttons on the trainer board
	; INPUTS
	mov		r0, #0x7000
	movt	r0, #0x4000
	ldrb	r1,	[r0, #0x400]
	and		r1, r1, #0xF0			; to set a WRITE, we need a 0 for pins 0,1,2,3 - leave other bits alone with F
	strb	r1, [r0, #0x400]	; #0x400 is the offset for gpio-direction

	ldrb	r1, [r0, #0x51C]
	orr		r1, r1, #0x0F		; we want to enable all 4 bits, which is done with 0b1111 = #0xF
	strb	r1, [r0, #0x51C]	; enable pins for digital i/o
	; don't need to configure pull-up resistors



	; this is using port B, for the non-rgb LEDS on the trainer board
	mov		r0, #0x5000
	movt	r0, #0x4000
	strb 	r1, [r0, #0x400]	; gpio-dir, use 1 to set as output
	strb	r1, [r0, #0x51C]	; enable pins for digital i/o

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

read_string:
	push {r4-r12,lr} 		; store any registers in the range of r4 through r12
							; that are used in your routine.  include lr if this
							; routine calls another routine.
	and		r6, r6, #0  	; clear r6, we'll be using this to count each character in the passed in string and use it as metadata
	mov 	r4, r0			; preserve address given in r0 by copying it into r4

rsloop:
	bl		read_character  ; goto read_char subroutine to read the character put into the terminal
	strb	r0, [r4, r6]	; store character into passed in address r4 into r0 using r6 as offset
	add		r6, r6, #1		; r6++
	cmp		r0, #0x2D 		; check to see if the byte is -.  if it is, then we have a negative number
	it		eq				; this *should* force conditional execution
	bleq	setNegFlag		; if we encounter a negative number, set the regative flag
	bl		output_character; call output character so the user can see wtf they're doing
	cmp		r0, #0x0D		; compare with the hex value for the enter byte except NOT because for SOME FUCKING REASON WINDOWS USING 0D 0A
	; there is potential for a LINUX ONLY BUG HERE
	; linux ends its lines with 0A, not 0D 0A.  This code only looks for 0D.  So it isn't explicitly accomodating for linux, potential for infinite loop
	bne		rsloop			; if user hasn't inputted enter, loop

	sub		r6, r6, #1		; subtract one from strlen to account for the enter byte

	; so here we're just d	oing cleanup
	;strb	r6, [r4, #-1] 	; storing string length metadata.  since its before the start of the string, its gonna be considered metadata
	; that doesn't work because how one accesses memory is much more restricted than i once thought
	ldr		r7, ptr_to_space1; get a ptr to space 1 which is gonna be where we store string metadata
	ldr		r8, ptr_to_space2
	; for numerator, we'll use the byte at space1, and we'll check to see if it has contents.  if it does, we'll use the byte at space2
	; this will ensure that the demoninator will use space2
	ldrb	r10, [r7,#0] 	; grab the contents of ptr_to_space1 and shove it in r10
	cmp		r10, #0			; check to see if ptr_to_space1 has stuff in it
	ite		eq				; so if it does, then we shove it into denominator since we've already done this once before
	strbeq	r6, [r7, #0]	; store the length of the numerator in memory
	strbne	r6, [r8, #0]	; store the length of the denominator in memory

	and		r12, r12, #0	; clear r12 so we can store a null byte at the end of the string
	strb	r12, [r4, r6]	; store a null byte at the end of the string - this should replace the enter byte

	; after this point we should be done
	mov		r0, r4			; copy the address we saved in r4 back into r0, so the next subroutine can use it

	pop {r4-r12,lr}  		; restore registers all registers preserved in the
							; push at the top of this routine from the stack.
	mov pc, lr


output_character:
	push {r4-r12,lr} 		; store any registers in the range of r4 through r12
							; that are used in your routine.  include lr if this
							; routine calls another routine.

	mov  	r2, #0xc000		; this code left intentionally commented to remind me of wtf i'm doing in r2
	movt 	r2, #0x4000
	mov		r4, #0x20
							; looking for RxFF flag, offset 5 bits from #0x4000C018
tloop:						; Transmit loop
	ldrb	r1, [r2, #0x18] ; load flag reg to see if transmit buffer is full
	and		r3, r1, #0x20  	; bitmask looking for 1 in last place, store in r3 to preserve flag reg
	cmp		r3, r4			; checking bitmask
	beq		tloop			; if flag reg contains 1, loop
							; now we need to store r0 in data reg
	strb 	r0, [r2, #0]	; no offset needed, storing r0 into data reg


	pop {r4-r12,lr}   		; restore registers all registers preserved in the
							; push at the top of this routine from the stack.
	mov pc, lr



output_string:
	push {r4-r12,lr} 		; store any registers in the range of r4 through r12
							; that are used in your routine.  include lr if this
							; routine calls another routine.

							; your code for your output_string routine is placed here
	mov		r5, r0			; copy r0 into r5 to back it up
	; i don't actually need to do that, just use post-indexing loads instead

str_out_loop:
	ldrb	r0, [r5], #1	; load the character from r5+r4 (r4 is offset) into r0
	bl		output_character; print said character
	cmp		r0, #0			; check to see if the printed out character is a null byte or not
	bne		str_out_loop	; if we did not print out a null byte, loop


	pop {r4-r12,lr} 		; restore registers all registers preserved in the
							; push at the top of this routine from the stack.
	mov pc, lr

read_from_push_btns:
	PUSH {r4-r12,lr}		; Spill registers to stack

          					; Your code is placed here
    mov		r1, #0x7000
    movt	r1, #0x4000 		; put address of port D in r1
poll:
	ldrb	r0, [r1, #0x3FC] ; load data byte into r0
	cmp		r0, #0
	beq		poll			; make sure the user actually enters data into r0
							; poll until the user does
							; just return r0

	POP {r4-r12,lr}  		; Restore registers from stack
	MOV pc, lr

illuminate_LEDs:
	PUSH {r4-r12,lr}	; Spill registers to stack

	; we are assuming that there's input in r0 to store in memory

	mov		r1,#0x5000	; Your code is placed here
	movt	r1,#0x4000	; address of port B
	strb	r0, [r1, #0x3FC]	; address of data reg
	;; after this, there's not much that needs to be done


	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

illuminate_RGB_LED:
	PUSH {r4-r12,lr}	; Spill registers to stack

	cmp		r0, #12					; if the color the user entered is 0b1100, yell at them
	bleq	invalid_color

	cmp		r0, #3					; 0b0011 is also invalid, since if you flip 0011 it turns it into 1100 which is the invalid color
	bleq	invalid_color

	mov		r1, #0x5000
	movt	r1, #0x4002				; address of port F

	and		r4, r0, #0x1			; mask for lsb
	cmp		r4, #0x1
	itt		eq						; If the least significant bit is 1, that means SW5 is pressed.
	mvneq	r0, r0					; Since there isn't a 4th color, if SW5 is pressed invert all colors
	andeq	r0, r0, #0xE			; masks out bits before the 3rd bit



	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

invalid_color:

	push	{r4-r12,lr}

	ldr		r0, ptr_to_yellatuser	; yell at them
	bl		output_string
									; so now that we've yelled at them, make them do a different input
	bl		read_from_push_btns 	; we got different input, return


	pop		{r4-r12,lr}
	mov		pc, lr

change_color:
	PUSH {r4-r12,lr}	; Spill registers to stack
	; we change color depending on the contents of r2
	; use shift trickery to save instructions
	cmp		r2, #6		; light blue , 0b1100, not listed color to display, so skip it
	it		eq
	addeq		r2, r2, #1	; skips light blue

	cmp		r2, #7		; we don't want it to be greater than 7
	it		gt
	movgt	r2, #1		; if we iterate above 7, set to 1

	lsl		r2, #1		; for example, 2 = 0b0010, but we are not using bit 0.  shifting it
						; left once turns it onto 0b0100, which turns it into something we can write to the datareg





	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

read_tiva_push_button:

	PUSH {r4-r12,lr}	; Spill registers to stack

	; set pull up resistor for pin 4
	ldr r1, [r3, #0x510]		; offset
	AND r1, r1, #0x10			; mask 4th pin to enable
	str r1, [r3, #0x510]		; store masked bit

	; read data register pin until receive 1
read_loop:
	; change r0 to a different reg
	ldr r1, [r3, #0x3FC]		; offset for gpio data register
	AND r1, r1, #0x10			; mask 4th pin
	cmp r1, #0x10
	ite	eq						; do stuff based on equality
	moveq r0, #0				; if equal, return 0
	movne r0, #1				; if not equal, return 1

	POP {r4-r12,lr}  			; Restore registers from stack
	MOV pc, lr
div_and_mod:
	push {r4-r12,lr} 	; store any registers in the range of r4 through r12
						; that are used in your routine.  include lr if this
						; routine calls another routine.


						; your code for the div_and_mod routine goes here.
	and		r2, r2, #0	; clear r2, used for iterator

						; movt comes first to deal with negatives

						; we need to test to see if the denominator is greater than the numerator, eg 2/5 - both reg need to be positive


	cmp		r0, r1		; is r0 < r1?
	blt		r0ltr1		; if so, branch to r0ltr1 which handles this case

divloop:					; this section is where we actually do the divison loop
	add		r2, r2, #1	; r2++
	sub		r0, r0, r1	; r0 := r0 - r1
	cmp		r0, r1		; test to see if r0 >= r1.  at the end of the division, r0 should be smaller than r1
	bge		divloop		; if r0 >= r1, then loop again
						; division over
	mov 	r1, r0		; r0 currently contains remainder, r1 is where remainder should be returned in
	mov		r0, r2		; r2 is number of times iterated, so quotient.  copy into r0

	pop {r4-r12,lr}   	; restore registers all registers preserved in the
						; push at the top of this routine from the stack.
	mov pc, lr





r0ltr1:
	mov		r1, r0		; copy r0 into r1
	mov		r0, #0 		; copy a zero into r0
	movt	r0, #0

	pop {r4-r12,lr}   	; restore registers all registers preserved in the
						; push at the top of this routine from the stack.
	mov pc, lr


	pop {r4-r12,lr}   	; restore registers all registers preserved in the
						; push at the top of this routine from the stack.
	mov pc, lr

setNegFlag:
	push {r4-r12,lr} 		; store any registers in the range of r4 through r12

	and		r4, r4, #0		; clear r4, just so its 0
	ldr	r6, ptr_to_negFlag  ; grab the location of negFlag
	ldrb	r5, [r6, #0]	; actually load negFlag's contents into r5
	eor		r5, r5, #1		; xor r5 with 1, so that if this subroutine is called twice it'll unset the negative flag
	strb	r5, [r6, #0]    ; now that we've set or potentially unset the negative flag, shove it into memory again


	pop {r4-r12,lr}   		; restore registers all registers preserved in the
							; push at the top of this routine from the stack.
	mov pc, lr

read_character:
	push {r4-r12,lr} 		; store any registers in the range of r4 through r12
							; that are used in your routine.  include lr if this
							; routine calls another routine.
	mov		r4, #0x10
							; looking for RxFE flag, which is stored at 0x4000C018
rloop:						; Recieve loop
	; TODO: something's fishy in this subroutine
	ldrb	r1, [r2, #0x18] ; first thing is to check flag reg to see if buffer is full, r2 contains first half, u0frRF is offset of 4
	and		r3, r1, #0x10  	; bitmask looking for 1 in last place, store in r3 to preserve flag reg
	cmp		r3, r4			; check to see if flag reg is 0 or 1 - if 1, loop
	beq		rloop			; if flag reg contains 1, loop
							; now there should be data to read
	ldrb 	r0, [r2, #0]	; no offset needed, just load data reg into r0 and return from program

	pop {r4-r12,lr}   		; restore registers all registers preserved in the
							; push at the top of this routine from the stack.
	mov pc, lr



int2string:
	push {r4-r12,lr} 		; store any registers in the range of r4 through r12
							; that are used in your routine.  include lr if this
							; routine calls another routine.

							; your code for your int2string routine is placed here
	mov		r5, r0			; preserve the address in r0
	mov		r0, r1			; copy the number we're given into r0
	and		r8, r8, #0		; clear r8, use this to contain the string - WE CAN CONTAIN THE WHOLE STRING IN ONE REG!
	; now we need to determine the number of digits, we can do it by comparing to 99 and 9
	cmp		r1, #99			; if its greater than 99, then it has to be 3 digits in size
	itt		gt				; if-then-then block based on it being greater than 99
	movgt	r4, #3
	bgt		skip			; skip the rest of the checks

	cmp		r1, #9			; if its greater than 9, it must be 2 digits.  if its not, then it must be one digit
	ite	gt
	movgt	r1, #2
	movle	r1, #1

skip:

	ldr		r7, ptr_to_negFlag; we need to know if we have a negative number
	ldrb	r6, [r7, #0]
	cmp		r6, #1			; so if it is, then add 0x2D into r8 and shift it
	itt		eq
	addeq	r8, r8, #0x2D	; 0x2D is hex for -
	lsleq	r8, #8			; shift it by one byte, the smallest byte should be zero

	cmp		r4, #3			; check to see if we have three digits
	beq		three_digits	; if so, handle everything in three_digits.  repeat for 2 and 1

	cmp		r4, #2
	beq		two_digits

	cmp		r4, #1
	beq		one_digit


three_digits:

	mov		r1, #100		; copy 100 into r1 to do a div_and_mod with 100, root out the 100ths place
	bl		div_and_mod
	add		r0, r0, #0x30	; convert int to char
	add		r8, r8, r0		; we want quotient because that'll tell us the 100ths place
							; r8 is where we're keeping track of the string, adding 0x30 turns it into ascii
	lsl		r8, #8			; shift it by a byte, to keep the last two bytes 00
	mov		r0, r1			; then just copy the remainder into r0
							; now we just do it for two digits

two_digits:

	mov		r1, #10			; copy in 10 to r1
	bl		div_and_mod
	add		r0, r0, #0x30
	add		r8, r8, r0		; same as earlier
	lsl		r8, #8
	mov		r0, r1

one_digit:

	; unlike the other two times, if we only have 1 digit then we just add it to r8
	add		r0, r0, #0x30
	add		r8, r8, r0
	; no need for shifting

	; now at this point, given 435 with negative flag, r8 would look like: 0x2D343335 or "534-" because endianness.
	; rotate by 1 byte 3 times to fix
	ror		r8, r8, #8
	ror		r8, r8, #8
	ror		r8, r8, #8		; no, rotating once by 24 bits is NOT the same thing

	; now we can just store it
	str		r8, [r5, #0] 	; address will still be in r5


	pop {r4-r12,lr}   		; restore registers all registers preserved in the
							; push at the top of this routine from the stack.
	mov pc, lr

uart_interrupt_init:



	; Your code to initialize the UART0 interrupt goes here

	mov 	r1, #0xC000		; UARTIM base address
	movt 	r1, #0x4000
	ldr 	r0, [r1, #0x38]	; UARTIM offset
	ORR 	r0, r0, #0x10	; set RXIM pin 4
	str 	r0, [r1, #0x38]	; store set pin

	mov 	r1, #0xE000		; e0 base address
	movt 	r1, #0xE000
	ldr 	r0, [r1, #0x100]	; load offset
	ORR 	r0, r0, #0x20	; set bit 5 to 1
	str 	r0, [r1, #0x100]	; store change

	MOV pc, lr


gpio_interrupt_init:

	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.
	push	{r4-r11,lr}

	mov		r4, #0x5000				; port F address
	movt	r4, #0x4002				; upper half of port F
	ldrb	r5, [r4, #0x404]		; store a 0 to set GPIO interrupt to be edge sensitive
	and		r5, r5, #sw1mask		; bitmask for pin 4
	strb	r5, [r4, #0x404]

	ldrb	r5, [r4, #0x408]		; store 1 to configure to interrupt on both edges - so we store a 0
	orr		r5, r5, #sw1write
	strb	r5, [r4, #0x408]

	ldrb	r5, [r4, #0x40C]		; store 0 to configure to interrupt on falling edge
	and		r5, r5, #sw1mask
	strb	r5, [r4, #0x40C]

	ldrb	r5, [r4, #0x410]		; store 1 to enable interrupts
	orr		r5, r5, #sw1write
	strb	r5, [r4, #0x410]

	; different base address for en0
	mov		r4, #0xE000
	movt	r4, #0xE000

	ldr		r5, [r4, #0x100]		; store 1 at E000E100
	mov		r6, #0x0				; this is to set pin 30 to 1 to enable port F to interrupt
	movt	r6, #0x4000
	orr		r5, r5, r6				; set to 1
	str		r5, [r4, #0x100]

	pop		{r4-r11,lr}
	mov		pc, lr

	.end
