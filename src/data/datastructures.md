# Data Structures Overview

We will be manually creating multiple data structures and subrotuines to handle these data structures. All of these data structures will be built first before all other subroutines to allow us to work with some level of abstraction.  The data structures created will be matrices and three lookup tables.

## Matrices

Seven matrices will be used, with six of these matrices representing the six faces of the cube.  The seventh matrix will be the display matrix, the only matrix that will actually be rendered.  These matrices will store metadata and data that contain information about the face number, the cell index in row,column format and the color contents of the cell.  

The display matrix will contain the player's avatar, and will be a copy of one of the six face matrices, except with a rotation imposed on it depending on the player's orienation.  To assist with this, three key linear algebra operations will be implemented:  Row Reflection, Column Reflection, and Transposition.  More information can be found in the [Rotation and Player Orientation](board/rot.md) chapter. <!-- This should convert and link to the compiled html page -->

## Lookup Tables

Three lookup tables will be created to simplify the logic: the Adjacency List (a-list), the Face Orientation table (foTab), and the Relative to Cardinal Direction table (rcdTab).  Important information will be stored in these tables, and multiple subroutines will be written to access the data in them.  Details about the latter two tables are described [here](./tables.md).

### Adjacency List

The a-list is a lookup table that specifies what each cell is adjacent to.  There will always be four other cells that are adjacent to the current cell, one for each of the cardinal directions.  The direction is specified both within the assembly implementation of it, and in the pattern.  The pattern used through is East-South-North-West.  So if you go to Cell ID 400 and go to offset 4, you will be looking for the cell to the West of Cell 400.  Details of implementation will be [here](./alist.md).

### Face Orientation Table

The foTab is a lookup table that tells you what the player's new orientation will be given the current face and the move the player is moving to.  For example, if the player is on Face 2 and moves to Face 6, the player will experience a rotation of 270 degrees.  This table is based off of the orthographic projection of the cube and is easiest to understand if you have a physical object such as a Rubik's cube to mimic the rotation change.  More details are found in [the rotation section](../board/rot.md).  

### Relative to Cardinal Direction Table.

The rcdTable is a lookup table that converts relative directions to the absolute, cardinal directions.  Relative directions are what the player inputs, up down left right from the w, a, s, and d keys.  Because what cell the player will move to when inputting a direction will change based on orientation, having some form of absolute direction to use as a stable index is vital.  

## Cells


The cells table is a list of every cell ID in the adjacency list, in order.  There are no associated subroutines that manipulate it directly, but it is used by the routine to fill the board with random colors.

## Player Data

This is a word stored in memory declared in lab_7.s.  It contains basic information about the state of the player.  The most-significant byte contains the player's orientation; the second most significant byte contains the player's current color; and the last two bytes contain the player's current position as a cell ID.
