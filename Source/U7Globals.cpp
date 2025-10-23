#include "U7Globals.h"
#include "Geist/Engine.h"
#include "Geist/Logging.h"
#include "ConversationState.h"
#include "Pathfinding.h"
#include "lua.hpp"
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

Texture* g_Cursor;
Texture* g_objectSelectCursor;
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

std::unordered_map<int, unique_ptr<NPCData>> g_NPCData;

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

std::string g_objectDrawTypeStrings[] = { "Billboard", "Cuboid", "Flat", "Custom Mesh"};

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

bool g_LuaDebug = true;

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

// Pathfinding
PathfindingGrid* g_pathfindingGrid = nullptr;

Vector3 g_terrainUnderMousePointer = Vector3{ 0, 0, 0 };

U7Object* g_mouseOverObject = nullptr;

std::unique_ptr<GumpManager> g_gumpManager;

U7Object* g_objectUnderMousePointer;

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
		direction = Vector3Add(direction, {-GetFrameTime() * frameTimeModifier, 0, GetFrameTime() * frameTimeModifier });
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
		direction = Vector3Add(direction,  { GetFrameTime() * frameTimeModifier, 0, GetFrameTime() * frameTimeModifier });
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

	if(mouseWheel)
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

	if (IsLeftButtonDownInRect(g_Engine->m_ScreenWidth - (g_minimapSize * g_DrawScale), 0, g_Engine->m_ScreenWidth, g_minimapSize * g_DrawScale))
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
			g_cameraRotation +=  2 * PI;
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

void UpdateSortedVisibleObjects()
{
	int cameraChunkX = static_cast<int>(g_camera.target.x / 16);
	int cameraChunkY = static_cast<int>(g_camera.target.z / 16);
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
				object->m_distanceFromCamera = Vector3DistanceSqr(object->m_centerPoint, g_camera.position);
				g_sortedVisibleObjects.push_back(object);
 			}
 		}
 	}

 	std::sort(g_sortedVisibleObjects.begin(), g_sortedVisibleObjects.end(), [](U7Object* a, U7Object* b) { return a->m_distanceFromCamera > b->m_distanceFromCamera; });

	g_objectUnderMousePointer = nullptr;

	//  Is a gump open?  Are we over it?  See if there's an object under our mouse.
	if (!g_gumpManager->m_GumpList.empty() && g_gumpManager->IsMouseOverGump())
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

			Vector3 pos = { 0, 0, 0};
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

	g_terrainUnderMousePointer = {pickx, 0, picky};

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
			if(currentLineWidth > maxwidth)
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
		return;
	}

	container->AddObjectToInventory(objectID);

	// Objects in containers are not in world chunks
	UnassignObjectChunk(object);
}

float g_DrawScale;

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
	else if(IsMouseButtonPressed(button))  // if (IsMouseButtonPressed
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
	if (!g_pathfindingGrid)
		return;

	g_pathfindingGrid->UpdatePosition(worldX, worldZ);
}


// int l_add_dialogue(lua_State* L)
// {
// 	const char* message = luaL_checkstring(L, 1);
// 	printf("Lua says: %s\n", message);
// 	return 0;
// }
