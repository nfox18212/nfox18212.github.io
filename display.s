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
disp_row_00:    .word    ; .word what?  as is, this won't assemble
disp_row_01:    .word
disp_row_10:    .word

    .text
    .global     display_init
; DISPLAY MATRIX
; the current face will be passed in by r0
; it will output face and orientation in r0 and r1 respectively
display_init:
    ; 

; column reflection subroutine
col_reflection:

; transpose subroutine
transpose_reflection:

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