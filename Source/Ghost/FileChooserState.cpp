#include "FileChooserState.h"
#include "../Geist/Logging.h"
#include "../Geist/StateMachine.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Config.h"
#include "../Geist/Gui.h"
#include "../Geist/GuiElements.h"
#include <algorithm>

extern std::unique_ptr<StateMachine> g_StateMachine;
extern std::unique_ptr<ResourceManager> g_ResourceManager;

FileChooserState::~FileChooserState()
{
}

void FileChooserState::Init(const std::string& configfile)
{
	Log("FileChooserState::Init");

	// Create the window - it handles all config loading and GUI setup
	m_window = std::make_unique<GhostWindow>(
		"Gui/ghost_open_file.ghost",
		"Data/ghost.cfg",
		g_ResourceManager.get(),
		GetScreenWidth(),
		GetScreenHeight(),
		true);

	if (!m_window->GetGui())
	{
		Log("ERROR: Failed to load file chooser dialog GUI");
	}
	else
	{
		Log("FileChooserState: Successfully loaded dialog GUI");
	}
}

void FileChooserState::Shutdown()
{
	Log("FileChooserState::Shutdown");
	m_window.reset();
}

void FileChooserState::OnEnter()
{
	Log("FileChooserState::OnEnter");
	m_accepted = false;
	m_selectedFileIndex = -1;

	// Make the window visible
	m_window->Show();

	// Load the initial directory
	if (m_currentPath.empty())
	{
		m_currentPath = "Gui/";  // Default to Gui folder for .ghost files
	}

	LoadDirectory(m_currentPath);
	UpdatePathDisplay();
	PopulateListboxes();
}

void FileChooserState::OnExit()
{
	Log("FileChooserState::OnExit");
}

void FileChooserState::Update()
{
	m_window->Update();

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// TODO: Handle listbox item clicks for folder/file selection
	// TODO: Handle OK button click
	// TODO: Handle Cancel button click

	// Check for OK button click
	int okButtonID = m_window->GetElementID("OK_BUTTON");
	if (okButtonID != -1)
	{
		auto elem = gui->GetElement(okButtonID);
		if (elem && elem->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(elem.get());
			if (button->m_Clicked)
			{
				Log("OK button clicked!");

				if (m_selectedFileIndex >= 0 && m_selectedFileIndex < static_cast<int>(m_files.size()))
				{
					m_selectedPath = m_currentPath + m_files[m_selectedFileIndex];
					m_accepted = true;
					Log("Selected file: " + m_selectedPath);
				}
				else if (m_isSaveMode)
				{
					// TODO: Read filename from text input for save mode
					Log("Save mode not yet implemented");
				}
				else
				{
					Log("No file selected");
				}

				g_StateMachine->PopState();
				return;
			}
		}
	}

	// Check for Cancel button click
	int cancelButtonID = m_window->GetElementID("CANCEL_BUTTON");
	if (cancelButtonID != -1)
	{
		auto elem = gui->GetElement(cancelButtonID);
		if (elem && elem->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(elem.get());
			if (button->m_Clicked)
			{
				Log("Cancel button clicked!");
				m_accepted = false;
				g_StateMachine->PopState();
				return;
			}
		}
	}
}

void FileChooserState::Draw()
{
	// Draw a semi-transparent overlay behind the dialog
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	DrawRectangle(0, 0, screenWidth, screenHeight, Color{0, 0, 0, 128});

	// Draw the dialog GUI
	m_window->Draw();
}

void FileChooserState::SetMode(bool isSave, const std::string& filter, const std::string& initialPath)
{
	m_isSaveMode = isSave;
	m_filter = filter;

	if (!initialPath.empty())
	{
		m_currentPath = initialPath;
	}
	else
	{
		m_currentPath = "Gui/";  // Default path
	}

	Log("FileChooserState::SetMode - isSave: " + std::to_string(isSave) + ", filter: " + filter + ", path: " + m_currentPath);
}

void FileChooserState::LoadDirectory(const std::string& path)
{
	m_folders.clear();
	m_files.clear();

	Log("Loading directory: " + path);

	// Use raylib's LoadDirectoryFiles to enumerate directory contents
	FilePathList fileList = LoadDirectoryFiles(path.c_str());

	for (unsigned int i = 0; i < fileList.count; i++)
	{
		std::string fullPath = fileList.paths[i];

		// Get just the filename without the path
		size_t lastSlash = fullPath.find_last_of("/\\");
		std::string filename = (lastSlash != std::string::npos) ? fullPath.substr(lastSlash + 1) : fullPath;

		// Skip "." current directory entry
		if (filename == ".")
			continue;

		// Check if it's a directory
		if (IsPathFile(fullPath.c_str()))
		{
			// It's a file - check if it matches our filter
			if (m_filter.empty() || filename.find(m_filter) != std::string::npos)
			{
				m_files.push_back(filename);
			}
		}
		else
		{
			// It's a directory
			m_folders.push_back(filename);
		}
	}

	UnloadDirectoryFiles(fileList);

	// Sort folders and files alphabetically
	std::sort(m_folders.begin(), m_folders.end());
	std::sort(m_files.begin(), m_files.end());

	Log("Found " + std::to_string(m_folders.size()) + " folders and " + std::to_string(m_files.size()) + " files");
}

void FileChooserState::PopulateListboxes()
{
	// TODO: This requires dynamic GUI element creation
	// Element names to use (with namePrefix from ghost_open_file.ghost):
	//   Folders listbox: FOLDERS_FOLDER_LIST, FOLDERS_FOLDER_SCROLL, FOLDERS_EMPTY_ITEM
	//   Files listbox: FILES_FOLDER_LIST, FILES_FOLDER_SCROLL, FILES_EMPTY_ITEM
	// For now, just log what we would display
	Log("PopulateListboxes - Folders:");
	for (const auto& folder : m_folders)
	{
		Log("  [DIR] " + folder);
	}

	Log("PopulateListboxes - Files:");
	for (const auto& file : m_files)
	{
		Log("  " + file);
	}
}

void FileChooserState::NavigateToFolder(const std::string& folderName)
{
	if (folderName == "..")
	{
		// Navigate to parent directory
		size_t lastSlash = m_currentPath.find_last_of("/\\");
		if (lastSlash != std::string::npos && lastSlash > 0)
		{
			m_currentPath = m_currentPath.substr(0, lastSlash + 1);
		}
	}
	else
	{
		// Navigate into subdirectory
		m_currentPath += folderName + "/";
	}

	LoadDirectory(m_currentPath);
	UpdatePathDisplay();
	PopulateListboxes();
}

void FileChooserState::SelectFile(const std::string& filename)
{
	// Find the file in our list
	for (size_t i = 0; i < m_files.size(); i++)
	{
		if (m_files[i] == filename)
		{
			m_selectedFileIndex = static_cast<int>(i);
			Log("Selected file index: " + std::to_string(i) + " (" + filename + ")");
			return;
		}
	}

	m_selectedFileIndex = -1;
}

void FileChooserState::UpdatePathDisplay()
{
	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Update the FILE_PATH text area with current directory
	int filePathID = m_window->GetElementID("FILE_PATH");
	if (filePathID != -1)
	{
		auto elem = gui->GetElement(filePathID);
		if (elem && elem->m_Type == GUI_TEXTAREA)
		{
			static_cast<GuiTextArea*>(elem.get())->m_String = m_currentPath;
		}
	}
}
