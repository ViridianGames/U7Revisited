///////////////////////////////////////////////////////////////////////////
//
// Name:     LOGGING.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  Dirt-simple logging system.  Just call Log() with whatever
//           text you wish to write to the log file.  If it's the first
//           time the function is called, the logfile is created.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _LOGGING_H_
#define _LOGGING_H_

#include <string>

void SetLogFileName(std::string filename);
std::string GetLogFileName(void);

void Log(std::string text, std::string filename = "", bool suppressdatetime = false);

#endif
