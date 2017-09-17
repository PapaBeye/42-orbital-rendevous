
import time

def writeline(line):
    with open("cmdfifo", "w") as f:
        f.write(line + '\n')
        print('wrote')
        time.sleep(2)

writeline("1.0 c")
writeline("2.0 c")
writeline("3.0 c")
# writeline("4.0 c")
writeline("-1.0 c")
print("done")











