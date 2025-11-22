import math

SCALE_FACTOR = 30 # lower the more aggresive
OUTPUT_PEAK = 100 # top 8 bits
BITS = 8 


MAX_INDEX = (2**(BITS-1)) - 1

lut = []
for i in range(0, MAX_INDEX+1):
    x = i / SCALE_FACTOR

    y = math.tanh(x) # returns a value between 0 and 1
    y_scaled = int(round(y*OUTPUT_PEAK)) # scales it to actual size

    lut.append(y_scaled)

print("/* TANH LUT */")
print("reg[7:0] tanh_lut[0:255] = '{")

for idx, val in enumerate(lut):
    # Convert signed value to unsigned representation
    if val < 0:
        val = (1 << BITS) + val

    print(f"8'h{idx:02X}: 8'h{val:02X},",end="")

print("\n};")
