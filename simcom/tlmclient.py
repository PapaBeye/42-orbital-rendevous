import socket

import atexit

IP = '127.0.0.1'
PORT = 42420
BUFFER_SIZE = 1024



samplet = 'TIME  2014-172-01:01:05.000000000\n'
samplevars = 'POSITION  5.687925e+06 -3.137816e+06 0.000000e+00\n'\
    +'VELOCITY  3.746844e+03 6.967456e+03 0.000000e+00\n'\
    +'ANGVEL  -4.951036e-02 -1.895851e-02 1.131146e-02\n'\
    +'QBN  2.697208e-01 1.526913e-01 1.622114e-01 9.368156e-01\n'\
    +'SUNVEC  2.733975e-01 9.522412e-01 -1.359800e-01\n'\
    +'MAGVEC  -2.905525e-06 1.209234e-05 3.249486e-05\n'\
    +'ANGMOM  -4.951036e+00 -3.791701e+00 3.393439e+00\n'

def processmessage(mes):
    lines = mes.split('\n')
    coords = {}
    for line in lines:
        # print("line")
        components = line.split()
        # print(components)
        if components.__len__() == 4:
            comp_arr = [float(components[1]), float(components[2]), float(components[3])]
            coords[components[0]] = comp_arr
        elif components.__len__() == 5:
            comp_arr = [float(components[1]), float(components[2]), float(components[3]), float(components[4])]
            coords[components[0]] = comp_arr
        elif components.__len__() == 2:
            if components[0] == 'TIME':
                time = components[1]
                # print(int(time[9:11]), int(time[12:14]), float(time[15:21]))
                milliseconds = (3600000 * int(time[9:11])) + (60000 * int(time[12:14])) + int(1000.0 * float(time[15:21]))
                # print(seconds)
                #coords[components[0]] = comp_arr
                coords['TIME'] = milliseconds
            elif components[0] == 'SC':
                coords['SC'] = int(components[1])
    # for (key, val) in coords.items():
    #     print(key, ': ', val)
    return coords

# processmessage(samplet + samplevars)



s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((IP, PORT))

atexit.register(s.close)
counter = 0
def get_tlm_message():
    s.send(b'x')
    data = s.recv(BUFFER_SIZE)
    mess = data.decode('utf-8')
    # global counter
    # print(counter, ' raw mess 1: ', mess)
    if (mess.split().__len__() <= 2):
        s.send(b'x')
        data = s.recv(BUFFER_SIZE)
        # print(counter, 'raw mess 2: ', data)
        mess += data.decode('utf-8')
    # print(counter, 'combined message1: ', mess)
    # counter += 1
    return processmessage(mess)

while (True):
    print(get_tlm_message())


# s.close()





