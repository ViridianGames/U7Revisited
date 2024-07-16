#include "Globals.h"
#include "Engine.h"
#include "ResourceManager.h"
#include "StateMachine.h"
#include "Logging.h"
#include <sstream>
#include <fstream>
#include <time.h>
using namespace std;

void Engine::Init(const std::string& configfile)
{
	Log("Starting Engine::Init()");
	m_Done = false;
	m_ConfigFileName = configfile;
	m_EngineConfig.Load(configfile);

	g_ResourceManager = make_unique<ResourceManager>();
	g_ResourceManager->Init(configfile);
	g_StateMachine = make_unique<StateMachine>();
	g_StateMachine->Init(configfile);

	m_GameUpdates = 0;

	m_CurrentFrame = 0;

	m_debugDrawing = false;

	m_RenderWidth = m_EngineConfig.GetNumber("h_renderres");
	m_RenderHeight = m_EngineConfig.GetNumber("v_renderres");

	m_ScreenWidth = m_EngineConfig.GetNumber("h_res");
	m_ScreenHeight = m_EngineConfig.GetNumber("v_res");

	m_pixelated = false;

	//  Initialize Raylib and the screen.
	InitWindow(g_Engine->m_EngineConfig.GetNumber("h_res"), g_Engine->m_EngineConfig.GetNumber("v_res"), "Ultima VII: Revisited");
	if (g_Engine->m_EngineConfig.GetNumber("full_screen") == 1)
	{
		ToggleFullscreen();
	}
	SetTargetFPS(144);
	HideCursor(); // We'll use our own.

	m_renderTarget = LoadRenderTexture(m_RenderWidth, m_RenderHeight);

	Log("Done with Engine::Init()");
}

void Engine::Shutdown()
{
	UnloadRenderTexture(m_renderTarget);
	g_StateMachine->Shutdown();
	g_ResourceManager->Shutdown();
}

void Engine::Update()
{
	g_ResourceManager->Update();
	g_StateMachine->Update();

	if (WindowShouldClose())
	{
		m_Done = true;
	}

	// F12 takes a screenshot
	if (IsKeyPressed(KEY_F12))
	{
		CaptureScreenshot();
	}

	if (IsKeyPressed(KEY_SPACE))
	{
		m_pixelated = !m_pixelated;
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
	if (m_pixelated)
	{
		BeginTextureMode(m_renderTarget);
	}
	else
	{
		BeginDrawing();
	}

	g_ResourceManager->Draw();
	g_StateMachine->Draw();

	if (m_debugDrawing)
	{
		DrawFPS(0, 0);
	}

	if (m_pixelated)
	{
		EndTextureMode();
		BeginDrawing();
		DrawTexturePro(m_renderTarget.texture, { 0, 0, m_RenderWidth, -m_RenderHeight }, { 0, 0, m_ScreenWidth, m_ScreenHeight }, { 0, 0 }, 0, WHITE);
	}
	
	EndDrawing();

}

void Engine::CaptureScreenshot() {
	char filename[40];
	struct tm* timenow;

	time_t now = time(NULL);
	timenow = gmtime(&now);

	strftime(filename, sizeof(filename), "screenshot_%Y-%m-%d_%H_%M_%S.png", timenow);
	TakeScreenshot(filename);
}
