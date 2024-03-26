# CSE379 - Lab 7

## Nathan Fox and Sebastien Bowen <!-- omit in toc -->

- [CSE379 - Lab 7](#cse379---lab-7)
- [Section 0: Introduction](#section-0-introduction)
- [Section 1: Data Structures](#section-1-data-structures)
  - [Section 1.1: Matrices](#section-11-matrices)
  - [Section 1.2: Adjaceny List](#section-12-adjaceny-list)
- [Section 2: Random Number Generation](#section-2-random-number-generation)
  - [Section 2.1: Timers](#section-21-timers)
  - [Section 2.2: Filling the Board](#section-22-filling-the-board)
- [Section 3: Board Layout and Rotation](#section-3-board-layout-and-rotation)
- [Section 4: Movement](#section-4-movement)
- [Section 5: Pausing](#section-5-pausing)
- [Section 6: mdBook Documentation and GitHub pages](#section-6-mdbook-documentation-and-github-pages)
- [Section 7: Project Layout](#section-7-project-layout)

# Section 0: Introduction

In this document, various examples of code will be done in Python.  The associated git repository will contain a large number of Python files.  This is because we will be sketching out ideas and algorithms in Python before implementing in ARM assembly, due to the ease of testing.

The project will also be stored in multiple files.  data_structures.s will be used to contain all the subroutines and macros for the main file, rng.s will contain the psuedo-random number generation, and library.s will contain all the small, generic and helpful subroutines that were created throughout the semester.

# Section 1: Data Structures

We will be manually creating multiple data structures and subrotuines to handle these data structures.  Nathan Fox will be in charge of implementing these.  

## Section 1.1: Matrices

Multiple linear algebra subroutines will be implented to do basic linear algebra operations.  It will be stored as a contiguous block of memory, but these subroutines will allow us to abstract it away.

### Section 1.1.1: Metadata <!-- omit in toc -->
The specific data type will be stored as "metadata" just before the first cell by pushing forward the offset by 4 bytes.  This gives a word of metadata to store information about what a particular instance of a matrix is used for, such as what face of the Rubiks Cube it represents.

For example, storing a 1 in this metadata will indicate the associated matrix is a matrix of half-words, meaning each cell will contain 2 bytes of data.

All the matrices used will start by using the .space assembler directive to allocate and clear enough memory to store the matrix.

### Section 1.1.2: Indexing <!-- omit in toc -->
An index macro will be implemented to access these matrices by taking in two coordinate values, row and column, and calculating the offset in memory based on that information.  It will read the word of metadata to determine the size of each cell and take that into account when determining the offset.

Once the offset has been determined, it will load one cell of memory into register r0 and return that.

### Section 1.1.3: Reflection and Transposition <!-- omit in toc -->
Clever iterating within a for loop will allow us to do matrix reflections.  Using example in Python for clarity:

~~~python
import numpy as np
def main():
    oldMat = np.array([
        [1,2,3],
        [4,5,6],
        [7,8,9]
    ])
~~~

The standard way to iterate through this matrix with a for loop would be with incrementing rows and incrementing columns.  An example would be copying the old matrix into a new matrix.

```python
    newMat = np.zeros([3,3])

    for row in [0,1,2]:
        for col in [0,1,2]:
            newMat[row][col] = oldMat[row][col]

```

```
newMat = [[1,2,3],[4,5,6],[7,8,9]]
```

Just by changing the order of iteration, we can preform reflections and transposition.  If you start at row 2 and iterate down, you can preform a reflection over row 1.

```python
def rowReflection(mat):
    shape = np.shape(mat)
    numRows = shape[0] - 1
    numCols = shape[1] - 1
    newMat = np.zeros([3,3])

    for row in range(3):
        for col in range(3):
            newMat[row,col] = mat[numRows - row,col]
    return newMat
```
```
newMat = [[7. 8. 9.], [4. 5. 6.], [1. 2. 3.]]
```

This method can also be used to preform column reflections, and transposition.  Composing these operations will allow for rotation.  This will be implemented in ARM using conditionally executing branches.

## Section 1.2: Adjaceny List

To store what cell is adjacent to what cell, to easily determine what color is an adjacent cell, an adjacency list will be constructed.  

This adjacency list will store the address in memory of each cell that is adjacent to the indexed cell.  For example, if we look to see what's adjacent to cell 51, we would index and find a list that contains the addresses cells 52, 54, 41, and 37.  The order of these is important, as this tells us the cardinal direction you travel too access it.  52 is East, 54 is South, 41 is North, and 37 is West.  

These cardinal projections are based on the orthographic, flattened projection of the Rubiks cube.  Each cell has an identifier of the face number, and cell number.  The player's direction, stored as a byte, will translate it to Up, Down, Left, or Right or w, a, s, d.  To differentiate the abbreviation for South and West versus s and w, cardinal directions will always be capitalized.  

# Section 2: Random Number Generation
## Section 2.1: Timers 
To implement random number generation, we are going to use a seed-based approach.  We will use a seperate timer from the game timer to get a seed value, iterating a memory value at a rate of once per nano second.  This rate may change as we do not want to go over the 32 bit integer limit.  

If this does not give a sufficiently good seed value, we can "mess up" the number more by doing multiple bitwise operations, including a variety of shifts and XORs to make the number more unique.  A second timer may also be used that increments a memory value at a different rate to further alter the number.

These timer(s) will increment until a uart interrupt has occured, which will disable the timer interrupt(s).  To faciliate this, the player will be presented a title screen instead of going directly into the game.  Difficulty options will be presented, and as soon as uart recieves user input, the timers will stop and we will be presented with a seed.

## Section 2.2: Filling the Board

Once a seed value has been acquired, we will preform a series of modulous operations using the `div_and_mod` library subroutine to get an index value.  We will be using three index values: one index for determining which face, one for the specific cell in each face, and one for color.  Mod 6, Mod 9, Mod 6.

# Section 3: Board Layout and Rotation

The board will be laid out in memory using 7 matrices, and an adjacency list. 6 of these matrices represent the 6 faces of the cube.  The final matrix is the display matrix.  A table will represent the imposed rotation when the character moves between faces, if any.  The current character's orientation will be stored as an integer value 0-3, representing a rotation of 90 degrees times the integer value.

Each cell in the matrix will contain the color of that cell.  When we go to display one of the faces, we will copy the matrix we are displaying into the display matrix, and we will preform a composition of reflections and transposition based on the character's orientation.  

# Section 4: Movement

The character will move at a rate of two cells per second.  When onto a different face of the cube, the display matrix will pull the adjacent two columns from the new face and display them.  Then, after two game ticks which are half a second have occured, the new face will be fully rendered.

The orientation of the face will be based on the character's orientation, and only the display face's orientation will change.

# Section 5: Pausing

When `sw1` has been hit, the game will go into a blocking loop inside the interrupt after disabling all other interrupts, including the timer.  This will be done using an `eor` instruction and a `beq` instruction.  The board will be replaced with a string that simply says "GAME PAUSED" and this will stay for the duration of the pause.

# Section 6: mdBook Documentation and GitHub pages
All documentation will be hosted on GitHub pages, publically.  The docs will be written in Markdown and built in mdBook.

# Section 7: Project Layout

The project will be split into multiple files, which each file serving a separate purpose.  This is to make it so that the code is easy to read and parse without scrolling through chunks of irrelevant information.