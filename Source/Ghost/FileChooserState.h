#pragma once

#include "../Geist/State.h"
#include "GhostWindow.h"
#include <string>
#include <vector>
#include <memory>

class FileChooserState : public State
{
public:
	~FileChooserState();

	void Init(const std::string& configfile) override;
	void Shutdown() override;
	void OnEnter() override;
	void OnExit() override;
	void Update() override;
	void Draw() override;

	// Set the mode and parameters for the file chooser
	// isSave: true for save mode, false for open mode
	// filter: file extension filter (e.g., ".ghost" or ".png|.jpg" for multiple)
	// initialPath: starting directory path
	// title: dialog title (optional, defaults to "Open File" or "Save File")
	// initialFilename: filename to pre-select (optional)
	void SetMode(bool isSave, const std::string& filter, const std::string& initialPath = "", const std::string& title = "", const std::string& initialFilename = "");

	// Get the selected file path (call after dialog is closed)
	std::string GetSelectedPath() const { return m_selectedPath; }

	// Check if OK was pressed (vs Cancel)
	bool WasAccepted() const { return m_accepted; }

	// Check if this was opened in save mode
	bool IsSaveMode() const { return m_isSaveMode; }

private:
	void LoadDirectory(const std::string& path);
	void PopulateListboxes();
	void NavigateToFolder(const std::string& folderName);
	void SelectFile(const std::string& filename);
	void UpdatePathDisplay();
	std::string SanitizePath(const std::string& path);  // Convert backslashes to forward slashes

	std::unique_ptr<GhostWindow> m_window;

	bool m_accepted = false;
	bool m_isSaveMode = false;
	bool m_shouldClose = false;  // Defer closing to next frame to prevent input bleed-through

	std::string m_currentPath;
	std::string m_selectedPath;
	std::string m_filter;  // e.g., ".ghost" or ".png|.jpg"
	std::string m_title;   // Dialog title
	std::string m_initialFilename;  // Filename to pre-select when dialog opens

	std::vector<std::string> m_folders;  // Subdirectories in current path
	std::vector<std::string> m_files;    // Files matching filter in current path
	int m_selectedFileIndex = -1;

	// Remember last directory used
	static std::string s_lastDirectory;
};
