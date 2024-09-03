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
#include "Terrain.h"
#include "ShapeData.h"
#include "U7Object.h"
#include "raylib.h"
#include "raymath.h"


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
	STATE_OBJECTEDITORSTATE,
	STATE_WORLDEDITORSTATE,
	STATE_LASTSTATE
};

extern std::string g_gameStateStrings[];

extern std::string g_objectDrawTypeStrings[];

enum class ObjectTypes
{
	OBJECT_STATIC = 0,   // Static objects cannot be changed.  They cannot be moved, created or destroyed.
	OBJECT_CREATURE,
	OBJECT_WEAPON,
	OBJECT_ARMOR,
	OBJECT_CONTAINER,
	OBJECT_QUEST_ITEM,
	OBJECT_KEY,
	OBJECT_ITEM
};

enum class EngineModes
{
	ENGINE_MODE_BLACK_GATE = 0,
	ENGINE_MODE_SERPENT_ISLE,
	ENGINE_MODE_LAST_MODE
};

extern std::string g_engineModeStrings[];

extern std::string g_objectTypeStrings[];

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

extern std::string g_version;

extern Vector3 g_Gravity;

extern Texture* g_Cursor;

extern std::shared_ptr<Font> g_Font;
//extern std::shared_ptr<Font> g_SmallFont;

extern float g_fontSize;
//extern float g_smallFontSize;

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
extern std::array<ObjectData, 1024> g_objectTable;

extern unsigned int g_minimapSize;

extern std::vector< std::vector<unsigned short> > g_World;

float GetDistance(float startX, float startZ, float endX, float endZ);

bool IsDistanceLessThan(float startX, float startZ, float endX, float endZ, float range);

void MakeAnimationFrameMeshes();

unsigned int DoCameraMovement();

void IsCellVisible(float x, float y);

void IsPointVisible(float x, float y);

std::shared_ptr<U7Object> GetPointerFromID(int unitID);

std::shared_ptr<U7Object> U7ObjectClassFactory(int type);

void PopulateLocationMap();

std::vector<std::shared_ptr<U7Object> > GetAllUnitsWithinRange(float x, float y, float range);

Vector3 GetRadialVector(float partitions, float thispartition);

void AddObject(int shapenum, int framenum, int id, float x, float y, float z);

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

void ClearConsole();

void AddConsoleString(std::string string, Color color, float starttime);

void AddConsoleString(std::string string, Color color = Color{ 255, 255, 255, 255 });

void DrawConsole();

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

extern std::shared_ptr<Sprite> g_InactiveButtonL;
extern std::shared_ptr<Sprite> g_InactiveButtonM;
extern std::shared_ptr<Sprite> g_InactiveButtonR;
extern std::shared_ptr<Sprite> g_ActiveButtonL;
extern std::shared_ptr<Sprite> g_ActiveButtonM;
extern std::shared_ptr<Sprite> g_ActiveButtonR;

extern std::shared_ptr<Sprite> g_LeftArrow;
extern std::shared_ptr<Sprite> g_RightArrow;

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

extern bool m_pixelated;
extern RenderTexture2D	m_renderTarget;


//////////////////////////////////////////////////////////////////////////////
///  CAMERA SETTINGS AND RELATED FUNCTIONS
//////////////////////////////////////////////////////////////////////////////

extern Camera g_camera;

extern float g_cameraDistance; // distance from target
extern float g_cameraRotation; // angle around target

extern EngineModes g_engineMode;

void RecalculateCamera();

#endif