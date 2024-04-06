#!/usr/bin/env python

import binascii
import argparse

parser = argparse.ArgumentParser(
    prog="asciitohex",
    description="give me an ascii string and i'll turn it into hex"
)
parser.add_argument('invar')
args = parser.parse_args()

invar = args.invar

if('0x' in invar):
    slic = invar[2:]
    outstr = binascii.unhexlify(slic)
    print(outstr)

else:
    out = args.invar.encode("utf-8").hex()
    outlist = []
    store = 0

    for i in range(len(out)):
        if(i != len(out)-1):
            token = out[i] + out[i+1]
            i = i + 1
            store = store ^ 1
            if(store == 1):
                outlist.append(token)

    for i in range(len(outlist)):
        outlist[i] = '0x' + outlist[i] + ', '

    outlist=''.join(outlist)
    outlist=outlist[0:len(outlist)-2]
    print(outlist)

