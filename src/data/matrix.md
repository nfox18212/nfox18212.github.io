# Matrices

Multiple linear algebra subroutines will be implented to do basic linear algebra operations.  It will be stored as a contiguous block of memory, but these subroutines will allow us to abstract it away.

## Matrix Metadata 
The specific data type will be stored as "metadata" just before the first cell by pushing forward the offset by 4 bytes.  This gives a word of metadata to store information about what a particular instance of a matrix is used for, such as what face of the Rubiks Cube it represents.

For example, storing a 1 in this metadata will indicate the associated matrix is a matrix of half-words, meaning each cell will contain 2 bytes of data.

All the matrices used will start by using the .space assembler directive to allocate and clear enough memory to store the matrix.

## Indexing 
An index macro will be implemented to access these matrices by taking in two coordinate values, row and column, and calculating the offset in memory based on that information.  It will read the word of metadata to determine the size of each cell and take that into account when determining the offset.

Once the offset has been determined, it will load one cell of memory into register r0 and return that.

## Reflection and Transposition 
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