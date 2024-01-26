///////////////////////////////////////////////////////////////////////////
//
// Name:     ENGINE.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  The master subsystem, which initializes, updates and destroys
//           all the others.  This subsystem also owns things lots of other
//           subsystems depend on, like the timer, logging, and RNG
//           subsystems.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _ENGINE_H_
#define _ENGINE_H_

#include <unordered_map>

#include "SDL.h"
#include "Object.h"
#include "Config.h"

class Engine : public Object
{
public:
	Engine() {};

	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	//  Timer Stuff
	unsigned int  Time();
	float         TimeInSeconds();
	unsigned int  GameTimeInMS() { return m_GameTimeInMS; }
	float         GameTimeInSeconds() { return m_GameTimeInSeconds; }
	unsigned int  GameUpdates() { return m_GameUpdates; }
	unsigned int  StartTime() { return m_StartTime; }
	float		  LastUpdateInSeconds() { return m_LastUpdateInSeconds; }
	unsigned int  LastUpdateInMS() { return m_LastUpdateInMS; }

	unsigned int  m_StartTime;         //  The start time of the game, in MS.

	unsigned int  m_GameTimeInMS;      //  The number of MS since the game started
	float         m_GameTimeInSeconds; //  The mnumber of seconds since the game started.
	unsigned int  m_GameUpdates;       //  Number of updates handled since the game started.

	unsigned int  m_LastUpdateInMS;    //  Duration of the most recent update in MS.
	float         m_LastUpdateInSeconds;   //  Duration of the most recent update in seconds.
	unsigned int  m_AverageUpdate;     //  The average duration of an update, used to detect lag.

	unsigned int  m_MSBetweenUpdates;  //  This is the target number of milliseconds we want between updates.  If an update has taken less
	//  time than this, the engine will wait to process the next update.  If you want the engine to run
	//  as fast as possible, set this to 0.

	Config        m_EngineConfig;
	bool          m_Done;
	bool          m_UsingSteam;
	std::string   m_ConfigFileName;

	int           m_Frames[50];
	int           m_CurrentFrame;
	float         m_FrameRate;
	float         m_MillisecondsThisFrame;

	int           m_DrawFrames[50];
	int           m_UpdateFrames[50];

	unsigned int  m_DrawTime;
	unsigned int  m_UpdateTime;
};

#endif