import signal
import time

import os
import subprocess




ss_dir = '/home/osboxes/42 20170118/42/Screenshots/'

old_filenames = os.listdir(ss_dir)


args = ['eog', ss_dir + 'CamFrame00026.ppm']
#pro = subprocess.call(args)
#pro = subprocess.Popen(args)
pro = subprocess.Popen(args, stdout=subprocess.PIPE, preexec_fn=os.setsid)
#pro = subprocess.Popen(args, stdout=subprocess.PIPE, shell=True, preexec_fn=os.setsid)
time.sleep(2)
os.killpg(os.getpgid(pro.pid), signal.SIGTERM)

while True:
    print("loop")
    current_filenames = os.listdir(ss_dir)
    new_filenames = []
    for fn in current_filenames:
        if fn not in old_filenames:
            print('appending')
            new_filenames.append(fn)
    for fn in sorted(new_filenames):
        print(fn)

    if new_filenames.__len__() > 1:
        print('Should be displaying')
        #subprocess.call('eog', new_filenames[0])
        args = ['eog', ss_dir + new_filenames[0]]
        pro = subprocess.Popen(args, stdout=subprocess.PIPE, preexec_fn=os.setsid)
        time.sleep(10)
        os.killpg(os.getpgid(pro.pid), signal.SIGTERM)
    old_filenames = current_filenames
    time.sleep(1)
