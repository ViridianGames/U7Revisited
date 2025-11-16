#include "U7Globals.h"
#include "Geist/Engine.h"
#include "Geist/Logging.h"
#include "Geist/ScriptingSystem.h"
#include "ConversationState.h"
#include "Pathfinding.h"
#include "lua.hpp"
#include "../ThirdParty/raylib/include/rlgl.h"
#include "../ThirdParty/nlohmann/json.hpp"
#include <algorithm>
#include <fstream>
#include <sstream>
#include <iterator>
#include <utility>
#include <iomanip>
#include <iostream>
#include <cassert>

using namespace std;

std::string g_version;

unordered_map<int, std::unique_ptr<U7Object> > g_objectList;

Mesh* g_AnimationFrames;

extern Texture* g_Cursor; // Defined in StateMachine.cpp
Texture* g_objectSelectCursor;
Texture* g_EmptyTexture;
Texture* g_Minimap;

std::shared_ptr<Font> g_Font;
std::shared_ptr<Font> g_SmallFont;
std::shared_ptr<Font> g_ConversationFont;
std::shared_ptr<Font> g_ConversationSmallFont;
std::shared_ptr<Font> g_guiFont;

//float g_smallFontSize = 8;
float g_fontSize = 16;
float g_guiFontSize = 8;

std::unique_ptr<RNG> g_VitalRNG;
std::unique_ptr<RNG> g_NonVitalRNG;

std::unique_ptr<Terrain> g_Terrain;

std::array<std::array<ShapeData, 32>, 1024> g_shapeTable;
std::array<ObjectData, 1024> g_objectDataTable;

// Weather/effect sprite data
std::array<std::vector<SpriteFrame>, 32> g_spriteTable;

// Misc names from TEXT.FLX for frame-specific item names
std::vector<std::string> g_miscNames;

std::unordered_map<int, unique_ptr<NPCData>> g_NPCData;

// Spell system data
std::vector<ReagentData> g_reagentData;
std::vector<SpellCircle> g_spellCircles;
std::unordered_map<int, SpellData*> g_spellMap;

ConversationState* g_ConversationState;
MainState* g_mainState;

bool g_CameraMoved;

unsigned int g_CurrentUpdate;

unsigned int g_minimapSize;

std::vector< std::vector<unsigned short> > g_World;

Vector3 g_Gravity = Vector3{ 0, .1f, 0 };

float g_CameraRotateSpeed = 0;

Vector3 g_CameraMovementSpeed = Vector3{ 0, 0, 0 };

std::string g_gameStateStrings[] = { "LoadingState", "TitleState", "MainState", "OptionsState", "ObjectEditorState", "WorldEditorState" };

std::string g_objectDrawTypeStrings[] = { "Billboard", "Cuboid", "Flat", "Custom Mesh" };

std::string g_objectTypeStrings[] = { "Static", "Creature", "Weapon", "Armor", "Container", "Quest Item", "Key", "Item" };

int g_selectedShape = 150;
int g_selectedFrame = 0;

std::unordered_map<int, int[16][16]> g_ChunkTypeList;  // The 16x16 tiles for each chunk type
int g_chunkTypeMap[192][192]; // The type of each chunk in the map
std::vector<U7Object*> g_chunkObjectMap[192][192]; // The objects in each chunk

std::vector<U7Object*> g_sortedVisibleObjects;

float g_cameraDistance; // distance from target
float g_cameraRotation = 0; // angle around target
float g_cameraRotationTarget = 0;

Shader g_alphaDiscard;

bool g_pixelated = false;
RenderTexture2D g_renderTarget;
RenderTexture2D g_guiRenderTarget;

std::unique_ptr<U7Player> g_Player;

bool g_LuaDebug = false;  // Toggle with F8 key
bool g_showScriptedObjects = false;  // Toggle with F11 key - highlights objects with scripts

std::unique_ptr<Model> g_CuboidModel;

std::vector< std::vector<Texture> > g_walkFrames;

std::unordered_map<int, std::vector<NPCSchedule> > g_NPCSchedules;

Color g_dayNightColor = WHITE;
bool g_isDay = true;

float g_lastTime;
unsigned int g_hour;
unsigned int g_minute;
unsigned int g_scheduleTime;
float g_secsPerMinute = 5;
bool g_autoRotate = false;

// NPC pathfinding queue system
std::queue<int> g_npcPathfindQueue;
int g_lastScheduleTimeCheck = -1;

// Pathfinding
PathfindingGrid* g_pathfindingGrid = nullptr;
AStar* g_aStar = nullptr;

#ifdef DEBUG_NPC_PATHFINDING
std::unordered_map<int, NPCPathStats> g_npcMaxPathStats;
#endif

Vector3 g_terrainUnderMousePointer = Vector3{ 0, 0, 0 };

U7Object* g_mouseOverObject = nullptr;

std::unique_ptr<GumpManager> g_gumpManager;

U7Object* g_objectUnderMousePointer;
bool g_mouseOverUI = false;

U7Object* g_doubleClickedObject;

//  This makes an animation
void MakeAnimationFrameMeshes()
{
	g_AnimationFrames = new Mesh();
	vector<Vertex> vertices;
	vector<unsigned int> indices;
	for (int i = 0; i < 8; ++i)
	{
		for (int j = 0; j < 8; ++j)
		{
			vertices.push_back(CreateVertex(-.5, 0, 0, 1, 1, 1, 1, (i + 1) * 0.1250, (j + 1) * 0.1250));
			vertices.push_back(CreateVertex(.5, 0, 0, 1, 1, 1, 1, i * 0.1250, (j + 1) * 0.1250));
			vertices.push_back(CreateVertex(-.5, 1, 0, 1, 1, 1, 1, (i + 1) * 0.1250, j * 0.1250));
			vertices.push_back(CreateVertex(.5, 1, 0, 1, 1, 1, 1, i * 0.1250, j * 0.1250));
		}
	}

	for (int i = 0; i < 256; )
	{
		indices.push_back(i);
		indices.push_back(i + 1);
		indices.push_back(i + 2);
		indices.push_back(i + 3);
		indices.push_back(i + 2);
		indices.push_back(i + 1);

		i += 4;
	}

	//g_AnimationFrames->Init(vertices, indices);
}

unsigned int DoCameraMovement(bool forcemove)
{
	g_CameraMoved = forcemove;

	Vector3 direction = { 0, 0, 0 };
	float deltaRotation = 0;

	float frameTimeModifier = 30;

	if (IsKeyDown(KEY_A))
	{
		direction = Vector3Add(direction, { -GetFrameTime() * frameTimeModifier, 0, GetFrameTime() * frameTimeModifier });
		g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_D))
	{
		direction = Vector3Add(direction, { GetFrameTime() * frameTimeModifier, 0, -GetFrameTime() * frameTimeModifier });
		g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_W))
	{
		direction = Vector3Add(direction, { -GetFrameTime() * frameTimeModifier, 0, -GetFrameTime() * frameTimeModifier });
		g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_S))
	{
		direction = Vector3Add(direction, { GetFrameTime() * frameTimeModifier, 0, GetFrameTime() * frameTimeModifier });
		g_CameraMoved = true;
	}

	if (g_CameraMoved)
	{
		g_CameraMovementSpeed = direction;
	}

	bool cameraRotated = false;
	if (IsKeyDown(KEY_Q))
	{
		g_CameraRotateSpeed = GetFrameTime() * 5;
		g_CameraMoved = true;
		cameraRotated = true;
	}

	if (IsKeyDown(KEY_E))
	{
		g_CameraRotateSpeed = -GetFrameTime() * 5;
		g_CameraMoved = true;
		cameraRotated = true;
	}

	float newDistance = g_cameraDistance;
	bool mouseWheel = false;
	float mouseDelta = 1;
	if (GetMouseWheelMove() < 0)
	{
		newDistance = g_cameraDistance + mouseDelta;
		mouseWheel = true;
	}

	if (GetMouseWheelMove() > 0)
	{
		newDistance = g_cameraDistance - mouseDelta;
		mouseWheel = true;
	}

	if (mouseWheel)
	{
		if (newDistance > g_Engine->m_EngineConfig.GetNumber("camera_far_limit"))
		{
			newDistance = g_Engine->m_EngineConfig.GetNumber("camera_far_limit");
		}

		if (newDistance < g_Engine->m_EngineConfig.GetNumber("camera_close_limit"))
		{
			newDistance = g_Engine->m_EngineConfig.GetNumber("camera_close_limit");
		}

		g_cameraDistance = newDistance;

		g_CameraMoved = true;
	}

	if (IsLeftButtonDownInRect(g_Engine->m_ScreenWidth - (g_minimapSize * g_DrawScale), 0, g_Engine->m_ScreenWidth, g_minimapSize * g_DrawScale)
		&& !g_gumpManager->IsAnyGumpBeingDragged())
	{
		float minimapx = float(GetMouseX() - (g_Engine->m_ScreenWidth - (g_minimapSize * g_DrawScale))) / float(g_minimapSize * g_DrawScale) * 3072;
		float minimapy = float(GetMouseY()) / float(g_minimapSize * g_DrawScale) * 3072;

		g_camera.target = Vector3{ minimapx, 0, minimapy };
		g_CameraMoved = true;
	}

	bool moveDecay = false;
	bool rotateDecay = false;
	if (!g_CameraMoved && (g_CameraMovementSpeed.x != 0 || g_CameraMovementSpeed.z != 0))
	{
		g_CameraMovementSpeed = Vector3{ g_CameraMovementSpeed.x * .75f, g_CameraMovementSpeed.y, g_CameraMovementSpeed.z * .75f };

		if (abs(g_CameraMovementSpeed.x) < .01f)
		{
			g_CameraMovementSpeed.x = 0;
		}

		if (abs(g_CameraMovementSpeed.z) < .01f)
		{
			g_CameraMovementSpeed.z = 0;
		}

		moveDecay = true;
	}

	float delta = g_cameraRotationTarget - g_cameraRotation;
	if (g_autoRotate == true)
	{
		if (abs(delta) > 0.05 && !cameraRotated && g_autoRotate)
		{
			if (delta > PI)
			{
				delta -= 2 * PI;
			}
			else if (delta < -PI)
			{
				delta += 2 * PI;
			}
			g_CameraRotateSpeed = (delta > 0.0f) ? GetFrameTime() * 1 : GetFrameTime() * -1;
		}
		else
		{
			g_autoRotate = false;
			g_cameraRotation = g_cameraRotationTarget;
		}
	}

	if (!cameraRotated && g_CameraRotateSpeed != 0)
	{
		g_CameraRotateSpeed = g_CameraRotateSpeed * .75f;
		if (abs(g_CameraRotateSpeed) < .01f)
		{
			g_CameraRotateSpeed = 0;
		}

		rotateDecay = true;
	}

	if (moveDecay || rotateDecay)
	{
		g_CameraMoved = true;
	}

	if (g_CameraMoved)
	{
		g_cameraRotation += g_CameraRotateSpeed;

		while (g_cameraRotation < 0)
		{
			g_cameraRotation += 2 * PI;
		}

		while (g_cameraRotation > 2 * PI)
		{
			g_cameraRotation -= 2 * PI;
		}

		Vector3 current = g_camera.target;

		Vector3 finalmovement = Vector3RotateByAxisAngle(g_CameraMovementSpeed, Vector3{ 0, 1, 0 }, g_cameraRotation);

		current = Vector3Add(current, finalmovement);

		if (current.x < 0) current.x = 0;
		if (current.x > 3072) current.x = 3072;
		if (current.z < 0) current.z = 0;
		if (current.z > 3072) current.z = 3072;

		Vector3 camPos = { g_cameraDistance, g_cameraDistance, g_cameraDistance };
		camPos = Vector3RotateByAxisAngle(camPos, Vector3{ 0, 1, 0 }, g_cameraRotation);

		g_camera.target = current;
		g_camera.position = Vector3Add(current, camPos);
		g_camera.fovy = g_cameraDistance;
	}

	return 0;
}

U7Object* GetObjectFromID(int unitID)
{
	auto it = g_objectList.find(unitID);
	if (it != g_objectList.end())
	{
		return it->second.get(); // Returns raw pointer to U7Object
	}
	return nullptr;
}

U7Object* GetRootNPCFromContainer(U7Object* container)
{
	if (container == nullptr)
		return nullptr;

	// If this container is already an NPC, return it
	if (container->m_isNPC)
		return container;

	// Follow the parent chain up to find an NPC
	int currentId = container->m_containingObjectId;
	while (currentId != -1)
	{
		U7Object* parent = GetObjectFromID(currentId);
		if (parent == nullptr)
			break;

		if (parent->m_isNPC)
			return parent;

		currentId = parent->m_containingObjectId;
	}

	return nullptr;
}

float GetMaxWeightFromStrength(int strength)
{
	return 2.0f * strength;
}

void UpdateSortedVisibleObjects()
{
	if (g_LuaDebug)
	{
		AddConsoleString("UpdateSortedVisibleObjects: Starting");
	}
	int cameraChunkX = static_cast<int>(g_camera.target.x / 16);
	int cameraChunkY = static_cast<int>(g_camera.target.z / 16);

	// DEBUG: Log before clearing
	int beforeCount = static_cast<int>(g_sortedVisibleObjects.size());

	g_sortedVisibleObjects.clear();

	for (int x = cameraChunkX - 2; x <= cameraChunkX + 2; x++)
	{
		for (int y = cameraChunkY - 2; y <= cameraChunkY + 2; y++)
		{
			if (x < 0 || x >= 192 || y < 0 || y >= 192)
			{
				continue; // Out of bounds
			}

			for (auto object : g_chunkObjectMap[x][y])
			{
				// Skip null, dead, or contained objects
				if (!object || object->GetIsDead() || object->m_isContained)
				{
					if (g_LuaDebug && object && object->GetIsDead())
					{
						AddConsoleString("UpdateSortedVisibleObjects: Skipping dead object");
					}
					continue;
				}

				object->m_distanceFromCamera = Vector3DistanceSqr(object->m_centerPoint, g_camera.position);
				g_sortedVisibleObjects.push_back(object);
			}
		}
	}

	// DEBUG: Log count after populating
	int afterCount = static_cast<int>(g_sortedVisibleObjects.size());
	static int lastLoggedCount = -1;
	// Always log when called from RebuildWorldFromLoadedData, otherwise only log on changes
	static bool forceNextLog = false;
	if (afterCount != lastLoggedCount || forceNextLog)
	{
		Log("UpdateSortedVisibleObjects: Camera chunk (" + std::to_string(cameraChunkX) + "," + std::to_string(cameraChunkY) +
			"), found " + std::to_string(afterCount) + " visible objects (was " + std::to_string(beforeCount) + ")");
		lastLoggedCount = afterCount;
		forceNextLog = false;
	}

	std::sort(g_sortedVisibleObjects.begin(), g_sortedVisibleObjects.end(), [](U7Object* a, U7Object* b) { return a->m_distanceFromCamera > b->m_distanceFromCamera; });

	g_objectUnderMousePointer = nullptr;

	// Don't pick objects if mouse is over UI elements
	if (g_mouseOverUI)
	{
		return;
	}

	//  Is a gump open?  Are we over it?  See if there's an object under our mouse.
	if (!g_gumpManager->m_GumpList.empty() && g_gumpManager->IsMouseOverGump() && g_gumpManager->m_gumpUnderMouse != nullptr)
	{
		g_objectUnderMousePointer = g_gumpManager->m_gumpUnderMouse->GetObjectUnderMousePointer();
	}
	else
	{
		for (auto node = g_sortedVisibleObjects.rbegin(); node != g_sortedVisibleObjects.rend(); ++node)
		{
			if (*node == nullptr || !(*node)->m_Visible)
			{
				continue;
			}

			Vector3 pos = { 0, 0, 0 };
			float picked = (*node)->PickXYZ(pos);

			if (picked != -1)
			{
				g_objectUnderMousePointer = *node;
				break;
			}
		}
	}

	// Pick cell under mouse pointer
	Ray ray = GetMouseRay(GetMousePosition(), g_camera);
	float pickx = 0;
	float picky = 0;

	Vector3 planeNormal = { 0.0f, 1.0f, 0.0f };
	Vector3 planePoint = { 0.0f, 0.0f, 0.0f };
	float denominator = Vector3DotProduct(ray.direction, planeNormal);

	if (fabs(denominator) > 0.0001f)
	{
		Vector3 pointToPlane = Vector3Subtract(planePoint, ray.position);
		float t = Vector3DotProduct(pointToPlane, planeNormal) / denominator;
		if (t >= 0.0f) {
			Vector3 hitPoint = Vector3Add(ray.position, Vector3Scale(ray.direction, t));
			int x = static_cast<int>(floor(hitPoint.x));
			int y = static_cast<int>(floor(hitPoint.z));
			if (x >= 0 && x < 3072 && y >= 0 && y < 3072)
			{
				pickx = x;
				picky = y;
			}
		}
	}

	g_terrainUnderMousePointer = { pickx, 0, picky };

	g_terrainUnderMousePointer.x = roundf(g_terrainUnderMousePointer.x);
	g_terrainUnderMousePointer.y = roundf(g_terrainUnderMousePointer.y);
	g_terrainUnderMousePointer.z = roundf(g_terrainUnderMousePointer.z);

}

Vector3 GetRadialVector(float partitions, float thispartition)
{
	float finalpartition = ((PI * 2) / partitions) * thispartition;

	return Vector3{ cos(finalpartition), 0, sin(finalpartition) };
}

unsigned int g_CurrentUnitID = 0;

unsigned int GetNextID() { return g_CurrentUnitID++; }

U7Object* AddObject(int shapenum, int framenum, int id, float x, float y, float z)
{
	if (shapenum == 739 && x == 968 && z == 2292)
	{
		Log("Stop here.");
	}

	g_objectList.emplace(id, make_unique<U7Object>());

	U7Object* temp = g_objectList[id].get();
	temp->Init("Data/Units/Walker.cfg", shapenum, framenum);
	temp->m_ID = id;
	temp->SetInitialPos(Vector3{ x, y, z });
	AssignObjectChunk(temp);
	//UpdateModelAnimation(temp->m_shapeData->m_customMesh->GetModel(), temp->m_shapeData->m_customMesh->GetModel()-> ->   0);

	// Notify pathfinding grid if this is a non-walkable object
	if (temp->m_objectData && temp->m_objectData->m_isNotWalkable)
	{
		NotifyPathfindingGridUpdate((int)x, (int)z);
	}

	return g_objectList[id].get();
}

void UpdateObjectChunk(U7Object* object, Vector3 fromPos)
{
	Vector2 fromChunkPos = Vector2{ floor(fromPos.x / 16), floor(fromPos.z / 16) };

	if (object->GetChunkPos().x == fromChunkPos.x && object->GetChunkPos().y == fromChunkPos.y)
	{
		// Object hasn't moved chunk
		return;
	}

	auto& fromChunk = g_chunkObjectMap[int(fromChunkPos.x)][int(fromChunkPos.y)];
	auto fromChunknode = std::find(fromChunk.begin(), fromChunk.end(), object);
	if (fromChunknode != fromChunk.end()) {
		fromChunk.erase(fromChunknode);
	}

	auto& toChunk = g_chunkObjectMap[int(object->GetChunkPos().x)][int(object->GetChunkPos().y)];
	toChunk.push_back(object);
}

void AssignObjectChunk(U7Object* object)
{
	int i = static_cast<int>(object->m_Pos.x / 16);
	int j = static_cast<int>(object->m_Pos.z / 16);

	g_chunkObjectMap[i][j].push_back(object);
}

void UnassignObjectChunk(U7Object* object)
{
	int i = static_cast<int>(object->m_Pos.x / 16);
	int j = static_cast<int>(object->m_Pos.z / 16);

	auto fromChunkPos = std::find(g_chunkObjectMap[i][j].begin(), g_chunkObjectMap[i][j].end(), object);
	if (fromChunkPos != g_chunkObjectMap[i][j].end())
	{
		g_chunkObjectMap[i][j].erase(fromChunkPos);
	}
}

void AddObjectToInventory(int objectId, int containerId)
{
	U7Object* object = GetObjectFromID(objectId);
	U7Object* container = GetObjectFromID(containerId);

	if (object == nullptr || container == nullptr)
	{
		return;
	}

	container->AddObjectToInventory(objectId);
}

//////////////////////////////////////////////////////////////////////////////
//  CONSOLE
//////////////////////////////////////////////////////////////////////////////

std::vector<ConsoleString> g_ConsoleStrings;

void ClearConsole()
{
	g_ConsoleStrings.clear();
}

void AddConsoleString(std::string string, Color color, float starttime)
{
	ConsoleString temp;
	temp.m_String = string;
	temp.m_Color = color;
	temp.m_StartTime = starttime;

	g_ConsoleStrings.push_back(temp);
}

void AddConsoleString(std::string string, Color color)
{
	ConsoleString temp;
	temp.m_String = string;
	temp.m_Color = color;
	temp.m_StartTime = GetTime();

	g_ConsoleStrings.push_back(temp);
	cout << string << endl;
}

void SaveShapeTable()
{
	std::ofstream file("Data/shapetable.dat", std::ios::trunc);
	if (file.is_open())
	{
		for (int i = 150; i < 1024; ++i)
		{
			for (int j = 0; j < 32; ++j)
			{
				g_shapeTable[i][j].Serialize(file);
			}
		}
		file.close();
	}
	AddConsoleString("Saved shapetable.dat successfully!", GREEN);
}

void DrawWorld()
{
	// Draw 3D world - used by MainState and modal dialogs
	BeginMode3D(g_camera);

	// Draw the terrain
	g_Terrain->Draw();

	// Draw objects (non-flats first)
	for (auto object : g_sortedVisibleObjects)
	{
		if (object->m_drawType != ShapeDrawType::OBJECT_DRAW_FLAT)
		{
			object->Draw();
		}
	}

	// Flats require disabling the depth mask to draw correctly
	rlDisableDepthMask();
	for (auto object : g_sortedVisibleObjects)
	{
		if (object->m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
		{
			object->Draw();
		}
	}
	rlEnableDepthMask();

	EndMode3D();
}

void DrawConsole()
{
	int counter = 0;
	vector<ConsoleString>::iterator node = g_ConsoleStrings.begin();
	float shadowOffset = 1;
	if (shadowOffset < 1)
	{
		shadowOffset = 1;
	}
	for (node; node != g_ConsoleStrings.end(); ++node)
	{
		float elapsed = GetTime() - (*node).m_StartTime;
		if (elapsed > 9)
		{
			float alpha = float(9 - elapsed);
			if (alpha == 1.0f)
			{
				alpha = 0;
			}
			(*node).m_Color.a = alpha * 255;
		}

		if (elapsed < 10)
		{
			DrawOutlinedText(g_SmallFont, (*node).m_String.c_str(), Vector2{ 0, float(counter * (g_SmallFont->baseSize + 2)) }, g_SmallFont->baseSize, 1, (*node).m_Color);

		}
		++counter;
	}

	node = g_ConsoleStrings.begin();
	for (node; node != g_ConsoleStrings.end();)
	{
		if (GetTime() - (*node).m_StartTime > 10)
		{
			node = g_ConsoleStrings.erase(node);
		}
		else
		{
			++node;
		}
	}
}

void DrawOutlinedText(std::shared_ptr<Font> font, const std::string& text, Vector2 position, float fontSize, int spacing, Color color)
{
	DrawTextEx(*font, text.c_str(), Vector2{ position.x + 1, position.y + 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x, position.y + 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x - 1, position.y - 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x, position.y - 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x + 1, position.y - 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x + 1, position.y }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x - 1, position.y + 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x - 1, position.y }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), position, fontSize, spacing, color);
}

void DrawParagraph(std::shared_ptr<Font> font, const std::string& text, Vector2 position, float maxwidth, float fontSize, int spacing, Color color, bool outlined)
{
	std::istringstream iss(text);
	std::string word;
	std::vector<std::string> lines;
	float lineWidth = 0;

	string rawline;
	string line;
	while (getline(iss, rawline))
	{
		std::stringstream lineStream(rawline);
		while (lineStream >> word)
		{
			int currentLineWidth = MeasureTextEx(*font, (line + word).c_str(), fontSize, spacing).x;
			if (currentLineWidth > maxwidth)
			{
				lines.push_back(line);
				line.clear();
				line += word + " ";
			}
			else
			{
				line += word + " ";
			}
		}

		lines.push_back(line);

		line.clear();
	}

	auto it = lines.begin();
	float y = position.y;
	while (it != lines.end())
	{
		if (outlined)
		{
			DrawOutlinedText(font, (*it).c_str(), Vector2{ position.x, y }, fontSize, spacing, color);
		}
		else
		{
			DrawTextEx(*font, (*it).c_str(), Vector2{ position.x, y }, fontSize, spacing, color);
		}
		y += fontSize * 1.2f;
		++it;
	}
}


void AddObjectToContainer(int objectID, int containerID)
{
	U7Object* object = GetObjectFromID(objectID);
	U7Object* container = GetObjectFromID(containerID);

	if (object == nullptr || container == nullptr)
	{
		Log("AddObjectToContainer ERROR: object=" + std::to_string(objectID) + " is " + (object ? "valid" : "NULL") +
			", container=" + std::to_string(containerID) + " is " + (container ? "valid" : "NULL"));
		return;
	}

	bool success = container->AddObjectToInventory(objectID);

	// Debug: Log inventory addition
	static int addCount = 0;
	if (addCount < 30)
	{
		Log("AddObjectToContainer: Added object " + std::to_string(objectID) + " to container " + std::to_string(containerID) +
			" (success=" + std::string(success ? "true" : "false") + ", inventory size now=" + std::to_string(container->m_inventory.size()) + ")");
		addCount++;
	}

	// Objects in containers are not in world chunks
	UnassignObjectChunk(object);
}

extern float g_DrawScale; // Defined in StateMachine.cpp

std::shared_ptr<Sprite> g_BoxTL;
std::shared_ptr<Sprite> g_BoxT;
std::shared_ptr<Sprite> g_BoxTR;
std::shared_ptr<Sprite> g_BoxL;
std::shared_ptr<Sprite> g_BoxC;
std::shared_ptr<Sprite> g_BoxR;
std::shared_ptr<Sprite> g_BoxBL;
std::shared_ptr<Sprite> g_BoxB;
std::shared_ptr<Sprite> g_BoxBR;

std::vector<std::shared_ptr<Sprite> > g_Borders;
std::vector<std::shared_ptr<Sprite> > g_ConversationBorders;

shared_ptr<Sprite> g_InactiveButtonL;
shared_ptr<Sprite> g_InactiveButtonM;
shared_ptr<Sprite> g_InactiveButtonR;
shared_ptr<Sprite> g_ActiveButtonL;
shared_ptr<Sprite> g_ActiveButtonM;
shared_ptr<Sprite> g_ActiveButtonR;

shared_ptr<Sprite> g_ShapeButtonL;
shared_ptr<Sprite> g_ShapeButtonM;
shared_ptr<Sprite> g_ShapeButtonR;

shared_ptr<Sprite> g_LeftArrow;
shared_ptr<Sprite> g_RightArrow;

shared_ptr<Sprite> g_gumpBackground;
shared_ptr<Sprite> g_gumpCheckmarkUp;
shared_ptr<Sprite> g_gumpCheckmarkDown;

shared_ptr<Sprite> g_GitHubButton;
shared_ptr<Sprite> g_XButton;
shared_ptr<Sprite> g_YouTubeButton;
shared_ptr<Sprite> g_PatreonButton;
shared_ptr<Sprite> g_KoFiButton;

shared_ptr<Sprite> g_gumpNumberBarBackground;
shared_ptr<Sprite> g_gumpNumberBarMarker;
shared_ptr<Sprite> g_gumpNumberBarRightArrow;
shared_ptr<Sprite> g_gumpNumberBarLeftArrow;


shared_ptr<Texture2D> g_statsBackground;

Camera g_camera = { 0 };

bool g_hasCameraChanged = true;

EngineModes g_engineMode = EngineModes::ENGINE_MODE_BLACK_GATE;

std::string g_engineModeStrings[] = { "blackgate", "serpentisle", "NONE" };

bool WasMouseButtonDoubleClicked(int button)
{
	static bool lmblastState = false;
	static float lmblastTime = 0;

	if (IsMouseButtonReleased(button))
	{
		if (lmblastState == false)
		{
			lmblastState = true;
			lmblastTime = GetTime();
		}
	}
	else if (IsMouseButtonPressed(button))  // if (IsMouseButtonPressed
	{
		if (GetTime() - lmblastTime < .25f)
		{
			lmblastState = false;
			return true;
		}
		lmblastState = false;
	}

	return false;
}

void OpenURL(const std::string& url)
{
#ifdef __linux__
	std::string command = "xdg-open " + url;
#elif _WIN32
	std::string command = "start " + url;
#elif __APPLE__
	std::string command = "open " + url;
#else
	return; // Unsupported platform
#endif
	std::system(command.c_str());
}

// Pathfinding grid update notification
void NotifyPathfindingGridUpdate(int worldX, int worldZ, int radius)
{
	// No longer needed - tile-based pathfinding checks walkability dynamically during A* search
	// Keeping this function as a no-op to avoid breaking existing code
}

#ifdef DEBUG_NPC_PATHFINDING
void PrintNPCPathStats()
{
	if (g_npcMaxPathStats.empty())
	{
		AddConsoleString("No NPC pathfinding stats collected yet.", YELLOW);
		return;
	}

	// Convert to vector for sorting
	std::vector<NPCPathStats> stats;
	stats.reserve(g_npcMaxPathStats.size());
	for (const auto& pair : g_npcMaxPathStats)
	{
		stats.push_back(pair.second);
	}

	// Sort by distance (longest first)
	std::sort(stats.begin(), stats.end(), [](const NPCPathStats& a, const NPCPathStats& b) {
		return a.distance > b.distance;
	});

	// Print header
	AddConsoleString("=== NPC Longest Pathfinding Routes (sorted by distance) ===", SKYBLUE);
	AddConsoleString("Total NPCs tracked: " + std::to_string(stats.size()), SKYBLUE);

	// Print each NPC's longest path
	for (const auto& stat : stats)
	{
		std::string msg = "NPC " + std::to_string(stat.npcID) +
			": Distance=" + std::to_string((int)stat.distance) + " tiles" +
			", Waypoints=" + std::to_string(stat.waypointCount) +
			", From=(" + std::to_string((int)stat.startPos.x) + "," + std::to_string((int)stat.startPos.z) + ")" +
			" To=(" + std::to_string((int)stat.endPos.x) + "," + std::to_string((int)stat.endPos.z) + ")";
		AddConsoleString(msg, WHITE);
	}

	AddConsoleString("=== End of NPC Path Stats ===", SKYBLUE);
}
#endif


// int l_add_dialogue(lua_State* L)
// {
// 	const char* message = luaL_checkstring(L, 1);
// 	printf("Lua says: %s\n", message);
// 	return 0;
// }

// Helper function to parse U7 text format: "a/<singular>//<plural>/s"
// Returns singular or plural with quantity
std::string ParseU7TextFormat(const std::string& rawText, int quantity)
{
	// Format can be:
	// "bread" - no slashes, just a name
	// "a/garlic//s" - article/singular_name/middle_part/plural_suffix
	// "/kni/fe/ves" - /prefix/suffix/plural_ending (for knife/knives)

	size_t firstSlash = rawText.find('/');
	if (firstSlash == std::string::npos)
	{
		// No slashes means no U7 text format, just return the name as-is without quantity
		return rawText;
	}

	// Find the second slash
	size_t secondSlash = rawText.find('/', firstSlash + 1);
	if (secondSlash == std::string::npos)
	{
		// Malformed, return as-is
		return rawText;
	}

	// Get the article (before first slash)
	std::string article = rawText.substr(0, firstSlash);

	// Get the first part (between 1st and 2nd slash)
	std::string firstPart = rawText.substr(firstSlash + 1, secondSlash - firstSlash - 1);

	// Find the third slash
	size_t thirdSlash = rawText.find('/', secondSlash + 1);

	// Check if there's content between 2nd and 3rd slash (middle part exists)
	bool hasMiddlePart = (thirdSlash != std::string::npos) && (thirdSlash > secondSlash + 1);

	std::string singularName;
	std::string pluralName;

	if (hasMiddlePart)
	{
		// Format: article/prefix/suffix/plural_ending (e.g., "/kni/fe/ves")
		std::string prefix = firstPart;
		std::string suffix = rawText.substr(secondSlash + 1, thirdSlash - secondSlash - 1);
		std::string pluralEnding = rawText.substr(thirdSlash + 1);

		singularName = prefix + suffix;  // "kni" + "fe" = "knife"
		pluralName = prefix + pluralEnding;  // "kni" + "ves" = "knives"
	}
	else
	{
		// Format: article/singular_name//plural_suffix (e.g., "a/garlic//s")
		singularName = firstPart;
		std::string pluralSuffix = "";
		if (thirdSlash != std::string::npos && thirdSlash + 1 < rawText.length())
		{
			pluralSuffix = rawText.substr(thirdSlash + 1);
		}
		pluralName = singularName + pluralSuffix;  // "garlic" + "s" = "garlics"
	}

	if (quantity == 1)
	{
		// Only add article if it's not empty and not just whitespace
		if (!article.empty() && article.find_first_not_of(" \t") != std::string::npos)
			return article + " " + singularName;
		else
			return singularName;
	}
	else
	{
		// Plural: quantity + plural name
		if (quantity > 0)
			return std::to_string(quantity) + " " + pluralName;
		else
			return singularName; // quantity 0 or invalid, just show the name
	}
}

std::string GetShapeFrameName(int shape, int frame, int quantity)
{
	// Check if misc_names are loaded yet
	if (!g_miscNames.empty())
	{
		// Shape 842: Reagents (8 frames)
		if (shape == 842 && frame >= 0 && frame < 8)
		{
			// Reagents: frames 0-7 map to misc_names 256-263
			// (black pearl, blood moss, nightshade, mandrake, garlic, ginseng, spider silk, sulfurous ash)
			int miscIndex = 256 + frame;
			if (miscIndex < g_miscNames.size())
			{
				return ParseU7TextFormat(g_miscNames[miscIndex], quantity);
			}
		}

		// Shape 377: Food items (32 frames)
		if (shape == 377 && frame >= 0 && frame < 32)
		{
			// Food items: frames 0-31 map to misc_names 267-298
			// (bread, bread, rolls, fruitcake, cake, pie, pastry, sausage, mutton, beef, fowl, etc.)
			int miscIndex = 267 + frame;
			if (miscIndex < g_miscNames.size())
			{
				return ParseU7TextFormat(g_miscNames[miscIndex], quantity);
			}
		}

		// Shape 675: Desk items (21 frames)
		if (shape == 675 && frame >= 0 && frame < 21)
		{
			// Desk items: frames 0-20 map to misc_names 301-321
			int miscIndex = 301 + frame;
			if (miscIndex < g_miscNames.size())
			{
				return ParseU7TextFormat(g_miscNames[miscIndex], quantity);
			}
		}

		// TODO: Shape 863: Kitchen items - need to find correct misc_names mapping from Exult
	}

	// Fall back to shape name if no frame-specific name found
	// Still parse it to handle the "a/name//s" format
	if (shape >= 0 && shape < 1024)
	{
		std::string shapeName = g_objectDataTable[shape].m_name;
		if (!shapeName.empty())
		{
			return ParseU7TextFormat(shapeName, quantity);
		}
	}

	return "unknown";
}

std::string FindNPCScriptByID(int npcID)
{
	// Format NPC ID as 4-digit hex suffix: _XXXX
	stringstream ss;
	ss << std::setfill('0') << std::setw(4) << npcID;
	string suffix = "_" + ss.str();

	// Search for script ending with this suffix that starts with "npc_"
	for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
	{
		const string& name = g_ScriptingSystem->m_scriptFiles[i].first;

		// Check if name starts with "npc_" and ends with the suffix
		if (name.length() >= 4 + suffix.length() &&
			name.substr(0, 4) == "npc_" &&
			name.compare(name.length() - suffix.length(), suffix.length(), suffix) == 0)
		{
			return name;
		}
	}

	return "";  // No matching NPC script found
}

std::string GetObjectScriptName(U7Object* object)
{
	if (!object)
		return "";

	// NPCs with conversation trees use NPC ID-based scripts
	if (object->m_isNPC && object->m_hasConversationTree)
	{
		return FindNPCScriptByID(object->m_NPCID);
	}
	// Regular objects use shape table scripts
	else
	{
		int shape = object->m_shapeData->GetShape();
		int frame = object->m_shapeData->GetFrame();
		if (shape < g_shapeTable.size() && frame < g_shapeTable[shape].size())
		{
			const std::string& scriptName = g_shapeTable[shape][frame].m_luaScript;
			if (!scriptName.empty() && scriptName != "default")
			{
				return scriptName;
			}
		}
	}

	return "";  // No script or using default
}

// Equipment slot configuration loaded from slots.json
static std::map<int, std::vector<EquipmentSlot>> g_equipmentSlotMap;      // Valid slots item can be placed in
static std::map<int, std::vector<EquipmentSlot>> g_equipmentSlotFillsMap; // All slots item occupies when equipped

// String to EquipmentSlot enum conversion
static EquipmentSlot StringToEquipmentSlot(const std::string& slotName)
{
	if (slotName == "SLOT_HEAD") return EquipmentSlot::SLOT_HEAD;
	if (slotName == "SLOT_NECK") return EquipmentSlot::SLOT_NECK;
	if (slotName == "SLOT_TORSO") return EquipmentSlot::SLOT_TORSO;
	if (slotName == "SLOT_LEGS") return EquipmentSlot::SLOT_LEGS;
	if (slotName == "SLOT_HANDS") return EquipmentSlot::SLOT_HANDS;
	if (slotName == "SLOT_FEET") return EquipmentSlot::SLOT_FEET;
	if (slotName == "SLOT_LEFT_HAND") return EquipmentSlot::SLOT_LEFT_HAND;
	if (slotName == "SLOT_RIGHT_HAND") return EquipmentSlot::SLOT_RIGHT_HAND;
	if (slotName == "SLOT_AMMO") return EquipmentSlot::SLOT_AMMO;
	if (slotName == "SLOT_LEFT_RING") return EquipmentSlot::SLOT_LEFT_RING;
	if (slotName == "SLOT_RIGHT_RING") return EquipmentSlot::SLOT_RIGHT_RING;
	if (slotName == "SLOT_BELT") return EquipmentSlot::SLOT_BELT;
	if (slotName == "SLOT_BACKPACK") return EquipmentSlot::SLOT_BACKPACK;
	return EquipmentSlot::SLOT_COUNT;
}

// Load equipment slot configuration from Data/equip_slots.json
void LoadEquipmentSlotsConfig()
{
	g_equipmentSlotMap.clear();
	g_equipmentSlotFillsMap.clear();

	std::string configPath = "Data/equip_slots.json";

	std::ifstream file(configPath);
	if (!file.is_open())
	{
		Log("ERROR: Could not open " + configPath);
		return;
	}

	try
	{
		nlohmann::json config;
		file >> config;

		// New format: root object is a map of shape_id (as string) to item data
		if (config.is_object())
		{
			for (auto& [shapeIdStr, item] : config.items())
			{
				// Convert string key to int
				int shapeId = std::stoi(shapeIdStr);

				if (item.contains("slots") && item["slots"].is_array())
				{
					std::vector<EquipmentSlot> validSlots;

					// Load valid slots (where item can be placed)
					for (const auto& slotName : item["slots"])
					{
						EquipmentSlot slot = StringToEquipmentSlot(slotName.get<std::string>());
						if (slot != EquipmentSlot::SLOT_COUNT)
						{
							validSlots.push_back(slot);
						}
					}

					if (!validSlots.empty())
					{
						g_equipmentSlotMap[shapeId] = validSlots;
					}

					// Load fills (all slots occupied when equipped)
					if (item.contains("fills") && item["fills"].is_array())
					{
						std::vector<EquipmentSlot> fillSlots;
						for (const auto& slotName : item["fills"])
						{
							EquipmentSlot slot = StringToEquipmentSlot(slotName.get<std::string>());
							if (slot != EquipmentSlot::SLOT_COUNT)
							{
								fillSlots.push_back(slot);
							}
						}
						if (!fillSlots.empty())
						{
							g_equipmentSlotFillsMap[shapeId] = fillSlots;
						}
					}
				}
			}
		}

		Log("Loaded equipment slot configuration for " + std::to_string(g_equipmentSlotMap.size()) + " item types");
	}
	catch (const std::exception& e)
	{
		Log("ERROR: Failed to parse " + configPath + ": " + e.what());
	}
}

// Returns all valid equipment slots for an item shape ID
std::vector<EquipmentSlot> GetEquipmentSlotsForShape(int shapeId)
{
	auto it = g_equipmentSlotMap.find(shapeId);
	if (it != g_equipmentSlotMap.end())
	{
		return it->second;
	}
	return {}; // Empty vector if not equippable
}

// Returns all slots this item occupies when equipped (may be multiple)
std::vector<EquipmentSlot> GetEquipmentSlotsFilled(int shapeId)
{
	auto it = g_equipmentSlotFillsMap.find(shapeId);
	if (it != g_equipmentSlotFillsMap.end())
	{
		return it->second;
	}
	return {}; // Empty vector if not equippable
}

// Deprecated: Returns only the first valid equipment slot for an item
// Use GetEquipmentSlotsForShape() for items that can go in multiple slots
EquipmentSlot GetEquipmentSlotForShape(int shapeId)
{
	auto slots = GetEquipmentSlotsForShape(shapeId);
	if (!slots.empty())
	{
		return slots[0];
	}
	return EquipmentSlot::SLOT_COUNT;
}

// NPCData equipment management implementations
void NPCData::SetEquippedItem(EquipmentSlot slot, int objectId)
{
	m_equipment[slot] = objectId;

	// Add to NPC's inventory if not already there, or invalidate cache if it is
	U7Object* npcObject = g_objectList[m_objectID].get();
	if (npcObject)
	{
		if (!npcObject->IsInInventoryById(objectId))
		{
			npcObject->AddObjectToInventory(objectId);
		}
		else
		{
			// Item already in inventory, just invalidate weight cache
			npcObject->InvalidateWeightCache();
		}
	}
}

void NPCData::UnequipItem(EquipmentSlot slot)
{
	int objectId = GetEquippedItem(slot);
	m_equipment[slot] = -1;

	// Remove from NPC's inventory
	if (objectId != -1)
	{
		U7Object* npcObject = g_objectList[m_objectID].get();
		if (npcObject)
		{
			npcObject->RemoveObjectFromInventory(objectId);
		}
	}
}

//////////////////////////////////////////////////////////////////////////////
//  SPELL SYSTEM
//////////////////////////////////////////////////////////////////////////////

void LoadSpellData()
{
	Log("Loading spell data from spells.json...");

	// Clear existing data
	g_reagentData.clear();
	g_spellCircles.clear();
	g_spellMap.clear();

	// Open spells.json
	std::string spellDataPath = "Data/spells.json";
	std::ifstream file(spellDataPath);

	if (!file.is_open())
	{
		Log("ERROR: Could not open " + spellDataPath);
		AddConsoleString("ERROR: Could not open " + spellDataPath, RED);
		return;
	}

	try
	{
		nlohmann::json spellJson;
		file >> spellJson;

		// Load reagents
		if (spellJson.contains("reagents") && spellJson["reagents"].is_array())
		{
			for (const auto& reagentJson : spellJson["reagents"])
			{
				ReagentData reagent;
				reagent.name = reagentJson["name"].get<std::string>();
				reagent.frame = reagentJson["frame"].get<int>();
				g_reagentData.push_back(reagent);
			}
			Log("Loaded " + std::to_string(g_reagentData.size()) + " reagents");
		}

		// Load spell circles
		if (spellJson.contains("circles") && spellJson["circles"].is_array())
		{
			for (const auto& circleJson : spellJson["circles"])
			{
				SpellCircle circle;
				circle.circle = circleJson["circle"].get<int>();
				circle.name = circleJson["name"].get<std::string>();

				// Load spells in this circle
				if (circleJson.contains("spells") && circleJson["spells"].is_array())
				{
					for (const auto& spellJson : circleJson["spells"])
					{
						SpellData spell;
						spell.id = spellJson["id"].get<int>();
						spell.name = spellJson["name"].get<std::string>();
						spell.x = spellJson["x"].get<int>();
						spell.y = spellJson["y"].get<int>();
						spell.words = spellJson["words"].get<std::string>();
						spell.scriptId = spellJson["scriptId"].get<int>();
						spell.circle = circle.circle;

						// Load reagents
						if (spellJson.contains("reagents") && spellJson["reagents"].is_array())
						{
							for (const auto& reagentName : spellJson["reagents"])
							{
								spell.reagents.push_back(reagentName.get<std::string>());
							}
						}

						// Load description
						if (spellJson.contains("desc"))
						{
							spell.desc = spellJson["desc"].get<std::string>();
						}

						circle.spells.push_back(spell);
					}
				}

				g_spellCircles.push_back(circle);
			}
			Log("Loaded " + std::to_string(g_spellCircles.size()) + " spell circles");
		}

		// Build spell lookup map
		for (auto& circle : g_spellCircles)
		{
			for (auto& spell : circle.spells)
			{
				g_spellMap[spell.id] = &spell;
			}
		}
		Log("Built spell lookup map with " + std::to_string(g_spellMap.size()) + " spells");
		AddConsoleString("Loaded " + std::to_string(g_spellMap.size()) + " spells from spells.json", GREEN);
	}
	catch (const std::exception& e)
	{
		Log("ERROR: Exception while loading spell data: " + std::string(e.what()));
		AddConsoleString("ERROR: Exception while loading spell data", RED);
	}

	file.close();
}

SpellData* GetSpellData(int spellId)
{
	auto it = g_spellMap.find(spellId);
	if (it != g_spellMap.end())
	{
		return it->second;
	}
	return nullptr;
}
