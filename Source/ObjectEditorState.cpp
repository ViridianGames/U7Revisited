#include "Globals.h"
#include "U7Globals.h"
#include "ObjectEditorState.h"

#include <list>
#include <string>
#include <sstream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <algorithm>
#include <unordered_map>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  ObjectEditorState
////////////////////////////////////////////////////////////////////////////////

ObjectEditorState::~ObjectEditorState()
{
	Shutdown();
}

void ObjectEditorState::Init(const string& configfile)
{
	m_currentShape = 150;
	m_currentFrame = 0;
	m_rotating = false;

	m_objectLibrary.resize(1024);
	for (int i = 0; i < 1024; ++i)
	{
		m_objectLibrary[i].resize(32);
	}
}

void ObjectEditorState::OnEnter()
{
	ClearConsole();
}

void ObjectEditorState::OnExit()
{

}

void ObjectEditorState::Shutdown()
{

}

void ObjectEditorState::Update()
{
	//  Handle input

	if (g_Input->WasKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_Done = true;
	}

	unsigned int time = g_Engine->Time();
	g_CameraMoved = false;

	float speed = 50;

	if (g_Input->WasAnyKeyPressed())
	{
		int stopper = 0;
	}
	if (g_Input->IsKeyDown(KEY_q))
	{
		g_CameraRotateSpeed += g_Engine->LastUpdateInSeconds() * 50;
		if (g_CameraRotateSpeed > 8)
		{
			g_CameraRotateSpeed = 8;
		}
		g_CameraMoved = true;
	}

	if (g_Input->IsKeyDown(KEY_e))
	{
		g_CameraRotateSpeed -= g_Engine->LastUpdateInSeconds() * 50;
		if (g_CameraRotateSpeed < -8)
		{
			g_CameraRotateSpeed = -8;
		}
		g_CameraMoved = true;
	}

	if (!g_CameraMoved)
	{
		g_CameraRotateSpeed *= .9;
		if (g_CameraRotateSpeed < 1 && g_CameraRotateSpeed > -1)
		{
			g_CameraRotateSpeed = 0;
		}
	}


	if (g_CameraRotateSpeed != 0)
	{
		g_Display->SetCameraAngle(g_Display->GetCameraAngle() + g_CameraRotateSpeed);
		g_Display->SetHasCameraChanged(true);
		g_Display->UpdateCamera();
		g_CameraMoved = true;
	}

	if (g_Input->WasKeyPressed(KEY_a))
	{
		int newShape = m_currentShape - 1;

		if (g_Input->IsKeyDown(KEY_LSHIFT))
		{
			newShape -= 9;
		}


		if (newShape < 150)
		{
			newShape = 1023;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			m_currentShape = newShape;
		}
		else
		{
			m_currentShape = 0;
		}

		m_currentFrame = 0;
	}

	if (g_Input->WasKeyPressed(KEY_d))
	{
		int newShape = m_currentShape + 1;

		if (g_Input->IsKeyDown(KEY_LSHIFT))
		{
			newShape += 9;
		}

		if (newShape > 1023)
		{
			newShape = 150;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			m_currentShape = newShape;
		}
		else
		{
			m_currentShape = 0;
		}

		m_currentFrame = 0;
	}

	if (g_Input->WasKeyPressed(KEY_w))
	{
		int newFrame = m_currentFrame + 1;
		if (newFrame > 31)
		{
			newFrame = 0;
		}

		if (g_shapeTable[m_currentShape][newFrame].IsValid())
		{
			m_currentFrame = newFrame;
		}
	}

	if (g_Input->WasKeyPressed(KEY_s))
	{
		int newFrame = m_currentFrame - 1;
		if (newFrame < 0)
		{
			newFrame = 31;
		}

		if (g_shapeTable[m_currentShape][newFrame].IsValid())
		{
			m_currentFrame = newFrame;
		}
	}

	if (g_Input->WasKeyPressed(KEY_SPACE))
	{
		ShapeDrawType newDrawType = static_cast<ShapeDrawType>((static_cast<int>(g_shapeTable[m_currentShape][m_currentFrame].GetDrawType()) + 1) % static_cast<int>(ShapeDrawType::OBJECT_DRAW_LAST));
		g_shapeTable[m_currentShape][m_currentFrame].SetDrawType(newDrawType);
	}

	if (g_Input->WasKeyPressed(KEY_F1))
	{
		g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
	}
}


void ObjectEditorState::Draw()
{
	g_Display->ClearScreen();
	g_Display->DrawBox(0, 0, g_Display->GetWidth(), g_Display->GetHeight(), Color(106, 90, 205, 255), true);

	float scale = 4;

	Texture* d = g_shapeTable[m_currentShape][m_currentFrame].GetTexture();
	Texture* t = g_shapeTable[m_currentShape][m_currentFrame].GetTopTexture();
	Texture* f = g_shapeTable[m_currentShape][m_currentFrame].GetFrontTexture();
	Texture* r = g_shapeTable[m_currentShape][m_currentFrame].GetRightTexture();
	g_Display->DrawImage(d,                           0,                                             0, d->GetWidth() * scale, d->GetHeight() * scale, Color(1, 1, 1, 1));	
	g_Display->DrawImage(t,                           0,                  (d->GetHeight() + 2) * scale, t->GetWidth() * scale, t->GetHeight() * scale, Color(1, 1, 1, 1));
	g_Display->DrawImage(r, (t->GetWidth() + 2) * scale,                  (d->GetHeight() + 2) * scale, r->GetWidth() * scale, r->GetHeight() * scale, Color(1, 1, 1, 1));
	g_Display->DrawImage(f,                           0, (d->GetHeight() + d->GetHeight() + 2) * scale, f->GetWidth() * scale, f->GetHeight() * scale, Color(1, 1, 1, 1));

	g_shapeTable[m_currentShape][m_currentFrame].Draw(g_Display->GetCameraLookAtPoint(), 0);

	DrawConsole();

	int yOffset = g_SmallFont->GetHeight();
	int y = -yOffset;

	g_SmallFont->DrawStringRight("Shape: " + to_string(m_currentShape), g_Display->GetWidth(), y += yOffset, Color(1, 1, 1, 1));
	g_SmallFont->DrawStringRight("Frame: " + to_string(m_currentFrame), g_Display->GetWidth(), y += yOffset, Color(1, 1, 1, 1));
	g_SmallFont->DrawStringRight("DrawType: " + g_objectDrawTypeStrings[static_cast<int>(g_shapeTable[m_currentShape][m_currentFrame].GetDrawType())], g_Display->GetWidth(), y += yOffset, Color(1, 1, 1, 1));
	g_SmallFont->DrawStringRight("Q/E: Rotate Left/Right", g_Display->GetWidth(), y += yOffset, Color(1, 1, 1, 1));
	g_SmallFont->DrawStringRight("A/D: Previous/Next Shape", g_Display->GetWidth(), y += yOffset, Color(1, 1, 1, 1));
	g_SmallFont->DrawStringRight("W/S: Previous/Next Frame", g_Display->GetWidth(), y += yOffset, Color(1, 1, 1, 1));
	g_SmallFont->DrawStringRight("LShift + A/D: Jump 10 shapes", g_Display->GetWidth(), y += yOffset, Color(1, 1, 1, 1));

	g_Display->DrawImage(g_Cursor, g_Input->m_MouseX, g_Input->m_MouseY);



}
