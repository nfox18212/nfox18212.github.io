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

def swap(idx):
    idx2 = ror(idx, 0x1D)
    idx1 = idx
    # print(f"idx1 = {hex(idx)}, idx2 = {hex(idx2)}")
    while(idx2 > 0x35):
        idx2 = idx2 ^ 0x33
        idx2 = idx2 >> 1
    # print(f"idx1 = {hex(idx)}, idx2 = {hex(idx2)}")
    color1 = colorOrder[idx1]
    color2 = colorOrder[idx2]

    colorOrder[idx1] = color2
    colorOrder[idx2] = color1

def newSeed(oldSeed):
    period = 0
    lfsr = oldSeed & 0xFFFF # take nibble to improve performance
    target = oldSeed & 0xFFFF
    for _ in iter(int,1):
        lfsr ^= lfsr >> 7
        lfsr ^= lfsr << 9
        lfsr ^= lfsr >> 13
        # lfsr ^= lfsr << 5
        lfsr &= 0xFFFF # make sure its a 16 bit number
        period += 1
        if(lfsr == target):
            break
    
    return period

global MAXB
MAXB = 32

# seed = time.time_ns()
seed = 0x5f3759df

# seed2 = newSeed(seed)
# print(hex(seed2))

global colorOrder
colorOrder : List[int] = []

initColorOrder()

for i in range(1000):
    idx = seed & 0x3F
    # make sure index isn't greater than the color list
    while(idx > 0x35):
        idx = idx ^ 0x33
        idx = idx >> 1

    swap(idx)
    seed ^= seed >> 7
    seed ^= seed << 13
    seed ^= seed >> 5
    seed ^= seed << 9
    seed &= 0xFFFFFFFF
    print(hex(seed))

print(colorOrder)

