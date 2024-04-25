	.cdecls C,NOLIST,"debug.h"

	.data


	.text
	.global init

init:
	push	{lr}
	bl		uart_init			; initalize uart
	bl		gpio_init			; init gpio
	bl		uart_interrupt_init ; init interrupts for uart
	bl		gpio_interrupt_init
	bl		timer_init
	pop		{lr}
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
	mov		r5, #0x2400
	movt	r5, #0x007A
	str		r5, [r4, #0x28]

	; to get good random number, make period for timer 1 big
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

	ldrb	r1,	[r0, #0x400] 	; gpiodir
	and		r1, r1, #0xF0		; set pins 0-3 as input by writing 0
	strb	r1, [r0, #0x400]

	ldrb	r1, [r0, #0x51C]	; gpioden
	orr		r1, r1, #0x0F		; we want to enable all 4 bits, which is done with 0b1111 = #0xF
	strb	r1, [r0, #0x51C]

	ldrb	r1, [r0, #0x510] 	; gpiopur - enforce disable
	and		r1, r1, #0xF0		; clear pins 0-3
	strb	r1, [r0, #0x510]


	; this is using port B, for the non-rgb LEDS on the trainer board
	mov		r0, #0x5000
	movt	r0, #0x4000
	strb 	r1, [r0, #0x400]	; gpio-dir, use 1 to set as output
	strb	r1, [r0, #0x51C]	; enable pins for digital i/o

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

gpio_interrupt_init:

	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.
	push	{r4-r11,lr}

	mov		r4, #0x5000				; port F address
	movt	r4, #0x4002				; upper half of port F
	ldrb	r5, [r4, #0x404]		; store a 0 to set GPIO interrupt to be edge sensitive
	and		r5, r5, #0xEF			; bitmask for pin 4
	strb	r5, [r4, #0x404]

	ldrb	r5, [r4, #0x408]		; store 1 to configure to interrupt on both edges - so we store a 0
	and		r5, r5, #0xEF
	strb	r5, [r4, #0x408]

	ldrb	r5, [r4, #0x40C]		; store 0 to configure to interrupt on falling edge
	and		r5, r5, #0xEF
	strb	r5, [r4, #0x40C]

	ldrb	r5, [r4, #0x410]		; store 1 to enable interrupts
	orr		r5, r5, #sw1write
	strb	r5, [r4, #0x410]

	;mov		r4, #0x7000				; port D address ( sw2-sw5)
	;movt	r4, #0x4000

	;ldrb	r5, [r4, #0x404]		; interrupt on edge sensitive
	;and		r5, r5, #0xF0			; edge sensitive interrupt for pins 0-3 for sw 2-5
	;strb	r5, [r4, #0x404]

	;ldrb	r5, [r4, #0x408]		; configure to let GPIO interrupt event reg control when it interrupts
	;and		r5, r5, #0xF0
	;strb	r5, [r4, #0x408]

	;ldrb	r5, [r4, #0x40C]		; interrupt on rising edge
	;orr		r5, r5, #0x0F
	;strb	r5, [r4, #0x40C]

	;ldrb	r5, [r4, #0x410]		; interrupt mask register
	;orr		r5, r5, #0x0F			; let pins 0-3 interrupt
	;strb	r5, [r4, #0x410]


	; different base address for en0
	;mov		r4, #0xE000
	;movt	r4, #0xE000

	;dr		r5, [r4, #0x100]		; store 1 at E000E100
	mov		r6, #0x0000				; set pin 30 and 19 to 1 to enable port D and F to interrupt
	;movt	r6, #0x4008
	movt	r6, #0x4000
	orr		r5, r5, r6				; set bit values
	str		r5, [r4, #0x100]

	pop		{r4-r11,lr}
	mov		pc, lr

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
