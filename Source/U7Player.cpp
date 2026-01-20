#include "U7Globals.h"
#include "U7Player.h"

#include <algorithm>
#include <string>

#include <string>
#include <vector>

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

	m_PlayerPosition = { 0.0f, 0.0f, 0.0f };
	m_PlayerDirection = { 0.0f, 0.0f, 1.0f }; // Default direction facing forward

	m_selectedPartyMember = 0;
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
	return g_objectList[g_NPCData[0]->m_objectID].get();
}

void U7Player::AddPartyMember(int index)
{
	if (std::find(m_PartyMemberIDs.begin(), m_PartyMemberIDs.end(), index) == m_PartyMemberIDs.end())
	{
		m_PartyMemberIDs.push_back(index);
		m_PartyMemberNames.push_back(g_NPCData[index]->name);
		g_objectList[g_NPCData[index]->m_objectID]->m_speed = 5.0f; // Set speed to match avatar
	}
}

void U7Player::RemovePartyMember(int index)
{
	m_PartyMemberIDs.erase(std::find(m_PartyMemberIDs.begin(), m_PartyMemberIDs.end(), index));
	m_PartyMemberNames.erase(std::find(m_PartyMemberNames.begin(), m_PartyMemberNames.end(), g_NPCData[index]->name));
}

// ============================================================================
// Serialization
// ============================================================================

u7json U7Player::SaveToJson() const
{
	u7json j;

	j["name"] = m_PlayerName;
	j["isMale"] = m_isMale;
	j["position"] = { m_PlayerPosition.x, m_PlayerPosition.y, m_PlayerPosition.z };
	j["direction"] = { m_PlayerDirection.x, m_PlayerDirection.y, m_PlayerDirection.z };
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

	return j;
}

void U7Player::LoadFromJson(const json& j)
{
	m_PlayerName = j.value("name", "Avatar");
	m_isMale = j.value("isMale", true);

	if (j.contains("position") && j["position"].is_array() && j["position"].size() == 3)
	{
		m_PlayerPosition.x = j["position"][0];
		m_PlayerPosition.y = j["position"][1];
		m_PlayerPosition.z = j["position"][2];
	}

	if (j.contains("direction") && j["direction"].is_array() && j["direction"].size() == 3)
	{
		m_PlayerDirection.x = j["direction"][0];
		m_PlayerDirection.y = j["direction"][1];
		m_PlayerDirection.z = j["direction"][2];
	}

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