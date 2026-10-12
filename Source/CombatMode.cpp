#include "CombatMode.h"
#include "MainState.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "U7Player.h"
#include "CombatState.h"
#include "PathfindingSystem.h"
#include "Geist/Engine.h"
#include "Geist/Config.h"
#include "Geist/Logging.h"
#include "raylib.h"
#include "raymath.h"
#include "rlgl.h"

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <queue>
#include <string>
#include <unordered_map>
#include <utility>

namespace
{
	constexpr const char* kCombatStyleConfigKey = "combat_style";

	CombatStyle ClampCombatStyle(int value)
	{
		if (value < static_cast<int>(CombatStyle::Original) ||
		    value > static_cast<int>(CombatStyle::TurnBased))
			return CombatStyle::RealTimePause;
		return static_cast<CombatStyle>(value);
	}
}

const char* CombatStyleDisplayName(CombatStyle style)
{
	switch (style)
	{
	case CombatStyle::Original: return "Original";
	case CombatStyle::RealTimePause: return "Real-Time with Pause";
	case CombatStyle::TurnBased: return "Turn-Based";
	}
	return "Real-Time with Pause";
}

const char* CombatStyleConfigToken(CombatStyle style)
{
	switch (style)
	{
	case CombatStyle::Original: return "original";
	case CombatStyle::RealTimePause: return "realtime_pause";
	case CombatStyle::TurnBased: return "turn_based";
	}
	return "realtime_pause";
}

CombatStyle GetCombatStylePreference()
{
	if (!g_Engine)
		return CombatStyle::RealTimePause;

	// engine.cfg ships combat_style = 1 (RealTimePause). Invalid values clamp to RealTimePause.
	return ClampCombatStyle(static_cast<int>(g_Engine->m_EngineConfig.GetNumber(kCombatStyleConfigKey)));
}

void SetCombatStylePreference(CombatStyle style)
{
	if (!g_Engine)
		return;
	g_Engine->m_EngineConfig.SetNumber(kCombatStyleConfigKey, static_cast<float>(static_cast<int>(style)));
	g_Engine->m_EngineConfig.Save();
}

std::unique_ptr<CombatMode> CreateCombatMode(CombatStyle style)
{
	switch (style)
	{
	case CombatStyle::Original:
		return std::make_unique<OriginalCombatMode>();
	case CombatStyle::RealTimePause:
		return std::make_unique<RealTimePauseCombatMode>();
	case CombatStyle::TurnBased:
		return std::make_unique<TurnBasedCombatMode>();
	}
	return std::make_unique<RealTimePauseCombatMode>();
}

void CombatMode::OnEnter(MainState& main)
{
	(void)main;
	if (IsImplemented())
		return;

	std::string line = std::string(GetDisplayName()) + " combat is not implemented yet.";
	AddConsoleString(line, YELLOW);
	AddConsoleString("Combat is frozen. Press C or Escape to leave.", WHITE);
	Log(std::string("CombatMode stub enter: ") + GetDisplayName());
}

void CombatMode::OnLeave(MainState& main)
{
	(void)main;
}

void CombatMode::Update(MainState& main)
{
	(void)main;
}

void CombatMode::HandleInput(MainState& main)
{
	(void)main;
	if (IsImplemented())
		return;

	if (IsKeyPressed(KEY_SPACE))
	{
		AddConsoleString(
			std::string(GetDisplayName()) + " - coming soon. Press C or Escape to leave combat.",
			YELLOW);
	}
}

void CombatMode::DrawHud(MainState& main)
{
	(void)main;
	if (IsImplemented())
		return;

	Font* font = g_SmallFont ? g_SmallFont.get() : nullptr;
	if (!font)
		return;

	const std::string title = std::string(GetDisplayName()) + " - Coming Soon";
	const std::string hint = "Press C or Escape to leave combat";
	const float fontSize = static_cast<float>(font->baseSize);
	const float titleW = MeasureTextEx(*font, title.c_str(), fontSize, 1).x;
	const float hintW = MeasureTextEx(*font, hint.c_str(), fontSize, 1).x;
	const float boxW = std::max(titleW, hintW) + 24.0f;
	const float boxH = fontSize * 2.6f + 16.0f;
	const float boxX = (640.0f - boxW) * 0.5f;
	const float boxY = 24.0f;

	DrawRectangle(static_cast<int>(boxX), static_cast<int>(boxY),
	              static_cast<int>(boxW), static_cast<int>(boxH),
	              Color{ 0, 0, 0, 180 });
	DrawRectangleLines(static_cast<int>(boxX), static_cast<int>(boxY),
	                   static_cast<int>(boxW), static_cast<int>(boxH), YELLOW);

	DrawTextEx(*font, title.c_str(),
	           Vector2{ boxX + (boxW - titleW) * 0.5f, boxY + 8.0f },
	           fontSize, 1, YELLOW);
	DrawTextEx(*font, hint.c_str(),
	           Vector2{ boxX + (boxW - hintW) * 0.5f, boxY + 8.0f + fontSize * 1.3f },
	           fontSize, 1, WHITE);
}

////////////////////////////////////////////////////////////////////////////////
// Real-Time with Pause
////////////////////////////////////////////////////////////////////////////////

void ClampCombatCameraKeepAvatarOnScreen()
{
	if (g_firstPersonEnabled)
		return;
	if (!g_Player || !g_Engine)
		return;
	if (IsCameraLocked())
		return;

	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
		return;

	const float screenW = static_cast<float>(g_Engine->m_ScreenWidth);
	const float screenH = static_cast<float>(g_Engine->m_ScreenHeight);
	if (screenW < 1.0f || screenH < 1.0f)
		return;

	const Vector3 avatarPos = avatar->m_centerPoint;

	// Camera-relative axes (same convention as third-person pan).
	Vector3 forward = Vector3{ -1.0f, 0.0f, -1.0f };
	forward = Vector3RotateByAxisAngle(forward, Vector3{ 0, 1, 0 }, g_cameraRotation);
	forward.y = 0.0f;
	if (Vector3LengthSqr(forward) > 1e-6f)
		forward = Vector3Normalize(forward);
	Vector3 right = Vector3Normalize(Vector3CrossProduct(Vector3{ 0.0f, 1.0f, 0.0f }, forward));

	// Ortho: fovy ≈ visible world height. Keep Avatar inside a ~12% screen margin
	// by hard-clamping look-at offset from the Avatar (no spring / no bounce).
	constexpr float kMarginFrac = 0.12f;
	const float halfH = std::max(g_cameraDistance, 1.0f) * 0.5f;
	const float halfW = halfH * (screenW / screenH);
	const float maxAlongRight = halfW * (1.0f - 2.0f * kMarginFrac);
	const float maxAlongFwd = halfH * (1.0f - 2.0f * kMarginFrac);

	const float dx = g_camera.target.x - avatarPos.x;
	const float dz = g_camera.target.z - avatarPos.z;
	float alongRight = dx * right.x + dz * right.z;
	float alongFwd = dx * forward.x + dz * forward.z;
	const float clampedRight = std::clamp(alongRight, -maxAlongRight, maxAlongRight);
	const float clampedFwd = std::clamp(alongFwd, -maxAlongFwd, maxAlongFwd);

	bool hitLeash = false;
	if (clampedRight != alongRight || clampedFwd != alongFwd ||
	    !std::isfinite(g_camera.target.x) || !std::isfinite(g_camera.target.z))
	{
		g_camera.target.x = avatarPos.x + right.x * clampedRight + forward.x * clampedFwd;
		g_camera.target.z = avatarPos.z + right.z * clampedRight + forward.z * clampedFwd;
		g_camera.target.y = avatarPos.y;
		hitLeash = true;
	}

	constexpr float kWorldMax = 3071.0f;
	if (!std::isfinite(g_camera.target.x) || g_camera.target.x < 0.0f)
	{
		g_camera.target.x = 0.0f;
		hitLeash = true;
	}
	if (g_camera.target.x > kWorldMax)
	{
		g_camera.target.x = kWorldMax;
		hitLeash = true;
	}
	if (!std::isfinite(g_camera.target.z) || g_camera.target.z < 0.0f)
	{
		g_camera.target.z = 0.0f;
		hitLeash = true;
	}
	if (g_camera.target.z > kWorldMax)
	{
		g_camera.target.z = kWorldMax;
		hitLeash = true;
	}

	// Kill pan momentum at the border so CameraUpdate decay cannot push past
	// and fight the hard stop (that felt like bounce).
	if (hitLeash)
	{
		g_CameraMovementSpeed = Vector3{ 0.0f, 0.0f, 0.0f };
		g_CameraMoved = true;
	}

	Vector3 camPos = { g_cameraDistance, g_cameraDistance, g_cameraDistance };
	camPos = Vector3RotateByAxisAngle(camPos, Vector3{ 0, 1, 0 }, g_cameraRotation);
	g_camera.position = Vector3Add(g_camera.target, camPos);
	g_camera.fovy = g_cameraDistance;
	g_camera.projection = CAMERA_ORTHOGRAPHIC;
}

bool RealTimePauseCombatMode::IsSimulationPaused() const
{
	return m_main ? m_main->m_combatPaused : true;
}

void RealTimePauseCombatMode::OnEnter(MainState& main)
{
	m_main = &main;
	m_wasCameraLocked = IsCameraLocked();

	// Unlock for battlefield pan/zoom; Avatar-on-screen leash runs in Update.
	if (IsCameraLocked())
		g_cameraLockObjectId = -1;

	main.m_combatPaused = true;
	main.m_combatSelectedPartyMemberObjectId = -1;

	// Frame the fight: look-at between Avatar and nearest threat, Avatar kept on-screen.
	U7Object* avatar = g_Player ? g_Player->GetAvatarObject() : nullptr;
	U7Object* threat = nullptr;
	float bestDistSqr = 1.0e12f;
	for (int pid : main.m_combatParticipants)
	{
		auto it = g_objectList.find(pid);
		if (it == g_objectList.end() || !it->second)
			continue;
		U7Object* obj = it->second.get();
		if (!IsHostileCombatUnit(obj))
			continue;
		if (!avatar)
		{
			threat = obj;
			break;
		}
		const float distSqr = Vector2DistanceSqr(
			{ obj->m_Pos.x, obj->m_Pos.z },
			{ avatar->m_Pos.x, avatar->m_Pos.z });
		if (distSqr < bestDistSqr)
		{
			bestDistSqr = distSqr;
			threat = obj;
		}
	}
	if (!threat)
		threat = FindNearestHostileInAggroRange();

	if (avatar && threat)
	{
		// Bias slightly toward the Avatar so the party stays readable.
		constexpr float kTowardThreat = 0.35f;
		g_camera.target.x = avatar->m_Pos.x + (threat->m_Pos.x - avatar->m_Pos.x) * kTowardThreat;
		g_camera.target.z = avatar->m_Pos.z + (threat->m_Pos.z - avatar->m_Pos.z) * kTowardThreat;
		g_camera.target.y = avatar->m_Pos.y;
		g_CameraMoved = true;

		// Prefer a slightly wider tactical view when still zoomed in.
		if (g_Engine)
		{
			const float farLimit = g_Engine->m_EngineConfig.GetNumber("camera_far_limit");
			const float prefer = std::min(farLimit, std::max(g_cameraDistance, 28.0f));
			g_cameraDistance = prefer;
		}
	}
	else if (avatar)
	{
		g_camera.target = avatar->m_Pos;
		g_CameraMoved = true;
	}

	ClampCombatCameraKeepAvatarOnScreen();

	AddConsoleString("Combat! Game is paused - issue orders, then press Space to fight.", YELLOW);
	AddConsoleString("Click a party member, then an enemy or the ground. H: Hold  A: Automatic.", WHITE);
	AddConsoleString("Camera unlocked between you and the nearest threat. Press C or Escape to leave.", WHITE);
	Log("RealTimePauseCombatMode::OnEnter");
}

void RealTimePauseCombatMode::OnLeave(MainState& main)
{
	(void)main;
	if (m_wasCameraLocked)
		LockCameraToAvatar();
	m_main = nullptr;
	m_wasCameraLocked = false;
	Log("RealTimePauseCombatMode::OnLeave");
}

void RealTimePauseCombatMode::Update(MainState& main)
{
	(void)main;
	// Avatar-on-screen leash runs after the late CameraUpdate in MainState so
	// pan input cannot push past the border for a frame and bounce.
}

void RealTimePauseCombatMode::HandleInput(MainState& main)
{
	if (!IsKeyPressed(KEY_SPACE))
		return;

	if (main.m_combatPaused)
		main.BeginCombatFighting();
	else
		main.PauseCombatForOrders();
}

void RealTimePauseCombatMode::DrawHud(MainState& main)
{
	Font* font = g_SmallFont ? g_SmallFont.get() : nullptr;
	if (!font)
		return;

	const bool paused = main.m_combatPaused;
	const std::string title = paused ? "PAUSED - Issue Orders" : "FIGHTING";
	const std::string hint = paused
		? "Space: fight   H: Hold   A: Auto   C/Esc: leave"
		: "Space: pause   C/Esc: leave";

	const float fontSize = static_cast<float>(font->baseSize);
	const float titleW = MeasureTextEx(*font, title.c_str(), fontSize, 1).x;
	const float hintW = MeasureTextEx(*font, hint.c_str(), fontSize, 1).x;
	const float boxW = std::max(titleW, hintW) + 24.0f;
	const float boxH = fontSize * 2.6f + 16.0f;
	const float boxX = (640.0f - boxW) * 0.5f;
	const float boxY = 8.0f;
	const Color accent = paused ? YELLOW : Color{ 220, 60, 60, 255 };

	DrawRectangle(static_cast<int>(boxX), static_cast<int>(boxY),
	              static_cast<int>(boxW), static_cast<int>(boxH),
	              Color{ 0, 0, 0, 160 });
	DrawRectangleLines(static_cast<int>(boxX), static_cast<int>(boxY),
	                   static_cast<int>(boxW), static_cast<int>(boxH), accent);

	DrawTextEx(*font, title.c_str(),
	           Vector2{ boxX + (boxW - titleW) * 0.5f, boxY + 6.0f },
	           fontSize, 1, accent);
	DrawTextEx(*font, hint.c_str(),
	           Vector2{ boxX + (boxW - hintW) * 0.5f, boxY + 6.0f + fontSize * 1.25f },
	           fontSize, 1, WHITE);

	if (paused && main.m_combatSelectedPartyMemberObjectId >= 0)
	{
		auto it = g_objectList.find(main.m_combatSelectedPartyMemberObjectId);
		if (it != g_objectList.end() && it->second)
		{
			const std::string sel = "Selected: " + it->second->m_name
				+ " - " + main.DescribeCombatOrder(it->second.get());
			const float selW = MeasureTextEx(*font, sel.c_str(), fontSize, 1).x;
			DrawTextEx(*font, sel.c_str(),
			           Vector2{ (640.0f - selW) * 0.5f, boxY + boxH + 4.0f },
			           fontSize, 1, SKYBLUE);
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
// Turn-Based (Gold Box / XCOM-style AP)
////////////////////////////////////////////////////////////////////////////////

bool TurnBasedCombatMode::IsSimulationPaused() const
{
	// Keep the global combat-pause gate closed so non-active units never run.
	// The active unit walks via ShouldUnitSimulate during Resolving.
	return true;
}

bool TurnBasedCombatMode::AllowsPlayerOrders() const
{
	if (m_phase != Phase::Planning)
		return false;
	U7Object* unit = GetActiveUnit();
	return unit && IsPartyUnit(unit) && IsLivingCombatant(unit);
}

bool TurnBasedCombatMode::ShouldUnitSimulate(const U7Object* unit) const
{
	if (!unit)
		return false;
	if (m_phase != Phase::Resolving)
		return false;
	return static_cast<int>(unit->m_ID) == m_activeUnitId;
}

bool TurnBasedCombatMode::IsLivingCombatant(const U7Object* obj) const
{
	if (!obj || obj->IsDeathStatus() || obj->m_hp <= 0.0f)
		return false;
	return true;
}

bool TurnBasedCombatMode::IsPartyUnit(const U7Object* obj) const
{
	if (!obj || !g_Player)
		return false;
	if (obj->m_UnitType != U7Object::UnitTypes::UNIT_TYPE_NPC)
		return false;
	return g_Player->NPCIDInParty(obj->m_NPCID);
}

bool TurnBasedCombatMode::IsTileOccupiedByOther(int tileX, int tileZ, int selfId) const
{
	if (!m_main)
		return false;
	for (int id : m_main->m_combatParticipants)
	{
		if (id == selfId)
			continue;
		auto it = g_objectList.find(id);
		if (it == g_objectList.end() || !it->second)
			continue;
		U7Object* o = it->second.get();
		if (!IsLivingCombatant(o))
			continue;
		const int ox = static_cast<int>(std::floor(o->m_Pos.x));
		const int oz = static_cast<int>(std::floor(o->m_Pos.z));
		if (ox == tileX && oz == tileZ)
			return true;
	}
	return false;
}

U7Object* TurnBasedCombatMode::GetActiveUnit() const
{
	if (m_activeUnitId < 0)
		return nullptr;
	auto it = g_objectList.find(m_activeUnitId);
	if (it == g_objectList.end() || !it->second)
		return nullptr;
	return it->second.get();
}

std::string TurnBasedCombatMode::UnitLabel(const U7Object* obj) const
{
	if (!obj)
		return "Unknown";
	if (!obj->m_name.empty())
		return obj->m_name;
	return IsPartyUnit(obj) ? "Party member" : "Enemy";
}

std::string TurnBasedCombatMode::FormatAp(float ap) const
{
	char buf[32];
	const float rounded = std::round(ap * 2.0f) / 2.0f;
	if (std::fabs(rounded - std::round(rounded)) < 0.01f)
		std::snprintf(buf, sizeof(buf), "%d", static_cast<int>(std::lround(rounded)));
	else
		std::snprintf(buf, sizeof(buf), "%.1f", static_cast<double>(rounded));
	return buf;
}

bool TurnBasedCombatMode::TrySpendAp(float cost)
{
	if (cost < 0.0f)
		return false;
	if (m_apRemaining + kApEpsilon < cost)
		return false;
	m_apRemaining -= cost;
	if (m_apRemaining < 0.0f)
		m_apRemaining = 0.0f;
	return true;
}

void TurnBasedCombatMode::LockCameraToActiveUnit()
{
	if (m_activeUnitId < 0)
		return;
	auto it = g_objectList.find(m_activeUnitId);
	if (it == g_objectList.end() || !it->second)
		return;

	g_cameraLockObjectId = m_activeUnitId;
	g_camera.target = it->second->m_Pos;
	g_CameraMoved = true;

	// Prefer a readable tactical zoom without unlocking.
	if (g_Engine)
	{
		const float farLimit = g_Engine->m_EngineConfig.GetNumber("camera_far_limit");
		const float prefer = std::min(farLimit, std::max(g_cameraDistance, 24.0f));
		g_cameraDistance = prefer;
	}
}

void TurnBasedCombatMode::ClearReachableTiles()
{
	m_reachTiles.clear();
}

const TurnBasedCombatMode::ReachTile* TurnBasedCombatMode::FindReachTile(int tileX, int tileZ) const
{
	for (const ReachTile& t : m_reachTiles)
	{
		if (t.x == tileX && t.z == tileZ)
			return &t;
	}
	return nullptr;
}

void TurnBasedCombatMode::ComputeReachableTiles(
	U7Object* unit, float maxAp, std::vector<ReachTile>& out) const
{
	out.clear();
	if (!unit || !g_pathfindingSystem)
		return;
	if (maxAp < 1.0f - kApEpsilon)
		return;

	const int startX = static_cast<int>(std::floor(unit->m_Pos.x));
	const int startZ = static_cast<int>(std::floor(unit->m_Pos.z));
	const float baseY = unit->m_Pos.y;
	const int selfId = static_cast<int>(unit->m_ID);

	auto pack = [](int x, int z) -> uint64_t {
		return (static_cast<uint64_t>(static_cast<uint32_t>(x)) << 32)
			| static_cast<uint32_t>(z);
	};

	struct Node
	{
		int x;
		int z;
		float cost;
		bool operator>(const Node& o) const { return cost > o.cost; }
	};

	std::priority_queue<Node, std::vector<Node>, std::greater<Node>> open;
	std::unordered_map<uint64_t, float> best;
	best.reserve(512);
	best[pack(startX, startZ)] = 0.0f;
	open.push(Node{ startX, startZ, 0.0f });

	static const int kDx[8] = { 1, -1, 0, 0, 1, 1, -1, -1 };
	static const int kDz[8] = { 0, 0, 1, -1, 1, -1, 1, -1 };

	while (!open.empty())
	{
		const Node cur = open.top();
		open.pop();

		const auto itBest = best.find(pack(cur.x, cur.z));
		if (itBest == best.end() || cur.cost > itBest->second + kApEpsilon)
			continue;

		for (int dir = 0; dir < 8; ++dir)
		{
			const int nx = cur.x + kDx[dir];
			const int nz = cur.z + kDz[dir];
			if (nx < 0 || nx >= 3072 || nz < 0 || nz >= 3072)
				continue;

			const Vector3 from{
				static_cast<float>(cur.x) + 0.5f, baseY, static_cast<float>(cur.z) + 0.5f };
			const Vector3 to{
				static_cast<float>(nx) + 0.5f, baseY, static_cast<float>(nz) + 0.5f };
			const float stepCost = CombatStepApCost(from, to);
			if (stepCost <= 0.0f)
				continue;

			const float newCost = cur.cost + stepCost;
			if (newCost > maxAp + kApEpsilon)
				continue;

			if (!g_pathfindingSystem->IsPositionWalkable(nx, nz, baseY, unit))
				continue;
			if (IsTileOccupiedByOther(nx, nz, selfId))
				continue;

			const uint64_t key = pack(nx, nz);
			auto it = best.find(key);
			if (it != best.end() && newCost + kApEpsilon >= it->second)
				continue;

			best[key] = newCost;
			open.push(Node{ nx, nz, newCost });
		}
	}

	out.reserve(best.size());
	for (const auto& [key, cost] : best)
	{
		if (cost <= kApEpsilon)
			continue; // skip standing tile
		ReachTile t;
		t.x = static_cast<int>(static_cast<uint32_t>(key >> 32));
		t.z = static_cast<int>(static_cast<uint32_t>(key & 0xffffffffu));
		t.cost = cost;
		t.apLeft = maxAp - cost;
		out.push_back(t);
	}
}

void TurnBasedCombatMode::RebuildReachableTiles()
{
	ClearReachableTiles();

	U7Object* unit = GetActiveUnit();
	if (!unit || !IsPartyUnit(unit) || m_phase != Phase::Planning)
		return;

	m_reachDrawY = unit->m_Pos.y + 0.05f;
	ComputeReachableTiles(unit, m_apRemaining, m_reachTiles);
}

void TurnBasedCombatMode::RebuildInitiative(MainState& main)
{
	struct Entry
	{
		int id = -1;
		int dex = 0;
		bool party = false;
	};
	std::vector<Entry> entries;
	entries.reserve(main.m_combatParticipants.size());

	for (int id : main.m_combatParticipants)
	{
		auto it = g_objectList.find(id);
		if (it == g_objectList.end() || !it->second)
			continue;
		U7Object* obj = it->second.get();
		if (!IsLivingCombatant(obj))
			continue;
		const bool party = IsPartyUnit(obj);
		if (!party && !IsHostileCombatUnit(obj))
			continue;
		entries.push_back(Entry{ id, GetCombatDexterity(obj), party });
	}

	std::stable_sort(entries.begin(), entries.end(), [](const Entry& a, const Entry& b) {
		if (a.dex != b.dex)
			return a.dex > b.dex;
		if (a.party != b.party)
			return a.party;
		return a.id < b.id;
	});

	m_initiative.clear();
	m_initiative.reserve(entries.size());
	for (const Entry& e : entries)
		m_initiative.push_back(e.id);

	m_initiativeIndex = 0;
	m_activeUnitId = -1;
	m_apRemaining = 0.0f;
	m_apBudget = 0.0f;
	m_phase = Phase::Planning;
	m_pendingMoveApCost = 0.0f;
	ClearReachableTiles();
}

void TurnBasedCombatMode::StartUnitTurn(MainState& main)
{
	m_phase = Phase::Planning;
	m_activeUnitId = -1;
	m_apRemaining = 0.0f;
	m_apBudget = 0.0f;
	m_pendingMoveApCost = 0.0f;
	m_enemyAiPending = false;
	m_endTurnAfterMove = false;
	m_resolveFrames = 0;
	ClearReachableTiles();

	if (m_initiative.empty())
	{
		AddConsoleString("No combatants left in initiative.", YELLOW);
		return;
	}

	if (m_initiativeIndex < 0 || m_initiativeIndex >= static_cast<int>(m_initiative.size()))
		m_initiativeIndex = 0;

	const int n = static_cast<int>(m_initiative.size());
	for (int attempt = 0; attempt < n; ++attempt)
	{
		const int idx = (m_initiativeIndex + attempt) % n;
		const int id = m_initiative[static_cast<size_t>(idx)];
		auto it = g_objectList.find(id);
		if (it == g_objectList.end() || !it->second || !IsLivingCombatant(it->second.get()))
			continue;

		U7Object* unit = it->second.get();
		m_initiativeIndex = idx;
		m_activeUnitId = id;
		m_apBudget = GetCombatTurnApBudget(unit);
		m_apRemaining = m_apBudget;
		LockCameraToActiveUnit();

		Log("TurnBased: start turn id=" + std::to_string(id)
			+ " dex=" + std::to_string(GetCombatDexterity(unit))
			+ " ap=" + FormatAp(m_apBudget)
			+ (IsPartyUnit(unit) ? " party" : " enemy"));

		if (IsPartyUnit(unit))
		{
			main.m_combatSelectedPartyMemberObjectId = id;
			RebuildReachableTiles();
			AddConsoleString(
				UnitLabel(unit) + "'s turn - AP " + FormatAp(m_apRemaining)
					+ "  [Click ground: Move   Space: End Turn]",
				SKYBLUE);
		}
		else
		{
			main.m_combatSelectedPartyMemberObjectId = -1;
			m_enemyAiPending = true;
			m_endTurnAfterMove = true;
			AddConsoleString(
				UnitLabel(unit) + "'s turn - AP " + FormatAp(m_apRemaining) + " (moving...)",
				ORANGE);
		}
		return;
	}

	m_activeUnitId = -1;
	AddConsoleString("No combatants left to act.", YELLOW);
}

void TurnBasedCombatMode::AdvanceToNextLiving(MainState& main)
{
	ClearReachableTiles();
	if (m_initiative.empty())
	{
		m_activeUnitId = -1;
		return;
	}

	const int n = static_cast<int>(m_initiative.size());
	const int start = m_initiativeIndex;
	for (int step = 0; step < n; ++step)
	{
		m_initiativeIndex = (start + 1 + step) % n;
		const int id = m_initiative[static_cast<size_t>(m_initiativeIndex)];
		auto it = g_objectList.find(id);
		if (it == g_objectList.end() || !it->second)
			continue;
		if (IsLivingCombatant(it->second.get()))
		{
			StartUnitTurn(main);
			return;
		}
	}

	m_activeUnitId = -1;
	m_apRemaining = 0.0f;
	AddConsoleString("Initiative empty - no living combatants.", YELLOW);
}

void TurnBasedCombatMode::EndActiveTurn()
{
	if (!m_main)
		return;

	U7Object* unit = GetActiveUnit();
	if (unit)
	{
		AddConsoleString(UnitLabel(unit) + " ends turn.", WHITE);
		m_main->StopCombatUnitActions(unit);
	}

	m_apRemaining = 0.0f;
	m_pendingMoveApCost = 0.0f;
	m_enemyAiPending = false;
	m_endTurnAfterMove = false;
	m_resolveFrames = 0;
	m_phase = Phase::Planning;
	ClearReachableTiles();
	AdvanceToNextLiving(*m_main);
}

bool TurnBasedCombatMode::BeginMoveToTile(U7Object* unit, int tileX, int tileZ, float spent)
{
	if (!unit || !g_pathfindingSystem)
		return false;
	if (!TrySpendAp(spent))
		return false;

	const Vector3 dest{
		static_cast<float>(tileX) + 0.5f,
		unit->m_Pos.y,
		static_cast<float>(tileZ) + 0.5f
	};

	const bool party = IsPartyUnit(unit);
	std::vector<Vector3> path = party
		? g_pathfindingSystem->FindFastPath(unit->m_Pos, dest, unit, PathCallerTag::AvatarParty)
		: g_pathfindingSystem->FindMonsterChasePath(unit->m_Pos, dest, unit);
	if (path.empty())
		path = g_pathfindingSystem->FindFastPath(unit->m_Pos, dest, unit, PathCallerTag::AvatarParty);
	if (path.empty())
		path = g_pathfindingSystem->FindMonsterChasePath(unit->m_Pos, dest, unit);

	if (path.empty())
	{
		m_apRemaining += spent; // refund
		return false;
	}

	m_pendingMoveApCost = spent;
	m_resolveFrames = 0;
	ClearReachableTiles();

	unit->m_target = 0;
	unit->m_combatSpellId = -1;
	unit->m_combatSpellTargetId = 0;
	unit->m_combatMoveOrder = true;
	unit->m_combatOrderMode = CombatOrderMode::Move;
	unit->ApplyPathWaypoints(std::move(path));

	// Path collapsed to "already there" — treat as finished immediately.
	if (!unit->m_isMoving && unit->m_pathWaypoints.empty() && !unit->m_pathfindingPending)
	{
		unit->m_combatMoveOrder = false;
		unit->m_combatOrderMode = CombatOrderMode::Hold;
		m_phase = Phase::Planning;
		m_pendingMoveApCost = 0.0f;
		AddConsoleString(
			UnitLabel(unit) + " steps in place (" + FormatAp(spent) + " AP) - "
				+ FormatAp(m_apRemaining) + " left.",
			party ? GREEN : ORANGE);
		return true; // caller may EndActiveTurn / rebuild; phase is Planning
	}

	m_phase = Phase::Resolving;

	AddConsoleString(
		UnitLabel(unit) + " moves (" + FormatAp(spent) + " AP) - "
			+ FormatAp(m_apRemaining) + " left.",
		party ? GREEN : ORANGE);
	return true;
}

bool TurnBasedCombatMode::TryIssueMoveTo(MainState& main, int tileX, int tileZ)
{
	(void)main;
	U7Object* unit = GetActiveUnit();
	if (!unit || !IsPartyUnit(unit) || m_phase != Phase::Planning)
		return false;

	const ReachTile* reach = FindReachTile(tileX, tileZ);
	if (!reach)
	{
		AddConsoleString("That tile is out of movement range.", YELLOW);
		return true;
	}

	// Charge the same cost the green/yellow overlay used (Dijkstra with 1/1.5 steps).
	if (!BeginMoveToTile(unit, tileX, tileZ, reach->cost))
	{
		AddConsoleString("No path to that tile.", YELLOW);
		return true;
	}
	if (m_phase == Phase::Planning)
		RebuildReachableTiles();
	return true;
}

U7Object* TurnBasedCombatMode::FindNearestPartyTarget(const U7Object* from) const
{
	if (!from || !g_Player)
		return nullptr;

	U7Object* best = nullptr;
	float bestDistSqr = 1.0e12f;
	for (int npcId : g_Player->GetPartyMemberIds())
	{
		auto itNpc = g_NPCData.find(npcId);
		if (itNpc == g_NPCData.end() || !itNpc->second)
			continue;
		auto itObj = g_objectList.find(itNpc->second->m_objectID);
		if (itObj == g_objectList.end() || !itObj->second)
			continue;
		U7Object* member = itObj->second.get();
		if (!IsLivingCombatant(member))
			continue;
		const float distSqr = Vector2DistanceSqr(
			{ from->m_Pos.x, from->m_Pos.z },
			{ member->m_Pos.x, member->m_Pos.z });
		if (distSqr < bestDistSqr)
		{
			bestDistSqr = distSqr;
			best = member;
		}
	}
	return best;
}

void TurnBasedCombatMode::RunEnemyTurnAi(MainState& main)
{
	m_enemyAiPending = false;

	U7Object* unit = GetActiveUnit();
	if (!unit || !IsLivingCombatant(unit))
	{
		EndActiveTurn();
		return;
	}
	if (IsPartyUnit(unit) || m_phase != Phase::Planning)
		return;

	U7Object* target = FindNearestPartyTarget(unit);
	if (!target)
	{
		AddConsoleString(UnitLabel(unit) + " finds no target.", ORANGE);
		EndActiveTurn();
		return;
	}

	std::vector<ReachTile> reach;
	ComputeReachableTiles(unit, m_apRemaining, reach);

	const float tx = target->m_Pos.x;
	const float tz = target->m_Pos.z;
	const int startX = static_cast<int>(std::floor(unit->m_Pos.x));
	const int startZ = static_cast<int>(std::floor(unit->m_Pos.z));

	auto distSqrToTarget = [&](int x, int z) -> float {
		const float cx = static_cast<float>(x) + 0.5f;
		const float cz = static_cast<float>(z) + 0.5f;
		const float dx = cx - tx;
		const float dz = cz - tz;
		return dx * dx + dz * dz;
	};

	int bestX = startX;
	int bestZ = startZ;
	float bestDist = distSqrToTarget(startX, startZ);
	float bestCost = 0.0f;

	for (const ReachTile& t : reach)
	{
		const float d = distSqrToTarget(t.x, t.z);
		if (d + 0.01f < bestDist
		    || (std::fabs(d - bestDist) <= 0.01f && t.cost + kApEpsilon < bestCost))
		{
			bestDist = d;
			bestCost = t.cost;
			bestX = t.x;
			bestZ = t.z;
		}
	}

	// Already as close as AP allows (or nowhere to walk).
	if (bestX == startX && bestZ == startZ)
	{
		AddConsoleString(UnitLabel(unit) + " holds position.", ORANGE);
		EndActiveTurn();
		return;
	}

	if (!BeginMoveToTile(unit, bestX, bestZ, bestCost))
	{
		AddConsoleString(UnitLabel(unit) + " cannot path closer.", ORANGE);
		EndActiveTurn();
		return;
	}

	// BeginMoveToTile may finish instantly (collapsed path) and leave Planning.
	if (m_phase == Phase::Planning)
	{
		EndActiveTurn();
		return;
	}
	(void)main;
}

void TurnBasedCombatMode::OnMoveResolved(MainState& main)
{
	U7Object* unit = GetActiveUnit();
	if (unit)
	{
		unit->m_combatMoveOrder = false;
		unit->m_combatOrderMode = CombatOrderMode::Hold;
		unit->SetDest(unit->GetPos());
		unit->m_isMoving = false;
	}

	m_pendingMoveApCost = 0.0f;
	m_phase = Phase::Planning;
	LockCameraToActiveUnit();

	if (m_endTurnAfterMove || (unit && !IsPartyUnit(unit)))
	{
		m_endTurnAfterMove = false;
		EndActiveTurn();
		return;
	}

	// Party: stay on this turn even at 0 AP so the player can End Turn (and later undo).
	RebuildReachableTiles();
	AddConsoleString(
		"AP remaining: " + FormatAp(m_apRemaining)
			+ "  [Space: End Turn]",
		SKYBLUE);
	(void)main;
}

void TurnBasedCombatMode::OnEnter(MainState& main)
{
	m_main = &main;
	m_wasCameraLocked = IsCameraLocked();
	main.m_combatPaused = true;
	main.m_combatSelectedPartyMemberObjectId = -1;
	m_pendingMoveApCost = 0.0f;
	ClearReachableTiles();

	RebuildInitiative(main);

	if (m_initiative.empty())
	{
		AddConsoleString("Turn-Based combat - no combatants enrolled.", YELLOW);
		AddConsoleString("Press C or Escape to leave.", WHITE);
	}
	else
	{
		AddConsoleString(
			"Turn-Based combat - initiative set ("
				+ std::to_string(m_initiative.size()) + " combatants).",
			YELLOW);
		AddConsoleString(
			"Green tiles: move and keep at least 3 AP for attack. Yellow: move only. Space: End Turn.",
			WHITE);
		StartUnitTurn(main);
	}

	Log("TurnBasedCombatMode::OnEnter initiative=" + std::to_string(m_initiative.size()));
}

void TurnBasedCombatMode::OnLeave(MainState& main)
{
	(void)main;
	ClearReachableTiles();
	if (m_wasCameraLocked)
		LockCameraToAvatar();
	else
		g_cameraLockObjectId = -1;
	m_main = nullptr;
	m_wasCameraLocked = false;
	m_initiative.clear();
	m_initiativeIndex = 0;
	m_activeUnitId = -1;
	m_apRemaining = 0.0f;
	m_apBudget = 0.0f;
	m_pendingMoveApCost = 0.0f;
	m_phase = Phase::Planning;
	Log("TurnBasedCombatMode::OnLeave");
}

void TurnBasedCombatMode::Update(MainState& main)
{
	if (m_phase == Phase::Planning && m_enemyAiPending)
	{
		RunEnemyTurnAi(main);
		// Enemy AI may have entered Resolving; fall through to drive movement.
	}

	if (m_phase != Phase::Resolving)
		return;

	U7Object* unit = GetActiveUnit();
	if (!unit || !IsLivingCombatant(unit))
	{
		m_phase = Phase::Planning;
		m_endTurnAfterMove = false;
		m_resolveFrames = 0;
		AdvanceToNextLiving(main);
		return;
	}

	// Drive the active unit here. Combat Update runs before the interest-sphere
	// object pass, and hostiles outside the party bubble would never walk otherwise.
	if (unit->m_combatMoveOrder || unit->m_combatOrderMode == CombatOrderMode::Move)
		unit->UpdateMovement();

	const bool arrived = !unit->m_isMoving
		&& unit->m_pathWaypoints.empty()
		&& !unit->m_pathfindingPending;
	if (arrived)
	{
		OnMoveResolved(main);
		return;
	}

	++m_resolveFrames;
	if (m_resolveFrames >= kResolveStuckFrames)
	{
		AddConsoleString(UnitLabel(unit) + " move timed out - ending action.", YELLOW);
		Log("TurnBased: resolve timeout id=" + std::to_string(m_activeUnitId)
			+ " moving=" + std::to_string(unit->m_isMoving ? 1 : 0)
			+ " waypoints=" + std::to_string(unit->m_pathWaypoints.size())
			+ " pending=" + std::to_string(unit->m_pathfindingPending ? 1 : 0));
		unit->m_pathWaypoints.clear();
		unit->m_currentWaypointIndex = 0;
		unit->m_pathfindingPending = false;
		unit->m_isMoving = false;
		unit->SetDest(unit->GetPos());
		OnMoveResolved(main);
	}
}

void TurnBasedCombatMode::HandleInput(MainState& main)
{
	if (!IsKeyPressed(KEY_SPACE))
		return;

	// Ignore Space while a move is resolving or an enemy is acting.
	if (m_phase == Phase::Resolving || m_enemyAiPending)
		return;

	U7Object* unit = GetActiveUnit();
	if (unit && !IsPartyUnit(unit))
		return; // enemy turns are automatic

	if (m_activeUnitId < 0)
	{
		RebuildInitiative(main);
		if (!m_initiative.empty())
			StartUnitTurn(main);
		return;
	}

	EndActiveTurn();
}

bool TurnBasedCombatMode::HandleOrdersClick(MainState& main)
{
	if (!AllowsPlayerOrders())
		return false;

	U7Object* unit = GetActiveUnit();
	if (!unit)
		return false;

	U7Object* clicked = g_objectUnderMousePointer;

	// Active unit / other party: keep selection on the active unit.
	if (clicked && IsPartyUnit(clicked))
	{
		if (static_cast<int>(clicked->m_ID) != m_activeUnitId)
			AddConsoleString("Only " + UnitLabel(unit) + " can act this turn.", YELLOW);
		main.m_combatSelectedPartyMemberObjectId = m_activeUnitId;
		return true;
	}

	if (clicked && main.IsCombatEnemyObject(clicked))
	{
		AddConsoleString("Attack coming next - click a highlighted tile to move for now.", YELLOW);
		return true;
	}

	const int tileX = static_cast<int>(std::floor(g_terrainUnderMousePointer.x));
	const int tileZ = static_cast<int>(std::floor(g_terrainUnderMousePointer.z));
	return TryIssueMoveTo(main, tileX, tileZ);
}

void TurnBasedCombatMode::DrawWorld(MainState& main)
{
	(void)main;
	if (m_phase != Phase::Planning || m_reachTiles.empty())
		return;

	const Color green = Color{ 40, 220, 90, 150 };
	const Color yellow = Color{ 240, 210, 40, 150 };

	rlDisableDepthMask();
	rlBegin(RL_TRIANGLES);
	for (const ReachTile& t : m_reachTiles)
	{
		const Color c = (t.apLeft + kApEpsilon >= kAttackApReserve) ? green : yellow;
		rlColor4ub(c.r, c.g, c.b, c.a);

		const float y = m_reachDrawY;
		const float x0 = static_cast<float>(t.x);
		const float z0 = static_cast<float>(t.z);
		const float x1 = x0 + 1.0f;
		const float z1 = z0 + 1.0f;

		rlVertex3f(x0, y, z0);
		rlVertex3f(x1, y, z0);
		rlVertex3f(x1, y, z1);

		rlVertex3f(x0, y, z0);
		rlVertex3f(x1, y, z1);
		rlVertex3f(x0, y, z1);
	}
	rlEnd();
	rlEnableDepthMask();

	// Destination ghost: 1-tile-high box, colored by reachability.
	if (g_mouseOverUI || (g_gumpManager && g_gumpManager->m_isMouseOverGump))
		return;

	const int hoverX = static_cast<int>(std::floor(g_terrainUnderMousePointer.x));
	const int hoverZ = static_cast<int>(std::floor(g_terrainUnderMousePointer.z));
	if (hoverX < 0 || hoverX >= 3072 || hoverZ < 0 || hoverZ >= 3072)
		return;

	Color boxColor = RED;
	if (const ReachTile* reach = FindReachTile(hoverX, hoverZ))
		boxColor = (reach->apLeft + kApEpsilon >= kAttackApReserve)
			? Color{ 40, 220, 90, 255 }
			: Color{ 240, 210, 40, 255 };

	BoundingBox box;
	box.min = Vector3{
		static_cast<float>(hoverX),
		m_reachDrawY - 0.05f,
		static_cast<float>(hoverZ)
	};
	box.max = Vector3{
		box.min.x + 1.0f,
		box.min.y + 1.0f,
		box.min.z + 1.0f
	};
	DrawBoundingBox(box, boxColor);
}

void TurnBasedCombatMode::DrawHud(MainState& main)
{
	(void)main;
	Font* font = g_SmallFont ? g_SmallFont.get() : nullptr;
	if (!font || !g_Engine)
		return;

	U7Object* unit = GetActiveUnit();
	std::string title;
	Color accent = YELLOW;
	if (m_phase == Phase::Resolving && unit)
	{
		title = std::string("MOVING - ") + UnitLabel(unit)
			+ "  AP " + FormatAp(m_apRemaining) + "/" + FormatAp(m_apBudget);
		accent = LIME;
	}
	else if (!unit)
	{
		title = "TURN - (none)";
	}
	else
	{
		const bool party = IsPartyUnit(unit);
		title = std::string("TURN - ") + UnitLabel(unit)
			+ "  AP " + FormatAp(m_apRemaining) + "/" + FormatAp(m_apBudget);
		accent = party ? SKYBLUE : ORANGE;
	}

	const std::string hint = (m_phase == Phase::Resolving)
		? "Moving...   C/Esc: leave"
		: "Click tile: Move   Space: End   C/Esc: leave";

	const float fontSize = static_cast<float>(font->baseSize);
	const float titleW = MeasureTextEx(*font, title.c_str(), fontSize, 1).x;
	const float hintW = MeasureTextEx(*font, hint.c_str(), fontSize, 1).x;
	const float padX = 10.0f;
	const float padY = 3.0f;
	const float lineGap = fontSize * 1.05f;
	const float boxW = std::max(titleW, hintW) + padX * 2.0f;
	const float boxH = padY * 2.0f + lineGap + fontSize;
	const float screenW = static_cast<float>(g_Engine->m_RenderWidth);
	const float screenH = static_cast<float>(g_Engine->m_RenderHeight);
	const float boxX = (screenW - boxW) * 0.5f;
	const float boxY = screenH - boxH - 6.0f;

	DrawRectangle(static_cast<int>(boxX), static_cast<int>(boxY),
	              static_cast<int>(boxW), static_cast<int>(boxH),
	              Color{ 0, 0, 0, 150 });
	DrawRectangleLines(static_cast<int>(boxX), static_cast<int>(boxY),
	                   static_cast<int>(boxW), static_cast<int>(boxH), accent);

	DrawTextEx(*font, title.c_str(),
	           Vector2{ boxX + (boxW - titleW) * 0.5f, boxY + padY },
	           fontSize, 1, accent);
	DrawTextEx(*font, hint.c_str(),
	           Vector2{ boxX + (boxW - hintW) * 0.5f, boxY + padY + lineGap },
	           fontSize, 1, WHITE);
}
