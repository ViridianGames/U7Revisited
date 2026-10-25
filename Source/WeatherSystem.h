///////////////////////////////////////////////////////////////////////////
// WeatherSystem — U7 weather state (IDs 0–6), precipitation, overcast tint,
// storm flash, world-space edge clouds, and MIDI weather beds.
// Storm phases mirror Black Gate weather.c (Weather_start / Weather_update).
///////////////////////////////////////////////////////////////////////////
#ifndef _WEATHERSYSTEM_H_
#define _WEATHERSYSTEM_H_

#include "raylib.h"
#include "../ThirdParty/nlohmann/json.hpp"
#include <cstdint>
#include <memory>
#include <string>
#include <vector>

enum class WeatherType : uint8_t
{
	Clear = 0,
	Snow = 1,
	Rain = 2,
	Sparkle = 3,
	Fog = 4,
	Overcast = 5,
	Cloudy = 6
};

enum class WeatherPhase : uint8_t
{
	Idle = 0,
	Burst = 1,
	Ramping = 2,
	Steady = 3,
	Stopping = 4,
	Finishing = 5
};

enum class WeatherIntensity : uint8_t
{
	Light = 0,
	Medium = 1,
	Heavy = 2
};

struct WeatherMusicProfile
{
	int musicRainTrack = 4;
	int musicSnowTrack = 5;
};

class WeatherSystem
{
public:
	static constexpr int kMaxParticles = 200;
	static constexpr int kTargetParticles = 90;   // Medium — leave headroom vs Heavy
	static constexpr int kLightParticles = 40;
	static constexpr int kHeavyParticles = 200;
	static constexpr int kPrecipSpriteShape = 0;
	// BG weather.c playEdgeSprite shape 1026 == FIRST_SPRITE(1024) + SPRITES.VGA #2.
	static constexpr int kCloudShapeId = 1026;
	static constexpr int kCloudSpriteShape = kCloudShapeId - 1024; // 2
	static constexpr int kMaxEdgeClouds = 16;
	static constexpr float kParticleDrawScale = 1.5f;
	static constexpr int kSparkleParticles = kMaxParticles / 6;
	static constexpr float kWeatherTickSeconds = 0.08f;
	static constexpr float kFogFadeSeconds = 3.5f;
	static constexpr float kFogIntensityBlendSeconds = 1.25f;
	static constexpr float kOvercastFadeSeconds = 1.5f;
	static constexpr float kCloudWorldSpeed = 4.0f; // world units / sec base
	static constexpr float kEdgeCloudFadeOutLife = 1.6f; // clamp when Stopping
	static constexpr float kPrecipFadeOutFallMul = 2.75f; // faster fall while Stopping/Finishing

	void Init();
	void Shutdown();

	void UpdateGameMinute();
	void Update(float dt);
	void Draw(Camera camera);

	void ApplyLightingModifiers(Color& dayNightColor, bool isDay) const;
	bool WantsOvercastPalette() const;
	bool WantsFogPalette() const;
	bool WantsCloudSprites() const;
	bool EffectsEnabled() const;
	bool IsAvatarSheltered() const; // dungeon ceiling or under building roof
	bool IsAntiMagic() const { return m_type == WeatherType::Sparkle; }

	int GetWeather() const { return static_cast<int>(m_type); }
	WeatherType GetWeatherType() const { return m_type; }
	WeatherPhase GetPhase() const { return m_phase; }
	WeatherIntensity GetIntensity() const { return m_intensity; }
	int GetRemainingMinutes() const { return m_remainingMinutes; }
	bool HasPendingWeather() const { return m_pending.active; }
	WeatherType GetPendingWeatherType() const { return m_pending.type; }

	const WeatherMusicProfile& GetMusicProfile() const { return m_music; }
	void SetMusicProfile(const WeatherMusicProfile& profile) { m_music = profile; }

	void SetWeather(int type, int durationMinutes = 0, bool fromEgg = false,
		Vector3 eggOrigin = { 0, 0, 0 }, int eggObjectId = -1, int intensity = -1);

	bool HasEggOrigin() const { return m_hasEggOrigin; }
	Vector3 GetEggOrigin() const { return m_eggOrigin; }
	int GetEggObjectId() const { return m_eggObjectId; }
	// Picker/Lua/Clear(255): blocks weather eggs until avatar walks ~48 tiles away.
	bool IsManualOverride() const { return m_manualOverride; }

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
		float animTimer = 0;
		bool forward = true;
		bool active = false;
	};

	struct EdgeCloud
	{
		float worldX = 0;
		float worldY = 0;
		float worldZ = 0;
		float vx = 0; // world X/sec
		float vz = 0; // world Z/sec
		int frame = 0;
		float life = 0;
		bool active = false;
	};

	struct PendingWeather
	{
		bool active = false;
		WeatherType type = WeatherType::Clear;
		WeatherIntensity intensity = WeatherIntensity::Medium;
		int durationMinutes = 0;
		bool fromEgg = false;
		Vector3 eggOrigin = { 0, 0, 0 };
		int eggObjectId = -1;
	};

	void ApplyType(WeatherType type, int durationMinutes, bool fromEgg,
		Vector3 eggOrigin, int eggObjectId, WeatherIntensity intensity);
	void ClearWeather(bool gradual);
	void FinishClear();
	void TryStartPending();
	void ConfigureEffectParams(WeatherType type, WeatherIntensity intensity);
	void ClearParticles();
	void ClearEdgeClouds();
	void ShortenEdgeCloudLives(float maxLifeSeconds);
	void UpdateParticles(float dt);
	void UpdateStormTick();
	void UpdateBlendFades(float dt);
	void TryAddParticle();
	void TrySpawnEdgeBurst(Camera camera);
	void UpdateEdgeClouds(float dt, Camera camera);
	void DrawEdgeClouds(Camera camera);
	int CountActiveParticles() const;
	int CountActiveEdgeClouds() const;
	bool VisualEffectsCleared() const;
	bool ShouldDrawPrecipitation() const;
	bool SpawnsPrecipParticles() const;
	void SyncWeatherMusic();
	void StopWeatherMusicIfPlaying();
	int ResolveMaxCount(WeatherType type, WeatherIntensity intensity) const;
	float ResolveFallSpeed(WeatherType type, WeatherIntensity intensity) const;
	int AvatarFacing8() const;
	bool TypeWantsOvercast(WeatherType type) const;
	bool IsFadingOut() const;

	WeatherType m_type = WeatherType::Clear;
	WeatherPhase m_phase = WeatherPhase::Idle;
	WeatherIntensity m_intensity = WeatherIntensity::Medium;
	int m_remainingMinutes = 0;
	bool m_hasEggOrigin = false;
	Vector3 m_eggOrigin = { 0, 0, 0 };
	int m_eggObjectId = -1;
	bool m_manualOverride = false;
	Vector3 m_manualOrigin = { 0, 0, 0 }; // avatar pos when manual SetWeather took ownership
	WeatherMusicProfile m_music;
	PendingWeather m_pending;

	int m_maxCount = 0;
	int m_targetCount = 0;
	int m_bursts = 0;
	int m_delay = 0;
	int m_direction = 0;
	int m_stormFlag = 0;
	float m_weatherTickAccum = 0;
	float m_fogFade = 0;
	float m_fogIntensityScale = 1.0f; // lerps toward Light/Med/Heavy fog density
	float m_overcastFade = 0;
	bool m_fogWasActive = false;

	float m_fallSpeed = 0;
	int m_firstFrame = 0;
	int m_frameCount = 0;
	bool m_useSplashes = false;
	int m_firstSplashFrame = 0;
	int m_splashFrames = 0;

	std::vector<Particle> m_particles;
	std::vector<EdgeCloud> m_edgeClouds;
	float m_spawnAccumulator = 0;
	float m_flashTimer = 0;
	float m_flashCooldown = 0;
	std::string m_activeWeatherMusicPath;

	// Last camera for storm ticks that spawn world clouds between Draws.
	Camera m_lastCamera = {};
	bool m_hasCamera = false;
};

extern std::unique_ptr<WeatherSystem> g_WeatherSystem;

#endif
