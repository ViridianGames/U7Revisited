///////////////////////////////////////////////////////////////////////////
//
// Name:     LOGGING.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  Dirt-simple logging system.  Just call Log() with whatever
//           text you wish to write to the log file.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _LOGGING_H_
#define _LOGGING_H_

#include <stdio.h>
#include <stdarg.h>
#include <time.h>
#include <string>

#include "raylib.h"

void LoggingCallback(int msgType, const char* text, va_list args);
void Log(std::string text, int msgType = LOG_INFO);


#endif
