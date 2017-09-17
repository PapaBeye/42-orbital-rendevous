#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
//#include <poll.h>

char *queue = (char *)malloc(sizeof(char) + )
char* next_push = (char *) malloc



void worker(){
  static FILE *CmdFile;
  static char CmdLine[512];
  static double CmdTime = 0.0;
  long NewCmdProcessed;
     while (CmdTime >= 0.0) {
        printf("loop a\n");
        //sleep(1);
        CmdFile = fopen("cmdfifo","rt");
        //fgets(CmdLine,512,CmdFile);
        int fd = fileno(CmdFile);


        //fgets(CmdLine,512,CmdFile);
        fgets(CmdLine,512,CmdFile);

        sscanf(CmdLine,"%lf",&CmdTime);
        //strcpy(CmdLine,"");
        printf("Cmdtime: %f \n", CmdTime);

        fclose(CmdFile);
     }
}
//

void main(int argc, char **argv)
{
  //printf("CmdInterpreter called");
  worker();

}


//  static FILE *CmdFile;
//  static char CmdLine[512];
//  static double CmdTime = 0.0;
//  long NewCmdProcessed;
//     while (CmdTime >= 0.0) {
//        printf("loop a\n");
//        sleep(1);
//        CmdFile = fopen("cmdfifo","rt");
//        //fgets(CmdLine,512,CmdFile);
//        int fd = fileno(CmdFile);
//        //if (poll(&(struct pollfd){ .fd = fd, .events = POLLIN }, 1, 0)==1) {
////        printf("about to get flags\n");
//
////        int flags = fcntl(fd, F_GETFL, 0);
////        fcntl(fd, F_SETFL, flags | O_NONBLOCK);
////        errno = 0;
//
////        fgets(CmdLine,512,CmdFile);
////        printf("about to read\n");
////        size_t chars_read = read(fd, CmdLine, 500);
//        printf("read %d chars\n", (int) chars_read);
////        if (chars_read >= 0) {
//            sscanf(CmdLine,"%lf",&CmdTime);
//            printf("Cmdtime: %f \n", CmdTime);
//
//        }
//    //            if (!strncmp(CmdLine,"EOF",3)) {
//    //               fclose(CmdFile);
//    //               //printf("Reached CmdScript EOF at Time = %lf\n",SimTime);
//    //               //CmdFileActive = 0;
//    //            }
//
//        fclose(CmdFile);
//     }
