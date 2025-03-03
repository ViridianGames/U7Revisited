///////////////////////////////////////////////////////////////////////////
//
// Name:     LOGGING.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  Dirt-simple logging system.  Just call Log() with whatever
//           text you wish to write to the log file. An optional parameter
//           is the level of logging. One of LOG_INFO, LOG_ERROR, LOG_WARNING,
//           LOG_DEBUG. LOG_INFO is the default.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _LOGGING_H_
#define _LOGGING_H_

#include <string>
#include <stdarg.h>
#include <stdio.h>
#include <time.h>

#include "raylib.h"

void LoggingCallback(int msgType, const char* text, va_list args);
void Log(std::string text, int msgType = LOG_INFO);

#endif
