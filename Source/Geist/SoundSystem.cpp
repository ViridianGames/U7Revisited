#include "Globals.h"
#include "SoundSystem.h"
#include <assert.h>
#include <sstream>
#include <algorithm>
#include <cmath>
#include <vector>

#include "Engine.h"
#include "ResourceManager.h"
#include "raymath.h"

#define NUM_CHANNELS 16

using namespace std;

SoundSystem::~SoundSystem()
{
   Shutdown();
}

void SoundSystem::Shutdown()
{
   ClearAllInstruments();
   ClearAllLoopingSfx();
   m_hooks = {};
}

void SoundSystem::ClearAllLoopingSfx()
{
   for (auto& pair : m_loopingSfxByObject)
   {
      if (pair.second.sound.frameCount > 0)
      {
         if (IsSoundPlaying(pair.second.sound))
         {
            ::StopSound(pair.second.sound);
         }
         UnloadSoundAlias(pair.second.sound);
      }
   }
   m_loopingSfxByObject.clear();
}

void SoundSystem::ClearAllInstruments()
{
   for (auto& pair : m_playingInstruments)
   {
      NotifyInstrumentStopped(pair.first);
   }

   for (auto& pair : m_playingInstruments)
   {
      if (pair.second.sound.frameCount > 0)
      {
         if (IsSoundPlaying(pair.second.sound))
         {
            ::StopSound(pair.second.sound);
         }
         UnloadSoundAlias(pair.second.sound);
      }
   }
   m_playingInstruments.clear();
   RestoreBgmFromInstrumentDuck();
}

bool SoundSystem::IsInstrumentPlaying(int objectId)
{
   auto it = m_playingInstruments.find(objectId);
   if (it == m_playingInstruments.end())
   {
      return false;
   }

   return it->second.sound.frameCount > 0 && IsSoundPlaying(it->second.sound);
}

float SoundSystem::ResolveSpatialRange(float maxRange) const
{
   return (maxRange > 0.0f) ? maxRange : m_defaultSpatialRange;
}

void SoundSystem::ComputeSpatialTargets(float& outVolume, float& outPan, const Vector3& worldPos, float maxRange) const
{
   if (!m_hooks.getListenerCamera)
   {
      outVolume = m_GlobalSoundVolume / 100.0f;
      outPan = 0.5f;
      return;
   }

   const Camera listener = m_hooks.getListenerCamera();
   const float listenerX = listener.target.x;
   const float listenerZ = listener.target.z;

   const float dx = worldPos.x - listenerX;
   const float dz = worldPos.z - listenerZ;
   const float dist = sqrtf(dx * dx + dz * dz);

   float t = 1.0f - dist / maxRange;
   if (t < 0.0f)
   {
      t = 0.0f;
   }

   const float attenuation = t * t;
   outVolume = attenuation * (m_GlobalSoundVolume / 100.0f);

   if (dist < 0.0001f)
   {
      outPan = 0.5f;
      return;
   }

   Vector3 camForward = Vector3Subtract(listener.target, listener.position);
   camForward.y = 0.0f;
   float forwardLen = Vector3Length(camForward);
   if (forwardLen < 0.0001f)
   {
      const float yaw = m_hooks.getListenerYaw ? m_hooks.getListenerYaw() : 0.0f;
      camForward = Vector3{ sinf(yaw), 0.0f, cosf(yaw) };
      forwardLen = Vector3Length(camForward);
   }

   if (forwardLen > 0.0001f)
   {
      camForward = Vector3Scale(camForward, 1.0f / forwardLen);
   }

   const Vector3 camRight = Vector3{ camForward.z, 0.0f, -camForward.x };
   const Vector3 toSource = Vector3{ dx / dist, 0.0f, dz / dist };
   float lateral = Vector3DotProduct(toSource, camRight);
   lateral = std::clamp(lateral, -1.0f, 1.0f);
   outPan = 0.5f + lateral * 0.5f;
}

void SoundSystem::InitSpatialStateFromWorld(float& currentVolume, float& currentPan, const Vector3& worldPos, float maxRange)
{
   ComputeSpatialTargets(currentVolume, currentPan, worldPos, maxRange);
}

void SoundSystem::ApplySpatial(Sound& sound, const Vector3& worldPos, float maxRange)
{
   float volume = 0.0f;
   float pan = 0.5f;
   ComputeSpatialTargets(volume, pan, worldPos, maxRange);
   SetSoundVolume(sound, volume);
   SetSoundPan(sound, pan);
}

void SoundSystem::ApplySpatialSmoothed(Sound& sound, float& currentVolume, float& currentPan,
   const Vector3& worldPos, float maxRange, float dt)
{
   float targetVolume = 0.0f;
   float targetPan = 0.5f;
   ComputeSpatialTargets(targetVolume, targetPan, worldPos, maxRange);

   const float alpha = std::min(1.0f, m_spatialSmoothSpeed * dt);
   currentVolume += (targetVolume - currentVolume) * alpha;
   currentPan += (targetPan - currentPan) * alpha;

   SetSoundVolume(sound, currentVolume);
   SetSoundPan(sound, currentPan);
}

void SoundSystem::PlaySound(std::string soundName, float volume)
{
   Sound* sound = g_ResourceManager->GetSound(soundName);
   if (sound)
   {
      if (volume == -1)
      {
         ::SetSoundVolume(*sound, float(m_GlobalSoundVolume) / 100.0f);
      }
      else
      {
         SetSoundVolume(*sound, volume);
      }
      SetSoundPan(*sound, 0.5f);
      ::PlaySound(*sound);
   }
}

void SoundSystem::PlaySoundAtObject(std::string soundName, int objectId, float maxRange)
{
   Sound* sound = g_ResourceManager->GetSound(soundName);
   if (!sound)
   {
      return;
   }

   Vector3 objectPos;
   if (!GetObjectPosition(objectId, objectPos))
   {
      PlaySound(soundName);
      return;
   }

   const float range = ResolveSpatialRange(maxRange);
   ApplySpatial(*sound, objectPos, range);
   ::PlaySound(*sound);
}

void SoundSystem::PlayMusic(std::string musicName, float volume)
{
   Music* music = g_ResourceManager->GetMusic(musicName);
   if (music)
   {
      PlayMusicStream(*music);

      if (volume == -1)
      {
         float vol = float(m_GlobalMusicVolume) / 100.0f;
         SetMusicVolume(*music, vol);
      }
      else
      {
         SetMusicVolume(*music, volume);
      }

      m_currentMusicName = musicName;
   }
}

void SoundSystem::StopMusic(std::string musicName)
{
   Music* music = g_ResourceManager->GetMusic(musicName);
   if (music)
   {
      StopMusicStream(*music);
      m_currentMusicName.clear();
      ClearAllInstruments();
   }
}

void SoundSystem::StopSound(std::string soundName)
{
   Sound* sound = g_ResourceManager->GetSound(soundName);
   if (sound)
   {
      ::StopSound(*sound);
   }
}

void SoundSystem::EnsureInstrumentBgmDuck()
{
   if (m_isDuckingBgm || m_currentMusicName.empty())
   {
      return;
   }

   Music* music = g_ResourceManager->GetMusic(m_currentMusicName);
   if (music)
   {
      m_isDuckingBgm = true;
      SetMusicVolume(*music, float(m_GlobalMusicVolume) / 100.0f * m_instrumentDuckFactor);
   }
}

void SoundSystem::RestoreBgmFromInstrumentDuck()
{
   if (!m_isDuckingBgm)
   {
      return;
   }

   if (!m_currentMusicName.empty())
   {
      Music* music = g_ResourceManager->GetMusic(m_currentMusicName);
      if (music)
      {
         SetMusicVolume(*music, float(m_GlobalMusicVolume) / 100.0f);
      }
   }

   m_isDuckingBgm = false;
}

bool SoundSystem::StopInstrument(int objectId)
{
   auto it = m_playingInstruments.find(objectId);
   if (it == m_playingInstruments.end())
   {
      return false;
   }

   NotifyInstrumentStopped(objectId);

   if (it->second.sound.frameCount > 0)
   {
      if (IsSoundPlaying(it->second.sound))
      {
         ::StopSound(it->second.sound);
      }
      UnloadSoundAlias(it->second.sound);
   }

   m_playingInstruments.erase(it);

   if (m_playingInstruments.empty())
   {
      RestoreBgmFromInstrumentDuck();
   }

   return true;
}

bool SoundSystem::PlayInstrument(int objectId, std::string musicPath, float maxRange)
{
   auto existing = m_playingInstruments.find(objectId);
   if (existing != m_playingInstruments.end())
   {
      if (existing->second.sound.frameCount > 0 && IsSoundPlaying(existing->second.sound))
      {
         StopInstrument(objectId);
         return false;
      }
      // A finished clip still owns an alias, effects, and possibly BGM ducking.
      StopInstrument(objectId);
   }

   Sound* baseSound = g_ResourceManager->GetSound(musicPath);
   if (!baseSound || baseSound->frameCount == 0)
   {
      return false;
   }

   Sound alias = LoadSoundAlias(*baseSound);
   if (alias.frameCount == 0)
   {
      return false;
   }

   InstrumentEntry entry;
   entry.musicPath = musicPath;
   entry.maxRange = ResolveSpatialRange(maxRange);
   entry.sound = alias;

   Vector3 objectPos;
   if (GetObjectPosition(objectId, objectPos))
   {
      InitSpatialStateFromWorld(entry.currentVolume, entry.currentPan, objectPos, entry.maxRange);
      SetSoundVolume(entry.sound, entry.currentVolume);
      SetSoundPan(entry.sound, entry.currentPan);
   }
   else
   {
      entry.currentVolume = float(m_GlobalSoundVolume) / 100.0f;
      entry.currentPan = 0.5f;
      SetSoundVolume(entry.sound, entry.currentVolume);
      SetSoundPan(entry.sound, entry.currentPan);
   }

   ::PlaySound(entry.sound);
   m_playingInstruments[objectId] = entry;

   if (m_hooks.onInstrumentStarted)
   {
      m_hooks.onInstrumentStarted(objectId);
   }

   EnsureInstrumentBgmDuck();
   return true;
}

SoundSystem::SoundSystem()
{
   m_GlobalSoundVolume = 0;
   m_GlobalMusicVolume = 0;
}

void SoundSystem::Init(const std::string& configfile)
{
   SetGlobalSoundVolume(g_Engine->m_EngineConfig.GetNumber("sound_volume"));
   SetGlobalMusicVolume(g_Engine->m_EngineConfig.GetNumber("music_volume"));

   float duckPercent = g_Engine->m_EngineConfig.GetNumber("instrument_duck_percent");
   if (duckPercent <= 0.0f)
      duckPercent = 15.0f;
   if (duckPercent > 100.0f)
      duckPercent = 100.0f;
   m_instrumentDuckFactor = duckPercent / 100.0f;

   m_defaultSpatialRange = g_Engine->m_EngineConfig.GetNumber("spatial_sound_default_range");
   if (m_defaultSpatialRange <= 0.0f)
   {
      m_defaultSpatialRange = 32.0f;
   }

   m_spatialSmoothSpeed = g_Engine->m_EngineConfig.GetNumber("spatial_sound_smooth_speed");
   if (m_spatialSmoothSpeed <= 0.0f)
   {
      m_spatialSmoothSpeed = 8.0f;
   }

   m_RNG = make_unique<RNG>();

   InitAudioDevice();
}

void SoundSystem::Update()
{
   const float dt = g_Engine->LastFrameInSeconds();

   if (!m_currentMusicName.empty())
   {
      UpdateMusicStream(*g_ResourceManager->GetMusic(m_currentMusicName));
   }

   std::vector<int> instrumentsOutOfRange;

   for (auto it = m_playingInstruments.begin(); it != m_playingInstruments.end();)
   {
      const int objectId = it->first;
      InstrumentEntry& entry = it->second;
      if (entry.sound.frameCount == 0)
      {
         NotifyInstrumentStopped(objectId);
         it = m_playingInstruments.erase(it);
         continue;
      }

      if (!IsSoundPlaying(entry.sound))
      {
         NotifyInstrumentStopped(objectId);
         UnloadSoundAlias(entry.sound);
         it = m_playingInstruments.erase(it);
         continue;
      }

      Vector3 objectPos;
      if (GetObjectPosition(objectId, objectPos) && m_hooks.getListenerCamera)
      {
         const Camera listener = m_hooks.getListenerCamera();
         const float dist = Vector2Distance(
            { objectPos.x, objectPos.z },
            { listener.target.x, listener.target.z }
         );

         if (dist > entry.maxRange)
         {
            instrumentsOutOfRange.push_back(objectId);
         }
         else
         {
            ApplySpatialSmoothed(entry.sound, entry.currentVolume, entry.currentPan,
               objectPos, entry.maxRange, dt);
         }
      }
      else
      {
         entry.currentVolume = m_GlobalSoundVolume / 100.0f;
         entry.currentPan = 0.5f;
         SetSoundVolume(entry.sound, entry.currentVolume);
         SetSoundPan(entry.sound, entry.currentPan);
      }

      ++it;
   }

   for (int objectId : instrumentsOutOfRange)
   {
      StopInstrument(objectId);
   }

   if (m_playingInstruments.empty())
   {
      RestoreBgmFromInstrumentDuck();
   }

   for (auto it = m_loopingSfxByObject.begin(); it != m_loopingSfxByObject.end();)
   {
      const int objectId = it->first;
      LoopingSfxEntry& entry = it->second;

      if (entry.sound.frameCount == 0)
      {
         it = m_loopingSfxByObject.erase(it);
         continue;
      }

      Vector3 objectPos;
      const bool objectFound = GetObjectPosition(objectId, objectPos);
      if (entry.stopWhenNotVisible && objectFound && IsObjectVisibleOnScreen(objectId))
      {
         entry.wasEverVisibleOnScreen = true;
      }

      if (ShouldStopLoopingEntry(entry, objectFound, objectId))
      {
         ++it;
         StopLoopingSoundEffect(objectId);
         continue;
      }

      if (!objectFound)
      {
         entry.currentVolume = m_GlobalSoundVolume / 100.0f;
         entry.currentPan = 0.5f;
         SetSoundVolume(entry.sound, entry.currentVolume);
         SetSoundPan(entry.sound, entry.currentPan);
      }

      if (!IsSoundPlaying(entry.sound))
      {
         if (objectFound)
            InitSpatialStateFromWorld(entry.currentVolume, entry.currentPan, objectPos, entry.maxRange);
         SetSoundVolume(entry.sound, entry.currentVolume);
         SetSoundPan(entry.sound, entry.currentPan);
         ::PlaySound(entry.sound);
      }

      if (objectFound)
         ApplySpatialSmoothed(entry.sound, entry.currentVolume, entry.currentPan, objectPos, entry.maxRange, dt);

      ++it;
   }
}

bool SoundSystem::GetObjectPosition(int objectId, Vector3& outPos) const
{
   return m_hooks.getObjectPosition && m_hooks.getObjectPosition(objectId, outPos);
}

bool SoundSystem::IsObjectVisibleOnScreen(int objectId) const
{
   return m_hooks.isObjectOnScreen && m_hooks.isObjectOnScreen(objectId);
}

void SoundSystem::NotifyInstrumentStopped(int objectId)
{
   if (m_hooks.onInstrumentStopped)
   {
      m_hooks.onInstrumentStopped(objectId);
   }
}

bool SoundSystem::ShouldStopLoopingEntry(const LoopingSfxEntry& entry, bool objectFound, int objectId) const
{
   // An absent lookup means unpositioned playback; a failed lookup means the
   // tracked object has gone away.
   if ((m_hooks.getObjectPosition && !objectFound) ||
       (m_hooks.isObjectDead && m_hooks.isObjectDead(objectId)))
   {
      return true;
   }

   if (m_hooks.isObjectOnScreen && entry.stopWhenNotVisible &&
       entry.wasEverVisibleOnScreen && !IsObjectVisibleOnScreen(objectId))
   {
      return true;
   }

   return false;
}

void SoundSystem::PlayLoopingSoundEffect(int objectId, const std::string& soundPath, float maxRange, bool stopWhenNotVisible)
{
   if (objectId < 0 || soundPath.empty())
   {
      return;
   }

   StopLoopingSoundEffect(objectId);

   Sound* baseSound = g_ResourceManager->GetSound(soundPath);
   if (!baseSound || baseSound->frameCount == 0)
   {
      return;
   }

   Sound alias = LoadSoundAlias(*baseSound);
   if (alias.frameCount == 0)
   {
      return;
   }

   LoopingSfxEntry entry;
   entry.path = soundPath;
   entry.maxRange = ResolveSpatialRange(maxRange);
   entry.stopWhenNotVisible = stopWhenNotVisible;
   entry.sound = alias;

   Vector3 objectPos;
   if (GetObjectPosition(objectId, objectPos))
   {
      InitSpatialStateFromWorld(entry.currentVolume, entry.currentPan, objectPos, entry.maxRange);
   }
   else
   {
      entry.currentVolume = float(m_GlobalSoundVolume) / 100.0f;
      entry.currentPan = 0.5f;
   }

   SetSoundVolume(entry.sound, entry.currentVolume);
   SetSoundPan(entry.sound, entry.currentPan);
   ::PlaySound(entry.sound);

   m_loopingSfxByObject[objectId] = entry;
}

void SoundSystem::StopLoopingSoundEffect(int objectId)
{
   auto it = m_loopingSfxByObject.find(objectId);
   if (it == m_loopingSfxByObject.end())
   {
      return;
   }

   if (it->second.sound.frameCount > 0)
   {
      if (IsSoundPlaying(it->second.sound))
      {
         ::StopSound(it->second.sound);
      }
      UnloadSoundAlias(it->second.sound);
   }

   m_loopingSfxByObject.erase(it);
}

void SoundSystem::SetGlobalSoundVolume(float newVolume)
{
   if (newVolume > 100)
      newVolume = 100;
   if (newVolume < 0)
      newVolume = 0;

   m_GlobalSoundVolume = newVolume;

   g_Engine->m_EngineConfig.SetNumber("sound_volume", m_GlobalSoundVolume);
}

void SoundSystem::SetGlobalMusicVolume(float newVolume)
{
   if (newVolume > 100)
      newVolume = 100;
   if (newVolume < 0)
      newVolume = 0;

   m_GlobalMusicVolume = newVolume;

   g_Engine->m_EngineConfig.SetNumber("music_volume", m_GlobalMusicVolume);

   if (!m_currentMusicName.empty() && !m_isDuckingBgm)
   {
      Music* music = g_ResourceManager->GetMusic(m_currentMusicName);
      if (music)
      {
         SetMusicVolume(*music, float(m_GlobalMusicVolume) / 100.0f);
      }
   }
   else if (!m_currentMusicName.empty() && m_isDuckingBgm)
   {
      Music* music = g_ResourceManager->GetMusic(m_currentMusicName);
      if (music)
      {
         SetMusicVolume(*music, float(m_GlobalMusicVolume) / 100.0f * m_instrumentDuckFactor);
      }
   }
}
