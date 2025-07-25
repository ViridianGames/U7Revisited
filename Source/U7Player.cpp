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
	m_PlayerName = "Avatar";
	m_PartyMemberIDs.clear();
	m_PartyMemberIDs.push_back(0);
	m_PartyMemberIDs.push_back(1);
	m_PartyMemberIDs.push_back(2);
	m_PartyMemberNames.clear();
	m_PartyMemberNames.push_back("Avatar");
	m_PartyMemberNames.push_back("Iolo");
	m_PartyMemberNames.push_back("Spark");

	m_PlayerPosition = { 0.0f, 0.0f, 0.0f };
	m_PlayerDirection = { 0.0f, 0.0f, 1.0f }; // Default direction facing forward
	m_isMale = true; // Default
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