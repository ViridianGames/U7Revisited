#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/StateMachine.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"
#include "PatreonVillageState.h"
#include "MainState.h"
#include "rlgl.h"

#include <list>
#include <string>
#include <sstream>
#include <math.h>
#include <fstream>
#include <algorithm>

#include "LoadSaveState.h"
#include "Logging.h"
#include "SoundSystem.h"

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  PatreonVillageState
////////////////////////////////////////////////////////////////////////////////

PatreonVillageState::~PatreonVillageState()
{
	Shutdown();
}

void PatreonVillageState::Init(const string& configfile)
{
	m_mouseMoved = false;
}

void PatreonVillageState::OnEnter()
{
	ClearConsole();
	m_LastUpdate = 0;
	g_SoundSystem->PlayMusic("Audio/Music/22bg.ogg");
}

void PatreonVillageState::OnExit()
{
	g_SoundSystem->StopMusic("Audio/Music/22bg.ogg");
}

void PatreonVillageState::Shutdown()
{
}

void PatreonVillageState::Update()
{
	UpdateSortedVisibleObjects();

	//  Slow rotate on the title screen
	g_CameraRotateSpeed = 0.001f;
	g_cameraRotation += g_CameraRotateSpeed;

	Vector3 current = g_camera.target;

	Vector3 finalmovement = Vector3RotateByAxisAngle(g_CameraMovementSpeed, Vector3{0, 1, 0}, g_cameraRotation);

	current = Vector3Add(current, finalmovement);

	if (current.x < 0) current.x = 0;
	if (current.x > 3072) current.x = 3072;
	if (current.z < 0) current.z = 0;
	if (current.z > 3072) current.z = 3072;

	Vector3 camPos = {g_cameraDistance, g_cameraDistance, g_cameraDistance};
	camPos = Vector3RotateByAxisAngle(camPos, Vector3{0, 1, 0}, g_cameraRotation);

	g_camera.target = current;
	g_camera.position = Vector3Add(current, camPos);
	g_camera.fovy = g_cameraDistance;

	g_Terrain->CalculateLighting();
	g_Terrain->Update();

	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_StateMachine->MakeStateTransition(STATE_TITLESTATE);
	}

	// if (m_fadeState == FadeState::FADE_OUT)
	// {
	// 	m_fadeTime += GetFrameTime();
	// 	if (m_fadeTime > m_fadeDuration)
	// 	{
	// 		m_fadeTime = m_fadeDuration;
	// 		m_fadeState = FadeState::FADE_NONE;
	// 	}
	// 	m_currentFadeAlpha = int(255 * (m_fadeTime / m_fadeDuration));
	// }
	//
	// else if (m_fadeState == FadeState::FADE_IN)
	// {
	// 	m_fadeTime -= GetFrameTime();
	// 	if (m_fadeTime < 0)
	// 	{
	// 		m_fadeTime = 0;
	// 		m_fadeState = FadeState::FADE_NONE;
	// 	}
	// 	m_currentFadeAlpha = int(255 * (m_fadeTime / m_fadeDuration));
	// }
	// else
	// {
	// 	m_currentFadeAlpha = 0;
	// }
}

void PatreonVillageState::FadeIn(float fadeTime)
{
	m_fadeState = FadeState::FADE_IN;
	m_fadeDuration = fadeTime;
	m_fadeTime = 0;
}

void PatreonVillageState::FadeOut(float fadeTime)
{
	m_fadeState = FadeState::FADE_OUT;
	m_fadeDuration = fadeTime;
	m_fadeTime = 0;
}


void PatreonVillageState::Draw()
{
	//rlSetBlendFactors(RL_SRC_ALPHA, RL_ONE_MINUS_SRC_ALPHA, RL_MIN);
	rlSetBlendMode(BLEND_ALPHA);

	ClearBackground(Color{0, 0, 0, 255});

	BeginMode3D(g_camera);

	//  Draw the terrain
	g_Terrain->Draw();

	//  Draw the objects
	for (auto object : g_sortedVisibleObjects)
	{
		if (object->m_Pos.y <= 4 && object->m_drawType != ShapeDrawType::OBJECT_DRAW_FLAT)
		{
			object->Draw();
		}
	}

	rlDisableDepthMask();
	for (auto object : g_sortedVisibleObjects)
	{
		if (object->m_Pos.y <= 4 && object->m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
		{
			object->Draw();
		}
	}
	rlEnableDepthMask();


	EndMode3D();

	//  Draw GUI overlay
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({0, 0, 0, 0});

	//  Draw the minimap and marker

	DrawConsole();

	//  Draw version number in lower-right

	if (m_mouseMoved)
	{
		DrawOutlinedText(g_SmallFont, "Press ESC to return to the main menu.", {8, 8}, g_SmallFont->baseSize * g_DrawScale, 1, WHITE);
	}

	//  Draw any tooltips
	EndTextureMode();
	DrawTexturePro(g_guiRenderTarget.texture,
	               {0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height)},
	               {
		               0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth),
		               -float(g_Engine->m_ScreenHeight)
	               },
	               {0, 0}, 0, WHITE);
}