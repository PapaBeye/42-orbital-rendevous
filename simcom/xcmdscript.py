
import time

def writeline(line):
    with open("/home/osboxes/PycharmProjects/42-orbital-rendevous/cmdfifo", "w") as f:
        f.write(line + '\n')
        print('wrote')
        time.sleep(0.1)

def runcmdscript():
    print("trying to write cmds")

    # writeline("0.0 Point SC[0].B[0] Primary Vector [1.0 0.0 0.0] at SC[1]")
    # writeline("0.0 Align SC[0].B[0] Secondary Vector [0.0 1.0 0.0] with L-frame Vector [0.0 1.0 0.0]")
    # writeline("0.0 Point SC[1].B[0] Primary Vector [1.0 0.0 0.0] at SC[0]")
    # writeline("0.0 Align SC[1].B[0] Secondary Vector [0.0 1.0 0.0] with L-frame Vector [0.0 1.0 0.0]")
    # time.sleep(2)
    writeline("")
    time.sleep(1)
    # writeline("150.0 SC[1].Thr[1] TRUE")
    # time.sleep(2)
    # writeline("150.0 SC[1].Thr[1] TRUE")
    # time.sleep(2)
    # writeline("150.0 SC[1].Thr[1] TRUE")
    # writeline("4.0 c")
    #writeline("-1.0 c")
    print("done")

if __name__ == "__main__":
    runcmdscript()