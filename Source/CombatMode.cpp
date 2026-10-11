#include "CombatMode.h"
#include "MainState.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "U7Player.h"
#include "CombatState.h"
#include "Geist/Engine.h"
#include "Geist/Config.h"
#include "Geist/Logging.h"
#include "raylib.h"
#include "raymath.h"

#include <algorithm>
#include <cmath>
#include <string>

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
			std::string(GetDisplayName()) + " — coming soon. Press C or Escape to leave combat.",
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

	const std::string title = std::string(GetDisplayName()) + " — Coming Soon";
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

	AddConsoleString("Combat! Game is paused — issue orders, then press Space to fight.", YELLOW);
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
	const std::string title = paused ? "PAUSED — Issue Orders" : "FIGHTING";
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
				+ " — " + main.DescribeCombatOrder(it->second.get());
			const float selW = MeasureTextEx(*font, sel.c_str(), fontSize, 1).x;
			DrawTextEx(*font, sel.c_str(),
			           Vector2{ (640.0f - selW) * 0.5f, boxY + boxH + 4.0f },
			           fontSize, 1, SKYBLUE);
		}
	}
}
