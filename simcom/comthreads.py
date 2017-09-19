from threading import Thread

import time

import simcom.camscrape
import simcom.tlmclient
import simcom.xcmdscript

if __name__ == "__main__":
    # simcom.xcmdscript.runcmdscript()
    # time.sleep(5)
    simcom.tlmclient.connect()
    t1= Thread(target=simcom.camscrape.scrapeloop) #, args=(10,))
    t1.start()
    t2 = Thread(target=simcom.tlmclient.monitor_tlm)  # , args=(10,))
    t2.start()

    time.sleep(3)
    simcom.tlmclient.s.send('260.0 CaptureCam TRUE'.encode('utf-8'))
    print("sent command")

    time.sleep(40)
    simcom.tlmclient.s.send('260.0 CaptureCam FALSE'.encode('utf-8'))
    print("sent command")

    t1.join()
    t2.join()


