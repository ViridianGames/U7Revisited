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
	void SetPartyMembers(std::vector<int> partyMembers) { m_PartyMembers = partyMembers; }
	void SetPlayerName(std::string name) { m_PlayerName = name; }
	void SetMale(bool isMale) { m_isMale = isMale; }
	bool GetIsMale() { return m_isMale; }
	std::string GetPlayerName() { return m_PlayerName; }
	void SetPlayerPosition(Vector3 position) { m_PlayerPosition = position; }
	Vector3 GetPlayerPosition() { return m_PlayerPosition; }
	void SetPlayerDirection(Vector3 direction) { m_PlayerDirection = direction; }
	Vector3 GetPlayerDirection() { return m_PlayerDirection; }
	bool CanCarry(int objectId, int quantity) { 
		// Placeholder for actual carry logic
		return true; 
	}
	void AddItem(int itemId, int quantity) { 
		// Placeholder for actual item addition logic
	}

	private:
	int m_Gold;
	std::vector<int> m_PartyMembers;
	std::string m_PlayerName;
	Vector3 m_PlayerPosition;
	Vector3 m_PlayerDirection;

	bool m_isMale;

};

#endif