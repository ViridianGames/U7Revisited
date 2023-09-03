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
//#include "tinyxml2.h"
#include "Primitives.h"
#include "Font.h"
#include "RNG.h"
#include "Terrain.h"
#include "U7Unit.h"

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
   STATE_TITLESTATE = 0,
   STATE_MAINSTATE,
   STATE_OPTIONSSTATE,
   STATE_LASTSTATE
};

/*enum PlayerActions
{
   PA_FLATTEN = 0,
   PA_RAISE,
   PA_LOWER,
   PA_EARTHQUAKE,
   PA_GOLEM,
   PA_STONERAIN,
   PA_FLAMESTRIKE,
   PA_VOLCANO,
   PA_LIGHTNING,
   PA_LIGHTNINGSTORM,
   PA_METEOR,
   PA_BLESS,
   PA_SWAMP,
   PA_HEALINGRAIN,
   PA_ARMAGEDDON,
   PA_CREATEARCHER,
   PA_CREATEBARBARIAN,
   PA_CREATEWARRIOR,
   PA_MOVEGENERAL,
   PA_MOVECAMERA,
   PA_ADDCONSOLETEXT,
   PA_LASTPLAYERACTION
};*/


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

enum BuffTypes
{
   BUFF_SPEED = 0,
   BUFF_HEALTH,
   BUFF_ATTACK,
   BUFF_DEFENSE,
   BUFF_TEAM,
   BUFF_DOT,
   BUFF_HOT,
   
   BUFF_LASTBUFF
};

enum TerrainTypes
{
   TT_GRASS = 0,
   TT_BEACH,
   TT_WATER,
   TT_FLATLAND,  //  Can be built on or turned into farmland
   TT_DIRT,
   TT_STONE,
   TT_COBBLESTONE,
   TT_FARMLAND,
   TT_LAVA,  // HOW ARE YOU ALIVE THE FLOOR IS LAVA
   TT_BLESSEDLAND,
   TT_SWAMP,
   
   TT_INVALIDTYPE,
   TT_LASTTERRAINTYPE
};

enum PacketTypes
{
   PT_CLIENTCONNECT = 0,
   PT_SERVERGAMESTART,
   PT_SERVERSENTEVENTS,
   PT_CLIENTSENTEVENTS,
   PT_CLIENTACKEVENTS,
   PT_CHATSTRING,
};

struct GameEvent
{
	unsigned int m_UpdateIndex;
   int m_Handled;
	int m_Event;
	int m_UnitID;
   int m_Team;
   int m_Type;
   float m_PosX;
   float m_PosY;
   float m_PosZ;
	int m_Int1;
	int m_Int2;
	int m_Int3;
	int m_Int4;
	float m_Float1;
	float m_Float2;
	float m_Float3;
	float m_Float4;
};

struct PairHash
{
   std::size_t operator()(const std::pair<int, int> &pair) const
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

void ClearEvent(GameEvent& event);

//  This class represents a single buff/debuff
struct Buff
{
   bool m_IsBuff; //  If this is false, it's actually a debuff.
   int m_ValueToMod;
   float m_ModValue;
   int m_Ticks;
};

extern glm::vec3 g_Gravity;

extern Mesh*    g_AnimationFrames;
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

extern std::string GameEventStrings[LASTGAMEEVENT + 1];
extern std::string UnitTypeStrings[UNIT_LASTUNITTYPE + 1];

extern Mesh* g_TestMesh;

extern std::list<GameEvent> g_EventStack;
extern std::list<GameEvent> g_ProcessedStack;
extern std::list<GameEvent> g_ReplayStack;

//  Stacks for networking
extern std::list<GameEvent> g_ClientTurnStack;
extern std::list<GameEvent> g_ServerTurnStack;

extern unsigned int g_CurrentUpdate;

extern bool g_IsSinglePlayer;  //  not single payer
extern bool g_IsServer;
extern bool g_CameraMoved;

extern unsigned int g_minimapSize;

extern std::vector< std::vector<unsigned short> > g_World;

float GetDistance(float startX, float startZ, float endX, float endZ);

bool IsDistanceLessThan(float startX, float startZ, float endX, float endZ, float range);

float Lerp(float a, float b, float t);

void MakeAnimationFrameMeshes();

void DoCameraMovement();

void IsCellVisible(float x, float y);

void IsPointVisible(float x, float y);

void SendEvent( GameEvent event );

void ReceiveEvents();

std::shared_ptr<U7Unit> GetPointerFromID(int unitID);

std::shared_ptr<U7Unit> U7UnitClassFactory(int type);

extern std::unordered_map<std::pair<int, int>, std::vector<std::shared_ptr<U7Unit> >, PairHash > g_LocationMap;
//extern std::vector<shared_ptr<U7Unit> >* g_LocationMap;

void PopulateLocationMap();

std::vector<std::shared_ptr<U7Unit> > GetAllUnitsWithinRange(float x, float y, int range);

glm::vec3 GetRadialVector(float partitions, float thispartition);

//void DoGodPower(int power, float x, float y, int player, bool charging);

void AddUnit(int player, int unittype, int id, float x, float y, float z );

void SendGodPower(int power, float x, float y, int player, bool charging);

void SendUnit(int player, int unittype, int id, float x, float y, float z );


void AddUnitActual(int player, int unittype, int id, float x, float y, float z );

unsigned int GetNextID();

void ResolveOrderStack();

void SaveReplay();

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

#endif