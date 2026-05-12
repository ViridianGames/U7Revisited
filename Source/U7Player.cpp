#include "U7Globals.h"
#include "U7Player.h"
#include "Geist/StateMachine.h"  
#include "MainState.h"           
#include "PathfindingSystem.h"
#include "U7Object.h"

#include <algorithm>
#include <shared_mutex>
#include <string>

#include <vector>
#include <sstream>

#include "ResourceManager.h"

using namespace std;

U7Player::U7Player()
{
	m_PartyMemberNames.clear(); // Initialize with -1 (no party members)
	m_isMale = true;
	if (m_isMale)
	{
		m_PlayerName = "Victor";
	}
	else
	{
		m_PlayerName = "Victoria";
	}
	m_PartyMemberIDs.clear();
	m_PartyMemberIDs.push_back(0);

	m_PartyMemberNames.clear();
	m_PartyMemberNames.push_back("Avatar");

	m_selectedPartyMember = 0;
}

void U7Player::SetAvatarObject(U7Object* obj)
{
	m_AvatarObject = obj;
}

vector<string>& U7Player::GetPartyMemberNames()
{
	return m_PartyMemberNames;
}

void U7Player::SetSelectedPartyMember(int index)
{
	if (!(std::find(m_PartyMemberIDs.begin(), m_PartyMemberIDs.end(), index) == m_PartyMemberIDs.end()))
	{
		m_selectedPartyMember = index;
	}
	else
	{
		m_selectedPartyMember = 0;
	}

}

bool U7Player::NPCIDInParty(int npc_id)
{
	for (int i = 0; i < m_PartyMemberIDs.size(); i++)
	{
		if (m_PartyMemberIDs[i] == npc_id)
		{
			return true;
		}
	}
	return false;
}

bool U7Player::NPCNameInParty(std::string npc_name)
{
	for (int i = 0; i < m_PartyMemberNames.size(); i++)
	{
		if (m_PartyMemberNames[i] == npc_name)
		{
			return true;
		}
	}
	return false;
}

U7Object* U7Player::GetAvatarObject()
{
	return m_AvatarObject;
}

void U7Player::AddPartyMember(int index)
{
	if (std::find(m_PartyMemberIDs.begin(), m_PartyMemberIDs.end(), index) == m_PartyMemberIDs.end())
	{
		m_PartyMemberIDs.push_back(index);
		m_PartyMemberNames.push_back(g_NPCData[index]->name);
		g_objectList[g_NPCData[index]->m_objectID]->m_speed = m_AvatarObject->m_speed; // Set speed to match avatar

		// Ensure new party member does NOT follow schedules
		if (g_StateMachine)
		{
			auto mainState = dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE));
			if (mainState)
				mainState->SetFollowingScheduleForNpc(index, false);
		}
	}
}

void U7Player::RemovePartyMember(int index)
{
	auto itId = std::find(m_PartyMemberIDs.begin(), m_PartyMemberIDs.end(), index);
	if (itId != m_PartyMemberIDs.end())
		m_PartyMemberIDs.erase(itId);
	auto itName = std::find(m_PartyMemberNames.begin(), m_PartyMemberNames.end(), g_NPCData[index]->name);
	if (itName != m_PartyMemberNames.end())
		m_PartyMemberNames.erase(itName);

	// Restore schedule-following for this NPC if schedules are enabled
	if (g_StateMachine)
	{
		auto mainState = dynamic_cast<MainState*>(g_StateMachine->GetState(STATE_MAINSTATE));
		if (mainState)
		{
			bool enabled = mainState->IsNpcSchedulesEnabled();
			mainState->SetFollowingScheduleForNpc(index, enabled && enabled /*explicit intent, keep readable*/);
		}
	}
}

// ============================================================================
// Serialization
// ============================================================================

u7json U7Player::SaveToJson() const
{
	u7json j;

	j["name"] = m_PlayerName;
	j["isMale"] = m_isMale;
	j["position"] = { m_AvatarObject->m_Pos.x, m_AvatarObject->m_Pos.y, m_AvatarObject->m_Pos.z };
	j["direction"] = { m_AvatarObject->m_Direction.x, m_AvatarObject->m_Direction.y, m_AvatarObject->m_Direction.z };
	j["gold"] = m_Gold;
	j["str"] = m_str;
	j["dex"] = m_dex;
	j["int"] = m_int;
	j["combat"] = m_combat;
	j["magic"] = m_magic;
	j["trainingPoints"] = m_TrainingPoints;
	j["partyMemberIDs"] = m_PartyMemberIDs;
	j["selectedPartyMember"] = m_selectedPartyMember;
	j["isWearingFellowshipMedallion"] = m_isWearingFellowshipMedallion;
	j["avatarObject"] = g_NPCData[0]->m_objectID;

	return j;
}

void U7Player::LoadFromJson(const json& j)
{
	m_PlayerName = j.value("name", "Avatar");
	m_isMale = j.value("isMale", true);

	m_Gold = j.value("gold", 100);
	m_str = j.value("str", 18);
	m_dex = j.value("dex", 18);
	m_int = j.value("int", 18);
	m_combat = j.value("combat", 14);
	m_magic = j.value("magic", 10);
	m_TrainingPoints = j.value("trainingPoints", 3);
	m_selectedPartyMember = j.value("selectedPartyMember", 0);
	m_isWearingFellowshipMedallion = j.value("isWearingFellowshipMedallion", false);

	if (j.contains("partyMemberIDs") && j["partyMemberIDs"].is_array())
	{
		m_PartyMemberIDs = j["partyMemberIDs"].get<std::vector<int>>();
	}

	g_NPCData[0]->m_objectID = j.value("avatarObject", 0);
	if (g_objectList.find(g_NPCData[0]->m_objectID) != g_objectList.end())
	{
		m_AvatarObject = g_objectList[g_NPCData[0]->m_objectID].get();
	}

	if (m_AvatarObject)
	{
		if (m_isMale)
		{
			SetAvatarMale();
		}
		else
		{
			SetAvatarFemale();
		}

		if (j.contains("position") && j["position"].is_array() && j["position"].size() == 3)
		{
			m_AvatarObject->m_Pos.x = j["position"][0];
			m_AvatarObject->m_Pos.y = j["position"][1];
			m_AvatarObject->m_Pos.z = j["position"][2];
		}

		if (j.contains("direction") && j["direction"].is_array() && j["direction"].size() == 3)
		{
			m_AvatarObject->m_Direction.x = j["direction"][0];
			m_AvatarObject->m_Direction.y = j["direction"][1];
			m_AvatarObject->m_Direction.z = j["direction"][2];
		}
	}

}

bool U7Player::IsWearingFellowshipMedallion()
{
	if (g_NPCData[0]->GetEquippedItem(EquipmentSlot::SLOT_NECK) == -1) // Nothing on the neck
	{
		return false;
	}

	int neckShape = g_objectList[g_NPCData[0]->GetEquippedItem(EquipmentSlot::SLOT_NECK)]->m_shapeData->GetShape();
	int neckFrame = g_objectList[g_NPCData[0]->GetEquippedItem(EquipmentSlot::SLOT_NECK)]->m_shapeData->GetFrame();
	return (neckShape == 955 && neckFrame == 1);
}

// AABB vs AABB intersection helper (axis-aligned)
static bool AABBIntersectsAABB(const Vector3& minA, const Vector3& maxA, const Vector3& minB, const Vector3& maxB)
{
    if (maxA.x < minB.x || minA.x > maxB.x) return false;
    if (maxA.y < minB.y || minA.y > maxB.y) return false;
    if (maxA.z < minB.z || minA.z > maxB.z) return false;
    return true;
}

bool U7Player::TryMove(const Vector3& desiredPos)
{
    U7Object* avatar = GetAvatarObject();
    if (!avatar) return false;

    // If pathfinding grid isn't available, fall back to simple SetDest
    if (!g_pathfindingSystem || !g_pathfindingSystem->m_pathfindingGrid)
    {
        avatar->SetDest(desiredPos);
        avatar->m_isMoving = true;
        return true;
    }

    PathfindingGrid* grid = g_pathfindingSystem->m_pathfindingGrid.get();

    int destX = (int)floor(desiredPos.x);
    int destZ = (int)floor(desiredPos.z);

    // Bounds check
    if (destX < 0 || destX >= 3072 || destZ < 0 || destZ >= 3072)
        return false;

    // Local walkable surface classifier (keeps in sync with PathfindingSystem::IsWalkableSurface)
    auto IsWalkableSurfaceLocal = [](int shapeID) -> bool {
        if (shapeID >= 367 && shapeID <= 370) return true; // Stairs
        if (shapeID == 1014) return true;                 // Teleporter/Floor
        if (shapeID >= 426 && shapeID <= 430) return true; // Bridges
        if (shapeID == 150 || shapeID == 193 || shapeID == 192) return true; // Rugs/Wood Floors
        if (shapeID == 973 || shapeID == 974) return true; // Stone floors
        if (shapeID >= 385 && shapeID <= 387) return true; // Thatch/Dirt floors
    	if (shapeID == 657 || shapeID == 678) return true; // Curtains
    	if (shapeID == 415) return true; // Garbage
    	if (shapeID == 257) return true; // fortress gateway
        return false;
    };

    // Source height (feet)
    float srcH = avatar->m_Pos.y;

    // Query grid default roof/terrain height
    float gridH = grid->GetTileHeight(destX, destZ);
    float destH = gridH; // default

    // Get overlapping world objects at tile
    auto overlappingObjects = grid->GetOverlappingObjects(destX, destZ);

    // Find best reachable floor/stair layer near our feet
    float bestFloorDist = 999.0f;
    bool foundReachableLayer = false;

    for (const auto& ov : overlappingObjects)
    {
        if (!ov.obj || !ov.obj->m_shapeData) continue;

        // Skip eggs/triggers — they should not affect climb/walkable surface decisions
        if (ov.obj->m_isEgg) continue;

        int sID = ov.obj->m_shapeData->GetShape();
    		if (sID == 257 || sID == 368 || sID == 657 || sID == 678 || sID == 415)
    		{
    			foundReachableLayer = true;
    			destH = srcH; // Stay at current height
    			break;
    		}

        if (IsWalkableSurfaceLocal(sID))
        {
            float walkableTop = ov.obj->m_Pos.y + (ov.obj->m_objectData ? ov.obj->m_objectData->m_height : 0.0f);
            float dist = fabs(walkableTop - srcH);

            if (dist <= MAX_CLIMBABLE_HEIGHT && dist < bestFloorDist)
            {
                destH = walkableTop;
                bestFloorDist = dist;
                foundReachableLayer = true;
            }
        }
    }

    // If no reachable object floor layer found, consider the grid height if within climb range
    if (!foundReachableLayer)
    {
        float gridDist = fabs(gridH - srcH);
        if (gridDist > MAX_CLIMBABLE_HEIGHT)
        {
            NPCDebugPrint("TryMove: BLOCKED - No reachable floor found (Grid=" + std::to_string(gridH) + " Feet=" + std::to_string(srcH) + ")");
            return false;
        }
        destH = gridH;
    }

    // Check for doors covering the tile (hinge vs tile)
    bool doorCoversTile = false;
    for (const auto& ov : overlappingObjects)
    {
        if (!ov.obj || !ov.obj->m_objectData) continue;

        // Skip eggs — they are non-blocking, non-door triggers
        if (ov.obj->m_isEgg) continue;

        if (ov.obj->m_objectData && ov.obj->m_objectData->m_isDoor)
        {
            // If this door object is not centered on this tile, it may cover it (hinge check)
            if (destX != (int)floor(ov.obj->m_Pos.x) || destZ != (int)floor(ov.obj->m_Pos.z))
            {
                doorCoversTile = true;
                break;
            }
        }
    }

    // Collision detection using chunk object map
    const float kPlayerRadius = 0.35f;     // current halfSize
    const float kPlayerHeight = 1.6f;      // current playerHeight
    const float kSmallObstacleHeight = 0.25f;
    const float kSweptSampleStep = 0.25f;
    // Use swept vertical range between src and dest so tall stairs are handled
    float footMinY = std::min(srcH, destH);
    float footMaxY = std::max(srcH, destH);
    Vector3 playerMin = { desiredPos.x - kPlayerRadius, footMinY, desiredPos.z - kPlayerRadius };
    Vector3 playerMax = { desiredPos.x + kPlayerRadius, footMaxY + kPlayerHeight, desiredPos.z + kPlayerRadius };

    int chunkX = destX / 16;
    int chunkZ = destZ / 16;
    const float stairHeightTolerance = 1.0f;
    const float climbEpsilon = 0.05f;

    // Protect chunk map with shared lock if available
    extern std::shared_mutex g_chunkMapMutex;
    std::shared_lock lock(g_chunkMapMutex);

    for (int dz = -1; dz <= 1; ++dz)
    {
        for (int dx = -1; dx <= 1; ++dx)
        {
            int cx = chunkX + dx;
            int cz = chunkZ + dz;
            if (cx < 0 || cx >= 192 || cz < 0 || cz >= 192) continue;

            for (U7Object* obj : g_chunkObjectMap[cx][cz])
            {
                if (!obj) continue;

                // Allow walking through eggs/triggers: they should be interactive but non-blocking.
                if (obj->m_isEgg) continue;

                if (obj->m_isNPC) continue;
                if (!obj->m_shapeData) continue;
                if (obj->m_isContained) continue; // skip items in containers

                // Use the object's world-space bounding box (more accurate than m_Pos + height)
                Vector3 minObj = obj->m_boundingBox.min;
                Vector3 maxObj = obj->m_boundingBox.max;

                // conservative small expansion (very small, tune if needed)
                const float eps = 0.02f;
                minObj.x -= eps; minObj.y -= eps; minObj.z -= eps;
                maxObj.x += eps; maxObj.y += eps; maxObj.z += eps;

                // Quick reject if AABBs don't overlap
                if (!AABBIntersectsAABB(playerMin, playerMax, minObj, maxObj))
                    continue;

                // Now we have overlap — decide whether it should block movement
                float objBottom = minObj.y;
                float objTop = maxObj.y;
                int shapeID = obj->m_shapeData->GetShape();

                // Compute canonical walkable surface top when object has objectData (stairs/floors).
                float walkableTop = objTop;
                if (obj->m_objectData)
                    walkableTop = obj->m_Pos.y + obj->m_objectData->m_height;

                // 1) ignore very small ground clutter early
                float objHeight = objTop - objBottom;
                if (objHeight > 0.0f && objHeight < kSmallObstacleHeight)
                {
                    if (!(obj->m_objectData && obj->m_objectData->m_isDoor))
                    {
                        continue;
                    }

                    float footprintX = maxObj.x - minObj.x;
                    float footprintZ = maxObj.z - minObj.z;
                    if (objHeight < kSmallObstacleHeight && footprintX < 1.0f && footprintZ < 1.0f) continue;
                }

                // 2) door hinge special-case (unchanged)
                if (obj->m_objectData && obj->m_objectData->m_isDoor)
                {
                    if (destX == (int)floor(obj->m_Pos.x) && destZ == (int)floor(obj->m_Pos.z))
                    {
#ifdef DEBUG_NPC_PATHFINDING
                        NPCDebugPrint("TryMove: BLOCKED by door hinge on tile");
#endif
                        return false;
                    }
#ifdef DEBUG_NPC_PATHFINDING
                    NPCDebugPrint("TryMove: door object encountered but not hinge tile -> allow");
#endif
                    continue;
                }

                // 3) ignore ceilings / upper floors
                // Use the maximum foot height (src/dest) so objects whose bottom is higher than any head position are ignored
                if (objBottom >= (footMaxY + kPlayerHeight))
                {
#ifdef DEBUG_NPC_PATHFINDING
                    NPCDebugPrint("TryMove: ignoring object - bottom above player's max head height (upper floor / ceiling)");
#endif
                    continue;
                }

                // 4) swept collision: sample along movement from src -> desired
                Vector3 srcPos = avatar->m_Pos;
                Vector3 moveDelta = Vector3Subtract(desiredPos, srcPos);
                float distXZ = sqrtf(moveDelta.x * moveDelta.x + moveDelta.z * moveDelta.z);
                if (distXZ > 0.0001f)
                {
                    const float sampleStep = 0.25f; // tune: smaller = more precise, bigger = cheaper
                    int steps = (int)ceil(distXZ / sampleStep);
                    bool hit = false;
                    for (int s = 1; s <= steps; ++s)
                    {
                        float t = (float)s / (float)steps;
                        Vector3 samplePos = Vector3Add(srcPos, Vector3Scale(moveDelta, t));
                        // Interpolate Y between src and dest to account for slopes/steps
                        float sampleY = srcH + (destH - srcH) * t; // linear interp
                        Vector3 sampleMin = { samplePos.x - kPlayerRadius, sampleY, samplePos.z - kPlayerRadius };
                        Vector3 sampleMax = { samplePos.x + kPlayerRadius, sampleY + kPlayerHeight, samplePos.z + kPlayerRadius };
                        if (AABBIntersectsAABB(sampleMin, sampleMax, minObj, maxObj))
                        {
                            hit = true;
#ifdef DEBUG_NPC_PATHFINDING
                            {
                                std::stringstream ss;
                                ss << "TryMove: swept hit objID=" << obj->m_ID << " at t=" << t << " sampleY=" << sampleY;
                                NPCDebugPrint(ss.str());
                            }
#endif
                            // If the object is a walkable surface (stairs/floor) attempt a more permissive check:
                            // Query the grid for walkable surface heights at the sample tile and allow the intersection
                            // if any candidate surface is both reachable from our current feet (srcH) and within one-step climb
                            // from the sampled foot height. This helps multi-step stairs where bounding meshes/risers are taller
                            // than the usable surface.
                            if (IsWalkableSurfaceLocal(shapeID))
                            {
                                int tx = (int)floor(samplePos.x);
                                int tz = (int)floor(samplePos.z);
                                bool allowWalkableHit = false;
                                if (tx >= 0 && tx < 3072 && tz >= 0 && tz < 3072)
                                {
                                    auto heights = grid->GetWalkableSurfaceHeights(tx, tz);
                                    for (float h : heights)
                                    {
                                        // h is a candidate usable surface top for that tile.
                                        // Allow if:
                                        //  - we can reach that surface from our current feet (h - srcH <= MAX_CLIMBABLE_HEIGHT + epsilon)
                                        //  - and the sampled foot position is within one step of that surface (h - sampleY <= MAX_CLIMBABLE_HEIGHT + epsilon)
                                        if ((h - srcH) <= (MAX_CLIMBABLE_HEIGHT + climbEpsilon) &&
                                            (h - sampleY) <= (MAX_CLIMBABLE_HEIGHT + climbEpsilon) &&
                                            (h + 0.001f) >= sampleY) // ensure the surface is at-or-above sample foot
                                        {
                                            allowWalkableHit = true;
                                            break;
                                        }
                                    }
                                }

                                if (allowWalkableHit)
                                {
#ifdef DEBUG_NPC_PATHFINDING
                                    NPCDebugPrint("TryMove: swept hit on walkable surface accepted by tile-surface check");
#endif
                                    hit = false; // ignore this swept hit
                                }
                            }

                            break;
                        }
                    }
                    if (hit)
                    {
#ifdef DEBUG_NPC_PATHFINDING
                        {
                            std::stringstream ss;
                            ss << "TryMove BLOCKED (swept): objID=" << obj->m_ID
                               << " name=\"" << (obj->m_objectData ? obj->m_objectData->m_name : std::string("Object")) << "\""
                               << " objBottom=" << objBottom << " objTop=" << objTop;
                            NPCDebugPrint(ss.str());
                        }
#endif
                        return false;
                    }
                }

                // 5) vertical-span overlap check (fallback)
                // Allow if this is a walkable surface and its canonical top is close to either src or dest feet (covers step climbing).
                // Also check tile surfaces to allow cases where bounding-box geometry extends above the usable surface.
                bool allowedBySurface = false;
                if (IsWalkableSurfaceLocal(shapeID))
                {
                    // Canonical quick allow
                    if ((fabs(walkableTop - srcH) <= (MAX_CLIMBABLE_HEIGHT + climbEpsilon)) ||
                        (fabs(walkableTop - destH) <= (MAX_CLIMBABLE_HEIGHT + climbEpsilon)))
                    {
                        allowedBySurface = true;
                    }
                    else
                    {
                        // As fallback, consult tile's walkable heights (defensive)
                        int tx = destX;
                        int tz = destZ;
                        if (tx >= 0 && tx < 3072 && tz >= 0 && tz < 3072)
                        {
                            auto heights = grid->GetWalkableSurfaceHeights(tx, tz);
                            for (float h : heights)
                            {
                                if ((h - srcH) <= (MAX_CLIMBABLE_HEIGHT + climbEpsilon) &&
                                    (h - destH) <= (MAX_CLIMBABLE_HEIGHT + climbEpsilon))
                                {
                                    allowedBySurface = true;
                                    break;
                                }
                            }
                        }
                    }
                }

                if (allowedBySurface)
                {
#ifdef DEBUG_NPC_PATHFINDING
                    NPCDebugPrint("TryMove: vertical overlap with walkable surface allowed by tile-surface check");
#endif
                    continue;
                }

                // Final blocking test against our swept vertical range
                if (!(objTop < playerMin.y || objBottom > playerMax.y))
                {
#ifdef DEBUG_NPC_PATHFINDING
                    std::stringstream ss;
                    ss << "TryMove BLOCKED: objID=" << obj->m_ID
                       << " name=\"" << (obj->m_objectData ? obj->m_objectData->m_name : std::string("Object")) << "\""
                       << " objBottom=" << objBottom << " objTop=" << objTop
                       << " playerMinY=" << playerMin.y << " playerMaxY=" << playerMax.y
                       << " srcH=" << srcH << " destH=" << destH;
                    NPCDebugPrint(ss.str());
#endif
                    return false;
                }

#ifdef DEBUG_NPC_PATHFINDING
                NPCDebugPrint("TryMove: overlap resolved as non-blocking (fallback)");
#endif
            }
        }
    }

    // Finalize: snap avatar for small vertical steps, and set dest
    Vector3 finalDest = desiredPos;
    finalDest.y = destH;

    // Instant step for stairs / small height changes
    if (fabs(destH - srcH) > 0.05f)
    {
        Vector3 snapPos = avatar->m_Pos;
        snapPos.y = destH + 0.1f;
        avatar->SetPos(snapPos);
    }

    avatar->SetDest(finalDest);
    avatar->m_isMoving = true;
    return true;
}

void U7Player::SetAvatarMale()
{
	m_isMale = true;
	m_PlayerName = "Victor";

	int shapenum = 721;

						Image image;

					//  South-west
					m_AvatarObject->m_NPCData->m_walkTextures[0][0] = &g_shapeTable[shapenum][16].m_texture->m_Texture;
					g_NPCData[0]->m_walkTextures[0][1] = &g_shapeTable[shapenum][17].m_texture->m_Texture;

					//  North-west

					//  Frame 1
					std::string texturename = to_string(shapenum) + "_NW_0";
					if(g_ResourceManager->DoesTextureExist(texturename))
					{
						g_NPCData[0]->m_walkTextures[1][0] = g_ResourceManager->GetTexture(texturename);
					}
					else
					{
						image = ImageCopy(g_shapeTable[shapenum][16].m_texture->m_Image);
						ImageFlipHorizontal(&image);
						g_ResourceManager->AddTexture(image, texturename);
						m_AvatarObject->m_NPCData->m_walkTextures[1][0] = g_ResourceManager->GetTexture(texturename);
					}

					//  Frame 2

					texturename = to_string(shapenum) + "_NW_1";
					if(g_ResourceManager->DoesTextureExist(texturename))
					{
						m_AvatarObject->m_NPCData->m_walkTextures[1][1] = g_ResourceManager->GetTexture(texturename);
					}
					else
					{
						image = ImageCopy(g_shapeTable[shapenum][17].m_texture->m_Image);
						ImageFlipHorizontal(&image);
						g_ResourceManager->AddTexture(image, texturename);
						m_AvatarObject->m_NPCData->m_walkTextures[1][1] = g_ResourceManager->GetTexture(texturename);
					}

					//  North-east
					m_AvatarObject->m_NPCData->m_walkTextures[2][0] = &g_shapeTable[shapenum][0].m_texture->m_Texture;
					m_AvatarObject->m_NPCData->m_walkTextures[2][1] = &g_shapeTable[shapenum][1].m_texture->m_Texture;

					//  South-east

					//  Frame 1
					texturename = to_string(shapenum) + "_SE_0";
					if(g_ResourceManager->DoesTextureExist(texturename))
					{
						m_AvatarObject->m_NPCData->m_walkTextures[3][0] = g_ResourceManager->GetTexture(texturename);
					}
					else
					{
						image = ImageCopy(g_shapeTable[shapenum][1].m_texture->m_Image);
						ImageFlipHorizontal(&image);
						g_ResourceManager->AddTexture(image, texturename);
						m_AvatarObject->m_NPCData->m_walkTextures[3][0] = g_ResourceManager->GetTexture(texturename);
					}

					//  Frame 2

					texturename = to_string(shapenum) + "_SE_1";
					if(g_ResourceManager->DoesTextureExist(texturename))
					{
						m_AvatarObject->m_NPCData->m_walkTextures[3][1] = g_ResourceManager->GetTexture(texturename);
					}
					else
					{
						image = ImageCopy(g_shapeTable[shapenum][2].m_texture->m_Image);
						ImageFlipHorizontal(&image);
						g_ResourceManager->AddTexture(image, texturename);
						m_AvatarObject->m_NPCData->m_walkTextures[3][1] = g_ResourceManager->GetTexture(texturename);
					}
}

void U7Player::SetAvatarFemale()
{
	m_isMale = false;
	m_PlayerName = "Victoria";

	int shapenum = 989;

						Image image;

					//  South-west
					m_AvatarObject->m_NPCData->m_walkTextures[0][0] = &g_shapeTable[shapenum][16].m_texture->m_Texture;
					g_NPCData[0]->m_walkTextures[0][1] = &g_shapeTable[shapenum][17].m_texture->m_Texture;

					//  North-west

					//  Frame 1
					std::string texturename = to_string(shapenum) + "_NW_0";
					if(g_ResourceManager->DoesTextureExist(texturename))
					{
						g_NPCData[0]->m_walkTextures[1][0] = g_ResourceManager->GetTexture(texturename);
					}
					else
					{
						image = ImageCopy(g_shapeTable[shapenum][16].m_texture->m_Image);
						ImageFlipHorizontal(&image);
						g_ResourceManager->AddTexture(image, texturename);
						m_AvatarObject->m_NPCData->m_walkTextures[1][0] = g_ResourceManager->GetTexture(texturename);
					}

					//  Frame 2

					texturename = to_string(shapenum) + "_NW_1";
					if(g_ResourceManager->DoesTextureExist(texturename))
					{
						m_AvatarObject->m_NPCData->m_walkTextures[1][1] = g_ResourceManager->GetTexture(texturename);
					}
					else
					{
						image = ImageCopy(g_shapeTable[shapenum][17].m_texture->m_Image);
						ImageFlipHorizontal(&image);
						g_ResourceManager->AddTexture(image, texturename);
						m_AvatarObject->m_NPCData->m_walkTextures[1][1] = g_ResourceManager->GetTexture(texturename);
					}

					//  North-east
					m_AvatarObject->m_NPCData->m_walkTextures[2][0] = &g_shapeTable[shapenum][0].m_texture->m_Texture;
					m_AvatarObject->m_NPCData->m_walkTextures[2][1] = &g_shapeTable[shapenum][1].m_texture->m_Texture;

					//  South-east

					//  Frame 1
					texturename = to_string(shapenum) + "_SE_0";
					if(g_ResourceManager->DoesTextureExist(texturename))
					{
						m_AvatarObject->m_NPCData->m_walkTextures[3][0] = g_ResourceManager->GetTexture(texturename);
					}
					else
					{
						image = ImageCopy(g_shapeTable[shapenum][1].m_texture->m_Image);
						ImageFlipHorizontal(&image);
						g_ResourceManager->AddTexture(image, texturename);
						m_AvatarObject->m_NPCData->m_walkTextures[3][0] = g_ResourceManager->GetTexture(texturename);
					}

					//  Frame 2

					texturename = to_string(shapenum) + "_SE_1";
					if(g_ResourceManager->DoesTextureExist(texturename))
					{
						m_AvatarObject->m_NPCData->m_walkTextures[3][1] = g_ResourceManager->GetTexture(texturename);
					}
					else
					{
						image = ImageCopy(g_shapeTable[shapenum][2].m_texture->m_Image);
						ImageFlipHorizontal(&image);
						g_ResourceManager->AddTexture(image, texturename);
						m_AvatarObject->m_NPCData->m_walkTextures[3][1] = g_ResourceManager->GetTexture(texturename);
					}
}
