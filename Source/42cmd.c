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
ssize_t dummy_recv(char *cmd) {
    strcpy(cmd, "#150.0 CaptureCam TRUE");
    return 0;
}

long HandleCommand(double CmdTime, char *CmdLine) {
         long NewCmdProcessed = FALSE;
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

         return NewCmdProcessed;
}



void SocketCmdInterpreter(void)
{
    //printf("SocketCmdInterpreter\n");
      static char CmdLine[512];
      static double CmdTime;
      long NewCmdProcessed;

      static long size_recvd = 0;

      if (size_recvd <= 0) {
         size_recvd = RecvCommand(CmdLine);
//         size_recvd = dummy_recv(CmdLine);
         if (size_recvd > 0) {
            sscanf(CmdLine,"%lf",&CmdTime);
         }
      }

      while (CmdTime <= SimTime && size_recvd > 0) {
        //printf("recv loop\n");
//         NewCmdProcessed = FALSE;
//         /* Look for known command patterns */
//
//         /* Skip Comment Lines */
//         if (!strncmp(CmdLine," ",1) ||
//             !strncmp(CmdLine,"//",2) ||
//             !strncmp(CmdLine,"#",1) ||
//             !strncmp(CmdLine,"\n",1) ||
//             !strncmp(CmdLine,"%",1)) NewCmdProcessed = TRUE;
//
//         /* Sim Commands */
//         else if (SimCmdInterpreter(CmdLine,&CmdTime))
//            NewCmdProcessed = TRUE;
//
//         /* Visualization Commands */
//         #ifdef _USE_GUI_
//            else if (GuiCmdInterpreter(CmdLine,&CmdTime))
//               NewCmdProcessed = TRUE;
//         #endif
//
//         /* FSW Commands */
//         else if (FswCmdInterpreter(CmdLine,&CmdTime))
//            NewCmdProcessed = TRUE;
         NewCmdProcessed = HandleCommand(CmdTime, CmdLine);
         /* If any match found, get next command */
         if (NewCmdProcessed) {
            printf("Executed Command: %s",CmdLine);
            size_recvd = RecvCommand(CmdLine);
//            size_recvd = dummy_recv(CmdLine);
            if (size_recvd > 0) {
                sscanf(CmdLine,"%lf",&CmdTime);
            }
            fflush(stdout);
         }
      }
}

void CmdInterpreter(void)
{
      static FILE *CmdFile;
      static char CmdLine[512];
      static double CmdTime;
      long NewCmdProcessed;

      static long First = 1;
      static long CmdFileActive = 1;

      if (First) {
         First = 0;
         if (!strcmp(CmdFileName,"NONE"))
            CmdFileActive = 0;
         else {
            CmdFile = FileOpen(InOutPath,CmdFileName,"rt");
            fgets(CmdLine,512,CmdFile);
            fgets(CmdLine,512,CmdFile);
            sscanf(CmdLine,"%lf",&CmdTime);
            if (!strncmp(CmdLine,"EOF",3)) {
               fclose(CmdFile);
               printf("Reached CmdScript EOF at Time = %lf\n",SimTime);
               CmdFileActive = 0;
            }
         }
      }

      while (CmdTime <= SimTime && CmdFileActive) {
//         NewCmdProcessed = FALSE;
//         /* Look for known command patterns */
//
//         /* Skip Comment Lines */
//         if (!strncmp(CmdLine," ",1) ||
//             !strncmp(CmdLine,"//",2) ||
//             !strncmp(CmdLine,"#",1) ||
//             !strncmp(CmdLine,"\n",1) ||
//             !strncmp(CmdLine,"%",1)) NewCmdProcessed = TRUE;
//
//         /* Sim Commands */
//         else if (SimCmdInterpreter(CmdLine,&CmdTime))
//            NewCmdProcessed = TRUE;
//
//         /* Visualization Commands */
//         #ifdef _USE_GUI_
//            else if (GuiCmdInterpreter(CmdLine,&CmdTime))
//               NewCmdProcessed = TRUE;
//         #endif
//
//         /* FSW Commands */
//         else if (FswCmdInterpreter(CmdLine,&CmdTime))
//            NewCmdProcessed = TRUE;
        NewCmdProcessed = HandleCommand(CmdTime, CmdLine);
         /* If any match found, get next command */
         if (NewCmdProcessed) {
            printf("%s",CmdLine);
            fgets(CmdLine,512,CmdFile);
            sscanf(CmdLine,"%lf",&CmdTime);
            if (!strncmp(CmdLine,"EOF",3)) {
               fclose(CmdFile);
               printf("Reached CmdScript EOF at Time = %lf\n",SimTime);
               CmdFileActive = 0;
            }
            fflush(stdout);
         }
      }
      if (!CmdFileActive) {
        SocketCmdInterpreter();
      }
}

//#ifdef __cplusplus
//}
//#endif

