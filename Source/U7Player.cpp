#include "U7Globals.h"
#include "U7Player.h"
#include "Geist/StateMachine.h"
#include "Geist/Logging.h"
#include "MainState.h"
#include "PathfindingSystem.h"
#include "U7Object.h"

#include <algorithm>
#include <shared_mutex>
#include <string>

#include <vector>
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

	// Rebuild display names from IDs (names were not always saved).
	m_PartyMemberNames.clear();
	for (int npcId : m_PartyMemberIDs)
	{
		auto it = g_NPCData.find(npcId);
		if (it != g_NPCData.end() && it->second)
			m_PartyMemberNames.push_back(it->second->name);
		else if (npcId == 0)
			m_PartyMemberNames.push_back(m_PlayerName.empty() ? "Avatar" : m_PlayerName);
		else
			m_PartyMemberNames.push_back("Unknown");
	}
	if (m_PartyMemberNames.empty())
	{
		m_PartyMemberNames.push_back(m_PlayerName.empty() ? "Avatar" : m_PlayerName);
		if (m_PartyMemberIDs.empty())
			m_PartyMemberIDs.push_back(0);
	}

	const int avatarObjId = j.value("avatarObject", 0);
	auto avNpc = g_NPCData.find(0);
	if (avNpc != g_NPCData.end() && avNpc->second)
		avNpc->second->m_objectID = avatarObjId;

	if (g_objectList.find(avatarObjId) != g_objectList.end())
	{
		m_AvatarObject = g_objectList[avatarObjId].get();
	}
	else
	{
		m_AvatarObject = nullptr;
		Log("U7Player::LoadFromJson - WARNING: avatar object id " + std::to_string(avatarObjId) + " not in object list");
	}

	if (m_AvatarObject)
	{
		if (m_isMale)
			SetAvatarMale();
		else
			SetAvatarFemale();

		// Prefer position already restored on the object via objects[] + SetPos.
		// Player JSON may override if present (use SetPos so bbox/chunk stay valid).
		if (j.contains("position") && j["position"].is_array() && j["position"].size() == 3)
		{
			Vector3 pos = {
				j["position"][0].get<float>(),
				j["position"][1].get<float>(),
				j["position"][2].get<float>()
			};
			m_AvatarObject->SetPos(pos);
			m_AvatarObject->SetDest(pos);
			m_AvatarObject->m_isMoving = false;
			m_AvatarObject->m_pathWaypoints.clear();
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

bool U7Player::TryMove(const Vector3& desiredPos)
{
	U7Object* avatar = GetAvatarObject();
	if (!avatar) return false;

	// Manual steer owns the avatar — cancel any click-path so it cannot fight us.
	avatar->m_pathWaypoints.clear();
	avatar->m_currentWaypointIndex = 0;
	avatar->m_pathfindingPending = false;
	avatar->m_isSchedulePath = false;

	const Vector3 pos = avatar->m_Pos;
	// Horizontal intent: keep feet Y so ValidateMove may step up onto platforms.
	Vector3 candidate = desiredPos;
	candidate.y = pos.y;
	float destH = pos.y;

	auto tryCandidate = [&](const Vector3& c, float& outH) -> bool {
		return PathfindingSystem::ValidateMove(avatar, c, outH);
	};

	bool accepted = tryCandidate(candidate, destH);

	// Wall slide: keep free axis; re-validate so climb height is recomputed.
	if (!accepted)
	{
		const float eps = 1e-5f;
		const bool wantX = fabsf(desiredPos.x - pos.x) > eps;
		const bool wantZ = fabsf(desiredPos.z - pos.z) > eps;

		Vector3 slideX = { desiredPos.x, pos.y, pos.z };
		Vector3 slideZ = { pos.x, pos.y, desiredPos.z };
		float hX = pos.y;
		float hZ = pos.y;
		const bool okX = wantX && tryCandidate(slideX, hX);
		const bool okZ = wantZ && tryCandidate(slideZ, hZ);

		if (okX && okZ)
		{
			if (fabsf(desiredPos.x - pos.x) >= fabsf(desiredPos.z - pos.z))
			{
				candidate = slideX;
				destH = hX;
			}
			else
			{
				candidate = slideZ;
				destH = hZ;
			}
			accepted = true;
		}
		else if (okX)
		{
			candidate = slideX;
			destH = hX;
			accepted = true;
		}
		else if (okZ)
		{
			candidate = slideZ;
			destH = hZ;
			accepted = true;
		}
	}

	if (!accepted)
		return false;

	Vector3 finalDest = candidate;
	finalDest.y = destH;

	const float climbDelta = destH - pos.y;
	const bool isClimbOrDrop = fabsf(climbDelta) > 0.05f && fabsf(climbDelta) <= MAX_CLIMBABLE_HEIGHT + 0.05f;

	// Climb/drop and flat walk both go through UpdateMovement so 3D speed
	// (XZ + height) is applied consistently — no instant vertical snaps.
	if (isClimbOrDrop)
	{
		// Prefer tile-center footprint for multi-tile crates/stairs.
		const int tx = (int)floorf(finalDest.x);
		const int tz = (int)floorf(finalDest.z);
		Vector3 landed = { tx + 0.5f, destH, tz + 0.5f };
		float landH = destH;
		if (tryCandidate(landed, landH))
		{
			landed.y = landH;
			avatar->SetDest(landed);
		}
		else
		{
			// Fallback: raw candidate XZ at resolved height.
			finalDest.y = destH;
			avatar->SetDest(finalDest);
		}
		avatar->m_Direction = Vector3{
			finalDest.x - pos.x, 0.0f, finalDest.z - pos.z
		};
		if (Vector3Length(avatar->m_Direction) > 1e-5f)
			avatar->m_Direction = Vector3Normalize(avatar->m_Direction);
		avatar->m_isMoving = true;
		return true;
	}

	// Flat walk: UpdateMovement interpolates toward dest.
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
