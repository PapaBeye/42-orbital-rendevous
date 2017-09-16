#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <poll.h>

void main(int argc, char **argv)
{
  //printf("CmdInterpreter called");
  static FILE *CmdFile;
  static char CmdLine[512];
  static double CmdTime = 0.0;
  long NewCmdProcessed;
     while (CmdTime >= 0.0) {
        printf("loop\n");
        sleep(1);
        CmdFile = fopen("cmdfifo","rt");
        //fgets(CmdLine,512,CmdFile);
        int fd = fileno(CmdFile);
        //if (poll(&(struct pollfd){ .fd = fd, .events = POLLIN }, 1, 0)==1) {
            fgets(CmdLine,512,CmdFile);
            sscanf(CmdLine,"%lf",&CmdTime);
        //}

//            if (!strncmp(CmdLine,"EOF",3)) {
//               fclose(CmdFile);
//               //printf("Reached CmdScript EOF at Time = %lf\n",SimTime);
//               //CmdFileActive = 0;
//            }
        printf("Cmdtime: %f \n", CmdTime);
        fclose(CmdFile);
     }
}

