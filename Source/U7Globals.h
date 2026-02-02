///////////////////////////////////////////////////////////////////////////
//
// Name:     U7GLOBALS.H
// Author:   Anthony Salter
// Date:     12/31/23
// Purpose:  Game-specific globals.
///////////////////////////////////////////////////////////////////////////

#ifndef _U7Globals_H_
#define _U7Globals_H_

// Debug flag for NPC pathfinding statistics
#define DEBUG_NPC_PATHFINDING

#include <list>
#include <vector>
#include <string>
#include <unordered_map>
#include <array>
#include <queue>
#include <shared_mutex>

#include "Geist/Primitives.h"
#include "Geist/RNG.h"
#include "ConversationState.h"
#include "GumpManager.h"
#include "MainState.h"
#include "Terrain.h"
#include "ShapeData.h"
#include "U7Object.h"
#include "raylib.h"
#include "raymath.h"
#include "U7Player.h"
#include "U7GumpPaperdoll.h"

//class ConversationState;
class MainState;

struct coords
{
	int x, y;
};

enum GameStates
{
	STATE_LOADINGSTATE = 0,
	STATE_TITLESTATE,
	STATE_MAINSTATE,
	STATE_OPTIONSSTATE,
	STATE_SHAPEEDITORSTATE,
	STATE_CREDITS,
	STATE_CONVERSATIONSTATE,
	STATE_SCRIPTRENAMESTATE,
	STATE_LOADSAVESTATE,
	STATE_ASKEXITSTATE,
	STATE_ASKSAVESTATE,
	STATE_LASTSTATE
};

extern std::string g_gameStateStrings[];

extern std::string g_objectDrawTypeStrings[];

extern bool g_LuaDebug;
extern bool g_showScriptedObjects;

// enum class ObjectTypes
// {
// 	OBJECT_STATIC = 0,   // Static objects cannot be changed.  They cannot be moved, created or destroyed.
// 	OBJECT_CREATURE,
// 	OBJECT_WEAPON,
// 	OBJECT_ARMOR,
// 	OBJECT_CONTAINER,
// 	OBJECT_QUESTobject_,
// 	OBJECT_KEY,
// 	OBJECTobject_
// };

enum class EngineModes
{
	ENGINE_MODE_BLACK_GATE = 0,
	ENGINE_MODE_SERPENT_ISLE,
	ENGINE_MODE_LAST_MODE
};

extern std::string g_engineModeStrings[];

extern std::string g_objectTypeStrings[];

extern float g_lastTime;
extern unsigned int g_hour;
extern unsigned int g_minute;
extern unsigned int g_scheduleTime;
extern float g_secsPerMinute;

// NPC pathfinding queue system
extern std::queue<int> g_npcPathfindQueue;  // Queue of NPC IDs needing pathfinding
extern int g_lastScheduleTimeCheck;          // Last schedule time we checked

extern Color g_dayNightColor;
extern bool g_isDay;

struct ObjectData
{
	//  From wgtvol.dat
	float m_weight;
	float m_volume;

	//  From tfa.dat
	bool m_hasSoundEffect;
	bool m_rotatable;
	bool m_isAnimated;
	bool m_isNotWalkable;
	bool m_isWater;
	float m_height;
	float m_width;
	float m_depth;
	bool m_isTrap;
	bool m_isDoor;
	bool m_isVehiclePart;
	bool m_isNotSelectable;
	bool m_isLightSource;
	bool m_isTranslucent;
	char m_shapeType;

	//  From text.flx
	std::string m_name;

	//std::unique_ptr<Mesh> m_mesh = nullptr;
};

// Misc names from TEXT.FLX (entries 1024+) for frame-specific item names
extern std::vector<std::string> g_miscNames;

// Get the name for a specific shape, frame, and quantity
std::string GetShapeFrameName(int shape, int frame, int quantity = 1);

// Get the display name for an object (handles quantity calculation)
std::string GetObjectDisplayName(U7Object* object);

// Find NPC script by NPC ID (returns script name or empty string)
// Only matches scripts starting with "npc_" and ending with "_XXXX" where XXXX is the NPC ID
std::string FindNPCScriptByID(int npcID);

// Get the script name for any object (handles both NPCs and regular objects)
// Returns empty string if object has no script or uses "default"
std::string GetObjectScriptName(U7Object* object);


//  Here's how schedules work:
//  Each NPC has a schedule that is a list of time indices.  Time indices can only be from 0 - 8 and represent three hour blocks of the day.
//  At that time, the NPC's activity flag will change to the activity specified in the schedule, and the NPC will move to the destination specified in the schedule.
//  The activity flag is a number that corresponds to a specific activity, such as "sleeping", "eating", "working", etc.
//  For a lot of flags, the activity simply changes the NPC's behavior in their Lua script, but some activities also trigger movement to a specific location.
//  For instance, "pace horizontal" and "pace vertical" will cause the NPC to move back and forth while the activity is active.
struct NPCSchedule
{
	unsigned int m_destX;
	unsigned int m_destY;
	unsigned int m_time;
	unsigned int m_activity;
};

extern std::unordered_map<int, std::vector<NPCSchedule> > g_NPCSchedules;

// Helper function to initialize NPC activities based on current schedule time
void InitializeNPCActivitiesFromSchedules();

//////////////////////////////////////////////////////////////////////////////
//  SPELL SYSTEM
//////////////////////////////////////////////////////////////////////////////

/// @brief Reagent definition structure
struct ReagentData
{
	std::string name;                 // "Black Pearl", "Blood Moss", etc.
	int frame;                        // Frame number in shape 842
};

/// @brief Spell data structure matching spells.json format
struct SpellData
{
	int id;                           // Unique spell ID (0-63)
	std::string name;                 // "Awaken All", "Create Food", etc.
	int x;                            // X coordinate in gumps.png for spell icon
	int y;                            // Y coordinate in gumps.png for spell icon
	std::string words;                // "Vas An Zu", "In Mani Ylem", etc.
	int scriptId;                     // Script shape ID (320-391)
	std::vector<std::string> reagents; // Reagent names: "Ginseng", "Garlic", etc.
	std::string desc;                 // Spell description
	int circle;                       // Which circle this spell belongs to (1-8)
};

/// @brief Circle data structure (8 circles, each with 8 spells)
struct SpellCircle
{
	int circle;                       // Circle number (1-8)
	std::string name;                 // "First Circle", "Second Circle", etc.
	std::vector<SpellData> spells;    // 8 spells in this circle
};

// Spell data loaded from spells.json
extern std::vector<ReagentData> g_reagentData;        // 8 reagents
extern std::vector<SpellCircle> g_spellCircles;       // 8 circles with 8 spells each
extern std::unordered_map<int, SpellData*> g_spellMap; // Quick lookup by spell ID

// Load spell data from Redist/Data/spells.json
void LoadSpellData();

// Get spell data by ID (0-63)
SpellData* GetSpellData(int spellId);

//////////////////////////////////////////////////////////////////////////////

enum class EquipmentSlot
{
	SLOT_HEAD = 0,
	SLOT_NECK,
	SLOT_TORSO,
	SLOT_LEGS,
	SLOT_HANDS,
	SLOT_FEET,
	SLOT_LEFT_HAND,    // Shield
	SLOT_RIGHT_HAND,   // Weapon
	SLOT_AMMO,
	SLOT_LEFT_RING,
	SLOT_RIGHT_RING,
	SLOT_BELT,
	SLOT_BACKPACK,
	SLOT_COUNT
};

// Helper functions to determine equipment slots from item shape ID
void LoadEquipmentSlotsConfig();
std::vector<EquipmentSlot> GetEquipmentSlotsForShape(int shapeId);
std::vector<EquipmentSlot> GetEquipmentSlotsFilled(int shapeId); // Returns all slots this item occupies when equipped
EquipmentSlot GetEquipmentSlotForShape(int shapeId); // Deprecated: returns first valid slot only

struct NPCData
{
	unsigned char x;
	unsigned char y;
	unsigned short shapeId;
	unsigned short type;
	unsigned char proba;
	unsigned short data1;
	unsigned char lift;
	unsigned short data2;

	unsigned short index;
	unsigned short referent;
	unsigned short status;
	unsigned char str;
	unsigned char dex;
	unsigned char iq;
	unsigned char combat;
	unsigned char magic;
	unsigned char DAM;
	char soak1[3];
	unsigned short status2;
	unsigned char id;
	char soak2[2];
	unsigned int xp;
	unsigned char training;
	unsigned short primary;
	unsigned short secondary;
	unsigned short oppressor;
	unsigned short ivrx;
	unsigned short ivry;
	unsigned short svrx;
	unsigned short svry;
	unsigned short status3;
	char soak3[5];
	unsigned char acty;
	char soak4[29];
	unsigned char SN;
	unsigned char V1;
	unsigned char V2;
	unsigned char food;
	char soak5[7];
	char name[16];
	std::vector<int> m_schedule;
	std::vector<std::vector<Texture*> > m_walkTextures;

	int m_currentActivity;
	int m_lastActivity = -1;  // Track last activity to detect changes
	int m_objectID;

	// Equipment system - maps slot to object ID (-1 = empty slot)
	std::map<EquipmentSlot, int> m_equipment;

	// Helper methods
	int GetEquippedItem(EquipmentSlot slot) const
	{
		auto it = m_equipment.find(slot);
		return (it != m_equipment.end()) ? it->second : -1;
	}

	void SetEquippedItem(EquipmentSlot slot, int objectId);
	void UnequipItem(EquipmentSlot slot);

	bool HasItemEquipped(EquipmentSlot slot) const
	{
		auto it = m_equipment.find(slot);
		return (it != m_equipment.end() && it->second != -1);
	}
};

extern std::string g_version;

extern Vector3 g_Gravity;

extern Texture* g_Cursor;
extern Texture* g_objectSelectCursor;
extern Texture* g_EmptyTexture; // Empty 4x4 texture for hidden/empty slots

extern std::shared_ptr<Font> g_Font;
extern std::shared_ptr<Font> g_SmallFont;
extern std::shared_ptr<Font> g_ConversationFont;
extern std::shared_ptr<Font> g_ConversationSmallFont;
extern std::shared_ptr<Font> g_guiFont;

extern float g_fontSize;
extern float g_guiFontSize;

extern std::unique_ptr<RNG> g_VitalRNG;
extern std::unique_ptr<RNG> g_NonVitalRNG;

extern std::unique_ptr<Terrain> g_Terrain;

extern std::unordered_map<int, std::unique_ptr<U7Object> > g_objectList;

extern unsigned int g_CurrentUnitID;  // Next available object ID for dynamic objects
extern unsigned int g_CurrentUpdate;

extern bool g_CameraMoved;

extern std::unordered_map<int, int[16][16] > g_ChunkTypeList;  // The 16x16 tiles for each chunk type
extern int g_chunkTypeMap[192][192]; // The type of each chunk in the map
extern std::vector<U7Object*> g_chunkObjectMap[192][192]; // The objects in each chunk
extern std::shared_mutex g_chunkMapMutex; // Protects g_chunkObjectMap for thread-safe pathfinding

extern std::array<std::array<ShapeData, 32>, 1024> g_shapeTable;
extern std::array<ObjectData, 1024> g_objectDataTable;
extern std::unordered_map<int, std::unique_ptr<NPCData> > g_NPCData;

extern std::array<int, 1024> g_isObjectMoveable;        // Maps item shape ID to valid equipment slots

// Weather/effect sprite data structure
struct SpriteFrame {
	Image image;
	Texture2D texture;
	int width;
	int height;
	int xOffset;
	int yOffset;
};

extern std::array<std::vector<SpriteFrame>, 32> g_spriteTable;  // 32 sprite shapes, each with multiple frames

extern std::vector<U7Object*> g_sortedVisibleObjects;

extern unsigned int g_minimapSize;

extern std::unique_ptr<U7Player> g_Player;

extern std::vector< std::vector<unsigned short> > g_World;

extern std::vector< std::vector<Texture> > g_walkFrames;

extern std::unique_ptr<Model> g_CuboidModel;

void DrawOutlinedText(std::shared_ptr<Font> font, const std::string& text, Vector2 position, float fontSize, int spacing, Color color);

void DrawParagraph(std::shared_ptr<Font> font, const std::string& text, Vector2 position, float maxwidth, float fontSize, int spacing, Color color, bool outlined = false);

void DebugPrint(std::string text);

void NPCDebugPrint(std::string text);  // Writes to npcdebug.log instead of debuglog.txt

float GetDistance(float startX, float startZ, float endX, float endZ);

bool IsDistanceLessThan(float startX, float startZ, float endX, float endZ, float range);

void MakeAnimationFrameMeshes();

extern bool g_isCameraLockedToAvatar;

void LockCamera();

void UnlockCamera();

void CameraUpdate(bool forcemove = false);

void CameraInput();

void IsCellVisible(float x, float y);

void IsPointVisible(float x, float y);

U7Object* GetObjectFromID(int unitID);

U7Object* GetObjectUnderMouse();

/// @brief Find the root NPC owner of a container (follows parent chain to find NPC)
/// @param container The container object to start from
/// @return The root NPC object, or nullptr if no NPC found in parent chain
U7Object* GetRootNPCFromContainer(U7Object* container);

/// @brief Calculate max carry weight from strength stat
/// @param strength The strength value
/// @return Maximum weight that can be carried (2 * strength)
float GetMaxWeightFromStrength(int strength);

U7Object* U7ObjectClassFactory(int type);

void PopulateLocationMap();

/// @brief Update an object's chunk when it has moved
/// @param object The object that moved
/// @param fromPos The object's prevous position
void UpdateObjectChunk(U7Object* object, Vector3 fromPos);

/// @brief Assign an object into a chunk (world partition for visibility).
/// @param object The object to assign
void AssignObjectChunk(U7Object* object);
void UnassignObjectChunk(U7Object* object);

void UpdateSortedVisibleObjects();

Vector3 GetRadialVector(float partitions, float thispartition);

U7Object* AddObject(int shapenum, int framenum, int id, float x, float y, float z);

void AddObjectToContainer(int objectID, int containerID);

unsigned int GetNextID();

bool WasMouseButtonDoubleClicked(int button);

void OpenURL(const std::string& url);

extern Vector3 g_terrainUnderMousePointer;

extern std::unique_ptr<GumpManager> g_gumpManager;

extern U7Object* g_objectUnderMousePointer;
extern bool g_mouseOverUI;  // True when mouse is over any UI element (blocks world interaction)

extern U7Object* g_doubleClickedObject;

//////////////////////////////////////////////////////////////////////////////
//  CONSOLE
//////////////////////////////////////////////////////////////////////////////

struct ConsoleString
{
	std::string m_String;
	Color m_Color;
	unsigned int m_StartTime;
};

extern std::vector<ConsoleString> g_ConsoleStrings;

void ClearConsole();

void AddConsoleString(std::string string, Color color, float starttime);

void AddConsoleString(std::string string, Color color = Color{ 255, 255, 255, 255 });

void SaveShapeTable();

void DrawConsole();

void DrawWorld();  // Draws 3D world and terrain (used by MainState and modal dialogs)

//int l_add_dialogue(lua_State* L);

extern ConversationState* g_ConversationState;
extern MainState* g_mainState;

extern bool g_autoRotate;

//////////////////////////////////////////////////////////////////////////////

extern float g_DrawScale;

extern float g_CameraRotateSpeed;
extern Vector3 g_CameraMovementSpeed;

//////////////////////////////////////////////////////////////////////////////
//  GUI ELEMENTS
//////////////////////////////////////////////////////////////////////////////

extern std::shared_ptr<Sprite> g_BoxTL;
extern std::shared_ptr<Sprite> g_BoxT;
extern std::shared_ptr<Sprite> g_BoxTR;
extern std::shared_ptr<Sprite> g_BoxL;
extern std::shared_ptr<Sprite> g_BoxC;
extern std::shared_ptr<Sprite> g_BoxR;
extern std::shared_ptr<Sprite> g_BoxBL;
extern std::shared_ptr<Sprite> g_BoxB;
extern std::shared_ptr<Sprite> g_BoxBR;

extern std::vector<std::shared_ptr<Sprite> > g_Borders;
extern std::vector<std::shared_ptr<Sprite> > g_ConversationBorders;

extern std::shared_ptr<Sprite> g_InactiveButtonL;
extern std::shared_ptr<Sprite> g_InactiveButtonM;
extern std::shared_ptr<Sprite> g_InactiveButtonR;
extern std::shared_ptr<Sprite> g_ActiveButtonL;
extern std::shared_ptr<Sprite> g_ActiveButtonM;
extern std::shared_ptr<Sprite> g_ActiveButtonR;

extern std::shared_ptr<Sprite> g_ShapeButtonL;
extern std::shared_ptr<Sprite> g_ShapeButtonM;
extern std::shared_ptr<Sprite> g_ShapeButtonR;

extern std::shared_ptr<Sprite> g_LeftArrow;
extern std::shared_ptr<Sprite> g_RightArrow;

extern std::shared_ptr<Sprite> g_gumpBackground;
extern std::shared_ptr<Sprite> g_gumpCheckmarkUp;
extern std::shared_ptr<Sprite> g_gumpCheckmarkDown;

extern std::shared_ptr<Sprite> g_GitHubButton;
extern std::shared_ptr<Sprite> g_XButton;
extern std::shared_ptr<Sprite> g_YouTubeButton;
extern std::shared_ptr<Sprite> g_PatreonButton;
extern std::shared_ptr<Sprite> g_KoFiButton;

extern std::shared_ptr<Texture2D> g_statsBackground;

extern std::shared_ptr<Sprite> g_gumpNumberBarBackground;
extern std::shared_ptr<Sprite> g_gumpNumberBarMarker;
extern std::shared_ptr<Sprite> g_gumpNumberBarRightArrow;
extern std::shared_ptr<Sprite> g_gumpNumberBarLeftArrow;

extern Color g_Red;
extern Color g_Blue;
extern Color g_Pink;
extern Color g_LightBlue;
extern Color g_Brown;
extern Color g_Purple;
extern Color g_Green;
extern Color g_Gray;
extern Color g_DarkGray;
extern Color g_Black;
extern Color g_White;

extern int g_selectedShape;
extern int g_selectedFrame;

extern Shader g_alphaDiscard;

extern bool g_pixelated;
extern RenderTexture2D g_renderTarget;
extern RenderTexture2D g_guiRenderTarget;


//////////////////////////////////////////////////////////////////////////////
///  CAMERA SETTINGS AND RELATED FUNCTIONS
//////////////////////////////////////////////////////////////////////////////

extern Camera g_camera;

extern bool g_hasCameraChanged;

// --- FIRST PERSON CAMERA ---
extern bool g_firstPersonEnabled;    // Toggleable first-person view
extern float g_firstPersonHeight;    // Eye height above avatar center
extern float g_firstPersonFOV;       // FOV when in first-person
extern float g_firstPersonYaw;       // Yaw (radians) for first-person look
extern float g_firstPersonPitch;     // Pitch (radians) for first-person look (unused by default)
extern float g_firstPersonMoveSpeed; // Movement speed while in first-person
//extern bool g_firstPersonPreserveCenter;
//extern Vector3 g_firstPersonFocus; // world coords of the center-of-screen to preserve when entering 1st person

extern float g_cameraDistance; // distance from target
extern float g_cameraRotation; // angle around target
extern float g_cameraRotationTarget;

extern EngineModes g_engineMode;

void RecalculateCamera();

//////////////////////////////////////////////////////////////////////////////
///  PATHFINDING
//////////////////////////////////////////////////////////////////////////////

class PathfindingGrid;
class AStar;
class PathfindingThreadPool;
extern PathfindingGrid* g_pathfindingGrid;
extern AStar* g_aStar;
extern PathfindingThreadPool* g_pathfindingThreadPool;

// Maximum height difference NPCs can climb/descend between adjacent tiles
const float MAX_CLIMBABLE_HEIGHT = 1.0f;

// Movement cost for walking on objects (stairs, platforms, etc.) - replaces terrain cost
const float CLIMB_MOVEMENT_COST = 2.0f;

// Maximum height for walkable surface objects to be considered (filters out upper floors)
const float MAX_WALKABLE_SURFACE_HEIGHT = 5.0f;

// Call this whenever ANY object changes position or state
void NotifyPathfindingGridUpdate(int worldX, int worldZ, int radius = 1);

extern bool g_allowInput;

#ifdef DEBUG_NPC_PATHFINDING
struct NPCPathStats
{
	int npcID;
	Vector3 startPos;
	Vector3 endPos;
	float distance;
	int waypointCount;
};
extern std::unordered_map<int, NPCPathStats> g_npcMaxPathStats;
void PrintNPCPathStats();
#endif

#endif