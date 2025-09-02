#include "U7Globals.h"
#include "Geist/Engine.h"
#include "Geist/Logging.h"
#include "ConversationState.h"
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

unordered_map<int, std::unique_ptr<U7Object> > g_ObjectList;

Mesh* g_AnimationFrames;

Texture* g_Cursor;
Texture* g_Minimap;

std::shared_ptr<Font> g_Font;
std::shared_ptr<Font> g_SmallFont;
std::shared_ptr<Font> g_ConversationFont;
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

Vector3 g_terrainUnderMousePointer = Vector3{ 0, 0, 0 };

U7Object* g_mouseOverObject = nullptr;

std::unique_ptr<GumpManager> g_gumpManager;

U7Object* g_objectUnderMousePointer;

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

unsigned int DoCameraMovement()
{
	g_CameraMoved = false;

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
	auto it = g_ObjectList.find(unitID);
	if (it != g_ObjectList.end())
	{
		return it->second.get(); // Returns raw pointer to U7Object
	}
	return nullptr;
}

void UpdateSortedVisibleObjects()
{
	int cameraChunkI = static_cast<int>(g_camera.target.x / 16);
	int cameraChunkJ = static_cast<int>(g_camera.target.z / 16);
	int minChunkIVisibleDistance = static_cast<int>(TILEWIDTH / 2 / 16);
	int minChunkJVisibleDistance = static_cast<int>(TILEHEIGHT / 2 / 16);
 	g_sortedVisibleObjects.clear();

 	for (int i = 0; i < 192; i++)
 	{
 		for (int j = 0; j < 192; j++)
 		{
 			bool isChunkVisible = abs(cameraChunkI - i) <= minChunkIVisibleDistance && abs(cameraChunkJ - j) <= minChunkJVisibleDistance;

 			if (isChunkVisible)
 			{
 				for (auto object : g_chunkObjectMap[i][j])
 				{
 					object->m_distanceFromCamera = Vector3DistanceSqr(object->m_centerPoint, g_camera.position);

 					g_sortedVisibleObjects.push_back(object);
 				}
 			}
 		}
 	}

 	std::sort(g_sortedVisibleObjects.begin(), g_sortedVisibleObjects.end(), [](U7Object* a, U7Object* b) { return a->m_distanceFromCamera > b->m_distanceFromCamera; });

	g_objectUnderMousePointer = nullptr;
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

void AddObject(int shapenum, int framenum, int id, float x, float y, float z)
{
	if (shapenum == 451)
	{
		Log("Stop here.");
	}

	g_ObjectList.emplace(id, make_unique<U7Object>());

	U7Object* temp = g_ObjectList[id].get();
	temp->Init("Data/Units/Walker.cfg", shapenum, framenum);
	temp->m_ID = id;
	temp->SetInitialPos(Vector3{ x, y, z });
	AssignObjectChunk(temp);
}

void UpdateObjectChunk(U7Object* object, Vector3 fromPos)
{
	int fromI = static_cast<int>(fromPos.x / 16);
	int fromJ = static_cast<int>(fromPos.z / 16);
	int toI = static_cast<int>(object->m_Pos.x / 16);
	int toJ = static_cast<int>(object->m_Pos.z / 16);

	if (fromI == toI && fromJ == toJ)
	{
		// Object hasn't moved chunk
		return;
	}

	assert(fromI >= 0 && fromI < 192);
	assert(toI >= 0 && toI < 192);
	assert(fromJ >= 0 && fromJ < 192);
	assert(toJ >= 0 && toJ < 192);

	auto& fromChunk = g_chunkObjectMap[fromI][fromJ];
	auto fromChunkPos = std::find(fromChunk.begin(), fromChunk.end(), object);
    if (fromChunkPos != fromChunk.end()) {
        fromChunk.erase(fromChunkPos);
    }

	auto& toChunk = g_chunkObjectMap[toI][toJ];
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

	auto fromChunk = g_chunkObjectMap[i][j];
	auto fromChunkPos = std::find(fromChunk.begin(), fromChunk.end(), object);
    if (fromChunkPos != fromChunk.end())
    {
        fromChunk.erase(fromChunkPos);
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

void DrawParagraph(std::shared_ptr<Font> font, const std::string& text, Vector2 position, float maxwidth, float fontSize, int spacing, Color color)
{
	std::istringstream iss(text);
	std::string word;
	std::vector<std::string> lines;
	float lineWidth = 0;

	// If the text is less than the width, just draw it.
	if(MeasureTextEx(*font, text.c_str(), fontSize, spacing).x < maxwidth)
	{
		DrawOutlinedText(font, text.c_str(), position, fontSize, spacing, color);
		return;
	}

	string line;
	while (iss >> word)
	{
		if(MeasureTextEx(*font, line.c_str(), fontSize, spacing).x > maxwidth)
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

	if (!line.empty())
	{
		lines.push_back(line);
	}

	auto it = lines.begin();
	float y = position.y;
	while (it != lines.end())
	{
		DrawOutlinedText(font, (*it).c_str(), Vector2{ position.x, y }, fontSize, spacing, color);
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

bool WasLMBDoubleClicked()
{
	static bool lmblastState = false;
	static float lmblastTime = 0;

	if (IsMouseButtonReleased(MOUSE_LEFT_BUTTON))
	{
		if (lmblastState == false)
		{
			lmblastState = true;
			lmblastTime = GetTime();
		}
	}
	else if(IsMouseButtonPressed(MOUSE_LEFT_BUTTON))  // if (IsMouseButtonPressed
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

bool WasRMBDoubleClicked()
{
	static bool rmblastState = false;
	static float rmblastTime = 0;

	if (IsMouseButtonReleased(MOUSE_RIGHT_BUTTON))
	{
		if (rmblastState == false)
		{
			rmblastState = true;
			rmblastTime = GetTime();
		}
	}
	else if(IsMouseButtonPressed(MOUSE_RIGHT_BUTTON))  // if (IsMouseButtonPressed
	{
		if (GetTime() - rmblastTime < .25f)
		{
			rmblastState = false;
			return true;
		}
		rmblastState = false;
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


// int l_add_dialogue(lua_State* L)
// {
// 	const char* message = luaL_checkstring(L, 1);
// 	printf("Lua says: %s\n", message);
// 	return 0;
// }
