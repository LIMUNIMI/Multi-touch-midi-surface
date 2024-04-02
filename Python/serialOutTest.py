import serial,time

ser = serial.Serial(
    port='COM8',
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout = None
)

counter = 0

while True:
    ser.write(counter)
    print(counter)
    counter += 1
    time.sleep(1)