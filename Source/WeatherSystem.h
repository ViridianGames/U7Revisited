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

// Wind strength — separate from precip density (WeatherIntensity).
enum class WeatherWindSpeed : uint8_t
{
	Off = 0,
	Light = 1,
	Medium = 2,
	Heavy = 3
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
	// High-band sky fluff (no ground shadow). Separate from edge shadow pool.
	static constexpr int kMaxSkyClouds = 12;
	static constexpr float kParticleDrawScale = 1.5f;
	static constexpr int kSparkleParticles = kMaxParticles / 6;
	static constexpr float kWeatherTickSeconds = 0.08f;
	static constexpr float kFogFadeSeconds = 3.5f;
	static constexpr float kFogIntensityBlendSeconds = 1.25f;
	static constexpr float kOvercastFadeSeconds = 1.5f;
	static constexpr float kCloudWorldSpeed = 4.0f; // world units / sec at Medium wind
	static constexpr float kSkyCloudSpeedMul = 1.45f; // high band vs low-band base
	static constexpr float kSkyCloudBaseY = 14.0f;
	static constexpr float kSkyCloudYSpan = 10.0f;
	static constexpr float kEdgeCloudFadeOutLife = 1.6f; // clamp when Stopping
	static constexpr float kPrecipFadeOutFallMul = 2.75f; // faster fall while Stopping/Finishing
	// Screen-space precip drift (pixels/sec) at Medium wind. Light/Heavy use
	// steeper multipliers in PrecipWindDriftPixels (stronger lean in Heavy).
	static constexpr float kPrecipWindDriftMedium = 95.0f;

	void Init();
	void Shutdown();

	void UpdateGameMinute();
	void Update(float dt);
	void Draw(Camera camera);
	// Mode3D backdrop: sky fill + high-band flat cloud quads.
	// Call after BeginMode3D, before terrain. ClearBackground with GetSkyClearColor first.
	// useHemisphereDome: MainState only. Title/Conversation use DrawGameWorldFrame with
	// default false (camera-facing panel) — dome previously broke menu GUI state.
	void DrawSkyLayer(Camera camera, bool useHemisphereDome = false);
	Color GetSkyClearColor() const; // horizon stop, or black if dungeon/effects off

	// Weather 10 celestial — orrery state 0..9; moonLightAmount 0..1 for night shadows.
	void SetOrreryState(int state); // snap; cancels in-flight anim
	void SetOrreryStateAnimated(int targetState, float durationSeconds);
	int GetOrreryState() const { return m_orreryState; } // logical destination once anim starts
	bool IsOrreryAnimating() const { return m_orreryAnimActive; }
	void RefreshOrreryStateFromFlags(); // cancel anim + snap from plot flags
	float GetMoonLightAmount() const;

	// Weather 10.3 sandbox: equal-time sun path markers (Ctrl+Shift+P).
	void SetDrawCelestialPathTrail(bool enabled) { m_drawCelestialPathTrail = enabled; }
	bool GetDrawCelestialPathTrail() const { return m_drawCelestialPathTrail; }
	void ToggleDrawCelestialPathTrail() { m_drawCelestialPathTrail = !m_drawCelestialPathTrail; }

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

	// Global wind: 0=N … 7=NW; speed 0=Off … 3=Heavy (not precip intensity).
	int GetWindDir() const { return m_windDir; }
	WeatherWindSpeed GetWindSpeed() const { return m_windSpeed; }
	void SetWeatherWind(int dir, int speed = -1); // speed -1 keeps current; 0–3 Off…Heavy
	// 0 Off / ~0.55 Light / 1 Med / ~1.45 Heavy — precip/clouds only (Off = 0).
	float WindSpeedScale(WeatherWindSpeed speed) const;
	// Flag cloth idle (shapes 222/232/248 only): Off uses ambient Light rate so
	// cloth keeps fluttering; L/M/H match WindSpeedScale.
	float FlagAnimSpeedScale() const;
	bool IsWindActive() const { return m_windSpeed != WeatherWindSpeed::Off; }

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

	// High-altitude sky fluff — Mode3D XZ quads only (no ground shadow).
	struct SkyCloud
	{
		float worldX = 0;
		float worldY = 0;
		float worldZ = 0;
		float vx = 0;
		float vz = 0;
		float size = 10.0f; // world-space quad width (X)
		int frame = 0;
		float life = 0;
		float maxLife = 0; // set at spawn; used for fade-in
		float alpha = 0.55f;
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
	void ClearSkyClouds();
	void ShortenEdgeCloudLives(float maxLifeSeconds);
	void ShortenSkyCloudLives(float maxLifeSeconds);
	void UpdateParticles(float dt);
	void UpdateStormTick();
	void UpdateBlendFades(float dt);
	void TryAddParticle();
	void TrySpawnEdgeBurst(Camera camera);
	void TrySpawnSkyCloud(Camera camera, bool clearAmbient);
	void UpdateEdgeClouds(float dt, Camera camera);
	void UpdateSkyClouds(float dt, Camera camera);
	// Weather 10.1 — one sky-color sample per frame for dome + moon silhouettes.
	struct SkyAtmosphereState
	{
		float dayAmount = 0.0f;
		float sunAz = 0.0f;
		float sunEl = 0.0f;
		Vector3 sunDir{ 0.0f, 1.0f, 0.0f };
		Color zenith{};
		Color mid{};
		Color horizon{};
		Color warmTint{ 255, 145, 70, 255 };
		float overcastFade = 0.0f;
	};
	SkyAtmosphereState BuildSkyAtmosphereState() const;
	static Color EvaluateSkyColor(Vector3 skyDirection, const SkyAtmosphereState& atm);

	void DrawSkyGradient(Camera camera) const;       // Title-safe camera-facing panel
	void DrawSkyHemisphere(Camera camera, const SkyAtmosphereState& atm) const;
	void DrawCelestialBodies(Camera camera, const SkyAtmosphereState& atm); // may clear orrery anim after e=1

	// Weather 10.2 Phase E — generic constellation system (data-driven)
	struct ConstellationStarRuntime
	{
		std::string id;
		float canvasX = 0.5f;
		float canvasY = 0.5f;
		float brightness = 1.0f;
		Color tint{ 235, 238, 255, 255 };
		Vector3 restDir{ 0.0f, 1.0f, 0.0f };
		float size = 0.16f;
		bool principal = false;
	};
	struct ConstellationRuntime
	{
		std::string id;
		std::string name;
		bool enabled = true;
		float aspectRatio = 1.0f;
		std::string poleStarId;
		float centerRA = 0.0f;
		float centerDec = 20.0f;
		float rotationDeg = 0.0f;
		float scaleDeg = 12.0f;
		bool mirrorX = false; // flip local U (left/right) after canvas offsets
		std::vector<ConstellationStarRuntime> stars;
	};
	struct ProceduralStarRuntime
	{
		Vector3 restDir{ 0.0f, 1.0f, 0.0f };
		Color tint{ 235, 238, 255, 255 };
		float mag = 0.55f;
		float size = 0.16f;
		float omega = 1.2f;
		float phase = 0.0f;
		float flickerAmt = 0.1f;
	};
	void LoadConstellations();
	void BuildConstellationDirections();
	void BuildProceduralStars();
	void DrawConstellations(Camera camera, float siderealDeg, float skyLum, float overcastDim,
		float drawCullEl, float timeSec) const;
	void DrawProceduralStars(Camera camera, float siderealDeg, float skyLum, float overcastDim,
		float drawCullEl, float timeSec) const;

	void DrawSkyCloudQuads() const;
	void DrawEdgeClouds(Camera camera);
	void GetSkyGradientColors(Color& zenith, Color& mid, Color& horizon) const;
	bool WantsOpenSky() const; // sky backdrop; false only if effects off or dungeon (houses OK)
	bool WantsSkyFluff() const;
	int CountActiveParticles() const;
	int CountActiveEdgeClouds() const;
	int CountActiveSkyClouds() const;
	bool VisualEffectsCleared() const;
	bool ShouldDrawPrecipitation() const;
	bool SpawnsPrecipParticles() const;
	void SyncWeatherMusic();
	void StopWeatherMusicIfPlaying();
	int ResolveMaxCount(WeatherType type, WeatherIntensity intensity) const;
	float ResolveFallSpeed(WeatherType type, WeatherIntensity intensity) const;
	float PrecipWindDriftPixels() const;
	float CloudWindWorldSpeed() const; // low-band / shadows (Off = slow ambient)
	float SkyCloudWindWorldSpeed() const; // high-band (Off = 0 / still)
	float WindUnitWX() const; // continuous yaw → world X (-1..1); N=0
	float WindUnitWZ() const; // continuous yaw → world Z; N=-1
	void UpdateWindYaw(float dt); // lerp m_windYawDeg toward m_windDir * 45
	void SeedWindFromAvatar(WeatherIntensity intensity);
	void RetargetEdgeCloudVelocities();
	void RetargetSkyCloudVelocities();
	void UpdateFlagCloth(float dt);
	bool WantsWindEffects() const;
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
	int m_direction = 0; // kept in sync with m_windDir for save compat / storm phases
	int m_windDir = 0;   // 0=N … 7=NW — discrete target (picker / Lua / seed)
	float m_windYawDeg = 0; // continuous degrees; lerps toward m_windDir * 45 (drives visuals)
	WeatherWindSpeed m_windSpeed = WeatherWindSpeed::Off;
	int m_stormFlag = 0;
	float m_weatherTickAccum = 0;
	float m_fogFade = 0;
	float m_fogIntensityScale = 1.0f; // lerps toward Light/Med/Heavy fog density
	float m_overcastFade = 0;
	bool m_fogWasActive = false;
	int m_orreryState = 0; // 0..9; default = no plot flags set (B0 / retail start = S0 spread)
	// Phase F — cinematic rest-frame blend (not saved; real-time elapsed vs Britannia tDays)
	bool m_orreryAnimActive = false;
	float m_orreryAnimDuration = 0.0f;
	float m_orreryAnimElapsed = 0.0f;
	Vector3 m_orreryAnimRestStart[8]{};
	bool m_drawCelestialPathTrail = false;

	float m_fallSpeed = 0;
	int m_firstFrame = 0;
	int m_frameCount = 0;
	bool m_useSplashes = false;
	int m_firstSplashFrame = 0;
	int m_splashFrames = 0;

	std::vector<Particle> m_particles;
	std::vector<EdgeCloud> m_edgeClouds;
	std::vector<SkyCloud> m_skyClouds;
	float m_spawnAccumulator = 0;
	float m_skySpawnAccumulator = 0;
	float m_flashTimer = 0;
	float m_flashCooldown = 0;
	std::string m_activeWeatherMusicPath;

	// Last camera for storm ticks that spawn world clouds between Draws.
	Camera m_lastCamera = {};
	bool m_hasCamera = false;

	std::vector<ConstellationRuntime> m_constellations;
	std::vector<ProceduralStarRuntime> m_proceduralStars;
};

extern std::unique_ptr<WeatherSystem> g_WeatherSystem;

#endif
