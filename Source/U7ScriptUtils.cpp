#include "U7ScriptUtils.h"
#include "U7Globals.h"
#include "MainState.h"
#include "ShapeEditorState.h"
#include "Geist/Logging.h"
#include "Geist/ScriptingSystem.h"

#include <string>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <filesystem>

using namespace std;

extern unique_ptr<ScriptingSystem> g_ScriptingSystem;

namespace U7ScriptUtils
{
	void RenameScript(const string& oldScript, const string& newName)
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

		g_ScriptingSystem->SortScripts();
		Log("RenameScript: Scripting system reinitialized, loaded " + std::to_string(g_ScriptingSystem->m_scriptFiles.size()) + " scripts");

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
}
