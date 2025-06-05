#include "U7Globals.h"
#include "U7Player.h"

#include <string>

#include <string>
#include <vector>

using namespace std;

U7Player::U7Player()
{
	m_Gold = 0;
	m_PartyMembers.clear(); // Initialize with -1 (no party members)
	m_PlayerName = "Avatar";
	m_PartyMemberIDs.clear();
	m_PartyMemberIDs.push_back(0);
	m_PartyMembers.clear();
	m_PartyMembers.push_back("Avatar");
	m_PlayerPosition = { 0.0f, 0.0f, 0.0f };
	m_PlayerDirection = { 0.0f, 0.0f, 1.0f }; // Default direction facing forward
	m_isMale = true; // Default
}

vector<string>& U7Player::GetPartyMembers()
{
	return m_PartyMembers;
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
	for (int i = 0; i < m_PartyMembers.size(); i++)
	{
		if (m_PartyMembers[i] == npc_name)
		{
			return true;
		}
	}
	return false;
}