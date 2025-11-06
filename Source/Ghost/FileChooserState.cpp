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
	m_shouldClose = false;

	// Make the window visible
	m_window->Show();

	// Load the initial directory
	if (m_currentPath.empty())
	{
		// Default to Gui folder where .ghost files are located
		m_currentPath = SanitizePath(GetWorkingDirectory());
		m_currentPath += "/Gui/";
	}

	LoadDirectory(m_currentPath);
	UpdatePathDisplay();
	PopulateListboxes();

	// Update OK button text based on mode and clear filename textinput
	Gui* gui = m_window->GetGui();
	if (gui)
	{
		int okButtonID = m_window->GetElementID("OK_BUTTON");
		if (okButtonID != -1)
		{
			auto elem = gui->GetElement(okButtonID);
			if (elem && elem->m_Type == GUI_TEXTBUTTON)
			{
				auto button = static_cast<GuiTextButton*>(elem.get());
				button->m_String = m_isSaveMode ? "  Save  " : "  OK  ";
			}
		}

		// Clear the filename textinput
		int filenameInputID = m_window->GetElementID("FILENAME");
		if (filenameInputID != -1)
		{
			auto elem = gui->GetElement(filenameInputID);
			if (elem && elem->m_Type == GUI_TEXTINPUT)
			{
				auto textInput = static_cast<GuiTextInput*>(elem.get());
				textInput->m_String = "";
			}
		}
	}
}

void FileChooserState::OnExit()
{
	Log("FileChooserState::OnExit");
}

void FileChooserState::Update()
{
	// If we're marked to close, wait until mouse is released
	if (m_shouldClose)
	{
		if (!IsMouseButtonDown(MOUSE_LEFT_BUTTON))
		{
			g_StateMachine->PopState();
		}
		return;
	}

	m_window->Update();

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Check for folder listbox clicks
	int foldersListBoxID = m_window->GetElementID("FOLDERS_LISTBOX");
	if (foldersListBoxID != -1)
	{
		auto elem = gui->GetElement(foldersListBoxID);
		if (elem && elem->m_Type == GUI_LISTBOX)
		{
			auto listbox = static_cast<GuiListBox*>(elem.get());
			// Double-click navigates into folder
			if (listbox->m_DoubleClicked)
			{
				std::string folderName = listbox->GetString();
				Log("Folder double-clicked: " + folderName);
				NavigateToFolder(folderName);
				return;  // Navigation will repopulate the lists
			}
			// Single click just selects
			else if (listbox->m_Clicked)
			{
				std::string folderName = listbox->GetString();
				Log("Folder selected: " + folderName);
			}
		}
	}

	// Check for file listbox clicks
	int filesListBoxID = m_window->GetElementID("FILES_LISTBOX");
	if (filesListBoxID != -1)
	{
		auto elem = gui->GetElement(filesListBoxID);
		if (elem && elem->m_Type == GUI_LISTBOX)
		{
			auto listbox = static_cast<GuiListBox*>(elem.get());
			// Double-click accepts the file (like pressing OK)
			if (listbox->m_DoubleClicked)
			{
				std::string filename = listbox->GetString();
				Log("File double-clicked: " + filename);
				SelectFile(filename);

				// Accept the selection and close the dialog
				if (m_selectedFileIndex >= 0 && m_selectedFileIndex < static_cast<int>(m_files.size()))
				{
					m_selectedPath = m_currentPath + m_files[m_selectedFileIndex];
					m_accepted = true;
					Log("Accepted file: " + m_selectedPath);
					m_window->Hide();  // Hide immediately
					m_shouldClose = true;  // Close on next frame to prevent input bleed-through
					return;
				}
			}
			// Single click just selects
			else if (listbox->m_Clicked)
			{
				std::string filename = listbox->GetString();
				Log("File selected: " + filename);
				SelectFile(filename);
			}
		}
	}

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
				Log("OK/Save button clicked!");

				// In save mode, always prioritize the textinput content
				if (m_isSaveMode)
				{
					// Save mode: read filename from text input
					int filenameInputID = m_window->GetElementID("FILENAME");
					if (filenameInputID != -1)
					{
						auto filenameElem = gui->GetElement(filenameInputID);
						if (filenameElem && filenameElem->m_Type == GUI_TEXTINPUT)
						{
							auto textInput = static_cast<GuiTextInput*>(filenameElem.get());
							std::string filename = textInput->m_String;

							// Validate filename is not empty
							if (!filename.empty())
							{
								// Check if filename already has the correct extension
								bool hasExtension = false;

								// Get the first extension from the filter (e.g., ".ghost" from ".ghost" or from ".png|.jpg")
								std::string primaryExtension = m_filter;
								size_t pipePos = m_filter.find('|');
								if (pipePos != std::string::npos)
								{
									primaryExtension = m_filter.substr(0, pipePos);
								}

								// Check if filename ends with any of the valid extensions
								size_t start = 0;
								std::string filterCopy = m_filter + "|";
								while ((pipePos = filterCopy.find('|', start)) != std::string::npos)
								{
									std::string ext = filterCopy.substr(start, pipePos - start);
									if (!ext.empty() && filename.length() >= ext.length() &&
										filename.compare(filename.length() - ext.length(), ext.length(), ext) == 0)
									{
										hasExtension = true;
										break;
									}
									start = pipePos + 1;
								}

								// Add primary extension if not present
								if (!hasExtension)
								{
									filename += primaryExtension;
								}

								// Construct full path
								m_selectedPath = m_currentPath + filename;
								m_accepted = true;
								Log("Save file: " + m_selectedPath);
							}
							else
							{
								Log("ERROR: No filename entered for save");
								return;  // Don't close dialog if no filename
							}
						}
					}
				}
				else  // Open mode
				{
					if (m_selectedFileIndex >= 0 && m_selectedFileIndex < static_cast<int>(m_files.size()))
					{
						// File selected from list
						m_selectedPath = m_currentPath + m_files[m_selectedFileIndex];
						m_accepted = true;
						Log("Selected file: " + m_selectedPath);
					}
					else
					{
						Log("ERROR: No file selected in open mode");
						return;  // Don't close dialog if nothing selected in open mode
					}
				}

				m_window->Hide();  // Hide immediately
				m_shouldClose = true;  // Close on next frame to prevent input bleed-through
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
				m_window->Hide();  // Hide immediately
				m_shouldClose = true;  // Close on next frame to prevent input bleed-through
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

void FileChooserState::SetMode(bool isSave, const std::string& filter, const std::string& initialPath, const std::string& title)
{
	m_isSaveMode = isSave;
	m_filter = filter;

	// Set title or use default
	if (!title.empty())
	{
		m_title = title;
	}
	else
	{
		m_title = isSave ? "Save File" : "Open File";
	}

	if (!initialPath.empty())
	{
		m_currentPath = SanitizePath(initialPath);
	}
	else
	{
		// Default to Gui folder where .ghost files are located
		m_currentPath = SanitizePath(GetWorkingDirectory());
		m_currentPath += "/Gui/";
	}

	Log("FileChooserState::SetMode - isSave: " + std::to_string(isSave) + ", filter: " + filter + ", path: " + m_currentPath + ", title: " + m_title);
}

void FileChooserState::LoadDirectory(const std::string& path)
{
	m_folders.clear();
	m_files.clear();

	Log("Loading directory: " + path);

	// Special case: empty path means show available drives (Windows)
	if (path.empty())
	{
		Log("Enumerating available drives");
		// Check drives A: through Z:
		for (char drive = 'A'; drive <= 'Z'; drive++)
		{
			std::string drivePath = std::string(1, drive) + ":";
			// Try to access the drive to see if it exists
			FilePathList testList = LoadDirectoryFiles(drivePath.c_str());
			if (testList.count > 0)
			{
				m_folders.push_back(drivePath);
				Log("Found drive: " + drivePath);
			}
			UnloadDirectoryFiles(testList);
		}
		Log("Found " + std::to_string(m_folders.size()) + " drives");
		return;
	}

	// Use raylib's LoadDirectoryFiles to enumerate directory contents
	FilePathList fileList = LoadDirectoryFiles(path.c_str());

	for (unsigned int i = 0; i < fileList.count; i++)
	{
		std::string fullPath = SanitizePath(fileList.paths[i]);

		// Get just the filename without the path
		size_t lastSlash = fullPath.find_last_of("/");
		std::string filename = (lastSlash != std::string::npos) ? fullPath.substr(lastSlash + 1) : fullPath;

		// Skip "." current directory entry
		if (filename == ".")
			continue;

		// Check if it's a directory
		if (IsPathFile(fullPath.c_str()))
		{
			// It's a file - check if it matches our filter
			if (m_filter.empty())
			{
				// No filter, add all files
				m_files.push_back(filename);
			}
			else
			{
				// Support multiple extensions separated by | (e.g., ".png|.jpg|.bmp")
				bool matches = false;
				size_t start = 0;
				size_t pipePos = m_filter.find('|');

				// If no pipe, just check single extension
				if (pipePos == std::string::npos)
				{
					if (filename.length() >= m_filter.length() &&
						filename.compare(filename.length() - m_filter.length(), m_filter.length(), m_filter) == 0)
					{
						matches = true;
					}
				}
				else
				{
					// Multiple extensions - check each one
					std::string filterCopy = m_filter;
					filterCopy += "|";  // Add trailing pipe for easier parsing

					while ((pipePos = filterCopy.find('|', start)) != std::string::npos)
					{
						std::string ext = filterCopy.substr(start, pipePos - start);
						if (!ext.empty() && filename.length() >= ext.length() &&
							filename.compare(filename.length() - ext.length(), ext.length(), ext) == 0)
						{
							matches = true;
							break;
						}
						start = pipePos + 1;
					}
				}

				if (matches)
				{
					m_files.push_back(filename);
				}
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
	Gui* gui = m_window->GetGui();
	if (!gui)
	{
		Log("ERROR: PopulateListboxes - No GUI");
		return;
	}

	// Get the folders listbox
	int foldersListBoxID = m_window->GetElementID("FOLDERS_LISTBOX");
	if (foldersListBoxID != -1)
	{
		auto elem = gui->GetElement(foldersListBoxID);
		if (elem && elem->m_Type == GUI_LISTBOX)
		{
			auto listbox = static_cast<GuiListBox*>(elem.get());
			listbox->Clear();

			// Only add ".." if we're not at the drive list level
			if (!m_currentPath.empty())
			{
				listbox->AddItem("[DIR] ..");
			}

			// Add folders
			Log("PopulateListboxes - Adding " + std::to_string(m_folders.size()) + " folders");
			for (const auto& folder : m_folders)
			{
				listbox->AddItem("[DIR] " + folder);
			}
		}
	}

	// Get the files listbox
	int filesListBoxID = m_window->GetElementID("FILES_LISTBOX");
	if (filesListBoxID != -1)
	{
		auto elem = gui->GetElement(filesListBoxID);
		if (elem && elem->m_Type == GUI_LISTBOX)
		{
			auto listbox = static_cast<GuiListBox*>(elem.get());
			listbox->Clear();

			// Add files
			Log("PopulateListboxes - Adding " + std::to_string(m_files.size()) + " files");
			for (const auto& file : m_files)
			{
				listbox->AddItem(file);
			}
		}
	}
}

void FileChooserState::NavigateToFolder(const std::string& folderName)
{
	// Remove "[DIR] " prefix if present
	std::string actualFolderName = folderName;
	if (folderName.find("[DIR] ") == 0)
	{
		actualFolderName = folderName.substr(6);  // Skip "[DIR] "
	}

	if (actualFolderName == "..")
	{
		// Navigate to parent directory
		// Remove trailing slash first
		std::string pathWithoutTrailingSlash = m_currentPath;
		if (!pathWithoutTrailingSlash.empty() &&
		    (pathWithoutTrailingSlash.back() == '/' || pathWithoutTrailingSlash.back() == '\\'))
		{
			pathWithoutTrailingSlash.pop_back();
		}

		// Check if we're already at a drive root (e.g., "C:")
		if (pathWithoutTrailingSlash.length() == 2 && pathWithoutTrailingSlash[1] == ':')
		{
			// We're at a drive root, navigate to drive list by using empty path
			m_currentPath = "";
			Log("At drive root, navigating to drive list");
		}
		else
		{
			// Find the last slash in the path (which is now the parent folder separator)
			size_t lastSlash = pathWithoutTrailingSlash.find_last_of("/\\");
			if (lastSlash != std::string::npos)
			{
				// Keep everything up to and including that slash
				m_currentPath = pathWithoutTrailingSlash.substr(0, lastSlash + 1);
				Log("Navigating to parent: " + m_currentPath);
			}
			else
			{
				// No parent directory, stay at current level
				Log("Already at root level, cannot navigate up");
			}
		}
	}
	else
	{
		// Check if this is a drive name (e.g., "C:")
		if (actualFolderName.length() == 2 && actualFolderName[1] == ':')
		{
			// Navigating to a drive, set path to "C:/"
			m_currentPath = actualFolderName + "/";
			Log("Navigating to drive: " + m_currentPath);
		}
		else
		{
			// Navigate into subdirectory
			m_currentPath += actualFolderName + "/";
		}
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

			// Update the FILENAME textinput with the selected filename
			Gui* gui = m_window->GetGui();
			if (gui)
			{
				int filenameInputID = m_window->GetElementID("FILENAME");
				if (filenameInputID != -1)
				{
					auto elem = gui->GetElement(filenameInputID);
					if (elem && elem->m_Type == GUI_TEXTINPUT)
					{
						auto textInput = static_cast<GuiTextInput*>(elem.get());
						textInput->m_String = filename;
					}
				}
			}

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
			// Show title and current path
			std::string displayText = m_title;
			if (!m_currentPath.empty())
			{
				displayText += ": " + m_currentPath;
			}
			static_cast<GuiTextArea*>(elem.get())->m_String = displayText;
		}
	}
}

std::string FileChooserState::SanitizePath(const std::string& path)
{
	std::string sanitized = path;
	// Replace all backslashes with forward slashes
	for (char& c : sanitized)
	{
		if (c == '\\')
			c = '/';
	}
	return sanitized;
}
