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
#include <string>
#include <memory>

class SoundSystem : public Object
{
   //  For various effects
   std::unique_ptr<RNG> m_RNG;

public:
   SoundSystem();

   virtual void Init(const std::string& configfile);
   virtual void Shutdown() {};
   virtual void Update();
   virtual void Draw() {};

   void PlaySound(std::string fName, float volume = -1);
   void StopSound(std::string fName);
   void PlayMusic(std::string fName, float volume = -1);
   void StopMusic(std::string fName);

   void SetGlobalSoundVolume(float newVolume);
   void SetGlobalMusicVolume(float newVolume);

   float GetGlobalSoundVolume() { return m_GlobalSoundVolume; }
   float GetGlobalMusicVolume() { return m_GlobalMusicVolume; }

private:

   float m_GlobalSoundVolume = 0;
   float m_GlobalMusicVolume = 0;

   std::string m_currentMusicName;
};

#endif