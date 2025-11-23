import numpy as np
import math
import matplotlib.pyplot as plt

SCALE_FACTOR = 40 # lower the more aggresive
OUTPUT_PEAK = 255 # top 8 bits
BITS = 8 


MAX_INDEX = (2**(BITS)-1)
MIN_INDEX = 0

lut = []
x_in = []
y_out1 = []
y_out2 = []
y_out3 = []
for i in range(MIN_INDEX, MAX_INDEX+1):
    x = i
    x_in.append(x)
    y1 = math.tanh(x/20.0)
    y2 = math.tanh(x/40.0)
    y3 = math.tanh(x/80.0)
    y1 = y1*OUTPUT_PEAK
    y2 = y2*OUTPUT_PEAK
    y3 = y3*OUTPUT_PEAK
    y_out1.append(y1)
    y_out2.append(y2)
    y_out3.append(y3)

    lut.append(int(round(y2)))

print("/* TANH LUT */")
print("initial begin")

for idx, val in enumerate(lut):
    # Convert signed value to unsigned representation
    if val < 0:
        val = (1 << BITS) + val
    print(f"    LUT[{idx}] = 8'h{val:02X};")
print("end")

plt.plot(x_in, y_out1, label = "20")
plt.plot(x_in, y_out2, label="40")
plt.plot(x_in, y_out3, label="80")
plt.show()