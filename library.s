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
ptr_to_lab4prompt		.word lab4prompt
ptr_to_introdummy		.word introdummy
ptr_to_restart			.word restartprompt




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



init:
	push	{r4-r12,lr}
	bl		uart_init			; initalize uart
	bl		gpio_init			; init gpio
	bl		uart_interrupt_init ; init interrupts for uart
	bl		gpio_interrupt_init
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

	;mov  r2, #0xc000		; this code left intentionally commented to remind me of wtf i'm doing in r2
	;movt r2, #0x4000
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
							; looking for RxFE flag, which is stored at 0x4000C01C
rloop:						; Recieve loop
	ldrb	r1, [r2, #0x18] ; first thing is to check flag reg to see if buffer is full, r2 contains first half, u0frRF is offset of 4
	and		r3, r1, #0x10  	; bitmask looking for 1 in last place, store in r3 to preserve flag reg
	cmp		r3, r4			; check to see if flag reg is 0 or 1 - if 1, loop
	beq		rloop			; if flag reg contains 1, loop
							; now there should be data to read
	ldrb 	r0, [r2, #0]	; no offset needed, just load data reg into r0 and return from program

	pop {r4-r12,lr}   		; restore registers all registers preserved in the
							; push at the top of this routine from the stack.
	mov pc, lr


	.end
