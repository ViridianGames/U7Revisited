#include "FileDialog.h"

#ifdef _WIN32
#include <windows.h>
#include <commdlg.h>
#endif

std::string FileDialog::OpenFile(const char* title, const char* filter)
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
