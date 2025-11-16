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

#include "Object.h"
#include "Config.h"

class Engine : public Object
{
public:
	Engine()
		: m_Done(false)
		, m_CurrentFrame(0)
		, m_FrameRate(0.0f)
		, m_MillisecondsThisFrame(0.0f)
		, m_Frames{0}
		, m_DrawFrames{0}
		, m_UpdateFrames{0}
		, m_DrawTime(0)
		, m_UpdateTime(0)
		, m_debugDrawing(false)
		, m_RenderWidth(0.0f)
		, m_RenderHeight(0.0f)
		, m_ScreenWidth(0.0f)
		, m_ScreenHeight(0.0f)
	{}

	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string &configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	void CaptureScreenshot();

	Config m_EngineConfig;
	bool m_Done;
	bool m_askedToExit = false;  // Track if we've shown exit confirmation dialog
	std::string m_ConfigFileName;

	int m_GameUpdates = 0;
	int m_Frames[50];
	int m_CurrentFrame;
	float m_FrameRate;
	float m_MillisecondsThisFrame;

	int m_DrawFrames[50];
	int m_UpdateFrames[50];

	unsigned int m_DrawTime;
	unsigned int m_UpdateTime;

	bool m_debugDrawing;

	float m_RenderWidth;
	float m_RenderHeight;

	float m_ScreenWidth;
	float m_ScreenHeight;
};

#endif
