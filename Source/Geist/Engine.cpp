#include "Globals.h"
#include "Engine.h"
#include "ResourceManager.h"
#include "StateMachine.h"
#include "ScriptingSystem.h"
#include "Logging.h"
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

	m_GameUpdates = 0;

	m_CurrentFrame = 0;

	m_debugDrawing = false;

	m_RenderWidth = m_EngineConfig.GetNumber("h_renderres");
	m_RenderHeight = m_EngineConfig.GetNumber("v_renderres");

	m_ScreenWidth = m_EngineConfig.GetNumber("h_res");
	m_ScreenHeight = m_EngineConfig.GetNumber("v_res");

	//  Initialize Raylib and the screen.
#ifdef __APPLE__
	SetConfigFlags(FLAG_WINDOW_RESIZABLE);
#endif
	InitWindow(g_Engine->m_EngineConfig.GetNumber("h_res"), g_Engine->m_EngineConfig.GetNumber("v_res"), "Ultima VII: Revisited");
	SetExitKey(KEY_NULL);

#ifdef __APPLE__
	int monitorWidth = GetMonitorWidth(0);
	int monitorHeight = GetMonitorHeight(0);
	int targetWidth = monitorWidth - 20;
	int targetHeight = monitorHeight - 100;
	
	SetWindowPosition(10, 50);
	SetWindowSize(targetWidth, targetHeight);
	WaitTime(0.1);
	
	int actualScreenWidth = GetScreenWidth();
	int actualScreenHeight = GetScreenHeight();
	
	BeginDrawing();
	ClearBackground(BLACK);
	EndDrawing();
	
	m_ScreenWidth = actualScreenWidth;
	m_ScreenHeight = actualScreenHeight;
	
	extern float g_DrawScale;
	g_DrawScale = float(m_ScreenHeight) / float(m_RenderHeight);
	
	Log("=== MACOS DEBUG SCALING INFO ===");
	Log("Monitor dimensions: " + std::to_string(monitorWidth) + "x" + std::to_string(monitorHeight));
	Log("Target window size: " + std::to_string(targetWidth) + "x" + std::to_string(targetHeight));
	Log("Actual screen size: " + std::to_string(actualScreenWidth) + "x" + std::to_string(actualScreenHeight));
	Log("Engine screen size: " + std::to_string(m_ScreenWidth) + "x" + std::to_string(m_ScreenHeight));
	Log("Render resolution: " + std::to_string(m_RenderWidth) + "x" + std::to_string(m_RenderHeight));
	Log("g_DrawScale: " + std::to_string(g_DrawScale));
	Log("=== END DEBUG INFO ===");
#endif
	g_ResourceManager = make_unique<ResourceManager>();
	g_ResourceManager->Init(configfile);
	g_StateMachine = make_unique<StateMachine>();
	g_StateMachine->Init(configfile);
	g_ScriptingSystem = make_unique<ScriptingSystem>();
	g_ScriptingSystem->Init(configfile);

	if (g_Engine->m_EngineConfig.GetNumber("full_screen") == 1)
	{
		ToggleFullscreen();
	}
	SetTargetFPS(60);
	HideCursor(); // We'll use our own.

	Log("Done with Engine::Init()");
}

void Engine::Shutdown()
{
	g_StateMachine->Shutdown();
	g_ResourceManager->Shutdown();
}

void Engine::Update()
{
	g_ResourceManager->Update();
	g_StateMachine->Update();
	g_ScriptingSystem->Update();

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
	g_ResourceManager->Draw();
	g_StateMachine->Draw();
	g_ScriptingSystem->Draw();
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
