import signal
import subprocess
import simcom.tlmclient

import time
import simcom.imagedistance2

import os

ss_dir = '/home/osboxes/PycharmProjects/42-orbital-rendevous/Screenshots'

old_filenames = os.listdir(ss_dir)

#subprocess.call(['rm', ss_dir + "/CamFrame*"])
#rm /home/osboxes/PycharmProjects/42-orbital-rendevous/Screenshots/CamFrame*


def handle_new_image(ms, path):
    tlm_distance = simcom.tlmclient.latest_distance
    print(ms, " ", path)
    img_distance = simcom.imagedistance2.get_dist_w_fl(path)
    print("Distance comparison: ", tlm_distance, " ", img_distance)



def scrapeloop():
    global ss_dir, old_filenames
    print("Starting scrape loop")
    while True:
        # print("scrape loop")
        current_filenames = os.listdir(ss_dir)
        # print(current_filenames)
        new_filenames = []
        for fn in current_filenames:
            if fn not in old_filenames:
                # print('appending')
                new_filenames.append(fn)
        # for fn in sorted(new_filenames):
        #     print(fn)

        if new_filenames.__len__() > 0:
            print('New filenames: ', new_filenames)
            new_fn = new_filenames[0]
            seconds = int(new_fn[8:14])
            time_ms = 1000 * seconds
            image_path = ss_dir + "/" + new_fn
            # print(time_ms, " ", image_path)
            handle_new_image(time_ms, image_path)

            # # subprocess.call('eog', new_filenames[0])
            # args = ['eog', ss_dir + new_filenames[0]]
            # pro = subprocess.Popen(args, stdout=subprocess.PIPE, preexec_fn=os.setsid)
            # time.sleep(10)
            # os.killpg(os.getpgid(pro.pid), signal.SIGTERM)
        old_filenames = current_filenames
        for new_fn in new_filenames:
            os.remove(ss_dir + "/" + new_fn)
        time.sleep(2)

if __name__ == "__main__":
    scrapeloop()
