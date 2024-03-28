# Data Structures Overview

We will be manually creating multiple data structures and subrotuines to handle these data structures. All of these data structures will be built first before all other subroutines to allow us to work with some level of abstraction.  The two most used datas structures will be Matrices, Adjacency Lists, and Tables.  

Seven matrices will be used, with six of these matrices representing the six faces of the cube.  The seventh matrix will be the display matrix, the only matrix that will actually be rendered.  These matrices will store metadata and data that contain information about the face number, the cell index in row,column format and the color contents of the cell.  

The display matrix will contain the player's avatar, and will be a copy of one of the six face matrices, except with a rotation imposed on it depending on the player's orienation.  To assist with this, three key linear algebra operations will be implemented:  Row Reflection, Column Reflection, and Transposition.  More information can be found in the [Rotation and Player Orientation](board/rot.md) chapter. <!-- This should convert and link to the compiled html page -->

The adjacency list will be a list of addresses to the four cells that any given cell is adjacent to, including the cells that are not being rendered.  This allows for an easy collision check without having to iterate through every cell in every matrix, and an easy access to grab an adjacent cell.

Tables will be used to store the orientation change depending on the the current face and the face that the player is moving to.  It is based on an orthographic projection of the cube, with face 1 being the starting face.

