///////////////////////////////////////////////////////////////////////////
// WeatherSystem — U7 weather state (IDs 0–6), precipitation, overcast tint,
// storm flash, and MIDI weather beds.
///////////////////////////////////////////////////////////////////////////
#ifndef _WEATHERSYSTEM_H_
#define _WEATHERSYSTEM_H_

#include "raylib.h"
#include "../ThirdParty/nlohmann/json.hpp"
#include <cstdint>
#include <memory>
#include <string>
#include <vector>

// Canonical Black Gate / Exult weather IDs (usecode.uh / SetWeather).
enum class WeatherType : uint8_t
{
	Clear = 0,
	Snow = 1,
	Rain = 2,       // Storm / rain
	Sparkle = 3,    // Anti-magic; also indoors (visuals in PR D)
	Fog = 4,        // Visuals in PR D
	Overcast = 5,
	Cloudy = 6
};

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
	static constexpr int kMaxParticles = 200;      // Exult ceiling
	static constexpr int kTargetParticles = 125;   // Original BG target
	static constexpr int kPrecipSpriteShape = 0;   // SPRITES.VGA shape 0
	static constexpr int kCloudSpriteShape = 2;    // SPRITES.VGA shape 2

	void Init();
	void Shutdown();

	void UpdateGameMinute();
	void Update(float dt);
	void Draw(Camera camera);

	// Apply overcast/storm dim and lightning flash into the day/night tint.
	void ApplyLightingModifiers(Color& dayNightColor, bool isDay) const;
	bool WantsOvercastPalette() const;
	bool WantsCloudSprites() const;

	int GetWeather() const { return static_cast<int>(m_type); }
	WeatherType GetWeatherType() const { return m_type; }
	WeatherPhase GetPhase() const { return m_phase; }
	int GetRemainingMinutes() const { return m_remainingMinutes; }

	const WeatherMusicProfile& GetMusicProfile() const { return m_music; }
	void SetMusicProfile(const WeatherMusicProfile& profile) { m_music = profile; }

	void SetWeather(int type, int durationMinutes = 0, bool fromEgg = false,
		Vector3 eggOrigin = { 0, 0, 0 }, int eggObjectId = -1);

	bool HasEggOrigin() const { return m_hasEggOrigin; }
	Vector3 GetEggOrigin() const { return m_eggOrigin; }
	int GetEggObjectId() const { return m_eggObjectId; }

	void CheckEggDistanceCancel(Vector3 avatarPos, float maxDistanceTiles = 48.0f);

	nlohmann::json SaveToJson() const;
	void LoadFromJson(const nlohmann::json& j);

private:
	struct Particle
	{
		float x = 0;
		float y = 0;
		float endY = 0;
		int frame = 0;
		float splash = 0;
		bool active = false;
	};

	void ApplyType(WeatherType type, int durationMinutes, bool fromEgg,
		Vector3 eggOrigin, int eggObjectId);
	void ClearWeather(bool gradual);
	void ConfigureEffectParams(WeatherType type);
	void ClearParticles();
	void UpdateParticles(float dt);
	void TryAddParticle();
	bool ShouldDrawPrecipitation() const;
	void SyncWeatherMusic();
	void StopWeatherMusicIfPlaying();

	WeatherType m_type = WeatherType::Clear;
	WeatherPhase m_phase = WeatherPhase::Idle;
	int m_remainingMinutes = 0;
	bool m_hasEggOrigin = false;
	Vector3 m_eggOrigin = { 0, 0, 0 };
	int m_eggObjectId = -1;
	WeatherMusicProfile m_music;

	// Effect params (from original SetWeather)
	int m_maxCount = 0;
	float m_fallSpeed = 0;
	int m_firstFrame = 0;
	int m_frameCount = 0;
	bool m_useSplashes = false;
	int m_firstSplashFrame = 0;
	int m_splashFrames = 0;

	std::vector<Particle> m_particles;
	float m_spawnAccumulator = 0;
	float m_flashTimer = 0;
	float m_flashCooldown = 0;
	std::string m_activeWeatherMusicPath;
	int m_cloudFrame = 0;
	float m_cloudTimer = 0;
};

extern std::unique_ptr<WeatherSystem> g_WeatherSystem;

#endif
