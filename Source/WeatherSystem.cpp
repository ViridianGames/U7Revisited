#include "WeatherSystem.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "U7Player.h"
#include "Geist/Logging.h"
#include "Geist/SoundSystem.h"
#include "Geist/Engine.h"
#include "Geist/Config.h"
#include "rlgl.h"
#include "raymath.h"
#include <algorithm>
#include <cmath>

std::unique_ptr<WeatherSystem> g_WeatherSystem;

namespace
{
	constexpr float kFlashDuration = 0.12f;
	// Daylight multiply at full overcast fade (1 = no dim). Lower = darker.
	// Was a flat 0.42 (~58% darker) — too heavy for light rain; now intensity-scaled and lighter overall.
	constexpr int kOvercastVeilAlpha = 55; // was 70; intensity scale applied on top
	constexpr float kFogDimR = 0.55f;
	constexpr float kFogDimG = 0.60f;
	constexpr float kFogDimB = 0.68f;
	constexpr int kFogVeilAlpha = 150;

	float FogIntensityScale(WeatherIntensity intensity)
	{
		switch (intensity)
		{
		case WeatherIntensity::Light:  return 0.55f;
		case WeatherIntensity::Heavy:  return 1.35f;
		case WeatherIntensity::Medium:
		default:                       return 1.0f;
		}
	}

	// Lighting multiply at full fade: Light drizzle barely dims; keep Heavy shy of old 0.42.
	float OvercastDimMultiplier(WeatherIntensity intensity)
	{
		switch (intensity)
		{
		case WeatherIntensity::Light:  return 0.90f; // ~10% darker
		case WeatherIntensity::Heavy:  return 0.70f; // ~30% darker (was 0.55 / flat 0.42)
		case WeatherIntensity::Medium:
		default:                       return 0.80f; // ~20% darker
		}
	}

	Color LerpSkyColor(Color a, Color b, float t)
	{
		t = std::clamp(t, 0.0f, 1.0f);
		return Color{
			static_cast<unsigned char>(a.r + (b.r - a.r) * t),
			static_cast<unsigned char>(a.g + (b.g - a.g) * t),
			static_cast<unsigned char>(a.b + (b.b - a.b) * t),
			static_cast<unsigned char>(a.a + (b.a - a.a) * t)
		};
	}

	Color ScaleSkyColor(Color c, float mul)
	{
		mul = std::clamp(mul, 0.0f, 1.5f);
		return Color{
			static_cast<unsigned char>(std::clamp(static_cast<int>(c.r * mul), 0, 255)),
			static_cast<unsigned char>(std::clamp(static_cast<int>(c.g * mul), 0, 255)),
			static_cast<unsigned char>(std::clamp(static_cast<int>(c.b * mul), 0, 255)),
			c.a
		};
	}

	float OvercastVeilScale(WeatherIntensity intensity)
	{
		switch (intensity)
		{
		case WeatherIntensity::Light:  return 0.40f;
		case WeatherIntensity::Heavy:  return 0.95f;
		case WeatherIntensity::Medium:
		default:                       return 0.65f;
		}
	}

	// Continuous wind uses WindUnitWX/WZ: 0° = N (-Z), wx=sin(yaw), wz=-cos(yaw).

	constexpr float kSkyCloudFadeInSec = 3.0f;
	constexpr float kDayNightNightFloor = 64.0f;
	constexpr float kDayNightDayCeil = 255.0f;

	// Continuous 0..1 day amount matching MainState's pre-modifier dusk/dawn ramp
	// on g_dayNightColor.b (hour 20: 255→64, hour 6: 64→255). Computed from
	// g_hour/g_minute so ApplyLightingModifiers (overcast/fog) on the global
	// color cannot collapse the sky toward night at midday.
	float SkyDayAmount()
	{
		float b = kDayNightDayCeil;
		if (g_hour == 20)
		{
			b = kDayNightDayCeil
				- (static_cast<float>(g_minute) / 60.0f) * (kDayNightDayCeil - kDayNightNightFloor);
		}
		else if (g_hour == 6)
		{
			b = kDayNightNightFloor
				+ (static_cast<float>(g_minute) / 60.0f) * (kDayNightDayCeil - kDayNightNightFloor);
		}
		else if (g_hour > 20 || g_hour < 6)
		{
			b = kDayNightNightFloor;
		}
		return std::clamp(
			(b - kDayNightNightFloor) / (kDayNightDayCeil - kDayNightNightFloor),
			0.0f,
			1.0f);
	}

	bool SkyFluffUsesStormTint(WeatherType type)
	{
		return type == WeatherType::Rain
			|| type == WeatherType::Snow
			|| type == WeatherType::Overcast;
	}

	void DrawTexturedXZQuad(const Texture2D& tex, Vector3 center, float halfX, float halfZ, Color tint)
	{
		if (tex.id == 0)
		{
			return;
		}
		const float y = center.y;
		rlSetTexture(tex.id);
		rlBegin(RL_QUADS);
		rlColor4ub(tint.r, tint.g, tint.b, tint.a);
		rlNormal3f(0.0f, 1.0f, 0.0f);
		rlTexCoord2f(0.0f, 1.0f);
		rlVertex3f(center.x - halfX, y, center.z - halfZ);
		rlTexCoord2f(0.0f, 0.0f);
		rlVertex3f(center.x - halfX, y, center.z + halfZ);
		rlTexCoord2f(1.0f, 0.0f);
		rlVertex3f(center.x + halfX, y, center.z + halfZ);
		rlTexCoord2f(1.0f, 1.0f);
		rlVertex3f(center.x + halfX, y, center.z - halfZ);
		rlEnd();
		rlSetTexture(0);
	}
}

void WeatherSystem::Init()
{
	m_type = WeatherType::Clear;
	m_phase = WeatherPhase::Idle;
	m_intensity = WeatherIntensity::Medium;
	m_remainingMinutes = 0;
	m_hasEggOrigin = false;
	m_eggObjectId = -1;
	m_manualOverride = false;
	m_manualOrigin = { 0, 0, 0 };
	m_pending = {};
	m_music.musicRainTrack = 4;
	m_music.musicSnowTrack = 5;
	m_particles.assign(kMaxParticles, Particle{});
	m_edgeClouds.assign(kMaxEdgeClouds, EdgeCloud{});
	m_skyClouds.assign(kMaxSkyClouds, SkyCloud{});
	ClearParticles();
	ClearEdgeClouds();
	ClearSkyClouds();
	m_spawnAccumulator = 0;
	m_skySpawnAccumulator = 0;
	m_flashTimer = 0;
	m_flashCooldown = 0;
	m_weatherTickAccum = 0;
	m_fogFade = 0;
	m_fogIntensityScale = 1.0f;
	m_overcastFade = 0;
	m_fogWasActive = false;
	m_targetCount = 0;
	m_bursts = 0;
	m_delay = 0;
	m_direction = 0;
	// Wind starts Off; picker / storm seed / Lua turn it on.
	m_windDir = 0;
	m_windYawDeg = 0;
	m_windSpeed = WeatherWindSpeed::Off;
	m_stormFlag = 0;
	m_hasCamera = false;
	StopWeatherMusicIfPlaying();
	ConfigureEffectParams(WeatherType::Clear, WeatherIntensity::Medium);
}

void WeatherSystem::Shutdown()
{
	m_pending = {};
	ClearWeather(false);
}

bool WeatherSystem::TypeWantsOvercast(WeatherType type) const
{
	return type == WeatherType::Snow
		|| type == WeatherType::Rain
		|| type == WeatherType::Overcast;
}

bool WeatherSystem::IsFadingOut() const
{
	return m_phase == WeatherPhase::Stopping || m_phase == WeatherPhase::Finishing;
}

bool WeatherSystem::SpawnsPrecipParticles() const
{
	return m_type == WeatherType::Rain
		|| m_type == WeatherType::Snow
		|| m_type == WeatherType::Sparkle;
}

void WeatherSystem::UpdateGameMinute()
{
	if (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle && !m_pending.active)
	{
		return;
	}

	if (m_remainingMinutes > 0 && !IsFadingOut())
	{
		--m_remainingMinutes;
		if (m_remainingMinutes <= 0)
		{
			// Do NOT wipe m_pending — picker/Lua may have queued an override.
			ClearWeather(true);
		}
	}
}

void WeatherSystem::SetWeather(int type, int durationMinutes, bool fromEgg,
	Vector3 eggOrigin, int eggObjectId, int intensity)
{
	auto takeManualOwnership = [this]() {
		m_manualOverride = true;
		m_hasEggOrigin = false;
		m_eggObjectId = -1;
		if (g_Player)
		{
			if (U7Object* avatar = g_Player->GetAvatarObject())
			{
				m_manualOrigin = avatar->m_Pos;
				return;
			}
		}
		m_manualOrigin = { 0, 0, 0 };
	};

	if (type == 255)
	{
		// Debug/Lua clear: own the clear so nearby weather eggs don't instantly re-hatch.
		takeManualOwnership();
		m_pending = {};
		ClearWeather(true);
		return;
	}

	if (type < 0 || type > 6)
	{
		Log("WeatherSystem::SetWeather: ignoring out-of-range type " + std::to_string(type));
		return;
	}

	WeatherIntensity inten = WeatherIntensity::Medium;
	if (intensity >= 0 && intensity <= 2)
	{
		inten = static_cast<WeatherIntensity>(intensity);
	}

	const WeatherType newType = static_cast<WeatherType>(type);

	if (fromEgg)
	{
		m_manualOverride = false;
	}
	else
	{
		takeManualOwnership();
	}

	// Sparkle snaps on/off (exclusive anti-magic field).
	if (newType == WeatherType::Sparkle || m_type == WeatherType::Sparkle)
	{
		m_pending = {};
		ApplyType(newType, durationMinutes, fromEgg, eggOrigin, eggObjectId, inten);
		return;
	}

	// Same type already running: rain/snow/fog retarget intensity; others keep as-is.
	if (m_type == newType && !IsFadingOut() && m_type != WeatherType::Clear)
	{
		m_remainingMinutes = (durationMinutes <= 0) ? 6000 : durationMinutes;
		if (fromEgg)
		{
			m_hasEggOrigin = true;
			m_eggOrigin = eggOrigin;
			m_eggObjectId = eggObjectId;
		}
		else
		{
			m_hasEggOrigin = false;
			m_eggObjectId = -1;
		}
		if (newType == WeatherType::Rain || newType == WeatherType::Snow || newType == WeatherType::Fog)
		{
			m_intensity = inten;
			ConfigureEffectParams(newType, inten);
			if (newType == WeatherType::Rain || newType == WeatherType::Snow)
			{
				if (m_phase == WeatherPhase::Steady)
				{
					m_targetCount = m_maxCount;
				}
				else if (m_targetCount > m_maxCount)
				{
					m_targetCount = m_maxCount;
				}
			}
		}
		return;
	}

	// Already idle/clear: start immediately (blend fades may still drain — OK to crossfade).
	if (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle)
	{
		m_pending = {};
		ApplyType(newType, durationMinutes, fromEgg, eggOrigin, eggObjectId, inten);
		return;
	}

	// Queue B, fade out A first. Manual pending must not carry egg origin.
	m_pending.active = true;
	m_pending.type = newType;
	m_pending.intensity = inten;
	m_pending.durationMinutes = durationMinutes;
	m_pending.fromEgg = fromEgg;
	m_pending.eggOrigin = fromEgg ? eggOrigin : Vector3{ 0, 0, 0 };
	m_pending.eggObjectId = fromEgg ? eggObjectId : -1;

	if (!IsFadingOut())
	{
		ClearWeather(true);
	}
}

int WeatherSystem::ResolveMaxCount(WeatherType type, WeatherIntensity intensity) const
{
	switch (type)
	{
	case WeatherType::Snow:
	case WeatherType::Rain:
		switch (intensity)
		{
		case WeatherIntensity::Light:  return kLightParticles;
		case WeatherIntensity::Heavy:  return kHeavyParticles;
		case WeatherIntensity::Medium:
		default:                       return kTargetParticles;
		}
	case WeatherType::Sparkle:
		return kSparkleParticles;
	case WeatherType::Overcast:
	case WeatherType::Cloudy:
		return 0; // edges + palette only; no precip particles
	default:
		return 0;
	}
}

float WeatherSystem::ResolveFallSpeed(WeatherType type, WeatherIntensity intensity) const
{
	float base = 0.0f;
	if (type == WeatherType::Rain)
	{
		base = 220.0f;
	}
	else if (type == WeatherType::Snow)
	{
		base = 40.0f;
	}
	else
	{
		return 0.0f;
	}

	switch (intensity)
	{
	case WeatherIntensity::Light:  return base * 0.70f;
	case WeatherIntensity::Heavy:  return base * 1.55f;
	case WeatherIntensity::Medium:
	default:                       return base;
	}
}

int WeatherSystem::AvatarFacing8() const
{
	if (!g_Player)
	{
		return GetRandomValue(0, 7);
	}
	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
	{
		return GetRandomValue(0, 7);
	}
	float deg = avatar->m_Angle;
	while (deg < 0.0f) deg += 360.0f;
	while (deg >= 360.0f) deg -= 360.0f;
	return static_cast<int>((deg + 22.5f) / 45.0f) % 8;
}

float WeatherSystem::WindSpeedScale(WeatherWindSpeed speed) const
{
	switch (speed)
	{
	case WeatherWindSpeed::Off:    return 0.0f;
	case WeatherWindSpeed::Light:  return 0.55f;
	case WeatherWindSpeed::Heavy:  return 1.45f;
	case WeatherWindSpeed::Medium:
	default:                       return 1.0f;
	}
}

float WeatherSystem::FlagAnimSpeedScale() const
{
	// Ambient breeze: Off still flutters at Light rate. Does not affect precip.
	if (m_windSpeed == WeatherWindSpeed::Off)
	{
		return WindSpeedScale(WeatherWindSpeed::Light);
	}
	return WindSpeedScale(m_windSpeed);
}

float WeatherSystem::PrecipWindDriftPixels() const
{
	// Steeper than WindSpeedScale so Heavy reads as a clear lean vs Light/Med.
	switch (m_windSpeed)
	{
	case WeatherWindSpeed::Off:    return 0.0f;
	case WeatherWindSpeed::Light:  return kPrecipWindDriftMedium * 0.75f;
	case WeatherWindSpeed::Heavy:  return kPrecipWindDriftMedium * 2.25f;
	case WeatherWindSpeed::Medium:
	default:                       return kPrecipWindDriftMedium;
	}
}

float WeatherSystem::CloudWindWorldSpeed() const
{
	// Low-band / ground shadows: Off still drifts slowly (plan).
	if (m_windSpeed == WeatherWindSpeed::Off)
	{
		return kCloudWorldSpeed * 0.28f;
	}
	return kCloudWorldSpeed * WindSpeedScale(m_windSpeed);
}

float WeatherSystem::SkyCloudWindWorldSpeed() const
{
	// High-band: Off = stationary; otherwise faster than low band.
	if (m_windSpeed == WeatherWindSpeed::Off)
	{
		return 0.0f;
	}
	return CloudWindWorldSpeed() * kSkyCloudSpeedMul;
}

float WeatherSystem::WindUnitWX() const
{
	// 0° = N (-Z): wx = sin(yaw), wz = -cos(yaw) — matches kDirWX/WZ octants.
	return std::sin(m_windYawDeg * DEG2RAD);
}

float WeatherSystem::WindUnitWZ() const
{
	return -std::cos(m_windYawDeg * DEG2RAD);
}

void WeatherSystem::UpdateWindYaw(float dt)
{
	const float target = static_cast<float>((m_windDir % 8 + 8) % 8) * 45.0f;
	float delta = target - m_windYawDeg;
	while (delta > 180.0f)
	{
		delta -= 360.0f;
	}
	while (delta < -180.0f)
	{
		delta += 360.0f;
	}
	// ~100°/s — a 45° picker step eases in under half a second.
	constexpr float kTurnDegPerSec = 100.0f;
	const float step = kTurnDegPerSec * dt;
	if (std::fabs(delta) <= step)
	{
		m_windYawDeg = target;
	}
	else
	{
		m_windYawDeg += (delta > 0.0f) ? step : -step;
	}
	while (m_windYawDeg < 0.0f)
	{
		m_windYawDeg += 360.0f;
	}
	while (m_windYawDeg >= 360.0f)
	{
		m_windYawDeg -= 360.0f;
	}
}

bool WeatherSystem::WantsWindEffects() const
{
	return m_type == WeatherType::Rain
		|| m_type == WeatherType::Snow
		|| m_type == WeatherType::Overcast
		|| m_type == WeatherType::Cloudy;
}

void WeatherSystem::SeedWindFromAvatar(WeatherIntensity intensity)
{
	m_windDir = (AvatarFacing8() + 3 + GetRandomValue(0, 2)) % 8;
	m_direction = m_windDir;
	// Do NOT snap m_windYawDeg — UpdateWindYaw lerps so flags, precip drift,
	// and edge clouds (WindUnitWX/WZ) ease into the new storm direction.
	// Map precip L/M/H (0–2) → wind Light/Medium/Heavy (1–3); never leave Off in a storm.
	m_windSpeed = static_cast<WeatherWindSpeed>(static_cast<int>(intensity) + 1);
}

void WeatherSystem::SetWeatherWind(int dir, int speed)
{
	m_windDir = ((dir % 8) + 8) % 8;
	m_direction = m_windDir;
	// m_windYawDeg lerps toward the new target in UpdateWindYaw — no snap.
	if (speed >= 0 && speed <= 3)
	{
		m_windSpeed = static_cast<WeatherWindSpeed>(speed);
	}
	RetargetEdgeCloudVelocities();
	RetargetSkyCloudVelocities();
}

void WeatherSystem::RetargetEdgeCloudVelocities()
{
	// Rebuild speed magnitude only. Heading stays with UpdateEdgeClouds, which
	// re-aims along the lerped m_windYawDeg every frame (no direction snap).
	for (EdgeCloud& c : m_edgeClouds)
	{
		if (!c.active)
		{
			continue;
		}
		const float use = CloudWindWorldSpeed()
			+ static_cast<float>(GetRandomValue(0, 30)) / 10.0f;
		const float mag = std::sqrt(c.vx * c.vx + c.vz * c.vz);
		if (mag < 0.01f)
		{
			c.vx = WindUnitWX() * use;
			c.vz = WindUnitWZ() * use;
		}
		else
		{
			c.vx = (c.vx / mag) * use;
			c.vz = (c.vz / mag) * use;
		}
	}
}

void WeatherSystem::UpdateFlagCloth(float dt)
{
	(void)dt;
	// Ambient breeze: flags follow wind outdoors even in Clear when speed != Off.
	// Precip/shadows stay gated by WantsWindEffects() elsewhere.
	if (IsAvatarSheltered() || !IsWindActive())
	{
		return;
	}

	// Cloth glTF extends along local +X. DrawModelEx Y-rot maps +X → (cos θ, 0, -sin θ).
	// Wind travel is (sin φ, 0, -cos φ) with φ = m_windYawDeg, so θ = 90° − φ aligns
	// the fabric with the same direction clouds/precip use (WindUnitWX/WZ).
	float angle = 90.0f - m_windYawDeg;
	while (angle < 0.0f)
	{
		angle += 360.0f;
	}
	while (angle >= 360.0f)
	{
		angle -= 360.0f;
	}

	for (U7Object* obj : g_sortedVisibleObjects)
	{
		if (!obj || !obj->m_shapeData || !obj->m_Visible || obj->m_isContained)
		{
			continue;
		}
		const int shape = obj->m_shapeData->GetShape();
		// Flag cloth only — mast (713) stays put.
		if (shape != 222 && shape != 232 && shape != 248)
		{
			continue;
		}
		obj->m_Angle = angle;
	}
}

void WeatherSystem::ConfigureEffectParams(WeatherType type, WeatherIntensity intensity)
{
	m_maxCount = ResolveMaxCount(type, intensity);
	m_fallSpeed = ResolveFallSpeed(type, intensity);
	m_firstFrame = 0;
	m_frameCount = 0;
	m_useSplashes = false;
	m_firstSplashFrame = 0;
	m_splashFrames = 0;

	switch (type)
	{
	case WeatherType::Snow:
		m_firstFrame = 13;
		m_frameCount = 8;
		// No splash: frames 21–27 are sparkle art and read as a sudden shrink/shape change.
		m_useSplashes = false;
		break;
	case WeatherType::Rain:
		m_firstFrame = 3;
		m_frameCount = 4;
		if (intensity != WeatherIntensity::Light)
		{
			m_useSplashes = true;
			m_firstSplashFrame = 7;
			m_splashFrames = 1;
		}
		break;
	case WeatherType::Sparkle:
		m_fallSpeed = 0;
		m_firstFrame = 21;
		m_frameCount = 7;
		break;
	default:
		break;
	}
}

void WeatherSystem::ApplyType(WeatherType type, int durationMinutes, bool fromEgg,
	Vector3 eggOrigin, int eggObjectId, WeatherIntensity intensity)
{
	if (type == WeatherType::Clear)
	{
		ClearWeather(false);
		return;
	}

	m_type = type;
	m_intensity = intensity;

	int minutes = durationMinutes;
	if (minutes <= 0)
	{
		minutes = 6000;
	}
	m_remainingMinutes = minutes;

	m_hasEggOrigin = fromEgg;
	m_eggOrigin = fromEgg ? eggOrigin : Vector3{ 0, 0, 0 };
	m_eggObjectId = fromEgg ? eggObjectId : -1;
	if (fromEgg)
	{
		m_manualOverride = false;
	}

	ConfigureEffectParams(type, intensity);
	ClearParticles();
	// Keep living edge clouds only if continuing storm look; otherwise clear.
	if (type == WeatherType::Fog || type == WeatherType::Sparkle)
	{
		ClearEdgeClouds();
	}
	m_spawnAccumulator = 0;
	m_flashTimer = 0;
	m_flashCooldown = GetRandomValue(2, 8) / 10.0f;
	m_weatherTickAccum = 0;

	const bool isStorm = (type == WeatherType::Rain || type == WeatherType::Snow
		|| type == WeatherType::Overcast || type == WeatherType::Cloudy);
	m_stormFlag = isStorm ? 2 : 0;
	m_targetCount = SpawnsPrecipParticles() ? (isStorm ? 1 : m_maxCount) : 0;
	m_bursts = 0;
	m_delay = (m_stormFlag * 25) / 2;
	if (isStorm)
	{
		SeedWindFromAvatar(intensity);
	}
	m_phase = m_stormFlag ? WeatherPhase::Burst : WeatherPhase::Ramping;

	if (type == WeatherType::Fog)
	{
		m_phase = WeatherPhase::Steady;
		m_delay = 0;
		m_targetCount = 0;
		m_fogWasActive = true;
		// Kick so the veil/dim read immediately; rest eases in over kFogFadeSeconds.
		if (m_fogFade < 0.28f)
		{
			m_fogFade = 0.28f;
		}
	}
	else if (type == WeatherType::Sparkle)
	{
		m_phase = WeatherPhase::Steady;
		m_targetCount = m_maxCount;
		m_delay = 0;
	}

	// Overcast dim/veil: kick early so day darkening is felt right away (Rain/Snow/Overcast).
	if (TypeWantsOvercast(type) && m_overcastFade < 0.35f)
	{
		m_overcastFade = 0.35f;
	}

	SyncWeatherMusic();
}

void WeatherSystem::ClearWeather(bool gradual)
{
	if (!gradual || (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle))
	{
		FinishClear();
		return;
	}

	// Sparkle snaps off — particles never drain via storm ticks.
	if (m_type == WeatherType::Sparkle)
	{
		FinishClear();
		return;
	}

	if (m_type == WeatherType::Fog)
	{
		m_fogWasActive = true;
		m_phase = WeatherPhase::Stopping;
		m_remainingMinutes = 0;
		return;
	}

	// Rain/Snow/Overcast/Cloudy: stop new spawns, let precip finish falling (sped up),
	// and let edge clouds expire quickly — never snap-clear clouds.
	// Sky fluff shortens too; Clear ambient may respawn light fluff after FinishClear.
	m_delay = 0;
	m_targetCount = 0;
	ShortenEdgeCloudLives(kEdgeCloudFadeOutLife);
	ShortenSkyCloudLives(kEdgeCloudFadeOutLife);
	m_phase = WeatherPhase::Stopping;
	m_remainingMinutes = 0;
}

void WeatherSystem::TryStartPending()
{
	if (!m_pending.active)
	{
		return;
	}
	if (!VisualEffectsCleared())
	{
		return;
	}

	PendingWeather p = m_pending;
	m_pending = {};
	ApplyType(p.type, p.durationMinutes, p.fromEgg, p.eggOrigin, p.eggObjectId, p.intensity);
}

void WeatherSystem::FinishClear()
{
	StopWeatherMusicIfPlaying();
	m_type = WeatherType::Clear;
	m_phase = WeatherPhase::Idle;
	m_remainingMinutes = 0;
	m_hasEggOrigin = false;
	m_eggObjectId = -1;
	m_targetCount = 0;
	m_bursts = 0;
	m_delay = 0;
	m_stormFlag = 0;
	ConfigureEffectParams(WeatherType::Clear, WeatherIntensity::Medium);
	ClearParticles();
	ClearEdgeClouds();
	// Keep high-band sky fluff into Clear; ambient spawn maintains a light layer.
	m_flashTimer = 0;

	// Keep fog/overcast blends decaying via UpdateBlendFades; then start pending.
	TryStartPending();
}

void WeatherSystem::ClearParticles()
{
	for (Particle& p : m_particles)
	{
		p = Particle{};
	}
}

void WeatherSystem::ClearEdgeClouds()
{
	for (EdgeCloud& c : m_edgeClouds)
	{
		c = EdgeCloud{};
	}
}

void WeatherSystem::ClearSkyClouds()
{
	for (SkyCloud& c : m_skyClouds)
	{
		c = SkyCloud{};
	}
}

void WeatherSystem::ShortenEdgeCloudLives(float maxLifeSeconds)
{
	for (EdgeCloud& c : m_edgeClouds)
	{
		if (c.active && c.life > maxLifeSeconds)
		{
			c.life = maxLifeSeconds;
		}
	}
}

void WeatherSystem::ShortenSkyCloudLives(float maxLifeSeconds)
{
	for (SkyCloud& c : m_skyClouds)
	{
		if (c.active && c.life > maxLifeSeconds)
		{
			c.life = maxLifeSeconds;
		}
	}
}

void WeatherSystem::RetargetSkyCloudVelocities()
{
	const float use = SkyCloudWindWorldSpeed();
	for (SkyCloud& c : m_skyClouds)
	{
		if (!c.active)
		{
			continue;
		}
		if (use < 0.01f)
		{
			c.vx = 0.0f;
			c.vz = 0.0f;
			continue;
		}
		const float jitter = static_cast<float>(GetRandomValue(0, 20)) / 10.0f;
		c.vx = WindUnitWX() * (use + jitter);
		c.vz = WindUnitWZ() * (use + jitter);
	}
}

void WeatherSystem::CheckEggDistanceCancel(Vector3 avatarPos, float maxDistanceTiles)
{
	// Manual picker/Lua weather: drop override once avatar walks away so eggs can hatch again.
	if (m_manualOverride)
	{
		const float mdx = avatarPos.x - m_manualOrigin.x;
		const float mdz = avatarPos.z - m_manualOrigin.z;
		if (std::sqrt(mdx * mdx + mdz * mdz) > maxDistanceTiles)
		{
			m_manualOverride = false;
		}
		return; // never cancel weather for egg distance while manual owns it
	}

	if (!m_hasEggOrigin || m_type == WeatherType::Clear)
	{
		return;
	}

	const float dx = avatarPos.x - m_eggOrigin.x;
	const float dz = avatarPos.z - m_eggOrigin.z;
	const float dist = std::sqrt(dx * dx + dz * dz);
	if (dist > maxDistanceTiles)
	{
		// Preserve a non-egg pending override (e.g. picker queued during egg weather).
		if (m_pending.active && !m_pending.fromEgg)
		{
			if (!IsFadingOut())
			{
				ClearWeather(true);
			}
			return;
		}
		m_pending = {};
		ClearWeather(true);
	}
}

bool WeatherSystem::EffectsEnabled() const
{
	if (!g_Engine)
	{
		return true;
	}
	return g_Engine->m_EngineConfig.GetNumber("weather_effects") >= 0.5f;
}

bool WeatherSystem::IsAvatarSheltered() const
{
	if (g_dungeonViewActive)
	{
		return true;
	}
	if (!g_pathfindingSystem || !g_Player)
	{
		return false;
	}
	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
	{
		return false;
	}
	const int ax = static_cast<int>(std::floor(avatar->m_Pos.x));
	const int az = static_cast<int>(std::floor(avatar->m_Pos.z));
	return g_pathfindingSystem->IsInteriorTile(ax, az);
}

bool WeatherSystem::WantsOvercastPalette() const
{
	return m_overcastFade > 0.01f;
}

bool WeatherSystem::WantsFogPalette() const
{
	return m_fogFade > 0.01f;
}

bool WeatherSystem::WantsCloudSprites() const
{
	return m_type == WeatherType::Overcast
		|| m_type == WeatherType::Cloudy
		|| m_type == WeatherType::Rain
		|| m_type == WeatherType::Snow
		|| CountActiveEdgeClouds() > 0;
}

bool WeatherSystem::WantsOpenSky() const
{
	return EffectsEnabled() && !IsAvatarSheltered();
}

bool WeatherSystem::WantsSkyFluff() const
{
	if (!WantsOpenSky())
	{
		return false;
	}
	// Clear gets light high fluff (no ground shadows). Storm types denser.
	return m_type == WeatherType::Clear
		|| m_type == WeatherType::Overcast
		|| m_type == WeatherType::Cloudy
		|| m_type == WeatherType::Rain
		|| m_type == WeatherType::Snow
		|| m_type == WeatherType::Fog
		|| CountActiveSkyClouds() > 0;
}

bool WeatherSystem::ShouldDrawPrecipitation() const
{
	if (!EffectsEnabled() || IsAvatarSheltered())
	{
		return false;
	}
	return m_type == WeatherType::Rain || m_type == WeatherType::Snow
		|| ((m_type == WeatherType::Clear || IsFadingOut())
			&& CountActiveParticles() > 0 && m_fallSpeed > 0.0f);
}

int WeatherSystem::CountActiveParticles() const
{
	int n = 0;
	for (const Particle& p : m_particles)
	{
		if (p.active)
		{
			++n;
		}
	}
	return n;
}

int WeatherSystem::CountActiveEdgeClouds() const
{
	int n = 0;
	for (const EdgeCloud& c : m_edgeClouds)
	{
		if (c.active)
		{
			++n;
		}
	}
	return n;
}

int WeatherSystem::CountActiveSkyClouds() const
{
	int n = 0;
	for (const SkyCloud& c : m_skyClouds)
	{
		if (c.active)
		{
			++n;
		}
	}
	return n;
}

bool WeatherSystem::VisualEffectsCleared() const
{
	// Blend fades (fog/overcast) may still drain — pending weather is allowed to crossfade.
	// Sky fluff is allowed to persist into Clear and does not block pending handoff.
	return CountActiveParticles() == 0
		&& CountActiveEdgeClouds() == 0;
}

void WeatherSystem::TryAddParticle()
{
	if (m_type != WeatherType::Sparkle)
	{
		if (!SpawnsPrecipParticles() || m_fallSpeed <= 0.0f)
		{
			return;
		}
	}

	const int active = CountActiveParticles();
	if (active >= m_targetCount || active >= m_maxCount || m_maxCount <= 0)
	{
		return;
	}

	int freeIndex = -1;
	for (int i = 0; i < static_cast<int>(m_particles.size()); ++i)
	{
		if (!m_particles[i].active)
		{
			freeIndex = i;
			break;
		}
	}
	if (freeIndex < 0)
	{
		return;
	}

	Particle& p = m_particles[freeIndex];
	p.active = true;
	p.splash = 0;
	p.animTimer = 0;
	p.forward = (GetRandomValue(0, 1) == 1);

	if (m_type == WeatherType::Sparkle)
	{
		p.x = static_cast<float>(GetRandomValue(0, 620));
		p.y = static_cast<float>(GetRandomValue(0, 340));
		p.endY = p.y;
		p.frame = m_firstFrame + GetRandomValue(0, std::max(0, m_frameCount - 1));
	}
	else
	{
		p.x = static_cast<float>(GetRandomValue(-40, 680));
		p.y = static_cast<float>(GetRandomValue(-40, 20));
		p.endY = static_cast<float>(GetRandomValue(120, 380));
		p.frame = 0;
	}
}

void WeatherSystem::TrySpawnEdgeBurst(Camera camera)
{
	// Keep spawning while sheltered — outdoor weather continues; Draw hides it indoors.
	if (m_delay == 0 || !WantsCloudSprites())
	{
		return;
	}
	if (IsFadingOut())
	{
		return;
	}

	int chance = 75;
	if (m_phase == WeatherPhase::Burst)
	{
		chance = m_delay;
	}
	else if (m_phase == WeatherPhase::Stopping)
	{
		chance = 9999;
	}

	if (GetRandomValue(0, std::max(1, chance) - 1) != 0)
	{
		return;
	}

	const int count = GetRandomValue(1, 3);
	const auto& clouds = g_spriteTable[kCloudSpriteShape];
	if (clouds.empty())
	{
		++m_bursts;
		return;
	}

	const float speed = CloudWindWorldSpeed() + static_cast<float>(GetRandomValue(0, 30)) / 10.0f;
	const float wx = WindUnitWX();
	const float wz = WindUnitWZ();
	const float vx = wx * speed;
	const float vz = wz * speed;

	const Vector3 center = camera.target;
	const float spawnDist = 28.0f + static_cast<float>(GetRandomValue(0, 12));
	// Incoming side = opposite travel direction.
	const float inX = center.x - wx * spawnDist;
	const float inZ = center.z - wz * spawnDist;
	// Sit near ground — these are cloud *shadows* on the terrain, not sky billboards.
	const float baseY = 0.12f;

	for (int n = 0; n < count; ++n)
	{
		int slot = -1;
		for (int i = 0; i < static_cast<int>(m_edgeClouds.size()); ++i)
		{
			if (!m_edgeClouds[i].active)
			{
				slot = i;
				break;
			}
		}
		if (slot < 0)
		{
			break;
		}

		const float lateral = static_cast<float>(GetRandomValue(-14, 14));
		// Perpendicular in XZ: (-vz, vx) normalized-ish.
		float px = -vz;
		float pz = vx;
		const float plen = std::sqrt(px * px + pz * pz);
		if (plen > 0.01f)
		{
			px = px / plen * lateral;
			pz = pz / plen * lateral;
		}
		else
		{
			px = lateral;
			pz = 0;
		}

		EdgeCloud& c = m_edgeClouds[slot];
		c.active = true;
		c.frame = GetRandomValue(0, static_cast<int>(clouds.size()) - 1);
		c.vx = vx;
		c.vz = vz;
		c.life = 10.0f + static_cast<float>(GetRandomValue(0, 50)) / 10.0f;
		c.worldX = inX + px;
		c.worldZ = inZ + pz;
		c.worldY = baseY + static_cast<float>(GetRandomValue(0, 8)) / 100.0f;
	}

	++m_bursts;
}

void WeatherSystem::UpdateEdgeClouds(float dt, Camera camera)
{
	const Vector3 center = camera.target;
	const float wx = WindUnitWX();
	const float wz = WindUnitWZ();
	for (EdgeCloud& c : m_edgeClouds)
	{
		if (!c.active)
		{
			continue;
		}
		// Re-aim along continuous wind yaw; keep each cloud's speed magnitude.
		float mag = std::sqrt(c.vx * c.vx + c.vz * c.vz);
		if (mag < 0.1f)
		{
			mag = CloudWindWorldSpeed();
		}
		c.vx = wx * mag;
		c.vz = wz * mag;
		c.worldX += c.vx * dt;
		c.worldZ += c.vz * dt;
		c.life -= dt;
		const float dx = c.worldX - center.x;
		const float dz = c.worldZ - center.z;
		const float dist = std::sqrt(dx * dx + dz * dz);
		if (c.life <= 0.0f || dist > 80.0f)
		{
			c.active = false;
		}
	}
}

void WeatherSystem::TrySpawnSkyCloud(Camera camera, bool clearAmbient)
{
	if (!WantsSkyFluff() || IsFadingOut())
	{
		return;
	}
	if (clearAmbient && m_type != WeatherType::Clear)
	{
		return;
	}
	if (!clearAmbient && m_type == WeatherType::Clear)
	{
		return;
	}

	const auto& clouds = g_spriteTable[kCloudSpriteShape];
	if (clouds.empty())
	{
		return;
	}

	const int active = CountActiveSkyClouds();
	const int softCap = clearAmbient ? 4 : kMaxSkyClouds;
	if (active >= softCap)
	{
		return;
	}

	int slot = -1;
	for (int i = 0; i < static_cast<int>(m_skyClouds.size()); ++i)
	{
		if (!m_skyClouds[i].active)
		{
			slot = i;
			break;
		}
	}
	if (slot < 0)
	{
		return;
	}

	const float wx = WindUnitWX();
	const float wz = WindUnitWZ();
	const float speed = SkyCloudWindWorldSpeed()
		+ ((m_windSpeed == WeatherWindSpeed::Off)
			? 0.0f
			: static_cast<float>(GetRandomValue(0, 25)) / 10.0f);
	const Vector3 center = camera.target;
	const float spawnDist = 32.0f + static_cast<float>(GetRandomValue(0, 18));
	const float inX = center.x - wx * spawnDist;
	const float inZ = center.z - wz * spawnDist;
	const float lateral = static_cast<float>(GetRandomValue(-18, 18));
	float px = -wz;
	float pz = wx;
	const float plen = std::sqrt(px * px + pz * pz);
	if (plen > 0.01f)
	{
		px = px / plen * lateral;
		pz = pz / plen * lateral;
	}
	else
	{
		px = lateral;
		pz = 0.0f;
	}

	const float heightT = static_cast<float>(GetRandomValue(0, 100)) / 100.0f;
	SkyCloud& c = m_skyClouds[slot];
	c.active = true;
	c.frame = GetRandomValue(0, static_cast<int>(clouds.size()) - 1);
	c.vx = wx * speed;
	c.vz = wz * speed;
	c.life = clearAmbient
		? (18.0f + static_cast<float>(GetRandomValue(0, 80)) / 10.0f)
		: (12.0f + static_cast<float>(GetRandomValue(0, 60)) / 10.0f);
	c.maxLife = c.life;
	c.worldX = inX + px;
	c.worldZ = inZ + pz;
	c.worldY = kSkyCloudBaseY + heightT * kSkyCloudYSpan;
	c.size = 9.0f + static_cast<float>(GetRandomValue(0, 70)) / 10.0f;
	c.alpha = clearAmbient ? 0.35f : (0.50f + static_cast<float>(GetRandomValue(0, 25)) / 100.0f);
}

void WeatherSystem::UpdateSkyClouds(float dt, Camera camera)
{
	const Vector3 center = camera.target;
	const float wx = WindUnitWX();
	const float wz = WindUnitWZ();
	const float baseSpeed = SkyCloudWindWorldSpeed();
	for (SkyCloud& c : m_skyClouds)
	{
		if (!c.active)
		{
			continue;
		}
		if (baseSpeed < 0.01f)
		{
			c.vx = 0.0f;
			c.vz = 0.0f;
		}
		else
		{
			float mag = std::sqrt(c.vx * c.vx + c.vz * c.vz);
			if (mag < 0.1f)
			{
				mag = baseSpeed;
			}
			c.vx = wx * mag;
			c.vz = wz * mag;
		}
		c.worldX += c.vx * dt;
		c.worldZ += c.vz * dt;
		c.life -= dt;
		const float dx = c.worldX - center.x;
		const float dz = c.worldZ - center.z;
		const float dist = std::sqrt(dx * dx + dz * dz);
		if (c.life <= 0.0f || dist > 95.0f)
		{
			c.active = false;
		}
	}
}

void WeatherSystem::UpdateStormTick()
{
	if (m_type == WeatherType::Clear || m_type == WeatherType::Fog || m_type == WeatherType::Sparkle)
	{
		return;
	}

	switch (m_phase)
	{
	case WeatherPhase::Burst:
		if (!(m_bursts < 3 && m_delay != 0))
		{
			m_phase = WeatherPhase::Ramping;
		}
		break;
	case WeatherPhase::Ramping:
		if (m_targetCount >= m_maxCount)
		{
			m_phase = WeatherPhase::Steady;
		}
		else if (SpawnsPrecipParticles())
		{
			++m_targetCount;
		}
		else
		{
			m_phase = WeatherPhase::Steady;
		}
		break;
	case WeatherPhase::Steady:
		break;
	case WeatherPhase::Stopping:
		m_delay = 0;
		// Drain targetCount quickly so we don't linger in Stopping for Heavy storms.
		if (m_targetCount <= 0)
		{
			m_phase = WeatherPhase::Finishing;
		}
		else
		{
			m_targetCount = std::max(0, m_targetCount - 20);
		}
		break;
	case WeatherPhase::Finishing:
		if (CountActiveParticles() <= 0 && CountActiveEdgeClouds() <= 0)
		{
			FinishClear();
			return;
		}
		break;
	default:
		break;
	}

	if (SpawnsPrecipParticles()
		&& (m_phase == WeatherPhase::Burst || m_phase == WeatherPhase::Ramping
			|| m_phase == WeatherPhase::Steady))
	{
		int newParticles = GetRandomValue(1, 12);
		while (newParticles > 0 && CountActiveParticles() < m_targetCount)
		{
			TryAddParticle();
			--newParticles;
		}
	}

	if (m_delay != 0 && m_hasCamera && WantsCloudSprites() && !IsFadingOut())
	{
		TrySpawnEdgeBurst(m_lastCamera);
	}

	// Storm sky fluff — denser than Clear ambient (spawned from Update).
	if (m_hasCamera && WantsSkyFluff() && !IsFadingOut() && m_type != WeatherType::Clear)
	{
		if (GetRandomValue(0, 4) == 0)
		{
			TrySpawnSkyCloud(m_lastCamera, false);
		}
	}
}

void WeatherSystem::UpdateParticles(float dt)
{
	constexpr float kSparkleFrameSeconds = 0.08f;
	const int sparkleLast = m_firstFrame + m_frameCount - 1;

	for (Particle& p : m_particles)
	{
		if (!p.active)
		{
			continue;
		}

		// Safety: non-sparkle zero-speed orphans (Overcast leftover).
		if (m_type != WeatherType::Sparkle && m_fallSpeed <= 0.0f && p.splash <= 0.0f)
		{
			p.active = false;
			continue;
		}

		if (p.splash > 0)
		{
			p.splash -= dt * 12.0f;
			if (p.splash <= 0)
			{
				p.active = false;
			}
			continue;
		}

		if (m_type == WeatherType::Sparkle && m_fallSpeed <= 0.0f)
		{
			p.animTimer += dt;
			while (p.animTimer >= kSparkleFrameSeconds)
			{
				p.animTimer -= kSparkleFrameSeconds;
				if (p.forward)
				{
					++p.frame;
					if (p.frame >= sparkleLast)
					{
						p.frame = sparkleLast;
						p.forward = false;
						p.x = static_cast<float>(GetRandomValue(0, 620));
						p.y = static_cast<float>(GetRandomValue(0, 340));
						p.frame = m_firstFrame + GetRandomValue(0, std::max(0, m_frameCount - 1));
						p.forward = (GetRandomValue(0, 1) == 1);
					}
				}
				else
				{
					--p.frame;
					if (p.frame <= m_firstFrame)
					{
						p.frame = m_firstFrame;
						p.forward = true;
					}
				}
			}
			continue;
		}

		const float fallMul = IsFadingOut() ? kPrecipFadeOutFallMul : 1.0f;
		p.y += m_fallSpeed * fallMul * dt;
		// Screen-space wind drift: project world wind through the camera so streaks
		// travel the same way edge-cloud shadows move on screen (and match flags).
		if (WantsWindEffects() && m_fallSpeed > 0.0f)
		{
			const float drift = PrecipWindDriftPixels() * dt;
			float dx = 0.0f;
			float dy = 0.0f;
			if (m_hasCamera)
			{
				const Vector3 origin = m_lastCamera.target;
				const Vector3 tip = {
					origin.x + WindUnitWX(),
					origin.y,
					origin.z + WindUnitWZ()
				};
				const Vector2 s0 = GetWorldToScreen(origin, m_lastCamera);
				const Vector2 s1 = GetWorldToScreen(tip, m_lastCamera);
				dx = s1.x - s0.x;
				dy = s1.y - s0.y;
				extern float g_DrawScale;
				if (g_DrawScale > 0.0f)
				{
					dx /= g_DrawScale;
					dy /= g_DrawScale;
				}
				const float len = std::sqrt(dx * dx + dy * dy);
				if (len > 0.01f)
				{
					dx /= len;
					dy /= len;
				}
				else
				{
					dx = 1.0f;
					dy = 0.0f;
				}
			}
			else
			{
				// No camera yet — crude fallback (same basis as before).
				dx = -(WindUnitWX() * 0.75f - WindUnitWZ() * 0.35f);
				dy = 0.0f;
			}
			p.x += dx * drift;
			p.y += dy * drift;
			if (p.x < -40.0f)
			{
				p.x += 700.0f;
			}
			else if (p.x > 660.0f)
			{
				p.x -= 700.0f;
			}
		}
		if (m_frameCount > 0)
		{
			p.frame = (p.frame + 1) % m_frameCount;
		}

		if (p.y >= p.endY)
		{
			// Skip splash during fade-out so precip clears faster for pending weather.
			if (m_useSplashes && m_splashFrames > 0 && !IsFadingOut())
			{
				p.splash = static_cast<float>(m_splashFrames);
			}
			else
			{
				p.active = false;
			}
		}
	}
}

void WeatherSystem::UpdateBlendFades(float dt)
{
	const bool fogOn = (m_type == WeatherType::Fog && !IsFadingOut());
	const float fogTarget = fogOn ? 1.0f : 0.0f;
	if (fogOn)
	{
		m_fogWasActive = true;
	}
	const float fogStep = dt / kFogFadeSeconds;
	if (m_fogFade < fogTarget)
	{
		m_fogFade = std::min(fogTarget, m_fogFade + fogStep);
	}
	else if (m_fogFade > fogTarget)
	{
		m_fogFade = std::max(fogTarget, m_fogFade - fogStep);
	}
	if (m_fogFade < 0.01f)
	{
		m_fogFade = 0;
		if (!fogOn)
		{
			m_fogWasActive = false;
		}
	}

	// Smooth Light/Medium/Heavy fog density (veil + dim) — no instant snaps.
	{
		const float intenTarget = (fogOn || m_fogFade > 0.01f)
			? FogIntensityScale(m_intensity)
			: 1.0f;
		const float intenStep = dt / kFogIntensityBlendSeconds;
		if (m_fogIntensityScale < intenTarget)
		{
			m_fogIntensityScale = std::min(intenTarget, m_fogIntensityScale + intenStep);
		}
		else if (m_fogIntensityScale > intenTarget)
		{
			m_fogIntensityScale = std::max(intenTarget, m_fogIntensityScale - intenStep);
		}
	}

	const bool overOn = TypeWantsOvercast(m_type) && !IsFadingOut() && m_type != WeatherType::Clear;
	const float overTarget = overOn ? 1.0f : 0.0f;
	const float overStep = dt / kOvercastFadeSeconds;
	if (m_overcastFade < overTarget)
	{
		m_overcastFade = std::min(overTarget, m_overcastFade + overStep);
	}
	else if (m_overcastFade > overTarget)
	{
		m_overcastFade = std::max(overTarget, m_overcastFade - overStep);
	}
	if (m_overcastFade < 0.01f)
	{
		m_overcastFade = 0;
	}

	// Fog-only stop: finish when veil drained.
	if (m_type == WeatherType::Fog && IsFadingOut() && m_fogFade < 0.02f)
	{
		FinishClear();
	}
	else if (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle && m_pending.active)
	{
		TryStartPending();
	}
}

void WeatherSystem::Update(float dt)
{
	UpdateWindYaw(dt);
	UpdateBlendFades(dt);
	UpdateFlagCloth(dt);

	if (!EffectsEnabled())
	{
		return;
	}

	if (m_hasCamera)
	{
		UpdateEdgeClouds(dt, m_lastCamera);
		UpdateSkyClouds(dt, m_lastCamera);

		// Clear / Fog ambient high fluff (no ground shadows for Clear).
		if (WantsSkyFluff() && !IsFadingOut()
			&& (m_type == WeatherType::Clear || m_type == WeatherType::Fog)
			&& (m_phase == WeatherPhase::Idle || m_phase == WeatherPhase::Steady
				|| m_phase == WeatherPhase::Ramping || m_phase == WeatherPhase::Burst))
		{
			m_skySpawnAccumulator += dt;
			const float interval = (m_type == WeatherType::Fog) ? 1.4f : 2.2f;
			if (m_skySpawnAccumulator >= interval)
			{
				m_skySpawnAccumulator = 0.0f;
				if (GetRandomValue(0, 2) == 0)
				{
					TrySpawnSkyCloud(m_lastCamera, m_type == WeatherType::Clear);
				}
			}
		}
	}

	if (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle)
	{
		return;
	}

	if (m_type == WeatherType::Sparkle)
	{
		if (IsFadingOut())
		{
			FinishClear();
			return;
		}
		if (m_phase == WeatherPhase::Steady)
		{
			m_spawnAccumulator += dt * static_cast<float>(m_maxCount) * 0.35f;
			while (m_spawnAccumulator >= 1.0f)
			{
				m_spawnAccumulator -= 1.0f;
				m_targetCount = m_maxCount;
				TryAddParticle();
			}
		}
		UpdateParticles(dt);
		return;
	}

	if (m_type == WeatherType::Fog)
	{
		return;
	}

	m_weatherTickAccum += dt;
	while (m_weatherTickAccum >= kWeatherTickSeconds)
	{
		m_weatherTickAccum -= kWeatherTickSeconds;
		UpdateStormTick();
		if (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle)
		{
			break;
		}
	}

	UpdateParticles(dt);

	// Exult Lightning_effect: flash+SFX 62 when not in dungeon (no day/night gate).
	// U7R: suppress in dungeon only; night storms may thunder.
	if (m_type == WeatherType::Rain && !g_dungeonViewActive && !IsFadingOut())
	{
		if (m_flashTimer > 0)
		{
			m_flashTimer -= dt;
		}
		else
		{
			m_flashCooldown -= dt;
			if (m_flashCooldown <= 0)
			{
				if (GetRandomValue(0, 100) < 8)
				{
					m_flashTimer = kFlashDuration;
					if (g_SoundSystem)
					{
						g_SoundSystem->PlaySound(BuildU7SfxPath(62));
					}
				}
				m_flashCooldown = GetRandomValue(15, 45) / 10.0f;
			}
		}
	}
	else if (m_type != WeatherType::Rain || g_dungeonViewActive)
	{
		m_flashTimer = 0;
	}
}

void WeatherSystem::ApplyLightingModifiers(Color& dayNightColor, bool isDay) const
{
	if (!EffectsEnabled() || IsAvatarSheltered())
	{
		return;
	}

	// Overcast dim is a daytime sky look; fog applies day or night so Fog picker is visible.
	// Rain/Snow intensity (and Overcast/Cloudy via current m_intensity) scales how dark it gets.
	if (isDay && m_overcastFade > 0.01f)
	{
		const float t = m_overcastFade;
		const float floor = OvercastDimMultiplier(m_intensity);
		const float dim = 1.0f - (1.0f - floor) * t;
		dayNightColor.r = static_cast<unsigned char>(dayNightColor.r * dim);
		dayNightColor.g = static_cast<unsigned char>(dayNightColor.g * dim);
		dayNightColor.b = static_cast<unsigned char>(dayNightColor.b * dim);
	}

	if (m_fogFade > 0.01f)
	{
		const float t = m_fogFade * m_fogIntensityScale;
		const float dimR = 1.0f - (1.0f - kFogDimR) * std::min(1.0f, t);
		const float dimG = 1.0f - (1.0f - kFogDimG) * std::min(1.0f, t);
		const float dimB = 1.0f - (1.0f - kFogDimB) * std::min(1.0f, t);
		dayNightColor.r = static_cast<unsigned char>(dayNightColor.r * dimR);
		dayNightColor.g = static_cast<unsigned char>(dayNightColor.g * dimG);
		dayNightColor.b = static_cast<unsigned char>(dayNightColor.b * dimB);
	}

	// Flash may fire at night too (Exult); still skip when sheltered so indoor view stays calm.
	if (m_flashTimer > 0)
	{
		dayNightColor = { 255, 255, 255, 255 };
	}
}

void WeatherSystem::GetSkyGradientColors(Color& zenith, Color& mid, Color& horizon) const
{
	// Base sky stops — day blue vs night indigo. Lerp by continuous dayAmount so
	// dusk (hour 20) and dawn (hour 6) match MainState's lighting ramp (no g_isDay snap).
	// Do NOT multiply stops by g_dayNightColor RGB: that already includes
	// ApplyLightingModifiers (overcast/fog) and would double-dim.
	const Color dayZenith = { 70, 125, 205, 255 };
	const Color dayMid = { 130, 175, 220, 255 };
	const Color dayHorizon = { 175, 200, 225, 255 };
	const Color nightZenith = { 6, 8, 22, 255 };
	const Color nightMid = { 14, 18, 40, 255 };
	const Color nightHorizon = { 24, 28, 50, 255 };

	const float dayAmount = SkyDayAmount();
	zenith = LerpSkyColor(nightZenith, dayZenith, dayAmount);
	mid = LerpSkyColor(nightMid, dayMid, dayAmount);
	horizon = LerpSkyColor(nightHorizon, dayHorizon, dayAmount);

	// Overcast darkening scaled by dayAmount (fades out at night) — not gated on g_isDay.
	if (m_overcastFade > 0.01f && dayAmount > 0.01f)
	{
		const float floor = OvercastDimMultiplier(m_intensity);
		const float dim = 1.0f - (1.0f - floor) * m_overcastFade * dayAmount;
		zenith = ScaleSkyColor(zenith, dim * 0.92f);
		mid = ScaleSkyColor(mid, dim);
		horizon = ScaleSkyColor(horizon, dim * 1.02f);
	}

	// FP is inside fog — pull sky toward the veil tone.
	if (m_fogFade > 0.01f)
	{
		const float t = std::min(1.0f, m_fogFade * m_fogIntensityScale);
		const Color fogCol = { 220, 225, 230, 255 };
		zenith = LerpSkyColor(zenith, fogCol, t * 0.85f);
		mid = LerpSkyColor(mid, fogCol, t * 0.90f);
		horizon = LerpSkyColor(horizon, fogCol, t * 0.95f);
	}

	if (m_flashTimer > 0)
	{
		zenith = { 255, 255, 255, 255 };
		mid = { 255, 255, 255, 255 };
		horizon = { 240, 245, 255, 255 };
	}
}

Color WeatherSystem::GetSkyClearColor() const
{
	if (!WantsOpenSky())
	{
		return Color{ 0, 0, 0, 255 };
	}
	Color zenith{}, mid{}, horizon{};
	GetSkyGradientColors(zenith, mid, horizon);
	return horizon;
}

void WeatherSystem::DrawSkyGradient(Camera camera) const
{
	Color zenith{}, mid{}, horizon{};
	GetSkyGradientColors(zenith, mid, horizon);

	Vector3 forward = Vector3Subtract(camera.target, camera.position);
	if (Vector3LengthSqr(forward) < 0.0001f)
	{
		forward = { 0.0f, 0.0f, -1.0f };
	}
	else
	{
		forward = Vector3Normalize(forward);
	}

	Vector3 right = Vector3CrossProduct(forward, camera.up);
	if (Vector3LengthSqr(right) < 0.0001f)
	{
		right = Vector3CrossProduct(forward, Vector3{ 0.0f, 0.0f, 1.0f });
	}
	if (Vector3LengthSqr(right) < 0.0001f)
	{
		right = { 1.0f, 0.0f, 0.0f };
	}
	else
	{
		right = Vector3Normalize(right);
	}
	Vector3 up = Vector3Normalize(Vector3CrossProduct(right, forward));

	// Large camera-facing panel just inside a typical far plane so look-up is sky.
	constexpr float kDist = 70.0f;
	constexpr float kHalfW = 110.0f;
	constexpr float kHalfH = 90.0f;
	const Vector3 center = Vector3Add(camera.position, Vector3Scale(forward, kDist));

	auto corner = [&](float u, float v) {
		return Vector3Add(center,
			Vector3Add(Vector3Scale(right, u * kHalfW), Vector3Scale(up, v * kHalfH)));
	};

	const Vector3 topL = corner(-1.0f, 1.0f);
	const Vector3 topR = corner(1.0f, 1.0f);
	const Vector3 midL = corner(-1.0f, 0.15f);
	const Vector3 midR = corner(1.0f, 0.15f);
	const Vector3 botL = corner(-1.0f, -1.0f);
	const Vector3 botR = corner(1.0f, -1.0f);

	rlDisableDepthTest();
	rlDisableDepthMask();
	rlBegin(RL_TRIANGLES);

	auto tri = [](Vector3 a, Color ca, Vector3 b, Color cb, Vector3 c, Color cc) {
		rlColor4ub(ca.r, ca.g, ca.b, 255);
		rlVertex3f(a.x, a.y, a.z);
		rlColor4ub(cb.r, cb.g, cb.b, 255);
		rlVertex3f(b.x, b.y, b.z);
		rlColor4ub(cc.r, cc.g, cc.b, 255);
		rlVertex3f(c.x, c.y, c.z);
	};

	// Upper band: zenith → mid
	tri(topL, zenith, topR, zenith, midR, mid);
	tri(topL, zenith, midR, mid, midL, mid);
	// Lower band: mid → horizon
	tri(midL, mid, midR, mid, botR, horizon);
	tri(midL, mid, botR, horizon, botL, horizon);

	rlEnd();
	rlEnableDepthMask();
	rlEnableDepthTest();
}

void WeatherSystem::DrawSkyCloudQuads() const
{
	if (CountActiveSkyClouds() == 0)
	{
		return;
	}

	const auto& clouds = g_spriteTable[kCloudSpriteShape];
	if (clouds.empty())
	{
		return;
	}

	// Same continuous dayAmount as sky gradient (dusk + dawn). Soft night floor so
	// fluff stays readable; Clear stays bright, storm band darker gray.
	const float dayAmount = SkyDayAmount();
	const float shade = 0.75f + 0.25f * dayAmount;
	const bool stormTint = SkyFluffUsesStormTint(m_type);
	const float baseR = stormTint ? 130.0f : 245.0f;
	const float baseG = stormTint ? 135.0f : 245.0f;
	const float baseB = stormTint ? 145.0f : 250.0f;
	const unsigned char tr = static_cast<unsigned char>(std::clamp(static_cast<int>(baseR * shade), 0, 255));
	const unsigned char tg = static_cast<unsigned char>(std::clamp(static_cast<int>(baseG * shade), 0, 255));
	const unsigned char tb = static_cast<unsigned char>(std::clamp(static_cast<int>(baseB * shade), 0, 255));

	rlDisableDepthMask();
	BeginShaderMode(g_alphaDiscard);
	BeginBlendMode(BLEND_ALPHA);

	for (const SkyCloud& c : m_skyClouds)
	{
		if (!c.active)
		{
			continue;
		}
		const int idx = c.frame % static_cast<int>(clouds.size());
		const SpriteFrame& cloud = clouds[idx];
		if (cloud.texture.id == 0)
		{
			continue;
		}

		const float age = std::max(0.0f, c.maxLife - c.life);
		const float fadeIn = std::min(1.0f, age / kSkyCloudFadeInSec);
		const float fadeOut = std::min(1.0f, c.life * 0.25f);
		const unsigned char a = static_cast<unsigned char>(
			std::clamp(static_cast<int>(255.0f * c.alpha * fadeIn * fadeOut), 0, 220));
		const Color tint = { tr, tg, tb, a };
		const float aspect = (cloud.height > 0)
			? (static_cast<float>(cloud.width) / static_cast<float>(cloud.height))
			: 1.5f;
		const float halfX = c.size * 0.5f;
		const float halfZ = (c.size / std::max(0.35f, aspect)) * 0.5f;
		DrawTexturedXZQuad(
			cloud.texture,
			Vector3{ c.worldX, c.worldY, c.worldZ },
			halfX,
			halfZ,
			tint);
	}

	EndBlendMode();
	EndShaderMode();
	rlEnableDepthMask();
}

void WeatherSystem::DrawSkyLayer(Camera camera)
{
	m_lastCamera = camera;
	m_hasCamera = true;

	if (!WantsOpenSky())
	{
		return;
	}

	DrawSkyGradient(camera);
	if (WantsSkyFluff() || CountActiveSkyClouds() > 0)
	{
		DrawSkyCloudQuads();
	}
}

void WeatherSystem::DrawEdgeClouds(Camera camera)
{
	if (IsAvatarSheltered() || CountActiveEdgeClouds() == 0)
	{
		return;
	}

	// Night blots read as crawling fog on dark ground — hide/fade with dayAmount.
	// Weather 10/11 will replace this gate with moonLightAmount.
	const float dayAmount = SkyDayAmount();
	if (dayAmount < 0.05f)
	{
		return;
	}

	const auto& clouds = g_spriteTable[kCloudSpriteShape];
	if (clouds.empty())
	{
		return;
	}

	extern float g_DrawScale;

	for (const EdgeCloud& c : m_edgeClouds)
	{
		if (!c.active)
		{
			continue;
		}
		const int idx = c.frame % static_cast<int>(clouds.size());
		const SpriteFrame& cloud = clouds[idx];
		if (cloud.texture.id == 0)
		{
			continue;
		}

		Vector3 worldPos = { c.worldX, c.worldY, c.worldZ };
		Vector2 screenPos = GetWorldToScreen(worldPos, camera);
		Vector2 screenPosRight = GetWorldToScreen(
			Vector3{ c.worldX + 1.0f, c.worldY, c.worldZ }, camera);
		float pixelsPerUnit = Vector2Distance(screenPos, screenPosRight);
		if (pixelsPerUnit < 1.0f)
		{
			pixelsPerUnit = 1.0f;
		}
		if (g_DrawScale > 0.0f)
		{
			screenPos.x /= g_DrawScale;
			screenPos.y /= g_DrawScale;
			pixelsPerUnit /= g_DrawScale;
		}

		// Slightly larger than precip scale so the shadow covers a readable patch of ground.
		const float scale = (pixelsPerUnit / 8.0f) * 1.6f;
		const float xleft = static_cast<float>(cloud.width - cloud.xOffset - 1);
		const float yabove = static_cast<float>(cloud.height - cloud.yOffset - 1);
		const float drawW = static_cast<float>(cloud.width) * scale;
		const float drawH = static_cast<float>(cloud.height) * scale;
		const float drawX = screenPos.x - xleft * scale;
		const float drawY = screenPos.y - yabove * scale;

		// Texture already carries xform-253 alpha; life + dayAmount fade the blot.
		const float lifeFade = std::min(1.0f, c.life * 0.35f);
		const float dayFade = lifeFade * dayAmount;
		const int alphaFloor = (dayAmount >= 0.99f) ? 40 : 0;
		const unsigned char tintA = static_cast<unsigned char>(
			std::clamp(static_cast<int>(255.0f * dayFade), alphaFloor, 255));
		if (tintA < 1)
		{
			continue;
		}
		Rectangle source = { 0, 0, static_cast<float>(cloud.width), static_cast<float>(cloud.height) };
		Rectangle dest = { drawX, drawY, drawW, drawH };
		BeginBlendMode(BLEND_ALPHA);
		DrawTexturePro(cloud.texture, source, dest, { 0, 0 }, 0.0f, Color{ 255, 255, 255, tintA });
		EndBlendMode();
	}
}

void WeatherSystem::Draw(Camera camera)
{
	m_lastCamera = camera;
	m_hasCamera = true;

	if (!EffectsEnabled())
	{
		return;
	}

	const bool drawPrecip = ShouldDrawPrecipitation()
		|| (m_type == WeatherType::Rain || m_type == WeatherType::Snow)
		|| (IsFadingOut() && CountActiveParticles() > 0 && m_fallSpeed > 0.0f);
	const bool drawSparkle = (m_type == WeatherType::Sparkle);

	const bool sheltered = IsAvatarSheltered();

	// Ground cloud shadows first; precip/sparkle overlays draw on top so drops
	// are not buried under the blot.
	DrawEdgeClouds(camera);

	if ((drawPrecip || drawSparkle) && !sheltered)
	{
		const auto& frames = g_spriteTable[kPrecipSpriteShape];
		// Sparkle frames vary in size — lock dest to first-frame box so they don't "shrink".
		float sparkleDrawW = 0.0f;
		float sparkleDrawH = 0.0f;
		if (drawSparkle && m_firstFrame >= 0 && m_firstFrame < static_cast<int>(frames.size()))
		{
			sparkleDrawW = static_cast<float>(frames[m_firstFrame].width) * kParticleDrawScale;
			sparkleDrawH = static_cast<float>(frames[m_firstFrame].height) * kParticleDrawScale;
		}

		for (const Particle& p : m_particles)
		{
			if (!p.active)
			{
				continue;
			}

			int frameIndex = 0;
			if (p.splash > 0 && m_useSplashes)
			{
				const int splashLeft = std::max(1, static_cast<int>(p.splash));
				frameIndex = m_firstSplashFrame + (m_splashFrames - splashLeft);
			}
			else if (drawSparkle)
			{
				frameIndex = p.frame;
			}
			else if (m_frameCount > 0)
			{
				frameIndex = m_firstFrame + (p.frame % m_frameCount);
			}
			else
			{
				continue;
			}

			if (frameIndex < 0 || frameIndex >= static_cast<int>(frames.size()))
			{
				continue;
			}

			const SpriteFrame& frame = frames[frameIndex];
			if (frame.texture.id == 0)
			{
				continue;
			}

			float w = static_cast<float>(frame.width) * kParticleDrawScale;
			float h = static_cast<float>(frame.height) * kParticleDrawScale;
			if (drawSparkle && sparkleDrawW > 0.0f && sparkleDrawH > 0.0f)
			{
				w = sparkleDrawW;
				h = sparkleDrawH;
			}
			Rectangle source = { 0, 0, static_cast<float>(frame.width), static_cast<float>(frame.height) };
			Rectangle dest = { p.x, p.y, w, h };

			Color tint = WHITE;
			if (drawSparkle && frame.livePaletteIndex >= 0)
			{
				tint = g_runtimePalette[frame.livePaletteIndex & 255];
				tint.a = 255;
			}

			DrawTexturePro(frame.texture, source, dest, { 0, 0 }, 0.0f, tint);
		}
	}

	if (!sheltered && m_overcastFade > 0.01f && g_isDay)
	{
		const unsigned char a = static_cast<unsigned char>(
			std::clamp(static_cast<int>(kOvercastVeilAlpha * m_overcastFade * OvercastVeilScale(m_intensity)), 0, 255));
		DrawRectangle(0, 0, 640, 360, Color{ 40, 45, 55, a });
	}

	if (!sheltered && m_fogFade > 0.01f)
	{
		// Slightly stronger veil at night so Fog still reads on a dark scene.
		const float nightBoost = g_isDay ? 1.0f : 1.15f;
		const unsigned char a = static_cast<unsigned char>(
			std::clamp(static_cast<int>(kFogVeilAlpha * m_fogFade * nightBoost * m_fogIntensityScale), 0, 255));
		DrawRectangle(0, 0, 640, 360, Color{ 220, 225, 230, a });
	}
}

void WeatherSystem::SyncWeatherMusic()
{
	if (!g_SoundSystem || !EffectsEnabled())
	{
		return;
	}

	StopWeatherMusicIfPlaying();

	int track = -1;
	if (m_type == WeatherType::Rain)
	{
		track = m_music.musicRainTrack;
	}
	else if (m_type == WeatherType::Snow)
	{
		track = m_music.musicSnowTrack;
	}

	if (track < 0)
	{
		return;
	}

	m_activeWeatherMusicPath = BuildU7MusicPath(track);
	g_SoundSystem->PlayMusic(m_activeWeatherMusicPath);
}

void WeatherSystem::StopWeatherMusicIfPlaying()
{
	if (!g_SoundSystem || m_activeWeatherMusicPath.empty())
	{
		m_activeWeatherMusicPath.clear();
		return;
	}

	g_SoundSystem->StopMusic(m_activeWeatherMusicPath);
	m_activeWeatherMusicPath.clear();
}

nlohmann::json WeatherSystem::SaveToJson() const
{
	nlohmann::json j;
	j["type"] = static_cast<int>(m_type);
	j["phase"] = static_cast<int>(m_phase);
	j["intensity"] = static_cast<int>(m_intensity);
	j["remainingMinutes"] = m_remainingMinutes;
	j["hasEggOrigin"] = m_hasEggOrigin;
	j["eggObjectId"] = m_eggObjectId;
	j["eggOrigin"] = { m_eggOrigin.x, m_eggOrigin.y, m_eggOrigin.z };
	j["manualOverride"] = m_manualOverride;
	j["manualOrigin"] = { m_manualOrigin.x, m_manualOrigin.y, m_manualOrigin.z };
	j["musicRainTrack"] = m_music.musicRainTrack;
	j["musicSnowTrack"] = m_music.musicSnowTrack;
	j["targetCount"] = m_targetCount;
	j["bursts"] = m_bursts;
	j["delay"] = m_delay;
	j["direction"] = m_direction;
	j["windDir"] = m_windDir;
	j["windYawDeg"] = m_windYawDeg;
	j["windSpeed"] = static_cast<int>(m_windSpeed);
	j["windSpeedHasOff"] = true;
	j["fogFade"] = m_fogFade;
	j["overcastFade"] = m_overcastFade;
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
	if (phase >= 0 && phase <= 5)
	{
		m_phase = static_cast<WeatherPhase>(phase);
	}
	const int intensity = j.value("intensity", 1);
	if (intensity >= 0 && intensity <= 2)
	{
		m_intensity = static_cast<WeatherIntensity>(intensity);
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
	m_manualOverride = j.value("manualOverride", false);
	if (j.contains("manualOrigin") && j["manualOrigin"].is_array() && j["manualOrigin"].size() >= 3)
	{
		m_manualOrigin.x = j["manualOrigin"][0].get<float>();
		m_manualOrigin.y = j["manualOrigin"][1].get<float>();
		m_manualOrigin.z = j["manualOrigin"][2].get<float>();
	}
	m_music.musicRainTrack = j.value("musicRainTrack", 4);
	m_music.musicSnowTrack = j.value("musicSnowTrack", 5);
	m_targetCount = j.value("targetCount", 0);
	m_bursts = j.value("bursts", 0);
	m_delay = j.value("delay", 0);
	m_direction = j.value("direction", 0);
	m_windDir = j.value("windDir", m_direction);
	m_windDir = ((m_windDir % 8) + 8) % 8;
	m_direction = m_windDir;
	m_windYawDeg = j.value("windYawDeg", static_cast<float>(m_windDir) * 45.0f);
	while (m_windYawDeg < 0.0f)
	{
		m_windYawDeg += 360.0f;
	}
	while (m_windYawDeg >= 360.0f)
	{
		m_windYawDeg -= 360.0f;
	}
	// New: 0=Off … 3=Heavy. Legacy saves used 0–2 as L/M/H (no Off) → +1.
	if (j.contains("windSpeed"))
	{
		int windSpeed = j["windSpeed"].get<int>();
		if (j.value("windSpeedHasOff", false))
		{
			if (windSpeed >= 0 && windSpeed <= 3)
			{
				m_windSpeed = static_cast<WeatherWindSpeed>(windSpeed);
			}
		}
		else if (windSpeed >= 0 && windSpeed <= 2)
		{
			m_windSpeed = static_cast<WeatherWindSpeed>(windSpeed + 1);
		}
	}
	m_fogFade = j.value("fogFade", 0.0f);
	m_overcastFade = j.value("overcastFade", 0.0f);
	if (m_fogFade > 0.01f)
	{
		m_fogWasActive = true;
	}

	if (m_type == WeatherType::Clear)
	{
		m_phase = WeatherPhase::Idle;
		m_hasEggOrigin = false;
	}
	else
	{
		ConfigureEffectParams(m_type, m_intensity);
		if (m_targetCount <= 0 && m_maxCount > 0 && !IsFadingOut())
		{
			m_targetCount = (m_phase == WeatherPhase::Steady) ? m_maxCount : 1;
		}
		SyncWeatherMusic();
	}
}
