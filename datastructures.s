
	.data

mats: 		.space 	128 	; matrix storage, size will need to change - sebastien this is yours to implement
adj_list:	.space 	512		; adjacency list, size will need to change

; yes, this is kind of unreadable.  just read the docs, specifically about adjacency list
fotab:		.byte 0x01, .byte 0x60, .byte 0x24, .byte 0x48, .byte 0x5C,
			.byte 0x02, .byte 0x63, .byte 0x35, .byte 0x18, .byte 0x5D,
			.byte 0x03, .byte 0x62, .byte 0x44, .byte 0x28, .byte 0x51,
			.byte 0x04, .byte 0x61, .byte 0x15, .byte 0x34, .byte 0x5F,
			.byte 0x05, .byte 0x10, .byte 0x27, .byte 0x49, .byte 0x2F,
			.byte 0x06, .byte 0x32, .byte 0x25, .byte 0x4B, .byte 0x1C
			.byte 0x00 ; null terminator byte



; up: bits 6,7 - down: bits 4,5 - left: bits 2,3 right: 0,1
; East: 00,  South: 01, North: 10, West: 11
; table that converts relative movement (up, down, left, right) into cardinal directions
rcdTab:	.half 0x00B4, .half 0x012D, .half 0x028B, .half 0x3D2, .byte 0x00 ; null terminator byte

matrix_list:	.word	mats
alist:	.word	adj_list

init_datastructures:

	push	{r4-r12,lr}
	ldr		r4, alist		; first
