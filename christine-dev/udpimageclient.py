import socket                   # Import socket module

s = socket.socket()             # Create a socket object
#s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
host = "192.168.137.233"       # Get local machine name
port = 6000                    # Reserve a port for your service.

s.connect((host, port))
#s.send("Hello server!")
#UDP_IP = "192.168.137.114"
#UDP_PORT = 5005

#sock = socket.socket(socket.AF_INET, # Internet
#                     socket.SOCK_DGRAM) # UDP
#s.bind((host, port))

with open('received_file.ppm', 'wb') as f:
    print 'file opened'
    while True:
        print('receiving data...')
        data = s.recv(1024)
        print('data=%s', (data))
        if not data:
            break
        # write data to a file
        f.write(data)
#        f = open(data, "rb").read()

f.close()
print('Successfully get the file')
s.close()
print('connection closed')