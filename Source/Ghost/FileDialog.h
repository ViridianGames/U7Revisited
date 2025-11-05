#ifndef _FILEDIALOG_H_
#define _FILEDIALOG_H_

#include <string>

class FileDialog
{
public:
	// Show an "Open File" dialog
	// Returns empty string if cancelled
	static std::string OpenFile(const char* title, const char* filter);

	// Show a "Save File" dialog
	// Returns empty string if cancelled
	static std::string SaveFile(const char* title, const char* filter);
};

#endif
