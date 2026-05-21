#include <Geist/Globals.h>
#include <Geist/Engine.h>
#include <Geist/ResourceManager.h>
#include <Geist/StateMachine.h>
#include <Geist/ScriptingSystem.h>
#include <Geist/SoundSystem.h>
#include <Geist/InputSystem.h>
#include <Geist/Logging.h>
#include <sstream>
#include <fstream>
#include <time.h>

using namespace std;

void Engine::Init(const std::string &configfile)
{
	Log("Starting Engine::Init()");
	m_Done = false;
	m_ConfigFileName = configfile;
	m_EngineConfig.Load(configfile);

	g_ResourceManager = make_unique<ResourceManager>();
	g_ResourceManager->Init(configfile);
	g_StateMachine = make_unique<StateMachine>();
	g_StateMachine->Init(configfile);
	g_ScriptingSystem = make_unique<ScriptingSystem>();
	g_ScriptingSystem->Init(configfile);
	g_InputSystem = make_unique<InputSystem>();
	g_InputSystem->Init(configfile);

	m_GameUpdates = 0;

	m_CurrentFrame = 0;

	m_debugDrawing = false;

	m_RenderWidth = m_EngineConfig.GetNumber("h_renderres");
	m_RenderHeight = m_EngineConfig.GetNumber("v_renderres");

	m_ScreenWidth = m_EngineConfig.GetNumber("h_res");
	m_ScreenHeight = m_EngineConfig.GetNumber("v_res");

	//  Initialize Raylib and the screen.
	std::string windowTitle = m_EngineConfig.GetString("name");
	InitWindow(g_Engine->m_EngineConfig.GetNumber("h_res"), g_Engine->m_EngineConfig.GetNumber("v_res"), windowTitle.c_str());
	SetExitKey(KEY_NULL); // We'll handle exiting with ESC
	if (g_Engine->m_EngineConfig.GetNumber("full_screen") == 1)
	{
		ToggleFullscreen();
	}
	//SetTargetFPS(120);

	//  Relies on Raylib, so let's set it up after Raylib has started.
	g_SoundSystem = make_unique<SoundSystem>();
	g_SoundSystem->Init(configfile);

	HideCursor(); // We'll use our own.

	Log("Done with Engine::Init()");
}

void Engine::Shutdown()
{
	g_StateMachine->Shutdown();
	g_ResourceManager->Shutdown();
	g_InputSystem->Shutdown();
	CloseAudioDevice();
}

void Engine::Update()
{
	double time = GetFrameTime();
	m_UpdateTime = GetTime();

	g_InputSystem->Update();
	g_ResourceManager->Update();
	g_StateMachine->Update();
	g_ScriptingSystem->Update();
	g_SoundSystem->Update();

	m_UpdateTime = GetTime() - m_UpdateTime;

	//  Drawtime is updated in Draw()

	for (int i = 1; i < 50; ++i)
	{
		m_UpdateFrames[i - 1] = m_UpdateFrames[i];
	}
	m_UpdateFrames[49] = m_UpdateTime;

	// int _CurrentTime = int(GetTime() * 1000);
	//
	// m_Frames[m_CurrentFrame] = _CurrentTime;
	// m_FrameRate = 1000.0f / ((float)(m_Frames[m_CurrentFrame] - m_Frames[(m_CurrentFrame + 1) % 50]) / 50);
	// m_MillisecondsThisFrame = (float(m_Frames[m_CurrentFrame] - m_Frames[(m_CurrentFrame + 1) % 50]) / 50);
	// m_CurrentFrame++;
	// m_CurrentFrame %= 50;

	if (WindowShouldClose())
	{
		m_Done = true;
	}

	// F12 takes a screenshot
	if (IsKeyPressed(KEY_F12))
	{
		CaptureScreenshot();
	}

	// F9 toggles the debug drawing
	if (IsKeyPressed(KEY_F9))
	{
		m_debugDrawing = !m_debugDrawing;
	}

	++m_GameUpdates;
}

void Engine::Draw()
{
	m_DrawTime = GetTime();
	BeginDrawing();
	ClearBackground(BLACK);
	g_ResourceManager->Draw();
	g_StateMachine->Draw();
	g_ScriptingSystem->Draw();
	g_InputSystem->Draw();
	EndDrawing();
	m_DrawTime = GetTime() - m_DrawTime;

	for (int i = 1; i < 50; ++i)
	{
		m_DrawFrames[i - 1] = m_DrawFrames[i];
	}
	m_DrawFrames[49] = m_DrawTime;
}

void Engine::CaptureScreenshot()
{
	char filename[40];
	struct tm *timenow;

	time_t now = time(NULL);
	timenow = gmtime(&now);

	strftime(filename, sizeof(filename), "screenshot_%Y-%m-%d_%H_%M_%S.png", timenow);
	TakeScreenshot(filename);
}
