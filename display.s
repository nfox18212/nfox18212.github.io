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
topbotbar   .string "+-----------------+"
midbar      .string "-----"
sidebar     .string "|"

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

; DISPLAY MATRIX
; the current face will be passed in by r0
; it will output face and orientation in r0 and r1 respectively

; creates initial display matrix
display_init:
    


; column reflection subroutine
col_reflection:

; transpose subroutine
transpose:

; rotation subroutine
rotate_full:
    ; take in number of rotations
    bl col_reflection
    bl transpose
    ; compare number of rotations to 0
    ; if 0, move on
    ; if not, decrement number of rotations


; APPLY PROPER ROTATION AND OUTPUT
output_matrix:
    ; see orientation
    ; call rotation sub



; animate rotation of cube... right, left, up, down
