#!/bin/env python

import numpy as np

def rowReflection(mat):
    shape = np.shape(mat)
    numRows = shape[0] - 1
    numCols = shape[1] - 1
    newMat = np.zeros([3,3])

    for row in range(3):
        for col in range(3):
            newMat[row,col] = mat[numRows - row,col]
    return newMat

def colReflection(mat):
    shape = np.shape(mat)
    numRows = shape[0] - 1
    numCols = shape[1] - 1
    newMat = np.zeros([3,3])

    for row in range(3):
        for col in range(3):
            newMat[row,col] = mat[row,numCols - col]
    return newMat

def tpose(mat):
    shape = np.shape(mat)
    numRows = shape[0] - 1
    numCols = shape[1] - 1
    newMat = np.zeros([3,3])

    for row in range(3):
        for col in range(3):
            newMat[row,col] = mat[col, row]
    return newMat

mat = np.array([
    [100,101,102],
    [110,111,112],
    [120,121,122]
    ])
omat = np.array([
    [100,101,102],
    [110,111,112],
    [120,121,122]
])

print(mat)

mat = tpose(mat)
print(mat)

mat = rowReflection(mat)
print(mat)







