///////////////////////////////////////////////////////////////////////////
//
// Name:     SOUND.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  The Sound subsystem, which handles the playing of sounds.
//
///////////////////////////////////////////////////////////////////////////
#ifndef _SOUND_H_
#define _SOUND_H_

#include "Object.h"
#include "RNG.h"
#include <string>
#include <map>
#include <list>
#include "soloud.h"
#include "soloud_speech.h"
#include "soloud_thread.h"
#include "soloud_wav.h"

class Sound : public Object
{
	//  Songs
	enum SongIDs
	{
		INVALID_SONG = -1
	};

	class Song
	{
	public:
		Song() {};
		Song(int ID, std::string name, std::string intro, std::string loop, bool lazy = false)
		{
			Init(ID, name, intro, loop, lazy);
		}
		void Init(int ID, std::string name, std::string intro, std::string loop, bool lazy = false);

		std::string m_Name = "INVALID SONG";
		std::string m_IntroName = "";
		std::string m_LoopName = "";
		int m_ID = INVALID_SONG;
		SoLoud::Wav* m_Intro = nullptr;
		SoLoud::Wav* m_Loop = nullptr;
		SoLoud::Queue* m_Queue = nullptr;
		int m_Handle;
	};

	//  Crossfade Groups
	SoLoud::handle m_CrossfadeGroup;
	std::map<int, int> m_CrossfadeTracks;
	int m_CurrentCrossfadeTrack;
	int m_NewCrossfadeTrack;
	int m_LastCrossfadeTrack = -1;
	float m_CrossfadeDelay = 0;
	bool m_CrossfadeGroupRunning = false;

	//  For various effects
	std::unique_ptr<RNG> m_RNG;

	std::unordered_map< SoLoud::Wav*, unsigned int> m_SoundsThisUpdate;

public:
	Sound();

	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw() {};

	void PlaySFX(std::string fName, float tweakrange = 0, float panning = 0, float overridevolume = 0, bool clocked = true);
	void PlaySFXGroup(std::string fName, int numberofsounds, std::string fExt);

	void Say(std::string text);

	void SetSoundVolume(float newVolume);
	void SetMusicVolume(float newVolume);

	float GetSoundVolume() { return m_SoundVolume; }
	float GetMusicVolume() { return m_MusicVolume; }

	//  Songs
	std::map<int, std::unique_ptr<Song>> m_SongList;
	void AddSong(int ID, std::string name, std::string intro, std::string loop, bool lazy = false);
	void AddSong(int ID, std::string name, std::string loop, bool lazy = false);
	void PlaySong(int ID, float delay = 0, float crossfadelength = 1, bool skpintro = false);
	void StopSong(float delay);
	void PlaySongEX();
	int  GetCurrentSongID(void) { return m_CurrentSongID; }
	bool IsSongPlaying();
	bool InSongTransition() { return m_InSongTransition; } // Are we fading in/out on a song?
	int  m_CurrentSongID = -1;
	int  m_IncomingSongID = -1;
	Song* m_CurrentSong = nullptr;
	bool  m_SongSkipIntro = false;

	float* GetFFT(void);

	//  Handling song transitions
	bool  m_SongDelaying = false;
	float m_SongDelayTimer = 0;
	bool  m_SongFading = false;
	float m_SongFadeLength = 0;
	float m_SongFadeTimer = 0;
	bool  m_InSongTransition = false;
	float m_SongTransitionTimer = 0;

	//  Crossfade groups
	void AddTrackToCrossfadeGroup(int ID, SoLoud::Wav* track);
	void StartCrossfadeGroup(int ID);
	void StopCrossfadeGroup();
	void ClearCrossfadeGroup();
	void SilenceCrossfadeGroup();
	void RestoreCrossfadeGroup();
	void CrossfadeTo(int ID);
	int  GetCurrentCrossfadeTrack() { return m_LastCrossfadeTrack; }

private:

	float m_SoundVolume;
	float m_MusicVolume;

	//  SoLoud-specific stuff
	std::unique_ptr<SoLoud::Soloud> m_SoLoud;
	std::unique_ptr<SoLoud::Speech> m_Speech;

	SoLoud::Wav thisWav;
	SoLoud::Bus* m_QueueBus;
};

#endif