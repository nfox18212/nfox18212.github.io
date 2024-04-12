#!/usr/bin/env python

dataList = []

with open("scripts/alist.txt","r") as f:
    lines = f.readlines()
    for line in lines:
        line = line.replace(".byte", "").strip()
        line = line.split(", ")
        # print(line)
        dataList.append(line[0]+", "+line[1]+", ")

    f.close()

    longth = len(dataList)-1
    print(longth)
    dataList[longth] = dataList[longth].replace(",","")
    dataList[0] = "cells:\t\t.byte " + dataList[0]

with open("scripts/cells.txt", "w") as f:
    f.writelines(dataList)
