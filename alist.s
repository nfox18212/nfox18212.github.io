    .cdecls C,NOLIST,"debug.h"

; test file for specifically working with the adjacency lis

    .if separate_alist_file=1
        .data
; format described in docs
; simple description: first 4 bits are color, next 12 are the cell index.  0,1,2,3 are cardinal direction for East, South, North, West and other cell indexes.
alist:		
			.byte 0x64, 0x00, 0x65, 0x00, 0x6E, 0x10, 0xA4, 0x21, 0xF6, 0x31
			.byte 0x65, 0x00, 0x66, 0x00, 0x6F, 0x10, 0xA5, 0x21, 0x64, 0x30
			.byte 0x66, 0x00, 0x58, 0x02, 0x70, 0x10, 0xA6, 0x21, 0x65, 0x30
			.byte 0x6E, 0x00, 0x6F, 0x00, 0x78, 0x10, 0x64, 0x20, 0x00, 0x32
			.byte 0x6F, 0x00, 0x70, 0x00, 0x79, 0x10, 0x65, 0x20, 0x6E, 0x30
			.byte 0x70, 0x00, 0x62, 0x02, 0x7A, 0x10, 0x66, 0x20, 0x6F, 0x30
			.byte 0x78, 0x00, 0x79, 0x00, 0xC8, 0x10, 0x6E, 0x20, 0x0A, 0x32
			.byte 0x79, 0x00, 0x7A, 0x00, 0xC9, 0x10, 0x6F, 0x20, 0x7A, 0x30
			.byte 0x7A, 0x00, 0x6C, 0x02, 0xCA, 0x10, 0x70, 0x20, 0x79, 0x30
			.byte 0xC8, 0x00, 0xC9, 0x00, 0xD2, 0x10, 0x78, 0x20, 0x0A, 0x32
			.byte 0xC9, 0x00, 0xCA, 0x00, 0xD3, 0x10, 0x79, 0x20, 0xC8, 0x30
			.byte 0xCA, 0x00, 0x6C, 0x02, 0xD4, 0x10, 0x7A, 0x20, 0xC9, 0x30
			.byte 0xD2, 0x00, 0xD3, 0x00, 0xDC, 0x10, 0xC8, 0x20, 0x09, 0x32
			.byte 0xD3, 0x00, 0xD4, 0x00, 0xDD, 0x10, 0xC9, 0x20, 0xD4, 0x30
			.byte 0xD4, 0x00, 0x6D, 0x02, 0xDE, 0x10, 0xCA, 0x20, 0xD3, 0x30
			.byte 0xDC, 0x00, 0xDD, 0x00, 0x2E, 0x11, 0xD2, 0x20, 0xDD, 0x30
			.byte 0xDD, 0x00, 0xDE, 0x00, 0x38, 0x11, 0xD3, 0x20, 0xDE, 0x30
			.byte 0xDE, 0x00, 0xDD, 0x00, 0x42, 0x11, 0xD4, 0x20, 0x6E, 0x32
			.byte 0x2C, 0x01, 0x2D, 0x01, 0x36, 0x11, 0xDC, 0x20, 0xF6, 0x31
			.byte 0x2D, 0x01, 0x2E, 0x01, 0x37, 0x11, 0xDD, 0x20, 0x2C, 0x31
			.byte 0x2E, 0x01, 0x6E, 0x02, 0x38, 0x11, 0xDE, 0x20, 0x2D, 0x31
			.byte 0x36, 0x01, 0x37, 0x01, 0x40, 0x11, 0x2C, 0x21, 0xF5, 0x31
			.byte 0x37, 0x01, 0x38, 0x01, 0x41, 0x11, 0x2D, 0x21, 0x36, 0x31
			.byte 0x38, 0x01, 0x64, 0x02, 0x42, 0x11, 0x2E, 0x21, 0x37, 0x31
			.byte 0x40, 0x01, 0x41, 0x01, 0x90, 0x11, 0x36, 0x21, 0xF4, 0x31
			.byte 0x41, 0x01, 0x42, 0x01, 0x91, 0x11, 0x37, 0x21, 0x40, 0x31
			.byte 0x42, 0x01, 0x5A, 0x02, 0x92, 0x11, 0x38, 0x21, 0x5A, 0x32
			.byte 0x90, 0x01, 0x91, 0x01, 0x9A, 0x11, 0x40, 0x21, 0xF4, 0x31
			.byte 0x91, 0x01, 0x92, 0x01, 0x9B, 0x11, 0x41, 0x21, 0x90, 0x31
			.byte 0x92, 0x01, 0x5A, 0x02, 0x9C, 0x11, 0x42, 0x21, 0x91, 0x31
			.byte 0x9A, 0x01, 0x9B, 0x01, 0xA4, 0x11, 0x90, 0x21, 0xF5, 0x31
			.byte 0x9B, 0x01, 0x9C, 0x01, 0xA5, 0x11, 0x91, 0x21, 0x9A, 0x31
			.byte 0x9C, 0x01, 0x59, 0x02, 0xA6, 0x11, 0x92, 0x21, 0x9B, 0x31
			.byte 0xA4, 0x01, 0xA5, 0x01, 0x64, 0x10, 0x9A, 0x21, 0xF6, 0x31
			.byte 0xA5, 0x01, 0xA6, 0x01, 0x65, 0x10, 0x9B, 0x21, 0xA4, 0x31
			.byte 0xA6, 0x01, 0x58, 0x02, 0x66, 0x10, 0x9C, 0x21, 0xA5, 0x31
			.byte 0xF4, 0x01, 0xF5, 0x01, 0xFE, 0x11, 0x90, 0x21, 0x40, 0x31
			.byte 0xF5, 0x01, 0xF6, 0x01, 0xFF, 0x11, 0x9A, 0x21, 0xF4, 0x31
			.byte 0xF6, 0x01, 0x64, 0x00, 0x00, 0x12, 0xA4, 0x21, 0xF5, 0x31
			.byte 0xFE, 0x01, 0xFF, 0x01, 0x08, 0x12, 0xF4, 0x21, 0x36, 0x31
			.byte 0xFF, 0x01, 0x00, 0x02, 0x09, 0x12, 0xF5, 0x21, 0xFE, 0x31
			.byte 0x00, 0x02, 0x6E, 0x00, 0x0A, 0x12, 0xF6, 0x21, 0xF5, 0x31
			.byte 0x08, 0x02, 0x09, 0x02, 0xDC, 0x10, 0xFE, 0x21, 0x2C, 0x31
			.byte 0x09, 0x02, 0x0A, 0x02, 0xD2, 0x10, 0xFF, 0x21, 0x08, 0x32
			.byte 0x0A, 0x02, 0x78, 0x00, 0xC8, 0x10, 0x00, 0x22, 0x09, 0x32
			.byte 0x58, 0x02, 0x59, 0x02, 0x62, 0x12, 0xA6, 0x21, 0x66, 0x30
			.byte 0x59, 0x02, 0x5A, 0x02, 0x63, 0x12, 0x9C, 0x21, 0x58, 0x32
			.byte 0x5A, 0x02, 0x42, 0x01, 0x64, 0x12, 0x92, 0x21, 0x59, 0x32
			.byte 0x62, 0x02, 0x63, 0x02, 0x6C, 0x12, 0x58, 0x22, 0x70, 0x30
			.byte 0x63, 0x02, 0x64, 0x02, 0x6D, 0x12, 0x59, 0x22, 0x64, 0x32
			.byte 0x64, 0x02, 0x38, 0x01, 0x6E, 0x12, 0x5A, 0x22, 0x63, 0x32
			.byte 0x6C, 0x02, 0x6D, 0x02, 0xCA, 0x10, 0x62, 0x22, 0x7A, 0x30
			.byte 0x6D, 0x02, 0x6E, 0x02, 0xD4, 0x10, 0x63, 0x22, 0x6C, 0x32
			.byte 0x6E, 0x02, 0x2E, 0x01, 0xDE, 0x10, 0x64, 0x22, 0x6D, 0x32
			.byte 0x00, 0x00 ; null byte at end

crashstr:	.string 	"Encountered unresolvable problem, crashing program", 0xD,0xA, 0x0

globals:    .byte 0x0

    .text
    .global set_color
    .global get_color
    .global get_cell
    .global div_and_mod
    .global extract_cid
    .global crash

getclcrashp:	.word crashstr
alistp:     	.word alist

set_color:
	; given cell ID in r0
	; given color in r1
	; returns cell in r0
	push	{r4-r12,lr}

	; backup r1
	mov		r4, r1
	; set r1 to 4 to specify to get_cell we want exactly cell r0
	mov		r1, #4
	bl		get_cell
	; now there's the cell contents in r0
	orr		r0, r0, r4, lsl #12		; this adds the color into the cell contents

	ldr		r7, alistp 		; get the pointer to the alist
	strh	r0, [r7, r1]	; store the modified cell contents in the alist
	; nothing else to do, return

	pop		{r4-r12,lr}
	mov		pc, lr

get_color:
	; given cell ID in r0
	; no other registers are important
	; return color in r0
	push	{r4-r12,lr}

	mov		r1, #4
	bl		get_cell
	and		r0, r0, #0xF000		; mask for the color
	lsr		r0, r0, #12			; shift back to 1,2,3,4,5,6
	; return
	pop		{r4-r12,lr}
	mov		pc, lr

get_cell:

	; r0 - current cell index
	; r1 - cardinal direction to grab - as 0 - East, 1 - South , 2 - North, 3 - West, Current Cell 
	; returns:
	; r0 - new cell
	; r1 - returns offset
	push	{r4-r12,lr}
	; first we need to calculate the offset
	; formula is: 90*(face-1)+30*row+10*col+2*(direction+1)
	; first we need to extract face, row, col
	; if dir = 4, return the current cell from the table
	; returns cell contents in r0, offset from alist to get to cell in r1
	mov		r4, r1 		; backup the direction the character is facing
	mov		r10, r0
	bl		extract_cid
	; now we have face in r0, row in r1, col in r2
	; prep for formula

	mov		r6, #0
	mov		r7, #0

	; r6 will be used as the running sum when calculating offset
	; Formula is correct
	mov		r5, #90		; move for multiplication
	sub 	r0, r0, #1	; face -= 1
	mla		r6, r0, r5, r6 ; r6 *= 45*face + r6

	mov		r5, #30
	mla		r6, r1, r5, r6 ; r6 = r6 + r1*15

	mov		r5, #10
	mla		r6, r2, r5, r6 ; r6 = r6 + r2*5

	; Account for direction, aka if the given direction is 1, the cell south to the given cell is being asked for
	; the formula is 2*(direction+1)
	; only do this if the direction is not 4.
	; 4 means the caller is asking for how the given cell is stored in the alist, so returning the contents of the alist for the given cell will 
	; give access to said cell's color
	cmp		r4, #4
	ittt	ne
	movne	r5, #2			
	addne	r4, r4, #1		; the add 1 part of the formula
	mlane	r6, r4, r5, r6; r6 = r4*r5 + r6
	

	
	; if r4 > 4, something has horribly wrong and crash the program
	ldr		r0, getclcrashp ; custom crash string
	bgt		crash
	
	ldr		r5, alistp 		; grab ptr to alist
	ldrh	r0, [r5, r6]	; grab cell contents using the calculated offset
	; if direction was not 4, filter out first nibble.  It contains direction data which is irrelevant. 
	itt		ne
	movne	r10, #0x0FFF
	andne	r0, r0, r10
	mov		r1, r6			; return the offset in r1 for set_color


	pop		{r4-r12,lr}
	mov		pc, lr 





























    .endif