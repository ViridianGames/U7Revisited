#include "WeatherSystem.h"
#include "Geist/Logging.h"
#include <algorithm>
#include <cmath>

std::unique_ptr<WeatherSystem> g_WeatherSystem;

void WeatherSystem::Init()
{
	m_type = WeatherType::Clear;
	m_phase = WeatherPhase::Idle;
	m_remainingMinutes = 0;
	m_hasEggOrigin = false;
	m_eggObjectId = -1;
	// Black Gate defaults; Serpent Isle would use 68/69 when that profile is active.
	m_music.musicRainTrack = 4;
	m_music.musicSnowTrack = 5;
}

void WeatherSystem::Shutdown()
{
	ClearWeather(false);
}

void WeatherSystem::UpdateGameMinute()
{
	if (m_type == WeatherType::Clear)
	{
		return;
	}

	if (m_remainingMinutes > 0)
	{
		--m_remainingMinutes;
		if (m_remainingMinutes <= 0)
		{
			// Duration elapsed → clear (original weather eggs send 255 after wait).
			ClearWeather(true);
		}
	}
}

void WeatherSystem::SetWeather(int type, int durationMinutes, bool fromEgg,
	Vector3 eggOrigin, int eggObjectId)
{
	if (type == 255)
	{
		ClearWeather(true);
		return;
	}

	if (type < 0 || type > 6)
	{
		Log("WeatherSystem::SetWeather: ignoring out-of-range type " + std::to_string(type));
		return;
	}

	ApplyType(static_cast<WeatherType>(type), durationMinutes, fromEgg, eggOrigin, eggObjectId);
}

void WeatherSystem::ApplyType(WeatherType type, int durationMinutes, bool fromEgg,
	Vector3 eggOrigin, int eggObjectId)
{
	// Rel Hur / usecode never clear sparkle via normal clear path; eggs may replace.
	if (type == WeatherType::Clear)
	{
		ClearWeather(false);
		return;
	}

	m_type = type;
	m_phase = WeatherPhase::Rising;

	int minutes = durationMinutes;
	if (minutes <= 0)
	{
		// Continuous egg: originals use a long wait (~6000 game minutes).
		minutes = 6000;
	}
	m_remainingMinutes = minutes;

	m_hasEggOrigin = fromEgg;
	m_eggOrigin = eggOrigin;
	m_eggObjectId = fromEgg ? eggObjectId : -1;

	// MIDI bed IDs are stored on the profile for PR C playback; do not play here.
}

void WeatherSystem::ClearWeather(bool gradual)
{
	(void)gradual;
	m_type = WeatherType::Clear;
	m_phase = gradual ? WeatherPhase::Stopping : WeatherPhase::Idle;
	m_remainingMinutes = 0;
	m_hasEggOrigin = false;
	m_eggObjectId = -1;
	if (!gradual)
	{
		m_phase = WeatherPhase::Idle;
	}
}

void WeatherSystem::CheckEggDistanceCancel(Vector3 avatarPos, float maxDistanceTiles)
{
	if (!m_hasEggOrigin || m_type == WeatherType::Clear)
	{
		return;
	}

	const float dx = avatarPos.x - m_eggOrigin.x;
	const float dz = avatarPos.z - m_eggOrigin.z;
	const float dist = std::sqrt(dx * dx + dz * dz);
	if (dist > maxDistanceTiles)
	{
		ClearWeather(true);
	}
}

nlohmann::json WeatherSystem::SaveToJson() const
{
	nlohmann::json j;
	j["type"] = static_cast<int>(m_type);
	j["phase"] = static_cast<int>(m_phase);
	j["remainingMinutes"] = m_remainingMinutes;
	j["hasEggOrigin"] = m_hasEggOrigin;
	j["eggObjectId"] = m_eggObjectId;
	j["eggOrigin"] = { m_eggOrigin.x, m_eggOrigin.y, m_eggOrigin.z };
	j["musicRainTrack"] = m_music.musicRainTrack;
	j["musicSnowTrack"] = m_music.musicSnowTrack;
	return j;
}

void WeatherSystem::LoadFromJson(const nlohmann::json& j)
{
	Init();
	if (j.is_null() || !j.is_object())
	{
		return;
	}

	const int type = j.value("type", 0);
	if (type >= 0 && type <= 6)
	{
		m_type = static_cast<WeatherType>(type);
	}
	const int phase = j.value("phase", 0);
	if (phase >= 0 && phase <= 4)
	{
		m_phase = static_cast<WeatherPhase>(phase);
	}
	m_remainingMinutes = j.value("remainingMinutes", 0);
	m_hasEggOrigin = j.value("hasEggOrigin", false);
	m_eggObjectId = j.value("eggObjectId", -1);
	if (j.contains("eggOrigin") && j["eggOrigin"].is_array() && j["eggOrigin"].size() >= 3)
	{
		m_eggOrigin.x = j["eggOrigin"][0].get<float>();
		m_eggOrigin.y = j["eggOrigin"][1].get<float>();
		m_eggOrigin.z = j["eggOrigin"][2].get<float>();
	}
	m_music.musicRainTrack = j.value("musicRainTrack", 4);
	m_music.musicSnowTrack = j.value("musicSnowTrack", 5);

	if (m_type == WeatherType::Clear)
	{
		m_phase = WeatherPhase::Idle;
		m_hasEggOrigin = false;
	}
}
