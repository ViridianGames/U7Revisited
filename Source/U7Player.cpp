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

bool U7Player::TryMove(const Vector3& desiredPos)
{
    U7Object* avatar = GetAvatarObject();
    if (!avatar) return false;

    float destH = avatar->m_Pos.y;
    if (!PathfindingSystem::ValidateMove(avatar, desiredPos, destH))
    {
        return false;
    }

    // Finalize: snap avatar for small vertical steps, and set dest
    Vector3 finalDest = desiredPos;
    finalDest.y = destH;

    // Instant step for stairs / small height changes
    if (fabs(destH - avatar->m_Pos.y) > 0.05f && fabs(destH - avatar->m_Pos.y) <= MAX_CLIMBABLE_HEIGHT)
    {
        Vector3 snapPos = avatar->m_Pos;
        snapPos.y = destH;
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
