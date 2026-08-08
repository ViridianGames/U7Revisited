#include "GameSerializer.h"
#include "Geist/Logging.h"
#include "Geist/ScriptingSystem.h"
#include "U7Globals.h"
#include "U7Player.h"
#include "U7Object.h"
#include "../ThirdParty/nlohmann/json.hpp"
#include <filesystem>
#include <sstream>
#include <iomanip>
#include <unordered_map>
#include <vector>
#include <memory>

using u7json = nlohmann::json;
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

		// Atomic save: write to temp, then rename over the slot (crash-safe).
		std::string filePath = BuildSaveFilePath(slotNumber, saveName);
		std::string tempPath = filePath + ".tmp";

		{
			std::ofstream file(tempPath, std::ios::binary | std::ios::trunc);
			if (!file.is_open())
			{
				SetError("Cannot write to save folder - check permissions");
				return false;
			}

			if (!SaveToStream(file, saveName))
			{
				file.close();
				std::error_code ec;
				fs::remove(tempPath, ec);
				return false;
			}
			file.flush();
			if (!file.good())
			{
				file.close();
				std::error_code ec;
				fs::remove(tempPath, ec);
				SetError("Failed to write complete save file");
				return false;
			}
			file.close();
		}

		// Remove any other file occupying this slot (different save name).
		std::string existingFile = GetSaveFilePath(slotNumber);
		if (!existingFile.empty() && existingFile != filePath && fs::exists(existingFile))
		{
			std::error_code ec;
			fs::remove(existingFile, ec);
		}

		// Replace destination with temp (rename is atomic on same filesystem).
		std::error_code ec;
		fs::remove(filePath, ec); // ignore if missing
		fs::rename(tempPath, filePath, ec);
		if (ec)
		{
			// Fallback: copy then remove temp
			fs::copy_file(tempPath, filePath, fs::copy_options::overwrite_existing, ec);
			fs::remove(tempPath, ec);
			if (ec)
			{
				SetError("Failed to finalize save file - " + ec.message());
				return false;
			}
		}

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

		// Session / camera (optional restore for continuity)
		saveData["session"]["combatMode"] = g_isCombatMode;
		saveData["session"]["camera"] = {
			{"target", { g_camera.target.x, g_camera.target.y, g_camera.target.z }},
			{"position", { g_camera.position.x, g_camera.position.y, g_camera.position.z }},
			{"distance", g_cameraDistance},
			{"rotation", g_cameraRotation}
		};

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

		// Save dynamic objects: anything that is not permanent scenery.
		// UNIT_TYPE_STATIC = immovable + unusable scenery only (see U7Object::Init).
		// Doors, scripted fixtures, pickups, NPCs, eggs, monsters are all saved.
		json objectsArray = json::array();
		for (const auto& [id, obj] : g_objectList)
		{
			// Skip null, dead, or static scenery
			if (obj == nullptr || obj->GetIsDead())
				continue;

			if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_STATIC)
				continue;

			objectsArray.push_back(obj->SaveToJson());
		}
		saveData["objects"] = objectsArray;

		// Global state
		saveData["nextObjectID"] = g_CurrentUnitID;

		// Save global flags
		json flagsArray = json::array();
		if (g_ScriptingSystem != nullptr)
		{
			for (const auto& [flagId, value] : g_ScriptingSystem->m_flags)
			{
				if (value)  // Only save flags that are set to true
					flagsArray.push_back(flagId);
			}
		}
		else
		{
			Log("GameSerializer::SaveToStream - WARNING: g_ScriptingSystem is null!");
		}
		saveData["flags"] = flagsArray;
		Log("GameSerializer::SaveToStream - Saved " + std::to_string(flagsArray.size()) + " true flags");

		//  Save NPCData structure


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
		// Parse and validate fully BEFORE mutating live world state.
		json saveData = json::parse(stream);

		if (!saveData.contains("version"))
		{
			SetError("Save file is incomplete or corrupted");
			return false;
		}

		std::string version = saveData["version"];
		// Accept 1.0.0 and future 1.x with optional new fields.
		if (version != "1.0.0" && version.rfind("1.", 0) != 0)
		{
			SetError("Save file is from a different version of the game (" + version + ")");
			return false;
		}

		if (!saveData.contains("objects") || !saveData["objects"].is_array())
		{
			SetError("Save file is missing objects data");
			return false;
		}
		if (!saveData.contains("player"))
		{
			SetError("Save file is missing player data");
			return false;
		}
		if (g_Player == nullptr)
		{
			SetError("Cannot load - player object is null");
			return false;
		}

		// Stage objects off-world first so a failed create does not wipe the live game.
		std::vector<std::unique_ptr<U7Object>> staged;
		staged.reserve(saveData["objects"].size());
		std::unordered_map<int, U7Object*> stagedById;

		// Snapshot egg configs from the live world before wipe. Older saves only stored
		// hasTriggered/shouldReset; monster shape and criteria came from FIXED.DAT at
		// world load. Matching by object id restores that config for incomplete saves.
		std::unordered_map<int, EggData> liveEggConfigById;
		for (const auto& [id, obj] : g_objectList)
		{
			if (obj && obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_EGG)
				liveEggConfigById[id] = obj->m_eggData;
		}

		for (const auto& objData : saveData["objects"])
		{
			U7Object* raw = U7Object::LoadFromJson(objData);
			if (raw == nullptr)
			{
				SetError("Save file contains an object that failed to load");
				return false;
			}
			if (stagedById.count(raw->m_ID))
			{
				delete raw;
				SetError("Save file has duplicate object id " + std::to_string(raw->m_ID));
				return false;
			}

			// Back-fill egg config when the save lacked full egg fields.
			if (raw->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_EGG &&
			    !objData.contains("m_monsterShape") &&
			    !objData.contains("m_eggType"))
			{
				auto eggIt = liveEggConfigById.find(raw->m_ID);
				if (eggIt != liveEggConfigById.end())
				{
					const bool hasTriggered = raw->m_eggData.m_hasTriggered;
					const bool shouldReset = raw->m_eggData.m_shouldReset;
					raw->m_eggData = eggIt->second;
					raw->m_eggData.m_hasTriggered = hasTriggered;
					raw->m_eggData.m_shouldReset = shouldReset;
				}
			}

			stagedById[raw->m_ID] = raw;
			staged.emplace_back(raw);
		}

		// ---- Commit point: mutate live world ----

		// Stop scripts before destroying objects they may reference.
		if (g_ScriptingSystem)
			g_ScriptingSystem->ClearAllCoroutines();

		// Clear dynamic objects; keep permanent static scenery.
		auto it = g_objectList.begin();
		while (it != g_objectList.end())
		{
			if (it->second == nullptr || it->second->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_STATIC)
				it = g_objectList.erase(it);
			else
				++it;
		}

		// Insert staged objects
		for (auto& up : staged)
		{
			int id = up->m_ID;
			g_objectList[id] = std::move(up);
		}
		staged.clear();
		stagedById.clear();

		// Game time
		if (saveData.contains("gameTime"))
		{
			g_hour = saveData["gameTime"].value("hour", 0);
			g_minute = saveData["gameTime"].value("minute", 0);
			g_scheduleTime = saveData["gameTime"].value("scheduleTime", 0);
		}

		if (saveData.contains("nextObjectID"))
			g_CurrentUnitID = saveData["nextObjectID"];

		// Rewire NPCData -> object ID (map lookup, not size()).
		for (const auto& [id, obj] : g_objectList)
		{
			if (!obj || obj->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_NPC)
				continue;
			auto npcIt = g_NPCData.find(obj->m_NPCID);
			if (npcIt != g_NPCData.end() && npcIt->second)
				npcIt->second->m_objectID = obj->m_ID;
		}

		// Player (uses SetPos for avatar; rebuilds party names)
		g_Player->LoadFromJson(saveData["player"]);

		// Second pass: inventories + equipment (validate IDs exist)
		for (const auto& objData : saveData["objects"])
		{
			int objId = objData.value("id", -1);
			auto oit = g_objectList.find(objId);
			if (objId == -1 || oit == g_objectList.end() || !oit->second)
				continue;

			U7Object* obj = oit->second.get();

			if (objData.contains("inventoryIds") && objData["inventoryIds"].is_array())
			{
				obj->m_inventory.clear();
				for (int itemId : objData["inventoryIds"])
				{
					if (g_objectList.find(itemId) != g_objectList.end())
						obj->m_inventory.push_back(itemId);
					else
						Log("LoadFromStream: dropping missing inventory id " + std::to_string(itemId) +
							" from container " + std::to_string(objId));
				}
			}

			if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC &&
			    obj->m_NPCData != nullptr &&
			    objData.contains("equipment"))
			{
				const auto& equipment = objData["equipment"];
				auto setEq = [&](const char* key, EquipmentSlot slot)
				{
					if (!equipment.contains(key)) return;
					int itemId = equipment[key].get<int>();
					if (itemId == -1 || g_objectList.find(itemId) != g_objectList.end())
						obj->m_NPCData->SetEquippedItem(slot, itemId);
				};
				setEq("HEAD", EquipmentSlot::SLOT_HEAD);
				setEq("NECK", EquipmentSlot::SLOT_NECK);
				setEq("TORSO", EquipmentSlot::SLOT_TORSO);
				setEq("LEGS", EquipmentSlot::SLOT_LEGS);
				setEq("HANDS", EquipmentSlot::SLOT_HANDS);
				setEq("FEET", EquipmentSlot::SLOT_FEET);
				setEq("LEFT_HAND", EquipmentSlot::SLOT_LEFT_HAND);
				setEq("RIGHT_HAND", EquipmentSlot::SLOT_RIGHT_HAND);
				setEq("AMMO", EquipmentSlot::SLOT_AMMO);
				setEq("LEFT_RING", EquipmentSlot::SLOT_LEFT_RING);
				setEq("RIGHT_RING", EquipmentSlot::SLOT_RIGHT_RING);
				setEq("BELT", EquipmentSlot::SLOT_BELT);
				setEq("BACKPACK", EquipmentSlot::SLOT_BACKPACK);
			}
		}

		// Flags (only trues are stored)
		if (g_ScriptingSystem != nullptr)
		{
			g_ScriptingSystem->m_flags.clear();
			if (saveData.contains("flags") && saveData["flags"].is_array())
			{
				for (int flagId : saveData["flags"])
					g_ScriptingSystem->m_flags[flagId] = true;
				Log("GameSerializer::LoadFromStream - Restored " +
					std::to_string(saveData["flags"].size()) + " flags");
			}
		}

		// Session / camera
		if (saveData.contains("session"))
		{
			const auto& session = saveData["session"];
			if (session.contains("combatMode"))
				g_isCombatMode = session["combatMode"].get<bool>();
			if (session.contains("camera"))
			{
				const auto& cam = session["camera"];
				if (cam.contains("target") && cam["target"].is_array() && cam["target"].size() == 3)
				{
					g_camera.target.x = cam["target"][0];
					g_camera.target.y = cam["target"][1];
					g_camera.target.z = cam["target"][2];
				}
				if (cam.contains("position") && cam["position"].is_array() && cam["position"].size() == 3)
				{
					g_camera.position.x = cam["position"][0];
					g_camera.position.y = cam["position"][1];
					g_camera.position.z = cam["position"][2];
				}
				if (cam.contains("distance"))
					g_cameraDistance = cam["distance"].get<float>();
				if (cam.contains("rotation"))
					g_cameraRotation = cam["rotation"].get<float>();
			}
		}

		int staticCount = 0, objectCount = 0, npcCount = 0, totalCount = 0;
		for (const auto& [id, obj] : g_objectList)
		{
			if (!obj) continue;
			totalCount++;
			if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_STATIC)
				staticCount++;
			else if (obj->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
				npcCount++;
			else
				objectCount++;
		}

		Log("GameSerializer::LoadFromStream - g_objectList: " + std::to_string(totalCount) +
		    " (" + std::to_string(staticCount) + " static, " +
		    std::to_string(objectCount) + " objects, " + std::to_string(npcCount) + " NPCs)");

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
