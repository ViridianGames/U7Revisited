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

}

void PatreonVillageState::OnEnter()
{
	ClearConsole();
	m_LastUpdate = 0;
	//g_SoundSystem->PlayMusic("Audio/Music/22bg.ogg");
	m_currentFadeAlpha = 0;
	m_mouseMoved = false;
	m_fadeState = FadeState::FADE_IN;
	m_fadeTime = 1.0f;
	m_fadeDuration = 1.0f;
	g_camera.target = m_waypoints[m_currentWaypoint];
	CameraUpdate(true);
	g_cameraRotation = 0;
	g_CameraRotateSpeed = 0;
	g_cameraSpeed = 50.0f;
}

void PatreonVillageState::OnExit()
{
	//g_SoundSystem->StopMusic("Audio/Music/22bg.ogg");
}

void PatreonVillageState::Shutdown()
{
}

void PatreonVillageState::Update()
{
	UpdateSortedVisibleObjects();

	if (g_shouldCameraMoveToDestination)
	{
		if (!Vector3Equals(g_cameraDestination, g_camera.target))
		{
			Vector3 current = g_camera.target;
			Vector3 thisdest = Vector3Subtract(g_cameraDestination, g_camera.target);
			if (abs(Vector3Length(thisdest)) < (g_cameraSpeed * GetFrameTime()))
			{
				current = g_cameraDestination;
				g_shouldCameraMoveToDestination = false;
			}
			else
			{
				thisdest = Vector3Normalize(thisdest);
				thisdest = Vector3Scale(thisdest, (g_cameraSpeed * GetFrameTime()));
				current = Vector3Add(current, thisdest);
			}

			if (current.x < 0) current.x = 0;
			if (current.x > 3072) current.x = 3072;
			if (current.z < 0) current.z = 0;
			if (current.z > 3072) current.z = 3072;

			Vector3 camPos = { g_cameraDistance, g_cameraDistance, g_cameraDistance };
			camPos = Vector3RotateByAxisAngle(camPos, Vector3{ 0, 1, 0 }, g_cameraRotation);

			g_camera.target = current;
			g_camera.position = Vector3Add(current, camPos);
			g_camera.fovy = g_cameraDistance;
		}
	}

	g_Terrain->CalculateLighting();
	g_Terrain->Update();

	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_StateMachine->MakeStateTransition(STATE_TITLESTATE);
	}

	if (abs(GetMouseDelta().x) > 25 || abs(GetMouseDelta().y) > 25)
	{
		m_mouseMoved = true;
	}

	if (m_fadeState == FadeState::FADE_OUT)
	{
		m_fadeTime += GetFrameTime();
		if (m_fadeTime > m_fadeDuration)
		{
			m_fadeTime = m_fadeDuration;
			m_fadeState = FadeState::FADE_NONE;
		}
		m_currentFadeAlpha = int(255 * (m_fadeTime / m_fadeDuration));
	}

	else if (m_fadeState == FadeState::FADE_IN)
	{
		m_fadeTime -= GetFrameTime();
		if (m_fadeTime < 0)
		{
			m_fadeTime = 0;
			m_fadeState = FadeState::FADE_NONE;
		}
		m_currentFadeAlpha = int(255 * (m_fadeTime / m_fadeDuration));
	}
	else
	{
		m_currentFadeAlpha = 0;
	}

	if (m_cameraTimer <= 0)
	{
		m_cameraTimer = 10.0f;
		m_currentWaypoint++;
		if (m_currentWaypoint >= m_waypoints.size())
		{
			m_currentWaypoint = 0;
		}
		g_cameraDestination = m_waypoints[m_currentWaypoint];
		g_shouldCameraMoveToDestination = true;
	}
	else if (!g_shouldCameraMoveToDestination)
	{
		m_cameraTimer -= GetFrameTime();
	}
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

	//  DrawNPCBarks
	for (auto object : g_sortedVisibleObjects)
	{
		if (object->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
		{
			Vector3 textPos = { object->m_Pos.x, object->m_Pos.y + object->m_shapeData->m_Dims.y * 1.25f, object->m_Pos.z };
			string barkText = object->m_NPCData->name;

			// Convert 3D world position to 2D screen coordinates
			Vector2 screenPos = GetWorldToScreen(textPos, g_camera);
			screenPos.x /= g_DrawScale;
			screenPos.x = int(screenPos.x);
			screenPos.y /= g_DrawScale;
			screenPos.y = int(screenPos.y);
			screenPos.y -= g_ConversationFont->baseSize * 1.5f; // Offset above the object

			int xoffset = 8 * g_DrawScale;
			float width = MeasureTextEx(*g_ConversationFont,  barkText.c_str(), g_ConversationFont->baseSize, 1).x + xoffset;
			screenPos.x -= width / 2;
			float height = g_ConversationFont->baseSize * 1.2;

			DrawRectangleRounded({ screenPos.x, screenPos.y, width, height }, 5, 100, { 0, 0, 0, 192 });
			DrawTextEx(*g_ConversationFont, barkText.c_str(), { float(screenPos.x) + xoffset / 2, float(screenPos.y) + (height * .1f) }, g_ConversationFont->baseSize, 1, YELLOW);
		}
	}

	DrawOutlinedText(g_SmallFont, "Camera Dest: " + to_string(m_waypoints[m_currentWaypoint].x) + " " + to_string(m_waypoints[m_currentWaypoint].z), { 4, 208 }, g_SmallFont->baseSize, 1, WHITE);
	DrawOutlinedText(g_SmallFont, "Camera Pos: " + to_string(g_camera.target.x) + " " + to_string(g_camera.target.z), { 4, 220 }, g_SmallFont->baseSize, 1, WHITE);

	if (m_mouseMoved)
	{
		DrawOutlinedText(g_SmallFont, "Press ESC to return to the main menu.", {4, 4}, g_SmallFont->baseSize, 1, WHITE);
	}

	DrawOutlinedText(g_SmallFont, "Other Patrons:", {4, 300}, g_SmallFont->baseSize, 1, WHITE);

	//  Draw any tooltips
	EndTextureMode();
	DrawTexturePro(g_guiRenderTarget.texture,
	               {0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height)},
	               {
		               0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth),
		               -float(g_Engine->m_ScreenHeight)
	               },
	               {0, 0}, 0, WHITE);

	DrawRectangle(0, 0, g_Engine->m_ScreenWidth, g_Engine->m_ScreenHeight, { 0, 0, 0, m_currentFadeAlpha });
}