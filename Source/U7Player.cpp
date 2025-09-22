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
	m_PartyMemberIDs.push_back(1);
	//m_PartyMemberIDs.push_back(2);
	m_PartyMemberNames.clear();
	m_PartyMemberNames.push_back("Avatar");
	m_PartyMemberNames.push_back("Iolo");
	//m_PartyMemberNames.push_back("Spark");

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

float U7Player::GetWeight()
{
	U7Object* avatarObject = g_objectList[g_NPCData[0]->m_objectID].get();
	float totalweight = 0;

	for (auto node = avatarObject->m_inventory.begin(); node != avatarObject->m_inventory.end(); node++)
	{
		U7Object* thisObject = g_objectList[(*node)].get();

		totalweight += g_objectDataTable[thisObject->m_shapeData->m_shape].m_weight;
	}

	m_weight = totalweight;

	return m_weight;
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

void U7Player::AddPartyMember(int index)
{
	if (std::find(m_PartyMemberIDs.begin(), m_PartyMemberIDs.end(), index) == m_PartyMemberIDs.end())
	{
		m_PartyMemberIDs.push_back(index);
		m_PartyMemberNames.push_back(g_NPCData[index]->name);
	}
}

void U7Player::RemovePartyMember(int index)
{
	m_PartyMemberIDs.erase(std::find(m_PartyMemberIDs.begin(), m_PartyMemberIDs.end(), index));
	m_PartyMemberNames.erase(std::find(m_PartyMemberNames.begin(), m_PartyMemberNames.end(), g_NPCData[index]->name));
}