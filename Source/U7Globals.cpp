#include "U7Globals.h"
#include "U7Unit.h"
#include <algorithm>
#include <fstream>
#include <sstream>
#include <iterator>
#include <utility>
#include <iomanip>

using namespace std;

unordered_map<int, std::shared_ptr<U7Unit> > g_UnitList;

unordered_map<int, std::shared_ptr<U7Object> > g_ObjectList;

Mesh* g_AnimationFrames;

Texture* g_WalkerTexture;
Texture* g_WalkerMask;
Texture* g_Cursor;
Texture* g_Sprites;
Texture* g_Minimap;

std::shared_ptr<Font> g_Font;
std::shared_ptr<Font> g_SmallFont;

std::unique_ptr<RNG> g_VitalRNG;
std::unique_ptr<RNG> g_NonVitalRNG;

std::unique_ptr<Terrain> g_Terrain;

std::array<Texture*, 1024> g_shapeTable;
std::array<ObjectData, 1024> g_objectTable;

Mesh* g_TestMesh;

bool g_IsSinglePlayer;  //  not single payer
bool g_IsServer;

bool g_CameraMoved;

unsigned int g_CurrentUpdate;

unsigned int g_minimapSize;

std::vector< std::vector<unsigned short> > g_World;

glm::vec3 g_Gravity = glm::vec3(0, .1f, 0);

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

float Lerp(float a, float b, float t)
{
	return a - (a * t) + (b * t);
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

	g_AnimationFrames->Init(vertices, indices);
}

void DoCameraMovement()
{
	g_CameraMoved = false;

	float speed = 50;

	if (g_Input->WasAnyKeyPressed())
	{
		int stopper = 0;
	}
	if (g_Input->IsKeyDown(KEY_q))
	{
		g_Display->SetCameraAngle(g_Display->GetCameraAngle() + g_Engine->LastUpdateInMS() / 2);
		g_CameraMoved = true;
	}

	if (g_Input->IsKeyDown(KEY_e))
	{
		g_Display->SetCameraAngle(g_Display->GetCameraAngle() - g_Engine->LastUpdateInMS() / 2);
		g_CameraMoved = true;
	}

	if (g_Input->IsKeyDown(KEY_a))
	{
		glm::vec3 current = g_Display->GetCameraLookAtPoint();
		glm::vec3 direction = glm::vec3(-1, 0, 1);

		direction = direction * ((float)g_Engine->LastUpdateInMS() / speed);

		glm::vec4 final = g_Display->GetCameraRotationMatrix() * glm::vec4(direction, 1);

		current = current + glm::vec3(final);

		if (current.x < 0) current.x = 0;
		if (current.x > g_Terrain->m_CellWidth) current.x = g_Terrain->m_CellWidth;
		if (current.z < 0) current.z = 0;
		if (current.z > g_Terrain->m_CellHeight) current.z = g_Terrain->m_CellHeight;

		g_Display->SetCameraPosition(current);
		g_CameraMoved = true;
	}

	if (g_Input->IsKeyDown(KEY_d))
	{
		glm::vec3 current = g_Display->GetCameraLookAtPoint();
		glm::vec3 direction = glm::vec3(1, 0, -1);

		direction = direction * ((float)g_Engine->LastUpdateInMS() / speed);

		glm::vec4 final = g_Display->GetCameraRotationMatrix() * glm::vec4(direction, 1);

		current = current + glm::vec3(final);

		if (current.x < 0) current.x = 0;
		if (current.x > g_Terrain->m_CellWidth) current.x = g_Terrain->m_CellWidth;
		if (current.z < 0) current.z = 0;
		if (current.z > g_Terrain->m_CellHeight) current.z = g_Terrain->m_CellHeight;

		g_Display->SetCameraPosition(current);

		g_CameraMoved = true;
	}

	if (g_Input->IsKeyDown(KEY_w))
	{
		glm::vec3 current = g_Display->GetCameraLookAtPoint();
		glm::vec3 direction = glm::vec3(-1, 0, -1);

		direction = direction * ((float)g_Engine->LastUpdateInMS() / speed);

		glm::vec4 final = g_Display->GetCameraRotationMatrix() * glm::vec4(direction, 1);

		current = current + glm::vec3(final);

		if (current.x < 0) current.x = 0;
		if (current.x > g_Terrain->m_CellWidth) current.x = g_Terrain->m_CellWidth;
		if (current.z < 0) current.z = 0;
		if (current.z > g_Terrain->m_CellHeight) current.z = g_Terrain->m_CellHeight;

		g_Display->SetCameraPosition(current);
		g_CameraMoved = true;
	}

	if (g_Input->IsKeyDown(KEY_s))
	{
		glm::vec3 current = g_Display->GetCameraLookAtPoint();
		glm::vec3 direction = glm::vec3(1, 0, 1);

		direction = direction * ((float)g_Engine->LastUpdateInMS() / speed);

		glm::vec4 final = g_Display->GetCameraRotationMatrix() * glm::vec4(direction, 1);

		current = current + glm::vec3(final);

		if (current.x < 0) current.x = 0;
		if (current.x > g_Terrain->m_CellWidth) current.x = g_Terrain->m_CellWidth;
		if (current.z < 0) current.z = 0;
		if (current.z > g_Terrain->m_CellHeight) current.z = g_Terrain->m_CellHeight;

		g_Display->SetCameraPosition(current);

		g_CameraMoved = true;
	}

	if (g_Input->MouseWheelUp())
	{
		float newDistance = g_Display->GetCameraDistance() + 3;
		if (newDistance > g_Engine->m_EngineConfig.GetNumber("camera_far_limit"))
		{
			newDistance = g_Engine->m_EngineConfig.GetNumber("camera_far_limit");
		}

		g_Display->SetCameraDistance(newDistance);
		g_Display->SetHasCameraChanged(true);
		g_Display->UpdateCamera();
		g_CameraMoved = true;
	}

	if (g_Input->MouseWheelDown())
	{
		float newDistance = g_Display->GetCameraDistance() - 3;
		if (newDistance < g_Engine->m_EngineConfig.GetNumber("camera_close_limit"))
		{
			newDistance = g_Engine->m_EngineConfig.GetNumber("camera_close_limit");
		}

		g_Display->SetCameraDistance(newDistance);
		g_Display->SetHasCameraChanged(true);
		g_Display->UpdateCamera();
		g_CameraMoved = true;
	}

	if (g_Input->IsLButtonDownInRegion(g_Display->GetWidth() - g_minimapSize, 0, g_Display->GetWidth(), g_minimapSize))
	{
		float minimapx = float(g_Input->m_MouseX - (g_Display->GetWidth() - g_minimapSize)) / float(g_minimapSize) * 3072;
		float minimapy = float(g_Input->m_MouseY) / float(g_minimapSize) * 3072;

		g_Display->SetCameraPosition(glm::vec3(minimapx, 0, minimapy));
		g_Display->SetHasCameraChanged(true);
		g_Display->UpdateCamera();
		g_CameraMoved = true;
	}

}

shared_ptr<U7Unit> GetPointerFromID(int unitID)
{
	unordered_map<int, shared_ptr<U7Unit> >::iterator finder = g_UnitList.find(unitID);

	if (finder == g_UnitList.end())
		return nullptr;
	else
		return (*finder).second;
}

shared_ptr<U7Unit> U7UnitClassFactory(int type)
{
		shared_ptr<U7Unit> temp = make_shared<U7Unit>();
		temp->m_UnitType = type;
		return temp;
}

shared_ptr<U7Object> U7ObjectClassFactory(ObjectDrawTypes type)
{
	switch (type)
	{
	case ObjectDrawTypes::OBJECT_DRAW_BILLBOARD:
	{
		shared_ptr<U7Object> temp = make_shared<U7Object>();
		return temp;
	}
	break;
	case ObjectDrawTypes::OBJECT_DRAW_CUBOID:
	{
		shared_ptr<U7Object> temp = make_shared<U7Object>();
		temp->Init("Data/Objects/Cuboid.cfg");
		return temp;
	}
	break;

	default:
		throw("Bad identifier in unit factory!");
		break;
	}
}

vector<shared_ptr<U7Unit> > GetAllUnitsWithinRange(float x, float y, int range)
{
	vector<shared_ptr<U7Unit> > _Targets;
	for (auto& unit : g_UnitList)
	{
		if (IsDistanceLessThan(x, y, unit.second->m_Pos.x, unit.second->m_Pos.z, range))
		{
			_Targets.emplace_back(unit.second);
		}
	}

	return _Targets;
}

glm::vec3 GetRadialVector(float partitions, float thispartition)
{
	float finalpartition = ((PI * 2) / partitions) * thispartition;

	return glm::vec3(cos(finalpartition), 0, sin(finalpartition));
}

unsigned int g_CurrentUnitID = 0;

unsigned int GetNextID() { return g_CurrentUnitID++; }

void AddUnit(int player, int unittype, int id, float x, float y, float z)
{
	shared_ptr<U7Unit> temp = U7UnitClassFactory(unittype);
	temp->Init("Data/Units/Walker.cfg", unittype);
	temp->SetInitialPos(glm::vec3(x, y, z));
	temp->m_BaseTeam = player;
	temp->m_Team = player;
	temp->m_Texture = g_shapeTable[unittype];
	g_UnitList[id] = temp;
}

int AddObject(ObjectDrawTypes objecttype, int id, int shape, int frame, float x, float y, float z)
{
	shared_ptr<U7Object> temp = U7ObjectClassFactory(objecttype);
	temp->Init("Data/Objects/Billboard.cfg");
	temp->SetPos(glm::vec3(x, y, z));
	std::stringstream filename;
	filename << "Images/Objects/u7shape_" << std::setfill('0') << std::setw(4) << std::to_string(shape) << ".png";
	temp->m_Texture = g_ResourceManager->GetTexture(filename.str(), false);

	//  Set the UVs
	float v1 = (frame + 1) * .03125;
	float v2 = (frame + 2) * .03125;
	Vertex tempVertex = temp->m_Mesh->GetVertex(0);
	tempVertex.v = v1;
	temp->m_Mesh->SetVertex(0, tempVertex);

	tempVertex = temp->m_Mesh->GetVertex(1);
	tempVertex.v = v2;
	temp->m_Mesh->SetVertex(1, tempVertex);

	tempVertex = temp->m_Mesh->GetVertex(2);
	tempVertex.v = v1;
	temp->m_Mesh->SetVertex(2, tempVertex);

	tempVertex = temp->m_Mesh->GetVertex(3);
	tempVertex.v = v2;
	temp->m_Mesh->SetVertex(3, tempVertex);

	tempVertex = temp->m_Mesh->GetVertex(4);
	tempVertex.v = v1;
	temp->m_Mesh->SetVertex(4, tempVertex);

	tempVertex = temp->m_Mesh->GetVertex(5);
	tempVertex.v = v2;
	temp->m_Mesh->SetVertex(5, tempVertex);

	g_ObjectList[id] = temp;

	return id;
}


//////////////////////////////////////////////////////////////////////////////
//  CONSOLE
//////////////////////////////////////////////////////////////////////////////

std::vector<ConsoleString> g_ConsoleStrings;

void AddConsoleString(std::string string, Color color, unsigned int starttime)
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
	temp.m_StartTime = g_Engine->Time();

	g_ConsoleStrings.push_back(temp);
}

void DrawConsole()
{
	int counter = 0;
	vector<ConsoleString>::iterator node = g_ConsoleStrings.begin();
	for (node; node != g_ConsoleStrings.end(); ++node)
	{
		unsigned int elapsed = g_Engine->Time() - (*node).m_StartTime;
		if (elapsed > 9000)
		{
			float alpha = float(9999 - elapsed);
			if (alpha == 1.0f)
			{
				alpha = 0;
			}
			(*node).m_Color.a = alpha / 1000.0f;
		}
		g_SmallFont->DrawString((*node).m_String, 3, counter * (g_SmallFont->GetHeight() + 2) + 3, Color(0, 0, 0, (*node).m_Color.a));
		g_SmallFont->DrawString((*node).m_String, 0, counter * (g_SmallFont->GetHeight() + 2), (*node).m_Color);
		++counter;
	}

	node = g_ConsoleStrings.begin();
	for (node; node != g_ConsoleStrings.end();)
	{
		if (g_Engine->Time() - (*node).m_StartTime > 10000)
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

std::array<std::tuple<ObjectDrawTypes, ObjectTypes>, 1024 > g_ObjectTypes;