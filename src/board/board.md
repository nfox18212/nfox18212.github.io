# Board

The board is displayed using a display matrix.  This display matrix was partially implemented by Sebastien.  The colors are stored in the [adjacency list](data/alist.md).  Various subroutine interact with the board, changing its state by changing the adjacency list.

# Subroutines

**detect_collisions**:
This subroutine determines if the movement is valid or not.  Using the information passed in of the new cell in r0, the player's color in r1, and returns a 0 or a 1 in r2.  It checks to see if the new cell's color is the same as the player's color that was passed in.  If it is, it returns a 1.  Otherwise, it returns a 0.

**check_board_state**:

This subroutine checks the state of the board.  Essentially, it checks to see if any of the faces are completed and if so, how many, by iterating through every single cell in the cell list and calling [**get_color**](data/alist.md).  It determines the color of the first cell of 9 and checks to see if the next 8 cells all have the same color as the first cell.  If so, it increments the number of completed faces by 1.  Repeat this for the other 5 faces.

After it iterates through the cell list, it 
