import math

BITS = 8
index = 256
# each index represent the top 8 bits
LUT = []
for i in range(0,index-1):
    angle = 2*math.pi * (i/index) #256 is full cycle
    y = math.sin(angle)

    y = int(round(y * 32767))

    if y < 0:
        y = (1<<16) + y #twos complement

    y = int(y)
    LUT.append(y) # should store output of sine

print("initial begin")
for i in range (0,index-1):
    print(f"LUT[{i}] = 16'h{LUT[i]:04X};")
print("end")