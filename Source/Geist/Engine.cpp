#include "Globals.h"
#include "SDL.h"
#include <sstream>
#include <fstream>
using namespace std;

void Engine::Init(const std::string& configfile)
{
	ofstream logstream(GetLogFileName().c_str(), ofstream::trunc);
	Log("Starting Engine::Init()");
	m_Done = false;
	m_ConfigFileName = configfile;

	m_EngineConfig.Load(configfile);

#ifdef REQUIRES_STEAM
	g_SteamManager = make_unique<SteamManager>();
	g_SteamManager->Init(configfile);
#endif

	SDL_Init(SDL_INIT_EVERYTHING);
	SDL_ShowCursor(0);

	g_ResourceManager = make_unique<ResourceManager>();
	g_ResourceManager->Init(configfile);
	g_MemoryManager = make_unique<MemoryManager>();
	g_MemoryManager->Init(configfile);
	g_Display = make_unique<Display>();
	g_Display->Init(configfile);
	g_Input = make_unique<Input>();
	g_Input->Init(configfile);
	g_Sound = make_unique<Sound>();
	g_Sound->Init(configfile);
	g_StateMachine = make_unique<StateMachine>();
	g_StateMachine->Init(configfile);

	m_StartTime = SDL_GetTicks();
	m_GameTimeInMS = 0;
	m_GameTimeInSeconds = 0;
	m_LastUpdateInMS = 0;
	m_LastUpdateInSeconds = 0;

	m_GameUpdates = 0;

	m_CurrentFrame = 0;

	m_MSBetweenUpdates = (unsigned int)m_EngineConfig.GetNumber("milliseconds_between_updates");
	if (m_MSBetweenUpdates == 0)
		m_MSBetweenUpdates = 16; //  Default to 60 FPS.

	Log("Done with Engine::Init()");
}

void Engine::Shutdown()
{
	g_StateMachine->Shutdown();
	g_Sound->Shutdown();
	g_Input->Shutdown();
	g_Display->Shutdown();
	g_MemoryManager->Shutdown();
	g_ResourceManager->Shutdown();
#ifdef REQUIRES_STEAM
	g_SteamManager->Shutdown();
#endif

	SDL_Quit();
}

void Engine::Update()
{
	unsigned int _CurrentTime = SDL_GetTicks();
	SDL_PumpEvents();

	m_LastUpdateInMS = (_CurrentTime - m_StartTime) - m_GameTimeInMS;
	m_LastUpdateInSeconds = float(m_LastUpdateInMS) / 1000.0f;

	// the game time will accurately reflect real time, but LastUpdateInMS and InSeconds will be capped at a minimum of 10fps, to prevent super-long updates from running which break physics.
	if (m_LastUpdateInMS > 100)
	{
		m_LastUpdateInMS = 100;
		m_LastUpdateInSeconds = 0.1f;
	}
	m_GameTimeInMS = _CurrentTime - m_StartTime;
	m_GameTimeInSeconds = float(m_GameTimeInMS) / 1000.0f;

	m_Frames[m_CurrentFrame] = _CurrentTime;
	m_FrameRate = 1000.0f / ((float)(m_Frames[m_CurrentFrame] - m_Frames[(m_CurrentFrame + 1) % 50]) / 50);
	m_MillisecondsThisFrame = (float(m_Frames[m_CurrentFrame] - m_Frames[(m_CurrentFrame + 1) % 50]) / 50);
	m_CurrentFrame++;
	m_CurrentFrame %= 50;
	m_UpdateTime = Time();

	if (1)	// updates are capped at 50ms. If an update takes longer, it's split into multiple updates. This causes even more slowdown since it's more processing, but since
		// slowdown is usually in the graphics, it may not hurt much. The main thing is, it fixes physics issues
	{
		unsigned int lastMS = m_LastUpdateInMS;
		float lastTime = m_LastUpdateInSeconds;
		unsigned int storeLastMS = m_LastUpdateInMS;
		float storeLastTime = m_LastUpdateInSeconds;

		while (lastMS > 0)
		{
			if (lastMS > 50)
			{
				m_LastUpdateInMS = 50;
				m_LastUpdateInSeconds = 0.05f;
				lastMS -= 50;
				lastTime = (float)lastMS / 1000.0f;
			}
			else
			{
				m_LastUpdateInMS = lastMS;
				m_LastUpdateInSeconds = lastTime;
				lastMS = 0;
				lastTime = 0;
			}
			g_Input->Update();
			g_ResourceManager->Update();
			g_MemoryManager->Update();
			g_Sound->Update();
			g_Display->Update();
			g_StateMachine->Update();
		}
		m_LastUpdateInMS = storeLastMS;
		m_LastUpdateInSeconds = storeLastTime;
	}
	else // old-fashioned updates: no matter how long the delay was, we just do one update
	{
		g_Input->Update();
		g_ResourceManager->Update();
		g_MemoryManager->Update();
		g_Sound->Update();
		g_Display->Update();
		g_StateMachine->Update();
	}
#ifdef REQUIRES_STEAM
	g_SteamManager->Update();
#endif

	m_UpdateTime = Time() - m_UpdateTime;

	for (int i = 1; i < 50; ++i)
	{
		m_UpdateFrames[i - 1] = m_UpdateFrames[i];
		m_DrawFrames[i - 1] = m_DrawFrames[i];
	}

	m_UpdateFrames[49] = m_UpdateTime;
	m_DrawFrames[49] = m_DrawTime;

	++m_GameUpdates;
	m_AverageUpdate = m_GameTimeInMS / m_GameUpdates;
}

void Engine::Draw()
{
	m_DrawTime = Time();

	g_Input->Draw();
	g_ResourceManager->Draw();
	g_MemoryManager->Draw();
	g_Sound->Draw();
	g_StateMachine->Draw();
	g_Display->Draw();

	m_DrawTime = Time() - m_DrawTime;
}

unsigned int Engine::Time()
{
	return SDL_GetTicks();
}

float Engine::TimeInSeconds()
{
	return float(SDL_GetTicks()) / 1000.0f;
}