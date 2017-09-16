
import time

def writeline(line):
    with open("cmdfifo", "w") as f:
        f.write(line + '\n')
        print('wrote')
        time.sleep(3)

writeline("1.0")
writeline("2.0")
writeline("3.0")
writeline("-1.0")
print("done")











