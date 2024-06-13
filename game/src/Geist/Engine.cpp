#include "Globals.h"
#include "Engine.h"
#include "ResourceManager.h"
#include "StateMachine.h"
#include "Logging.h"
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

	g_ResourceManager = make_unique<ResourceManager>();
	g_ResourceManager->Init(configfile);
	g_StateMachine = make_unique<StateMachine>();
	g_StateMachine->Init(configfile);

	m_GameUpdates = 0;

	m_CurrentFrame = 0;

	m_debugDrawing = false;

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

	if (WindowShouldClose())
	{
		m_Done = true;
	}

	if (IsKeyPressed(KEY_F9))
	{
		m_debugDrawing = !m_debugDrawing;
	}

	++m_GameUpdates;
}

void Engine::Draw()
{
	BeginDrawing();

	g_ResourceManager->Draw();
	g_StateMachine->Draw();

	if (m_debugDrawing)
	{
		DrawFPS(0, 0);
	}

	EndDrawing();
}
