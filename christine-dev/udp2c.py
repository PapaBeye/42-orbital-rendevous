import socket                   # Import socket module
import cv2

s = socket.socket()             # Create a socket object
host = socket.gethostname()     # Get local machine name
port = 60000                    # Reserve a port for your service.

s.connect((host, port))
s.send("Hello server!")

with open('received_file.ppm', 'wb') as f:
    print 'file opened'
    while True:
        print('receiving data...')
        data = s.recv(1024)
        img = cv2.imread(data, cv2.IMREAD_COLOR)
        cv2.imshow(data, img)
        cv2.waitKey(0)
        cv2.destroyAllWindows()
 #       print('data=%s', (data))
        if not data:
            break
        # write data to a file
#        f.write(data, "rb")

f.close()
print('Successfully get the file')
s.close()
print('connection closed')