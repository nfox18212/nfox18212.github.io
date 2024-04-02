
	.data

mats: 		.space 	128 	; matrix storage, size will need to change
adj_list:	.space 	512		; adjacency list, size will need to change
face_oc:	.space 	512
; up: bits 6,7 - down: bits 4,5 - left: bits 2,3 right: 0,1
; East: 00,  South: 01, North: 10, West: 11
wasdToCard:	.half 0x00B4, .half 

matrix_list:	.word	mats
alist:	.word	adj_list

init_datastructures:

	push	{r4-r12,lr}
	ldr		r4, alist		; first
