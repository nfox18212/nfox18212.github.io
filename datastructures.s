
	.data

mats: 		.space 	128 	; matrix storage, size will need to change
adj_list:	.space 	512		; adjacency list, size will need to change

	.text
	.global init_datastructures


matrix_list:	.word	mats
alist:	.word	adj_list

init_datastructures:

	push	{r4-r12,lr}
	ldr		r4, alist		; first
