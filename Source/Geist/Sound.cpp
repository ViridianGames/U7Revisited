#include "Globals.h"
#include <assert.h>
#include <sstream>
#include <algorithm>

#define NUM_CHANNELS 16

using namespace std;
using namespace SoLoud;

void Sound::Song::Init(int ID, std::string name, std::string intro, std::string loop, bool lazy)
{
	m_ID = ID;
	m_Name = name;
	m_LoopName = loop;
	m_IntroName = intro;

	//  We can use lazy intialization to help smooth out the loading of songs.
	if (!lazy)
	{
		m_Loop = g_ResourceManager->GetSound(m_LoopName);
		if (m_IntroName != "")
			m_Intro = g_ResourceManager->GetSound(m_IntroName);
	}
	else
	{
		m_Loop = nullptr;
		m_Intro = nullptr;
	}
}


Sound::Sound()
{
	m_SoundVolume = 0;
	m_MusicVolume = 0;
	m_SoundsThisUpdate.clear();
}

void Sound::Init(const std::string& configfile)
{
	SetSoundVolume(g_Engine->m_EngineConfig.GetNumber("sound_volume"));
	SetMusicVolume(g_Engine->m_EngineConfig.GetNumber("music_volume"));

	// initialize SoLoud.
	m_SoLoud = make_unique<Soloud>();
	m_Speech = make_unique<Speech>();
	m_SoLoud->init(Soloud::ENABLE_VISUALIZATION);

	// Start the queue for songs.
	m_QueueBus = new SoLoud::Bus();
	m_SoLoud->play(*m_QueueBus);

	//  Create the group for crossfading.
	m_CrossfadeGroup = m_SoLoud->createVoiceGroup();
	m_NewCrossfadeTrack = -1;

	//  Set up RNG for effects
	m_RNG = make_unique<RNG>();
	m_RNG->SeedRNG(g_Engine->Time());
}

void Sound::AddTrackToCrossfadeGroup(int ID, SoLoud::Wav* track)
{
	int handle = m_SoLoud->play(*track, 0, 0, 1); //  Play the track paused and silent, then add it to the group.
	m_SoLoud->seek(handle, 0);
	m_SoLoud->setProtectVoice(handle, 1); // Do NOT throw this channel away to make room for a new channel.
	m_SoLoud->setLooping(handle, true);
	m_CrossfadeTracks[ID] = handle;
	m_SoLoud->addVoiceToGroup(m_CrossfadeGroup, handle);
}

void Sound::StartCrossfadeGroup(int ID)
{
	StopSong(.5f);
	m_SoLoud->fadeVolume(m_CrossfadeTracks[ID], m_MusicVolume, 1);
	m_CurrentCrossfadeTrack = ID;
	m_SoLoud->setPause(m_CrossfadeGroup, false);
	m_CrossfadeGroupRunning = true;
	m_LastCrossfadeTrack = ID;
}

void Sound::StopCrossfadeGroup()
{
	m_SoLoud->fadeVolume(m_CrossfadeTracks[m_CurrentCrossfadeTrack], 0, 1);
	m_CurrentCrossfadeTrack = -1;
	m_CrossfadeGroupRunning = false;
}

void Sound::ClearCrossfadeGroup()
{
	StopCrossfadeGroup();
	m_SoLoud->destroyVoiceGroup(m_CrossfadeGroup);
	m_CrossfadeTracks.clear();
	m_CrossfadeGroup = m_SoLoud->createVoiceGroup();
	m_CrossfadeGroupRunning = false;
}

void Sound::CrossfadeTo(int ID)
{
	if (m_CrossfadeTracks.find(ID) != m_CrossfadeTracks.end())
	{
		if (ID != m_CurrentCrossfadeTrack && ID != m_NewCrossfadeTrack)
		{
			m_CrossfadeDelay = 2;
			m_NewCrossfadeTrack = ID;
			m_LastCrossfadeTrack = ID;
		}
	}
}

void Sound::SilenceCrossfadeGroup()
{
	if (m_CrossfadeGroupRunning)
	{
		m_SoLoud->fadeVolume(m_CrossfadeTracks[m_CurrentCrossfadeTrack], 0, 1); // Fade new track in
		m_CrossfadeGroupRunning = false;

		//  Auto-complete any current cross-fade.
		if (m_CurrentCrossfadeTrack != m_NewCrossfadeTrack && m_NewCrossfadeTrack != -1)
		{
			m_CrossfadeDelay = 0;
			m_CurrentCrossfadeTrack = m_NewCrossfadeTrack;
			m_NewCrossfadeTrack = -1;
		}
	}
}

void Sound::RestoreCrossfadeGroup()
{
	m_SoLoud->fadeVolume(m_CrossfadeTracks[m_CurrentCrossfadeTrack], m_MusicVolume, 1); // Fade new track in
	m_CrossfadeGroupRunning = true;
}

void Sound::Shutdown()
{
	m_SongList.clear();
	delete m_QueueBus;
	m_SoLoud->deinit();
}

void Sound::Update()
{
	if (m_IncomingSongID != -1) // We are transitioning to a new song.
	{
		if (m_SongDelaying)
		{
			if (m_SongDelayTimer > 0)
				m_SongDelayTimer -= g_Engine->LastUpdateInSeconds();
			if (m_SongDelayTimer <= 0)  //  Start fading out the previous song, if there is one.
			{
				if (m_CurrentSong)
				{
					//               Log("Sound::Update - Timing out song: " + m_CurrentSong->m_Name);
					m_SoLoud->fadeVolume(m_CurrentSong->m_Handle, 0, m_SongFadeLength);
					m_SoLoud->scheduleStop(m_CurrentSong->m_Handle, m_SongFadeLength);
				}
				m_SongDelaying = false;
				m_SongFading = true;
			}
		}

		if (m_SongFading)
		{
			if (m_SongFadeTimer > 0)
				m_SongFadeTimer -= g_Engine->LastUpdateInSeconds();
			if (m_SongFadeTimer <= 0)
			{
				//            if (m_CurrentSong)
				//               Log("Sound::Update - Fading out song: " + m_CurrentSong->m_Name);
				m_SongFading = false;
				PlaySongEX();
			}
		}
	}

	if (m_InSongTransition && m_SongTransitionTimer > 0)
	{
		m_SongTransitionTimer -= g_Engine->LastUpdateInSeconds();
		if (m_SongTransitionTimer < 0)
			m_InSongTransition = false;
	}
	else if (m_InSongTransition)
	{
		//  This wasn't flagging properly if we had a transition time of 0.
		m_InSongTransition = false;
	}

	if (m_CurrentSong != nullptr)
	{
		//  If we're down to one song in the queue, reloop the queue.
		if (m_CurrentSong->m_Queue->getQueueCount() < 2)
		{
			m_CurrentSong->m_Queue->play(*m_CurrentSong->m_Loop);
		}
	}

	if (m_CrossfadeDelay > 0)
	{
		m_CrossfadeDelay -= g_Engine->LastUpdateInSeconds();
		if (m_CrossfadeDelay < 0)
		{
			m_SoLoud->fadeVolume(m_CrossfadeTracks[m_CurrentCrossfadeTrack], 0, 1); // Fade previous track out
			m_SoLoud->fadeVolume(m_CrossfadeTracks[m_NewCrossfadeTrack], m_MusicVolume, 1); // Fade new track in
			m_CrossfadeDelay = 0;
			m_CurrentCrossfadeTrack = m_NewCrossfadeTrack;
			m_NewCrossfadeTrack = -1;
		}
	}
}

void Sound::Say(string text)
{
	m_Speech->setText(text.c_str());
	m_SoLoud->play(*m_Speech);
}

bool Sound::IsSongPlaying()
{
	return (m_CurrentSong != nullptr);
}

void Sound::PlaySFX(string fName, float tweakrange, float panning, float overridevolume, bool clocked)
{
	SoLoud::Wav* thisWav = g_ResourceManager->GetSound(fName);

	if (clocked)
	{
		if (m_SoundsThisUpdate.find(thisWav) != m_SoundsThisUpdate.end() && g_Engine->GameTimeInMS() - m_SoundsThisUpdate[thisWav] < 60)
			return;
		else
			m_SoundsThisUpdate[thisWav] = g_Engine->GameTimeInMS();
	}

	float desiredvolume;
	if (overridevolume > 0)
		desiredvolume = overridevolume;
	else
		desiredvolume = m_SoundVolume;

	float tweak = 0;
	if (tweakrange != 0)
	{
		tweak = 1.0f - (m_RNG->RandomRangeFloat(0, tweakrange) - (tweakrange / 2));
	}

	int h = m_SoLoud->play(*thisWav, desiredvolume, panning);

	if (tweak != 0)
		m_SoLoud->setRelativePlaySpeed(h, tweak);
	//   Log("Played sound: " + fName);
}

void Sound::PlaySong(int ID, float delay, float crossfadelength, bool skipintro)
{
	//  Make sure the song requested is in the list.
	if (m_SongList.find(ID) == m_SongList.end())
		return;

	//  If we used lazy initialization, load the song now.
	if (m_SongList[ID]->m_Loop == nullptr)
	{
		m_SongList[ID]->m_Loop = g_ResourceManager->GetSound(m_SongList[ID]->m_LoopName);
	}
	if (m_SongList[ID]->m_IntroName != "" && m_SongList[ID]->m_Intro == nullptr)
	{
		m_SongList[ID]->m_Intro = g_ResourceManager->GetSound(m_SongList[ID]->m_IntroName);
	}

	//  Set up everything so that Update() can handle the transition when the time comes.
	m_IncomingSongID = ID;
	m_SongSkipIntro = skipintro;

	if (m_SongDelaying == false && m_SongFading == false) //  We are not already transitioning
	{
		m_SongDelayTimer = delay;
		m_SongFadeLength = crossfadelength;
		m_SongFadeTimer = crossfadelength;
		m_SongDelaying = true;
		m_SongFading = false;
		m_InSongTransition = true;
		m_SongTransitionTimer = crossfadelength * 2;
	}

	//   Log("Sound::PlaySong - Queuing Song: " + m_SongList[ID]->m_Name);
}

//  Because Songs can be played "delayed" and have variable-timed crossfades,
//  sometimes a song won't actually play when you call PlaySong().  This is
//  the function that actually plays the song.
void Sound::PlaySongEX()
{
	//   Log("Sound::PlaySongEX - Playing Song: " + m_SongList[m_IncomingSongID]->m_Name);
	m_CurrentSong = m_SongList[m_IncomingSongID].get();
	m_CurrentSongID = m_IncomingSongID;
	delete m_CurrentSong->m_Queue;
	m_CurrentSong->m_Queue = new SoLoud::Queue();

	m_CurrentSong->m_Handle = m_QueueBus->play(*m_CurrentSong->m_Queue, 0);
	m_SoLoud->fadeVolume(m_CurrentSong->m_Handle, m_MusicVolume, m_SongFadeLength);
	if (m_CurrentSong->m_Intro != nullptr && m_SongSkipIntro == false)
	{
		m_CurrentSong->m_Queue->play(*m_CurrentSong->m_Intro);
	}
	else
	{
		m_CurrentSong->m_Queue->play(*m_CurrentSong->m_Loop);
	}
	m_CurrentSong->m_Queue->play(*m_CurrentSong->m_Loop);
	m_IncomingSongID = -1;
}

void Sound::StopSong(float delay)
{
	if (m_CurrentSong != nullptr)
	{
		m_SoLoud->fadeVolume(m_CurrentSong->m_Handle, 0, delay);
		m_SoLoud->scheduleStop(m_CurrentSong->m_Handle, delay);
		m_CurrentSong = nullptr;
		m_CurrentSongID = -1;
	}
	else // If a song has been queued but isn't actually playing yet, turn off the flag so that it never plays.
	{
		m_CurrentSongID = -1;
		m_IncomingSongID = -1;
	}
}

void Sound::PlaySFXGroup(string fName, int numberofsounds, string fExt)
{
	stringstream finalfilename;
	finalfilename.str("");

	int soundtoplay = (rand() % numberofsounds) + 1;

	finalfilename << fName << soundtoplay << fExt;

	PlaySFX(finalfilename.str().c_str());
}

void Sound::SetSoundVolume(float newVolume)
{
	if (newVolume > 1)
		newVolume = 1;
	if (newVolume < 0)
		newVolume = 0;

	m_SoundVolume = newVolume;

	g_Engine->m_EngineConfig.SetNumber("sound_volume", m_SoundVolume);
}

void Sound::SetMusicVolume(float newVolume)
{
	if (newVolume > 1)
		newVolume = 1;
	if (newVolume < 0)
		newVolume = 0;

	m_MusicVolume = newVolume;

	if (m_CurrentSong != nullptr)
		m_SoLoud->setVolume(m_CurrentSong->m_Handle, m_MusicVolume);

	if (m_CrossfadeGroupRunning)
		m_SoLoud->setVolume(m_CrossfadeTracks[m_CurrentCrossfadeTrack], m_MusicVolume);

	g_Engine->m_EngineConfig.SetNumber("music_volume", m_MusicVolume);
}

void Sound::AddSong(int ID, std::string name, std::string intro, std::string loop, bool lazy)
{
	if (m_SongList.find(ID) == m_SongList.end()) // Song doesn't already exist
		m_SongList[ID] = make_unique<Song>(ID, name, intro, loop, lazy);
}

void Sound::AddSong(int ID, std::string name, std::string loop, bool lazy)
{
	if (m_SongList.find(ID) == m_SongList.end()) // Song doesn't already exist
		m_SongList[ID] = make_unique<Song>(ID, name, "", loop, lazy);
}

float* Sound::GetFFT(void)
{
	float* fft = m_SoLoud->calcFFT();
	return fft;
}