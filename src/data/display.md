# UPDATE_DISPLAY

After initialization, UPDATE_DISPLAY is used at every tick to update the data stored and display the new, or current, state of the board. It first checks the type of action that was performed. 

If the last action was a move within the same face, disp_mat is updated so that the top 4 bits represent the new player position. If the previous action was to swap colors, then the player color is extracted from playerdata and inserted into the player's current position

If the action was a move onto a new face, adj_mat is build. The algroithm is similar to display_init seen in the [display structures doc](./displaystructs.md), but begins by pulling in the current face from player data, and inserting the colors into adj_mat. disp_mat is then replaced by adj_mat.

OUTPUT_SCREEN is called at the end of this conditional.

# OUTPUT_SCREEN

OUPUT_SCREEN is the final stage of output. It first prints the top/bottom bar, "+-----------------+". After a new line, it prints a side bar "|".

Then the orientation is found. This determines how disp_mat will be iterated through while printing, so that the orientation always points the player's "head" towards the top of the display. Orientation can be 0, 1, 2, 3-- corresponding to how many multiples of 90 degrees CCW they require for relative correction. For more on orientation, see [Rotatation](../board/rot.md) and [Look up tables](./tables.md).

For example, if orientation is 0, disp_mat can be iterated through with bits 26-18 representing cells 0, 1, and 2 of the outputted screen. The three code color values will be passed into [op_cell_row](./displaystructs.md). The mask will then right shift 9 bits to pass the second row of colors into op_cell_row.

The order of output of disp_mat can be visualized like the following:

>Orientation 0
>| |   |   |
>|---|---|---|
>| 1 | 1 | 1 |
>| 2 | 2 | 2 |
>| 3 | 3 | 3 |
>
>This requires a mask of b1111100000000011 1111111111111111. The mask is rotated right 9 >bits after each row is completed.

>Orientation 1
>| |   |   |
>|---|---|---|
>| 3 | 2 | 1 |
>| 3 | 2 | 1 |
>| 3 | 2 | 1 |
>
>This requires a mask of b1111 1 111 111 000 111 111 000 111 111 000. The mask is .>rotated left 3 bits after each row is completed.

>Orientation 2
>| |   |   |
>|---|---|---|
>| 3 | 3 | 3 |
>| 2 | 2 | 2 |
>| 1 | 1 | 1 |
>
>This requires a mask of b1111 1 111 111 111 111 111 111 000 000 000. The mask is >rotated left 9 bits after each row is completed.

>Orientation 3
>| |   |   |
>|---|---|---|
>| 1 | 2 | 3 |
>| 1 | 2 | 3 |
>| 1 | 2 | 3 |
>
>This requires a mask of b1111 1 000 111 111 000 111 111 000 111 111. The mask is >rotated right 3 bits after each row is completed.

After the rows are printed, The top/bottom bar is printed again, and the time and the moves are displayed beneath it.