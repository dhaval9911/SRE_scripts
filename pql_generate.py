#!/usr/bin/env python3

import sys

if (len(sys.argv) != 4):
    print("Please provide input arguments for: max split, input filename, output filename.")
    exit(0)

num = int(sys.argv[1])
ifilen = sys.argv[2]
ofilen = sys.argv[3]

print("Splitting by: " + str(num))
print("Reading from: " + ifilen)
print("Outputting to: " + ofilen)

ifile = open(ifilen, "r")
ofile = open(ofilen, "w")
lines = ifile.readlines()
isFirst = True

pql = "nodes { certname in ["
count = 0
gcount = 0

for line in lines:
    line = line.strip()
    if (isFirst):
        isFirst = False
    else:
        count += 1
        if (count % num == 0):
            gcount += 1
            pql += line + "]}"
            ofile.write(pql+"\n\n")
            pql = "nodes { certname in ["
        else:
            pql += line + ","

if (count % num != 0):
    gcount += 1
    pql = pql[:-1] + "]}"
    ofile.write(pql+"\n\n")

ofile.close()
print()
print(str(count) + " instances")
print(str(gcount) + " batches")
