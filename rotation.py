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

def rotate(mat,angle):
    # angle is value 0-3
    newMat = np.zeros([3,3])

    for i in range(angle):
        # print(i)
        if i == 0:
            newMat = tpose(mat)
        else:
            newMat = tpose(newMat)
        newMat = rowReflection(newMat)
        

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

def mprint(i, mat):
    print(f"Matrix rotation of value {i} gives:\n {mat}")

mprint(0,mat)

mat = rotate(omat,1)
mprint(1,mat)

mat = rotate(omat, 2)
mprint(2,mat)

mprint(3, rotate(omat, 3))









