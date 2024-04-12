# Adjaceny List

To store what cell is adjacent to what cell, to easily determine what color is an adjacent cell, an adjacency list will be constructed.  

This adjacency list will store the address in memory of each cell that is adjacent to the indexed cell.  For example, if we look to see what's adjacent to cell 500, we would index and find a list that contains the addresses cells 501, 510, 400, and 320.  The order of these is important, as this tells us the cardinal direction you travel to access it.  501 is East, 510 is South, 400 is North, and 320 is West.  

These cardinal projections are based on the orthographic, flattened projection of the Rubiks cube.  Absolute North is equivalent to moving up on Face 1 with zero rotation.  Each cell has an identifier of the face number, and cell number.  The player's direction, stored as a byte, will translate the Up, Down, Left, Right from w, a, s, and d into N, S, E, W using a lookup table.  

Currently, we are going to store 30 out of the 54 cells.  The reason is because for 24 cells, we don't need to store them and can easily calculate them based on the direction of movement and the current cell's index.  We will call these **In-Face Cells**.  Below is a example of it using face 1:

| 100     | 101     | 102     |
| ------- | ------- | ------- |
| **110** | **111** | **112** |
| **120** | **121** | **122** |

If the current cell is in the format XX0 or XX1, then going East will always result in adding 1 to the cell's index.  120 will become 121, 121 will become 122, etc.  The full list of rules is below:

| XX0/XX1 | X0X/X1X | X2X/X1X | XX1/XX2 | Dir |
| ------- | ------- | ------- | ------- | --- |
| +001    | N/A     | N/A     | N/A     | E   |
| N/A     | +010    | N/A     | N/A     | S   |
| N/A     | N/A     | -010    | N/A     | N   |
| N/A     | N/A     | N/A     | -001    | W   |

All other movements will need to be indexed using the adjacency list, but this removes the need to specify 24 cells in the .data section of the assembly program.  Less manual work is better.  The mapping of what cell is adjacent to what will be [in this google sheet.](https://docs.google.com/spreadsheets/d/1lIbhq9RJiK44gera0EY-gOZbGEYBQ-LJChw7v7JewIk/edit?usp=sharing)


## Color

The color is also stored in the alist, but only the indexing cell.  Meaning if you look through the adjacency table for cell 111, the color of cell 111 will be stored at that offset.  As the table is stored in hex, it would look like this if cell 111 was purple:

```arm

.half   0x6F06
```

It is stored this way in memory to account for the little endian architecture.  The largest 3 bits in this index stores the color, and the rest is the cell ID.  

## Subroutines

The following subroutines are availible for the adjacency list: (as of 2024-04-12)

**get_color**: Given an input cell ID in r0, returns the color of that cell in r0.

**set_color**:  Given an input CID in r0 and a color in r1, sets the color of that cell to the color givenn in r1.  Returns the new cell value in r0.

**extract_cid**:  Given a CID, returns the face number in r0, the row number in r1, nad the column number in r2.

**get_cell**:  Given a CID in r0 and a direction in r1, return the given cell from the alist in memory in r0 and the offset it took in r1.  You **must** provide a valid direction (0-4) in r1 or else the subroutine will crash.  Directions: 0 - East, 1 - South, 2 - North, 3 - West, 4 - No movement.  If given 4 in r1, will return the given cell from memory which includes color data.  

**dirindex**:  Given an input ascii character representing a cardinal direction or a number 0-3 that represents a cardinal direction, returns in r0 the character/integer version.