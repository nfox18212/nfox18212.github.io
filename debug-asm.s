	.cdecls C,NOLIST,"debug.h"

clc .macro
	push	{r0}
	mov		r0, #0xC	; form feed
	bl	output_character
	pop		{r0}
	.endm

newl .macro				; print a newline
	push 	{r0}
	mov		r0, #0xD
	bl		output_character
	mov		r0, #0xA
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






.data

didcrash:	.byte 0x0
baddr:		.word 0x0

	.global	didcrash
	.global baddr

	.text


	.global crash


	.if en_uart_out=1
	.global output_character
	.global output_string
	.endif

	.if en_uart_out=0
	.global uprintf ; c function to print to uart
	.endif

didcrashp:  .word didcrash
baddrp:     .word baddr


crash:
	; takes crash string in r0
	; make this code uninterruptible
	push	{r0-r2, r4-r12, lr} ; preserve but r3 to be able to restore context because jumping to fault
    .if en_timer_int==1
    ; disable timer 0
	mov		r4, #0x0000
	movt	r4, #0x4003
	ldr		r5, [r4, #0xC]
	mov		r6, #0xFFFE
	movt	r6, #0xFFFF
	and		r5, r6, r5
	str		r5, [r4, #0xC]
	.endif 

    .if en_uart_int=1
	; disable uart interrupts
	mov 	r1, #0xE000		; e0 base address
	movt 	r1, #0xE000
	ldr 	r0, [r1, #0x100]	; load offset
	mov		r4, #0xFFDF			; 1s cmp of 0x20
	movt	r4, #0xFFFF
	and		r0, r4, #0x20		; set bit 5 to 0
	str 	r0, [r1, #0x100]	; store change
    .endif

    .if en_gpio_int=1
	; disable gpio interrupts
	ldrb	r5, [r4, #0x410]		; store 0 to disable interrupts
	mov		r6, #0xFF10
	movt	r6, #0xFFFF
	and		r5, r5, r6			
	strb	r5, [r4, #0x410]
    .endif

	; set custom memory location to set that we intetionally caused a fault
	ldr		r4, didcrashp
	mov		 r5, #1		; this signifies that the program was intentionally crashed
	strb	r5, [r4, #0]	; store it

	; store the link register into baddr
	; the link register stores the next instruction to execute, store it there
	ldr		r5, baddrp
	str		lr, [r5, #0] ; store lr


    ;; custom crash string in r0
    .if en_uart_out=1
	clc
	bl		output_string
    .endif

    .if en_uart_out=0
    bl      uprintf
    .endif

    ; fault
	mov		r3, #0xFFFF
	movt	r3, #0xFFFF
	ldr		r3, [r3, #0] ; attempt to load invalid memory

.end
