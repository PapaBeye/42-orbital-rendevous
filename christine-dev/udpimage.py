
import socket                   # Import socket module

#UDP_IP = "192.168.137.114"
#UDP_PORT = 5005

port = 5005                    # Reserve a port for your service.
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#s = socket.socket()             # Create a socket object
host = "192.168.137.114"     # Get local machine name
s.bind(('', port))            # Bind to the port
s.listen(0)                     # Now wait for client connection.

print 'Server listening....'

while True:
    conn, addr = s.accept()     # Establish connection with client.
    print 'Got connection from', addr
    data = conn.recv(1024)
    print('Server received', repr(data))

    filename='CamFrame1.ppm'
    f = open(filename,'rb')
    l = f.read(1024)
    while (l):
       conn.send(l)
       print('Sent ',repr(l))
       l = f.read(1024)
    f.close()

    print('Done sending')
    conn.send('Thank you for connecting')
    conn.close()