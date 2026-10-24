///////////////////////////////////////////////////////////////////////////
// WeatherSystem — U7 weather state (IDs 0–6). Visuals/MIDI playback land in
// later PRs; this module owns identity, duration, egg origin, and save data.
///////////////////////////////////////////////////////////////////////////
#ifndef _WEATHERSYSTEM_H_
#define _WEATHERSYSTEM_H_

#include "raylib.h"
#include "../ThirdParty/nlohmann/json.hpp"
#include <cstdint>
#include <memory>

// Canonical Black Gate / Exult weather IDs (usecode.uh / SetWeather).
enum class WeatherType : uint8_t
{
	Clear = 0,
	Snow = 1,
	Rain = 2,       // Storm / rain
	Sparkle = 3,    // Anti-magic; also indoors
	Fog = 4,
	Overcast = 5,
	Cloudy = 6
};

// Transition phase stub for future particle ramp (original weather.c).
enum class WeatherPhase : uint8_t
{
	Idle = 0,
	Rising = 1,
	Steady = 2,
	Falling = 3,
	Stopping = 4
};

struct WeatherMusicProfile
{
	// Mode-0 MIDI/XMI beds from original SetWeather (not melodic themes).
	int musicRainTrack = 4;   // BG; SI uses 68
	int musicSnowTrack = 5;   // BG; SI uses 69
};

class WeatherSystem
{
public:
	void Init();
	void Shutdown();

	// Advance timers by one game minute (call when g_minute ticks).
	void UpdateGameMinute();

	int GetWeather() const { return static_cast<int>(m_type); }
	WeatherType GetWeatherType() const { return m_type; }
	WeatherPhase GetPhase() const { return m_phase; }
	int GetRemainingMinutes() const { return m_remainingMinutes; }

	const WeatherMusicProfile& GetMusicProfile() const { return m_music; }
	void SetMusicProfile(const WeatherMusicProfile& profile) { m_music = profile; }

	// fromEgg: when true, stores origin for distance cancel (Exult egg weather).
	// durationMinutes: 0 means continuous (original → 6000 game minutes).
	// type 255: gradual clear (original itemcmd end-weather sentinel).
	void SetWeather(int type, int durationMinutes = 0, bool fromEgg = false,
		Vector3 eggOrigin = { 0, 0, 0 }, int eggObjectId = -1);

	bool HasEggOrigin() const { return m_hasEggOrigin; }
	Vector3 GetEggOrigin() const { return m_eggOrigin; }
	int GetEggObjectId() const { return m_eggObjectId; }

	// Distance cancel for egg-origin weather (Exult-style). Avatar world XZ.
	void CheckEggDistanceCancel(Vector3 avatarPos, float maxDistanceTiles = 48.0f);

	nlohmann::json SaveToJson() const;
	void LoadFromJson(const nlohmann::json& j);

private:
	void ApplyType(WeatherType type, int durationMinutes, bool fromEgg,
		Vector3 eggOrigin, int eggObjectId);
	void ClearWeather(bool gradual);

	WeatherType m_type = WeatherType::Clear;
	WeatherPhase m_phase = WeatherPhase::Idle;
	int m_remainingMinutes = 0;
	bool m_hasEggOrigin = false;
	Vector3 m_eggOrigin = { 0, 0, 0 };
	int m_eggObjectId = -1;
	WeatherMusicProfile m_music;
};

extern std::unique_ptr<WeatherSystem> g_WeatherSystem;

#endif
