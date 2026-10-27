import wave
import struct
import math
import random
import os

SAMPLE_RATE = 22050

def write_wav(filepath, samples):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1) # mono
        wav_file.setsampwidth(2) # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        raw_data = bytearray()
        for s in samples:
            # Clamp to -1.0 to 1.0
            clamped = max(-1.0, min(1.0, s))
            int_val = int(clamped * 32767.0)
            raw_data.extend(struct.pack('<h', int_val))
        wav_file.writeframes(raw_data)
    print(f"Generated {filepath} ({len(samples)} samples)")

def eating_sound():
    duration = 1.1
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # 3 bites: at 0.1s, 0.4s, 0.7s
    bites = [0.1, 0.4, 0.7]
    for b in bites:
        start_idx = int(b * SAMPLE_RATE)
        bite_len = int(0.2 * SAMPLE_RATE)
        for i in range(bite_len):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 28.0)
            # crunch noise + low thud
            noise = (random.random() * 2.0 - 1.0) * 0.6
            thud = math.sin(2 * math.pi * (350 - t * 600) * t) * 0.4
            idx = start_idx + i
            if idx < total_samples:
                samples[idx] += (noise + thud) * env * 0.8
    return samples

def drinking_sound():
    duration = 1.2
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # 3 gulps (gluk gluk gluk)
    gulps = [0.1, 0.45, 0.8]
    for g in gulps:
        start_idx = int(g * SAMPLE_RATE)
        g_len = int(0.22 * SAMPLE_RATE)
        for i in range(g_len):
            t = i / SAMPLE_RATE
            env = math.sin(math.pi * (i / g_len))
            # bubble frequency rising
            freq = 280 + 350 * (t / 0.22)
            sine = math.sin(2 * math.pi * freq * t)
            idx = start_idx + i
            if idx < total_samples:
                samples[idx] += sine * env * 0.75
    return samples

def pee_sound():
    duration = 1.4
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # rushing water flush
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        # Envelope: rise quickly, stay, fade out
        if t < 0.2:
            env = t / 0.2
        elif t > 1.0:
            env = (1.4 - t) / 0.4
        else:
            env = 1.0
        # Water noise with low resonance
        noise = (random.random() * 2.0 - 1.0) * 0.4
        wave_swirl = math.sin(2 * math.pi * (180 + 40 * math.sin(2 * math.pi * 3 * t)) * t) * 0.35
        samples[i] = (noise + wave_swirl) * env * 0.7
    return samples

def poop_sound():
    duration = 1.2
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # water splash "plung splash"
    splash_start = int(0.2 * SAMPLE_RATE)
    splash_len = int(0.8 * SAMPLE_RATE)
    for i in range(splash_len):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 6.0)
        # Drop thud
        thud = math.sin(2 * math.pi * max(80, 500 - t * 900) * t) * 0.5
        noise = (random.random() * 2.0 - 1.0) * (0.5 if t < 0.3 else 0.2)
        idx = splash_start + i
        if idx < total_samples:
            samples[idx] += (thud + noise) * env * 0.8
    return samples

def bath_sound():
    duration = 1.3
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # Rubber duck squeak at 0.1s
    squeak_start = int(0.1 * SAMPLE_RATE)
    squeak_len = int(0.35 * SAMPLE_RATE)
    for i in range(squeak_len):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / squeak_len))
        # Quack-like frequency modulation
        mod = math.sin(2 * math.pi * 25 * t) * 150
        freq = 750 + mod + (120 if t < 0.15 else -100)
        sine = math.sin(2 * math.pi * freq * t)
        samples[squeak_start + i] += sine * env * 0.7
        
    # Splash at 0.5s
    splash_start = int(0.5 * SAMPLE_RATE)
    splash_len = int(0.7 * SAMPLE_RATE)
    for i in range(splash_len):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 5.5)
        noise = (random.random() * 2.0 - 1.0) * 0.45
        bubbles = math.sin(2 * math.pi * (400 + 200 * math.sin(30 * t)) * t) * 0.3
        idx = splash_start + i
        if idx < total_samples:
            samples[idx] += (noise + bubbles) * env * 0.75
    return samples

def brush_teeth_sound():
    duration = 1.3
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # 4 brush strokes: "gosok-gosok"
    strokes = [0.1, 0.38, 0.66, 0.94]
    for s in strokes:
        start_idx = int(s * SAMPLE_RATE)
        stroke_len = int(0.2 * SAMPLE_RATE)
        for i in range(stroke_len):
            t = i / SAMPLE_RATE
            env = math.sin(math.pi * (i / stroke_len))
            noise = (random.random() * 2.0 - 1.0) * 0.5
            sizzle = math.sin(2 * math.pi * 2200 * t) * 0.25
            idx = start_idx + i
            if idx < total_samples:
                samples[idx] += (noise + sizzle) * env * 0.8
    return samples

def wash_hands_sound():
    duration = 1.3
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # Running water tap trickle + bubbles
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        env = min(1.0, t / 0.15) * min(1.0, (1.3 - t) / 0.25)
        noise = (random.random() * 2.0 - 1.0) * 0.35
        trickle = math.sin(2 * math.pi * (800 + 300 * math.sin(12 * math.pi * t)) * t) * 0.25
        samples[i] = (noise + trickle) * env * 0.75
    return samples

def sleep_sound():
    duration = 1.8
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # Music box 4-note lullaby (C5, E5, G5, C6)
    notes = [(0.1, 523.25), (0.5, 659.25), (0.9, 783.99), (1.3, 1046.50)]
    for start_t, freq in notes:
        start_idx = int(start_t * SAMPLE_RATE)
        note_len = int(0.7 * SAMPLE_RATE)
        for i in range(note_len):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 4.5)
            # pure sine + high chime harmonic
            sine = math.sin(2 * math.pi * freq * t) * 0.6 + math.sin(2 * math.pi * freq * 2 * t) * 0.2
            idx = start_idx + i
            if idx < total_samples:
                samples[idx] += sine * env * 0.7
    return samples

def happy_sound():
    duration = 1.3
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # Giggle pulses: hahaha
    giggles = [(0.1, 600), (0.35, 750), (0.6, 900), (0.85, 800)]
    for start_t, freq in giggles:
        start_idx = int(start_t * SAMPLE_RATE)
        g_len = int(0.18 * SAMPLE_RATE)
        for i in range(g_len):
            t = i / SAMPLE_RATE
            env = math.sin(math.pi * (i / g_len))
            # gentle vibrato
            vibrato = math.sin(2 * math.pi * 18 * t) * 40
            sine = math.sin(2 * math.pi * (freq + vibrato) * t) * 0.7
            idx = start_idx + i
            if idx < total_samples:
                samples[idx] += sine * env * 0.75
    return samples

def sad_sound():
    duration = 1.4
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # Soft sniffing + gentle melancholy chime
    # sniff at 0.1
    for i in range(int(0.25 * SAMPLE_RATE)):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / 0.25))
        noise = (random.random() * 2.0 - 1.0) * 0.3
        samples[int(0.1 * SAMPLE_RATE) + i] += noise * env * 0.5
        
    # gentle comforting soft descending tone A4 -> F4 -> E4
    chimes = [(0.4, 440.0), (0.75, 349.23), (1.05, 329.63)]
    for start_t, freq in chimes:
        start_idx = int(start_t * SAMPLE_RATE)
        c_len = int(0.4 * SAMPLE_RATE)
        for i in range(c_len):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 5.0)
            sine = math.sin(2 * math.pi * freq * t) * 0.5
            idx = start_idx + i
            if idx < total_samples:
                samples[idx] += sine * env * 0.6
    return samples

def angry_sound():
    duration = 1.5
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # Calming deep breath: soft inhale, then slow release exhale
    # Inhale (0.1 to 0.6)
    for i in range(int(0.5 * SAMPLE_RATE)):
        t = i / SAMPLE_RATE
        env = (t / 0.5) ** 1.5
        noise = (random.random() * 2.0 - 1.0) * 0.2
        samples[int(0.1 * SAMPLE_RATE) + i] += noise * env * 0.4
        
    # Long calming exhale whoosh (0.65 to 1.45)
    exhale_len = int(0.8 * SAMPLE_RATE)
    for i in range(exhale_len):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / 0.8))
        noise = (random.random() * 2.0 - 1.0) * 0.35
        soft_hum = math.sin(2 * math.pi * 160 * t) * 0.25
        samples[int(0.65 * SAMPLE_RATE) + i] += (noise + soft_hum) * env * 0.5
    return samples

def surprised_sound():
    duration = 1.0
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # "Wah / o-oh" portamento cartoon surprise
    for i in range(int(0.7 * SAMPLE_RATE)):
        t = i / 0.7
        env = math.sin(math.pi * t)
        freq = 300 + 550 * math.sin(math.pi * 0.5 * t)
        sine = math.sin(2 * math.pi * freq * (i / SAMPLE_RATE)) * 0.7
        samples[int(0.15 * SAMPLE_RATE) + i] = sine * env * 0.75
    return samples

def scared_sound():
    duration = 1.5
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # Cartoon heartbeat "lub-dub" at 0.1s and 0.35s
    beats = [0.1, 0.35]
    for b in beats:
        start_idx = int(b * SAMPLE_RATE)
        b_len = int(0.18 * SAMPLE_RATE)
        for i in range(b_len):
            t = i / SAMPLE_RATE
            env = math.sin(math.pi * (i / b_len))
            sub = math.sin(2 * math.pi * 75 * t) * 0.7
            idx = start_idx + i
            if idx < total_samples:
                samples[idx] += sub * env * 0.8
                
    # Reassuring warm harmonic hug chord at 0.7s (C4 - E4 - G4)
    chord_start = int(0.7 * SAMPLE_RATE)
    chord_len = int(0.75 * SAMPLE_RATE)
    for i in range(chord_len):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 3.5)
        ch = (math.sin(2 * math.pi * 261.63 * t) +
              math.sin(2 * math.pi * 329.63 * t) +
              math.sin(2 * math.pi * 392.00 * t)) * 0.25
        idx = chord_start + i
        if idx < total_samples:
            samples[idx] += ch * env * 0.7
    return samples

def love_sound():
    duration = 1.3
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # "Muach" kiss pop at 0.1s
    kiss_len = int(0.2 * SAMPLE_RATE)
    for i in range(kiss_len):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / 0.2))
        freq = 420 + 200 * math.sin(math.pi * (t / 0.2))
        sine = math.sin(2 * math.pi * freq * t) * 0.6
        samples[int(0.1 * SAMPLE_RATE) + i] += sine * env * 0.8
        
    # Sparkling heart twinkle bells at 0.35s
    sparkles = [(0.35, 1318.51), (0.52, 1567.98), (0.7, 1975.53), (0.88, 2637.02)]
    for start_t, freq in sparkles:
        start_idx = int(start_t * SAMPLE_RATE)
        s_len = int(0.4 * SAMPLE_RATE)
        for i in range(s_len):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 6.5)
            sine = math.sin(2 * math.pi * freq * t) * 0.5
            idx = start_idx + i
            if idx < total_samples:
                samples[idx] += sine * env * 0.65
    return samples

def sleepy_sound():
    duration = 1.5
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # Yawn curve "hoaaam" gliding up and descending
    yawn_len = int(1.1 * SAMPLE_RATE)
    for i in range(yawn_len):
        t = i / yawn_len
        env = math.sin(math.pi * t)
        freq = 350 + 250 * math.sin(math.pi * t) - 100 * (t ** 2)
        sine = math.sin(2 * math.pi * freq * (i / SAMPLE_RATE)) * 0.5
        noise = (random.random() * 2.0 - 1.0) * 0.15
        samples[int(0.2 * SAMPLE_RATE) + i] += (sine + noise) * env * 0.7
    return samples

def proud_sound():
    duration = 1.4
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    # Clapping cheering
    claps = [0.1, 0.28, 0.46, 0.64]
    for c in claps:
        start_idx = int(c * SAMPLE_RATE)
        c_len = int(0.12 * SAMPLE_RATE)
        for i in range(c_len):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 25.0)
            noise = (random.random() * 2.0 - 1.0) * 0.6
            idx = start_idx + i
            if idx < total_samples:
                samples[idx] += noise * env * 0.7
                
    # Fanfare triumph chord (C5 - E5 - G5 - C6) at 0.75s
    chord_start = int(0.75 * SAMPLE_RATE)
    chord_len = int(0.65 * SAMPLE_RATE)
    for i in range(chord_len):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 3.5)
        fanfare = (math.sin(2 * math.pi * 523.25 * t) +
                   math.sin(2 * math.pi * 659.25 * t) +
                   math.sin(2 * math.pi * 783.99 * t) +
                   math.sin(2 * math.pi * 1046.50 * t)) * 0.25
        idx = chord_start + i
        if idx < total_samples:
            samples[idx] += fanfare * env * 0.8
    return samples

def main():
    routines = {
        'assets/audio/routines/eating.wav': eating_sound(),
        'assets/audio/routines/drinking.wav': drinking_sound(),
        'assets/audio/routines/pee.wav': pee_sound(),
        'assets/audio/routines/poop.wav': poop_sound(),
        'assets/audio/routines/bath.wav': bath_sound(),
        'assets/audio/routines/brush_teeth.wav': brush_teeth_sound(),
        'assets/audio/routines/wash_hands.wav': wash_hands_sound(),
        'assets/audio/routines/sleep.wav': sleep_sound(),
    }
    for path, data in routines.items():
        write_wav(path, data)

    emotions = {
        'assets/audio/emotions/happy.wav': happy_sound(),
        'assets/audio/emotions/sad.wav': sad_sound(),
        'assets/audio/emotions/angry.wav': angry_sound(),
        'assets/audio/emotions/surprised.wav': surprised_sound(),
        'assets/audio/emotions/scared.wav': scared_sound(),
        'assets/audio/emotions/love.wav': love_sound(),
        'assets/audio/emotions/sleepy.wav': sleepy_sound(),
        'assets/audio/emotions/proud.wav': proud_sound(),
    }
    for path, data in emotions.items():
        write_wav(path, data)

if __name__ == '__main__':
    main()
