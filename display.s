; COLOR STRINGS

    .data
    
; background (squares)
redbg:      .string 27,"[48;5;31H"
greenbg:    .string 27,"[48;5;32H"
yellowbg:   .string 27,"[48;5;33H"
bluebg:     .string 27,"[48;5;34H"
magentabg:  .string 27,"[48;5;35H"
cyanbg:     .string 27,"[48;5;36H"

; foreground (player)
redfg:      .string 27,"[38;5;31H"
greenfg:    .string 27,"[38;5;32H"
yellowfg:   .string 27,"[38;5;33H"
bluefg:     .string 27,"[38;5;34H"
magentafg:  .string 27,"[38;5;35H"
cyanfg:     .string 27,"[38;5;36H"

; useful strings for display
topbotbar   .string "+-----------------+", 0xD, 0xA, 0x0
midbar      .cstring "-----"
sidebar     .char "|"

; DECLARE DISPLAY MATRIX
; left-most 2 bits keep track of where the player is given he is always on the display.
; 00-10 flag the column he stands in the row, 11 shows he is not in the row.

; following the player flag, the next 7 bits represent the cell a familiar FFFCCRR format.
; 3 bits after that represent the color, so that 0x30 can be added to them easily for ANSI codes
;       001 = RED
;       010 = GREEN
;       011 = YELLOW
;       100 = BLUE
;       101 = MAGENTA
;       110 = CYAN
; P  F  R C CLR F  R C CLR F  R C CLR
; 11 0010000000 0010001000 0010010000
; C    8   0    2   2   0    9   0
; 01 0010100000 0010101000 0010110000
; 4    A   0    2   A   0    B   0
; 11 0011000000 0011001000 0011010000
; C    C   0    3   2   0    D   0
disp_row_00:    .word 0xC8022090
disp_row_01:    .word 0x4A02A0B0
disp_row_10:    .word 0xCC0320D0
disp_row_20: 	.word 0x0
disp_row_02:	.word 0x0


rotated_mat:    .word 0x0

    .global     playerdata

; DISPLAY MATRIX
; the current face will be passed in by r0
; it will output face and orientation in r0 and r1 respectively
; need player position, current face, and orientation


    .text

    .global 	output_character
    .global		output_string
    .global		get_color
    .global		set_color

disp_row_00p:	.word disp_row_00
disp_row_01p:	.word disp_row_01
disp_row_10p:	.word disp_row_10
playerdatap:    .word playerdata
disp_row_20p: 	.word disp_row_20
disp_row_02p:	.word disp_row_02
topbotbarp:		.word topbotbar

; creates initial display matrix
; face 1, orientation 0, player at [1,1]
display_init:
    push    {r4-r12, lr}
    ; ROW 0
    mov     r0, #0x64           ; cell 100
    movt    r0, #0x0
    bl      get_color
    lsl     r0, r0, #20         ; 20 place for col 0 color
    ldr     r2, disp_row_00p
    ldr		r1, [r2, #0]
    orr     r1, r1, r0          ; mask in color
    str     r0, [r2, #0]    ; store color in datastructure

    mov     r0, #0x65           ; cell 101
    movt    r0, #0x0
    bl      get_color
    lsl     r0, r0, #10         ; 10 place for col 1 color
    ldr     r2, disp_row_00p
    ldr		r1, [r2, #0]
    orr     r1, r1, r0          ; mask in color
    str     r0, [r2, #0]     ; store color in datastructure

    mov     r0, #0x66           ; cell 102    
    movt    r0, #0x0
    bl      get_color
    ldr     r2, disp_row_00p
    ldr		r1, [r2, #0]
    orr     r1, r1, r0          ; mask in color
    str     r0, [r2, #0]   ; store color in datastructure

    ; ROW 1
    mov     r0, #0x6E           ; cell 110
    movt    r0, #0x0
    bl      get_color
    lsl     r0, r0, #20         ; 20 place for col 0 color
    ldr     r2, disp_row_01p
    ldr		r1, [r2, #0]
    orr     r1, r1, r0          ; mask in color
    str     r0,[r2, #0]     ; store color in datastructure

    mov     r0, #0x6F           ; cell 111
    bl      get_color
    lsl     r0, r0, #10         ; 10 place for col 1 color
    ldr     r2, disp_row_01p
    ldr		r1, [r2, #0]
    orr     r1, r1, r0          ; mask in color
    str     r0, [r2, #0]     ; store color in datastructure

    mov     r0, #0x70           ; cell 112
    movt    r0, #0x0
    bl      get_color
    ldr     r2, disp_row_01p
    ldr		r1, [r2, #0]
    orr     r1, r1, r0          ; mask in color
    str     r0, [r2, #0]    ; store color in datastructure

    ; ROW 2
    mov     r0, #0x78           ; cell 120
    movt    r0, #0x0
    bl      get_color
    lsl     r0, r0, #20         ; 20 place for col 0 color
    ldr     r2, disp_row_02p
    ldr		r1, [r2, #0]
    orr     r1, r1, r0          ; mask in color
    str     r0, [r2, #0]   ; store color in datastructure

    mov     r0, #0x79           ; cell 121
    movt    r0, #0x0
    bl      get_color
    lsl     r0, r0, #10         ; 10 place for col 1 color
    ldr     r2, disp_row_02p
    ldr		r1, [r2, #0]
    orr     r1, r1, r0          ; mask in color
    str     r0, [r2, #0]    ; store color in datastructure

    mov     r0, #0x7A           ; cell 122   
    movt    r0, #0x0
    bl      get_color
    ldr     r2, disp_row_02p
    ldr		r1, [r2, #0]
    orr     r1, r1, r0          ; mask in color
    str     r0, [r2, #0]     ; store color in datastructure

    pop     {r4-r12, lr}
    mov     pc, lr

; column reflection subroutine
col_reflection:

; transpose subroutine
transpose:

; rotation subroutine
rotate_full:
    ; take in number of rotations
    bl      col_reflection
    bl      transpose
    ; compare number of rotations to 0
    ; if 0, move on
    ; if not, decrement number of rotations


; APPLY PROPER ROTATION AND OUTPUT
output_matrix:
    ; see orientation
    ; call rotation sub
    push    {r0}
    
    ; output top bar
    ldr     r0, topbotbarp
    bl      output_string
    ; carriage return, new line, null



; animate rotation of cube... right, left, up, down
