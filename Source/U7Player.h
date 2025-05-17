#ifndef _U7PLAYER_H_
#define _U7PLAYER_H_

#include <list>
#include <vector>
#include <memory>
#include <map>

#include "Geist/Object.h"
#include "Geist/Primitives.h"
#include "Geist/Gui.h"
#include "Geist/GuiElements.h"

class U7Player
{
public:
	U7Player();
	virtual ~U7Player(){};

	int GetGold() { return m_Gold; }
	void SpendGold(int amount) { m_Gold -= amount; }
	void AddGold(int amount) { m_Gold += amount; }
	void SetGold(int amount) { m_Gold = amount; }
	void SetPartyMember(int index, int npc_id) { m_PartyMembers[index] = npc_id; }
	//void SetPartyMembers(std::vector<int> partyMembers) { m_PartyMemberIDs = partyMembers; }
	void SetPlayerName(std::string name) { m_PlayerName = name; }
	void SetMale(bool isMale) { m_isMale = isMale; }
	bool GetIsMale() { return m_isMale; }
	std::string GetPlayerName() { return m_PlayerName; }
	void SetPlayerPosition(Vector3 position) { m_PlayerPosition = position; }
	Vector3 GetPlayerPosition() { return m_PlayerPosition; }
	void SetPlayerDirection(Vector3 direction) { m_PlayerDirection = direction; }
	Vector3 GetPlayerDirection() { return m_PlayerDirection; }
	std::vector<std::string>& GetPartyMembers();
	bool NPCInParty(int npc_id);
	bool IsWearingFellowshipMedallion() { return m_isWearingFellowshipMedallion; }

	private:
	int m_Gold;
	std::vector<std::string> m_PartyMembers;
	std::vector<int> m_PartyMemberIDs;
	std::string m_PlayerName;
	Vector3 m_PlayerPosition;
	Vector3 m_PlayerDirection;

	bool m_isMale;

	bool m_isWearingFellowshipMedallion = false;

};

#endif