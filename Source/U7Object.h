#ifndef _U7OBJECT_H_
#define _U7OBJECT_H_

#include "Geist/Globals.h"
#include "Geist/BaseUnits.h"
#include <string>
#include <list>
#include "lua.h"
#include "U7Globals.h"
#include "../ThirdParty/nlohmann/json.hpp"

using u7json = nlohmann::json;

struct ObjectData;
enum class ObjectTypes;
enum class ShapeDrawType;
class ShapeData;
struct NPCSchedule;

enum class EquipmentSlot
{
	SLOT_HEAD = 0,
	SLOT_NECK,
	SLOT_TORSO,
	SLOT_LEGS,
	SLOT_HANDS,
	SLOT_FEET,
	SLOT_LEFT_HAND, // Shield
	SLOT_RIGHT_HAND, // Weapon
	SLOT_AMMO,
	SLOT_LEFT_RING,
	SLOT_RIGHT_RING,
	SLOT_BELT,
	SLOT_BACKPACK,
	SLOT_COUNT
};

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
	unsigned short id;
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
	std::vector<std::vector<Texture *> > m_walkTextures;

	int m_currentActivity;
	int m_lastActivity = -1; // Track last activity to detect changes
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


// EggType - Main behavior of the egg
enum class EggType
{
	MonsterSpawner = 0,
	ProximitySound,
	Jukebox,
	Voice,
	Weather,
	Teleporter,
	Path,
	Usecode,
	// Add more as needed for the demo and beyond
};

enum class EggCriteria : uint8_t
{
	CachedIn = 0, // Default / cached in memory (internal trigger)
	PartyNear = 1,
	AvatarNear = 2,
	AvatarFar = 3,
	AvatarFootpad = 4,
	PartyFootpad = 5,
	SomethingOn = 6,
	External = 7,
};

struct EggData
{
	EggType type = EggType::MonsterSpawner;
	EggCriteria criteria = EggCriteria::CachedIn; // MUST have at least this
	uint8_t distance = 8;
	uint8_t probability = 100;
	bool hasTriggered = false;
	bool onceOnly = false;
	bool nocturnal = false;
	bool autoReset = false;

	uint8_t specificValue = 0;
	std::string audioFile;
	int usecodeFunc = 0;

	// Monster spawner extras (optional)
	int monsterShape = 0;
	int monsterFrame = 0;
	int spawnCount = 1;
	float spawnChance = 1.0f;

	// Teleport extras
	Vector3 teleportDest = {0, 0, 0};
	int destMap = 0;
};

class U7Object : public Unit3D
{
public:
	enum class UnitTypes
	{
		UNIT_TYPE_STATIC = 0,
		// Static objects cannot be changed.  They cannot be moved, created or destroyed. They may have animations or lighting effects but are otherwise unchanging.  They do not have inventories or scripts.
		UNIT_TYPE_OBJECT,
		// Generic object, can be moved, created and destroyed.  May have an inventory.  May have an attached Lua script.  Clever use of scripts can make these objects behave like NPCs, but that should be discouraged.
		UNIT_TYPE_NPC,
		// Non-player character, can move, can have schedules and conversations, and has an inventory.  May have an attached Lua script.  Monsters are considered NPCs.
		UNIT_TYPE_EGG,
		// "Eggs" are what would be called "triggers" in later games.  They are invisible, intangible objects that "hatch" and run scripts when the player interacts with them or enters their bounding box.
		UNIT_TYPE_LAST
	};

	U7Object()
		: m_Pos({0.0f, 0.0f, 0.0f})
		  , m_Dest({0.0f, 0.0f, 0.0f})
		  , m_Direction({0.0f, 0.0f, 0.0f})
		  , m_Scaling({1.0f, 1.0f, 1.0f})
		  , m_anchorPos({0.0f, 0.0f, 0.0f})
		  , m_ExternalForce({0.0f, 0.0f, 0.0f})
		  , m_Angle(0.0f)
		  , m_ObjectType(0)
		  , m_Frame(0)
		  , m_Quality(0)
		  , m_Visible(false)
		  , m_Selected(false)
		  , m_BaseSpeed(0.0f)
		  , m_BaseMaxHP(0.0f)
		  , m_BaseHP(0.0f)
		  , m_BaseAttack(0.0f)
		  , m_BaseDefense(0.0f)
		  , m_BaseTeam(0.0f)
		  , m_speed(0.0f)
		  , m_hp(0.0f)
		  , m_combat(0.0f)
		  , m_magic(0.0f)
		  , m_Team(0)
		  , m_GravityFlag(false)
		  , m_ExternalForceFlag(false)
		  , m_BounceFlag(false)
		  , m_Mesh(nullptr)
		  , m_Texture(nullptr)
		  , m_DropShadow(nullptr)
		  , m_ObjectConfig(nullptr)
		  , m_drawType(ShapeDrawType(0))
		  , m_shapeData(nullptr)
		  , m_objectData(nullptr)
		  , m_distanceFromCamera(0.0)
		  , m_boundingBox({0})
		  , m_terrainCenterPoint({0.0f, 0.0f, 0.0f})
		  , m_centerPoint({0.0f, 0.0f, 0.0f})
		  , m_isNPC(false)
		  , m_isContainer(false)
		  , m_isContained(false)
		  , m_containingObjectId(-1)
		  , m_hasConversationTree(false)
		  , m_hasGump(false)
		  , m_isEgg(false)
		  , m_NPCID(-1)
		  , m_InventoryPos({0.0f, 0.0f})
	{
	}

	virtual ~U7Object();

	virtual void Init(const std::string &configfile, int unitType, int frame);

	virtual void Shutdown();

	virtual void Update();

	virtual void Draw();

	virtual void Attack(int unitid);

	virtual Vector3 GetPos() { return m_Pos; }
	virtual Vector2 GetChunkPos() { return Vector2{floor(m_Pos.x / 16), floor(m_Pos.z / 16)}; }
	virtual Vector3 GetDest() { return m_Dest; }
	virtual float GetSpeed() { return m_speed; }

	void SetInitialPos(Vector3 pos);

	virtual void SetPos(Vector3 pos);

	virtual void SetDest(Vector3 pos);

	void PathfindToDest(Vector3 dest); // Use A* pathfinding to reach dest (fire-and-forget)
	int PathfindToDestTracked(Vector3 dest); // Returns request ID for tracking (used by Lua)
	virtual void SetSpeed(float speed) { m_speed = speed; }

	void SetFrame(int frame); // Change object frame (e.g., for doors)

	void Interact(int event);

	bool GetIsMoving() { return m_isMoving; }

	float Pick(); //  Returns distance if hit, -1 if no hit
	float PickXYZ(Vector3 &pos); // Returns distance and hit point in pos.

	bool AddObjectToInventory(int objectid);

	bool RemoveObjectFromInventory(int objectid);

	bool IsInInventoryById(int objectid);

	bool IsInInventory(int shape, int frame = -1, int quality = -1);

	void NPCUpdate();

	void NPCDraw();

	void NPCInit(NPCData *npcData);

	void TryOpenDoorAtCurrentPosition();

	void EggUpdate();

	void HandleMonsterSpawnerEgg();

	void HandleProximitySoundEgg();

	void HandleJukeboxEgg();

	void HandleVoiceEgg();

	void HandleWeatherEgg();

	void HandleTeleporterEgg();

	void HandlePathEgg();

	void HandleUsecodeEgg();

	void SetOverrideFrame(int overrideFrame)
	{
		m_overrideFrame = overrideFrame;
		m_isFrameOverridden = true;
	}

	void ClearOverrideFrame()
	{
		m_isFrameOverridden = false;
		m_overrideFrame = 0;
	}

	void CheckLighting();

	bool IsLocked();

	bool IsMagicLocked();

	void SetFrames(int framex, int framey)
	{
		m_currentFrameX = framex;
		m_currentFrameY = framey;
	}

	// Serialization
	json SaveToJson() const;

	static U7Object *LoadFromJson(const json &j);

	Vector3 m_Pos;
	Vector3 m_Dest;
	Vector3 m_Direction;
	Vector3 m_Scaling;
	Vector3 m_anchorPos;

	// Pathfinding
	std::vector<Vector3> m_pathWaypoints; // Queue of waypoints to follow
	int m_currentWaypointIndex = 0; // Which waypoint we're moving toward
	bool m_isSchedulePath = false; // True for C++ schedule paths, false for Lua activity paths
	bool m_pathfindingPending = false; // True while waiting for pathfinding to complete

	Vector3 m_ExternalForce;

	float m_Angle;

	UnitTypes m_UnitType = UnitTypes::UNIT_TYPE_OBJECT;
	int m_ObjectType;
	int m_Frame;
	int m_Quality;

	bool m_isFrameOverridden = false;
	int m_overrideFrame = 0;
	bool m_Visible; // This is set to false for objects that are out of range or otherwise not visible
	bool m_ShouldDraw = true; // This is an override that can be set in a Lua script.
	bool m_Selected;

	float m_BaseSpeed;
	float m_BaseMaxHP;
	float m_BaseHP;
	float m_BaseAttack;
	float m_BaseDefense;
	float m_BaseTeam;

	float m_speed;
	float m_hp;
	float m_combat;
	float m_magic;
	int m_Team;

	bool m_GravityFlag;
	bool m_ExternalForceFlag;
	bool m_BounceFlag;

	unsigned int m_flags = 0; // General-purpose flags bitfield for Exult intrinsics

	Mesh *m_Mesh;
	Texture *m_Texture;
	Texture *m_DropShadow;
	std::unique_ptr<Mesh> m_customMesh = nullptr;

	Config *m_ObjectConfig;

	ShapeDrawType m_drawType;
	ShapeData *m_shapeData;
	ObjectData *m_objectData;

	double m_distanceFromCamera;

	Color m_color = WHITE;

	BoundingBox m_boundingBox;
	Vector3 m_terrainCenterPoint;
	Vector3 m_centerPoint;

	bool m_isNPC;
	bool m_isContainer;
	bool m_isContained;
	int m_containingObjectId;
	bool m_hasConversationTree;
	bool m_hasGump;
	bool m_isEgg;

	int m_NPCID;

	bool m_isLit = true;

	Vector2 m_InventoryPos;
	bool m_isSorted = false;
	bool m_shouldBeSorted = true;

	NPCData *m_NPCData = nullptr;

	bool m_followingSchedule = false;
	int m_lastSchedule = -1;
	int m_currentFrameX = 0;
	int m_currentFrameY = 0;

	EggData m_eggData;

	std::vector<int> m_inventory; //  Each entry is the ID of an object in the object list

	float m_totalWeight = 0.0f; // 0.0f = cache invalid, needs recalc

	float GetWeight(); // Recursive cached weight calculation
	void InvalidateWeightCache(); // Invalidate this object + parent chain
	float GetRemainingCarryCapacity(); // How much more weight can this NPC carry (max - current)

	unsigned int m_scheduleTime = 0;
	unsigned int m_currentActivity = 0;
	bool m_movingToActivity = false;
	bool m_isMoving = false;
	bool m_isPaused = true;

		// Per-NPC contiguous index used for deterministic batching of activity script updates.
		// Assigned at NPCInit time to guarantee a compact range [0..N).
		int m_npcBatchIndex = -1;
};

#endif
