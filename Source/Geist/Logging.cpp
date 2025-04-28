#include "Logging.h"
#include <stdio.h> // Required for vprintf, fprintf, stderr
#include <time.h>   // Required for time, localtime, strftime

// ANSI escape codes for colors
#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"
#define ANSI_COLOR_BLUE    "\x1b[34m"
#define ANSI_COLOR_RESET   "\x1b[0m"

void LoggingCallback(int logLevel, const char* text, va_list args)
{
	char timeStr[64] = { 0 };
	time_t now = time(NULL);
	struct tm* tm_info = localtime(&now);

	strftime(timeStr, sizeof(timeStr), "%Y-%m-%d %H:%M:%S", tm_info);

	const char* levelStr;
	const char* colorPrefix = "";
	FILE* outputDest = stdout; // Default to stdout

	switch (logLevel)
	{
		case LOG_TRACE: levelStr = "TRACE"; break; // Keep default color
		case LOG_DEBUG: levelStr = "DEBUG"; break; // Keep default color
		case LOG_INFO:
			levelStr = "INFO";
			colorPrefix = ANSI_COLOR_BLUE; // Blue for INFO
			break;
		case LOG_WARNING:
			levelStr = "WARN";
			colorPrefix = ANSI_COLOR_YELLOW; // Yellow for WARNING
			outputDest = stderr; // Warnings often go to stderr
			break;
		case LOG_ERROR:
			levelStr = "ERROR";
			colorPrefix = ANSI_COLOR_RED; // Red for ERROR
			outputDest = stderr; // Errors typically go to stderr
			break;
		case LOG_FATAL:
			levelStr = "FATAL";
			colorPrefix = ANSI_COLOR_RED; // Red for FATAL
			outputDest = stderr;
			break;
		default: levelStr = "OTHER"; break; // Keep default color
	}

	// Print timestamp, log level with color, and the message
	fprintf(outputDest, "%s[%s%s%s]: " ANSI_COLOR_RESET, timeStr, colorPrefix, levelStr, ANSI_COLOR_RESET);
	vfprintf(outputDest, text, args);
	fprintf(outputDest, "\n"); // Ensure newline after message
	fflush(outputDest); // Ensure the message is immediately visible
}

void Log(std::string text, int msgType) {
	TraceLog(msgType, text.c_str());
}
