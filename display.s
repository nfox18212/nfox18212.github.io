    .data
    
; background (squares)
redbg:      .string 27,"[48;5;31H"
greenbg:    .string 27,"[48;5;32H"
yellowbg:   .string 27,"[48;5;33H"
bluebg:     .string 27,"[48;5;34H"
magentabg:  .string 27,"[48;5;35H"
cyanbg:     .string 27,"[48;5;36H"

; useful strings for display
topbotbar   .string "+-----------------+", 0xD, 0xA, 0x0
midbar      .string "|-----|-----|-----|", 0xD, 0xA, 0x0
sidebar     .char "|"
timeStr     .string "time:"
movesStr    .string "moves:"
new_line    .string 0xD, 0xA, 0x0
twoSpaces   .string "  "

; following the 4 bit player flag representing cells 0-8, there are 9 sets of 3 bit 
; codes showing the color of each cell
;       001 = RED
;       010 = GREEN
;       011 = YELLOW
;       100 = BLUE
;       101 = MAGENTA
;       110 = CYAN
; initial disp_mat shows player in cell 4 (center), with no colors input yet
disp_mat:       .word 0x0
adj_mat:        .word 0x0

    .global     playerdata
    .global     atype

    .text

    .global 	output_character
    .global		output_string
    .global		get_color
    .global		set_color
    .global		extract_cid

redbgp          .word redbg
greenbgp        .word greenbg
yellowbgp       .word yellowbg
bluebgp         .word bluebg
magentabgp      .word magentabg
cyanbgp         .word cyanbg

playerdatap:    .word playerdata
topbotbarp:		.word topbotbar
sidebarp:       .word sidebar
midbarp:        .word midbar
timeStrp:       .word timeStr
movesStrp:      .word movesStr
disp_matp:      .word disp_mat
adj_matp:       .word adj_mat
atypep:         .word atype
nlp             .word new_line
twoSpacesp      .word twoSpaces

display_init:                       ; creates initial display matrix, player at cell 4
    push    {r4-r12, lr}
    mov		r2, #0x0
    movt	r2, #0x4000				; initial player pos is 4

    ; ROW 0
    mov     r0, #0x0064             ; cell 100
    bl      get_color
    lsl		r0, r0, #24				; left shift to cell 0 position
    orr     r2, r2, r0

    mov     r0, #0x0065             ; cell 101
    bl      get_color
    lsl 	r0, r0, #21				; left shift to cell 1
    orr     r2, r2, r0

    mov     r0, #0x0066             ; cell 102
    bl      get_color
    lsl     r0, r0, #18     		; load disp_matp, offset to cell 2
    orr     r2, r2, r0

    ; ROW 1
    mov     r0, #0x006E             ; cell 102
    bl      get_color
    lsl     r0, r0, #15     		; load disp_matp, offset to cell 2
    orr     r2, r2, r0

    mov     r0, #0x006F             ; cell 102
    bl      get_color
    lsl     r0, r0, #12     		; load disp_matp, offset to cell 2
    orr     r2, r2, r0

    mov     r0, #0x0070             ; cell 102
    bl      get_color
    lsl     r0, r0, #9     		; load disp_matp, offset to cell 2
    orr     r2, r2, r0

    ; ROW 2
    mov     r0, #0x0078             ; cell 102
    bl      get_color
    lsl     r0, r0, #6     		; load disp_matp, offset to cell 2
    orr     r2, r2, r0

    mov     r0, #0x0079             ; cell 102
    bl      get_color
    lsl     r0, r0, #3     		; load disp_matp, offset to cell 2
    orr     r2, r2, r0

    mov     r0, #0x007A             ; cell 102
    bl      get_color
    orr     r2, r2, r0

   	ldr		r1, disp_matp
   	str		r2, r1

    pop     {r4-r12, lr}
    mov     pc, lr

player_pos:                         ; translates player position (r1 row, r2 col) into a value 0-8, return in r1
    push    {r4-r12, lr}
    mov     r4, #0

    cmp     r1, #0
    beq     exit_pos_cond

    cmp     r1, #1
    it      eq
    moveq   r4, #3
    beq     exit_pos_cond

    cmp     r1, #2
    it      eq
    moveq   r4, #6
    beq     exit_pos_cond

exit_pos_cond:
    add     r4, r4, r2
    mov     r0, r4
    pop     {r4-r12, lr}
    bx      lr

find_op_color:                      ; takes in integer at r3, returns pointer to color in r0
    push    {r4-r12, lr}
    cmp     r3, #1                  ; RED
    it      eq
    ldreq   r0, redbgp              ; move red background string into r0
    beq     exit_ansi_cond
    
    cmp     r3, #2                  ; GREEN
    it      eq
    ldreq   r0, greenbgp            ; move red background string into r0
    beq     exit_ansi_cond

    cmp     r3, #3                  ; YELLOW
    it      eq
    ldreq   r0, yellowbgp           ; move red background string into r0
    beq     exit_ansi_cond
    
    cmp     r3, #4                  ; BLUE
    it      eq
    ldreq   r0, bluebgp             ; move red background string into r0
    beq     exit_ansi_cond

    cmp     r3, #5                  ; MAGENTA
    it      eq
    ldreq   r0, magentabgp          ; move red background string into r0
    beq     exit_ansi_cond

    cmp     r3, #6                  ; CYAN
    it      eq
    ldreq   r0, cyanbgp             ; move red background string into r0
    beq     exit_ansi_cond

exit_ansi_cond:
    pop     {r4-r12, lr}
    bx      lr

layer_loop:                         ; takes in color at r0 and prints it 5 times
    push    {r4-r12, lr}
    bl      output_string
    bl      output_string
    bl      output_string
    bl      output_string    
    bl      output_string    
    pop     {r4-r12, lr}
UPDATE_DISPLAY:                     ; TAKE IN ACTION AND ADJUST MATRIX ACCORDINGLY
    push    {r4-12, lr}

    ldr     r4, playerdatap
    and     r0, r4, #0x00FF         ; mask position
    bl      extract_cid             ; returns face (r0), row (r1), col (r2)
    bl      player_pos              ; r1 HOLDS PLAYER POSITION

    ; needs conditional: move or place color? 
place_color:
    ldr     r5, disp_matp           ; load display matrix
    mov     r6, #0xFFFF
    movt    r6, #0xF8FF             ; initial mask 0x1111100011111111 1111111111111111
    bl      get_color               ; r0 HOLDS CELL COLOR

    mov     r7, #3                  ; #3
    mul     r8, r1, r7              ; r1 * 3
    ror     r6, r6, r7              ; rotate mask right by number of cell (r1 * 3)
    and     r5, r5, r6              ; clear those bits

    mov     r9, #8                  ; #8
    sub     r9, r9, r0              ; 8 - r0
    mul     r9, r9, r7              ; (8 - r0) * 3
    lsl     r0, r0, r9              ; left shift r0 by (8 - r0) * 3
    orr     r5, r5, r0              ; insert new color
    str     r5, disp_matp           ; store disp_mat with new color
    
    bl      OUTPUT_SCREEN

same_face:
    ldr     r5, disp_matp           ; input into disp_mat
    mov     r6, #0xFFFF
    movt    r6, #0x07FF             ; initial mask 0x0000011111111111 1111111111111111
    and     r5, r5, r6
    lsl     r1, r1, #28             ; shift position left
    orr     r5, r5, r1              ; insert new player position
    str     r5, disp_matp           ; store disp_mat with new position

    bl      OUTPUT_SCREEN

rotate_anim:                        ; initiates cube rotation
    ; see new face
    ; find what direction
    ; set player pos to 1111 so it doesnt print

anim_loop:                          ; rebuild disp_rows row by row

    ; if counter not equal  to 2, b anim_loop
    ; set player pos to new player pos
    bx      lr

OUTPUT_SCREEN:                      ; print cells to screen with player
    push    {r4-r12, lr}
    ldr     r4, playerdatap
    and     r0, r4, #0x00FF         ; mask position
    bl      extract_cid             ; returns face (r0), row (r1), col (r2)
    bl      player_pos              ; r1 HOLDS PLAYER POSITION
    and     r2, r4, #0xFF000000     ; mask orientation
    ror     r2, r2, #24             ; r2 HOLDS PLAYER'S ORIENTATION

    ldr     r0, nlp             ; print new line
    bl      output_string

    ldr     r0, topbotbarp
    bl      output_string       ; output top bar
    ldr     r0, sidebarp
    bl      output_character    ; output side bar

    mov     r4, #0x0            ; this will be the cell counter
    mov     r5, #0x0            ; this will be the row counter
    mov     r6, #0x0            ; cell 0 color for cur row
    mov     r7, #0x0            ; cell 1 color for cur row
    mov     r8, #0x0            ; cell 2 color for cur row
    mov     r9, #0x0111         ; this will be the mask that is moved around

    ldr     r10, disp_matp     ; we will be extracting from this array

    cmp     r2, #1              
    it      eq                  ; if player is facing east
    lsleq   r9, r9, #18         ; move mask to starting position 2
    beq     east_loop           ; print 90 degrees rotated

    cmp     r2, #2              
    it      eq                  ; if player is facing south
    beq    south_loop           ; print 180 degrees

    cmp     r2, #3
    it      eq                  ; if player facing north
    lsleq   r9, r9, #24         ; move mask to starting position 0
    beq     north_loop          ; print 0 degrees

    cmp     r2, #4
    it      eq                  ; if player facing west
    lsleq   r9, r9, #6          ; move mask to starting position 6
    beq     west_loop           ; print 270 degrees

east_loop:
    ; first three color shifts --> 18, 9, 0
    ; second three color shifts -> 21, 12, 3
    ; third three color shifts --> 24, 15, 6

    mov     r3, #3
    mul     r3, r3, r5          ; (3 * row num (r5))

    ; stores three bit color values in respective registers
    mov     r11, #18
    add     r11, r11, r3        ; base offset + (3 * row num)
    and     r6, r10, r9         ; mask cell 0 color (disp_mat + mask = r6)
    ror     r6, r6, r11         ; store cell 0 color

    mov     r11, #9
    add     r11, r11, r3        ; base offset + (3 * row num)
    ror     r9, r9, #9          ; move mask to next cell
    and     r7, r10, r9         ; mask cell 1 color
    ror     r7, r7, r11         ; store cell 1 color

    mov     r11, #0
    add     r11, r11, r3        ; base offset + (3 * row num)
    ror     r9, r9, #9          ; move mask to next cell
    and     r8, r10, r9         ; store cell 2 color
    ror     r8, r8, r11

    ; replace color vals with pointers to ansi strings
    mov     r3, r6
    bl      find_op_color
    ldr     r6, r0              ; cell 0 pointer to ansi color now in r6
    mov     r3, r7
    bl      find_op_color
    ldr     r7, r0              ; cell 1 pointer to ansi color now in r7
    mov     r3, r8
    bl      find_op_color
    ldr     r8, r0              ; cell 2 pointer to ansi color now in r8        

    ; LAYER ONE
    ldr     r0, r6              ; input for layer_loop
    bl      layer_loop          ; print cell 0 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r7              ; input for layer_loop
    bl      layer_loop          ; print cell 1 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r8              ; input for layer_loop
    bl      layer_loop          ; print cell 2 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string

    ; LAYER TWO    
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ; print cell 0
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r6              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldrne   r0, r6              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    add     r4, r4, #1          ; iterate cell num
    
    ; print cell 1
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldrne   r0, r7              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    add     r4, r4, #1          ; iterate cell num

    ; print cell 2
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r8              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r8              ; print cell color once
    bleq    output_character
    ldrne   r0, r8              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string
    add     r4, r4, #1          ; iterate cell num

    ; LAYER THREE
    ldr     r0, r6              ; input for layer_loop
    bl      layer_loop          ; print cell 0 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r7              ; input for layer_loop
    bl      layer_loop          ; print cell 1 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r8              ; input for layer_loop
    bl      layer_loop          ; print cell 2 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string

    cmp     r5, #2              ; if row = 2, 
    beq     exit_op_loop        ; skip to exit_op_loop 
    add     r5, r5, #1          ; iterate row num
    lsl     r9, r9, #21         ; move mask -21 bits
    ldr     r0, midbarp         ; print midbar
    b       east_loop           ; jump back to east_loop

south_loop:
    ; first three color shifts --> 0, 3, 6         base numbers + (9 * row num (r5))
    ; second three color shifts -> 9, 12, 15
    ; third three color shifts --> 18, 21, 24

    mov     r3, #9
    mul     r3, r3, r5          ; (9 * row num (r5))

    ; stores three bit color values in respective registers
    mov     r11, #0
    add     r11, r11, r3        ; base offset + (9 * row num)
    and     r6, r10, r9         ; mask cell 0 color (disp_mat + mask = r6)
    ror     r6, r6, r11

    mov     r11, #3
    add     r11, r11, r3        ; base offset + (9 * row num)
    lsl     r9, r9, #3          ; move mask to next cell
    and     r7, r10, r9         ; mask cell 1 color
    ror     r7, r7, r11         ; store cell 1 color

    mov     r11, #6
    add     r11, r11, r3        ; base offset + (9 * row num)
    lsl     r9, r9, #3          ; move mask to next cell
    and     r8, r10, r9         ; mask cell 2 color
    ror     r8, r8, #6          ; store cell 2 color

    ; replace color vals with pointers to ansi strings
    mov     r3, r6
    bl      find_op_color
    ldr     r6, r0              ; cell 0 pointer to ansi color now in r6
    mov     r3, r7
    bl      find_op_color
    ldr     r7, r0              ; cell 1 pointer to ansi color now in r7
    mov     r3, r8
    bl      find_op_color
    ldr     r8, r0              ; cell 2 pointer to ansi color now in r8        

    ; LAYER ONE
    ldr     r0, r6              ; input for layer_loop
    bl      layer_loop          ; print cell 0 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r7              ; input for layer_loop
    bl      layer_loop          ; print cell 1 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r8              ; input for layer_loop
    bl      layer_loop          ; print cell 2 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string

    ; LAYER TWO    
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ; print cell 0
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r6              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift    
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldrne   r0, r6              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    add     r4, r4, #1          ; iterate cell num
    
    ; print cell 1
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldrne   r0, r7              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    add     r4, r4, #1          ; iterate cell num

    ; print cell 2
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r8              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r8              ; print cell color once
    bleq    output_character
    ldrne   r0, r8              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string
    add     r4, r4, #1          ; iterate cell num

    ; LAYER THREE
    ldr     r0, r6              ; input for layer_loop
    bl      layer_loop          ; print cell 0 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r7              ; input for layer_loop
    bl      layer_loop          ; print cell 1 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r8              ; input for layer_loop
    bl      layer_loop          ; print cell 2 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string

    cmp     r5, #2              ; if row = 2, 
    beq     exit_op_loop        ; skip to exit_op_loop 
    add     r5, r5, #1          ; iterate row num
    lsl     r9, r9, #3          ; move mask -3 bits
    ldr     r0, midbarp         ; print midbar
    b       south_loop          ; jump back to south_loop

north_loop:
    ; first three color shifts --> 24, 21, 18         base numbers - (9 * row num (r5))
    ; second three color shifts -> 15, 12, 9
    ; third three color shifts --> 6, 3, 0

    mov     r3, #9
    mul     r3, r3, r5          ; (9 * row num (r5))

    ; stores three bit color values in respective registers
    mov     r11, #24
    sub     r11, r11, r3        ; base offset - (9 * row num)
    and     r6, r10, r9         ; mask cell 0 color (disp_mat + mask = r6)
    ror     r6, r6, r11         ; store cell 0 color

    mov     r11, #21
    sub     r11, r11, r3        ; base offset - (9 * row num)
    ror     r9, r9, #3          ; move mask to next cell
    and     r7, r10, r9         ; mask cell 1 color
    ror     r7, r7, r11         ; store cell 1 color

    mov     r11, #18
    add     r11, r11, r3        ; base offset - (9 * row num)
    lsl     r9, r9, #3          ; move mask to next cell
    and     r8, r10, r9         ; mask cell 2 color
    ror     r8, r8, r11         ; store cell 2 color

    ; replace color vals with pointers to ansi strings
    mov     r3, r6
    bl      find_op_color
    ldr     r6, r0              ; cell 0 pointer to ansi color now in r6
    mov     r3, r7
    bl      find_op_color
    ldr     r7, r0              ; cell 1 pointer to ansi color now in r7
    mov     r3, r8
    bl      find_op_color
    ldr     r8, r0              ; cell 2 pointer to ansi color now in r8        

    ; LAYER ONE
    ldr     r0, r6              ; input for layer_loop
    bl      layer_loop          ; print cell 0 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r7              ; input for layer_loop
    bl      layer_loop          ; print cell 1 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r8              ; input for layer_loop
    bl      layer_loop          ; print cell 2 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string

    ; LAYER TWO    
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ; print cell 0
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r6              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldrne   r0, r6              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    add     r4, r4, #1          ; iterate cell num
    
    ; print cell 1
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldrne   r0, r7              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    add     r4, r4, #1          ; iterate cell num

    ; print cell 2
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r8              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r8              ; print cell color once
    bleq    output_character
    ldrne   r0, r8              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string
    add     r4, r4, #1          ; iterate cell num

    ; LAYER THREE
    ldr     r0, r6              ; input for layer_loop
    bl      layer_loop          ; print cell 0 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r7              ; input for layer_loop
    bl      layer_loop          ; print cell 1 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r8              ; input for layer_loop
    bl      layer_loop          ; print cell 2 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string

    cmp     r5, #2              ; if row = 2, 
    beq     exit_op_loop        ; skip to exit_op_loop 
    add     r5, r5, #1          ; iterate row num
    ror     r9, r9, #3          ; move mask +3 bits
    ldr     r0, midbarp         ; print midbar
    b       south_loop          ; jump back to south_loop

west_loop:
    ; first three color shifts --> 6, 15, 24         base numbers - (3 * row num (r5))
    ; second three color shifts -> 3, 12, 21
    ; third three color shifts --> 0, 9, 18

    mov     r3, #3
    mul     r3, r3, r5          ; (3 * row num (r5))

    ; stores three bit color values in respective registers
    mov     r11, #6
    sub     r11, r11, r3        ; base offset - (3 * row num)
    and     r6, r10, r9         ; mask cell 0 color (disp_mat + mask = r6)
    ror     r6, r6, r11         ; store cell 0 color

    mov     r11, #15
    sub     r11, r11, r3        ; base offset - (3 * row num)
    ror     r9, r9, #9          ; move mask to next cell
    and     r7, r10, r9         ; mask cell 1 color
    ror     r7, r7, r11         ; store cell 1 color

    mov     r11, #24
    add     r11, r11, r3        ; base offset - (3 * row num)
    lsl     r9, r9, #9          ; move mask to next cell
    and     r8, r10, r9         ; mask cell 2 color
    ror     r8, r8, r11         ; store cell 2 color

    ; replace color vals with pointers to ansi strings
    mov     r3, r6
    bl      find_op_color
    ldr     r6, r0              ; cell 0 pointer to ansi color now in r6
    mov     r3, r7
    bl      find_op_color
    ldr     r7, r0              ; cell 1 pointer to ansi color now in r7
    mov     r3, r8
    bl      find_op_color
    ldr     r8, r0              ; cell 2 pointer to ansi color now in r8        

    ; LAYER ONE
    ldr     r0, r6              ; input for layer_loop
    bl      layer_loop          ; print cell 0 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r7              ; input for layer_loop
    bl      layer_loop          ; print cell 1 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r8              ; input for layer_loop
    bl      layer_loop          ; print cell 2 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string

    ; LAYER TWO    
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ; print cell 0
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r6              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldrne   r0, r6              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    add     r4, r4, #1          ; iterate cell num
    
    ; print cell 1
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string 
    ldreq   r0, r7              ; print cell color once
    bleq    output_character
    ldrne   r0, r7              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    add     r4, r4, #1          ; iterate cell num

    ; print cell 2
    cmp     r4, r1              
    ite     eq                  ; if player_pos(r1) equal to cell num (r4)
    ldreq   r0, r8              ; print cell color once
    bleq    output_character
    ldreq   r3, playerdatap     ; load playerdata into r3 from r4
    andeq   r3, r3, 0x00FF0000  ; mask color byte
    roreq   r3, r3, #16         ; right shift
    bleq    find_op_color       ; player color from find_op_color to r0
    bleq    output_string       ; print player color 3 times
    bleq    output_string
    bleq    output_string  
    ldreq   r0, r8              ; print cell color once
    bleq    output_character
    ldrne   r0, r8              ; else, 
    blne    layer_loop          ; print cell color five times 
    ldr     r0, sidebarp        ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string
    add     r4, r4, #1          ; iterate cell num

    ; LAYER THREE
    ldr     r0, r6              ; input for layer_loop
    bl      layer_loop          ; print cell 0 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r7              ; input for layer_loop
    bl      layer_loop          ; print cell 1 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character

    ldr     r0, r8              ; input for layer_loop
    bl      layer_loop          ; print cell 2 five times
    mov     r0, sidebar         ; print sidebar
    bl      output_character
    ldr     r0, nlp             ; print new line
    bl      output_string

    cmp     r5, #2              ; if row = 2, 
    beq     exit_op_loop        ; skip to exit_op_loop 
    add     r5, r5, #1          ; iterate row num
    ror     r9, r9, #21          ; move mask +21 bits
    ldr     r0, midbarp         ; print midbar
    b       south_loop          ; jump back to south_loop

bottom_chrome:
    ldr     r0, topbotbarp
    bl      output_string
    ldr     r0, nlp
    bl      output_string

    ; check for anim loop
    ; branch back if needed 

    ldr     r0, timeStrp
    bl      output_string
    ; print time val string
    ldr     r0, twoSpacesp
    bl      output_string
    ldr     r0, movesStrp
    bl      output_string
    ; print move val string

    pop     {r4-r12, lr}
    bx      pc, lr
