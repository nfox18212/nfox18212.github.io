#!/bin/env python

import numpy as np

def rotate(mat, axis, angle):
    # mat is matrix being rotated
    # axis is axis of rotation
    # angle is the degree of movement 
    rot = np.zeros([3,3])

    if(axis == 'x'):
        rot[0,0] = 1
        rot[1,1] = rot[2,2] = np.cos(angle)
        rot[1,2] = -np.sin(angle)
        rot[2,1] = np.sin(angle)
    elif(axis == 'y'):
        rot[0,0] = rot[2,2] = np.cos(angle)
        rot[0,2] = np.sin(angle)
        rot[1,1] = 1
        rot[2,0] = -np.sin(angle)
    elif(axis == 'z'):
        rot[0,0] = rot[1,1] = np.cos(angle)
        rot[0,1] = -np.sin(angle)
        rot[1,0] = np.sin(angle)
    else:
        print("invalid axis dummy")

    return mat @ rot

def rowReflection(mat):
    shape = np.shape(mat)
    numRows = shape[0] - 1
    numCols = shape[1] - 1
    newMat = np.zeros([3,3])

    for row in range(3):
        for col in range(3):
            newMat[row,col] = mat[numRows - row,col]
    return newMat


mat = np.array([
    [1,2,3],
    [4,5,6],
    [7,8,9]
    ])

pi = np.pi
#print(mat)
print(rowReflection(mat))
#print(rotate(mat, 'z', pi/2))
#print(rotate(mat, 'y', pi/2))


