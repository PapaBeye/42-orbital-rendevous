from threading import Thread
import simcom.camscrape
import simcom.tlmclient


if __name__ == "__main__":
    t1= Thread(target=simcom.camscrape.scrapeloop) #, args=(10,))
    t1.start()
    t2 = Thread(target=simcom.tlmclient.monitor_tlm)  # , args=(10,))
    t2.start()

    t1.join()
    t2.join()


