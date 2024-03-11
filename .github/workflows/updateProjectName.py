#!/usr/bin/env python
import argparse

parser = argparse.ArgumentParser(description="Replaces project name with given string")
parser.add_argument("newname")
args = parser.parse_args()

f = open(".project","r")
lines = f.readlines()

targetLine = 0 # starts at 0, we'll update it when we find the correct line

for line in lines:
	if line.find("<name>") != -1 and line.find("</name>") != -1:
		lines[targetLine] = "\t<name>" + args.newname + "</name>\n"
		break
	else:
		targetLine += 1

f.close()
f = open(".project","w")
f.writelines(lines)

