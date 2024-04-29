# Movement

The character will move at a rate of two cells per second.  When onto a different face of the cube, the display matrix will pull the adjacent two columns from the new face and display them.  Then, after two game ticks which are half a second have occured, the new face will be fully rendered.

The orientation of the face will be based on the character's orientation, and only the display face's orientation will change.

## Subroutines

**move**:
This subroutine is what actually moves the player.  It does not take in any input, but takes in the player's intended direction of movement from the byte nextMovement, which is declared in handlers.s.  [**UART0_handler**](ints/uart.md) stores the player's next absolute movement as n, s, e, or w.  From these two pieces of information, **move** will calculate the new orientation, using [**new_o**](data/tables.md).  **Move** uses the nextMovement as an input to [**get_cell**](data/alist.md).  This gets us the new cell and new orientation.  Then, it calls [**detect_collision**](board/board.md) to check if the player is allowed to move.  If they are, the movement is committed, playerdata is changed and the subroutine exists.  If the movement is invalid, the subroutine simply exists.  Unfortunately, the number of moves is not tracked.  This was forgotten about.

What this subroutine does track is the action type, atype.  If the player moves onto a new face, atype is set to 2.  Otherwise it is set to 1.  Finally, it sets nextMovement to zero.  When nextMovement is zero, there is no movement pending.

**swap**:
This subroutine is called whenever the player pushes space.  It sets atype to 3.  It calls [**get_color**](data/alist.md) to find the color of the cell the cursor is currently on and sets the cursor's color to that.  It then sets the cell's color to the player's color.  RGB LEDs were not updated to reflect the player's color.
