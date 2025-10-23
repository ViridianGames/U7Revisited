//  There are three types of objects in Ultima 7:
//  1. Statics, which are drawn in the world and do not move or interact with the player
//  2. Dynamic objects, which are drawn in the world and can move or interact with the player
//  3. NPCs, which are drawn in the world, can move and fight, and have a conversation tree
//
//  OOP would suggest that we should have a base class for all objects, and then subclass
//  each type of object.  However, I'm eschewing that complexity.  There's a lot of overlap
//  between dynamic objects and NPCs, so I'm just going to have a single class for all objects
//  and control things with flags.

#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Config.h"
#include "Geist/ScriptingSystem.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "ShapeData.h"
#include "LoadingState.h"
#include "MainState.h"
#include "Pathfinding.h"

#include <iostream>
#include <string>
#include <sstream>
#include <format>
#include <iomanip>
#include "raymath.h"
#include "rlgl.h"


using namespace std;

U7Object::~U7Object()
{
	Shutdown();
}

void U7Object::Init(const string& configfile, int unitType, int frame)
{
	m_Pos = Vector3{ 0, 0, 0 };
	m_Dest = Vector3{ 0, 0, 0 };
	m_Direction = Vector3{ 0, 0, 0 };
	m_Scaling = Vector3{ 1, 1, 1 };
	m_ExternalForce = Vector3{ 0, 0, 0 };
	m_GravityFlag = true;
	m_ExternalForceFlag = true;
	m_Angle = 0;
	m_Selected = false;
	m_Visible = true;
	m_Mesh = NULL;
	m_ObjectType = unitType;
	SetIsDead(false);
	m_UnitConfig = g_ResourceManager->GetConfig(configfile);
	m_Frame = frame;
	m_shapeData = &g_shapeTable[m_ObjectType][m_Frame];
	m_objectData = &g_objectDataTable[m_ObjectType];
	m_drawType = m_shapeData->GetDrawType();
	m_isContainer = false;
	m_isContained = false;
	m_isEgg = false;
	m_hasGump = false;
	m_inventory.clear();
	m_hasConversationTree = false;
	m_InventoryPos = Vector2{ 0, 0 };
	m_isNPC = false;
	m_isMoving = false;
	m_distanceFromCamera = 999999;
}

void U7Object::Draw()
{
	if (!m_Visible || m_isContained || m_isEgg || !m_ShouldDraw)
	{
		return;
	}

	if (m_isNPC)
	{
		NPCDraw();
	}
	else
	{
		int cellx = (TILEWIDTH / 2) + m_Pos.x - int(g_camera.target.x);
		int celly = (TILEHEIGHT / 2) + m_Pos.z - int(g_camera.target.z);

		if(cellx < 0 || cellx >= TILEWIDTH || celly < 0 || celly >= TILEHEIGHT)
		{
			return; // Not on the screen.
		}

		// if (m_objectData->m_isTranslucent)
		// {
		// 	Color color = g_Terrain->m_cellLighting[cellx][celly];
		// 	//color.a *= 0.5f;
		// 	m_shapeData->Draw(m_Pos, m_Angle, color);
		// }
		// else
		// {
			m_shapeData->Draw(m_Pos, m_Angle, g_Terrain->m_cellLighting[cellx][celly]);
		//}
	}

	if (g_Engine->m_debugDrawing)
	{
		DrawBoundingBox(m_boundingBox, MAGENTA);
	}

	if (g_Engine->m_debugDrawing)
	{
		DrawSphere(m_centerPoint, .15f, RED);
	}
}

void U7Object::CheckLighting()
{
	if (g_isDay)
	{
		m_isLit = true;
	}
	else
	{
		//  Run through list of nearby objects.  If any are light sources and are close enough, this object is lit.
		m_isLit = false;
		for (auto object : g_sortedVisibleObjects)
		{
			if (object->m_objectData->m_isLightSource)
			{
				//  If any point in the bounding box is near enough, the object is lit.
				if (Vector2DistanceSqr({object->m_Pos.x, object->m_Pos.z}, {m_Pos.x, m_Pos.z}) <= 64 ||
					Vector2DistanceSqr({object->m_Pos.x + object->m_boundingBox.max.x, object->m_Pos.z + object->m_boundingBox.max.z}, {m_Pos.x, m_Pos.z}) <= 64)
				{
					m_isLit = true;
				}
			}
		}
	}
}

void U7Object::Update()
{
	if (m_isNPC)
	{
		NPCUpdate();
	}
}

void U7Object::Attack(int _UnitID)
{

}

void U7Object::Shutdown()
{

}

void U7Object::NPCDraw()
{
	if (!m_Visible)
	{
		return;
	}

	// Check if this object has NPC data and properly initialized walk textures
	if (m_NPCData == nullptr || m_NPCData->m_walkTextures.size() < 4)
	{
		return;
	}

	// Verify all directional animation vectors are properly sized
	for (int i = 0; i < 4; i++)
	{
		if (m_NPCData->m_walkTextures[i].size() < 2)
		{
			return;
		}
	}

	if (m_NPCID == 0)
	{
		int stopper = 0; // Should be avatar;
	}


	//  Custom NPC drawing
	Vector3 finalPos = m_Pos;
	finalPos.x += .5f;
	finalPos.z += .5f;
	finalPos.y += m_shapeData->m_Dims.y * .62f;

	if (abs(finalPos.x - g_camera.target.x) > 64 || abs(finalPos.z - g_camera.target.z) > 64)
	{
		return; // Not on the screen.
	}

	Texture* finalTexture = m_NPCData->m_walkTextures[0][0];
	int finalAngle = 0;
	float billboardAngle = -45;

	Vector3 cameraAngle = Vector3Subtract(g_camera.position, g_camera.target);
	Vector3 cameraVector = Vector3{ cameraAngle.x, 0, cameraAngle.z };
	cameraVector = Vector3Normalize(cameraVector);
	float cameraAtan2 = atan2(cameraVector.x, cameraVector.z);

	float unitAngle;

	Vector3 unitVector;
	unitVector = m_Direction;
	float unitAtan2 = atan2(m_Direction.x, m_Direction.z);

	float angle = cameraAtan2 - unitAtan2;

	angle += ((1.0 / 16.0) * (2 * PI));

	while (angle < 0) { angle += (2 * PI); }
	while (angle > (2 * PI)) { angle -= (2 * PI); }

	int thisTime = GetTime() * 1000;

	int framerate = 200;

	Vector3 dims = { 1, 1, 1 };

	angle /= ((1.0 / 4.0) * (2 * PI));

	finalAngle = int(angle);
	framerate = 350;
	thisTime = (thisTime / framerate) % 2;

	if (!m_isMoving || g_mainState->m_paused) thisTime = 0;

	int frameIndex = 0;

		//  North frames are 1 and 2, South frames are 17 and 18
	switch(finalAngle)
	{
		case 0: // South-West
			finalTexture = m_NPCData->m_walkTextures[0][m_isMoving ? thisTime : 0];
			break;
		case 1: // North-West
			finalTexture = m_NPCData->m_walkTextures[3][m_isMoving ? thisTime : 0];
			billboardAngle = 45.0f;
			break;
		case 2: // North-East
			finalTexture = m_NPCData->m_walkTextures[2][m_isMoving ? thisTime : 0];
			break;
		case 3: // South-East
			finalTexture = m_NPCData->m_walkTextures[1][m_isMoving ? thisTime : 0];
			billboardAngle = 45.0f;
			break;
		default:
			int stopper = 0;
			break;
	}
	dims = Vector3{ float(finalTexture->width) / 8.0f, float(finalTexture->height) / 8.0f, 1 };

	Vector3 shadowPos = Vector3{ m_Pos.x - .5f, 0.02f, m_Pos.z + 1 };
	SetMaterialTexture(&g_ResourceManager->GetModel("Models/3dmodels/flat.obj")->GetModel().materials[0], MATERIAL_MAP_DIFFUSE, *g_ResourceManager->GetTexture("Images/dropshadow.png"));
	rlDisableDepthMask();
	DrawModel(g_ResourceManager->GetModel("Models/3dmodels/flat.obj")->GetModel(), shadowPos, 1.5f, BLACK);
	rlEnableDepthMask();

	BeginShaderMode(g_alphaDiscard);
	Color lighting = g_dayNightColor;
	if (m_isLit)
		lighting = WHITE;
	DrawBillboardPro(g_camera, *finalTexture, Rectangle{ 0, 0, float(finalTexture->width), float(finalTexture->height) }, finalPos, Vector3{ 0, 1, 0 },
		Vector2{ dims.x, dims.y }, Vector2{ 0, 0 }, billboardAngle, lighting);
	EndShaderMode();

}

void U7Object::NPCUpdate()
{
	// Don't do schedules while in the party
	if (g_Player->NPCIDInParty(m_NPCID) && m_NPCID != 0)
	{
		return;
	}

	// Schedule checking is now handled by MainState::Update() queue system
	// This function only handles waypoint following and movement

	// Follow waypoints from pathfinding
	if (!m_pathWaypoints.empty() && m_currentWaypointIndex < m_pathWaypoints.size())
	{
		// Check if reached current waypoint (within 2 tiles)
		float distToWaypoint = Vector3Distance(m_Pos, m_pathWaypoints[m_currentWaypointIndex]);
		if (distToWaypoint < 2.0f)
		{
			m_currentWaypointIndex++;
			if (m_currentWaypointIndex < m_pathWaypoints.size())
			{
				// Advance to next waypoint
				SetDest(m_pathWaypoints[m_currentWaypointIndex]);
			}
			else
			{
				// Reached final destination
				m_pathWaypoints.clear();
				m_currentWaypointIndex = 0;
				m_isMoving = false;
			}
		}
	}

	if (m_Pos.x != m_Dest.x || m_Pos.y != m_Dest.y  || m_Pos.z != m_Dest.z)
	{
		float deltav = (5.0f / g_secsPerMinute) * m_speed * GetFrameTime();
		Vector3 newPos = Vector3Add(m_Pos, Vector3Scale(m_Direction, deltav));

		//  If this update would take us beyond the destination, set the position to the destination
		if(Vector3DistanceSqr(newPos, m_Dest) > Vector3DistanceSqr(m_Pos, m_Dest))
		{
			SetPos(m_Pos);
			m_isMoving = false;
		}
		else
		{
			m_isMoving = true;
			SetPos(newPos);
		}
	}
	else  // Not moving, so randomly decide to move
	{
		//if (g_VitalRNG->RandomFloat(100.0f) < 5.0f)
		//{
		//	m_isMoving = true;
		//	Vector3 dest = Vector3{ g_VitalRNG->RandomFloat(10.0f) - 5.0f, 0, g_VitalRNG->RandomFloat(10.0f) - 5.0f };
		//	dest = Vector3Add(m_anchorPos, dest);
		//	SetDest(dest);
		//}
	}
}

void U7Object::SetInitialPos(Vector3 pos)
{
	m_Pos = pos;

	SetPos(pos);
	SetDest(pos);
}

void U7Object::SetPos(Vector3 pos)
{
	Vector3 fromPos = m_Pos;

	m_Pos = pos;

	Vector3 dims = Vector3{ 0, 0, 0 };
	Vector3 boundingBoxAnchorPoint = Vector3{ 0, 0, 0 };

	// Safety check for null shape data
	if (m_shapeData == nullptr)
	{
		m_boundingBox = { m_Pos, m_Pos };
		m_centerPoint = pos;
		return;
	}

	ObjectData* objectData = &g_objectDataTable[m_shapeData->GetShape()];

	if (m_drawType == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
	{
		dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
		boundingBoxAnchorPoint = Vector3Add(m_Pos, Vector3{ 0, 0, 0 });
	}
	else if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
	{
		// Safety check for null texture
		if (m_shapeData->m_texture == nullptr)
		{
			dims = Vector3{ 1.0f, 0, 1.0f }; // Default size
		}
		else
		{
			dims = Vector3{ float(m_shapeData->m_texture->width) / 8.0f, 0, float(m_shapeData->m_texture->height) / 8.0f };
		}
		boundingBoxAnchorPoint = Vector3Add(m_Pos, Vector3{ -dims.x + 1, 0, -dims.z + 1 });
	}
	else
	{
		dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
		boundingBoxAnchorPoint = Vector3Add(m_Pos, Vector3{ -dims.x + 1, 0, -dims.z + 1 });
	}

	m_boundingBox = { boundingBoxAnchorPoint, Vector3Add(boundingBoxAnchorPoint, dims) };

	m_centerPoint = Vector3Subtract(pos, {dims.x / 2, dims.y / 2, dims.z / 2});
	//m_centerPoint = Vector3Add(m_centerPoint, m_shapeData->m_TweakPos);
	m_terrainCenterPoint = m_centerPoint;
	m_terrainCenterPoint.y = m_Pos.y;

	UpdateObjectChunk(this, fromPos);

	// Notify pathfinding grid if this is a non-walkable STATIC object (not NPCs!)
	// NPCs don't block pathfinding grid, so no need to update when they move
	if (m_objectData && m_objectData->m_isNotWalkable && !m_isNPC)
	{
		// Update both old and new positions (object moved)
		NotifyPathfindingGridUpdate((int)fromPos.x, (int)fromPos.z);
		NotifyPathfindingGridUpdate((int)pos.x, (int)pos.z);
	}
}

void U7Object::SetFrame(int frame)
{
	// Store old frame to check if it actually changed
	int oldFrame = m_Frame;

	// Update frame and shapeData pointer
	m_Frame = frame;
	m_shapeData = &g_shapeTable[m_ObjectType][m_Frame];

	// Notify pathfinding grid if this is a door (frame change affects walkability)
	// Doors: frame 0 = closed (not walkable), frame > 0 = open (walkable)
	if (m_objectData && m_objectData->m_isDoor && oldFrame != frame)
	{
		NotifyPathfindingGridUpdate((int)m_Pos.x, (int)m_Pos.z);
	}
}

float U7Object::Pick()
{
	Ray ray = GetMouseRay(GetMousePosition(), g_camera);

	RayCollision collision = GetRayCollisionBox(ray, m_boundingBox);

	if (collision.hit)
	{
		return collision.distance;
	}
	else
	{
		return -1;
	}
}

float U7Object::PickXYZ(Vector3& pos)
{
	Ray ray = GetMouseRay(GetMousePosition(), g_camera);

	RayCollision collision = GetRayCollisionBox(ray, m_boundingBox);

	if (collision.hit)
	{
		pos = collision.point;
		return collision.distance;
	}
	else
	{
		return -1;
	}
}

void U7Object::SetDest(Vector3 dest)
{
	m_Dest = dest;
	m_Direction = Vector3Subtract(m_Dest, m_Pos);
	m_Direction = Vector3Normalize(m_Direction);
}

void U7Object::PathfindToDest(Vector3 dest)
{
	extern PathfindingGrid* g_pathfindingGrid;

	// Clear previous path
	m_pathWaypoints.clear();
	m_currentWaypointIndex = 0;

	// If no pathfinding grid, fall back to direct movement
	if (!g_pathfindingGrid)
	{
		SetDest(dest);
		return;
	}

	// Use A* to find path
	AStar astar;
	std::vector<Vector3> path = astar.FindPath(m_Pos, dest, g_pathfindingGrid);

	// If path found, store waypoints
	if (!path.empty())
	{
		m_pathWaypoints = path;
		m_currentWaypointIndex = 0;

		// Set first waypoint as destination
		if (m_pathWaypoints.size() > 0)
		{
			SetDest(m_pathWaypoints[0]);
		}

		// Debug output
		AddConsoleString("NPC " + std::to_string(m_NPCID) + " found path with " + std::to_string(path.size()) + " waypoints from (" +
		                 std::to_string((int)m_Pos.x) + "," + std::to_string((int)m_Pos.z) + ") to (" +
		                 std::to_string((int)dest.x) + "," + std::to_string((int)dest.z) + ")", GREEN);
	}
	else
	{
		// No path found, don't move at all
		AddConsoleString("WARNING: NPC " + std::to_string(m_NPCID) + " could not find path from (" +
		                 std::to_string((int)m_Pos.x) + "," + std::to_string((int)m_Pos.z) + ") to (" +
		                 std::to_string((int)dest.x) + "," + std::to_string((int)dest.z) + ") - staying put!", RED);
		// Don't call SetDest() - NPC will remain stationary
	}
}

bool U7Object::AddObjectToInventory(int objectid)
{
	if (m_isContainer)
	{
		m_inventory.push_back(objectid);
		return true;
	}

	return false;
}

bool U7Object::RemoveObjectFromInventory(int objectid)
{
	if (m_isContainer)
	{
		for (int i = 0; i < m_inventory.size(); i++)
		{
			if (m_inventory[i] == objectid)
			{
				GetObjectFromID(objectid)->m_isContained = true;
				m_inventory.erase(m_inventory.begin() + i);
				return true;
			}
		}
	}

	return false;
}

void U7Object::Interact(int event)
{
	if (m_hasConversationTree)
	{
		g_ConversationState->SetNPC(m_NPCID);

		string scriptName = "func_04";

		stringstream ss;
		ss << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << m_NPCID;

		scriptName += ss.str();

		g_ConversationState->SetLuaFunction(scriptName);

		DebugPrint("Calling Lua function: " + scriptName + " event: " + to_string(event) + " NPCID: " + to_string(m_NPCID));
		DebugPrint(g_ScriptingSystem->CallScript(scriptName, { event, m_NPCID }));
	}
	else
	{
		// If there's a script for this object type, call it
		if (m_shapeData->m_luaScript != "")
		{
			dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->SetLuaFunction(m_shapeData->m_luaScript);
			DebugPrint("Calling Lua function: " + m_shapeData->m_luaScript + " event: " + to_string(event) + " ID: " + to_string(m_ID));
			DebugPrint(g_ScriptingSystem->CallScript(m_shapeData->m_luaScript, { event, m_ID }));
		}
	}
}

bool U7Object::IsInInventoryById(int objectid)
{
	for (int i = 0; i < m_inventory.size(); i++)
	{
		if (m_inventory[i] == objectid)
		{
			return true;
		}
	}

	return false;
}

bool U7Object::IsInInventory(int shape, int frame, int quality)
{
	for (int i = 0; i < m_inventory.size(); i++)
	{
		U7Object* obj = GetObjectFromID(m_inventory[i]);
		if (obj != nullptr && obj->m_ObjectType == shape &&
			(frame == -1 || obj->m_Frame == frame) &&
			(quality == -1 || obj->m_Quality == quality || quality == -1))
		{
			return true;
		}
	}

	return false;
}

bool U7Object::IsLocked()
{
	if (m_shapeData->m_shape == 522)
	{
		return true;
	}

	return false;
}

void U7Object::NPCInit(NPCData* npcData)
{
	m_NPCData = npcData;
	m_isNPC = true;
	m_isContainer = true;
	m_isContained = false;
	m_speed = 2.5f;
	m_NPCID = npcData->id;
	m_anchorPos = m_Pos;

}


