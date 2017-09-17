#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <pthread.h>
//#include <poll.h>

int BUFF_SIZE = 512;
int QUEUE_SIZE = 32;
char *queue;
char *next_pop;
char *next_push;
pthread_mutex_t lock;

int inc_pop()
{
    pthread_mutex_lock(&lock);
    if (next_pop >= queue + (BUFF_SIZE * QUEUE_SIZE)) {
        next_pop = queue;
    } else {
        next_pop += BUFF_SIZE;
    }
    pthread_mutex_lock(&lock);
}

int inc_push()
{
    pthread_mutex_lock(&lock);
    if (next_push >= queue + (BUFF_SIZE * QUEUE_SIZE)) {
        next_push = queue;
    } else {
        next_push += BUFF_SIZE;
    }
    pthread_mutex_lock(&lock);
}

int is_cmd_avail()
{
    int res;
    pthread_mutex_lock(&lock);
    res = (next_pop == next_push);
    pthread_mutex_lock(&lock);
}

char *next_command()
{
    char *res;
    pthread_mutex_lock(&lock);
    if (next_pop == next_push)
    {
        res =NULL;
    } else {
        res = next_pop;
        next_pop += BUFF_SIZE;
    }
    pthread_mutex_lock(&lock);
    return res;
}



void* worker(void *arg){
    static FILE *CmdFile;
    //static char CmdLine[512];
    char *CmdLine;
    static double CmdTime = 0.0;
    long NewCmdProcessed;
    while (CmdTime >= 0.0) {
        CmdLine = next_push;
        printf("loop a\n");
        //sleep(1);
        CmdFile = fopen("cmdfifo","rt");
        //fgets(CmdLine,512,CmdFile);
        int fd = fileno(CmdFile);

        //fgets(CmdLine,512,CmdFile);
        fgets(CmdLine,BUFF_SIZE,CmdFile);


        sscanf(CmdLine,"%lf",&CmdTime);
        //strcpy(CmdLine,"");
        printf("Cmdtime: %f \n", CmdTime);

        fclose(CmdFile);
        next_push += BUFF_SIZE;
        }
    return NULL;
}



void main(int argc, char **argv)
{
  //printf("CmdInterpreter called");
  pthread_mutex_init(&lock, NULL);
  queue = (char *)malloc(sizeof(char) * BUFF_SIZE * QUEUE_SIZE);
  next_push = queue;
  next_pop = queue;

  pthread_t t;
  pthread_create(&t, NULL, &worker, NULL);

  while(1) {
    printf("mainloop\n");
    sleep(1);
    char *next_cmd = next_command();
    if (next_cmd){
        printf("nextcmd: %s\n", next_cmd);
    }
  }

//  worker();
//  for (int i = 0; i < 3; i++) {
//    printf("%s\n", queue + (BUFF_SIZE * i));
//  }

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
