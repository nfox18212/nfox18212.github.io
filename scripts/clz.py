#!/usr/bin/env python

import argparse
import binascii

def clz(num) -> int:
    # counts leading zeros of a 32 bit number
    num32 = num & 0xFFFFFFFF # force num to be 32 bits 
    endbit = 31
    lz = 0

    for bit in range(endbit): # counts backwards
        shift = endbit - bit # number of bits to shift
        mask = 1 << shift 
        
        if(mask & num32 == 0): # if the and result gives a zero, increment leadzing zeros by 1
            lz += 1
        else:
            break # break out of the loop if we ever encounter a 1
    return lz

parser = argparse.ArgumentParser()
parser.add_argument("number", help="number to count the leading zeros of")
args = parser.parse_args()

invar = args.number

num = 0

if('0x' in invar):
    num = int(invar[2:],16)


lz = clz(num)
print(f"there are {lz} leading zeros")