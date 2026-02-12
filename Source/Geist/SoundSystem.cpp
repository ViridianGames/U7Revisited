#include "Globals.h"
#include "SoundSystem.h"
#include <assert.h>
#include <sstream>
#include <algorithm>

#include "Engine.h"
#include "ResourceManager.h"

#define NUM_CHANNELS 16

using namespace std;

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
      ::PlaySound(*sound); //  Get around the namespace collision
   }
}

void SoundSystem::PlayMusic(std::string musicName, float volume)
{
   Music* music = g_ResourceManager->GetMusic(musicName);
   if (music)
   {
      PlayMusicStream(*music);

      if (volume == -1)
      {
         SetMusicVolume(*music, float(m_GlobalMusicVolume) / 100.0f);
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


SoundSystem::SoundSystem()
{
   m_GlobalSoundVolume = 0;
   m_GlobalMusicVolume = 0;
}

void SoundSystem::Init(const std::string& configfile)
{
   SetGlobalSoundVolume(g_Engine->m_EngineConfig.GetNumber("sound_volume"));
   SetGlobalMusicVolume(g_Engine->m_EngineConfig.GetNumber("music_volume"));

   //  Set up RNG for effects
   m_RNG = make_unique<RNG>();

   InitAudioDevice();
}

void SoundSystem::Update()
{
   if (!m_currentMusicName.empty())
   {
      UpdateMusicStream(*g_ResourceManager->GetMusic(m_currentMusicName));
   }
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

   m_GlobalSoundVolume = newVolume;

   g_Engine->m_EngineConfig.SetNumber("sound_volume", m_GlobalSoundVolume);
}