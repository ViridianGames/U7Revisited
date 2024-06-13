#include "U7Globals.h"
#include "Geist/Engine.h"
#include <algorithm>
#include <fstream>
#include <sstream>
#include <iterator>
#include <utility>
#include <iomanip>

using namespace std;

std::string g_VERSION;

unordered_map<int, std::shared_ptr<U7Object> > g_ObjectList;

Mesh* g_AnimationFrames;

Texture* g_Cursor;
Texture* g_Minimap;

std::shared_ptr<Font> g_Font;
std::shared_ptr<Font> g_SmallFont;

float g_smallFontSize = 8;
float g_fontSize = g_smallFontSize * 2;

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

Vector3 g_CameraMoveSpeed = Vector3{ 0, 0, 0 };

std::string g_gameStateStrings[] = { "LoadingState", "TitleState", "MainState", "OptionsState", "ObjectEditorState", "WorldEditorState" };

std::string g_objectDrawTypeStrings[] = { "Billboard", "Cuboid", "Flat", "Custom Mesh"};

std::string g_objectTypeStrings[] = { "Static", "Creature", "Weapon", "Armor", "Container", "Quest Item", "Key", "Item" };

int g_selectedShape = 150;
int g_selectedFrame = 0;

Camera g_Camera;

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
void DoCameraRotation()
{
	static float s_deltaAngle; // used as lerp target to smooth camera rotation out.
	//if (IsMouseButtonPressed(MOUSE_BUTTON_MIDDLE))
	//{

	//	if (!m_MouseLocked)
	//	{
	//		LockMouse();
	//		s_deltaAngle = 0.0f;
	//		return;
	//	}

	//	s_deltaAngle = Lerp(s_deltaAngle, -m_MouseDeltaX / 3.0f, 0.2f);
	//	float newAngle = GetCameraAngle() + s_deltaAngle;
	//	SetCameraAngle(newAngle);
	//	SetCameraChanged(true);
	//	UpdateCamera();
	//	g_CameraMoved = true;
	//	return;

	//}

	//if (m_MouseLocked)
	//{
	//	UnlockMouse();
	//	g_CameraRotateSpeed = s_deltaAngle;
	//}


	if (IsKeyDown(KEY_Q))
	{
		g_CameraRotateSpeed += GetFrameTime() * 50;
		if (g_CameraRotateSpeed > 8)
		{
			g_CameraRotateSpeed = 8;
		}
		g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_E))
	{
		g_CameraRotateSpeed -= GetFrameTime() * 50;
		if (g_CameraRotateSpeed < -8)
		{
			g_CameraRotateSpeed = -8;
		}
		g_CameraMoved = true;
	}

	if (!g_CameraMoved)
	{
		g_CameraRotateSpeed *= .9;
		if (g_CameraRotateSpeed < 1 && g_CameraRotateSpeed > -1)
		{
			g_CameraRotateSpeed = 0;
		}
	}


	if (g_CameraRotateSpeed != 0)
	{
		//SetCameraAngle(GetCameraAngle() + g_CameraRotateSpeed);
		//SetCameraChanged(true);
		g_CameraMoved = true;
	}
}

unsigned int DoCameraMovement()
{
	unsigned int time = GetTime();
	g_CameraMoved = false;

	float speed = 50;

	if (GetKeyPressed() == 0)
	{
		int stopper = 0;
	}

	DoCameraRotation();

	if (IsKeyDown(KEY_A))
	{
		//Vector3 current = GetCameraLookAtPoint();
		//Vector3 direction = Vector3{ -1, 0, 1 };

		//direction = direction * ((float)g_Engine->LastUpdateInMS() / speed);

		//Vector4 final = GetCameraRotationMatrix() * Vector4 { direction.x, direction.y, direction.z, 1 };

		//current = Vector3Add(current, Vector3{ final.x, final.y, final.z });

		//if (current.x < 0) current.x = 0;
		//if (current.x > g_Terrain->m_CellWidth) current.x = g_Terrain->m_CellWidth;
		//if (current.z < 0) current.z = 0;
		//if (current.z > g_Terrain->m_CellHeight) current.z = g_Terrain->m_CellHeight;

		//SetCameraPosition(current);
		//g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_D))
	{
		//Vector3 current = GetCameraLookAtPoint();
		//Vector3 direction = Vector3{ 1, 0, -1 };

		//direction = direction * ((float)GetTime() / speed);

		//Vector4 final = GetCameraRotationMatrix() * Vector4 { direction.x, direction.y, direction.z, 1 };

		//current = Vector3Add(current, Vector3{ final.x, final.y, final.z });

		//if (current.x < 0) current.x = 0;
		//if (current.x > g_Terrain->m_CellWidth) current.x = g_Terrain->m_CellWidth;
		//if (current.z < 0) current.z = 0;
		//if (current.z > g_Terrain->m_CellHeight) current.z = g_Terrain->m_CellHeight;

		//SetCameraPosition(current);

		//g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_W))
	{
		//Vector3 current = GetCameraLookAtPoint();
		//Vector3 direction = Vector3{ -1, 0, -1 };

		//direction = Vector3{ float(direction.x * (GetTime() / speed)), float(direction.y * (GetTime() / speed)), float(direction.z * (GetTime() / speed)) };

		//Vector4 final = GetCameraRotationMatrix() * glm::vec4(direction, 1);

		//current = current + Vector3(final);

		//if (current.x < 0) current.x = 0;
		//if (current.x > g_Terrain->m_CellWidth) current.x = g_Terrain->m_CellWidth;
		//if (current.z < 0) current.z = 0;
		//if (current.z > g_Terrain->m_CellHeight) current.z = g_Terrain->m_CellHeight;

		//SetCameraPosition(current);
		//g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_S))
	{
		//Vector3 current = GetCameraLookAtPoint();
		//Vector3 direction = Vector3(1, 0, 1);

		//direction = direction * ((float)g_Engine->LastUpdateInMS() / speed);

		//glm::vec4 final = GetCameraRotationMatrix() * glm::vec4(direction, 1);

		//current = current + Vector3(final);

		//if (current.x < 0) current.x = 0;
		//if (current.x > g_Terrain->m_CellWidth) current.x = g_Terrain->m_CellWidth;
		//if (current.z < 0) current.z = 0;
		//if (current.z > g_Terrain->m_CellHeight) current.z = g_Terrain->m_CellHeight;

		//SetCameraPosition(current);

		//g_CameraMoved = true;
	}

	//if (MouseWheelUp())
	//{
	//	float newDistance = GetCameraDistance() + .01f;
	//	if (newDistance > g_Engine->m_EngineConfig.GetNumber("camera_far_limit"))
	//	{
	//		newDistance = g_Engine->m_EngineConfig.GetNumber("camera_far_limit");
	//	}

	//	SetCameraDistance(newDistance);
	//	SetCameraChanged(true);
	//	UpdateCamera();
	//	g_CameraMoved = true;
	//}

	//if (MouseWheelDown())
	//{
	//	float newDistance = GetCameraDistance() - .01f;
	//	if (newDistance < g_Engine->m_EngineConfig.GetNumber("camera_close_limit"))
	//	{
	//		newDistance = g_Engine->m_EngineConfig.GetNumber("camera_close_limit");
	//	}

	//	SetCameraDistance(newDistance);
	//	SetCameraChanged(true);
	//	UpdateCamera();
	//	g_CameraMoved = true;
	//}

	//if (IsLButtonDownInRegion(GetRenderWidth() - g_minimapSize, 0, GetRenderWidth(), g_minimapSize))
	//{
	//	float minimapx = float(GetMouseX() - (GetRenderWidth() - g_minimapSize)) / float(g_minimapSize) * 3072;
	//	float minimapy = float(GetMouseY()) / float(g_minimapSize) * 3072;

	//	SetCameraPosition(Vector3(minimapx, 0, minimapy));
	//	SetCameraChanged(true);
	//	UpdateCamera();
	//	g_CameraMoved = true;
	//}

	time = GetTime() - time;
	return time;
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
			DrawTextEx(*g_SmallFont, (*node).m_String.c_str(), Vector2{ 3, counter * (g_SmallFont->baseSize + 2) + 3.0f }, g_smallFontSize, 1, Color{ 0, 0, 0, (*node).m_Color.a });
			DrawTextEx(*g_SmallFont, (*node).m_String.c_str(), Vector2{ 0, float(counter * (g_SmallFont->baseSize + 2)) }, g_smallFontSize, 1, (*node).m_Color);

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

Camera g_camera;

bool g_hasCameraChanged = true;
