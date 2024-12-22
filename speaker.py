import serial
import pyaudio

# Configure the serial port
ser = serial.Serial('COM5', 115200, timeout=1)  # Increased baud rate to 115200

# Initialize PyAudio
p = pyaudio.PyAudio()

# Open a stream with the intended sample rate
stream = p.open(format=pyaudio.paUInt8,  # 8-bit samples
                channels=1,
                rate=11520,  # Intended sample rate
                output=True)

# Read and play data live
try:
    print("Starting playback, press Ctrl+C to stop...")
    while True:
        if ser.in_waiting > 0:
            byte = ser.read()
            value = int.from_bytes(byte, byteorder='big')
            if value in [0, 1]:
                # Convert 0/1 to 0/255 and write to stream
                stream.write(bytes([value * 255]))
except KeyboardInterrupt:
    print("Stopping playback...")

# Close the serial port
ser.close()

# Stop and close the stream
stream.stop_stream()
stream.close()

# Terminate PyAudio
p.terminate()