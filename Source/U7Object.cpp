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
#include "Geist/SoundSystem.h"
#include "Geist/Logging.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "ShapeData.h"
#include "LoadingState.h"
#include "MainState.h"
#include "PathfindingSystem.h"

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>
#include "raymath.h"
#include "rlgl.h"
#include <atomic>


using namespace std;

// Contiguous per-NPC batch index allocator.
// This is file-scoped so it's preserved while the program runs and used by NPCInit / LoadFromJson.
static std::atomic_int s_nextNpcBatchIndex{0};

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

	if (!g_isObjectMoveable[unitType])
	{
		m_UnitType = U7Object::UnitTypes::UNIT_TYPE_STATIC;
	}
	else
	{
		m_UnitType = U7Object::UnitTypes::UNIT_TYPE_OBJECT;
	}
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

		Color renderColor = g_Terrain->m_cellLighting[cellx][celly];

		// Apply green tint if F11 script debug is enabled and object has a non-default script
		// Also check for conversation trees (NPCs with dialogue scripts)
		if (g_showScriptedObjects &&
		    ((m_shapeData->m_luaScript != "" && m_shapeData->m_luaScript != "default") || m_hasConversationTree))
		{
			// Blend with green to highlight scripted objects
			renderColor.r = (renderColor.r + 0) / 2;
			renderColor.g = (renderColor.g + 255) / 2;
			renderColor.b = (renderColor.b + 0) / 2;
		}
		// Apply blue tint if F11 debug is enabled and object is walkable (isNotWalkable = false)
		else if (g_showScriptedObjects && m_objectData && !m_objectData->m_isNotWalkable)
		{
			// Blend with blue to highlight walkable objects
			renderColor.r = (renderColor.r + 0) / 2;
			renderColor.g = (renderColor.g + 0) / 2;
			renderColor.b = (renderColor.b + 255) / 2;
		}

		m_shapeData->Draw(m_Pos, m_Angle, renderColor);
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

	if (m_isEgg || m_UnitType == U7Object::UnitTypes::UNIT_TYPE_EGG)
	{
		EggUpdate();
	}
}

void U7Object::EggUpdate()
{
	switch (m_eggData.type)
	{
		case EggType::MonsterSpawner:
			HandleMonsterSpawnerEgg();
			break; // Not implemented yet

		case EggType::Jukebox:
			HandleJukeboxEgg();
			break; // Not implemented yet

		case EggType::ProximitySound:
			HandleProximitySoundEgg();
			break; // Not implemented yet

		case EggType::Voice:
			HandleVoiceEgg();
			break;

		case EggType::Weather:
			HandleWeatherEgg();
			break;

		case EggType::Teleporter:
			HandleTeleporterEgg();
			break;

		case EggType::Path:
			HandlePathEgg();
			break;

		case EggType::Usecode:
			HandleUsecodeEgg();
			break;
	}
}

void U7Object::HandleMonsterSpawnerEgg()
{

}

void U7Object::HandleProximitySoundEgg()
{

}

void U7Object::HandleJukeboxEgg()
{

}

void U7Object::HandleVoiceEgg()
{
	bool playing = false;
	switch (m_eggData.criteria)
	{
		case EggCriteria::AvatarNear:
		case EggCriteria::PartyNear:
			if (!m_eggData.hasTriggered && Vector2Distance({m_Pos.x, m_Pos.z}, {g_Player->GetAvatarObject()->m_Pos.x, g_Player->GetAvatarObject()->m_Pos.z}) <= m_eggData.distance)
			{
				playing = true;
				m_eggData.hasTriggered = true;
			}
			break;
	}

	if (playing)
	{
		g_SoundSystem->PlaySound(m_eggData.audioFile);
	}
}

void U7Object::HandleWeatherEgg()
{

}

void U7Object::HandleTeleporterEgg()
{

}

void U7Object::HandlePathEgg()
{

}

void U7Object::HandleUsecodeEgg()
{
	U7Object* _avatar = g_Player->GetAvatarObject();

	if (m_eggData.hasTriggered && !m_eggData.autoReset)
	{
		return;
	}

	switch (m_eggData.criteria)
	{
		case EggCriteria::AvatarFootpad:
		{
			if (Vector3Equals(m_Pos, _avatar->m_Pos))
			{
				m_eggData.hasTriggered = true;
			}

		}

		case EggCriteria::AvatarNear:
		case EggCriteria::PartyNear:
			if (Vector2Distance({m_Pos.x, m_Pos.z}, {_avatar->m_Pos.x, _avatar->m_Pos.z}) <= m_eggData.distance)
			{
				m_eggData.hasTriggered = true;
			}
			break;
	}

	if (m_eggData.hasTriggered)
	{
		int stopper = 0;
		//  Get the script for this egg.
		int scriptnumber = m_eggData.usecodeFunc - 1280;
		string scriptname = "utility_unknown_0"+(std::to_string(scriptnumber));

		//  Run it.
		g_ScriptingSystem->CallScript(scriptname, {});
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
		//return;
	}

	// Check if this object has NPC data and properly initialized walk textures
	if (m_NPCData == nullptr)
	{
		return;
	}

	if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT )
	{

		return; // Xorinia the wisp is the only flat type, we'll handle her later.
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

	if (m_name == "Gret" || m_name == "Poutchouli" || m_name == "Mister Fisp")
		billboardAngle = -75;

	Vector3 cameraAngle = Vector3Subtract(g_camera.position, g_camera.target);
	Vector3 cameraVector = Vector3{ cameraAngle.x, 0, cameraAngle.z };
	cameraVector = Vector3Normalize(cameraVector);
	float cameraAtan2 = atan2(cameraVector.x, cameraVector.z);

	//float unitAngle;

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

	float straightenAngle = 75.0f;

	// If not moving, use the current frame set via npc_frame()
	if (!m_isMoving)
	{
		if (m_isFrameOverridden)
		{
			// Use the frame that was explicitly set (sleeping, sitting, etc.)
			if (g_shapeTable[m_ObjectType][m_overrideFrame].m_texture != nullptr)
			{
				finalTexture = &g_shapeTable[m_ObjectType][m_overrideFrame].m_texture->m_Texture;
				billboardAngle = m_overrideFrame % 2 ? straightenAngle : 0.0f;
			}
		}
		else
		{
			switch(finalAngle)
			{
				case 0: // South-West
					finalTexture = m_NPCData->m_walkTextures[0][0];
					break;
				case 1: // North-West
					finalTexture = m_NPCData->m_walkTextures[3][0];
					billboardAngle = straightenAngle;
					break;
				case 2: // North-East
					finalTexture = m_NPCData->m_walkTextures[2][0];
					break;
				case 3: // South-East
					finalTexture = m_NPCData->m_walkTextures[1][0];
					billboardAngle = straightenAngle;
					break;
				default:
					int stopper = 0;
					break;
			}
		}
	}
	else
	{
		// Normal walking animation (or standing if frame 0)
		switch(finalAngle)
		{
			case 0: // South-West
				finalTexture = m_NPCData->m_walkTextures[0][m_isMoving ? thisTime : 0];
				break;
			case 1: // North-West
				finalTexture = m_NPCData->m_walkTextures[3][m_isMoving ? thisTime : 0];
				billboardAngle = straightenAngle;
				break;
			case 2: // North-East
				finalTexture = m_NPCData->m_walkTextures[2][m_isMoving ? thisTime : 0];
				break;
			case 3: // South-East
				finalTexture = m_NPCData->m_walkTextures[1][m_isMoving ? thisTime : 0];
				billboardAngle = straightenAngle;
				break;
			default:
				int stopper = 0;
				break;
		}
	}
	dims = Vector3{ float(finalTexture->width) / 8.0f, float(finalTexture->height) / 8.0f, 1 };

	Vector3 shadowPos = Vector3{ m_Pos.x - .5f, 0.02f, m_Pos.z + 1 };
	SetMaterialTexture(&g_ResourceManager->GetModel("Models/3dmodels/flat.obj")->GetModel().materials[0], MATERIAL_MAP_DIFFUSE, *g_ResourceManager->GetTexture("Images/dropshadow.png"));
	rlDisableDepthMask();
	DrawModel(g_ResourceManager->GetModel("Models/3dmodels/flat.obj")->GetModel(), shadowPos, 1.5f, BLACK);
	rlEnableDepthMask();

	BeginShaderMode(g_alphaDiscard);

	Vector3 offset = Vector3Subtract(m_Pos, g_camera.target);
	offset = Vector3Add(offset, Vector3{ 50, 0, 50 });

	if (offset.x < 0 || offset.z < 0 || offset.x > 100 || offset.z > 100)
	{
		return; // This NPC is off the screen
	}

	Color lighting = g_Terrain->m_cellLighting[int(offset.x)][int(offset.z)];



	//if (m_isLit)
		//lighting = WHITE;

	// Apply green tint if F11 script debug is enabled and NPC has a non-default script
	// Also check for conversation trees (NPCs with dialogue scripts)
	if (g_showScriptedObjects &&
	    ((m_shapeData->m_luaScript != "" && m_shapeData->m_luaScript != "default") || m_hasConversationTree))
	{
		// Blend with green to highlight scripted NPCs
		lighting.r = (lighting.r + 0) / 2;
		lighting.g = (lighting.g + 255) / 2;
		lighting.b = (lighting.b + 0) / 2;
	}
	// Apply blue tint if F11 debug is enabled and object is walkable (isNotWalkable = false)
	else if (g_showScriptedObjects && m_objectData && !m_objectData->m_isNotWalkable)
	{
		// Blend with blue to highlight walkable objects
		lighting.r = (lighting.r + 0) / 2;
		lighting.g = (lighting.g + 0) / 2;
		lighting.b = (lighting.b + 255) / 2;
	}

	DrawBillboardPro(g_camera, *finalTexture, Rectangle{ 0, 0, float(finalTexture->width), float(finalTexture->height) }, finalPos, Vector3{ 0, 1, 0 },
		Vector2{ dims.x, dims.y }, Vector2{ 0, 0 }, billboardAngle, lighting);
	EndShaderMode();

}

// Helper function to convert activity ID to script name
static std::string GetActivityScriptName(int activityId)
{
	// Map activity IDs to descriptive script names
	static const char* ACTIVITY_SCRIPT_NAMES[] = {
		"combat",          // 0
		"pace_horz",       // 1  (horizontal pace)
		"pace_vert",       // 2  (vertical pace)
		"talk",            // 3
		"dance",           // 4
		"eat",             // 5
		"farm",            // 6
		"tend_shop",       // 7
		"miner",           // 8
		"hound",           // 9
		"stand",           // 10
		"loiter",          // 11
		"wander",          // 12
		"blacksmith",      // 13
		"sleep",           // 14
		"wait",            // 15
		"sit",             // 16  (major sit)
		"graze",           // 17
		"bake",            // 18
		"sew",             // 19
		"shy",             // 20
		"lab",             // 21
		"thief",           // 22
		"waiter",          // 23
		"special",         // 24
		"kid_games",       // 25
		"eat_at_inn",      // 26
		"duel",            // 27
		"preach",          // 28
		"patrol",          // 29
		"desk_work",       // 30
		"follow_avatar"    // 31
	};

	if (activityId >= 0 && activityId <= 31)
	{
		return std::string("activity_") + ACTIVITY_SCRIPT_NAMES[activityId];
	}

	// Fallback for invalid activity IDs
	return "activity_" + std::to_string(activityId);
}

void U7Object::NPCUpdate()
{
	// Don't do schedules while in the party
	// (Note: previously we returned early here which also prevented movement for party members,
	// causing them to animate but never change position.  Instead mark the in-party state
	// and skip only the activity/coroutine handling below.)
	bool isInParty = (g_Player->NPCIDInParty(m_NPCID) && m_NPCID != 0);

	// Increase batch size so fewer NPCs are checked per frame for starting/resuming activity scripts.
	// This reduces the number of script starts/resumes per frame for background NPCs.
	int batchSize = 48; // tune between 32..128 depending on performance vs responsiveness

	// totalAssigned is the number of NPC batch indices assigned so far (compact)
	int totalAssigned = s_nextNpcBatchIndex.load();
	if (totalAssigned <= 0) totalAssigned = 1;
	int numBatches = (totalAssigned + batchSize - 1) / batchSize;
	if (numBatches <= 0) numBatches = 1;

	// Use the global update counter so batch rotation is tied to the main update loop
	// (this mirrors the previous behavior before the per-call s_frameCounter change)
	int batchIndex = static_cast<int>(g_CurrentUpdate % numBatches);

	// Ensure this NPC has a batch index; if not, assign one lazily.
	if (m_npcBatchIndex < 0)
	{
		m_npcBatchIndex = s_nextNpcBatchIndex.fetch_add(1);
		// update totalAssigned/numBatches for this frame's decision if needed (safe skip, will run next cycle)
		totalAssigned = s_nextNpcBatchIndex.load();
		numBatches = (totalAssigned + batchSize - 1) / batchSize;
		if (numBatches <= 0) numBatches = 1;
		// recompute batchIndex in case numBatches changed (keep consistency for this frame)
		batchIndex = static_cast<int>(g_CurrentUpdate % numBatches);
	}

	bool shouldUpdateActivity = ((m_npcBatchIndex % numBatches) == batchIndex);

	// Optional targeted debug: only emit verbose per-NPC diagnostics when g_LuaDebug is enabled.
	//if (m_NPCID == 75 && g_LuaDebug)
	//{
	//	std::stringstream ss;
	//	ss << "NPCUpdate Debug id=" << m_NPCID
	//	   << " batchIndexAssigned=" << m_npcBatchIndex
	//	   << " totalAssigned=" << totalAssigned
	//	   << " numBatches=" << numBatches
	//	   << " frameBatchIndex=" << batchIndex
	//	   << " shouldUpdateActivity=" << (shouldUpdateActivity ? 1 : 0)
	//	   << " followingSchedule=" << (m_followingSchedule ? 1 : 0)
	//	   << " pathfindingPending=" << (m_pathfindingPending ? 1 : 0)
	//	   << " isSchedulePath=" << (m_isSchedulePath ? 1 : 0)
	//	   << " isMoving=" << (m_isMoving ? 1 : 0)
	//	   << " currentDest=(" << m_Dest.x << "," << m_Dest.y << "," << m_Dest.z << ")";
	//	NPCDebugPrint(ss.str());
	//}

	// Activity coroutine management - check if activity has changed
	// Only run activity scripts if schedules are enabled for this NPC
	// IMPORTANT: skip activity/coroutines for party members, but continue with movement below
	if (shouldUpdateActivity && m_followingSchedule && g_NPCData.find(m_NPCID) != g_NPCData.end() && !isInParty)
	{
		int currentActivity = g_NPCData[m_NPCID]->m_currentActivity;
		int lastActivity = g_NPCData[m_NPCID]->m_lastActivity;

		// Debug: log activity values for the NPC being checked (only when verbose debug enabled)
		if (m_NPCID == 75 && g_LuaDebug)
		{
			std::stringstream ss;
			ss << "NPCActivity Debug id=" << m_NPCID
			   << " currentActivity=" << currentActivity
			   << " lastActivity=" << lastActivity;
			NPCDebugPrint(ss.str());
		}

		// Has activity changed?
		if (currentActivity != lastActivity)
		{
			// Cleanup old coroutine if it exists
			if (lastActivity >= 0)
			{
				std::string old_script = GetActivityScriptName(lastActivity) + "_" + std::to_string(m_NPCID);
				if (g_ScriptingSystem->IsCoroutineActive(old_script))
				{
					g_ScriptingSystem->CleanupCoroutine(old_script);
				}
			}
			
			// Only start activity script if not following a schedule path
			// Block if: pathfinding pending OR currently on schedule path (orange)
			if (!m_pathfindingPending && !m_isSchedulePath)
			{
				// Start new activity script
				std::string new_script = GetActivityScriptName(currentActivity) + "_" + std::to_string(m_NPCID);
				std::vector<ScriptingSystem::LuaArg> args = { m_NPCID };

				// Log attempt only when verbose debug is enabled
				if (g_LuaDebug)
					NPCDebugPrint("Attempting to start activity script: " + new_script);

				// Try to start this frame (throttle)
				if (g_ScriptingSystem->TryConsumeScriptStart())
				{
				    std::string callResult = g_ScriptingSystem->CallScript(new_script, args);

				    if (!callResult.empty())
				    {
				        if (g_LuaDebug)
				            NPCDebugPrint("CallScript error for " + new_script + ": " + callResult);
				    }
				    else
				    {
				        if (g_LuaDebug)
				            NPCDebugPrint("Started activity coroutine: " + new_script);
				        g_NPCData[m_NPCID]->m_lastActivity = currentActivity;
				    }
				}
				else
				{
				    // Throttled - try again next frame
				    if (m_NPCID == 75 && g_LuaDebug) NPCDebugPrint("Throttled start for " + new_script + " (deferred)");
				}
			}
			else
			{
				// Debug: activity start blocked by movement/pathfinding flags (only when verbose)
				if (m_NPCID == 75 && g_LuaDebug)
				{
					std::stringstream ss;
					ss << "NPCActivity Blocked id=" << m_NPCID
					   << " pathfindingPending=" << (m_pathfindingPending ? 1 : 0)
					   << " isSchedulePath=" << (m_isSchedulePath ? 1 : 0);
					NPCDebugPrint(ss.str());
				}
			}
		}
		
		// Activity hasn't changed - resume if not on schedule path
		else if (currentActivity >= 0 && !m_pathfindingPending && !m_isSchedulePath)
		{
			std::string script_name = GetActivityScriptName(currentActivity) + "_" + std::to_string(m_NPCID);
			bool yielded = g_ScriptingSystem->IsCoroutineYielded(script_name);

			// --- when resuming a yielded activity coroutine ---
			if (yielded)
			{
			    if (g_ScriptingSystem->TryConsumeScriptResume())
			    {
			        std::vector<ScriptingSystem::LuaArg> args = { m_NPCID };
			        g_ScriptingSystem->ResumeCoroutine(script_name, args);

			        if (m_NPCID == 75 && g_LuaDebug)
			        {
			            NPCDebugPrint("NPCResume Debug: called ResumeCoroutine for " + script_name);
			        }
			    }
			    else
			    {
			        if (m_NPCID == 75 && g_LuaDebug) NPCDebugPrint("Throttled resume for " + script_name + " (deferred)");
			    }
			}
		}
	}
	// If schedules are disabled, cleanup any running activity scripts
	else if (!m_followingSchedule && g_NPCData.find(m_NPCID) != g_NPCData.end())
	{
		int lastActivity = g_NPCData[m_NPCID]->m_lastActivity;
		if (lastActivity >= 0)
		{
			std::string old_script = GetActivityScriptName(lastActivity) + "_" + std::to_string(m_NPCID);
			if (g_ScriptingSystem->IsCoroutineActive(old_script))
			{
				g_ScriptingSystem->CleanupCoroutine(old_script);
			}
			g_NPCData[m_NPCID]->m_lastActivity = -1;

			if (m_NPCID == 75 && g_LuaDebug)
			{
				NPCDebugPrint("NPCActivity Cleanup: cleared lastActivity for id=75");
			}
		}
	}

	// Schedule checking is now handled by MainState::Update() queue system
	// This function only handles waypoint following and movement

	// Follow waypoints from pathfinding (only when actively moving)
	if (m_isMoving && !m_pathfindingPending && !m_pathWaypoints.empty() && m_currentWaypointIndex < m_pathWaypoints.size())
	{
		float distToWaypoint = Vector3Distance(m_Pos, m_pathWaypoints[m_currentWaypointIndex]);
		bool isLastWaypoint = (m_currentWaypointIndex == m_pathWaypoints.size() - 1);
		float threshold = isLastWaypoint ? 0.1f : 0.5f;

		if (distToWaypoint < threshold)
		{
			if (isLastWaypoint)
			{
				m_pathWaypoints.clear();
				m_currentWaypointIndex = 0;
				m_isMoving = false;
				m_isSchedulePath = false;
				SetDest(m_Pos);
			}
			else
			{
				// Advance to next waypoint
				m_currentWaypointIndex++;
				SetDest(m_pathWaypoints[m_currentWaypointIndex]);
			}
		}
	}

	if (m_Pos.x != m_Dest.x || m_Pos.y != m_Dest.y  || m_Pos.z != m_Dest.z)
	{
		if (m_NPCID == 0)
		{
			int stopper = 0;
			stopper++;
		}

		float deltav = m_speed * GetFrameTime();

		// Detect "walking in place" and always log it for debugging.
		// Previously this was gated by g_LuaDebug, so you saw nothing when that flag was false.

		if (m_isMoving &&
			fabs(m_Direction.x) < 0.001f && fabs(m_Direction.z) < 0.001f)
		{
			std::stringstream ss;
			ss << "NPC walking-in-place detected id=" << m_NPCID
			   << " pos=(" << m_Pos.x << "," << m_Pos.y << "," << m_Pos.z << ")"
			   << " dest=(" << m_Dest.x << "," << m_Dest.y << "," << m_Dest.z << ")"
			   << " dir=(" << m_Direction.x << "," << m_Direction.y << "," << m_Direction.z << ")"
			   << " deltav=" << deltav
			   << " speed=" << m_speed
			   << " waypointCount=" << m_pathWaypoints.size()
			   << " waypointIndex=" << m_currentWaypointIndex;
			NPCDebugPrint(ss.str());

			// Dump the current waypoint list (helps verify whether waypoints actually advance in X/Z)
			for (size_t i = 0; i < m_pathWaypoints.size(); ++i)
			{
				const Vector3& wp = m_pathWaypoints[i];
				std::stringstream s2;
				s2 << "  wp[" << i << "] = (" << wp.x << ", " << wp.y << ", " << wp.z << ")";
				NPCDebugPrint(s2.str());
			}
		}

		Vector3 newPos = Vector3Add(m_Pos, Vector3Scale(m_Direction, deltav));

		if (Vector3DistanceSqr(newPos, m_Dest) > Vector3DistanceSqr(m_Pos, m_Dest))
		{
			SetPos(m_Dest);
			if (m_pathWaypoints.empty())
			{
				m_isMoving = false;
			}
		}
		else
		{
			m_isMoving = true;
			SetPos(newPos);

			// Check for doors after moving to new position
			TryOpenDoorAtCurrentPosition();
		}
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

	if (m_Dest.x == m_Pos.x && m_Dest.z == m_Pos.z)
		return;

	Vector3 newDirection = Vector3Subtract(m_Dest, m_Pos);
	newDirection = Vector3Normalize(newDirection);
	if (newDirection.x != 0 || newDirection.z != 0)
	{
		m_Direction = newDirection;
	}
}

void U7Object::TryOpenDoorAtCurrentPosition()
{
	int worldX = (int)m_Pos.x;
	int worldZ = (int)m_Pos.z;

	// Cache to avoid checking the same position multiple times per tile
	static std::unordered_map<int, std::pair<int, int>> lastCheckedPos;  // npcID -> (x, z)

	auto it = lastCheckedPos.find(m_NPCID);
	if (it != lastCheckedPos.end() && it->second.first == worldX && it->second.second == worldZ)
	{
		return;  // Already checked this position recently
	}
	lastCheckedPos[m_NPCID] = {worldX, worldZ};

	// Use the pathfinding grid's helper to get overlapping objects at current position
	auto overlappingObjects = g_pathfindingSystem->m_pathfindingGrid->GetOverlappingObjects(worldX, worldZ);

	// Check if any of the overlapping objects is a door
	for (const auto& ovObj : overlappingObjects)
	{
		U7Object* obj = ovObj.obj;

		if (!obj->m_objectData->m_isDoor)
			continue;

		// If we're standing on any door tile, interact with it to open
		obj->Interact(1);  // Event 1 = double-click interaction
		return;
	}
}

void U7Object::PathfindToDest(Vector3 dest)
{
	if (m_NPCID == 19)
	{
		int stopper = 0;
	}

	// Clear previous path and mark as pending
	m_pathWaypoints.clear();
	m_currentWaypointIndex = 0;
	m_pathfindingPending = true;

	m_pathWaypoints = g_pathfindingSystem->FindPath(m_Pos, dest);

	// If path found, store waypoints
	if (!m_pathWaypoints.empty())
	{
		// Pathfinding completed synchronously
		m_pathfindingPending = false;

		// Debug: Print the returned waypoints for inspection
		// This will show whether the A* path includes non-zero Y values for stairs/upper floors.
//#ifdef DEBUG_NPC_PATHFINDING
//		{
//			std::stringstream ss;
//			ss << "PathfindToDest: found " << m_pathWaypoints.size() << " waypoints (dest requested: "
//				<< dest.x << "," << dest.y << "," << dest.z << ")";
//			NPCDebugPrint(ss.str());
//
//			for (size_t i = 0; i < m_pathWaypoints.size(); ++i)
//			{
//				const Vector3& wp = m_pathWaypoints[i];
//				std::stringstream s2;
//				s2 << "  wp[" << i << "] = (" << wp.x << ", " << wp.y << ", " << wp.z << ")";
//				NPCDebugPrint(s2.str());
//			}
//		}
//#endif
		// Determine the correct initial waypoint index.
		// FindPath may return a single-point path (size == 1) — previously code used m_pathWaypoints[1] unguarded
		// which caused "vector subscript out of range" when size == 1.
		if (m_pathWaypoints.size() > 1)
		{
			// common case: first entry is current tile, second is the first step
			m_currentWaypointIndex = 1;
		}
		else
		{
			// single-point path: use index 0
			m_currentWaypointIndex = 0;
		}

		// Skip initial waypoints that do not change X/Z (these cause SetDest to not set a direction,
		// which results in "walking in place" because m_Direction remains zero but m_isMoving becomes true)
		int skipped = 0;
		while (m_currentWaypointIndex < static_cast<int>(m_pathWaypoints.size()) &&
			   (int)m_pathWaypoints[m_currentWaypointIndex].x == (int)m_Pos.x &&
			   (int)m_pathWaypoints[m_currentWaypointIndex].z == (int)m_Pos.z)
		{
			m_currentWaypointIndex++;
			skipped++;
		}

		// ALWAYS emit this debug info while debugging the walking-in-place issue so you see what's happening.
		// (Previously this was gated on g_LuaDebug; that prevented logs when the flag was false.)
		if (skipped > 0)
		{
			std::stringstream ss;
			ss << "PathfindToDest: skipped " << skipped << " initial waypoint(s) equal to current XZ for NPC " << m_NPCID
			   << "  new waypointIndex=" << m_currentWaypointIndex;
			NPCDebugPrint(ss.str());

			// Dump the waypoint list so you can inspect X/Y/Z values returned by the pathfinder
			for (size_t i = 0; i < m_pathWaypoints.size(); ++i)
			{
				const Vector3& wp = m_pathWaypoints[i];
				std::stringstream s2;
				s2 << "  wp[" << i << "] = (" << wp.x << ", " << wp.y << ", " << wp.z << ")";
				NPCDebugPrint(s2.str());
			}
		}

		// If we've advanced past the end, no effective movement needed
		if (m_currentWaypointIndex >= static_cast<int>(m_pathWaypoints.size()))
		{
			// Nothing to do (destination is current tile)
			m_pathWaypoints.clear();
			m_currentWaypointIndex = 0;
			m_isMoving = false;
			m_isSchedulePath = false;
		}
		else
		{
			// Set the initial destination only if the index is valid
			SetDest(m_pathWaypoints[m_currentWaypointIndex]);

			// Make sure NPC starts moving toward the destination right away.
			m_isMoving = true;
		}
	}
	else
	{
		m_pathfindingPending = false;  // No path found, done trying
		// No path found, don't move at all
	}
}

bool U7Object::AddObjectToInventory(int objectid)
{
	if (m_isContainer)
	{
		m_inventory.push_back(objectid);

		// Set the child's containing object ID to point back to this container
		U7Object* child = g_objectList[objectid].get();
		if (child)
		{
			child->m_containingObjectId = m_ID;
			child->m_isContained = true;  // Mark as contained
			child->SetPos(Vector3{0, 0, 0});  // Clear world position
		}

		InvalidateWeightCache();
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
				U7Object* child = GetObjectFromID(objectid);
				if (child)
				{
					// Don't change m_isContained here - let the code that places the object set it
					// (e.g., equip sets true, drop to ground sets false, add to container sets true)
					child->m_containingObjectId = -1; // Clear parent reference
				}
				m_inventory.erase(m_inventory.begin() + i);
				InvalidateWeightCache();
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

		// Find NPC script using new naming: npc_*_XXXX where XXXX = NPC ID in decimal (4 digits)
		// NPC IDs start at 0 and increment, independent of shape ID
		string scriptName = FindNPCScriptByID(m_NPCID);

		if (scriptName.empty())
		{
			NPCDebugPrint("No script found for NPC ID: " + to_string(m_NPCID));
			return;
		}

		NPCDebugPrint("Calling Lua function: " + scriptName + " event: " + to_string(event) + " NPCID: " + to_string(m_NPCID));
		std::string response = g_ScriptingSystem->CallScript(scriptName, { event, m_NPCID });
		NPCDebugPrint(response);
	}
	else
	{
		// If there's a script for this object type, call it
		if (m_shapeData->m_luaScript != "")
		{
			//dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE))->SetLuaFunction(m_shapeData->m_luaScript);
			NPCDebugPrint("Calling Lua function: " + m_shapeData->m_luaScript + " event: " + to_string(event) + " ID: " + to_string(m_ID) + " (Shape: " + to_string(m_ObjectType) + ", Frame: " + to_string(m_Frame) + ")");
			NPCDebugPrint(g_ScriptingSystem->CallScript(m_shapeData->m_luaScript, { event, m_ID }));
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

float U7Object::GetWeight()
{
	if (m_totalWeight > 0.0f)
		return m_totalWeight;

	float baseWeight = g_objectDataTable[m_shapeData->m_shape].m_weight;
	float inventoryWeight = 0.0f;

	for (int childId : m_inventory)
	{
		U7Object* child = g_objectList[childId].get();
		if (child != nullptr)
		{
			inventoryWeight += child->GetWeight();
		}
	}

	m_totalWeight = baseWeight + inventoryWeight;
	return m_totalWeight;
}

void U7Object::InvalidateWeightCache()
{
	m_totalWeight = 0.0f;

	if (m_containingObjectId != -1)
	{
		U7Object* parent = g_objectList[m_containingObjectId].get();
		if (parent != nullptr)
		{
			parent->InvalidateWeightCache();
		}
	}
}

float U7Object::GetRemainingCarryCapacity()
{
	// Only NPCs have carry capacity
	if (!m_isNPC || m_NPCData == nullptr)
		return 0.0f;

	float maxWeight = GetMaxWeightFromStrength(m_NPCData->str);
	float currentWeight = GetWeight();

	return maxWeight - currentWeight;
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
	m_UnitType = UnitTypes::UNIT_TYPE_NPC;
	m_isContainer = true;
	m_isContained = false;
	m_name = npcData->name;
	if (std::string(m_NPCData->name) == "Avatar")
	{
		m_speed = 20.0f;
	}
	else
	{
		m_speed = 10.0f;
	}
	m_NPCID = npcData->id;
	m_anchorPos = m_Pos;

	// Assign contiguous batch index if not already set (preserve any value restored from save)
	if (m_npcBatchIndex < 0)
	{
		// post-increment gives each NPC a unique contiguous index
		m_npcBatchIndex = s_nextNpcBatchIndex.fetch_add(1);
	}
	else
	{
		// Ensure allocator is ahead of any loaded index (LoadFromJson may have set m_npcBatchIndex)
		int desired = m_npcBatchIndex + 1;
		int cur = s_nextNpcBatchIndex.load();
		while (cur < desired && !s_nextNpcBatchIndex.compare_exchange_weak(cur, desired))
		{
			// loop until swapped or cur updated
		}
	}
}

// ============================================================================
// Serialization
// ============================================================================

json U7Object::SaveToJson() const
{
	// note: this will never be called for STATIC objects
	json j;

	// Core identity
	j["id"] = m_ID;

	// Only save unitType if not UNIT_TYPE_OBJECT (the default)
	if (m_UnitType != UnitTypes::UNIT_TYPE_OBJECT)
		j["unitType"] = static_cast<int>(m_UnitType);

	j["shape"] = m_ObjectType;

	// Only save non-default values
	if (m_Frame != 0)
		j["frame"] = m_Frame;
	if (m_Quality != 0)
		j["quality"] = m_Quality;

	// Transform (only save position if not contained)
	if (!m_isContained)
	{
		j["position"] = { m_Pos.x, m_Pos.y, m_Pos.z };
	}

	// State (only save if non-zero)
	if (m_flags != 0)
		j["flags"] = m_flags;

	// Container hierarchy
	if (m_isContained)
	{
		j["containingObjectId"] = m_containingObjectId;
		j["containerPos"] = { m_InventoryPos.x, m_InventoryPos.y };
	}

	// Only save inventory if it has items
	if (!m_inventory.empty())
		j["inventoryIds"] = m_inventory;

	// Save container state
	if (m_isContainer)
	{
		j["isContainer"] = true;
		if (!m_shouldBeSorted)
			j["shouldBeSorted"] = m_shouldBeSorted;
	}

	// NPC-specific fields
	if (m_UnitType == UnitTypes::UNIT_TYPE_NPC && m_NPCData != nullptr)
	{
		j["hp"] = m_hp;
		j["combat"] = m_combat;
		j["magic"] = m_magic;
		j["team"] = m_Team;
		j["npcID"] = m_NPCID;
		j["currentFrameX"] = m_currentFrameX;
		j["currentFrameY"] = m_currentFrameY;

		// Save conversation tree flag if true
		if (m_hasConversationTree)
			j["hasConversationTree"] = m_hasConversationTree;

		// Save movement state if true (default is false)
		if (m_isMoving)
			j["isMoving"] = m_isMoving;

		// Save schedule state
		if (m_followingSchedule)
			j["followingSchedule"] = m_followingSchedule;
		if (m_lastSchedule != -1)
			j["lastSchedule"] = m_lastSchedule;

		// Don't save destination - we want NPCs to stay at their saved position
		// The schedule system will set new destinations as needed after load

		// Persist batch index so distribution is stable across loads
		if (m_npcBatchIndex >= 0)
		 j["npcBatchIndex"] = m_npcBatchIndex;
		// Equipment slots
		json equipment;
		equipment["HEAD"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_HEAD);
		equipment["NECK"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_NECK);
		equipment["TORSO"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_TORSO);
		equipment["LEGS"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_LEGS);
		equipment["HANDS"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_HANDS);
		equipment["FEET"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_FEET);
		equipment["LEFT_HAND"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_LEFT_HAND);
		equipment["RIGHT_HAND"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_RIGHT_HAND);
		equipment["AMMO"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_AMMO);
		equipment["LEFT_RING"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_LEFT_RING);
		equipment["RIGHT_RING"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_RIGHT_RING);
		equipment["BELT"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_BELT);
		equipment["BACKPACK"] = m_NPCData->GetEquippedItem(EquipmentSlot::SLOT_BACKPACK);
		j["equipment"] = equipment;
	}

	return j;
}

U7Object* U7Object::LoadFromJson(const json& j)
{
	// Create new object
	U7Object* obj = new U7Object();

	// Set minimal properties needed for Init()
	// IMPORTANT: unitType defaults to 1 (UNIT_TYPE_OBJECT) if not present in JSON
	// We only save unitType if it's NOT 1 to reduce file size (see SaveToJson line 778)
	obj->m_UnitType = static_cast<UnitTypes>(j.value("unitType", 1));
	obj->m_ObjectType = j.value("shape", 0);
	obj->m_Frame = j.value("frame", 0);

	UnitTypes savedType = obj->m_UnitType;

	// Initialize object FIRST (loads texture, shape data, etc.)
	// This must happen before setting ANY other properties, since Init() resets many flags to defaults
	// IMPORTANT: Init's 2nd parameter is the SHAPE number (confusingly named "unitType" in Init's signature)
	obj->Init("", obj->m_ObjectType, obj->m_Frame);
	obj->m_UnitType = savedType;

	// Check if this is an egg object (same logic as LoadingState.cpp line 826)
	if (obj->m_objectData->m_name == "Egg" || obj->m_objectData->m_name == "path")
	{
		obj->m_isEgg = true;
		obj->m_isContainer = false;
	}

	// Now restore all other properties (which will overwrite Init's defaults)
	obj->m_ID = j.value("id", 0);
	obj->m_Quality = j.value("quality", 0);

	// Restore transform
	if (j.contains("position") && j["position"].is_array() && j["position"].size() == 3)
	{
		Vector3 loadedPos = {
			j["position"][0].get<float>(),
			j["position"][1].get<float>(),
			j["position"][2].get<float>()
		};
		// Use SetPos to properly calculate centerPoint, boundingBox, etc.
		obj->SetPos(loadedPos);
	}

	// Restore state
	obj->m_flags = j.value("flags", 0u);

	// Container hierarchy (restored in second pass by GameSerializer)
	int containingId = j.value("containingObjectId", -1);
	obj->m_isContained = (containingId != -1);
	obj->m_containingObjectId = containingId;

	if (j.contains("containerPos") && j["containerPos"].is_array() && j["containerPos"].size() == 2)
	{
		obj->m_InventoryPos.x = j["containerPos"][0];
		obj->m_InventoryPos.y = j["containerPos"][1];
	}

	// Inventory IDs will be restored in second pass by GameSerializer

	// Restore container state
	if (j.contains("isContainer"))
		obj->m_isContainer = j["isContainer"];
	if (j.contains("shouldBeSorted"))
		obj->m_shouldBeSorted = j["shouldBeSorted"];

	// NPC-specific fields
	if (obj->m_UnitType == UnitTypes::UNIT_TYPE_NPC)
	{
		obj->m_hp = j.value("hp", 25.0f);
		obj->m_combat = j.value("combat", 10.0f);
		obj->m_magic = j.value("magic", 0.0f);
		obj->m_Team = j.value("team", 0);
		obj->m_NPCID = j.value("npcID", 0);
		obj->m_currentFrameX = j.value("currentFrameX", 0);
		obj->m_currentFrameY = j.value("currentFrameY", 0);

		// Restore conversation tree flag
		obj->m_hasConversationTree = j.value("hasConversationTree", false);

		// Restore movement state (defaults to false)
		obj->m_isMoving = j.value("isMoving", false);

		// Restore schedule state
		obj->m_followingSchedule = j.value("followingSchedule", false);
		obj->m_lastSchedule = j.value("lastSchedule", -1);
		// Restore persisted batch index (optional)
		obj->m_npcBatchIndex = j.value("npcBatchIndex", -1);
		// DON'T restore destination - set it to current position so NPC doesn't walk back
		// If NPC was moved by player in sandbox mode, we want them to stay at their saved position
		// If they need to move for a schedule, the schedule system will set a new destination
		obj->SetDest(obj->m_Pos);

		// Get NPCData (should already be loaded from original data files)
		if (obj->m_NPCID >= 0 && obj->m_NPCID < g_NPCData.size())
		{
			obj->m_NPCData = g_NPCData[obj->m_NPCID].get();
			obj->m_isNPC = true;
			obj->m_isContainer = true;
		}

		obj->NPCInit(obj->m_NPCData);

		// Equipment slots will be restored in second pass by GameSerializer
	}

	if (obj->m_UnitType == UnitTypes::UNIT_TYPE_EGG || obj->m_shapeData->m_shape == 275)
	{
		obj->m_Visible = false;
	}

	return obj;
}
