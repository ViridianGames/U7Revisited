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

#include "Primitives.h"
#include "Font.h"
#include "RNG.h"
#include "Terrain.h"
#include "U7Object.h"


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
	OBJECT_STATIC = 0,   // Static objects cannot be changed.  They cannot be moved, created or destroyed.
	OBJECT_CREATURE,
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

	std::unique_ptr<Mesh> m_mesh = nullptr;
};

extern glm::vec3 g_Gravity;

extern Texture* g_Cursor;

extern std::shared_ptr<Font> g_Font;
extern std::shared_ptr<Font> g_SmallFont;

extern std::unique_ptr<RNG> g_VitalRNG;
extern std::unique_ptr<RNG> g_NonVitalRNG;

extern std::unique_ptr<Terrain> g_Terrain;

extern std::unordered_map<int, std::shared_ptr<U7Object> > g_ObjectList;

extern unsigned int g_CurrentUpdate;

extern bool g_CameraMoved;

extern std::array<std::array<Texture* , 32>, 1024> g_shapeTable;
extern std::array<ObjectData, 1024> g_objectTable;

extern unsigned int g_minimapSize;

extern std::vector< std::vector<unsigned short> > g_World;

float GetDistance(float startX, float startZ, float endX, float endZ);

bool IsDistanceLessThan(float startX, float startZ, float endX, float endZ, float range);

float Lerp(float a, float b, float t);

void MakeAnimationFrameMeshes();

unsigned int DoCameraMovement();

void IsCellVisible(float x, float y);

void IsPointVisible(float x, float y);

std::shared_ptr<U7Object> GetPointerFromID(int unitID);

std::shared_ptr<U7Object> U7ObjectClassFactory(int type);

void PopulateLocationMap();

std::vector<std::shared_ptr<U7Object> > GetAllUnitsWithinRange(float x, float y, int range);

glm::vec3 GetRadialVector(float partitions, float thispartition);

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

void AddConsoleString(std::string string, Color color, unsigned int starttime);

void AddConsoleString(std::string string, Color color = Color(1, 1, 1, 1));

void DrawConsole();

//////////////////////////////////////////////////////////////////////////////

extern float g_DrawScale;

extern std::array<std::tuple<ObjectDrawTypes, ObjectTypes>, 1024 > g_ObjectTypes;

extern float g_CameraRotateSpeed;
extern glm::vec3 g_CameraMovementSpeed;

#endif