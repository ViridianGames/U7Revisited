#ifndef _GAMESERIALIZER_H_
#define _GAMESERIALIZER_H_

#include <string>
#include <fstream>
#include <ctime>

class GameSerializer
{
public:
	// Query save slot status
	static bool DoesSaveExist(int slotNumber);
	static std::string GetSaveName(int slotNumber);  // Parse save name from filename
	static time_t GetSaveTimestamp(int slotNumber);   // Read last modified time

	// Save/Load operations
	static bool SaveGame(int slotNumber, const std::string& saveName);
	static bool LoadGame(int slotNumber);

	// Error handling
	static std::string GetLastError();  // Returns user-friendly error message from last failed operation

	// Low-level serialization (called by Save/LoadGame)
	static bool SaveToStream(std::ofstream& stream, const std::string& saveName);
	static bool LoadFromStream(std::ifstream& stream);

	// Filename sanitization (replaces Windows reserved characters with underscores)
	static std::string SanitizeSaveName(const std::string& name);

private:
	static std::string s_lastError;  // Stores last error message

	static void SetError(const std::string& error);  // Internal helper to set error message
	static std::string GetSaveFilePath(int slotNumber);  // Scans directory for "{slot}_*.json"
	static std::string BuildSaveFilePath(int slotNumber, const std::string& saveName);  // Returns "Saves/3_My_Save.json"
};

#endif // _GAMESERIALIZER_H_
