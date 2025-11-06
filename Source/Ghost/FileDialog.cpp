#include "FileDialog.h"

#ifdef _WIN32
#include <windows.h>
#include <commdlg.h>
#endif

std::string FileDialog::OpenFile(const char* title, const char* filter)
{
	return OpenFile(title, filter, nullptr, "");
}

std::string FileDialog::OpenFile(const char* title, const char* filter, const char* initialDir, const char* initialFile)
{
#ifdef _WIN32
	OPENFILENAMEA ofn;
	CHAR szFile[260] = { 0 };

	// If initialFile is provided, copy it to szFile buffer
	if (initialFile && initialFile[0] != '\0')
	{
		strncpy_s(szFile, sizeof(szFile), initialFile, _TRUNCATE);
	}

	ZeroMemory(&ofn, sizeof(OPENFILENAME));
	ofn.lStructSize = sizeof(OPENFILENAME);
	ofn.hwndOwner = NULL;
	ofn.lpstrFile = szFile;
	ofn.nMaxFile = sizeof(szFile);
	ofn.lpstrFilter = filter;
	ofn.nFilterIndex = 1;
	ofn.lpstrTitle = title;
	ofn.lpstrInitialDir = initialDir;  // Set initial directory
	ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_NOCHANGEDIR;

	if (GetOpenFileNameA(&ofn) == TRUE)
	{
		return std::string(ofn.lpstrFile);
	}
#else
	// TODO: Implement Linux file dialog using GTK or similar
#endif

	return "";
}

std::string FileDialog::SaveFile(const char* title, const char* filter)
{
#ifdef _WIN32
	OPENFILENAMEA ofn;
	CHAR szFile[260] = { 0 };

	ZeroMemory(&ofn, sizeof(OPENFILENAME));
	ofn.lStructSize = sizeof(OPENFILENAME);
	ofn.hwndOwner = NULL;
	ofn.lpstrFile = szFile;
	ofn.nMaxFile = sizeof(szFile);
	ofn.lpstrFilter = filter;
	ofn.nFilterIndex = 1;
	ofn.lpstrTitle = title;
	ofn.Flags = OFN_OVERWRITEPROMPT | OFN_NOCHANGEDIR;

	if (GetSaveFileNameA(&ofn) == TRUE)
	{
		return std::string(ofn.lpstrFile);
	}
#else
	// TODO: Implement Linux file dialog using GTK or similar
#endif

	return "";
}
