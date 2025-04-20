#include "U7Player.h"

U7Player::U7Player()
{
	m_Gold = 0;
	m_PartyMembers.resize(4, -1); // Initialize with -1 (no party members)
	m_PlayerName = "Avatar";
	m_PlayerPosition = { 0.0f, 0.0f, 0.0f };
	m_PlayerDirection = { 0.0f, 0.0f, 1.0f }; // Default direction facing forward
}
