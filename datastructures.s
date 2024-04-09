
	.data

mats: 		.space 	128 	; matrix storage, size will need to change - sebastien this is yours to implement

; yes, this is kind of unreadable.  just read the docs, specifically about adjacency list
fotab:	    .byte 0x01, 0x60, 0x24, 0x48, 0x5C
			.byte 0x02, 0x63, 0x35, 0x18, 0x5D
			.byte 0x03, 0x62, 0x44, 0x28, 0x51
			.byte 0x04, 0x61, 0x15, 0x34, 0x5F
			.byte 0x05, 0x10, 0x27, 0x49, 0x2F
			.byte 0x06, 0x32, 0x25, 0x4B, 0x1C
			.byte 0x00 ; null terminator byte
 

; format described in docs
; simple description: first 4 bits are color, next 12 are the cell index.  0,1,2,3 are cardinal direction for East, South, North, West and other cell indexes.
alist:		.half 0x0064, 0x0065, 0x106E, 0x21A4, 0x31F6
			.half 0x0065, 0x0066, 0x106F, 0x21A5, 0x3064
			.half 0x0066, 0x0258, 0x1070, 0x21A6, 0x3065
			.half 0x006E, 0x006F, 0x1078, 0x2064, 0x3200
			.half 0x006F, 0x0070, 0x1079, 0x2065, 0x306E
			.half 0x0070, 0x0262, 0x107A, 0x2066, 0x306F
			.half 0x0078, 0x0079, 0x10C8, 0x206E, 0x320A
			.half 0x0079, 0x007A, 0x10C9, 0x206F, 0x307A
			.half 0x007A, 0x026C, 0x10CA, 0x2070, 0x3079
			.half 0x00C8, 0x00C9, 0x10D2, 0x2078, 0x320A
			.half 0x00C9, 0x00CA, 0x10D3, 0x2079, 0x30C8
			.half 0x00CA, 0x026C, 0x10D4, 0x207A, 0x30C9
			.half 0x00D2, 0x00D3, 0x10DC, 0x20C8, 0x3209
			.half 0x00D3, 0x00D4, 0x10DD, 0x20C9, 0x30D4
			.half 0x00D4, 0x026D, 0x10DE, 0x20CA, 0x30D3
			.half 0x00DC, 0x00DD, 0x112E, 0x20D2, 0x30DD
			.half 0x00DD, 0x00DE, 0x1138, 0x20D3, 0x30DE
			.half 0x00DE, 0x00DD, 0x1142, 0x20D4, 0x326E
			.half 0x012C, 0x012D, 0x1136, 0x20DC, 0x31F6
			.half 0x012D, 0x012E, 0x1137, 0x20DD, 0x312C
			.half 0x012E, 0x026E, 0x1138, 0x20DE, 0x312D
			.half 0x0136, 0x0137, 0x1140, 0x212C, 0x31F5
			.half 0x0137, 0x0138, 0x1141, 0x212D, 0x3136
			.half 0x0138, 0x0264, 0x1142, 0x212E, 0x3137
			.half 0x0140, 0x0141, 0x1190, 0x2136, 0x31F4
			.half 0x0141, 0x0142, 0x1191, 0x2137, 0x3140
			.half 0x0142, 0x025A, 0x1192, 0x2138, 0x325A
			.half 0x0190, 0x0191, 0x119A, 0x2140, 0x31F4
			.half 0x0191, 0x0192, 0x119B, 0x2141, 0x3190
			.half 0x0192, 0x025A, 0x119C, 0x2142, 0x3191
			.half 0x019A, 0x019B, 0x11A4, 0x2190, 0x31F5
			.half 0x019B, 0x019C, 0x11A5, 0x2191, 0x319A
			.half 0x019C, 0x0259, 0x11A6, 0x2192, 0x319B
			.half 0x01A4, 0x01A5, 0x1064, 0x219A, 0x31F6
			.half 0x01A5, 0x01A6, 0x1065, 0x219B, 0x31A4
			.half 0x01A6, 0x0258, 0x1066, 0x219C, 0x31A5
			.half 0x01F4, 0x01F5, 0x10F6, 0x2190, 0x3140
			.half 0x01F5, 0x01F6, 0x11FF, 0x219A, 0x31F4
			.half 0x01F6, 0x0064, 0x1200, 0x21A4, 0x31F5
			.half 0x01FE, 0x01FF, 0x1208, 0x21F4, 0x3136
			.half 0x01FF, 0x0200, 0x1209, 0x12F5, 0x31FE
			.half 0x0200, 0x006E, 0x120A, 0x21F6, 0x31F5
			.half 0x0208, 0x0209, 0x10DC, 0x21F3, 0x312C
			.half 0x0209, 0x020A, 0x10D2, 0x21FF, 0x3208
			.half 0x020A, 0x0078, 0x10C8, 0x2200, 0x3209
			.half 0x0258, 0x0259, 0x1262, 0x21A6, 0x3066
			.half 0x0259, 0x025A, 0x1263, 0x219C, 0x3258
			.half 0x025A, 0x0142, 0x1264, 0x2192, 0x3259
			.half 0x0262, 0x0263, 0x126C, 0x2258, 0x3070
			.half 0x0263, 0x0264, 0x126D, 0x2259, 0x3264
			.half 0x0264, 0x0138, 0x126E, 0x225A, 0x3263
			.byte 0x00 ; null byte at end



; up: bits 6,7 - down: bits 4,5 - left: bits 2,3 right: 0,1
; East: 00,  South: 01, North: 10, West: 11
; table that converts relative movement (up, down, left, right) into cardinal directions
rcttab:		.half 0x00B4, 0x012D, 0x028B, 0x03D2
			.byte 0x00 ; null terminator byte

	.text

	.global new_o
	.global alistp
	.global fotabp
	.global rcdtabp
	.global rcd
	.global set_color
	.global get_color
	.global get_cell
	.global extract_cid
	.global div_and_mod ; from library

fotabp:		.word	fotab
alistp:		.word 	alist
rcdtabp:	.word 	rcttab

new_o:
	; r0: current face as number 1-6
	; r1: direction as character for cardinal direction: 'e', 'n', 's', 'w'
	; determines the new orientation of the player
	push	{r4-r12,lr}

	; determine offset of load
	; test for east
	cmp		r1, #0x65 		; e
	it		eq
	moveq	r4, #1			; one byte offset
	beq		foAfter_if

	cmp		r1, #0x73
	it		eq				; s
	moveq	r4, #2			; two byte offset
	beq		foAfter_if

	cmp		r1, #0x6E		; n
	it		eq
	moveq	r4, #3
	beq		foAfter_if

	cmp		r1, #0x77		; w
	ite		eq
	moveq	r4, #4
	movne	r4, #0xFFFF		; should cause a crash if the given character isn't ensw
	
foAfter_if:

	ldr		r5, fotabp		; get the address of the fotab
	mov		r10, r0			; copy	r0 into r10 to preserve it
foOffset_calc:				; nothing should branch to this label, only for debug	
	sub		r10, r10, #1	; to calculate offset, offset = 5*(fid - 1)+dir, where dir is 1,2,3,4 based on cardinal direction and fid is the face id
	mov		r9, #5			; mult can't use immediates
	mla		r4, r10, r9, r4 ; r4 = (r10*r9)+r4
	ldrb	r6, [r5, r4]	; grab table entry
	; return the new face in r0, and the new oreintation in r1
	and		r0, r6, #0x70	; new fid is first 3 bits, ignore all else
	lsr		r0, r0, #4		; shift it by a nibble, so #0x20 -> #0x02
	and		r1, r6, #0x03	; new orientation is last 2 bits

	; just return now
	pop		{r4-r12, lr}
	mov		pc, lr
	

rcd:
	; r0: current character orientation
	; r1: movement, relative directon wasd
	; converts wasd to NSEW, returns in r0 and clears r1
	push	{r4-r12,lr}
	
	

	; offset is based on passed in orientation
	cmp 	r0, #0x0
	it		eq
	moveq	r4, #1
	beq		rcdAfter_if

	cmp 	r0, #0x1
	it		eq
	moveq	r4, #3
	beq		rcdAfter_if

	cmp 	r0, #0x2
	it		eq
	moveq	r4, #0x5
	beq		rcdAfter_if

	cmp 	r0, #0x3
	it		eq
	moveq 	r4, #0x7
	beq		rcdAfter_if

rcdAfter_if:

	ldr		r5, rcdtabp
	ldrb	r6, [r5, r4]	; byte offset is in r4
	; now mask based on direction
	cmp		r1, #0x65		; w - up
	itt		eq
	andeq	r0, r0, #0xC0
	lsreq	r0, r0, #6		; shift right 6 bits to strip nullspace
	beq		rcdAfter_if2

	cmp		r1, #0x73		; a - left
	itt		eq
	andeq	r0, r0, #0x30
	lsreq	r0, r0, #4		; nullspace is 4 this time
	beq		rcdAfter_if2

	cmp		r1, #0x6E
	itt		eq
	andeq	r0, r0, #0x0C
	lsreq	r0, r0, #2		; only 2, next won't need a shift
	beq		rcdAfter_if2

	cmp		r1, #0x77
	it		eq
	andeq	r0, r0, #0x3	; no shift needed
	; why branch lol

rcdAfter_if2:

	; not much to do after this point
	mov		r1, #0			; clear r1
	mov		pc, lr 			; return

set_color:
	; given cell ID in r0
	; given color in r1
	; returns cell in r0
	push	{r4-r12,lr}

	; backup r1
	mov		r4, r1
	bl		get_cell
	; now there's the cell contents in r0
	orr		r0, r0, r4, lsl #12		; this adds the color into the cell contents
	
	ldr		r7, alistp 		; get the pointer to the alist, 
	str		r0, [r7, r1]	; store the modified cell contents in the alist
	; nothing else to do, return
	
	pop		{r4-r12,lr}
	mov		pc, lr

get_color:
	; given cell ID in r0
	; no other registers are important
	; return color in r0
	push	{r4-r12,lr}

	bl		get_cell
	and		r0, r0, #0xF000		; mask for the color
	lsr		r0, #12				; shift back to 1,2,3,4,5,6
	; return
	pop		{r4-r12,lr}
	mov		pc, lr


extract_cid:
	; input:   r0 - given cell index
	; returns: r0 - face, r1 - row, r2 - col
	push	{r4, lr}
	; extract face number first, use div_mod
	mov		r1, #100	; divide by 100, it'll return facenum in r0 and 10*row+col in r1
	bl		div_and_mod
	mov		r4, r0		; backup r0
	mov		r0, r1		; this is the new thing to do divmod on
	mov		r1, #10		; this will extract row and column: row => r0, col => r1
	bl		div_and_mod
	; shuffle values around to get to the desired return structure
	mov		r1, r2		; col should go into r2
	mov		r1, r0		; row should go into r1
	mov		r0, r4		; face number should go into r0
	; now we return
	pop		{r4, lr}
	mov		pc, lr




get_cell:

	; r0 - current cell index
	; r1 - cardinal direction to grab - as 0 - East, 1 - South , 2 - North, 3 - West, Current Cell 
	push	{r4-r12,lr}
	; first we need to calculate the offset
	; formula is: 45*(face-1)+15*row+5*col+(direction+1)
	; first we need to extract face, row, col
	; if dir = 4, return the current cell from the table
	; returns cell contents in r0, offset from alist to get to cell in r1
	mov		r4, r1 		; backup cell direction


	; r11 will be used as the running sum when calculating offset
	cmp		r4, #4
	it		ne
	addne	r11, r4, #1		; turn direction into offset and add it to r11, which is the new offset
	; only do this if the direction is not 4.  This for the internal offset, or offset within the alist to get what things are adjacent to.  4 returns the current cell, which gives access to color

	; if r4 > 4, something has gone horribly wrong.  cause a crash
	it		gt
	moveq	pc, #0x0010		; should crash program
	; some form of screen clear and debug message should go here as well


	bl		extract_cid
	; now we have face in r0, row in r1, col in r2
	; now calculate the formula
	; TODO: verify that this MLA works as intended
	mov		r5, #45		; move for multiplication
	sub 	r0, r0, #1	; face -= 1
	mla		r11, r0, r5, r11 ; r11 *= 45*face + r11

	mov		r5, #15
	mla		r11, r1, r5, r11 ; r11 = r11 + r1*r5

	mov		r5, #5
	mla		r11, r2, r5, r11 ; r11 = r11 + r1*r5


	
	ldr		r5, alistp 		; grab ptr to alist
	ldrh	r0, [r5, r11]	; grab cell contents using the calculated offset
	mov		r1, r11			; return the offset in r1 for set_color


	pop		{r4-r12,lr}
	mov		pc, lr 
