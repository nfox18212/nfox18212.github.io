import time
import numpy as np

def colorIdx(cidx):
    # color index, its a number from 0-5
    ret = ""
    match cidx:
        case 0:
            ret = "red"
        case 1:
            ret = "blue"
        case 2:
            ret = "orange"
        case 3:
            ret = "green"
        case 4:
            ret = "purple"
        case 5:
            ret = "white"
        case _:
            raise RuntimeError # should crash
    if(colorCount[ret] >= 9):
        raise NameError("Color Full")
    
    colorCount[ret] = colorCount[ret] + 1
    return ret

def faceIdx(idx):
    # Expecting a integer input, 100-622
    if(idx < 100 or idx > 622):
        raise NameError("Invalid Index")
    
    face,temp = divmod(idx, 100)
    row,col = divmod(temp, 10)
    face -= 1 # face is 1 greater than the index, handle it
    return faceList[face][row][col]

def isFull():
    totalColors = colorCount["red"]
    totalColors += colorCount["blue"]
    totalColors += colorCount["orange"]
    totalColors += colorCount["green"]
    totalColors += colorCount["purple"]
    totalColors += colorCount["white"]

    print(colorCount)

    if(totalColors >= 54):
        return True
    else:
        return False

def colors():
    retlist = []
    retlist.append(colorCount["red"])
    retlist.append(colorCount["blue"])
    retlist.append(colorCount["orange"])
    retlist.append(colorCount["green"])
    retlist.append(colorCount["purple"])
    retlist.append(colorCount["white"])
    return retlist

def pickColor(seed):
    idx = 0
    contents = 0
    newSeed = 0
    for _ in iter(int, 1):
        if(newSeed == 0):
            newSeed = seed
        (newSeed,face) = divmod(newSeed,6) # picks 0-5
        face += 1 # face should go from 1-6
        (newSeed,row) = divmod(newSeed, 3)
        (newSeed,col) = divmod(newSeed, 3)
        idx = ((100*face) + (10*row)) + col
        (newSeed,color) = divmod(newSeed, 6)
        newSeed = newSeed << 8
        try:
            color = colorIdx(color)
        except NameError:
            # if we enter this except, we need to pick a different color
            # print("Tried to use filled color")
            if(isFull):
                return newSeed
            newSeed = (newSeed ^ seed) << 4 # make seed messier
            continue

        
        contents = faceIdx(idx)
        if(contents == 0):
            faceList[face-1][row][col] = colorDict[color]
            contents = faceList[face-1][row][col]
            break
        else:
            continue

    print(f"idx={idx},seed={newSeed}, filled face = {faceList[face-1]}")
    # seed = (seed) ^ (seed >> 4)    
    return newSeed

global faceList
global time_now
global colorCount
global colorDict

colorCount = {
    "red" : 0,
    "blue" : 0,
    "orange" : 0,
    "green" : 0,
    "purple" : 0,
    "white" : 0
}

colorDict = {
    "red" : 1,
    "blue" : 2,
    "orange" : 3,
    "green" : 4,
    "purple" : 5,
    "white" : 6
}

f1 = np.zeros([3,3])
f2 = np.zeros([3,3])
f3 = np.zeros([3,3])
f4 = np.zeros([3,3])
f5 = np.zeros([3,3])
f6 = np.zeros([3,3])
f3[2][0] = 7
faceList = [f1, f2, f3, f4, f5, f6]
seed = time.time_ns()
 


for _ in iter(int, 1): # spin forever
    seed = pickColor(seed)
    if(isFull()):
        break

# TODO: Finish writing the algorithm for seeds

for face in faceList:
    print(face)








