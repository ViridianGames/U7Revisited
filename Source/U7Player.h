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
	void SetPartyMember(int index, int npc_id) { m_PartyMemberIDs[index] = npc_id; }
	//void SetPartyMembers(std::vector<int> partyMembers) { m_PartyMemberIDs = partyMembers; }
	void SetPlayerName(std::string name) { m_PlayerName = name; }
	void SetMale(bool isMale) { m_isMale = isMale; }
	bool GetIsMale() { return m_isMale; }
	std::string GetPlayerName() { return m_PlayerName; }
	void SetPlayerPosition(Vector3 position) { m_PlayerPosition = position; }
	Vector3 GetPlayerPosition() { return m_PlayerPosition; }
	void SetPlayerDirection(Vector3 direction) { m_PlayerDirection = direction; }
	Vector3 GetPlayerDirection() { return m_PlayerDirection; }
	std::vector<std::string>& GetPartyMemberNames();
	std::vector<int>& GetPartyMemberIds() { return m_PartyMemberIDs; };
	bool NPCIDInParty(int npc_id);
	bool NPCNameInParty(std::string name);
	bool IsWearingFellowshipMedallion() { return m_isWearingFellowshipMedallion; }
	int GetTrainingPoints() { return m_TrainingPoints; };
	int GetStr() { return m_str; }
	int GetDex() { return m_dex; }
	int GetInt() { return m_int; }
	int GetCombat() { return m_combat; }
	int GetMagic() { return m_magic; }
	float GetWeight();
	float GetMaxWeight() { return 2 * m_str;}

	void SetTrainingPoints(int tp) { m_TrainingPoints = tp; };
	void SetStr(int str) { m_str = str; }
	void SetDex(int dex) { m_dex = dex; }
	void SetInt(int iq) { m_int = iq; }
	void SetCombat(int combat) { m_combat = combat; }
	void SetMagic(int magic) { m_magic = magic; }

	int GetSelectedPartyMember() { return m_selectedPartyMember;};
	void SetSelectedPartyMember(int index);
	void AddPartyMember(int index);
	void RemovePartyMember(int index);

	private:
	int m_Gold = 100;
	int m_str = 18;
	int m_dex = 18;
	int m_int = 18;
	int m_combat = 14;
	int m_magic = 10;
	int m_TrainingPoints = 3;
	int m_weight = 0;
	std::vector<std::string> m_PartyMemberNames;
	std::vector<int> m_PartyMemberIDs;
	std::string m_PlayerName;
	Vector3 m_PlayerPosition;
	Vector3 m_PlayerDirection;

	bool m_isMale;

	bool m_isWearingFellowshipMedallion = false;

	int m_selectedPartyMember = 0; //  Avatar

};

#endif