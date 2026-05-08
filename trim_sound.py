import miniaudio
import numpy as np

def trim_silence(input_path, output_path, threshold=500):
    # Load the audio file
    print(f"Loading {input_path}...")
    audio = miniaudio.decode_file(input_path)
    
    # Get raw samples
    samples = np.frombuffer(audio.samples, dtype=np.int16)
    n_channels = audio.nchannels
    sample_rate = audio.sample_rate
    
    # Reshape if multi-channel
    if n_channels > 1:
        samples = samples.reshape(-1, n_channels)
    
    # Calculate energy or absolute max per sample
    if n_channels > 1:
        energy = np.max(np.abs(samples), axis=1)
    else:
        energy = np.abs(samples)
    
    # Find the first index where energy > threshold
    indices = np.where(energy > threshold)[0]
    if len(indices) == 0:
        print("No audio detected above threshold.")
        return
    
    start_index = indices[0]
    # Keep some buffer (e.g. 10ms)
    buffer = int(sample_rate * 0.01)
    start_index = max(0, start_index - buffer)
    
    print(f"Trimming {start_index} samples (approx {start_index/sample_rate:.3f}s)")
    
    # Trimmed samples
    trimmed_samples = samples[start_index:]
    
    # Flatten if multi-channel
    if n_channels > 1:
        trimmed_samples = trimmed_samples.flatten()
    
    # Encode back to mp3 (or wav if mp3 encoding is not supported easily)
    # Actually, miniaudio doesn't encode to mp3 directly.
    # I'll save as WAV first, then maybe the user can use it.
    # Wait, the user wants mp3.
    # If I have pydub, I can save to mp3, but it needs ffmpeg.
    
    # Let's try saving as WAV first and see if that's okay.
    # Or I can try pydub for saving, maybe it will find ffmpeg?
    
    output_wav = output_path.replace(".mp3", ".wav")
    print(f"Saving trimmed audio to {output_wav}...")
    
    with open(output_wav, "wb") as f:
        # Simple WAV header
        import struct
        
        num_samples = len(trimmed_samples)
        num_channels = n_channels
        bits_per_sample = 16
        
        # RIFF header
        f.write(b'RIFF')
        f.write(struct.pack('<I', 36 + num_samples * num_channels * 2))
        f.write(b'WAVE')
        
        # fmt chunk
        f.write(b'fmt ')
        f.write(struct.pack('<I', 16)) # Subchunk1Size
        f.write(struct.pack('<H', 1))  # AudioFormat (PCM)
        f.write(struct.pack('<H', num_channels))
        f.write(struct.pack('<I', sample_rate))
        f.write(struct.pack('<I', sample_rate * num_channels * 2)) # ByteRate
        f.write(struct.pack('<H', num_channels * 2)) # BlockAlign
        f.write(struct.pack('<H', bits_per_sample))
        
        # data chunk
        f.write(b'data')
        f.write(struct.pack('<I', num_samples * num_channels * 2))
        f.write(trimmed_samples.tobytes())

    print("Done!")

if __name__ == "__main__":
    import os
    input_file = r"assets\sounds\dice_shuffle.wav"
    output_file = r"assets\sounds\dice_shuffle_trimmed.wav"
    
    if os.path.exists(input_file):
        trim_silence(input_file, output_file)
    else:
        print(f"File not found: {input_file}")
