import time
import numpy as np

def colorIdx(idx):
    # idx is 0-5
    ret = ""
    match idx:
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
            ret = None
    if(colorCount[ret] > 9):
        return None
    
    colorCount[ret] = colorCount[ret] + 1
    return ret

def faceIdx(idx):
    # Expecting a integer input, 100-622
    if(idx < 100 or idx > 622):
        return None
    
    face,temp = divmod(idx, 100)
    row,col = divmod(temp, 10)
    return faceList[face][row][col]

def pickColor(seed):
    idx = 0
    contents = 0
    while(contents == 0):
        (newSeed,face) = divmod(seed,6) # picks 0-6
        (newSeed,row) = divmod(newSeed, 3)
        (newSeed,col) = divmod(newSeed, 3)
        idx = 100*face + 10*row + col
        (newSeed,color) = divmod(newSeed, 6)
        color = colorIdx(color)
        newSeed = newSeed << 4
        contents = faceIdx(idx)
        if(contents == 0):
            faceList[face][row][col] = colorDict[color]
            break
        else:
            continue

    print(f"idx={idx},seed={newSeed}, contents={contents}")
    # seed = (seed) ^ (seed >> 4)    
    return seed

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

for i in range(54):
    seed = pickColor(seed)

for face in faceList:
    print(face)








