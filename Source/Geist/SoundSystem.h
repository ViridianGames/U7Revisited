///////////////////////////////////////////////////////////////////////////
//
// Name:     SOUND.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  The Sound subsystem, which handles the playing of sounds.
//
///////////////////////////////////////////////////////////////////////////
#ifndef _SOUNDSYSTEM_H_
#define _SOUNDSYSTEM_H_

#include "Object.h"
#include "RNG.h"
#include "raylib.h"
#include <string>
#include <memory>
#include <unordered_map>

class U7Object;

class SoundSystem : public Object
{
   //  For various effects
   std::unique_ptr<RNG> m_RNG;

   struct LoopingSfxEntry
   {
      std::string path;
      float maxRange = 32.0f;
      Sound sound{};
      float currentVolume = 0.0f;
      float currentPan = 0.5f;
      bool stopWhenNotVisible = false;
      // Only stop after the object has been on screen at least once (spawn scripts run after the visible pass).
      bool wasEverVisibleOnScreen = false;
   };

   struct InstrumentEntry
   {
      std::string musicPath;
      float maxRange = 32.0f;
      Sound sound{};
      float currentVolume = 0.0f;
      float currentPan = 0.5f;
   };

public:
   SoundSystem();
   ~SoundSystem();

   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw() {};

   void PlaySound(std::string fName, float volume = -1);
   // Spatial one-shot at object world position (distance attenuation + stereo pan).
   void PlaySoundAtObject(std::string fName, int objectId, float maxRange = -1.0f);
   void StopSound(std::string fName);
   void PlayMusic(std::string fName, float volume = -1);
   void StopMusic(std::string fName);

   // One-shot instrument clip (Audio/Music/NNbg.ogg) via PlaySound; ducks BGM while any play.
   // Returns true if playback started; false if toggled off (same object was already playing).
   bool PlayInstrument(int objectId, std::string musicPath, float maxRange = -1.0f);
   bool StopInstrument(int objectId);
   bool IsInstrumentPlaying(int objectId);

   // Looped ambient SFX (e.g. pool water); replays while registered.
   void PlayLoopingSoundEffect(int objectId, int soundId, float maxRange = -1.0f, bool stopWhenNotVisible = false);
   void StopLoopingSoundEffect(int objectId);

   void SetGlobalSoundVolume(float newVolume);
   void SetGlobalMusicVolume(float newVolume);

   float GetGlobalSoundVolume() { return m_GlobalSoundVolume; }
   float GetGlobalMusicVolume() { return m_GlobalMusicVolume; }
   float GetSpatialDefaultRange() const { return m_defaultSpatialRange; }

private:

   float m_GlobalSoundVolume = 0;
   float m_GlobalMusicVolume = 0;
   float m_defaultSpatialRange = 32.0f;
   float m_spatialSmoothSpeed = 8.0f;

   std::string m_currentMusicName;

   // BGM ducking while any instrument clip is playing.
   bool m_isDuckingBgm = false;
   float m_instrumentDuckFactor = 0.15f;

   std::unordered_map<int, InstrumentEntry> m_playingInstruments;
   std::unordered_map<int, LoopingSfxEntry> m_loopingSfxByObject;

   void ClearAllInstruments();
   void ClearAllLoopingSfx();
   void EnsureInstrumentBgmDuck();
   void RestoreBgmFromInstrumentDuck();
   float ResolveSpatialRange(float maxRange) const;
   void ComputeSpatialTargets(float& outVolume, float& outPan, const Vector3& worldPos, float maxRange) const;
   void ApplySpatial(Sound& sound, const Vector3& worldPos, float maxRange);
   void ApplySpatialSmoothed(Sound& sound, float& currentVolume, float& currentPan,
      const Vector3& worldPos, float maxRange, float dt);
   void InitSpatialStateFromWorld(float& currentVolume, float& currentPan, const Vector3& worldPos, float maxRange);
   bool IsObjectVisibleOnScreen(int objectId) const;
   bool ShouldStopLoopingEntry(const LoopingSfxEntry& entry, U7Object* obj) const;
};

#endif
