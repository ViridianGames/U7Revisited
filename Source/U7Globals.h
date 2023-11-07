///////////////////////////////////////////////////////////////////////////
//
// Name:     PLANITIAGLOBLAS.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  Game-specific globals.
///////////////////////////////////////////////////////////////////////////

#pragma warning(disable:4786)

#ifndef _U7Globals_H_
#define _U7Globals_H_

#include <list>
#include <vector>
#include <string>
#include <unordered_map>
#include <array>

//#include "tinyxml2.h"
#include "Primitives.h"
#include "Font.h"
#include "RNG.h"
#include "Terrain.h"
#include "U7Unit.h"
#include "U7Object.h"

#ifdef WIN32
//#include "WindowsIncludes.h"
#else
#endif

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
	STATE_LASTSTATE
};

enum GameEvents
{
	//  Networking Events
	GE_ADDPLAYER = 0,
	GE_SETGAMETYPE,
	GE_SERVERSENTEVENTS,
	GE_CLIENTACKEVENTS,
	GE_SERVERADVANCETURN,
	GE_PLAYERCHAT,
	GE_PLAYERPAUSED,

	//  Game events
	GE_ADDUNIT,
	GE_SETUNITTARGET,
	GE_SETUNITEXTERNALFORCE,
	GE_BOUNCEUNIT,
	GE_TURNUNIT,
	GE_LINKUNITTOMASTER,
	GE_DAMAGEUNIT,
	GE_HEALUNIT,

	//  Miscellaneous events
	GE_USERINPUTON,
	GE_USERINPUTOFF,

	LASTGAMEEVENT
};

enum UnitTypes
{
	//  Main gameplay units
	UNIT_UNIT = 0, //  Default unit type; no specialized behavior.
	UNIT_ARCHER,
	UNIT_ARROW,
	UNIT_BARBARIAN,
	UNIT_GENERAL,
	UNIT_VILLAGE,
	UNIT_WALKER,
	UNIT_WARRIOR,

	//  Decorative units
	UNIT_BIRD,
	UNIT_ROCK,
	UNIT_SHEEP,
	UNIT_TREE,

	//  God power units
	UNIT_EARTHQUAKE,
	UNIT_FLAMESTRIKE,
	UNIT_FLAMERING,
	UNIT_HEALINGLIGHT,
	UNIT_GOLEM,
	UNIT_LIGHTNING,
	UNIT_METEOR,
	UNIT_TORNADO,
	UNIT_VOLCANO,

	UNIT_LASTUNITTYPE
};

enum class ObjectDrawTypes
{
	OBJECT_DRAW_BILLBOARD = 0,
	OBJECT_DRAW_CROSSBILLBOARD,
	OBJECT_DRAW_CUBOID,
	OBJECT_DRAW_FLAT,
	OBJECT_DRAW_CUSTOM_MESH
};

enum class ObjectTypes
{
	OBJECT_STATIC = 0,
	OBJECT_CREATURE,  // Every creature in the game is also a container and an item.
	OBJECT_WEAPON,
	OBJECT_ARMOR,
	OBJECT_CONTAINER,
	OBJECT_QUEST_ITEM,
	OBJECT_KEY,
	OBJECT_ITEM
};

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
};

struct PairHash
{
	std::size_t operator()(const std::pair<int, int>& pair) const
	{
		return pair.first * INT_MAX + pair.second;
	}
};

struct Coord
{
	Coord(int newx, int newy) { x = newx; y = newy; }
	int x;
	int y;
};

//  This class represents a single buff/debuff
struct Buff
{
	bool m_IsBuff; //  If this is false, it's actually a debuff.
	int m_ValueToMod;
	float m_ModValue;
	int m_Ticks;
};

extern glm::vec3 g_Gravity;

extern Mesh* g_AnimationFrames;
extern Texture* g_WalkerTexture;
extern Texture* g_WalkerMask;
extern Texture* g_Sprites;
extern Texture* g_Cursor;

extern std::shared_ptr<Font> g_Font;
extern std::shared_ptr<Font> g_SmallFont;

extern std::unique_ptr<RNG> g_VitalRNG;
extern std::unique_ptr<RNG> g_NonVitalRNG;

extern std::unique_ptr<Terrain> g_Terrain;

extern std::unordered_map<int, std::shared_ptr<U7Unit> > g_UnitList;

extern std::unordered_map<int, std::shared_ptr<U7Object> > g_ObjectList;

extern std::string GameEventStrings[LASTGAMEEVENT + 1];
extern std::string UnitTypeStrings[UNIT_LASTUNITTYPE + 1];

extern Mesh* g_TestMesh;

extern unsigned int g_CurrentUpdate;

extern bool g_IsSinglePlayer;  //  not single payer
extern bool g_IsServer;
extern bool g_CameraMoved;

extern std::array<std::array<Texture* , 32>, 1024> g_shapeTable;
extern std::array<ObjectData, 1024> g_objectTable;

extern unsigned int g_minimapSize;

extern std::vector< std::vector<unsigned short> > g_World;

float GetDistance(float startX, float startZ, float endX, float endZ);

bool IsDistanceLessThan(float startX, float startZ, float endX, float endZ, float range);

float Lerp(float a, float b, float t);

void MakeAnimationFrameMeshes();

void DoCameraMovement();

void IsCellVisible(float x, float y);

void IsPointVisible(float x, float y);

std::shared_ptr<U7Unit> GetPointerFromID(int unitID);

std::shared_ptr<U7Unit> U7UnitClassFactory(int type);

extern std::unordered_map<std::pair<int, int>, std::vector<std::shared_ptr<U7Unit> >, PairHash > g_LocationMap;
//extern std::vector<shared_ptr<U7Unit> >* g_LocationMap;

void PopulateLocationMap();

std::vector<std::shared_ptr<U7Unit> > GetAllUnitsWithinRange(float x, float y, int range);

glm::vec3 GetRadialVector(float partitions, float thispartition);

//void DoGodPower(int power, float x, float y, int player, bool charging);

void SendGodPower(int power, float x, float y, int player, bool charging);

void SendUnit(int player, int unittype, int id, float x, float y, float z);

void AddUnit(int player, int unittype, int id, float x, float y, float z);

int AddObject(ObjectDrawTypes type, int id, int shape, int frame, float x, float y, float z);

unsigned int GetNextID();

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

void AddConsoleString(std::string string, Color color, unsigned int starttime);

void AddConsoleString(std::string string, Color color = Color(1, 1, 1, 1));

void DrawConsole();

//////////////////////////////////////////////////////////////////////////////

extern float g_DrawScale;

extern std::array<std::tuple<ObjectDrawTypes, ObjectTypes>, 1024 > g_ObjectTypes;

#endif