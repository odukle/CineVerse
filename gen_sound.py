import wave
import struct
import math
import os

os.makedirs('assets/sounds', exist_ok=True)

f = wave.open('assets/sounds/dice_shuffle.wav', 'w')
f.setnchannels(1)
f.setsampwidth(2)
f.setframerate(44100)

sr = 44100
dur = 0.35
n = int(sr * dur)

for t in range(n):
    # Dice shuffle: rapid rattling noise with decaying envelope
    freq = 800 + 20 * (t // 1000)
    sample = int(32767 * math.sin(2 * math.pi * freq * t / sr) * math.exp(-t / (sr * 0.08)))
    f.writeframes(struct.pack('<h', sample))

f.close()
print('Generated dice_shuffle.wav')
