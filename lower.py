#!/usr/bin/env python

fname = input("Input file name:\n")
f = open(fname,"r")
lines = f.readlines()
numLines = len(lines)


for idx in range(0,numLines-1):
    print(lines[idx].lower())
    lines[idx] = lines[idx].lower()

f.close()
f = open(fname,"w")
f.writelines(lines)
f.close()
