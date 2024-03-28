# Board Layout and Rotation

The board will be laid out in memory using 7 matrices, and an adjacency list. 6 of these matrices represent the 6 faces of the cube.  The final matrix is the display matrix.  A table will represent the imposed rotation when the character moves between faces, if any.  The current character's orientation will be stored as an integer value 0-3, representing a rotation of 90 degrees times the integer value.

Each cell in the matrix will contain the color of that cell.  When we go to display one of the faces, we will copy the matrix we are displaying into the display matrix, and we will preform a composition of reflections and transposition based on the character's orientation.  

