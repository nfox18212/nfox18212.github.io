
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

; format described in docs
alist:		.half 0x0064, .half 0x0065, .half 0x106E, .half 0x21A4, .half 0x31F6,
			.half 0x0065, .half 0x0066, .half 0x106F, .half 0x21A5, .half 0x3064,
			.half 0x0066, .half 0x0258, .half 0x1070, .half 0x21A6, .half 0x3065,
			.half 0x006E, .half 0x006F, .half 0x1078, .half 0x2064, .half 0x3200,
			.half 0x006F, .half 0x0070, .half 0x1079, .half 0x2065, .half 0x306E,
			.half 0x0070, .half 0x0262, .half 0x107A, .half 0x2066, .half 0x306F,
			.half 0x0078, .half 0x0079, .half 0x10C8, .half 0x206E, .half 0x320A,
			.half 0x0079, .half 0x007A, .half 0x10C9, .half 0x206F, .half 0x307A,
			.half 0x007A, .half 0x026C, .half 0x10CA, .half 0x2070, .half 0x3079,
			.half 0x00C8, .half 0x00C9, .half 0x10D2, .half 0x2078, .half 0x320A,
			.half 0x00C9, .half 0x00CA, .half 0x10D3, .half 0x2079, .half 0x30C8,
			.half 0x00CA, .half 0x026C, .half 0x10D4, .half 0x207A, .half 0x30C9




; up: bits 6,7 - down: bits 4,5 - left: bits 2,3 right: 0,1
; East: 00,  South: 01, North: 10, West: 11
; table that converts relative movement (up, down, left, right) into cardinal directions
rcdTab:	.half 0x00B4, .half 0x012D, .half 0x028B, .half 0x3D2, .byte 0x00 ; null terminator byte

matrix_list:	.word	mats
alist:	.word	adj_list

init_datastructures:

	push	{r4-r12,lr}
	ldr		r4, alist		; first
