# Adjaceny List

To store what cell is adjacent to what cell, to easily determine what color is an adjacent cell, an adjacency list will be constructed.  

This adjacency list will store the address in memory of each cell that is adjacent to the indexed cell.  For example, if we look to see what's adjacent to cell 500, we would index and find a list that contains the addresses cells 501, 510, 400, and 320.  The order of these is important, as this tells us the cardinal direction you travel to access it.  501 is East, 510 is South, 400 is North, and 320 is West.  

These cardinal projections are based on the orthographic, flattened projection of the Rubiks cube.  Each cell has an identifier of the face number, and cell number.  The player's direction, stored as a byte, will translate it to Up, Down, Left, or Right or w, a, s, d.  To differentiate the abbreviation for South and West versus s and w, cardinal directions will always be capitalized.  

Currently, we are going to store 30 out of the 54 cells.  The reason is because for 24 cells, we don't need to store them and can easily calculate them based on the direction of movement and the current cell's index.  We will call these **In-Face Cells**.  Below is a example of it using face 1:

| 100     | 101     | 102     |
|---------|---------|---------|
| **110** | **111** | **112** |
| **120** | **121** | **122** |

If the current cell is in the format XX0 or XX1, then going East will always result in adding 1 to the cell's index.  120 will become 121, 121 will become 122, etc.  The full list of rules is below:

| XX0/XX1 | X0X/X1X | X2X/X1X | XX0/XX1 | Dir |
|---------|---------|---------|---------|-----|
| +001    | N/A     | N/A     | N/A     | E   |
| N/A     | +010    | N/A     | N/A     | S   |
| N/A     | N/A     | -010    | N/A     | N   |
| N/A     | N/A     | N/A     | -001    | W   |

All other movements will need to be indexed using the adjacency list, but this removes the need to specify 24 cells in the .data section of the assembly program.  Less manual work is better.  The mapping of what cell is adjacent to what will be [in this google sheet.]()
