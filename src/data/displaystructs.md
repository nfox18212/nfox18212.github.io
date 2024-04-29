# Display Structures

To display what the backend has calculated the current state of the game to be. Main routine should be called every tick, or every half second.

There are two main data structures.

**disp_mat**: Stores the encoded state of the display directly before being outputted. 

**adj_mat**: Built to allow separation from past display and incoming display when cube is rotated to a new face.

Each data structure takes up a word and is formatted as so:
![disp_mat](../images/disp_mat.drawio.png)

The three bit color values are the same as the ones used [in the alist docs](./alist.md). The top 4 bits store a value representing the player's position 0-8. 0-2 represent the first row, 3-5 second, and 6-8 third row. For example, if the current displayed face was like so, given bold represents the player's current position:

|           |           |              |
|---------- | --------- | ------------ |
| RED       | RED       | BLUE         |
| CYAN      | BLUE      | MAGENTA      |
| YELLOW    | **GREEN** | RED          |

The hex encoded disp_mat would like like the following:

```arm
.word   0x71334CD4
# 0111 0 001 001 100 110 100 101 011 010 100
```


# Subroutines
**display_init**: Initializes the first matrix to be displayed. Pulls color for given face 1 and inserted them into data structure with player position set to 4, or [1, 1]

**op_cell_row**: Outputs a full row of cells. Takes in three pointers to ansi esc strings with the colors of each cell in the current row. Prints the first layer of the three colors, including sidebars. In a new line, it checks for player position in these given cells. if player exists in the row, that cell will be given the player color during the second layer of printing. The third layer is printed like the first, just filling in the cell's color.

**player_pos**: Takes in row and column of player's current position and returns a number useful for the display, 0-8. For instance, if the player's current position in the backend shows [0, 0], player_pos returns 0. If the player is at [1, 2], player_pos returns 5.

**find_op_color**: Takes in a number 1-6 used in the background and returns a pointer to an ansi esc string representing the corresponding color. This is:
> red:      001
> 
> green:    010
> 
> yellow:   011
> 
> blue:     100
>
> magenta:  101
>
> cyan:     110