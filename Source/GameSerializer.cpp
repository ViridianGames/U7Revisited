#include "GameSerializer.h"
#include "Geist/Logging.h"
#include "Geist/ScriptingSystem.h"
#include "U7Globals.h"
#include "U7Player.h"
#include "U7Object.h"
#include <json.hpp>
#include <filesystem>
#include <sstream>
#include <iomanip>

using json = nlohmann::json;
namespace fs = std::filesystem;

// Static member initialization
std::string GameSerializer::s_lastError = "";

// ============================================================================
// Error Handling
// ============================================================================

void GameSerializer::SetError(const std::string& error)
{
	s_lastError = error;
	Log("GameSerializer Error: " + error);
}

std::string GameSerializer::GetLastError()
{
	return s_lastError;
}

// ============================================================================
// Filename Sanitization
// ============================================================================

std::string GameSerializer::SanitizeSaveName(const std::string& name)
{
	std::string sanitized;

	for (char c : name)
	{
		// Replace Windows reserved characters with underscore
		// Reserved: < > : " / \ | ? *
		// Also replace control characters (ASCII 0-31)
		if (c < 32 || c == '<' || c == '>' || c == ':' || c == '"' ||
		    c == '/' || c == '\\' || c == '|' || c == '?' || c == '*')
		{
			sanitized += '_';
		}
		else
		{
			sanitized += c;
		}
	}

	// Trim trailing spaces and periods (Windows doesn't allow these at end)
	while (!sanitized.empty() && (sanitized.back() == ' ' || sanitized.back() == '.'))
	{
		sanitized.pop_back();
	}

	// Ensure we have a valid filename
	if (sanitized.empty())
	{
		sanitized = "save";
	}

	return sanitized;
}

// ============================================================================
// File Path Helpers
// ============================================================================

std::string GameSerializer::BuildSaveFilePath(int slotNumber, const std::string& saveName)
{
	std::string sanitizedName = SanitizeSaveName(saveName);
	return "Saves/" + std::to_string(slotNumber) + "_" + sanitizedName + ".json";
}

std::string GameSerializer::GetSaveFilePath(int slotNumber)
{
	// Scan directory for file matching "{slot}_*.json" pattern
	std::string saveDir = "Saves";
	std::string slotPrefix = std::to_string(slotNumber) + "_";

	try
	{
		if (!fs::exists(saveDir))
		{
			return "";
		}

		for (const auto& entry : fs::directory_iterator(saveDir))
		{
			if (entry.is_regular_file())
			{
				std::string filename = entry.path().filename().string();
				// Check if filename starts with slot number and ends with .json
				if (filename.substr(0, slotPrefix.length()) == slotPrefix &&
					filename.length() > 5 &&
					filename.substr(filename.length() - 5) == ".json")
				{
					return entry.path().string();
				}
			}
		}
	}
	catch (const std::exception& e)
	{
		Log("GameSerializer::GetSaveFilePath - Exception: " + std::string(e.what()));
	}

	return "";
}

// ============================================================================
// Slot Query Methods
// ============================================================================

bool GameSerializer::DoesSaveExist(int slotNumber)
{
	// Validate slot number (0-9 for 10 slots)
	if (slotNumber < 0 || slotNumber > 9)
	{
		return false;
	}

	std::string filePath = GetSaveFilePath(slotNumber);
	return !filePath.empty();
}

std::string GameSerializer::GetSaveName(int slotNumber)
{
	// Validate slot number
	if (slotNumber < 0 || slotNumber > 9)
	{
		return "";
	}

	std::string filePath = GetSaveFilePath(slotNumber);
	if (filePath.empty())
	{
		return "";
	}

	// Extract filename from path
	fs::path path(filePath);
	std::string filename = path.filename().string();

	// Find the underscore after slot number
	size_t underscorePos = filename.find('_');
	if (underscorePos == std::string::npos)
	{
		return "";
	}

	// Extract the save name (between underscore and .json)
	size_t jsonPos = filename.rfind(".json");
	if (jsonPos == std::string::npos || jsonPos <= underscorePos + 1)
	{
		return "";
	}

	// Return the save name as-is (no decoding needed since we just sanitize, not encode)
	return filename.substr(underscorePos + 1, jsonPos - underscorePos - 1);
}

time_t GameSerializer::GetSaveTimestamp(int slotNumber)
{
	// Validate slot number
	if (slotNumber < 0 || slotNumber > 9)
	{
		return 0;
	}

	std::string filePath = GetSaveFilePath(slotNumber);
	if (filePath.empty())
	{
		return 0;
	}

	try
	{
		auto ftime = fs::last_write_time(filePath);
		// Convert file_time to time_t
		auto sctp = std::chrono::time_point_cast<std::chrono::system_clock::duration>(
			ftime - fs::file_time_type::clock::now() + std::chrono::system_clock::now());
		return std::chrono::system_clock::to_time_t(sctp);
	}
	catch (const std::exception& e)
	{
		Log("GameSerializer::GetSaveTimestamp - Exception: " + std::string(e.what()));
		return 0;
	}
}

// ============================================================================
// Save/Load Operations
// ============================================================================

bool GameSerializer::SaveGame(int slotNumber, const std::string& saveName)
{
	// Validate slot number (0-9)
	if (slotNumber < 0 || slotNumber > 9)
	{
		SetError("Invalid save slot number");
		return false;
	}

	// Validate save name
	if (saveName.empty())
	{
		SetError("Save name cannot be empty");
		return false;
	}

	if (saveName.length() > 64)
	{
		SetError("Save name is too long - maximum 64 characters");
		return false;
	}

	try
	{
		// Ensure save directory exists
		std::string saveDir = "Saves";
		if (!fs::exists(saveDir))
		{
			fs::create_directories(saveDir);
		}

		// Delete any existing save file for this slot
		std::string existingFile = GetSaveFilePath(slotNumber);
		if (!existingFile.empty() && fs::exists(existingFile))
		{
			fs::remove(existingFile);
		}

		// Build new save file path
		std::string filePath = BuildSaveFilePath(slotNumber, saveName);

		// Open file for writing
		std::ofstream file(filePath);
		if (!file.is_open())
		{
			SetError("Cannot write to save folder - check permissions");
			return false;
		}

		// Write save data
		if (!SaveToStream(file, saveName))
		{
			file.close();
			// Try to clean up failed save file
			if (fs::exists(filePath))
			{
				fs::remove(filePath);
			}
			return false;
		}

		file.close();
		Log("GameSerializer::SaveGame - Successfully saved to " + filePath);
		return true;
	}
	catch (const std::exception& e)
	{
		SetError("Failed to save game - " + std::string(e.what()));
		return false;
	}
}

bool GameSerializer::LoadGame(int slotNumber)
{
	// Validate slot number (0-9)
	if (slotNumber < 0 || slotNumber > 9)
	{
		SetError("Invalid save slot number");
		return false;
	}

	// Find save file
	std::string filePath = GetSaveFilePath(slotNumber);
	if (filePath.empty())
	{
		SetError("No save file found in this slot");
		return false;
	}

	try
	{
		// Open file for reading
		std::ifstream file(filePath);
		if (!file.is_open())
		{
			SetError("Cannot read save file");
			return false;
		}

		// Load save data
		if (!LoadFromStream(file))
		{
			file.close();
			return false;
		}

		file.close();
		Log("GameSerializer::LoadGame - Successfully loaded from " + filePath);
		return true;
	}
	catch (const std::exception& e)
	{
		SetError("Failed to load game - " + std::string(e.what()));
		return false;
	}
}

bool GameSerializer::SaveToStream(std::ofstream& stream, const std::string& saveName)
{
	try
	{
		json saveData;

		// Version and metadata
		saveData["version"] = "1.0.0";

		// Timestamp (ISO 8601 format)
		auto now = std::chrono::system_clock::now();
		auto time = std::chrono::system_clock::to_time_t(now);
		std::tm tm;
		#ifdef _WIN32
		localtime_s(&tm, &time);
		#else
		localtime_r(&time, &tm);
		#endif
		char timestamp[32];
		strftime(timestamp, sizeof(timestamp), "%Y-%m-%dT%H:%M:%S", &tm);
		saveData["timestamp"] = timestamp;

		// Game time
		saveData["gameTime"]["hour"] = g_hour;
		saveData["gameTime"]["minute"] = g_minute;
		saveData["gameTime"]["scheduleTime"] = g_scheduleTime;

		// Player state
		if (g_Player != nullptr)
		{
			saveData["player"] = g_Player->SaveToJson();
		}
		else
		{
			SetError("Cannot save - player object is null");
			return false;
		}

		// Save dynamic objects only (filter out UNIT_TYPE_STATIC)
		json objectsArray = json::array();
		for (const auto& [id, obj] : g_objectList)
		{
			// Skip null or dead objects
			if (obj == nullptr || obj->GetIsDead())
				continue;

			// Only save dynamic objects
			if (obj->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_STATIC)
			{
				// Skip terrain tiles (shape < 150)
				if (obj->m_ObjectType >= 150)
				{
					objectsArray.push_back(obj->SaveToJson());
				}
			}
		}
		saveData["objects"] = objectsArray;

		// Global state
		saveData["nextObjectID"] = g_CurrentUnitID;

		// Save global flags
		json flagsArray = json::array();
		if (g_ScriptingSystem != nullptr)
		{
			Log("GameSerializer::SaveToStream - Saving " + std::to_string(g_ScriptingSystem->m_flags.size()) + " total flags");
			for (const auto& [flagId, value] : g_ScriptingSystem->m_flags)
			{
				if (value)  // Only save flags that are set to true
				{
					flagsArray.push_back(flagId);
					Log("GameSerializer::SaveToStream - Saving flag " + std::to_string(flagId) + " = true");
				}
			}
		}
		else
		{
			Log("GameSerializer::SaveToStream - WARNING: g_ScriptingSystem is null!");
		}
		saveData["flags"] = flagsArray;
		Log("GameSerializer::SaveToStream - Saved " + std::to_string(flagsArray.size()) + " flags that are set to true");

		// Write to stream with indentation for readability
		stream << saveData.dump(2);

		Log("GameSerializer::SaveToStream - Saved " + std::to_string(objectsArray.size()) + " objects");
		return true;
	}
	catch (const json::exception& e)
	{
		SetError("JSON serialization error - " + std::string(e.what()));
		return false;
	}
	catch (const std::exception& e)
	{
		SetError("Failed to create save file - " + std::string(e.what()));
		return false;
	}
}

bool GameSerializer::LoadFromStream(std::ifstream& stream)
{
	try
	{
		// Parse JSON
		json saveData = json::parse(stream);

		// Validate version
		if (!saveData.contains("version"))
		{
			SetError("Save file is incomplete or corrupted");
			return false;
		}

		std::string version = saveData["version"];
		if (version != "1.0.0")
		{
			SetError("Save file is from a different version of the game");
			return false;
		}

		// Restore game time
		if (saveData.contains("gameTime"))
		{
			g_hour = saveData["gameTime"].value("hour", 0);
			g_minute = saveData["gameTime"].value("minute", 0);
			g_scheduleTime = saveData["gameTime"].value("scheduleTime", 0);
		}

		// Restore player state
		if (!saveData.contains("player"))
		{
			SetError("Save file is missing player data");
			return false;
		}

		if (g_Player != nullptr)
		{
			g_Player->LoadFromJson(saveData["player"]);
		}
		else
		{
			SetError("Cannot load - player object is null");
			return false;
		}

		// Clear dynamic objects from g_objectList
		auto it = g_objectList.begin();
		while (it != g_objectList.end())
		{
			// Skip null entries
			if (it->second == nullptr)
			{
				it = g_objectList.erase(it);
				continue;
			}

			if (it->second->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_STATIC)
			{
				it = g_objectList.erase(it);
			}
			else
			{
				++it;
			}
		}

		// First pass: Create all objects
		if (!saveData.contains("objects") || !saveData["objects"].is_array())
		{
			SetError("Save file is missing objects data");
			return false;
		}

		for (const auto& objData : saveData["objects"])
		{
			U7Object* obj = U7Object::LoadFromJson(objData);
			if (obj != nullptr)
			{
				g_objectList[obj->m_ID] = std::unique_ptr<U7Object>(obj);
			}
		}

		// Second pass: Restore relationships (inventories, equipment, containers)
		for (const auto& objData : saveData["objects"])
		{
			int objId = objData.value("id", -1);
			if (objId == -1 || g_objectList.find(objId) == g_objectList.end())
				continue;

			U7Object* obj = g_objectList[objId].get();

			// Restore inventory
			if (objData.contains("inventoryIds") && objData["inventoryIds"].is_array())
			{
				obj->m_inventory.clear();
				for (int itemId : objData["inventoryIds"])
				{
					obj->m_inventory.push_back(itemId);
				}
			}

			// Restore equipment for NPCs
			if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC &&
			    obj->m_NPCData != nullptr &&
			    objData.contains("equipment"))
			{
				const auto& equipment = objData["equipment"];
				if (equipment.contains("HEAD")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_HEAD, equipment["HEAD"]);
				if (equipment.contains("NECK")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_NECK, equipment["NECK"]);
				if (equipment.contains("TORSO")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_TORSO, equipment["TORSO"]);
				if (equipment.contains("LEGS")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_LEGS, equipment["LEGS"]);
				if (equipment.contains("HANDS")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_HANDS, equipment["HANDS"]);
				if (equipment.contains("FEET")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_FEET, equipment["FEET"]);
				if (equipment.contains("LEFT_HAND")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_LEFT_HAND, equipment["LEFT_HAND"]);
				if (equipment.contains("RIGHT_HAND")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_RIGHT_HAND, equipment["RIGHT_HAND"]);
				if (equipment.contains("AMMO")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_AMMO, equipment["AMMO"]);
				if (equipment.contains("LEFT_RING")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_LEFT_RING, equipment["LEFT_RING"]);
				if (equipment.contains("RIGHT_RING")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_RIGHT_RING, equipment["RIGHT_RING"]);
				if (equipment.contains("BELT")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_BELT, equipment["BELT"]);
				if (equipment.contains("BACKPACK")) obj->m_NPCData->SetEquippedItem(EquipmentSlot::SLOT_BACKPACK, equipment["BACKPACK"]);
			}
		}

		// Restore global state
		if (saveData.contains("nextObjectID"))
		{
			g_CurrentUnitID = saveData["nextObjectID"];
		}

		// Restore global flags
		if (g_ScriptingSystem != nullptr)
		{
			g_ScriptingSystem->m_flags.clear();  // Clear all flags first
			if (saveData.contains("flags") && saveData["flags"].is_array())
			{
				Log("GameSerializer::LoadFromStream - Loading " + std::to_string(saveData["flags"].size()) + " flags");
				for (int flagId : saveData["flags"])
				{
					g_ScriptingSystem->m_flags[flagId] = true;
					Log("GameSerializer::LoadFromStream - Loaded flag " + std::to_string(flagId) + " = true");
				}
			}
			else
			{
				Log("GameSerializer::LoadFromStream - No flags found in save file");
			}
		}
		else
		{
			Log("GameSerializer::LoadFromStream - WARNING: g_ScriptingSystem is null!");
		}

		Log("GameSerializer::LoadFromStream - Loaded " + std::to_string(saveData["objects"].size()) + " objects");

		// Debug: Count objects by type in g_objectList after loading
		int staticCount = 0, objectCount = 0, npcCount = 0, totalCount = 0;
		for (const auto& [id, obj] : g_objectList)
		{
			if (obj != nullptr)
			{
				totalCount++;
				if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_STATIC)
					staticCount++;
				else if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
					npcCount++;
				else
					objectCount++;
			}
		}
		Log("GameSerializer::LoadFromStream - g_objectList now has " + std::to_string(totalCount) +
		    " total objects: " + std::to_string(staticCount) + " static, " +
		    std::to_string(objectCount) + " objects, " + std::to_string(npcCount) + " NPCs");

		return true;
	}
	catch (const json::parse_error&)
	{
		SetError("Save file is corrupted or unreadable");
		return false;
	}
	catch (const json::exception& e)
	{
		SetError("Failed to parse save file - " + std::string(e.what()));
		return false;
	}
	catch (const std::exception& e)
	{
		SetError("Failed to load game - " + std::string(e.what()));
		return false;
	}
}
