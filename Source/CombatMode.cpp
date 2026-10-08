#include "CombatMode.h"
#include "MainState.h"
#include "U7Globals.h"
#include "Geist/Engine.h"
#include "Geist/Config.h"
#include "Geist/Logging.h"
#include "raylib.h"
#include "raymath.h"

#include <algorithm>
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
