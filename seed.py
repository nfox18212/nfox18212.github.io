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
            return None

def faceIdx(idx):
    # Expecting a integer input, 100-622
    if(idx < 100 or idx > 622):
        return None
    
    face,temp = divmod(idx, 100)
    row,col = divmod(temp, 10)
    return faceList[face][row][col]

def pickColor(seed):
    face = seed % 6 # picks 0-6

global faceList
global time_now
global colorCount

colorCount = {
    "red" : 0,
    "blue" : 0,
    "orange" : 0,
    "green" : 0,
    "purple" : 0,
    "white" : 0
}

f1 = np.zeros([3,3])
f2 = np.zeros([3,3])
f3 = np.zeros([3,3])
f4 = np.zeros([3,3])
f5 = np.zeros([3,3])
f6 = np.zeros([3,3])
f3[2][0] = 7
faceList = [f1, f2, f3, f4, f5, f6]
time_now = time.time_ns()



print(faceIdx(320))






