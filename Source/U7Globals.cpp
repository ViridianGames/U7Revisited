#include "U7Globals.h"
#include "Geist/Engine.h"
#include "Geist/Logging.h"
#include <algorithm>
#include <fstream>
#include <sstream>
#include <iterator>
#include <utility>
#include <iomanip>

using namespace std;

std::string g_version;

unordered_map<int, std::shared_ptr<U7Object> > g_ObjectList;

Mesh* g_AnimationFrames;

Texture* g_Cursor;
Texture* g_Minimap;

std::shared_ptr<Font> g_Font;
//std::shared_ptr<Font> g_SmallFont;

//float g_smallFontSize = 8;
float g_fontSize = 16;

std::unique_ptr<RNG> g_VitalRNG;
std::unique_ptr<RNG> g_NonVitalRNG;

std::unique_ptr<Terrain> g_Terrain;

std::array<std::array<ShapeData, 32>, 1024> g_shapeTable;
std::array<ObjectData, 1024> g_objectTable;

bool g_CameraMoved;

unsigned int g_CurrentUpdate;

unsigned int g_minimapSize;

std::vector< std::vector<unsigned short> > g_World;

Vector3 g_Gravity = Vector3{ 0, .1f, 0 };

float g_CameraRotateSpeed = 0;

bool v_showMinimap = false;

Vector3 g_CameraMovementSpeed = Vector3{ 0, 0, 0 };

std::string g_gameStateStrings[] = { "LoadingState", "TitleState", "MainState", "OptionsState", "ObjectEditorState", "WorldEditorState" };

std::string g_objectDrawTypeStrings[] = { "None", "Billboard", "Cuboid", "Flat", "Custom Mesh", "Character", "Terrain", "Ocean", "River"};

std::string g_objectTypeStrings[] = { "Static", "Creature", "Weapon", "Armor", "Container", "Quest Item", "Key", "Item" };

int g_selectedShape = 150;
int g_selectedFrame = 0;

std::unordered_map<int, int[16][16]> g_ChunkTypeList;  // The 16x16 tiles for each chunk type
int g_chunkTypeMap[192][192]; // The type of each chunk in the map
std::vector<U7Object*> g_chunkObjectMap[192][192]; // The objects in each chunk

float g_cameraDistance; // distance from target
float g_cameraRotation = 0; // angle around target

//animframes
bool g_animFramesInitialized = false;
int g_currentAnimFrame[32];

Shader g_alphaDiscard;

bool m_pixelated = false;
RenderTexture2D m_renderTarget;

//  Slow.  Use only when you actually need to know the distance.
float GetDistance(float startX, float startZ, float endX, float endZ)
{
	float dx = startX - endX;
	float dz = startZ - endZ;
	return sqrt((dx * dx) + (dz * dz));
}

//  Use when you just need to know if the distance is less than a certain range
//  (which is 90% of the time).  Much faster because it does not require a square root call.
//  Yes, technically it's "Is less than or equals to".
bool IsDistanceLessThan(float startX, float startZ, float endX, float endZ, float range)
{
	float dx = startX - endX;
	float dz = startZ - endZ;
	return ((dx * dx) + (dz * dz)) <= (range * range);
}

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

	float frameTimeModifier = 32.0;

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

	if (v_showMinimap)
	{
		if (IsLeftButtonDownInRect(GetRenderWidth() - g_minimapSize, 0, g_minimapSize, g_minimapSize))
		{
			float minimapx = float(GetMouseX() - (GetRenderWidth() - g_minimapSize)) / float(g_minimapSize) * 3072;
			float minimapy = float(GetMouseY()) / float(g_minimapSize) * 3072;

			g_camera.target = Vector3{ minimapx, 0, minimapy };
			g_CameraMoved = true;
		}
	}

	bool moveDecay = false;
	bool rotateDecay = false;
	if (!g_CameraMoved && (g_CameraMovementSpeed.x != 0 || g_CameraMovementSpeed.z != 0))
	{
		g_CameraMovementSpeed = Vector3{ g_CameraMovementSpeed.x * .75f, g_CameraMovementSpeed.y, g_CameraMovementSpeed.z * .75f };

		if (abs(g_CameraMovementSpeed.x) < .0001f)
		{
			g_CameraMovementSpeed.x = 0;
		}

		if (abs(g_CameraMovementSpeed.z) < .0001f)
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

		Vector3 current = g_camera.target;

		Vector3 finalmovement = Vector3RotateByAxisAngle(g_CameraMovementSpeed, Vector3{ 0, 1, 0 }, g_cameraRotation);

		current = Vector3Add(current, finalmovement);

		float worldBoxSize = 3072.0;
		while (current.x < 0.0)
		{
			current.x += worldBoxSize;
		}
		while (current.x >= worldBoxSize)
		{
				current.x -= worldBoxSize;
		}

		while (current.z < 0.0)
		{
			current.z += worldBoxSize;
		}
		while (current.z >= (worldBoxSize + 0.0))
		{
				current.z -= worldBoxSize;
		}

		/*
		if (current.x < 0) current.x = 0;
		if (current.x > 3072) current.x = 3072;
		if (current.z < 0) current.z = 0;
		if (current.z > 3072) current.z = 3072;
		*/
		float xOfs = g_cameraDistance * 0.5;
		float yOfs = g_cameraDistance * 0.5;
		Vector3 camPos = { xOfs, g_cameraDistance, yOfs };
		camPos = Vector3RotateByAxisAngle(camPos, Vector3{ 0, 1, 0 }, g_cameraRotation);

		g_camera.target = current;
		g_camera.position = Vector3Add(current, camPos);
		g_camera.fovy = 60.0;
	}
	DoGlobalAnimationFramesUpdate();
	return 0;
}

void DoGlobalAnimationFramesUpdate()
{
	float fTime = GetTime();
	float iTime = float(int(fTime));
	if (iTime > fTime) {
		iTime -= 1.0;
	}
	float inSecond = fTime - iTime;
	float frameTime = 1.0 / 3.0;
	float sKeep = 0.0;

	if (g_animFramesInitialized == false)
	{
		for (int i = 0; i < 32; i++)
		{
			g_currentAnimFrame[i] = 0;
		}
		g_animFramesInitialized = true;
	}

	for (int i = 2; i < 32; i++)
	{
		g_currentAnimFrame[i] = 0;
		frameTime = 1.0 / float(i);
		sKeep = inSecond;
		while ((sKeep - frameTime) > 0.0)
		{
			g_currentAnimFrame[i] += 1;
			sKeep -= frameTime;
		}
		if (g_currentAnimFrame[i] >= i)
		{
			g_currentAnimFrame[i] = 0;
		}
	}
}

int GetGlobalAnimationFrame(int frameCount)
{
	if (frameCount > 2)
	{
		if (frameCount < 32)
		{
			return g_currentAnimFrame[frameCount];
		}
	}
	return 0;
}

shared_ptr<U7Object> GetPointerFromID(int unitID)
{
	unordered_map<int, shared_ptr<U7Object> >::iterator finder = g_ObjectList.find(unitID);

	if (finder == g_ObjectList.end())
		return nullptr;
	else
		return (*finder).second;
}

shared_ptr<U7Object> U7ObjectClassFactory(int type)
{
		shared_ptr<U7Object> temp = make_shared<U7Object>();
		temp->m_ObjectType = type;
		return temp;
}

vector<shared_ptr<U7Object> > GetAllUnitsWithinRange(float x, float y, float range)
{
	vector<shared_ptr<U7Object> > _Targets;
	for (auto& unit : g_ObjectList)
	{
		if (IsDistanceLessThan(x, y, unit.second->m_Pos.x, unit.second->m_Pos.z, range))
		{
			_Targets.emplace_back(unit.second);
		}
	}

	return _Targets;
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
	/*
	if (shapenum == 451)
	{
		Log("Stop here.");
	}
	*/
	//printf("  adding object shape:%d frame:%d id:%d pos(%f %f %f)\n", shapenum, framenum, id, x, y, z);
	shared_ptr<U7Object> temp = U7ObjectClassFactory(0);
	temp->Init("Data/Units/Walker.cfg", shapenum, framenum);
	temp->SetInitialPos(Vector3{ x, y, z });
	temp->m_ID = id;

	g_ObjectList[id] = temp;
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
}

void DrawConsole()
{
	int counter = 0;
	vector<ConsoleString>::iterator node = g_ConsoleStrings.begin();
	float shadowOffset = GetRenderWidth() / 850.0f;
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
			DrawTextEx(*g_Font, (*node).m_String.c_str(), Vector2{ shadowOffset, counter * (g_Font->baseSize + 2) + shadowOffset }, g_fontSize, 1, Color{ 0, 0, 0, (*node).m_Color.a });
			DrawTextEx(*g_Font, (*node).m_String.c_str(), Vector2{ 0, float(counter * (g_Font->baseSize + 2)) }, g_fontSize, 1, (*node).m_Color);

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

shared_ptr<Sprite> g_InactiveButtonL;
shared_ptr<Sprite> g_InactiveButtonM;
shared_ptr<Sprite> g_InactiveButtonR;
shared_ptr<Sprite> g_ActiveButtonL;
shared_ptr<Sprite> g_ActiveButtonM;
shared_ptr<Sprite> g_ActiveButtonR;

shared_ptr<Sprite> g_LeftArrow;
shared_ptr<Sprite> g_RightArrow;

Camera g_camera = { 0 };

bool g_hasCameraChanged = true;

EngineModes g_engineMode = EngineModes::ENGINE_MODE_BLACK_GATE;

std::string g_engineModeStrings[] = { "blackgate", "serpentisle", "NONE" };


