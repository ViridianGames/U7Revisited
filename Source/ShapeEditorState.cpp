#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/StateMachine.h"
#include "Geist/ResourceManager.h"
#include "Geist/ScriptingSystem.h"
#include "Geist/TooltipSystem.h"
#include "Geist/Logging.h"
#include "U7Globals.h"
#include "U7ScriptUtils.h"
#include "ShapeEditorState.h"
#include "rlgl.h"

#include <list>
#include <string>
#include <sstream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <algorithm>
#include <unordered_map>
#include <filesystem>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  Helper Functions
////////////////////////////////////////////////////////////////////////////////

// Helper function to add a stretch button with auto-calculated width
static void AddAutoStretchButton(Gui* gui, int ID, int x, int y, const string& label, Font* font)
{
	int width = MeasureTextEx(*font, label.c_str(), font->baseSize, 1).x * 1.15f;
	gui->AddStretchButton(ID, x, y, width, label,
		g_ShapeButtonL, g_ShapeButtonR, g_ShapeButtonM,
		g_ShapeButtonL, g_ShapeButtonR, g_ShapeButtonM);
}

// Helper function to read the first line of a script file
static string GetFirstLineOfScript(const string& filepath)
{
	ifstream file(filepath);
	if (!file.is_open())
	{
		return "";
	}

	string line;
	if (getline(file, line))
	{
		return line;
	}

	return "";
}

////////////////////////////////////////////////////////////////////////////////
//  ShapeEditorState
////////////////////////////////////////////////////////////////////////////////

ShapeEditorState::~ShapeEditorState()
{
	Shutdown();
}

void ShapeEditorState::Init(const string& configfile)
{
	m_sideDrawStrings[0] = "Hidden";
	m_sideDrawStrings[1] = "Top";
	m_sideDrawStrings[2] = "Front";
	m_sideDrawStrings[3] = "Right";
	m_sideDrawStrings[4] = "Top Inv";
	m_sideDrawStrings[5] = "Front Inv";
	m_sideDrawStrings[6] = "Right Inv";

	m_sideStrings[0] = "Top";
	m_sideStrings[1] = "Front";
	m_sideStrings[2] = "Right";
	m_sideStrings[3] = "Bottom";
	m_sideStrings[4] = "Back";
	m_sideStrings[5] = "Left";

	m_currentShape = 150;
	m_currentFrame = 0;
	m_rotating = false;

	m_objectLibrary.resize(1024);
	for (int i = 0; i < 1024; ++i)
	{
		m_objectLibrary[i].resize(32);
	}

	SetupBboardGui();
	SetupFlatGui();
	SetupCuboidGui();
	SetupMeshGui();
	SetupCharacterGui();
	SetupShapePointerGui();
	SetupDontDrawGui();

	ChangeGui(m_bboardGui.get());
}

void ShapeEditorState::ChangeGui(Gui* newGui)
{
	m_bboardGui->m_ActiveElement = -1;
	m_bboardGui->m_Active = false;
	m_flatGui->m_ActiveElement = -1;
	m_flatGui->m_Active = false;
	m_cuboidGui->m_ActiveElement = -1;
	m_cuboidGui->m_Active = false;
	m_meshGui->m_ActiveElement = -1;
	m_meshGui->m_Active = false;
	m_characterGui->m_ActiveElement = -1;
	m_characterGui->m_Active = false;
	m_shapePointerGui->m_ActiveElement = -1;
	m_shapePointerGui->m_Active = false;
	m_dontDrawGui->m_ActiveElement = -1;
	m_dontDrawGui->m_Active = false;

	newGui->m_Active = true;

	m_currentGui = newGui;
}

void ShapeEditorState::SwitchToGuiForDrawType(ShapeDrawType drawType)
{
	switch (drawType)
	{
	case ShapeDrawType::OBJECT_DRAW_BILLBOARD:
		ChangeGui(m_bboardGui.get());
		break;
	case ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH:
		ChangeGui(m_meshGui.get());
		break;
	case ShapeDrawType::OBJECT_DRAW_CUBOID:
		ChangeGui(m_cuboidGui.get());
		break;
	case ShapeDrawType::OBJECT_DRAW_FLAT:
		ChangeGui(m_flatGui.get());
		break;
	case ShapeDrawType::OBJECT_DRAW_DONT_DRAW:
		ChangeGui(m_dontDrawGui.get());
		break;
	}
}

void ShapeEditorState::OnEnter()
{
	ClearConsole();

	m_currentFrame = g_selectedFrame;
	m_currentShape = g_selectedShape;

	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	for (auto node = g_ResourceManager->m_ModelList.begin(); node != g_ResourceManager->m_ModelList.end(); ++node)
	{
		if (node->first == shapeData.m_customMeshName)
		{
			m_modelIndex = node;
			break;
		}
	}

	m_luaScriptIndex = 0;
	for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
	{
		if (g_ScriptingSystem->m_scriptFiles[i].first == g_shapeTable[m_currentShape][m_currentFrame].m_luaScript)
		{
			m_luaScriptIndex = i;
			break;
		}
	}

	SwitchToGuiForDrawType(shapeData.m_drawType);
}

void ShapeEditorState::OnExit()
{
	g_selectedShape = m_currentShape;
	g_selectedFrame = m_currentFrame;
}

void ShapeEditorState::Shutdown()
{

}

void ShapeEditorState::SaveShapeTable()
{
	ofstream file("Data/shapetable.dat", ios::trunc);
	if (file.is_open())
	{
		for (int i = 150; i < 1024; ++i)
		{
			for (int j = 0; j < 32; ++j)
			{
				g_shapeTable[i][j].Serialize(file);
			}
		}
		file.close();
	}
	AddConsoleString("Saved shapetable.dat successfully!", GREEN);
}

void ShapeEditorState::RenameScript(const string& oldScript, const string& newName)
{
	// Extract the shape ID suffix from the old script name
	string shapeIDSuffix;
	size_t underscorePos = oldScript.rfind('_');
	if (underscorePos != string::npos)
	{
		shapeIDSuffix = oldScript.substr(underscorePos); // e.g., "_0290"
	}

	// Build the final new name with shape ID suffix
	string finalNewName = newName;

	// Check if newName already ends with _{number}
	size_t newUnderscorePos = newName.rfind('_');
	bool hasNumberSuffix = false;
	if (newUnderscorePos != string::npos && newUnderscorePos < newName.length() - 1)
	{
		// Check if everything after the underscore is digits
		string potentialNumber = newName.substr(newUnderscorePos + 1);
		hasNumberSuffix = !potentialNumber.empty() &&
			all_of(potentialNumber.begin(), potentialNumber.end(), ::isdigit);
	}

	// If new name doesn't have a number suffix, add the one from the original
	if (!hasNumberSuffix && !shapeIDSuffix.empty())
	{
		finalNewName += shapeIDSuffix;
	}
	// If new name has a number suffix, check if it matches the current shape
	else if (hasNumberSuffix)
	{
		string newSuffix = newName.substr(newUnderscorePos);
		if (!shapeIDSuffix.empty() && newSuffix != shapeIDSuffix)
		{
			Log("ERROR: Shape ID mismatch - script has " + shapeIDSuffix + " but new name has " + newSuffix);
			AddConsoleString("ERROR: Shape ID mismatch - cannot rename! Script has " + shapeIDSuffix + " but you entered " + newSuffix, RED);
			return;  // Abort the rename
		}
	}

	// Rename the script file using git mv
	string oldPath = "Data/Scripts/" + oldScript + ".lua";
	string newPath = "Data/Scripts/" + finalNewName + ".lua";

	Log("RenameScript: oldPath='" + oldPath + "', newPath='" + newPath + "'");
	Log("RenameScript: oldScript='" + oldScript + "', finalNewName='" + finalNewName + "'");

	// Check if old file exists
	ifstream oldFile(oldPath);
	if (!oldFile.good())
	{
		Log("ERROR: Script file not found: " + oldPath);
		AddConsoleString("ERROR: Script file not found: " + oldPath, RED);
		return;
	}
	oldFile.close();

	// First, update the function definition in the file itself BEFORE renaming
	bool funcDefUpdated = false;
	ifstream inFile(oldPath);
	if (inFile.is_open())
	{
		stringstream buffer;
		buffer << inFile.rdbuf();
		string content = buffer.str();
		inFile.close();

		Log("RenameScript: Read " + std::to_string(content.length()) + " bytes from " + oldPath);

		// Replace function definition: "function oldScript(" -> "function finalNewName("
		string oldFuncDef = "function " + oldScript + "(";
		string newFuncDef = "function " + finalNewName + "(";
		Log("RenameScript: Searching for '" + oldFuncDef + "' to replace with '" + newFuncDef + "'");

		size_t pos = content.find(oldFuncDef);
		if (pos != string::npos)
		{
			Log("RenameScript: Found function definition at position " + std::to_string(pos));
			content.replace(pos, oldFuncDef.length(), newFuncDef);

			// Write back the updated content
			ofstream outFile(oldPath, ios::trunc);
			if (outFile.is_open())
			{
				outFile << content;
				outFile.close();
				funcDefUpdated = true;
				Log("Updated function definition in " + oldPath);
			}
			else
			{
				Log("ERROR: Failed to write updated function definition to " + oldPath);
			}
		}
		else
		{
			Log("WARNING: Function definition '" + oldFuncDef + "' not found in " + oldPath);
		}
	}
	else
	{
		Log("ERROR: Failed to open " + oldPath + " for reading");
	}

	// Use git mv to rename the file
	string gitCommand = "git mv \"" + oldPath + "\" \"" + newPath + "\"";
	int result = system(gitCommand.c_str());

	if (result != 0)
	{
		Log("ERROR: Failed to rename script file: git mv failed with error code " + std::to_string(result));
		AddConsoleString("ERROR: Failed to rename file - git mv failed", RED);
		return;
	}

	// Update all frames using this script
	int updatedCount = 0;
	for (int shape = 0; shape < g_shapeTable.size(); ++shape)
	{
		for (int frame = 0; frame < g_shapeTable[shape].size(); ++frame)
		{
			if (g_shapeTable[shape][frame].IsValid() &&
				g_shapeTable[shape][frame].m_luaScript == oldScript)
			{
				Log("RenameScript: Updating shapetable[" + std::to_string(shape) + "][" + std::to_string(frame) + "] from '" + oldScript + "' to '" + finalNewName + "'");
				g_shapeTable[shape][frame].m_luaScript = finalNewName;
				updatedCount++;
			}
		}
	}
	Log("RenameScript: Updated " + std::to_string(updatedCount) + " shapetable entries");

	// Refresh the scripting system to pick up the renamed file
	Log("RenameScript: Shutting down and reinitializing scripting system");
	g_ScriptingSystem->Shutdown();
	g_ScriptingSystem->Init("");

	// Reload all scripts (same as Main.cpp initialization)
	string directoryPath("Data/Scripts");
	g_ScriptingSystem->LoadScript(directoryPath + "/global_flags_and_constants.lua");
	g_ScriptingSystem->LoadScript(directoryPath + "/u7_engine_api.lua");

	for (const auto& entry : std::filesystem::directory_iterator(directoryPath))
	{
		if (entry.is_regular_file())
		{
			std::string ext = entry.path().extension().string();

			if (ext == ".lua")
			{
				std::string filepath = entry.path().string();
				std::string filename = entry.path().filename().string();

				// Skip files we already loaded explicitly
				if (filename == "global_flags_and_constants.lua" ||
					filename == "u7_engine_api.lua")
				{
					continue;
				}

				g_ScriptingSystem->LoadScript(filepath);
			}
		}
	}

	g_ScriptingSystem->SortScripts();
	Log("RenameScript: Scripting system reinitialized, loaded " + std::to_string(g_ScriptingSystem->m_scriptFiles.size()) + " scripts");

	// Find the new script index
	bool foundNewScript = false;
	for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
	{
		const string& scriptName = g_ScriptingSystem->m_scriptFiles[i].first;
		if (scriptName == finalNewName)
		{
			m_luaScriptIndex = i;
			Log("RenameScript: Found new script '" + finalNewName + "' at index " + std::to_string(i));
			foundNewScript = true;
			break;
		}
	}

	if (!foundNewScript)
	{
		Log("ERROR: RenameScript: Could not find script '" + finalNewName + "' in scripting system after reload!");
		Log("RenameScript: First 10 scripts in list:");
		for (int i = 0; i < std::min(10, (int)g_ScriptingSystem->m_scriptFiles.size()); ++i)
		{
			Log("  [" + std::to_string(i) + "] " + g_ScriptingSystem->m_scriptFiles[i].first);
		}
	}

	// Update function names in all Lua scripts
	int scriptFilesUpdated = 0;
	for (const auto& scriptPair : g_ScriptingSystem->m_scriptFiles)
	{
		string scriptFile = "Data/Scripts/" + scriptPair.first + ".lua";

		// Read the entire file
		ifstream inFile(scriptFile);
		if (inFile.is_open())
		{
			stringstream buffer;
			buffer << inFile.rdbuf();
			string content = buffer.str();
			inFile.close();

			// Search and replace function name (old script name used as function name)
			string oldFuncName = oldScript + "(";
			string newFuncName = finalNewName + "(";
			size_t pos = 0;
			bool modified = false;

			while ((pos = content.find(oldFuncName, pos)) != string::npos)
			{
				content.replace(pos, oldFuncName.length(), newFuncName);
				pos += newFuncName.length();
				modified = true;
			}

			// Write back if modified
			if (modified)
			{
				ofstream outFile(scriptFile, ios::trunc);
				if (outFile.is_open())
				{
					outFile << content;
					outFile.close();
					scriptFilesUpdated++;
				}
			}
		}
	}

	// Save the shape table with updated script names
	SaveShapeTable();

	string message = "Renamed script from '" + oldScript + "' to '" + finalNewName + "' (";
	if (funcDefUpdated)
	{
		message += "1 function definition updated, ";
	}
	message += std::to_string(updatedCount) + " frames updated";
	if (scriptFilesUpdated > 0)
	{
		message += ", " + std::to_string(scriptFilesUpdated) + " script files updated";
	}
	message += ")";
	AddConsoleString(message);
}

void ShapeEditorState::Update()
{
	// Check if we have a pending rename to process (after dialog is hidden)
	if (!m_pendingRenameOldName.empty() && !m_pendingRenameNewName.empty())
	{
		AddConsoleString("Renaming script from '" + m_pendingRenameOldName + "' to '" + m_pendingRenameNewName + "'...");
		RenameScript(m_pendingRenameOldName, m_pendingRenameNewName);
		m_pendingRenameOldName.clear();
		m_pendingRenameNewName.clear();
	}

	// If modal window is visible, only handle modal window input and return early
	if (m_renameScriptWindow && m_renameScriptWindow->IsVisible())
	{
		// If we need to set focus and the mouse button is no longer pressed, do it now
		if (m_renameScriptWindowNeedsFocus && !IsMouseButtonDown(MOUSE_LEFT_BUTTON))
		{
			int nameInputID = m_renameScriptWindow->GetElementID("SCRIPT_NAME");
			if (nameInputID != -1)
			{
				auto elem = m_renameScriptWindow->GetGui()->GetElement(nameInputID);
				if (elem && elem->m_Type == GUI_TEXTINPUT)
				{
					GuiTextInput* textInput = static_cast<GuiTextInput*>(elem.get());
					textInput->m_HasFocus = true;
					m_renameScriptWindow->GetGui()->m_ActiveElement = nameInputID;
					Log("Set m_HasFocus = true after mouse released");
				}
			}
			m_renameScriptWindowNeedsFocus = false;
		}

		m_renameScriptWindow->Update();

		int okButtonID = m_renameScriptWindow->GetElementID("OK_BUTTON");
		int cancelButtonID = m_renameScriptWindow->GetElementID("CANCEL_BUTTON");

		if (m_renameScriptWindow->GetGui()->GetActiveElementID() == okButtonID)
		{
			// Get the new name from the text input
			int nameInputID = m_renameScriptWindow->GetElementID("SCRIPT_NAME");
			if (nameInputID != -1)
			{
				auto elem = m_renameScriptWindow->GetGui()->GetElement(nameInputID);
				if (elem && elem->m_Type == GUI_TEXTINPUT)
				{
					string newName = elem->GetString();
					string oldScript = g_shapeTable[m_currentShape][m_currentFrame].m_luaScript;

					// Only queue rename if name changed and is valid
					if (!newName.empty() && newName != "default" && newName != oldScript)
					{
						m_pendingRenameOldName = oldScript;
						m_pendingRenameNewName = newName;
					}

					// Hide dialog and re-enable main GUI
					m_renameScriptWindow->Hide();
					m_renameScriptWindow.reset();
					m_currentGui->m_AcceptingInput = true;
				}
			}
			else
			{
				m_renameScriptWindow->Hide();
				m_renameScriptWindow.reset();
				m_currentGui->m_AcceptingInput = true;
			}
		}
		else if (m_renameScriptWindow->GetGui()->GetActiveElementID() == cancelButtonID)
		{
			m_renameScriptWindow->Hide();
			m_renameScriptWindow.reset();
			m_currentGui->m_AcceptingInput = true;
		}

		return;  // Don't process main GUI while modal is visible
	}

	//  Handle input
	m_currentGui->Update();
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	unsigned int time = GetTime();
	g_CameraMoved = false;

	float speed = 50;

	if (GetKeyPressed() == 0)
	{
		int stopper = 0;
	}
	if (IsKeyDown(KEY_Q))
	{
		g_CameraRotateSpeed += GetFrameTime() * 50;
		if (g_CameraRotateSpeed > 8)
		{
			g_CameraRotateSpeed = 8;
		}
		g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_E))
	{
		g_CameraRotateSpeed -= GetFrameTime() * 50;
		if (g_CameraRotateSpeed < -8)
		{
			g_CameraRotateSpeed = -8;
		}
		g_CameraMoved = true;
	}

	if (!g_CameraMoved)
	{
		g_CameraRotateSpeed *= .9;
		if (g_CameraRotateSpeed < 1 && g_CameraRotateSpeed > -1)
		{
			g_CameraRotateSpeed = 0;
		}
	}


	if (g_CameraRotateSpeed != 0)
	{
		//SetCameraAngle(GetCameraAngle() + g_CameraRotateSpeed);
		//SetCameraChanged(true);
		g_CameraMoved = true;
	}


	if (IsKeyPressed(KEY_A) || m_currentGui->GetActiveElementID() == GE_PREVSHAPEBUTTON)
	{
		int newShape = m_currentShape - 1;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			newShape -= 9;
		}

		if (IsKeyDown(KEY_LEFT_CONTROL))
		{
			newShape -= 99;
		}

		if (newShape < 150)
		{
			newShape = 1023;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			m_currentShape = newShape;
			m_currentFrame = 0;
			SwitchToGuiForDrawType(g_shapeTable[m_currentShape][m_currentFrame].m_drawType);
		}
		else
		{
			m_currentShape = newShape - 1;
		}
	}

	if (IsKeyPressed(KEY_D) || m_currentGui->GetActiveElementID() == GE_NEXTSHAPEBUTTON)
	{
		int newShape = m_currentShape + 1;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			newShape += 9;
		}

		if (IsKeyDown(KEY_LEFT_CONTROL))
		{
			newShape += 99;
		}

		if (newShape > 1023)
		{
			newShape = 150;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			m_currentShape = newShape;
			SwitchToGuiForDrawType(g_shapeTable[m_currentShape][m_currentFrame].m_drawType);
		}
		else
		{
			m_currentShape = newShape + 1;
		}

		m_currentFrame = 0;

		m_luaScriptIndex = 0;
		for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
		{
			if (g_ScriptingSystem->m_scriptFiles[i].first == g_shapeTable[m_currentShape][m_currentFrame].m_luaScript)
			{
				m_luaScriptIndex = i;
				break;
			}
		}
	}

	if (IsKeyPressed(KEY_W) || m_currentGui->GetActiveElementID() == GE_NEXTFRAMEBUTTON)
	{
		// Find next valid frame, wrapping around
		const int maxFrameIndex = static_cast<int>(g_shapeTable[m_currentShape].size() - 1);
		int newFrame = m_currentFrame + 1;
		for (int i = 0; i < static_cast<int>(g_shapeTable[m_currentShape].size()); ++i)
		{
			if (newFrame > maxFrameIndex)
				newFrame = 0;

			if (g_shapeTable[m_currentShape][newFrame].IsValid())
			{
				m_currentFrame = newFrame;
				break;
			}
			newFrame++;
		}
	}

	if (IsKeyPressed(KEY_S) || m_currentGui->GetActiveElementID() == GE_PREVFRAMEBUTTON)
	{
		// Find previous valid frame, wrapping around
		const int maxFrameIndex = static_cast<int>(g_shapeTable[m_currentShape].size() - 1);
		int newFrame = m_currentFrame - 1;
		for (int i = 0; i < static_cast<int>(g_shapeTable[m_currentShape].size()); ++i)
		{
			if (newFrame < 0)
				newFrame = maxFrameIndex;

			if (g_shapeTable[m_currentShape][newFrame].IsValid())
			{
				m_currentFrame = newFrame;
				break;
			}
			newFrame--;
		}
	}

	if (IsKeyDown(KEY_Q))
	{
		g_cameraRotation += GetFrameTime() * 5;
		// Wrap angle to keep within 0 to 2*PI radians
		while (g_cameraRotation >= 2.0f * PI) g_cameraRotation -= 2.0f * PI;
		while (g_cameraRotation < 0) g_cameraRotation += 2.0f * PI;
		g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_E))
	{
		g_cameraRotation -= GetFrameTime() * 5;
		// Wrap angle to keep within 0 to 2*PI radians
		while (g_cameraRotation >= 2.0f * PI) g_cameraRotation -= 2.0f * PI;
		while (g_cameraRotation < 0) g_cameraRotation += 2.0f * PI;
		g_CameraMoved = true;
	}

	// Handle mouse interaction with view angle slider at bottom of screen (sticky drag)
	int guiPanelWidth = 120;
	int sliderWidth = 300;
	int sliderHeight = 20;
	int sliderX = ((g_Engine->m_ScreenWidth - guiPanelWidth) - sliderWidth) / 2;  // Center in 3D view area
	int sliderY = g_Engine->m_ScreenHeight - 40;

	// Detect initial press on slider (bounds check only on first press)
	if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
	{
		int mouseX = GetMouseX();
		int mouseY = GetMouseY();
		if (mouseX >= sliderX && mouseX <= sliderX + sliderWidth &&
		    mouseY >= sliderY && mouseY <= sliderY + sliderHeight)
		{
			m_isDraggingSlider = true;
		}
	}

	// While dragging, track mouse X anywhere (sticky - no bounds check)
	if (m_isDraggingSlider && IsMouseButtonDown(MOUSE_LEFT_BUTTON))
	{
		int mouseX = GetMouseX();
		int newAngle = ((mouseX - sliderX) * 360) / sliderWidth;
		// Wrap angle to valid range (0-359 degrees)
		while (newAngle < 0) newAngle += 360;
		while (newAngle >= 360) newAngle -= 360;
		g_cameraRotation = newAngle * DEG2RAD;
		g_CameraMoved = true;
	}

	// Release ends drag
	if (IsMouseButtonReleased(MOUSE_LEFT_BUTTON))
	{
		m_isDraggingSlider = false;
	}

	if (IsKeyPressed(KEY_F1) || IsKeyPressed(KEY_ESCAPE))
	{
		g_mainState->m_gameMode = MainStateModes::MAIN_STATE_MODE_SANDBOX;
		g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
	}

	if (IsKeyPressed(KEY_F2))
	{
		g_shapeTable[m_currentShape][m_currentFrame].UpdateTextures();
	}

	//  Handle GUI Input
	if (m_currentGui->GetActiveElementID() == GE_SAVEBUTTON)
	{
		AddConsoleString("Saving shapetable.dat...", WHITE);
		Draw();  // Force a frame render to show the loading message
		SaveShapeTable();
	}

	if (m_currentGui->GetActiveElementID() == GE_LOADBUTTON)
	{
		AddConsoleString("Loading shapetable.dat...", WHITE);
		Draw();  // Force a frame render to show the loading message
		ifstream file("Data/shapetable.dat");
		if (file.is_open())
		{
			for (int i = 150; i < 1024; ++i)
			{
				for (int j = 0; j < 32; ++j)
				{
					ShapeData& shapeData = g_shapeTable[i][j];
					shapeData.Deserialize(file);
				}
			}
			file.close();
			AddConsoleString("Done!", GREEN);
		}
		else
		{
			AddConsoleString("ERROR: Failed to load shapetable.dat!", RED);
		}
	}

	bool somethingChanged = false;

	if (m_currentGui->GetActiveElementID() == GE_PREVDRAWTYPE)
	{
		shapeData.m_drawType = static_cast<ShapeDrawType>(static_cast<int>(shapeData.m_drawType) - 1);
		if (shapeData.m_drawType < ShapeDrawType::OBJECT_DRAW_BILLBOARD)
		{
			shapeData.m_drawType = ShapeDrawType(int(ShapeDrawType::OBJECT_DRAW_LAST) - 1);
		}
		SwitchToGuiForDrawType(shapeData.m_drawType);
	}

	else if (m_currentGui->GetActiveElementID() == GE_NEXTDRAWTYPE)
	{
		shapeData.m_drawType = static_cast<ShapeDrawType>(static_cast<int>(shapeData.m_drawType) + 1);
		if (shapeData.m_drawType == ShapeDrawType::OBJECT_DRAW_LAST)
		{
			shapeData.m_drawType = ShapeDrawType::OBJECT_DRAW_BILLBOARD;
		}
		SwitchToGuiForDrawType(shapeData.m_drawType);
	}

	if (m_currentGui->GetActiveElementID() == GE_COPYPARAMSFROMFRAME0)
	{
		if (m_currentFrame != 0)
		{
			ShapeData& frame0Data = g_shapeTable[m_currentShape][0];
			shapeData.m_rotation = frame0Data.m_rotation;
			shapeData.m_Scaling = frame0Data.m_Scaling;
			shapeData.m_TweakPos = frame0Data.m_TweakPos;
			shapeData.m_topTextureRect.x = frame0Data.m_topTextureRect.x;
			shapeData.m_topTextureRect.y = frame0Data.m_topTextureRect.y;
			shapeData.m_topTextureRect.width = frame0Data.m_topTextureRect.width;
			shapeData.m_topTextureRect.height = frame0Data.m_topTextureRect.height;
			shapeData.m_frontTextureRect.x = frame0Data.m_frontTextureRect.x;
			shapeData.m_frontTextureRect.y = frame0Data.m_frontTextureRect.y;
			shapeData.m_frontTextureRect.width = frame0Data.m_frontTextureRect.width;
			shapeData.m_frontTextureRect.height = frame0Data.m_frontTextureRect.height;
			shapeData.m_rightTextureRect.x = frame0Data.m_rightTextureRect.x;
			shapeData.m_rightTextureRect.y = frame0Data.m_rightTextureRect.y;
			shapeData.m_rightTextureRect.width = frame0Data.m_rightTextureRect.width;
			shapeData.m_rightTextureRect.height = frame0Data.m_rightTextureRect.height;

			shapeData.m_sideTextures[int(CuboidSides::CUBOID_TOP)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_TOP)];
			shapeData.m_sideTextures[int(CuboidSides::CUBOID_FRONT)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_FRONT)];
			shapeData.m_sideTextures[int(CuboidSides::CUBOID_RIGHT)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_RIGHT)];
			shapeData.m_sideTextures[int(CuboidSides::CUBOID_BOTTOM)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_BOTTOM)];
			shapeData.m_sideTextures[int(CuboidSides::CUBOID_BACK)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_BACK)];
			shapeData.m_sideTextures[int(CuboidSides::CUBOID_LEFT)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_LEFT)];

			somethingChanged = true;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_JUMPTOINSTANCE)
	{
		bool foundInstance = false;
		for (unordered_map<int, unique_ptr<U7Object>>::iterator node = g_objectList.begin(); node != g_objectList.end(); ++node)
		{
			if ((*node).second == nullptr) continue;
			if((*node).second->m_shapeData->m_shape == m_currentShape && (*node).second->m_shapeData->m_frame == m_currentFrame && !(*node).second->m_isContained)
			{
				g_camera.target = (*node).second->m_Pos;
				g_camera.position = Vector3Add(g_camera.target, Vector3{ 0, g_cameraDistance, g_cameraDistance });
				g_CameraMoved = true;
				g_StateMachine->MakeStateTransition(STATE_MAINSTATE);  // Close shape editor after jumping
				foundInstance = true;
				break;
			}
		}
		if (!foundInstance)
		{
			AddConsoleString("No instance of shape " + to_string(m_currentShape) + " frame " + to_string(m_currentFrame) + " found in world", RED);
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TOPXMINUSBUTTON)
	{
		if (shapeData.m_topTextureRect.x + shapeData.m_topTextureRect.width - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureRect.x--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPXPLUSBUTTON)
	{
		if (shapeData.m_topTextureRect.x + shapeData.m_topTextureRect.width < shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_topTextureRect.x++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPYMINUSBUTTON)
	{
		if (shapeData.m_topTextureRect.y + shapeData.m_topTextureRect.height >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureRect.y--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPYPLUSBUTTON)
	{
		if (shapeData.m_topTextureRect.y + shapeData.m_topTextureRect.height < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_topTextureRect.y++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPWIDTHMINUSBUTTON)
	{
		if (shapeData.m_topTextureRect.x + shapeData.m_topTextureRect.width >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureRect.width--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPWIDTHPLUSBUTTON)
	{
		if (shapeData.m_topTextureRect.x + shapeData.m_topTextureRect.width <= shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_topTextureRect.width++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPHEIGHTMINUSBUTTON)
	{
		if (shapeData.m_topTextureRect.y + shapeData.m_topTextureRect.height >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureRect.height--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPHEIGHTPLUSBUTTON)
	{
		if (shapeData.m_topTextureRect.y + shapeData.m_topTextureRect.height < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_topTextureRect.height++;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_FRONTXMINUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.x + shapeData.m_frontTextureRect.width - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.x--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTXPLUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.x + shapeData.m_frontTextureRect.width + 1 < shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.x++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTYMINUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.y + shapeData.m_frontTextureRect.height - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.y--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTYPLUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.y + shapeData.m_frontTextureRect.height < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.y++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTWIDTHMINUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.x + shapeData.m_frontTextureRect.width >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.width--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTWIDTHPLUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.x + shapeData.m_frontTextureRect.width < shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.width++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTHEIGHTMINUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.y + shapeData.m_frontTextureRect.height >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.height--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTHEIGHTPLUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.y + shapeData.m_frontTextureRect.height < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.height++;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_RIGHTXMINUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.x + shapeData.m_rightTextureRect.width - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.x--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTXPLUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.x + shapeData.m_rightTextureRect.width + 1 < shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.x++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTYMINUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.y + shapeData.m_rightTextureRect.height - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.y--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTYPLUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.y + shapeData.m_rightTextureRect.height + 1 < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.y++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTWIDTHMINUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.x + shapeData.m_rightTextureRect.width - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.width--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTWIDTHPLUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.x + shapeData.m_rightTextureRect.width < shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.width++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTHEIGHTMINUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.y + shapeData.m_rightTextureRect.height - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.height--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTHEIGHTPLUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.y + shapeData.m_rightTextureRect.height + 1 < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.height++;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TOPRESET) { somethingChanged = true; shapeData.ResetTopTextureRect(); }
	if (m_currentGui->GetActiveElementID() == GE_FRONTRESET) { somethingChanged = true; shapeData.ResetFrontTextureRect(); }
	if (m_currentGui->GetActiveElementID() == GE_RIGHTRESET) { somethingChanged = true; shapeData.ResetRightTextureRect(); }

	if (m_currentGui->GetActiveElementID() == GE_PREVTOPBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_TOP, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTTOPBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_TOP, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVFRONTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_FRONT, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTFRONTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_FRONT, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVRIGHTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_RIGHT, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTRIGHTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_RIGHT, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVBOTTOMBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_BOTTOM, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTBOTTOMBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_BOTTOM, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVBACKBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_BACK, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTBACKBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_BACK, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVLEFTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_LEFT, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTLEFTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_LEFT, static_cast<CuboidTexture>(sideTexture));
	}


	//  Tweak dimensions

	if (m_currentGui->GetActiveElementID() == GE_TWEAKWIDTHPLUSBUTTON)
	{
		somethingChanged = true;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.x -= .5f;
		}
		else
		{
			shapeData.m_Scaling.x -= .05f;
		}

		if(shapeData.m_Scaling.x < -9.9f) shapeData.m_Scaling.x = -9.9f;

		if(abs(shapeData.m_Scaling.x) < 0.01f)
		{
			shapeData.m_Scaling.x = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKWIDTHMINUSBUTTON)
	{
		somethingChanged = true;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.x += .5f;
		}
		else
		{
			shapeData.m_Scaling.x += .05f;
		}

		if (shapeData.m_Scaling.x > 9.9) shapeData.m_Scaling.x = 9.9;

		if (abs(shapeData.m_Scaling.x) < 0.01f)
		{
			shapeData.m_Scaling.x = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKHEIGHTMINUSBUTTON)
	{
		somethingChanged = true;
		if(IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.y += .5f;
		}
		else
		{
			shapeData.m_Scaling.y += .05f;
		}
		if (shapeData.m_Scaling.y > 9.9) shapeData.m_Scaling.y = 9.9;

		if (abs(shapeData.m_Scaling.y) < 0.01f)
		{
			shapeData.m_Scaling.y = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKHEIGHTPLUSBUTTON)
	{
		somethingChanged = true;
		if(IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.y -= .5f;
		}
		else
		{
			shapeData.m_Scaling.y -= .05f;
		}
		if (shapeData.m_Scaling.y < -9.9f) shapeData.m_Scaling.y = 9.9f;

		if (abs(shapeData.m_Scaling.y) < 0.01f)
		{
			shapeData.m_Scaling.y = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKDEPTHMINUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.z += .5f;
		}
		else
		{
			shapeData.m_Scaling.z += .05f;
		}
		if (shapeData.m_Scaling.z < 0) shapeData.m_Scaling.z = 0;

		if (abs(shapeData.m_Scaling.z) < 0.01f)
		{
			shapeData.m_Scaling.z = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKDEPTHPLUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.z -= .5f;
		}
		else
		{
			shapeData.m_Scaling.z -= .05f;
		}
		if (shapeData.m_Scaling.z < -9.9) shapeData.m_Scaling.z = -9.9;

		if (abs(shapeData.m_Scaling.z) < 0.01f)
		{
			shapeData.m_Scaling.z = 0;
		}
	}

	//  Tweak Position
		if (m_currentGui->GetActiveElementID() == GE_TWEAKXPLUSBUTTON)
	{
		somethingChanged = true;
		if(IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.x -= .5f;
		}
		else
		{
			shapeData.m_TweakPos.x -= .05f;
		}
		if(shapeData.m_TweakPos.x < -9.9) shapeData.m_TweakPos.x = -9.9;

		if (abs(shapeData.m_TweakPos.x) < 0.01f)
		{
			shapeData.m_TweakPos.x = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKXMINUSBUTTON)
	{
		somethingChanged = true;
		if(IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.x += .5f;
		}
		else
		{
			shapeData.m_TweakPos.x += .05f;
		}
		if (shapeData.m_TweakPos.x > 9.9) shapeData.m_TweakPos.x = 9.9;

		if (abs(shapeData.m_TweakPos.x) < 0.01f)
		{
			shapeData.m_TweakPos.x = 0;
		}

	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKYMINUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.y += .5f;
		}
		else
		{
			shapeData.m_TweakPos.y += .05f;
		}
		if (shapeData.m_TweakPos.y > 9.9) shapeData.m_TweakPos.y = 9.9;

		if (abs(shapeData.m_TweakPos.y) < 0.01f)
		{
			shapeData.m_TweakPos.y = 0;
		}

	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKYPLUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.y -= .5f;
		}
		else
		{
			shapeData.m_TweakPos.y -= .05f;
		}
		if (shapeData.m_TweakPos.y < -9.9) shapeData.m_TweakPos.y = -9.9;

		if (abs(shapeData.m_TweakPos.y) < 0.01f)
		{
			shapeData.m_TweakPos.y = 0;
		}

	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKZMINUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.z += .5f;
		}
		else
		{
			shapeData.m_TweakPos.z += .05f;
		}
		if (shapeData.m_TweakPos.z > 9.9) shapeData.m_TweakPos.z = 9.9;

		if (abs(shapeData.m_TweakPos.z) < 0.01f)
		{
			shapeData.m_TweakPos.z = 0;
		}

	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKZPLUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.z -= .5f;
		}
		else
		{
			shapeData.m_TweakPos.z -= .05f;
		}
		if (shapeData.m_TweakPos.z < -9.9) shapeData.m_TweakPos.z = -9.9;

		if (abs(shapeData.m_TweakPos.z) < 0.01f)
		{
			shapeData.m_TweakPos.z = 0;
		}

	}

	if (m_currentGui->GetActiveElementID() == GE_MESHOUTLINECHECKBOX)
	{
		somethingChanged = true;
		shapeData.m_meshOutline = m_currentGui->GetActiveElement()->m_Selected;
	}

	if (m_currentGui->GetActiveElementID() == GE_USESHAPEPOINTERCHECKBOX)
	{
		somethingChanged = true;
		shapeData.m_useShapePointer = m_currentGui->GetActiveElement()->m_Selected;

		shapeData.UpdateTextures();
		shapeData.SafeAndSane();
	}

	// Tweak Rotation
	if (m_currentGui->GetActiveElementID() == GE_TWEAKROTATIONPLUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_rotation += 1.0f;
		if (shapeData.m_rotation > 360) shapeData.m_rotation = 0;
		if (shapeData.m_rotation < 0) shapeData.m_rotation = 360;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKROTATIONMINUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_rotation -= 1.0f;
		if (shapeData.m_rotation > 360) shapeData.m_rotation = 0;
		if (shapeData.m_rotation < 0) shapeData.m_rotation = 360;
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTMODELBUTTON)
	{
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			for(int i = 0; i < 10; ++i)
			{
				m_modelIndex++;
				if (m_modelIndex == g_ResourceManager->m_ModelList.end())
				{
					m_modelIndex = g_ResourceManager->m_ModelList.begin();
				}
			}
		}
		else
		{
			m_modelIndex++;
			if (m_modelIndex == g_ResourceManager->m_ModelList.end())
			{
				m_modelIndex = g_ResourceManager->m_ModelList.begin();
			}
		}

		g_shapeTable[m_currentShape][m_currentFrame].m_customMesh = (*m_modelIndex).second.get();
		g_shapeTable[m_currentShape][m_currentFrame].m_customMeshName = (*m_modelIndex).first;
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVMODELBUTTON)
	{
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			for(int i = 0; i < 10; ++i)
			{
				if (m_modelIndex == g_ResourceManager->m_ModelList.begin())
				{
					m_modelIndex = g_ResourceManager->m_ModelList.end();
				}
				m_modelIndex--;
			}
		}
		else
		{
			if (m_modelIndex == g_ResourceManager->m_ModelList.begin())
			{
				m_modelIndex = g_ResourceManager->m_ModelList.end();
			}
			m_modelIndex--;
		}

		g_shapeTable[m_currentShape][m_currentFrame].m_customMeshName = (*m_modelIndex).first;
		g_shapeTable[m_currentShape][m_currentFrame].m_customMesh = (*m_modelIndex).second.get();
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTLUASCRIPTBUTTON)
	{
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			for(int i = 0; i < 10; ++i)
			{
				m_luaScriptIndex++;
				if (m_luaScriptIndex >= g_ScriptingSystem->m_scriptFiles.size())
				{
					m_luaScriptIndex = 0;
				}
			}
		}
		else
		{
			m_luaScriptIndex++;
			if (m_luaScriptIndex >= g_ScriptingSystem->m_scriptFiles.size())
			{
				m_luaScriptIndex = 0;
			}
		}

		g_shapeTable[m_currentShape][m_currentFrame].m_luaScript = (g_ScriptingSystem->m_scriptFiles[m_luaScriptIndex].first);
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVLUASCRIPTBUTTON)
	{
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			for(int i = 0; i < 10; ++i)
			{
				m_luaScriptIndex--;
				if (m_luaScriptIndex < 0)
				{
					m_luaScriptIndex = static_cast<int>(g_ScriptingSystem->m_scriptFiles.size() - 1);
				}
			}
		}
		else
		{
			m_luaScriptIndex--;
			if (m_luaScriptIndex < 0)
			{
				m_luaScriptIndex = static_cast<int>(g_ScriptingSystem->m_scriptFiles.size()) - 1;
			}
		}

		g_shapeTable[m_currentShape][m_currentFrame].m_luaScript = (g_ScriptingSystem->m_scriptFiles[m_luaScriptIndex].first);
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVSHAPEPOINTERBUTTON)
	{
		int pointerShape = shapeData.m_pointerShape;
		int newShape = pointerShape - 1;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			newShape -= 9;
		}

		if (newShape < 0)
		{
			newShape = 1023;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			shapeData.m_pointerShape = newShape;
			if (shapeData.m_useShapePointer)
			{
				somethingChanged = true;
			}
		}
		else
		{
			shapeData.m_pointerShape = 0;
		}

		shapeData.m_pointerFrame = 0;
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTSHAPEPOINTERBUTTON)
	{
		int pointerShape = shapeData.m_pointerShape;
		int newShape = pointerShape + 1;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			newShape += 9;
		}

		if (newShape > 1023)
		{
			newShape = 150;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			shapeData.m_pointerShape = newShape;
			if (shapeData.m_useShapePointer)
			{
				somethingChanged = true;
			}
		}
		else
		{
			shapeData.m_pointerShape = 0;
		}

		shapeData.m_pointerFrame = 0;
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTFRAMEPOINTERBUTTON)
	{
		int newFrame = shapeData.m_pointerFrame + 1;
		if (newFrame > 31)
		{
			newFrame = 0;
		}

		if (g_shapeTable[shapeData.m_pointerShape][newFrame].IsValid())
		{
			shapeData.m_pointerFrame = newFrame;
			if (shapeData.m_useShapePointer)
			{
				somethingChanged = true;
			}
		}
	}

	if (IsKeyPressed(KEY_S) || m_currentGui->GetActiveElementID() == GE_PREVFRAMEPOINTERBUTTON)
	{
		int newFrame = shapeData.m_pointerFrame - 1;
		if (newFrame < 0)
		{
			newFrame = 31;
		}

		if (g_shapeTable[m_currentShape][newFrame].IsValid())
		{
			shapeData.m_pointerFrame = newFrame;
			if (shapeData.m_useShapePointer)
			{
				somethingChanged = true;
			}
		}
	}

	if(m_currentGui->GetActiveElementID() == GE_OPENLUASCRIPTBUTTON)
	{
		std::string filePath = g_ScriptingSystem->m_scriptFiles[m_luaScriptIndex].second;

		// Open the file with the default system application
		#ifdef _WIN32
			system(("start \"\" \"" + std::string(filePath) + "\"").c_str());
		#elif __APPLE__
			system(("open \"" + std::string(filePath) + "\"").c_str());
		#else // Linux and others
			system(("xdg-open \"" + std::string(filePath) + "\"").c_str());
		#endif
	}

	if(m_currentGui->GetActiveElementID() == GE_SETLUASCRIPTTOSHAPEIDBUTTON)
	{
		// Generate script name suffix based on new naming scheme
		std::string suffix;
		stringstream ss;

		if (m_currentShape < 150)
		{
			// func_XXXX (decimal, 4 digits)
			ss << std::setfill('0') << std::setw(4) << m_currentShape;
			suffix = "_" + ss.str();
		}
		else if (m_currentShape >= 150 && m_currentShape <= 1024)
		{
			// object_*_XXXX (decimal, 4 digits)
			ss << std::setfill('0') << std::setw(4) << m_currentShape;
			suffix = "_" + ss.str();
		}

		// Search for script ending with the calculated suffix (for non-NPC scripts)
		int newScriptIndex = 0;

		if (m_currentShape >= 1025 && m_currentShape <= 1280)
		{
			// npc_*_XXXX (decimal - 1024, 4 digits) - use helper function
			int npcID = m_currentShape - 1024;
			string scriptName = FindNPCScriptByID(npcID);
			if (!scriptName.empty())
			{
				// Find index in script files
				for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
				{
					if (g_ScriptingSystem->m_scriptFiles[i].first == scriptName)
					{
						newScriptIndex = i;
						AddConsoleString("Using script: " + scriptName);
						break;
					}
				}
			}
		}
		else if (m_currentShape > 1280)
		{
			// utility_*_XXXX (decimal - 1280, 4 digits)
			ss << std::setfill('0') << std::setw(4) << (m_currentShape - 1280);
			suffix = "_" + ss.str();
		}
		if (m_currentShape < 1025 || m_currentShape > 1280)
		{
			for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
			{
				const std::string& scriptName = g_ScriptingSystem->m_scriptFiles[i].first;
				if (scriptName.length() >= suffix.length() &&
					scriptName.compare(scriptName.length() - suffix.length(), suffix.length(), suffix) == 0)
				{
					newScriptIndex = i;
					AddConsoleString("Using script: " + scriptName);
					break;
				}
			}
		}

		if(newScriptIndex != 0)
		{
			m_luaScriptIndex = newScriptIndex;
			g_shapeTable[m_currentShape][m_currentFrame].m_luaScript = (g_ScriptingSystem->m_scriptFiles[m_luaScriptIndex].first);
		}
		else
		{
			AddConsoleString("No script found for shape ID: " + std::to_string(m_currentShape));
		}
	}

	if(m_currentGui->GetActiveElementID() == GE_ADDALLFRAMESSCRIPTBUTTON)
	{
		// Loop through all frames and assign scripts to those with "script default"
		int assignedCount = 0;
		int alreadyCorrectCount = 0;
		int skippedCount = 0;

		// First, determine what script we would assign
		std::string targetScript;
		int foundScriptIndex = 0;
		{
			// Handle NPCs separately with helper function
			if (m_currentShape >= 1025 && m_currentShape <= 1280)
			{
				int npcID = m_currentShape - 1024;
				targetScript = FindNPCScriptByID(npcID);
				if (!targetScript.empty())
				{
					// Find index in script files
					for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
					{
						if (g_ScriptingSystem->m_scriptFiles[i].first == targetScript)
						{
							foundScriptIndex = i;
							break;
						}
					}
				}
			}
			else
			{
				// For non-NPC scripts, use suffix matching
				std::string suffix;
				stringstream ss;

				if (m_currentShape < 150)
				{
					ss << std::setfill('0') << std::setw(4) << m_currentShape;
					suffix = "_" + ss.str();
				}
				else if (m_currentShape >= 150 && m_currentShape <= 1024)
				{
					ss << std::setfill('0') << std::setw(4) << m_currentShape;
					suffix = "_" + ss.str();
				}
				else if (m_currentShape > 1280)
				{
					ss << std::setfill('0') << std::setw(4) << (m_currentShape - 1280);
					suffix = "_" + ss.str();
				}

				// Search for script ending with the calculated suffix
				for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
				{
					const std::string& scriptName = g_ScriptingSystem->m_scriptFiles[i].first;
					if (scriptName.length() >= suffix.length() &&
						scriptName.compare(scriptName.length() - suffix.length(), suffix.length(), suffix) == 0)
					{
						foundScriptIndex = i;
						targetScript = scriptName;
						break;
					}
				}
			}

			if (foundScriptIndex == 0)
			{
				AddConsoleString("No script found for shape ID: " + std::to_string(m_currentShape));
				goto skip_button;
			}
		}

		// Now loop through frames and assign
		for (int frame = 0; frame < g_shapeTable[m_currentShape].size(); ++frame)
		{
			// Skip invalid frames
			if (!g_shapeTable[m_currentShape][frame].IsValid())
			{
				continue;
			}

			std::string currentScript = g_shapeTable[m_currentShape][frame].m_luaScript;

			// If frame has "default", assign the script
			if (currentScript == "default")
			{
				g_shapeTable[m_currentShape][frame].m_luaScript = targetScript;
				assignedCount++;
			}
			// If frame already has the same script, skip silently
			else if (currentScript == targetScript)
			{
				alreadyCorrectCount++;
			}
			// If frame has a different script, warn and skip
			else
			{
				DebugPrint("Frame " + std::to_string(frame) + " already has script '" + currentScript + "', not changing to '" + targetScript + "'");
				skippedCount++;
			}
		}

		// Update the script index so "Open Script" button opens the correct script
		m_luaScriptIndex = foundScriptIndex;

		AddConsoleString("Assigned scripts to " + std::to_string(assignedCount) + " frames, " + std::to_string(alreadyCorrectCount) + " already correct, " + std::to_string(skippedCount) + " skipped (different script)");
	}
	skip_button:

	if (m_currentGui->GetActiveElementID() == GE_CLEARSCRIPTBUTTON)
	{
		g_shapeTable[m_currentShape][m_currentFrame].m_luaScript = "default";
		AddConsoleString("Cleared script for current frame");
	}

	if (m_currentGui->GetActiveElementID() == GE_CLEARALLSCRIPTSBUTTON)
	{
		int clearedCount = 0;

		for (int frame = 0; frame < g_shapeTable[m_currentShape].size(); ++frame)
		{
			// Skip invalid frames
			if (!g_shapeTable[m_currentShape][frame].IsValid())
			{
				continue;
			}

			g_shapeTable[m_currentShape][frame].m_luaScript = "default";
			clearedCount++;
		}

		AddConsoleString("Cleared scripts for " + std::to_string(clearedCount) + " frames");
	}

	// Handle rename script button
	if (m_currentGui->GetActiveElementID() == GE_RENAMESCRIPTBUTTON)
	{
		Log("Rename script button clicked!");
		// Get the current script name (without .lua extension)
		string currentScript = g_shapeTable[m_currentShape][m_currentFrame].m_luaScript;
		Log("Current script: " + currentScript);
		if (currentScript == "default" || currentScript.empty())
		{
			AddConsoleString("No script assigned to rename");
		}
		else
		{
			Log("Creating rename dialog window...");
			Log("RenderWidth: " + std::to_string(g_Engine->m_RenderWidth) + ", RenderHeight: " + std::to_string(g_Engine->m_RenderHeight));
			Log("ScreenWidth: " + std::to_string(g_Engine->m_ScreenWidth) + ", ScreenHeight: " + std::to_string(g_Engine->m_ScreenHeight));
			Log("g_DrawScale: " + std::to_string(g_DrawScale));

			// Create the rename dialog window - use render dimensions since it draws in the render target
			m_renameScriptWindow = make_unique<GhostWindow>(
				"GUI/script_rename.ghost",
				"Data/u7.cfg",
				g_ResourceManager.get(),
				g_Engine->m_RenderWidth,
				g_Engine->m_RenderHeight,
				true  // modal
			);

			Log("Window created. IsValid: " + std::to_string(m_renameScriptWindow->IsValid()));

			// Mouse coordinates are in screen space, but GUI is rendered in render target space
			// InputScale divides mouse coords to transform them: screenMouse / g_DrawScale = renderMouse
			m_renameScriptWindow->GetGui()->m_InputScale = g_DrawScale;
			Log("Set InputScale to: " + std::to_string(g_DrawScale));

			// Disable input on main GUI while modal is visible
			m_currentGui->m_AcceptingInput = false;

			// Set the ORIG_NAME textarea to show the current script name
			int origNameID = m_renameScriptWindow->GetElementID("ORIG_NAME");
			if (origNameID != -1)
			{
				auto origElem = m_renameScriptWindow->GetGui()->GetElement(origNameID);
				if (origElem && origElem->m_Type == GUI_TEXTAREA)
				{
					origElem->m_String = currentScript;
					Log("Set ORIG_NAME to: " + currentScript);
				}
			}

			// Pre-fill the text input with the current script name
			int nameInputID = m_renameScriptWindow->GetElementID("SCRIPT_NAME");
			Log("SCRIPT_NAME ID: " + std::to_string(nameInputID));
			if (nameInputID != -1)
			{
				auto elem = m_renameScriptWindow->GetGui()->GetElement(nameInputID);
				if (elem && elem->m_Type == GUI_TEXTINPUT)
				{
					elem->m_String = currentScript;
					Log("Pre-filled script name");
				}
			}

			// Set flag to give focus after mouse button is released
			m_renameScriptWindowNeedsFocus = true;

			m_renameScriptWindow->Show();
			Log("Called Show(). IsVisible: " + std::to_string(m_renameScriptWindow->IsVisible()));
		}
	}

	if (somethingChanged)
	{
		shapeData.SafeAndSane();
		shapeData.UpdateTextures();
		shapeData.UpdateTextureCoordinates();
	}

	if (g_CameraMoved)
	{
		Vector3 camPos = { g_cameraDistance, g_cameraDistance, g_cameraDistance };
		camPos = Vector3RotateByAxisAngle(camPos, Vector3{ 0, 1, 0 }, g_cameraRotation);

		g_camera.position = Vector3Add(g_camera.target, camPos);
		g_camera.fovy = g_cameraDistance;
	}

	//  Update GUI Textareas
	std::stringstream ss;
    ss << std::uppercase << std::hex << m_currentShape;
	m_currentGui->GetElement(GE_CURRENTSHAPEIDTEXTAREA)->m_String = "S:" + to_string(m_currentShape) + " (" + ss.str() + ")";

	// Find max valid frame for this shape
	int maxFrame = 0;
	const int maxFrameIndex = static_cast<int>(g_shapeTable[m_currentShape].size() - 1);
	for (int i = maxFrameIndex; i >= 0; --i)
	{
		if (g_shapeTable[m_currentShape][i].IsValid())
		{
			maxFrame = i;
			break;
		}
	}
	m_currentGui->GetElement(GE_CURRENTFRAMEIDTEXTAREA)->m_String = "F:" + to_string(m_currentFrame) + "/" + to_string(maxFrame);

	if (m_currentGui == m_cuboidGui.get())
	{

		m_currentGui->GetElement(GE_TOPXTEXTAREA)->m_String = "X:" + to_string(int(shapeData.m_topTextureRect.x));
		m_currentGui->GetElement(GE_FRONTXTEXTAREA)->m_String = "X:" + to_string(int(shapeData.m_frontTextureRect.x));
		m_currentGui->GetElement(GE_RIGHTXTEXTAREA)->m_String = "X:" + to_string(int(shapeData.m_rightTextureRect.x));

		m_currentGui->GetElement(GE_TOPYTEXTAREA)->m_String = "Y:" + to_string(int(shapeData.m_topTextureRect.y));
		m_currentGui->GetElement(GE_FRONTYTEXTAREA)->m_String = "Y:" + to_string(int(shapeData.m_frontTextureRect.y));
		m_currentGui->GetElement(GE_RIGHTYTEXTAREA)->m_String = "Y:" + to_string(int(shapeData.m_rightTextureRect.y));

		m_currentGui->GetElement(GE_TOPWIDTHTEXTAREA)->m_String = "W:" + to_string(int(shapeData.m_topTextureRect.width));
		m_currentGui->GetElement(GE_FRONTWIDTHTEXTAREA)->m_String = "W:" + to_string(int(shapeData.m_frontTextureRect.width));
		m_currentGui->GetElement(GE_RIGHTWIDTHTEXTAREA)->m_String = "W:" + to_string(int(shapeData.m_rightTextureRect.width));

		m_currentGui->GetElement(GE_TOPHEIGHTTEXTAREA)->m_String = "H:" + to_string(int(shapeData.m_topTextureRect.height));
		m_currentGui->GetElement(GE_FRONTHEIGHTTEXTAREA)->m_String = "H:" + to_string(int(shapeData.m_frontTextureRect.height));
		m_currentGui->GetElement(GE_RIGHTHEIGHTTEXTAREA)->m_String = "H:" + to_string(int(shapeData.m_rightTextureRect.height));

		m_currentGui->GetElement(GE_TOPSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP))];
		m_currentGui->GetElement(GE_FRONTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT))];
		m_currentGui->GetElement(GE_RIGHTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT))];
		m_currentGui->GetElement(GE_BOTTOMSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM))];
		m_currentGui->GetElement(GE_BACKSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK))];
		m_currentGui->GetElement(GE_LEFTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT))];
	}

	if(m_currentGui == m_shapePointerGui.get())
	{
		m_currentGui->GetElement(GE_CURRENTSHAPEPOINTERIDTEXTAREA)->m_String = "PS:" + to_string(shapeData.m_pointerShape);
		m_currentGui->GetElement(GE_CURRENTFRAMEPOINTERIDTEXTAREA)->m_String = "PF:" + to_string(shapeData.m_pointerFrame);
	}

	std::ostringstream out;
	out.precision(2);
	out << std::fixed << shapeData.m_Scaling.x;
	m_currentGui->GetElement(GE_TWEAKWIDTHTEXTAREA)->m_String = "W:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_Scaling.y;
	m_currentGui->GetElement(GE_TWEAKHEIGHTTEXTAREA)->m_String = "H:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_Scaling.z;
	m_currentGui->GetElement(GE_TWEAKDEPTHTEXTAREA)->m_String = "D:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_TweakPos.x;
	m_currentGui->GetElement(GE_TWEAKXTEXTAREA)->m_String = "X:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_TweakPos.y;
	m_currentGui->GetElement(GE_TWEAKYTEXTAREA)->m_String = "Y:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_TweakPos.z;
	m_currentGui->GetElement(GE_TWEAKZTEXTAREA)->m_String = "Z:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_rotation;
	m_currentGui->GetElement(GE_TWEAKROTATIONTEXTAREA)->m_String = out.str();

	if (m_currentGui == m_meshGui.get())
	{
		m_currentGui->GetElement(GE_MESHOUTLINECHECKBOX)->m_Selected = shapeData.m_meshOutline;
	}

	if (m_currentGui == m_meshGui.get())
	{
		std::string newStr = g_shapeTable[m_currentShape][m_currentFrame].m_customMeshName.substr(16);
		m_currentGui->GetElement(GE_MODELNAMETEXTAREA)->m_String = newStr;
	}

	m_currentGui->GetElement(GE_LUASCRIPTTEXTAREA)->m_String = g_shapeTable[m_currentShape][m_currentFrame].m_luaScript;

}

void ShapeEditorState::DrawCuboidWireframe(const Vector3& position, const Vector3& dims, const Vector3& scaling, float rotationAngle)
{
	Vector3 scale = Vector3{ dims.x * scaling.x, dims.y * scaling.y, dims.z * scaling.z };

	// Match the cuboid positioning from ShapeData::Draw() exactly
	// thisPos is where the model is placed (model origin in world space)
	Vector3 thisPos = Vector3Add(position, Vector3{ -dims.x + 1, 0, -dims.z + 1 });

	// Gap size for offsetting faces outward so they don't overlap
	float gap = 0.05f;

	// Helper function to rotate a point around Y axis (angle in radians)
	auto rotateY = [](Vector3 point, float angleRadians) -> Vector3 {
		float s = sinf(angleRadians);
		float c = cosf(angleRadians);
		float newX = point.x * c - point.z * s;
		float newZ = point.x * s + point.z * c;
		return Vector3{ newX, point.y, newZ };
	};

	// Define the 8 corners in model space (before scaling)
	// The cuboid model is a 1x1x1 cube with origin at bottom-left-back corner (0,0,0 to 1,1,1)
	Vector3 localCorners[8] = {
		{0.0f, 0.0f, 0.0f},  // 0: bottom-left-back (origin)
		{1.0f, 0.0f, 0.0f},  // 1: bottom-right-back
		{1.0f, 0.0f, 1.0f},  // 2: bottom-right-front
		{0.0f, 0.0f, 1.0f},  // 3: bottom-left-front
		{0.0f, 1.0f, 0.0f},  // 4: top-left-back
		{1.0f, 1.0f, 0.0f},  // 5: top-right-back
		{1.0f, 1.0f, 1.0f},  // 6: top-right-front
		{0.0f, 1.0f, 1.0f}   // 7: top-left-front
	};

	// Transform corners: scale -> rotate -> translate (matching DrawModelEx)
	// DrawModelEx does: matTransform = scale * rotation * translation
	// This means rotation happens around origin (0,0,0) in model space, AFTER scaling
	Vector3 corners[8];
	for (int i = 0; i < 8; i++)
	{
		// Scale
		Vector3 scaled = Vector3{ localCorners[i].x * scale.x, localCorners[i].y * scale.y, localCorners[i].z * scale.z };
		// Rotate around origin (0,0,0) in model space
		// DrawModelEx expects degrees but receives rotationAngle (radians), so it does: angle*DEG2RAD
		// To match this, we need to apply the same conversion: rotationAngle * DEG2RAD
		Vector3 rotated = rotateY(scaled, rotationAngle * DEG2RAD);
		// Translate to world position
		corners[i] = Vector3Add(rotated, thisPos);
	}

	// Helper to offset a corner along a normal direction
	auto offsetCorner = [](Vector3 corner, Vector3 normal, float offset) -> Vector3 {
		return Vector3Add(corner, Vector3Scale(normal, offset));
	};

	// Draw top face (RED) - offset upward (+Y)
	Vector3 topNormal = {0, 1, 0};
	DrawLine3D(offsetCorner(corners[4], topNormal, gap), offsetCorner(corners[5], topNormal, gap), RED);
	DrawLine3D(offsetCorner(corners[5], topNormal, gap), offsetCorner(corners[6], topNormal, gap), RED);
	DrawLine3D(offsetCorner(corners[6], topNormal, gap), offsetCorner(corners[7], topNormal, gap), RED);
	DrawLine3D(offsetCorner(corners[7], topNormal, gap), offsetCorner(corners[4], topNormal, gap), RED);

	// Draw front face (GREEN) - offset forward (+Z)
	Vector3 frontNormal = {0, 0, 1};
	DrawLine3D(offsetCorner(corners[3], frontNormal, gap), offsetCorner(corners[2], frontNormal, gap), GREEN);
	DrawLine3D(offsetCorner(corners[2], frontNormal, gap), offsetCorner(corners[6], frontNormal, gap), GREEN);
	DrawLine3D(offsetCorner(corners[6], frontNormal, gap), offsetCorner(corners[7], frontNormal, gap), GREEN);
	DrawLine3D(offsetCorner(corners[7], frontNormal, gap), offsetCorner(corners[3], frontNormal, gap), GREEN);

	// Draw right face (BLUE) - offset right (+X)
	Vector3 rightNormal = {1, 0, 0};
	DrawLine3D(offsetCorner(corners[1], rightNormal, gap), offsetCorner(corners[2], rightNormal, gap), BLUE);
	DrawLine3D(offsetCorner(corners[2], rightNormal, gap), offsetCorner(corners[6], rightNormal, gap), BLUE);
	DrawLine3D(offsetCorner(corners[6], rightNormal, gap), offsetCorner(corners[5], rightNormal, gap), BLUE);
	DrawLine3D(offsetCorner(corners[5], rightNormal, gap), offsetCorner(corners[1], rightNormal, gap), BLUE);

	// Draw bottom face (RED) - offset downward (-Y)
	Vector3 bottomNormal = {0, -1, 0};
	DrawLine3D(offsetCorner(corners[0], bottomNormal, gap), offsetCorner(corners[1], bottomNormal, gap), RED);
	DrawLine3D(offsetCorner(corners[1], bottomNormal, gap), offsetCorner(corners[2], bottomNormal, gap), RED);
	DrawLine3D(offsetCorner(corners[2], bottomNormal, gap), offsetCorner(corners[3], bottomNormal, gap), RED);
	DrawLine3D(offsetCorner(corners[3], bottomNormal, gap), offsetCorner(corners[0], bottomNormal, gap), RED);

	// Draw back face (GREEN) - offset backward (-Z)
	Vector3 backNormal = {0, 0, -1};
	DrawLine3D(offsetCorner(corners[0], backNormal, gap), offsetCorner(corners[1], backNormal, gap), GREEN);
	DrawLine3D(offsetCorner(corners[1], backNormal, gap), offsetCorner(corners[5], backNormal, gap), GREEN);
	DrawLine3D(offsetCorner(corners[5], backNormal, gap), offsetCorner(corners[4], backNormal, gap), GREEN);
	DrawLine3D(offsetCorner(corners[4], backNormal, gap), offsetCorner(corners[0], backNormal, gap), GREEN);

	// Draw left face (BLUE) - offset left (-X)
	Vector3 leftNormal = {-1, 0, 0};
	DrawLine3D(offsetCorner(corners[0], leftNormal, gap), offsetCorner(corners[3], leftNormal, gap), BLUE);
	DrawLine3D(offsetCorner(corners[3], leftNormal, gap), offsetCorner(corners[7], leftNormal, gap), BLUE);
	DrawLine3D(offsetCorner(corners[7], leftNormal, gap), offsetCorner(corners[4], leftNormal, gap), BLUE);
	DrawLine3D(offsetCorner(corners[4], leftNormal, gap), offsetCorner(corners[0], leftNormal, gap), BLUE);
}


void ShapeEditorState::Draw()
{
	BeginDrawing();

	ClearBackground(Color{ 106, 90, 205, 255 });

	ShapeData* shapeData = &g_shapeTable[m_currentShape][m_currentFrame];

	BeginMode3D(g_camera);

	Vector3 cuboidScaling = shapeData->m_Scaling;
	cuboidScaling.x *= 2.5;
	cuboidScaling.y *= 2.5;
	cuboidScaling.z *= 2.5;

	Vector3 finalPos = Vector3Add(Vector3Add(g_camera.target, shapeData->m_TweakPos), Vector3{ shapeData->m_Dims.x / 2 - 1, 0, shapeData->m_Dims.z / 2 - 1 });

	shapeData->Draw(finalPos, g_cameraRotation, Color{255, 255, 255, 255}, cuboidScaling);

	// Draw colored wireframe outlines for cuboid faces
	if (shapeData->m_drawType == ShapeDrawType::OBJECT_DRAW_CUBOID)
	{
		DrawCuboidWireframe(finalPos, shapeData->m_Dims, shapeData->m_Scaling, g_cameraRotation);
	}

	DrawSphere(Vector3Add(shapeData->m_CenterPoint, finalPos), 0.15f, RED);

	EndMode3D();

	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({ 0, 0, 0, 0 });

	float scale = 2;

	//  Draw the minimap and marker

	if (shapeData->GetDrawType() == ShapeDrawType::OBJECT_DRAW_CUBOID)
	{
		Texture* d = shapeData->GetTexture();


		//  Draw original texture with label and border
		DrawTextEx(*g_guiFont.get(), "Original Texture", { 0, 0 }, g_guiFontSize, 1, WHITE);
		float yoffset = (g_guiFontSize + 2);
		DrawRectangleLinesEx({ 0, yoffset, float(d->width) * scale + scale + scale, float(d->height) * scale + scale + scale }, scale, WHITE);
		yoffset += scale;
		DrawTextureEx(*d, Vector2{ scale, yoffset }, 0, 2, Color{ 255, 255, 255, 255 });

		//  Draw rects on original texture showing top, front and right dimensions
		Rectangle fixedTopRect = shapeData->m_topTextureRect;
		fixedTopRect.x *= scale;
		fixedTopRect.x += scale - 1;
		fixedTopRect.y *= scale;
		fixedTopRect.y += yoffset - 1;
		fixedTopRect.width *= scale;
		fixedTopRect.width += scale;
		fixedTopRect.height *= scale;
		fixedTopRect.height += scale;

		DrawRectangleLinesEx(fixedTopRect, 1, RED);

		Rectangle fixedFrontRect = shapeData->m_frontTextureRect;
		fixedFrontRect.x += 1;
		fixedFrontRect.y *= scale;
		fixedFrontRect.y += yoffset - 2;
		fixedFrontRect.width *= scale;
		fixedFrontRect.width += scale;
		fixedFrontRect.height *= scale;
		fixedFrontRect.height += scale;

		DrawRectangleLinesEx(fixedFrontRect, 1, GREEN);

		Rectangle fixedRightRect = shapeData->m_rightTextureRect;
		fixedRightRect.x *= scale;
		fixedRightRect.x += scale - 1;
		//fixedRightRect.x += 1;
		fixedRightRect.y *= scale;
		fixedRightRect.y += yoffset - 1;
		fixedRightRect.width *= scale;
		fixedRightRect.width += scale;
		fixedRightRect.height *= scale;
		fixedRightRect.height += scale;

		DrawRectangleLinesEx(fixedRightRect, 1, BLUE);

		DrawTextureEx(*g_shapeTable[m_currentShape][m_currentFrame].GetCuboidTexture(), Vector2{ scale, yoffset + 10 + (d->height * scale) }, 0, 2, Color{ 255, 255, 255, 255 });

		////  Draw top texture with labels and borders
		Rectangle cuboidTopRect = shapeData->m_topTextureRect;
		cuboidTopRect.x = 1;
		cuboidTopRect.y = yoffset + 10 + (d->height * scale) - 1;
		cuboidTopRect.width *= scale;
		cuboidTopRect.width += scale;
		cuboidTopRect.height *= scale;
		cuboidTopRect.height += scale;

		DrawRectangleLinesEx(cuboidTopRect, 1, RED);

		Rectangle cuboidFrontRect = shapeData->m_frontTextureRect;
		cuboidFrontRect.x = 1;
		cuboidFrontRect.y = yoffset + 10 + (d->height * scale) - 1 + cuboidTopRect.height;
		cuboidFrontRect.width *= scale;
		cuboidFrontRect.width += scale;
		cuboidFrontRect.height *= scale;
		cuboidFrontRect.height += scale;

		DrawRectangleLinesEx(cuboidFrontRect, 1, GREEN);

		Rectangle cuboidRightRect = shapeData->m_rightTextureRect;
		cuboidRightRect.x = 1 + cuboidTopRect.width;
		cuboidRightRect.y = yoffset + 10 + (d->height * scale) - 1;
		cuboidRightRect.width *= scale;
		cuboidRightRect.width += scale;
		cuboidRightRect.height *= scale;
		cuboidRightRect.height += scale;

		DrawRectangleLinesEx(cuboidRightRect, 1, BLUE);
	}

	if (shapeData->GetDrawType() == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
	{
		Texture* d = shapeData->GetTexture();
		DrawTextureEx(*d, Vector2{ 0, 0 }, 0, scale, Color{ 255, 255, 255, 255 });
	}


	DrawConsole();

	int yOffset = g_guiFontSize;
	int y = -yOffset;

	m_currentGui->Draw();

	// Draw modal rename script window if visible
	if (m_renameScriptWindow && m_renameScriptWindow->IsVisible())
	{
		Log("Drawing rename window!");
		m_renameScriptWindow->Draw();
	}

	EndTextureMode();
	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	//  Draw any tooltips
	auto openScriptBtn = m_currentGui->GetElement(GE_OPENLUASCRIPTBUTTON);
	if (openScriptBtn && openScriptBtn->m_Hovered)
	{
		// Get the current frame's script name
		string currentScriptName = g_shapeTable[m_currentShape][m_currentFrame].m_luaScript;

		// Find the script path from the name
		string scriptPath = "";
		for (size_t i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
		{
			if (g_ScriptingSystem->m_scriptFiles[i].first == currentScriptName)
			{
				scriptPath = g_ScriptingSystem->m_scriptFiles[i].second;
				break;
			}
		}

		if (!scriptPath.empty())
		{
			string firstLine = GetFirstLineOfScript(scriptPath);

			if (!firstLine.empty() && g_guiFont && g_guiFont.get() != nullptr)
			{
				Vector2 mousePos = GetMousePosition();

				// Measure text size
				Vector2 textSize = MeasureTextEx(*g_guiFont.get(), firstLine.c_str(), 22.0f, 1);

				// Position tooltip to the left of cursor
				int tooltipX = mousePos.x - textSize.x - 10;
				int tooltipY = mousePos.y + 10;

				// Draw background
				DrawRectangle(tooltipX - 3, tooltipY - 3, textSize.x + 6, textSize.y + 6, Color{0, 0, 0, 230});
				DrawRectangleLines(tooltipX - 3, tooltipY - 3, textSize.x + 6, textSize.y + 6, WHITE);

				// Draw text
				DrawTextEx(*g_guiFont.get(), firstLine.c_str(), Vector2{(float)tooltipX, (float)tooltipY}, 22.0f, 1, YELLOW);
			}
		}
	}

	// Draw bark text above view angle slider (centered horizontally)
	int guiPanelWidth = 120;
	std::string barkText = GetShapeFrameName(m_currentShape, m_currentFrame, 1);
	int barkY = g_Engine->m_ScreenHeight - 63;  // Moved down 6 pixels from -65
	Vector2 barkTextSize = MeasureTextEx(*g_guiFont.get(), barkText.c_str(), 22.0f, 1);
	int barkX = ((g_Engine->m_ScreenWidth - guiPanelWidth) - (int)barkTextSize.x) / 2;  // Center in 3D view area
	DrawTextEx(*g_guiFont.get(), barkText.c_str(), {(float)barkX, (float)barkY}, 22.0f, 1, WHITE);

	// Draw view angle slider at bottom of main window
	int sliderWidth = 300;
	int sliderHeight = 20;
	int sliderX = ((g_Engine->m_ScreenWidth - guiPanelWidth) - sliderWidth) / 2;  // Center in 3D view area
	int sliderY = g_Engine->m_ScreenHeight - 40;

	// Draw slider background
	DrawRectangle(sliderX, sliderY, sliderWidth, sliderHeight, Color{64, 64, 128, 255});
	DrawRectangleLines(sliderX, sliderY, sliderWidth, sliderHeight, WHITE);

	// Draw label (larger font for readability)
	float labelFontSize = 22.0f;
	DrawTextEx(*g_guiFont.get(), "View Angle:", {(float)(sliderX - 120), (float)(sliderY)}, labelFontSize, 1, WHITE);

	// Calculate slider position
	int currentAngle = (int)(g_cameraRotation * RAD2DEG);
	while (currentAngle < 0) currentAngle += 360;
	while (currentAngle >= 360) currentAngle -= 360;

	int spurPos = (currentAngle * sliderWidth) / 360;
	DrawRectangle(sliderX + spurPos - 5, sliderY, 10, sliderHeight, WHITE);

	// Draw angle value (larger font for readability)
	DrawTextEx(*g_guiFont.get(), TextFormat("%d deg", currentAngle), {(float)(sliderX + sliderWidth + 10), (float)(sliderY)}, labelFontSize, 1, WHITE);

	DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);

	EndDrawing();
}

void ShapeEditorState::SetupBboardGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_bboardGui = make_unique<Gui>();

	m_bboardGui->m_Font = g_guiFont;
	m_bboardGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_bboardGui->m_InputScale = g_DrawScale;

	m_bboardGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_bboardGui.get());

	//  Billboard specific setup

	m_bboardGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "BBoard";
}

void ShapeEditorState::SetupFlatGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_flatGui = make_unique<Gui>();

	m_flatGui->m_Font = g_guiFont;
	m_flatGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_flatGui->m_InputScale = g_DrawScale;

	m_flatGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_flatGui.get());

	//  Flat specific setup

	int yoffset = 13;

	m_flatGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Flat";
}

void ShapeEditorState::SetupCuboidGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_cuboidGui = make_unique<Gui>();

	m_cuboidGui->m_Font = g_guiFont;
	m_cuboidGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_cuboidGui->m_InputScale = g_DrawScale;

	m_cuboidGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_cuboidGui.get());

	//  Cuboid specific setup

	m_cuboidGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Cuboid";

	int yoffset = 13;

	m_cuboidGui->AddTextArea(GE_TOPTEXTAREA, g_guiFont.get(), "Top Face", 3, y, 0, 0, RED);
	AddAutoStretchButton(m_cuboidGui.get(), GE_TOPRESET, 60, y - 2, " Reset ", g_guiFont.get());
	y += yoffset * .8f;

	m_cuboidGui->AddIconButton(GE_TOPXMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPXPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPXTEXTAREA, g_guiFont.get(), "X: " + to_string(int(shapeData.m_topTextureRect.x)), 14, y);

	m_cuboidGui->AddIconButton(GE_TOPYMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPYPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPYTEXTAREA, g_guiFont.get(), "Y: " + to_string(int(shapeData.m_topTextureRect.y)), 55, y);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_TOPWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPWIDTHTEXTAREA, g_guiFont.get(), "W: " + to_string(int(shapeData.m_topTextureRect.width)), 14, y);

	m_cuboidGui->AddIconButton(GE_TOPHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPHEIGHTPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPHEIGHTTEXTAREA, g_guiFont.get(), "H: " + to_string(int(shapeData.m_topTextureRect.height)), 55, y);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_FRONTTEXTAREA, g_guiFont.get(), "Front Face", 3, y, 0, 0, GREEN);
	AddAutoStretchButton(m_cuboidGui.get(), GE_FRONTRESET, 60, y - 2, " Reset ", g_guiFont.get());
	y += yoffset * .8f;

	m_cuboidGui->AddIconButton(GE_FRONTXMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTXPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTXTEXTAREA, g_guiFont.get(), "X: " + to_string(int(shapeData.m_topTextureRect.x)), 14, y);

	m_cuboidGui->AddIconButton(GE_FRONTYMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTYPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTYTEXTAREA, g_guiFont.get(), "Y: " + to_string(int(shapeData.m_topTextureRect.y)), 55, y);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_FRONTWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTWIDTHTEXTAREA, g_guiFont.get(), "W: " + to_string(int(shapeData.m_topTextureRect.width)), 14, y);

	m_cuboidGui->AddIconButton(GE_FRONTHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTHEIGHTPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTHEIGHTTEXTAREA, g_guiFont.get(), "H: " + to_string(int(shapeData.m_topTextureRect.height)), 55, y);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_RIGHTTEXTAREA, g_guiFont.get(), "Right Face", 3, y, 0, 0, BLUE);
	AddAutoStretchButton(m_cuboidGui.get(), GE_RIGHTRESET, 60, y - 2, " Reset ", g_guiFont.get());
	y += yoffset * .8f;

	m_cuboidGui->AddIconButton(GE_RIGHTXMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTXPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTXTEXTAREA, g_guiFont.get(), "X: " + to_string(int(shapeData.m_topTextureRect.x)), 14, y);

	m_cuboidGui->AddIconButton(GE_RIGHTYMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTYPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTYTEXTAREA, g_guiFont.get(), "Y: " + to_string(int(shapeData.m_topTextureRect.y)), 55, y);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_RIGHTWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTWIDTHTEXTAREA, g_guiFont.get(), "W: " + to_string(int(shapeData.m_topTextureRect.width)), 14, y);

	m_cuboidGui->AddIconButton(GE_RIGHTHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTHEIGHTPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTHEIGHTTEXTAREA, g_guiFont.get(), "H: " + to_string(int(shapeData.m_topTextureRect.height)), 55, y);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_TEXTUREASSIGNMENTTEXTAREA, g_guiFont.get(), "Texture Assignment:", 2, y);

	y += yoffset * .7f;

	m_cuboidGui->AddTextArea(GE_TOPSIDETEXTAREA, g_guiFont.get(), "Top", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVTOPBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_TOPSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTTOPBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_FRONTSIDETEXTAREA, g_guiFont.get(), "Front", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVFRONTBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_FRONTSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTFRONTBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_RIGHTSIDETEXTAREA, g_guiFont.get(), "Right", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVRIGHTBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTRIGHTBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_BOTTOMSIDETEXTAREA, g_guiFont.get(), "Bottom", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVBOTTOMBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_BOTTOMSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTBOTTOMBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_BACKSIDETEXTAREA, g_guiFont.get(), "Back", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVBACKBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_BACKSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTBACKBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_LEFTSIDETEXTAREA, g_guiFont.get(), "Left", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVLEFTBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_LEFTSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTLEFTBUTTON, 95, y, g_RightArrow);
}

void ShapeEditorState::SetupMeshGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_meshGui = make_unique<Gui>();

	m_meshGui->m_Font = g_guiFont;
	m_meshGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_meshGui->m_InputScale = g_DrawScale;

	m_meshGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_meshGui.get());

	//  Mesh specific setup

	m_meshGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Mesh";

	int yoffset = 13;

	m_meshGui->AddTextArea(GE_MODELTEXTAREA, g_guiFont.get(), "Model:", 2, y);

	y += yoffset;

	m_meshGui->AddIconButton(GE_PREVMODELBUTTON, 2, y, g_LeftArrow);
	m_meshGui->AddTextArea(GE_MODELNAMETEXTAREA, g_guiFont.get(), shapeData.m_customMeshName, 12, y);
	m_meshGui->AddIconButton(GE_NEXTMODELBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	m_meshGui->AddCheckBox(GE_MESHOUTLINECHECKBOX, 4, y, g_guiFont->baseSize, g_guiFont->baseSize);
	m_meshGui->GetElement(GE_MESHOUTLINECHECKBOX)->m_Selected = shapeData.m_meshOutline;
	m_meshGui->AddTextArea(GE_MESHOUTLINETEXTAREA, g_guiFont.get(), "Use Mesh Outline", 22, y);

}

void ShapeEditorState::SetupCharacterGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_characterGui = make_unique<Gui>();

	m_characterGui->m_Font = g_guiFont;
	m_characterGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_characterGui->m_InputScale = g_DrawScale;

	m_characterGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_characterGui.get());

	//  Character specific setup
	m_characterGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Character";
}

void ShapeEditorState::SetupShapePointerGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_shapePointerGui = make_unique<Gui>();

	m_shapePointerGui->m_Font = g_guiFont;
	m_shapePointerGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_shapePointerGui->m_InputScale = g_DrawScale;

	m_shapePointerGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_shapePointerGui.get());

	//  Shape Pointer specific setup

	m_shapePointerGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Pointer";

	int yoffset = 13;

	m_shapePointerGui->AddIconButton(GE_PREVSHAPEPOINTERBUTTON, 2, y, g_LeftArrow);
	m_shapePointerGui->AddIconButton(GE_NEXTSHAPEPOINTERBUTTON, 50, y, g_RightArrow);
	m_shapePointerGui->AddTextArea(GE_CURRENTSHAPEPOINTERIDTEXTAREA, g_guiFont.get(), "PS: " + to_string(m_currentShape), 12, y);

	m_shapePointerGui->AddIconButton(GE_PREVFRAMEPOINTERBUTTON, 62, y, g_LeftArrow);
	m_shapePointerGui->AddIconButton(GE_NEXTFRAMEPOINTERBUTTON, 110, y, g_RightArrow);
	m_shapePointerGui->AddTextArea(GE_CURRENTFRAMEPOINTERIDTEXTAREA, g_guiFont.get(), "PF: " + to_string(m_currentFrame), 71, y);

}

void ShapeEditorState::SetupDontDrawGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_dontDrawGui = make_unique<Gui>();

	m_dontDrawGui->m_Font = g_guiFont;
	m_dontDrawGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_dontDrawGui->m_InputScale = g_DrawScale;

	m_dontDrawGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	SetupCommonGui(m_dontDrawGui.get());

	//  Dont Draw specific setup
	m_dontDrawGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Don't Draw";
}

int ShapeEditorState::SetupCommonGui(Gui* gui)
{
	int yoffset = 13;
	int y = 4;

	AddAutoStretchButton(gui, GE_SAVEBUTTON, 8, y - 2, "  Save  ", g_guiFont.get());
	AddAutoStretchButton(gui, GE_LOADBUTTON, 64, y - 2, "  Load  ", g_guiFont.get());
	y += yoffset;

	gui->AddIconButton(GE_PREVSHAPEBUTTON, 2, y, g_LeftArrow);
	gui->AddIconButton(GE_NEXTSHAPEBUTTON, 60, y, g_RightArrow);
	std::stringstream ss;
    ss << std::uppercase << std::hex << m_currentShape;
	gui->AddTextArea(GE_CURRENTSHAPEIDTEXTAREA, g_guiFont.get(), "S:" + to_string(m_currentShape) + " (" + ss.str() + ")", 12, y);

	gui->AddIconButton(GE_PREVFRAMEBUTTON, 70, y, g_LeftArrow);
	gui->AddIconButton(GE_NEXTFRAMEBUTTON, 110, y, g_RightArrow);
	gui->AddTextArea(GE_CURRENTFRAMEIDTEXTAREA, g_guiFont.get(), "F:" + to_string(m_currentFrame), 80, y);

	y += yoffset;

	gui->AddTextArea(GE_DRAWTYPELABEL, g_guiFont.get(), "DrawType: ", 2, y);
	gui->AddIconButton(GE_PREVDRAWTYPE, 45, y, g_LeftArrow);
	gui->AddIconButton(GE_NEXTDRAWTYPE, 110, y, g_RightArrow);

	gui->AddTextArea(GE_CURRENTDRAWTYPETEXTAREA, g_guiFont.get(), "", 54, y);

	y += yoffset;

	AddAutoStretchButton(gui, GE_COPYPARAMSFROMFRAME0, 3, y - 2, "Copy From Frame 0", g_guiFont.get());

	y += yoffset;
	gui->AddTextArea(GE_TWEAKPOSITIONTEXTAREA, g_guiFont.get(), "Tweak Pos: ", 2, y);
	gui->AddTextArea(GE_TWEAKDIMENSIONSTEXTAREA, g_guiFont.get(), "Tweak Dims: ", 62, y);

	y += yoffset * .7f;

	gui->AddIconButton(GE_TWEAKXPLUSBUTTON, 2, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKXTEXTAREA, g_guiFont.get(), "X:", 11, y);
	gui->AddIconButton(GE_TWEAKXMINUSBUTTON, 50, y, g_RightArrow);

	std::ostringstream out;

	out.precision(1);
	gui->AddIconButton(GE_TWEAKWIDTHPLUSBUTTON, 62, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKWIDTHTEXTAREA, g_guiFont.get(), "W:", 71, y);
	gui->AddIconButton(GE_TWEAKWIDTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;

	gui->AddIconButton(GE_TWEAKYPLUSBUTTON, 2, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKYTEXTAREA, g_guiFont.get(), "Y:", 11, y);
	gui->AddIconButton(GE_TWEAKYMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	gui->AddIconButton(GE_TWEAKHEIGHTPLUSBUTTON, 62, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKHEIGHTTEXTAREA, g_guiFont.get(), "H:", 71, y);
	gui->AddIconButton(GE_TWEAKHEIGHTMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;

	gui->AddIconButton(GE_TWEAKZPLUSBUTTON, 2, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKZTEXTAREA, g_guiFont.get(), "Z:", 11, y);
	gui->AddIconButton(GE_TWEAKZMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	gui->AddIconButton(GE_TWEAKDEPTHPLUSBUTTON, 62, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKDEPTHTEXTAREA, g_guiFont.get(), "D:", 71, y);
	gui->AddIconButton(GE_TWEAKDEPTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	out.str("");
	out.precision(1);
	gui->AddTextArea(GE_TWEAKROTATIONTITLEAREA, g_guiFont.get(), "Tweak Rot:", 2, y);
	gui->AddIconButton(GE_TWEAKROTATIONPLUSBUTTON, 62, y, g_LeftArrow, g_LeftArrow, g_LeftArrow, "", g_guiFont.get(), Color{ 255, 255, 255, 255 }, 1, 1, true, true);
	gui->AddTextArea(GE_TWEAKROTATIONTEXTAREA, g_guiFont.get(), " ", 71, y);
	gui->AddIconButton(GE_TWEAKROTATIONMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset;
	AddAutoStretchButton(gui, GE_JUMPTOINSTANCE, 8, y - 2, "Jump To Instance", g_guiFont.get());

	y += yoffset;

	gui->AddTextArea(GE_LUASCRIPTLABEL, g_guiFont.get(), "Lua Script:", 2, y);
	AddAutoStretchButton(gui, GE_OPENLUASCRIPTBUTTON, 55, y - 2, "Open Script", g_guiFont.get());

	y += yoffset;

	gui->AddIconButton(GE_PREVLUASCRIPTBUTTON, 2, y, g_LeftArrow);
	gui->AddTextArea(GE_LUASCRIPTTEXTAREA, g_guiFont.get(), "", 12, y);
	gui->AddIconButton(GE_NEXTLUASCRIPTBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	AddAutoStretchButton(gui, GE_SETLUASCRIPTTOSHAPEIDBUTTON, 4, y - 2, "Set Script to ShapeID", g_guiFont.get());

	y += yoffset;

	AddAutoStretchButton(gui, GE_ADDALLFRAMESSCRIPTBUTTON, 4, y - 2, "Add All Frames", g_guiFont.get());
	AddAutoStretchButton(gui, GE_RENAMESCRIPTBUTTON, 80, y - 2, "Rename", g_guiFont.get());
	AddAutoStretchButton(gui, GE_CLEARSCRIPTBUTTON, 4, y + 11, "Clear Script", g_guiFont.get());
	AddAutoStretchButton(gui, GE_CLEARALLSCRIPTSBUTTON, 71, y + 11, "Clear All", g_guiFont.get());

	y += 27;

	return y;

}