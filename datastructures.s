clc .macro
	push	{r0}
	mov		r0, #clear	; form feed
	bl	output_character
	pop		{r0}
	.endm

	.data

mats: 		.space 	128 	; matrix storage, size will need to change - sebastien this is yours to implement

crashstr:	.cstring "In get_cell a direction greater than 4 was specified, crashing program\n"

; yes, this is kind of unreadable.  just read the docs, specifically about adjacency list
fotab:	    ;.byte 0x01, 0x60, 0x24, 0x48, 0x5C
			.byte 0x60, 0x01, 0x48, 0x24, 0x00, 0x5C
			.byte 0x63, 0x02, 0x18, 0x35, 0x00, 0x5D
			.byte 0x62, 0x03, 0x28, 0x44, 0x00, 0x51
			.byte 0x61, 0x04, 0x34, 0x15, 0x00, 0x5F
			.byte 0x10, 0x05, 0x49, 0x27, 0x00, 0x2F
			.byte 0x32, 0x06, 0x4B, 0x25, 0x00, 0x1C
			.byte 0x00 ; null terminator byte
 

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
			.byte 0xF4, 0x01, 0xF5, 0x01, 0xF6, 0x10, 0x90, 0x21, 0x40, 0x31
			.byte 0xF5, 0x01, 0xF6, 0x01, 0xFF, 0x11, 0x9A, 0x21, 0xF4, 0x31
			.byte 0xF6, 0x01, 0x64, 0x00, 0x00, 0x12, 0xA4, 0x21, 0xF5, 0x31
			.byte 0xFE, 0x01, 0xFF, 0x01, 0x08, 0x12, 0xF4, 0x21, 0x36, 0x31
			.byte 0xFF, 0x01, 0x00, 0x02, 0x09, 0x12, 0xF5, 0x12, 0xFE, 0x31
			.byte 0x00, 0x02, 0x6E, 0x00, 0x0A, 0x12, 0xF6, 0x21, 0xF5, 0x31
			.byte 0x08, 0x02, 0x09, 0x02, 0xDC, 0x10, 0xF3, 0x21, 0x2C, 0x31
			.byte 0x09, 0x02, 0x0A, 0x02, 0xD2, 0x10, 0xFF, 0x21, 0x08, 0x32
			.byte 0x0A, 0x02, 0x78, 0x00, 0xC8, 0x10, 0x00, 0x22, 0x09, 0x32
			.byte 0x58, 0x02, 0x59, 0x02, 0x62, 0x12, 0xA6, 0x21, 0x66, 0x30
			.byte 0x59, 0x02, 0x5A, 0x02, 0x63, 0x12, 0x9C, 0x21, 0x58, 0x32
			.byte 0x5A, 0x02, 0x42, 0x01, 0x64, 0x12, 0x92, 0x21, 0x59, 0x32
			.byte 0x62, 0x02, 0x63, 0x02, 0x6C, 0x12, 0x58, 0x22, 0x70, 0x30
			.byte 0x63, 0x02, 0x64, 0x02, 0x6D, 0x12, 0x59, 0x22, 0x64, 0x32
			.byte 0x64, 0x02, 0x38, 0x01, 0x6E, 0x12, 0x5A, 0x22, 0x63, 0x32
			.byte 0x00 ; null byte at end



; up: bits 6,7 - down: bits 4,5 - left: bits 2,3 right: 0,1
; East: 00,  South: 01, North: 10, West: 11
; table that converts relative movement (up, down, left, right) into cardinal directions
rcttab:		.byte 0xB4, 0x00, 0x2D, 0x01, 0x8B, 002, 0xD2, 0x93
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
	.global	output_string ; from library
	.global dirindex
	.global crash

fotabp:		.word	fotab
alistp:		.word 	alist
rcdtabp:	.word 	rcttab
crashstrp:	.word 	crashstr

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
	; set r1 to 4 to specify to get_cell we want exactly cell r0
	mov		r1, #4
	bl		get_cell
	; now there's the cell contents in r0
	orr		r0, r0, r4, lsl #12		; this adds the color into the cell contents
	
	ldr		r7, alistp 		; get the pointer to the alist
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
	mov		r2, r1		; col should go into r2 from r1, r1 => r2
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
	; formula is: 90*(face-1)+30*row+10*col+2*(direction+1)
	; first we need to extract face, row, col
	; if dir = 4, return the current cell from the table
	; returns cell contents in r0, offset from alist to get to cell in r1
	mov		r4, r1 		; backup the direction the character is facing

	bl		extract_cid
	; now we have face in r0, row in r1, col in r2
	; now calculate the formula
	; r6 will be used as the running sum when calculating offset
	; TODO Update: mla works as intended, need to verify the formula is correct
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
	bgt		crash

	
	ldr		r5, alistp 		; grab ptr to alist
	ldrh	r0, [r5, r6]	; grab cell contents using the calculated offset
	mov		r1, r6			; return the offset in r1 for set_color


	pop		{r4-r12,lr}
	mov		pc, lr 



dirindex:
	; leaf routine, takes in character and turns it into the numerical version, or vice versa
	; r0 - input char or num
	
	; cardinal
	cmp		r0, #0 ; e
	itt		eq
	moveq	r0, #0x65
	moveq	pc, lr

	cmp 	r0, #1 ; s
	itt		eq
	moveq	r0, #0x73
	moveq	pc, lr

	cmp		r0, #2 ; n
	itt		eq
	moveq	r0, #0x77
	moveq	pc, lr

	cmp		r0, #3
	itt		eq
	moveq	r0, #0x64
	moveq	pc, lr

	; relative

	cmp		r0, #0x10
	itt		eq
	moveq	r0, #0x61 ; a
	moveq	pc, lr

	cmp		r0, #0x11
	itt		eq
	moveq	r0, #0x73 ; s
	moveq	pc, lr

	cmp		r0, #0x12
	itt		eq
	moveq	r0, #0x77 ; w
	moveq	pc, lr

	cmp		r0, #0x13
	itt		eq
	moveq	r0, #0x64 ; d
	moveq	pc, lr

	cmp 	r0, #0x61 ; a
	itt		eq
	moveq	r0, #10
	moveq	pc, lr

	cmp		r0, #0x73 ; s
	itt		eq
	moveq	r0, #11
	moveq	pc, lr

	cmp		r0, #0x77 ; w
	itt		eq
	moveq	r0, #12
	moveq	pc, lr

	cmp		r0, #0x64 ; d
	itt		eq
	moveq	r0, #13
	moveq	pc, lr

	; cardinal
	cmp		r0, #0x65 ; e
	itt		eq
	moveq	r0, #0
	moveq	pc, lr		; return

	cmp		r0, #0x73 ; s
	itt		eq
	moveq	r0, #1
	moveq	pc, lr

	cmp		r0, #0x6E ; n
	itt		eq
	moveq	r0, #2
	moveq	pc, lr

	cmp		r0, #0x77 ; w
	itt		eq
	moveq	r0, #3
	moveq	pc, lr

	; if its not any of the above stuff, crash
	b		crash

crash:
	; expand to take custom strings?  if so, move to library.s
	; we're not preserving r4-r12 since this is not a subroutine that will be returned from
	; make this code uninterruptible
	; disable timer 0
	mov		r4, #0x0000
	movt	r4, #0x4003
	ldr		r5, [r4, #0xC]
	mov		r6, #0xFFFE
	movt	r6, #0xFFFF
	and		r5, r6, r5
	str		r5, [r4, #0xC]
	

	; disable uart interrupts
	mov 	r1, #0xE000		; e0 base address
	movt 	r1, #0xE000
	ldr 	r0, [r1, #0x100]	; load offset
	mov		r4, #0xFFDF			; 1s cmp of 0x20
	movt	r4, #0xFFFF
	and		r0, r4, #0x20		; set bit 5 to 0
	str 	r0, [r1, #0x100]	; store change

	; disable gpio interrupts
	ldrb	r5, [r4, #0x410]		; store 0 to disable interrupts
	mov		r6, #0xFF10
	movt	r6, #0xFFFF
	and		r5, r5, r6			
	strb	r5, [r4, #0x410]

	ldr		r0, crashstrp	; get string addr
	bl		output_string	; print it

	mov		pc, #0x0010		; should crash program
	; if not, this will
	mov		r12, #0xA
	ldr		r6, [r12, #0]  ; this WILL cause a fault
