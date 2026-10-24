#include "WeatherSystem.h"
#include "U7Globals.h"
#include "Geist/Logging.h"
#include "Geist/SoundSystem.h"
#include "Geist/Engine.h"
#include "Geist/Config.h"
#include <algorithm>
#include <cmath>

std::unique_ptr<WeatherSystem> g_WeatherSystem;

namespace
{
	constexpr float kFlashDuration = 0.12f;
	constexpr float kOvercastDim = 0.72f;
	constexpr float kFogDimR = 0.55f;
	constexpr float kFogDimG = 0.60f;
	constexpr float kFogDimB = 0.68f;
}

void WeatherSystem::Init()
{
	m_type = WeatherType::Clear;
	m_phase = WeatherPhase::Idle;
	m_remainingMinutes = 0;
	m_hasEggOrigin = false;
	m_eggObjectId = -1;
	m_music.musicRainTrack = 4;
	m_music.musicSnowTrack = 5;
	m_particles.assign(kMaxParticles, Particle{});
	ClearParticles();
	m_spawnAccumulator = 0;
	m_flashTimer = 0;
	m_flashCooldown = 0;
	m_cloudFrame = 0;
	m_cloudTimer = 0;
	StopWeatherMusicIfPlaying();
	ConfigureEffectParams(WeatherType::Clear);
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

void WeatherSystem::ConfigureEffectParams(WeatherType type)
{
	m_maxCount = 0;
	m_fallSpeed = 0;
	m_firstFrame = 0;
	m_frameCount = 0;
	m_useSplashes = false;
	m_firstSplashFrame = 0;
	m_splashFrames = 0;

	switch (type)
	{
	case WeatherType::Snow:
		// Original: 125, speed 1, frames 13-20, splash 21-27
		m_maxCount = kTargetParticles;
		m_fallSpeed = 40.0f;
		m_firstFrame = 13;
		m_frameCount = 8;
		m_useSplashes = true;
		m_firstSplashFrame = 21;
		m_splashFrames = 7;
		break;
	case WeatherType::Rain:
		// Original: 125, speed 6, frames 3-6
		m_maxCount = kTargetParticles;
		m_fallSpeed = 220.0f;
		m_firstFrame = 3;
		m_frameCount = 4;
		break;
	case WeatherType::Sparkle:
		// Exult: Basicdrop<21, 27, 0, true> — hover (delta 0), frames 21..27 ping-pong.
		m_maxCount = kSparkleParticles;
		m_fallSpeed = 0;
		m_firstFrame = 21;
		m_frameCount = 7; // 21..27 inclusive
		m_useSplashes = false;
		break;
	case WeatherType::Overcast:
	case WeatherType::Cloudy:
		m_maxCount = 1;
		m_fallSpeed = 0;
		break;
	default:
		break;
	}
}

void WeatherSystem::ApplyType(WeatherType type, int durationMinutes, bool fromEgg,
	Vector3 eggOrigin, int eggObjectId)
{
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
		minutes = 6000;
	}
	m_remainingMinutes = minutes;

	m_hasEggOrigin = fromEgg;
	m_eggOrigin = eggOrigin;
	m_eggObjectId = fromEgg ? eggObjectId : -1;

	ConfigureEffectParams(type);
	ClearParticles();
	m_spawnAccumulator = 0;
	m_flashTimer = 0;
	m_flashCooldown = GetRandomValue(2, 8) / 10.0f;
	SyncWeatherMusic();
}

void WeatherSystem::ClearWeather(bool gradual)
{
	(void)gradual;
	StopWeatherMusicIfPlaying();
	m_type = WeatherType::Clear;
	m_phase = WeatherPhase::Idle;
	m_remainingMinutes = 0;
	m_hasEggOrigin = false;
	m_eggObjectId = -1;
	ConfigureEffectParams(WeatherType::Clear);
	ClearParticles();
	m_flashTimer = 0;
}

void WeatherSystem::ClearParticles()
{
	for (Particle& p : m_particles)
	{
		p = Particle{};
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

bool WeatherSystem::EffectsEnabled() const
{
	if (!g_Engine)
	{
		return true;
	}
	// engine.cfg: weather_effects = 1 (default on). 0 disables particles/overlays.
	return g_Engine->m_EngineConfig.GetNumber("weather_effects") >= 0.5f;
}

bool WeatherSystem::WantsOvercastPalette() const
{
	// Original daytime weather palettes: snow, rain, overcast use overcast; cloudy does not.
	return m_type == WeatherType::Snow
		|| m_type == WeatherType::Rain
		|| m_type == WeatherType::Overcast;
}

bool WeatherSystem::WantsFogPalette() const
{
	return m_type == WeatherType::Fog;
}

bool WeatherSystem::WantsCloudSprites() const
{
	return m_type == WeatherType::Overcast
		|| m_type == WeatherType::Cloudy
		|| m_type == WeatherType::Rain;
}

bool WeatherSystem::ShouldDrawPrecipitation() const
{
	if (!EffectsEnabled())
	{
		return false;
	}
	if (m_type != WeatherType::Rain && m_type != WeatherType::Snow)
	{
		return false;
	}
	// Outdoor-only (not dungeon / under mountain ceiling).
	if (g_dungeonViewActive)
	{
		return false;
	}
	return true;
}

void WeatherSystem::TryAddParticle()
{
	int active = 0;
	int freeIndex = -1;
	for (int i = 0; i < static_cast<int>(m_particles.size()); ++i)
	{
		if (m_particles[i].active)
		{
			++active;
		}
		else if (freeIndex < 0)
		{
			freeIndex = i;
		}
	}

	if (active >= m_maxCount || freeIndex < 0)
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
		// Exult sparkle: spawn anywhere on screen; hang and twinkle in place.
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

void WeatherSystem::UpdateParticles(float dt)
{
	if (m_maxCount <= 0)
	{
		return;
	}

	if (m_phase == WeatherPhase::Rising || m_phase == WeatherPhase::Steady)
	{
		m_spawnAccumulator += dt * static_cast<float>(m_maxCount) * 0.35f;
		while (m_spawnAccumulator >= 1.0f)
		{
			m_spawnAccumulator -= 1.0f;
			TryAddParticle();
		}
		m_phase = WeatherPhase::Steady;
	}

	constexpr float kSparkleFrameSeconds = 0.08f;
	const int sparkleLast = m_firstFrame + m_frameCount - 1; // 27 when first=21, count=7

	for (Particle& p : m_particles)
	{
		if (!p.active)
		{
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

		// Exult sparkle: delta 0 — hover and ping-pong frames; respawn at end of cycle.
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
						// Respawn like Exult when reaching fraN with delta 0.
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

		p.y += m_fallSpeed * dt;
		if (m_frameCount > 0)
		{
			p.frame = (p.frame + 1) % m_frameCount;
		}

		if (p.y >= p.endY)
		{
			if (m_useSplashes && m_splashFrames > 0)
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

void WeatherSystem::Update(float dt)
{
	if (!EffectsEnabled() || m_type == WeatherType::Clear)
	{
		return;
	}

	// Sparkle particles update indoors; rain/snow only while outdoor draw is allowed.
	if (m_type == WeatherType::Sparkle || ShouldDrawPrecipitation())
	{
		UpdateParticles(dt);
	}

	if (WantsCloudSprites())
	{
		m_cloudTimer += dt;
		if (m_cloudTimer > 0.25f)
		{
			m_cloudTimer = 0;
			const auto& clouds = g_spriteTable[kCloudSpriteShape];
			if (!clouds.empty())
			{
				m_cloudFrame = (m_cloudFrame + 1) % static_cast<int>(clouds.size());
			}
		}
	}

	// Storm lightning flash (original: random palette flash while type == 2, daytime).
	if (m_type == WeatherType::Rain && g_isDay)
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
					// Optional Exult-aligned thunder SFX
					if (g_SoundSystem)
					{
						g_SoundSystem->PlaySound(BuildU7SfxPath(62));
					}
				}
				m_flashCooldown = GetRandomValue(15, 45) / 10.0f;
			}
		}
	}
	else
	{
		m_flashTimer = 0;
	}
}

void WeatherSystem::ApplyLightingModifiers(Color& dayNightColor, bool isDay) const
{
	if (!EffectsEnabled())
	{
		return;
	}

	if (!isDay)
	{
		return;
	}

	if (WantsOvercastPalette())
	{
		dayNightColor.r = static_cast<unsigned char>(dayNightColor.r * kOvercastDim);
		dayNightColor.g = static_cast<unsigned char>(dayNightColor.g * kOvercastDim);
		dayNightColor.b = static_cast<unsigned char>(dayNightColor.b * kOvercastDim);
	}

	if (WantsFogPalette())
	{
		dayNightColor.r = static_cast<unsigned char>(dayNightColor.r * kFogDimR);
		dayNightColor.g = static_cast<unsigned char>(dayNightColor.g * kFogDimG);
		dayNightColor.b = static_cast<unsigned char>(dayNightColor.b * kFogDimB);
	}

	if (m_flashTimer > 0)
	{
		dayNightColor = { 255, 255, 255, 255 };
	}
}

void WeatherSystem::Draw(Camera camera)
{
	(void)camera;

	if (!EffectsEnabled() || m_type == WeatherType::Clear)
	{
		return;
	}

	const bool drawPrecip = ShouldDrawPrecipitation();
	const bool drawSparkle = (m_type == WeatherType::Sparkle); // sparkles OK indoors
	if (drawPrecip || drawSparkle)
	{
		const auto& frames = g_spriteTable[kPrecipSpriteShape];
		for (const Particle& p : m_particles)
		{
			if (!p.active)
			{
				continue;
			}

			int frameIndex = 0;
			if (p.splash > 0 && m_useSplashes)
			{
				frameIndex = m_firstSplashFrame + (m_splashFrames - static_cast<int>(p.splash));
			}
			else if (drawSparkle)
			{
				// Sparkle stores absolute SPRITES.VGA frame (21..27).
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

			const float w = static_cast<float>(frame.width) * kParticleDrawScale;
			const float h = static_cast<float>(frame.height) * kParticleDrawScale;
			Rectangle source = { 0.0f, 0.0f, static_cast<float>(frame.width), static_cast<float>(frame.height) };
			Rectangle dest = { p.x, p.y, w, h };
			DrawTexturePro(frame.texture, source, dest, { 0.0f, 0.0f }, 0.0f, WHITE);
		}
	}

	if (WantsCloudSprites() && !g_dungeonViewActive)
	{
		const auto& clouds = g_spriteTable[kCloudSpriteShape];
		if (!clouds.empty())
		{
			const int idx = m_cloudFrame % static_cast<int>(clouds.size());
			const SpriteFrame& cloud = clouds[idx];
			if (cloud.texture.id != 0)
			{
				DrawTexture(cloud.texture, 40, 20, Color{ 255, 255, 255, 160 });
				DrawTexture(cloud.texture, 280, 48, Color{ 255, 255, 255, 120 });
			}
		}
	}

	// Soft fog veil in virtual GUI space (daytime fog palette already dims lighting).
	if (WantsFogPalette() && g_isDay && !g_dungeonViewActive)
	{
		DrawRectangle(0, 0, 640, 360, Color{ 220, 225, 230, 150 });
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

	// Weather beds are mode-0 ambient tracks. Jukebox eggs are still a stub;
	// when they land, prefer not restarting a regional track over a weather bed.
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
	else
	{
		ConfigureEffectParams(m_type);
		SyncWeatherMusic();
	}
}
