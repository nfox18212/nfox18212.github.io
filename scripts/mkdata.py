#!/usr/bin/env python

dataList = []

for i in range(9):
    dataList.append("0x1,")

for i in range(9):
    dataList.append("0x2,")

for i in range(9):
    dataList.append("0x3,")

for i in range(9):
    dataList.append("0x4,")

for i in range(9):
    dataList.append("0x5,")

for i in range(9):
    dataList.append("0x6,")

beginings = [0,9,18,27,36,45]
endings   = []

for num in beginings:
    endings.append(num + 8)

for i in beginings:
    dataList[i] = "\t\t\t.byte " + dataList[i]

for i in endings:
    dataList[i] = dataList[i].replace(",","") + "\n"

with open("scripts/colorarray.txt", "w") as f:
    f.writelines(dataList)