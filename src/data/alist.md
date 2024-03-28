# Adjaceny List

To store what cell is adjacent to what cell, to easily determine what color is an adjacent cell, an adjacency list will be constructed.  

This adjacency list will store the address in memory of each cell that is adjacent to the indexed cell.  For example, if we look to see what's adjacent to cell 500, we would index and find a list that contains the addresses cells 501, 510, 400, and 320.  The order of these is important, as this tells us the cardinal direction you travel to access it.  501 is East, 510 is South, 400 is North, and 320 is West.  

These cardinal projections are based on the orthographic, flattened projection of the Rubiks cube.  Each cell has an identifier of the face number, and cell number.  The player's direction, stored as a byte, will translate it to Up, Down, Left, or Right or w, a, s, d.  To differentiate the abbreviation for South and West versus s and w, cardinal directions will always be capitalized.  
