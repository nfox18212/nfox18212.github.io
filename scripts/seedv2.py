#!/usr/bin/env python
import time
import numpy as np

# citing https://www.falatic.com/index.php/108/python-and-bitwise-rotation for bitwise rotations
# (Nathan Fox) I adpated the original lambas into functions. original code in rot.py

def rol(val, r_bits):
    chunk1 = (val << r_bits%MAXB) & (2**MAXB-1) 
    chunk2 = ((val & (2**MAXB-1)) >> (MAXB-(r_bits%MAXB)))
    return chunk1 | chunk2

def ror(val, r_bits):
    chunk1 =  ((val & (2**MAXB-1)) >> r_bits%MAXB)
    chunk2 = (val << (MAXB-(r_bits%MAXB)) & (2**MAXB-1))
    return chunk1 | chunk2

def initColorOrder():
    for i in range(9):
        colorOrder.append(1)

    for i in range(9):
        colorOrder.append(2)

    for i in range(9):
        colorOrder.append(3)

    for i in range(9):
        colorOrder.append(4)

    for i in range(9):
        colorOrder.append(5)

    for i in range(9):
        colorOrder.append(6)

def red(num):
    newnum = num
    while(newnum > 53):
        newnum ^= 0x33
        newnum = newnum >> 1
    return newnum

def swap(idx):

    # make sure index isn't greater than the color list
    idx1 = red(idx)
    idx2 = red(ror(idx, 29))

    # fstr = f"idx1 = {hex(idx)}, idx2 = {hex(idx2)}"
    fstr = f"idx1 = {idx1}, idx2 = {idx2}"
    f.write(fstr+"\n")
    print(fstr)
    color1 = colorOrder[idx1]
    color2 = colorOrder[idx2]

    colorOrder[idx1] = color2
    colorOrder[idx2] = color1

global MAXB
MAXB = 32

seed = 0x5f3759df

global colorOrder
colorOrder : list[int] = []

global f
f = open("scripts/xindices.txt","w")

initColorOrder()

for i in range(1000):
    idx = seed & 0x3F
    swap(idx)

    seed ^= seed >> 7
    seed ^= seed << 13
    seed ^= seed >> 5
    seed ^= seed << 9
    seed &= 0xFFFFFFFF # force it to be 32 bits
    # print(hex(seed))

print(colorOrder)
f.close()
