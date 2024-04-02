import serial,time
import cv2 as cv
import numpy as np

ser = serial.Serial(
    port='COM8',
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout = None
)

arr = np.array([[1,0,0,0], [1,0,0,0] , [2,0,0,0]])

while 1:
    string=str(ser.readline())
    string_arr = string.split(',')
    print(string_arr)
    if '0' in string_arr[0]:
        arr[0,1] = int(string_arr[1])
        arr[0,2] = int(string_arr[2])
        arr[0,3] = int(string_arr[3].replace("\\r\\n'",''))
    elif '1' in string_arr[0]:
        arr[1,1] = int(string_arr[1])
        arr[1,2] = int(string_arr[2])
        arr[1,3] = int(string_arr[3].replace("\\r\\n'",''))
    else:
        arr[2,1] = int(string_arr[1])
        arr[2,2] = int(string_arr[2])
        arr[2,3] = int(string_arr[3].replace("\\r\\n'",''))
    print(arr)
    time.sleep(1)
    
