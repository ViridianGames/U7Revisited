///////////////////////////////////////////////////////////////////////////
//
// Name:     U7GLOBALS.H
// Author:   Anthony Salter
// Date:     12/31/23
// Purpose:  Game-specific globals.
///////////////////////////////////////////////////////////////////////////

#ifndef _U7Globals_H_
#define _U7Globals_H_

#include <list>
#include <vector>
#include <string>
#include <unordered_map>
#include <array>

#include "Geist/Primitives.h"
#include "Geist/RNG.h"
#include "ConversationState.h"
#include "Terrain.h"
#include "ShapeData.h"
#include "U7Object.h"
#include "raylib.h"
#include "raymath.h"
#include "U7Player.h"

//class ConversationState;

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
	STATE_OBJECTEDITORSTATE,
	STATE_WORLDEDITORSTATE,
	STATE_CREDITS,
    STATE_CONVERSATIONSTATE,
	STATE_LASTSTATE
};

extern std::string g_gameStateStrings[];

extern std::string g_objectDrawTypeStrings[];

extern bool g_LuaDebug;

enum class ObjectTypes
{
	OBJECT_STATIC = 0,   // Static objects cannot be changed.  They cannot be moved, created or destroyed.
	OBJECT_CREATURE,
	OBJECT_WEAPON,
	OBJECT_ARMOR,
	OBJECT_CONTAINER,
	OBJECT_QUESTobject_,
	OBJECT_KEY,
	OBJECTobject_
};

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

	std::unique_ptr<Mesh> m_mesh = nullptr;
};


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
	int m_objectID;
};

extern std::string g_version;

extern Vector3 g_Gravity;

extern Texture* g_Cursor;

extern std::shared_ptr<Font> g_Font;
extern std::shared_ptr<Font> g_SmallFont;
extern std::shared_ptr<Font> g_ConversationFont;
extern std::shared_ptr<Font> g_guiFont;

extern float g_fontSize;
extern float g_guiFontSize;

extern std::unique_ptr<RNG> g_VitalRNG;
extern std::unique_ptr<RNG> g_NonVitalRNG;

extern std::unique_ptr<Terrain> g_Terrain;

extern std::unordered_map<int, std::shared_ptr<U7Object> > g_ObjectList;

extern unsigned int g_CurrentUpdate;

extern bool g_CameraMoved;

extern std::unordered_map<int, int[16][16] > g_ChunkTypeList;  // The 16x16 tiles for each chunk type
extern int g_chunkTypeMap[192][192]; // The type of each chunk in the map
extern std::vector<U7Object*> g_chunkObjectMap[192][192]; // The objects in each chunk

extern std::array<std::array<ShapeData, 32>, 1024> g_shapeTable;
extern std::array<ObjectData, 1024> g_objectDataTable;
extern std::unordered_map<int, std::unique_ptr<NPCData> > g_NPCData;

extern std::vector<std::shared_ptr<U7Object>> g_sortedVisibleObjects;

extern unsigned int g_minimapSize;

extern std::unique_ptr<U7Player> g_Player;

extern std::vector< std::vector<unsigned short> > g_World;

extern std::vector< std::vector<Texture> > g_walkFrames;

extern std::unique_ptr<Model> g_CuboidModel;

void DrawOutlinedText(std::shared_ptr<Font> font, const std::string& text, Vector2 position, float fontSize, int spacing, Color color);

void DrawParagraph(std::shared_ptr<Font> font, const std::string& text, Vector2 position, float maxwidth, float fontSize, int spacing, Color color);


float GetDistance(float startX, float startZ, float endX, float endZ);

bool IsDistanceLessThan(float startX, float startZ, float endX, float endZ, float range);

void MakeAnimationFrameMeshes();

unsigned int DoCameraMovement();

void IsCellVisible(float x, float y);

void IsPointVisible(float x, float y);

std::shared_ptr<U7Object> GetObjectFromID(int unitID);

std::shared_ptr<U7Object> U7ObjectClassFactory(int type);

void PopulateLocationMap();

std::vector<std::shared_ptr<U7Object> > GetAllUnitsWithinRange(float x, float y, float range);

Vector3 GetRadialVector(float partitions, float thispartition);

void AddObject(int shapenum, int framenum, int id, float x, float y, float z);

void AddObjectToContainer(int objectID, int containerID);

unsigned int GetNextID();

bool WasLMBDoubleClicked();
bool WasRMBDoubleClicked();

void OpenURL(const std::string& url);

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

void DrawConsole();

//int l_add_dialogue(lua_State* L);

extern ConversationState* g_ConversationState;

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

extern float g_cameraDistance; // distance from target
extern float g_cameraRotation; // angle around target

extern EngineModes g_engineMode;

void RecalculateCamera();

#endif
