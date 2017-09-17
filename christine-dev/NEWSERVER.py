# ----- sender.py ------

#!/usr/bin/env python

from socket import *
import sys

s = socket(AF_INET,SOCK_DGRAM)
host = "192.168.137.114"
port = 9999
buf =1024
addr = (host,port)

file_name="CamFrame1.ppm"

s.sendto(file_name,addr)

f=open(file_name,"rb")
data = f.read(buf)
while (data):
    if(s.sendto(data,addr)):
        print "sending ..."
        data = f.read(buf)
s.close()
f.close()
