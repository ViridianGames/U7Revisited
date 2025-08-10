#include <fstream>
#include <string>
#include <sstream>
#include <algorithm>

#include "U7GumpNumberBar.h"
#include "Geist/Config.h"
#include "Geist/Engine.h"
#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"

#include "raylib.h"
#include "../ThirdParty/raylib/include/raylib.h"

using namespace std;

GumpNumberBar::GumpNumberBar()
{
	m_gui.m_PositionFlag = Gui::GUIP_USE_XY;
	m_gui.m_Width = 0;
	m_gui.m_Height = 0;
	m_gui.m_Active = 1;
	m_gui.m_Editing = false;
	m_gui.m_ActiveElement = -1;
	m_gui.m_LastElement = -2;
	m_gui.m_InputScale = 1;
	m_gui.m_Font = make_shared<Font>(GetFontDefault());
	m_gui.m_Draggable = false;  // Dragging is off by default
	m_gui.m_IsDragging = false;
	m_gui.m_DragOffset = { 0, 0 };
	m_gui.m_DragAreaHeight = 20;  // Default title bar height
	m_IsDead = false;
	m_gui.m_doneButtonId = -3;
	m_minAmount = 0;
	m_maxAmount = 20;

	m_gui.m_Font = g_SmallFont;
	m_gui.SetLayout(253, 170, 220, 150, g_DrawScale, Gui::GUIP_USE_XY);
	m_gui.AddSprite(1004, 0, 0, g_gumpNumberBarBackground);
	m_gui.AddIconButton(1005, 2, -2, g_gumpCheckmarkUp, g_gumpCheckmarkDown, g_gumpCheckmarkUp, "", g_SmallFont.get(), Color{255, 255, 255, 255}, 1, 0, 1, false);
	m_gui.AddIconButton(1006, 24, 5, g_gumpNumberBarLeftArrow, g_gumpNumberBarLeftArrow, g_gumpNumberBarLeftArrow, "", g_SmallFont.get(), Color{255, 255, 255, 255}, 1, 0, 1, false);
	m_gui.AddIconButton(1007, 95, 5, g_gumpNumberBarRightArrow, g_gumpNumberBarRightArrow, g_gumpNumberBarRightArrow, "", g_SmallFont.get(), Color{255, 255, 255, 255}, 1, 0, 1, false);
	m_gui.AddSprite(1008, 32, 5, g_gumpNumberBarMarker);
	m_gui.AddTextArea(1009, g_SmallFont.get(),  to_string(m_currentAmount), 124, 7, 0, g_SmallFont.get()->baseSize, BLACK, GuiTextArea::RIGHT);

	m_gui.SetDoneButtonId(1005);
}

GumpNumberBar::~GumpNumberBar()
{
}

void GumpNumberBar::OnEnter()
{

}

void GumpNumberBar::Setup(int min, int max, int step)
{
	m_minAmount = min;
	m_maxAmount = max;
	m_stepAmount = step;
	m_currentAmount = 0;
	m_isDragging = false;
	m_gui.GetElement(1009)->m_String = to_string(m_currentAmount);
	m_IsDead = false;
	m_gui.m_ActiveElement = -1;
	m_gui.m_Active = true;
	m_gui.m_isDone = false;
	m_gui.m_IsDragging = false;
}

void GumpNumberBar::Update()
{
	if (!m_isDragging)
	{
		m_gui.Update();
	}

	if (m_gui.GetActiveElementID() == 1006)
	{
		m_currentAmount -= m_stepAmount;
		if (m_currentAmount <= m_minAmount)
		{
			m_currentAmount = m_minAmount;
		}
	}

	if (m_gui.GetActiveElementID() == 1007)
	{
		m_currentAmount += m_stepAmount;
		if (m_currentAmount >= m_maxAmount)
		{
			m_currentAmount = m_maxAmount;
		}
	}

	if(m_gui.m_ActiveElement == m_gui.m_doneButtonId)
	{
		m_IsDead = true;
	}

	// Handle scrollbar
	Vector2 mousePos = GetMousePosition();
	mousePos.x /= g_DrawScale;
	mousePos.y /= g_DrawScale;

	if (!m_isDragging)
	{
		if (CheckCollisionPointRec(mousePos, Rectangle{ m_gui.m_Pos.x + 32, m_gui.m_Pos.y + 9,
		60, 8 }))
		{
			if (IsMouseButtonDown(MOUSE_LEFT_BUTTON))
			{
				m_isDragging = true;
			}
		}
	}

	if (m_isDragging)
	{
		if (!IsMouseButtonDown(MOUSE_LEFT_BUTTON))
		{
			m_isDragging = false;
		}

		float clickedPos = mousePos.x - (m_gui.m_Pos.x + 32);
		float percent = clickedPos / 60.0f;
		if (percent > 1) percent = 1;
		if (percent < 0) percent = 0;
		m_gui.GetElement(1008)->m_Pos.x = 30 + (percent * 60);
		m_currentAmount = percent * m_maxAmount + m_minAmount;
	}

	m_gui.GetElement(1009)->m_String = to_string(m_currentAmount);
	m_gui.GetElement(1008)->m_Pos.x = 30 + (float(m_currentAmount) / float(m_maxAmount) * 60);
	//m_gui.GetElement(1009)->Update();
}

void GumpNumberBar::Draw()
{
	m_gui.Draw();
}