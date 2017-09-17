import time

import math

import simcom.tlmclient as TC



sc0_pos = [0, 0, 0]
sc0_vel = [0,0,0]
sc1_pos = [0,0,0]
sc1_vel = [0,0,0]
dist = 0.0

while(True):
    # time.sleep(1)

    try:
        (ms, sc0, sc1) = TC.get_tlm_message()
        p0 = sc0['POSITION']
        p1 = sc1['POSITION']
        distance = math.sqrt(pow(p0[0] - p1[0], 2) + pow(p0[1] - p1[1], 2) + pow(p0[2] - p1[2], 2))
        print('Time:(ms) ', ms, " dist: ", distance, sc0['POSITION'], sc1['POSITION'], sc0['VELOCITY'], sc1['VELOCITY'])


    except Exception as e:
        # print(e.args)
        pass







