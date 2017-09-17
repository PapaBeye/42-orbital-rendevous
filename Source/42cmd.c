/*    This file is distributed with 42,                               */
/*    the (mostly harmless) spacecraft dynamics simulation            */
/*    created by Eric Stoneking of NASA Goddard Space Flight Center   */

/*    Copyright 2010 United States Government                         */
/*    as represented by the Administrator                             */
/*    of the National Aeronautics and Space Administration.           */

/*    No copyright is claimed in the United States                    */
/*    under Title 17, U.S. Code.                                      */

/*    All Other Rights Reserved.                                      */


#include "42.h"

//#ifdef __cplusplus
//namespace _42 {
//using namespace Kit;
//#endif


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <time.h>
#include <pthread.h>

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
    pthread_mutex_unlock(&lock);
}

int inc_push()
{
    pthread_mutex_lock(&lock);
    if (next_push >= queue + (BUFF_SIZE * QUEUE_SIZE)) {
        next_push = queue;
    } else {
        next_push += BUFF_SIZE;
    }
    pthread_mutex_unlock(&lock);
}

int is_cmd_avail()
{
    int res;
    pthread_mutex_lock(&lock);
    res = (next_pop == next_push);
    pthread_mutex_unlock(&lock);
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
    pthread_mutex_unlock(&lock);

    if (res) {
        printf("Next command is: %s\n", res);
    }
    else {
//        printf("No next command\n");
    }
    fflush(stdout);
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
        printf("worker loop\n");
        //sleep(1);
        CmdFile = fopen("/home/osboxes/PycharmProjects/42-orbital-rendevous/cmdfifo","rt");
        //fgets(CmdLine,512,CmdFile);
        int fd = fileno(CmdFile);

        //fgets(CmdLine,512,CmdFile);
        fgets(CmdLine,BUFF_SIZE,CmdFile);


        sscanf(CmdLine,"%lf",&CmdTime);
        //strcpy(CmdLine,"");
        printf("Cmdtime: %f \n", CmdTime);

        fclose(CmdFile);
        //next_push += BUFF_SIZE;
        inc_push();
        usleep(100000);
    }
    return NULL;
}


pthread_t cmdthread;
void start_cmd_thread()
{
  //printf("CmdInterpreter called");
  pthread_mutex_init(&lock, NULL);
  queue = (char *)malloc(sizeof(char) * BUFF_SIZE * QUEUE_SIZE);
  next_push = queue;
  next_pop = queue;

  pthread_create(&cmdthread, NULL, &worker, NULL);

//  while(1) {
//    printf("mainloop\n");
//    sleep(1);
//    char *next_cmd = next_command();
//    printf("checked next cmd\n");
//    if (next_cmd){
//        printf("nextcmd: %s\n", next_cmd);
//    }
//  }

}







long FswCmdInterpreter(char CmdLine[512], double *CmdTime);
#ifdef _USE_GUI_
long GuiCmdInterpreter(char CmdLine[512], double *CmdTime);
#endif

/**********************************************************************/
long SimCmdInterpreter(char CmdLine[512],double *CmdTime)
{
      char response[80];
      long NewCmdProcessed = FALSE;
      long Isc;
      double Val;

      if (sscanf(CmdLine,"%lf SC[%ld].RotDOF %s",
         CmdTime,&Isc,response) == 3) {
         NewCmdProcessed = TRUE;
         SC[Isc].RotDOF = DecodeString(response);
      }

      if (sscanf(CmdLine,"%lf DTSIM = %lf",
         CmdTime,&Val) == 2) {
         NewCmdProcessed = TRUE;
         DTSIM = Val;
      }

      return(NewCmdProcessed);
}
/**********************************************************************/
void CmdInterpreter(void)
{
//      printf("CmdInterpeter called\n");
      static FILE *CmdFile;
      //static char CmdLine[512];
      static char* CmdLine;
      static double CmdTime;
      long NewCmdProcessed;
      int command_ready = 0;

      static long First = 1;
      static long CmdFileActive = 1;

      if (First) {
            double ct = 0.0;
            FswCmdInterpreter("0.0 Point SC[0].B[0] Primary Vector [1.0 0.0 0.0] at SC[1]",&ct);
            FswCmdInterpreter("0.0 Align SC[0].B[0] Secondary Vector [0.0 1.0 0.0] with L-frame Vector [0.0 1.0 0.0]",&ct);
            FswCmdInterpreter("0.0 Point SC[1].B[0] Primary Vector [1.0 0.0 0.0] at SC[0]",&ct);
            FswCmdInterpreter("0.0 Align SC[1].B[0] Secondary Vector [0.0 1.0 0.0] with L-frame Vector [0.0 1.0 0.0]",&ct);
      }

      First = 0;


      if (!command_ready) {
         CmdLine = next_command();
         if (CmdLine) {
            printf("Got first command");
            command_ready = 1;
//            First = 0;
         } else {
            return;
         }

//         if (!strcmp(CmdFileName,"NONE"))
//            CmdFileActive = 0;
//         else {
//            CmdFile = FileOpen(InOutPath,CmdFileName,"rt");
//            fgets(CmdLine,512,CmdFile);
//            fgets(CmdLine,512,CmdFile);
//            sscanf(CmdLine,"%lf",&CmdTime);
//            if (!strncmp(CmdLine,"EOF",3)) {
//               fclose(CmdFile);
//               printf("Reached CmdScript EOF at Time = %lf\n",SimTime);
//               CmdFileActive = 0;
//            }
//         }
      }

      while (command_ready && CmdTime <= SimTime) {
            printf("CmdInterpeter loop\n");
         NewCmdProcessed = FALSE;
         /* Look for known command patterns */

         /* Skip Comment Lines */
         if (!strncmp(CmdLine," ",1) ||
             !strncmp(CmdLine,"//",2) ||
             !strncmp(CmdLine,"#",1) ||
             !strncmp(CmdLine,"\n",1) ||
             !strncmp(CmdLine,"%",1)) NewCmdProcessed = TRUE;

         /* Sim Commands */
         else if (SimCmdInterpreter(CmdLine,&CmdTime))
            NewCmdProcessed = TRUE;

         /* Visualization Commands */
         #ifdef _USE_GUI_
            else if (GuiCmdInterpreter(CmdLine,&CmdTime))
               NewCmdProcessed = TRUE;
         #endif

         /* FSW Commands */
         else if (FswCmdInterpreter(CmdLine,&CmdTime))
            NewCmdProcessed = TRUE;

         /* If any match found, get next command */
         if (NewCmdProcessed) {
            printf("%s",CmdLine);
//            fgets(CmdLine,512,CmdFile);
            CmdLine = next_command();
            if (CmdLine) {
                sscanf(CmdLine,"%lf",&CmdTime);
                if (!strncmp(CmdLine,"EOF",3)) {
                   fclose(CmdFile);
                   printf("Reached CmdScript EOF at Time = %lf\n",SimTime);
                   CmdFileActive = 0;
                }
                fflush(stdout);
                command_ready = 1;
            }
            else
            {
                command_ready = 0;
                printf("setting cmd ready to 0");
            }
         }
         if (NewCmdProcessed == FALSE) {
            return;
         }
      }
      printf("CmdInterpreter returned!!!!\n");
      fflush(stdout);
}

//#ifdef __cplusplus
//}
//#endif

