#include <fstream>
#include <string>
#include <sstream>
#include <memory>

#include "Gui.h"
#include "GuiElements.h"
#include "Globals.h"

using namespace std;



//  GUITEXTBUTTON

void GuiTextButton::Init(int ID, int posx, int posy, int width, int height,
	std::string text, Font* font, Color textcolor, Color backgroundcolor, Color bordercolor,
	int group, int active)
{
	if (font == nullptr)
	{
		throw("Bad font declaration in GuiTextButton!");
	}

	m_Type = GUI_TEXTBUTTON;
	m_ID = ID;

	//  Is the element available to be interacted with?
	m_Active = active;

	//  Does the element currently have the mouse over it?
	m_Down = false;

	//  Has the element actually been clicked on this frame?
	m_Clicked = false;

	m_Group = group;
	m_Font = font;
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);

	m_TextColor = textcolor;
	m_BackgroundColor = backgroundcolor;
	m_BorderColor = bordercolor;

	m_String = text;

	Vector2 textDims = MeasureTextEx(*font, text.c_str(), font->baseSize, 1);

	m_Width = textDims.x * 1.15f; //  Add a little padding for the button left/right sides
	m_Height = textDims.y * 1.5f;

	m_TextWidth = textDims.x;
}

void GuiTextButton::Update()
{
	Tween::Update();
	m_Hovered = false;
	m_Clicked = false;
	m_Down = false;

	if (!m_Gui->m_AcceptingInput)
		return;

	if (m_Visible && m_Active)
	{
		if (IsMouseInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			m_Width * m_Gui->m_InputScale,
			m_Height * m_Gui->m_InputScale))
		{
			m_Hovered = true;
		}

		if (IsLeftButtonDownInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			m_Width * m_Gui->m_InputScale,
			m_Height * m_Gui->m_InputScale))
		{
			m_Hovered = false;
			m_Down = true;
		}

		else if (WasLeftButtonClickedInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			m_Width * m_Gui->m_InputScale,
			m_Height * m_Gui->m_InputScale))
		{
			m_Down = false;
			m_Hovered = false;
			m_Clicked = true;
			m_Gui->m_ActiveElement = m_ID;
		}
	}
}

void GuiTextButton::Draw()
{
	if (m_Visible == false)
		return;

	if (!m_Active)
	{
		DrawRectangleRounded(Rectangle{ m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
		m_Width, m_Height },
			0.5f, 1, m_BackgroundColor);

		DrawRectangleRoundedLines(Rectangle{ m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),	m_Width, m_Height },
			0.5f,
         5,
         1,
         m_BorderColor);

		DrawStringCentered(m_Gui->m_Font.get(), m_Font->baseSize, m_String,
			Vector2 {m_Gui->m_Pos.x + int(m_Pos.x) + (m_Width / 2), m_Gui->m_Pos.y + int(m_Pos.y + (m_Height * .6f))},
			Color{ 25, 25, 25, 255 });

		return;
	}

	if (!m_Down)
	{
		DrawRectangleRounded(Rectangle{ m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
			m_Width, m_Height },
			0.5f, 1, m_BorderColor);

		float xoffset = .95f;
		float invxoffset = (1.0f - xoffset) / 2.0f;

		float yoffset = .8f;
		float invyoffset = (1.0f - yoffset) / 2.0f;

		DrawRectangleRounded(Rectangle{ (m_Gui->m_Pos.x + int(m_Pos.x)) + (m_Width * invxoffset), (m_Gui->m_Pos.y + int(m_Pos.y)) + (m_Height * invyoffset), m_Width * xoffset, m_Height * yoffset },
			0.5f, 1, m_BackgroundColor);

		DrawStringCentered(m_Gui->m_Font.get(), m_Font->baseSize , m_String,
			Vector2 {m_Gui->m_Pos.x + int(m_Pos.x) + (m_Width / 2), m_Gui->m_Pos.y + int(m_Pos.y + (m_Height * .6f))},
			m_TextColor);
	}
	else
	{
		DrawRectangleRounded(Rectangle{ m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
			m_Width, m_Height },
			0.5f, 1, m_BorderColor);

		DrawRectangleRoundedLines(Rectangle{ m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
			m_Width, m_Height },
			100, .05f, .05f, m_BackgroundColor);

		DrawStringCentered(m_Font, m_Font->baseSize, m_String,
			Vector2 {m_Gui->m_Pos.x + int(m_Pos.x) + (m_Width / 2), m_Gui->m_Pos.y + int(m_Pos.y + (m_Height * .6f))},
			m_BackgroundColor);
	}
};

int GuiTextButton::GetValue()
{
	return m_Clicked;
}

//  GUIICONBUTTON

void GuiIconButton::Init(int ID, int posx, int posy, shared_ptr<Sprite> upbutton, shared_ptr<Sprite> downbutton,
	shared_ptr<Sprite> inactivebutton, std::string text, Font* font, Color fontcolor, float scale, int group, int active, bool canbeheld)
{
	if (upbutton == nullptr)
	{
		throw("Bad sprite in GuiIconButton!");
	}

	m_Type = GUI_ICONBUTTON;
	m_ID = ID;
	m_Active = active;
	m_Group = group;

	m_Pos.x = float(posx);
	m_Pos.y = float(posy);

	m_UpTexture = upbutton;
	m_DownTexture = downbutton;
	m_InactiveTexture = inactivebutton;

	m_String = text;
	m_Font = font;
	m_FontColor = fontcolor;

	m_Width = upbutton->m_sourceRect.width;
	m_Height = upbutton->m_sourceRect.height;

	m_CanBeHeld = canbeheld;

	m_Scale = scale;

	m_Clicked = false;
}

void GuiIconButton::Draw()
{
	if (m_Visible == false)
		return;

	//  Bobbing doesn't actually move the element, it just causes it to be drawn slightly higher or lower on the y axis.  You have to manually set bobbing for the button.
	int yoffset = 0;
	if (m_Bobbing)
		yoffset = int(sin(GetTime() * 10) * m_Height * .025f);

	bool _ReturnState = false;
	//  First off, if it's inactive, draw it inactive and that's it.
	if (!m_Active)
	{
		if (m_InactiveTexture)
		{
			m_InactiveTexture->DrawScaled(
				Rectangle{ (m_Gui->m_Pos.x + (m_Pos.x)), (m_Gui->m_Pos.y + (m_Pos.y)), m_Width * m_Scale, m_Height * m_Scale },
				Vector2{ 0, 0 }, 0, m_Color);
		}
		else
		{
			m_UpTexture->DrawScaled(
			Rectangle{ (m_Gui->m_Pos.x + (m_Pos.x)), (m_Gui->m_Pos.y + (m_Pos.y)), m_Width * m_Scale, m_Height * m_Scale },
			Vector2{ 0, 0 }, 0, m_Color);
		}
	}
	else
	{
		if (m_Down)
		{
			if (m_DownTexture)
			{

				m_DownTexture->DrawScaled(
				Rectangle{ (m_Gui->m_Pos.x + (m_Pos.x)), (m_Gui->m_Pos.y + (m_Pos.y)), m_Width * m_Scale, m_Height * m_Scale },
				Vector2{ 0, 0 }, 0, m_Color);
			}
			else
			{
				m_UpTexture->DrawScaled(
				Rectangle{ (m_Gui->m_Pos.x + (m_Pos.x)), (m_Gui->m_Pos.y + (m_Pos.y)), m_Width * m_Scale, m_Height * m_Scale },
				Vector2{ 0, 0 }, 0, m_Color);
			}
		}
		else
		{
			m_UpTexture->DrawScaled(
			Rectangle{ (m_Gui->m_Pos.x + (m_Pos.x)), (m_Gui->m_Pos.y + (m_Pos.y)), m_Width * m_Scale, m_Height * m_Scale },
			Vector2{ 0, 0 }, 0, m_Color);
		}
	}
};

void GuiIconButton::Update()
{
	Tween::Update();
	m_Hovered = false;
	m_Clicked = false;
	m_Down = false;

	if (!m_Gui->m_AcceptingInput)
		return;

	if (m_Visible && m_Active)
	{
		if (IsMouseInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			m_Width * m_Gui->m_InputScale * m_Scale,
			m_Height * m_Gui->m_InputScale * m_Scale))
		{
			m_Hovered = true;
		}

		if (IsLeftButtonDownInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			m_Width * m_Gui->m_InputScale * m_Scale,
			m_Height * m_Gui->m_InputScale * m_Scale))
		{
			m_Hovered = false;
			m_Down = true;
			if (m_CanBeHeld)
			{
				m_Gui->m_ActiveElement = m_ID;
			}
		}

		else if (WasLeftButtonClickedInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			m_Width * m_Gui->m_InputScale * m_Scale,
			m_Height * m_Gui->m_InputScale * m_Scale))
		{
			m_Down = false;
			m_Hovered = false;
			m_Clicked = true;
			if (!m_CanBeHeld)
			{
				m_Gui->m_ActiveElement = m_ID;
			}
		}
	}
};

int GuiIconButton::GetValue()
{
	return m_Clicked;
}


//  GUISCROLLBAR

void GuiScrollBar::Init(int ID, int valuerange, int posx, int posy, int width, int height, bool vertical,
	Color spurcolor, Color backgroundcolor, int group, int active, bool shadowed)
{
	m_Type = GUI_SCROLLBAR;
	m_ValueRange = valuerange;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Vertical = vertical;
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);
	m_Width = width;
	m_Height = height;
	m_SpurLocation = 0;
	m_Value = 0;
	m_SpurColor = spurcolor;
	m_BackgroundColor = backgroundcolor;
	m_Shadowed = shadowed;
}

void GuiScrollBar::Draw()
{
	if (m_Visible == false)
		return;

	int adjustedx = m_Gui->m_Pos.x + (m_Pos.x);
	int adjustedy = m_Gui->m_Pos.y + (m_Pos.y);

	int adjustedw = m_Width;
	int adjustedh = m_Height;

	DrawRectangle(adjustedx, adjustedy, adjustedw, adjustedh, m_BackgroundColor);

	if (m_Vertical)
	{
		m_SpurLocation = int((float(m_Value) / float(m_ValueRange) * (m_Height - m_Width)));
		DrawRectangle(adjustedx, adjustedy + m_SpurLocation, int(m_Width), int(m_Width), m_SpurColor);
	}
	else
	{
		m_SpurLocation = int((float(m_Value) / float(m_ValueRange) * (adjustedw - adjustedh)));//;
		DrawRectangle(adjustedx + m_SpurLocation, adjustedy, int(m_Height), int(m_Height), m_SpurColor);
	}
}

void GuiScrollBar::Update()
{
	Tween::Update();

	if (!m_Gui->m_AcceptingInput || !m_Active)
		return;

	m_Hovered = false;

	//  Is the LMB down inside the spur?
	int adjustedx = (m_Gui->m_Pos.x + (m_Pos.x)) * m_Gui->m_InputScale;
	int adjustedy = (m_Gui->m_Pos.y + (m_Pos.y)) * m_Gui->m_InputScale;

	int adjustedw = m_Width * m_Gui->m_InputScale;
	int adjustedh = m_Height * m_Gui->m_InputScale;

	//  Previously clicked, try for hysterisis
	if (m_Gui->m_ActiveElement == -1 && m_Gui->m_LastElement == -1 && IsLeftButtonDownInRect(adjustedx, adjustedy, adjustedw, adjustedh))
	{
		//m_Gui->m_ActiveElement = m_ID;
		if (m_Vertical)
		{
			m_Value = std::round((float(GetMouseY() - adjustedy) / float(adjustedh)) * m_ValueRange);

			if (m_Value < 0)
			{
				m_Value = 0;
			}

			if (m_Value > m_ValueRange)
			{
				m_Value = m_ValueRange;
			}
		}
		else
		{
			m_Value = std::round((float(GetMouseX() - adjustedx) / float(adjustedw)) * m_ValueRange);

			if (m_Value < 0)
			{
				m_Value = 0;
			}

			if (m_Value > m_ValueRange)
			{
				m_Value = m_ValueRange;
			}
		}
	}
	else if (IsMouseInRect(adjustedx, adjustedy, adjustedx + adjustedw, adjustedy + adjustedh))
	{
		m_Hovered = true;
	}
};

int GuiScrollBar::GetValue()
{
	return m_Value;
}

string GuiScrollBar::GetString()
{
	stringstream sstream;
	sstream.str("");
	sstream << m_Value;
	return sstream.str();
}


//  GUITEXTINPUT

void GuiTextInput::Init(int ID, int posx, int posy, int width, int height,
	Font* font, std::string initialtext, Color textColor, Color boxcolor,
	Color backgroundcolor, int group, int active)
{
	m_Type = GUI_TEXTINPUT;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);
	m_Font = font;
	m_TextColor = textColor;
	m_BoxColor = boxcolor;
	m_BackgroundColor = backgroundcolor;
	m_Width = width;
	m_Height = height;

	m_HasFocus = false;

	m_String = initialtext;
}

void GuiTextInput::Draw()
{
	if (m_Visible == false)
		return;

	float adjustedx = m_Gui->m_Pos.x + m_Pos.x;
	float adjustedy = m_Gui->m_Pos.y + m_Pos.y;

	DrawRectangle(adjustedx, adjustedy, m_Width, m_Height, m_BackgroundColor);
	DrawRectangleLines(adjustedx, adjustedy, m_Width, m_Height, m_BoxColor);

	if (!m_HasFocus)
	{
		DrawTextEx(*m_Font, m_String.c_str(), Vector2{ adjustedx + 2, adjustedy + 2 }, m_Font->baseSize, 1, m_TextColor);
	}
	else
	{
		if (GetTime() > 500)
		{
			DrawTextEx(*m_Font, (m_String + "|").c_str(), Vector2{adjustedx + 2, adjustedy + 2}, m_Font->baseSize, 1, m_TextColor);
		}
		else
		{
			DrawTextEx(*m_Font, m_String.c_str(), Vector2{ adjustedx + 2, adjustedy + 2 }, m_Font->baseSize, 1, m_TextColor);
		}
	}

	return;
}

void GuiTextInput::Update()
{
	Tween::Update();

	int adjustedx = int(m_Gui->m_Pos.x + m_Pos.x);
	int adjustedy = int(m_Gui->m_Pos.y + m_Pos.y);

	if (m_HasFocus && m_Gui->m_LastElement != m_ID)
	{
		m_HasFocus = false;
	}

	if (!m_Gui->m_AcceptingInput)
		return;

	//  If the left button is down, we are CLICKED
	if (WasLeftButtonClickedInRect(adjustedx, adjustedy, adjustedx + m_Width, adjustedy + m_Height))
	{
		m_HasFocus = true;
		m_Gui->m_ActiveElement = m_ID;
	}


	if (m_HasFocus && (IsKeyPressed(KEY_KP_ENTER) || IsKeyPressed(KEY_ENTER)))
	{
		m_HasFocus = false;
	}

	if (m_HasFocus && (IsKeyPressed(KEY_BACKSPACE)))
	{
		if (m_String.size() > 0)
		{
			m_String = m_String.substr(0, m_String.size() - 1);
		}
	}

	if (m_HasFocus && GetKeyPressed() >= KEY_SPACE && GetKeyPressed() <= KEY_Z)
	{
		m_String += char(GetKeyPressed());
	}
}

//  GUICHECKBOX

void GuiCheckBox::Init(int ID, int posx, int posy, shared_ptr<Sprite> unselected, shared_ptr<Sprite> selected, shared_ptr<Sprite> hovered, shared_ptr<Sprite> hoveredselected,
	float scalex, float scaley, Color color, int group, int active)
{
	m_Type = GUI_CHECKBOX;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Pos.x = float(posx) * 1;
	m_Pos.y = float(posy) * 1;
	m_SelectSprite = selected;
	m_DeselectSprite = unselected;
	m_HoveredSprite = hovered;
	m_HoveredSelectedSprite = hoveredselected;
	m_Color = color;
	m_Width = selected->m_sourceRect.width;
	m_Height = selected->m_sourceRect.height;
	m_ScaleX = scalex;
	m_ScaleY = scaley;
	m_Selected = false;
}

void GuiCheckBox::Init(int ID, int posx, int posy, int width, int height, float scalex, float scaley,
	Color color, int group, int active)
{
	m_Type = GUI_CHECKBOX;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Pos.x = float(posx) * 1;
	m_Pos.y = float(posy) * 1;
	m_SelectSprite = nullptr;
	m_DeselectSprite = nullptr;
	m_Color = color;
	m_Width = width;
	m_Height = height;
	m_ScaleX = scalex;
	m_ScaleY = scaley;
	m_Selected = false;
}

//  If the user doesn't specify textures, just use a simple "box in box" system.
void GuiCheckBox::Draw()
{
	if (!m_Visible)
		return;

	int adjustedx = m_Gui->m_Pos.x + int(m_Pos.x);
	int adjustedy = m_Gui->m_Pos.y + int(m_Pos.y);

	int adjustedw = int(m_Width);
	int adjustedh = int(m_Height);

	if (m_SelectSprite == nullptr) // no sprites, just use draw commands to draw it
	{
		if (m_Selected)
		{
			DrawRectangleLines(adjustedx, adjustedy, adjustedw, adjustedh, Color{ 255, 255, 255, 255 });
			DrawRectangle(adjustedx + 2, adjustedy + 2, adjustedw - 4, adjustedh - 4, Color{ 255, 255, 255, 255 });
		}
		else
		{
			DrawRectangleLines(adjustedx, adjustedy, adjustedw, adjustedh, Color{ 255, 255, 255, 255 });
		}
	}
	else //  We have sprites, use them.
	{
		if (m_Selected)
		{
			if (m_Hovered || m_Down)
			{
				m_HoveredSelectedSprite->DrawScaled(
					Rectangle{ m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
					m_ScaleX* 1, m_ScaleY* 1 }, Vector2{ 0, 0 }, 0, m_Color);
			}
			else
			{
				m_SelectSprite->DrawScaled(
					Rectangle{m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
					m_ScaleX, m_ScaleY }, Vector2{ 0, 0 }, 0, m_Color);
			}
		}
		else
		{
			if (m_Hovered || m_Down)
			{
				m_HoveredSprite->DrawScaled(
					Rectangle {m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
					m_ScaleX, m_ScaleY }, Vector2{ 0, 0 }, 0, m_Color);

			}
			else
			{
				m_DeselectSprite->DrawScaled(
					Rectangle { m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
					m_ScaleX, m_ScaleY }, Vector2{ 0, 0 }, 0, m_Color);
			}
		}
	}
}

void GuiCheckBox::Update()
{
	Tween::Update();

	if (!m_Gui->m_AcceptingInput)
		return;

	if (m_Visible)
	{
		m_Hovered = IsMouseInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			m_Width * m_Gui->m_InputScale,
			m_Height * m_Gui->m_InputScale);

		m_Down = IsLeftButtonDownInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			m_Width * m_Gui->m_InputScale,
			m_Height * m_Gui->m_InputScale);

		if (WasLeftButtonClickedInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			m_Width * m_Gui->m_InputScale,
			m_Height * m_Gui->m_InputScale))
		{
			m_Selected = !m_Selected;
			m_Gui->m_ActiveElement = m_ID;
		}
	}
}


//  GUIRADIOBUTTON
//  Radio buttons are exactly like checkboxes, but use grouping to ensure that only one of them is ever selected.
void GuiRadioButton::Init(int ID, int posx, int posy, shared_ptr<Sprite> selected, shared_ptr<Sprite> deselected, shared_ptr<Sprite> hovered, float scalex, float scaley,
	Color color, int group, int active, bool shadowed)
{
	m_Type = GUI_RADIOBUTTON;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);
	m_SelectSprite = selected;
	m_DeselectSprite = deselected;
	m_HoveredSprite = hovered;
	m_Color = color;
	m_Width = selected->m_sourceRect.width;
	m_Height = selected->m_sourceRect.height;
	m_ScaleX = scalex;
	m_ScaleY = scaley;
	m_Selected = false;
	m_Shadowed = shadowed;
}

void GuiRadioButton::Init(int ID, int posx, int posy, int width, int height, float scalex, float scaley,
	Color color, int group, int active, bool shadowed)
{
	m_Type = GUI_RADIOBUTTON;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);
	m_SelectSprite = nullptr;
	m_DeselectSprite = nullptr;
	m_Color = color;
	m_Width = width;
	m_Height = height;
	m_ScaleX = scalex;
	m_ScaleY = scaley;
	m_Selected = false;
	m_Shadowed = shadowed;
}

//  If the user doesn't specify textures, just use a simple "box in box" system.
void GuiRadioButton::Draw()
{
	if (!m_Visible)
		return;

	int adjustedx = m_Gui->m_Pos.x + int(m_Pos.x);
	int adjustedy = m_Gui->m_Pos.y + int(m_Pos.y);

	int adjustedw = int(m_Width);
	int adjustedh = int(m_Height);

	if (m_SelectSprite == nullptr)
	{
		if (m_Selected)
		{
			DrawRectangleLines(adjustedx, adjustedy, adjustedw, adjustedh, Color{ 255, 255, 255, 255 });
			DrawRectangle(adjustedx + 2, adjustedy + 2, adjustedw - 4, adjustedh - 4, Color{ 255, 255, 255, 255 });
		}
		else
		{
			DrawRectangleLines(adjustedx, adjustedy, adjustedw, adjustedh, Color{ 255, 255, 255, 255 });
		}
	}
	else
	{
		if (m_Selected)
		{
			if (m_Shadowed)
			{
				m_SelectSprite->DrawScaled(
					Rectangle{ m_Gui->m_Pos.x + int((m_Pos.x + 3)), m_Gui->m_Pos.y + int((m_Pos.y + 3)),
					m_ScaleX* 1, m_ScaleY* 1 }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			}
			m_SelectSprite->DrawScaled(
				Rectangle{ m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
				m_ScaleX* 1, m_ScaleY* 1 }, Vector2{ 0, 0 }, 0, m_Color);
		}
		else
		{
			if (m_Hovered && m_HoveredSprite != nullptr)
			{
				if (m_Shadowed)
				{
					m_HoveredSprite->DrawScaled(
						Rectangle{ m_Gui->m_Pos.x + int((m_Pos.x + 3)), m_Gui->m_Pos.y + int((m_Pos.y + 3)),
						m_ScaleX* 1, m_ScaleY* 1 }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
				}
				m_HoveredSprite->DrawScaled(
					Rectangle{ m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
					m_ScaleX* 1, m_ScaleY* 1 }, Vector2{ 0, 0 }, 0, m_Color);
			}
			else
			{
				if (m_Shadowed)
				{
					m_DeselectSprite->DrawScaled(
						Rectangle{ m_Gui->m_Pos.x + int((m_Pos.x + 3)), m_Gui->m_Pos.y + int((m_Pos.y + 3)),
						m_ScaleX* 1, m_ScaleY* 1 }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
				}
				m_DeselectSprite->DrawScaled(
					Rectangle{ m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
					m_ScaleX* 1, m_ScaleY* 1 }, Vector2{ 0, 0 }, 0, m_Color);
			}
		}
	}
}

void GuiRadioButton::Update()
{
	Tween::Update();

	if (!m_Gui->m_AcceptingInput)
		return;

	if (m_Visible)
	{
		if (IsMouseInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.x + int(m_Pos.x) + int(m_Width)) *m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y) + int(m_Height)))* m_Gui->m_InputScale)
		{
			m_Hovered = true;
		}
		else
		{
			m_Hovered = false;
		}

		if (WasLeftButtonClickedInRect((m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.x + int(m_Pos.x) + int(m_Width)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y) + int(m_Height))) * m_Gui->m_InputScale)
		{
			if (!m_Selected)
			{
				m_Selected = !m_Selected;

				//  Deselect all other buttons in this radio button group.
				for (auto& node : m_Gui->m_GuiElementList)
				{
					if (node.second->m_Group == m_Group && node.second.get() != this)// && node.second->m_Type == GUI_RADIOBUTTON)
					{
						node.second->m_Selected = false;
					}
				}
			}
			m_Gui->m_ActiveElement = m_ID;
		}
	}
}


//  GUIPANEL
//  Panels can use textures or they can just be filled boxes.  They can also have a border

void GuiPanel::Init(int ID, int posx, int posy, int width, int height,
	Color color, bool filled, int group, int active)
{
	m_Type = GUI_PANEL;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);
	m_Width = width;
	m_Height = height;
	m_Color = color;
	m_Filled = filled;
}

void GuiPanel::Draw()
{
	if (!m_Visible)
		return;

	int adjustedx = m_Gui->m_Pos.x + int(m_Pos.x);
	int adjustedy = m_Gui->m_Pos.y + int(m_Pos.y);

	int adjustedw = int(m_Width);
	int adjustedh = int(m_Height);

	if (m_Filled)
		DrawRectangle(adjustedx, adjustedy, adjustedw, adjustedh, m_Color);
	else
		DrawRectangleLines(adjustedx, adjustedy, adjustedw, adjustedh, m_Color);
};

void GuiPanel::Update()
{
	Tween::Update();
}

int GuiPanel::GetValue()
{
	return 0;
}


//  GUITEXTAREA

void GuiTextArea::Init(int ID, Font* font, std::string text, int posx, int posy, int width, int height,
	Color color, int justified, int group, int active, bool shadowed)
{
	if (font == nullptr)
	{
		m_Font = m_Gui->m_Font.get();
	}
	else
	{
		m_Font = font;
	}

	m_Type = GUI_TEXTAREA;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Pos.x = float(posx) * 1;
	m_Pos.y = float(posy) * 1;
	m_String = text;
	m_Justified = justified;
	m_Font = font;
	m_Color = color;
	m_Width = width * m_Font->baseSize;
	m_Shadowed = shadowed;
	if (m_Width == 0)
		m_Height = int(m_Font->baseSize);
	else
		m_Height = height;
}

void GuiTextArea::Draw()
{
	if (!m_Active || !m_Visible)
		return;

	if (m_Justified == GuiTextArea::RIGHT)
	{
		if (m_Shadowed)
			DrawStringRight(m_Font, m_Font->baseSize, m_String, m_Gui->m_Pos.x + ((m_Pos.x + m_Width + 2)), m_Gui->m_Pos.y + ((m_Pos.y + 2)), Color{0, 0, 0, 255});

		DrawStringRight(m_Font, m_Font->baseSize, m_String, m_Gui->m_Pos.x + ((m_Pos.x + m_Width)), m_Gui->m_Pos.y + (m_Pos.y), m_Color);

	}
	else if (m_Justified == GuiTextArea::CENTERED)
	{
		if (m_Width == 0 || MeasureTextEx(*m_Font, m_String.c_str(), m_Font->baseSize, 1).x < m_Width)
		{
			int textlength = MeasureTextEx(*m_Gui->m_Font.get(), m_String.c_str(), m_Font->baseSize, 1).x;

			//DrawRectangle(int(m_Gui->m_Pos.x + ((m_Pos.x + (m_Width / 2)))) - (m_Width / 2), int(m_Gui->m_Pos.y + (m_Pos.y)), m_Width, m_Font->height, Color(.5, 0, 0, .75), true);
			if (m_Shadowed)
				DrawStringCentered(m_Font, m_Font->baseSize, m_String, int(m_Gui->m_Pos.x + ((m_Pos.x + (m_Width / 2))) + (m_Font->baseSize * .125)), int(m_Gui->m_Pos.y + (m_Pos.y) + (m_Font->baseSize * .125)), Color{ 0, 0, 0, 255 });
			DrawStringCentered(m_Font, m_Font->baseSize, m_String, int(m_Gui->m_Pos.x + ((m_Pos.x + (m_Width / 2)))), int(m_Gui->m_Pos.y + (m_Pos.y)), m_Color);
		}
	}
	else
	{
		if (m_Width == 0) // An unset width parameter means "draw as a single string"
		{
			int textlength = MeasureTextEx(*m_Font, m_String.c_str(), m_Font->baseSize, 1).x;
			//DrawRectangle(int(m_Gui->m_Pos.x + (m_Pos.x)), int(m_Gui->m_Pos.y + (m_Pos.y)), textWidth, m_Height, Color(.5, 0, 0, .75), true);
			if (m_Shadowed)
				DrawTextEx(*m_Font, m_String.c_str(), Vector2{ m_Gui->m_Pos.x + ((m_Pos.x + 2)), m_Gui->m_Pos.y + ((m_Pos.y + 2)) }, m_Font->baseSize, 1, Color{ 0, 0, 0, 255 });
			DrawTextEx(*m_Font, m_String.c_str(), Vector2{ m_Gui->m_Pos.x + (m_Pos.x), m_Gui->m_Pos.y + (m_Pos.y) }, m_Font->baseSize, 1, m_Color);
		}
		else
		{
			int height = m_Font->baseSize;
			//DrawRectangle(int(m_Gui->m_Pos.x + (m_Pos.x)), int(m_Gui->m_Pos.y + (m_Pos.y)), m_Width, height, {128, 0, 0, 192}, true);
			if (m_Shadowed)
				DrawTextEx(*m_Font, m_String.c_str(), Vector2{ m_Gui->m_Pos.x + ((m_Pos.x + 2)), m_Gui->m_Pos.y + ((m_Pos.y + 2)) }, m_Font->baseSize, 1, Color{ 0, 0, 0, 255 });
			DrawTextEx(*m_Font, m_String.c_str(), Vector2{ m_Gui->m_Pos.x + (m_Pos.x), m_Gui->m_Pos.y + (m_Pos.y) }, m_Font->baseSize, 1, m_Color);
		}
	}
};

void GuiTextArea::Update()
{
	Tween::Update();
}

int GuiTextArea::GetValue()
{
	return 0;
}



//  Just puts an image at a certain location.  Non-interactive.
void GuiSprite::Init(int ID, int posx, int posy, shared_ptr<Sprite> sprite, float scalex, float scaley,
	Color color, int group, int active)
{
	m_Type = GUI_SPRITE;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);
	m_Sprite = sprite;
	m_Color = color;
	m_Width = sprite->m_sourceRect.width;
	m_Height = sprite->m_sourceRect.height;
	m_ScaleX = scalex;
	m_ScaleY = scaley;
}

void GuiSprite::Draw()
{
	if (m_Sprite && m_Active && m_Visible)
	{
		m_Sprite->DrawScaled(Rectangle{ m_Gui->m_Pos.x + int(m_Pos.x), m_Gui->m_Pos.y + int(m_Pos.y),
			m_Width * m_ScaleX, m_Height * m_ScaleY }, Vector2{ 0, 0 }, 0, m_Color);
	}
}

void GuiSprite::Update()
{
	Tween::Update();
}

//  Just puts an image at a certain location.  Non-interactive.
void GuiOctagonBox::Init(int ID, int posx, int posy, int width, int height, std::vector<std::shared_ptr<Sprite> > borders,
	Color color, int group, int active)
{
	m_Type = GUI_OCTAGONBOX;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Pos.x = float(posx) * 1;
	m_Pos.y = float(posy) * 1;
	m_Color = color;
	m_Width = width * 1;
	m_Height = height * 1;
	m_Sprites = borders;
};

void GuiOctagonBox::Update()
{
	Tween::Update();
}

//  0 - Top left
//  1 - Top
//  2 - Top right
//  3 - Left
//  4 - Center
//  5 - Right
//  6 - Bottom left
//  7 - Bottom
//  8 - Bottom right
void GuiOctagonBox::Draw()
{
	if (!m_Active || !m_Visible)
		return;

	float x = m_Gui->m_Pos.x + (m_Pos.x);
	float y = m_Gui->m_Pos.y + (m_Pos.y);

	//  Find out, in pixels, how wide everything should be and where it should be positioned.
	float cornerWidth = (m_Sprites[0]->m_sourceRect.width + (1 < 1 ? 1 : 0));
	float cornerHeight = (m_Sprites[0]->m_sourceRect.height + (1 < 1 ? 1 : 0));

	float finalWidth = m_Width;
	float finalHeight = m_Height;

	float runnerWidth = finalWidth - (cornerWidth * 2); // Since both components have been scaled, this does not have to be scaled.
	float runnerHeight = finalHeight - (cornerHeight * 2); // Ditto.

	float xmiddle = cornerWidth;
	float xright = cornerWidth + runnerWidth;

	float ymiddle = cornerHeight;
	float ybottom = cornerHeight + runnerHeight;

	//  Center
	m_Sprites[4].get()->DrawScaled( Rectangle{x + cornerWidth, y + cornerHeight, float(runnerWidth), float(runnerHeight)}, Vector2{0, 0}, 0, m_Color);

	//  Top and bottom bars
	m_Sprites[1].get()->DrawScaled( Rectangle{ x + cornerWidth, y, float(runnerWidth), m_Sprites[1].get()->m_sourceRect.height }, Vector2{ 0, 0 }, 0, m_Color);
	m_Sprites[7].get()->DrawScaled( Rectangle{ x + cornerWidth, y + cornerHeight + runnerHeight, float(runnerWidth), m_Sprites[7].get()->m_sourceRect.height}, Vector2{0, 0}, 0, m_Color);
	//  Left and right bars
	m_Sprites[3].get()->DrawScaled( Rectangle{ x, y + cornerHeight, m_Sprites[3].get()->m_sourceRect.width, float(runnerHeight) }, Vector2{ 0, 0 }, 0, m_Color);
	m_Sprites[5].get()->DrawScaled( Rectangle{ x + cornerWidth + runnerWidth, y + cornerHeight, m_Sprites[5].get()->m_sourceRect.height, float(runnerHeight) }, Vector2{ 0, 0 }, 0, m_Color);

	//  Top corners
	m_Sprites[0].get()->DrawScaled( Rectangle{ x, y, m_Sprites[0].get()->m_sourceRect.width, m_Sprites[0].get()->m_sourceRect.height }, Vector2{ 0, 0 }, 0, m_Color);
	m_Sprites[2].get()->DrawScaled( Rectangle{ x + cornerWidth + runnerWidth, y, m_Sprites[2].get()->m_sourceRect.width, m_Sprites[2].get()->m_sourceRect.height }, Vector2{ 0, 0 }, 0, m_Color);

	//  Bottom corners
	m_Sprites[6].get()->DrawScaled( Rectangle{ x, y + cornerHeight + runnerHeight, m_Sprites[6].get()->m_sourceRect.width, m_Sprites[6].get()->m_sourceRect.width }, Vector2{ 0, 0 }, 0, m_Color);
	m_Sprites[8].get()->DrawScaled( Rectangle{ x + cornerWidth + runnerWidth, y + cornerHeight + runnerHeight, 1 * m_Sprites[8].get()->m_sourceRect.width, m_Sprites[8].get()->m_sourceRect.width }, Vector2{ 0, 0 }, 0, m_Color);
}

void GuiStretchButton::Init(int ID, int posx, int posy, int width, string label,
	std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> activeCenter,
	std::shared_ptr<Sprite> inactiveLeft, std::shared_ptr<Sprite> inactiveRight, std::shared_ptr<Sprite> inactiveCenter, int indent,
	Color color, int group, int active, bool shadowed)
{
	if (activeLeft == nullptr || activeRight == nullptr || activeCenter == nullptr ||
		inactiveLeft == nullptr || inactiveRight == nullptr || inactiveCenter == nullptr)
	{
		throw("Bad sprite in GuiStretchButton!");
	}

	m_Type = GUI_STRETCHBUTTON;
	m_ID = ID;
	m_Active = active;
	m_Shadowed = shadowed;
	m_Group = group;
	m_Pos.x = float(posx) * 1;
	m_Pos.y = float(posy) * 1;
	m_Color = color;
	m_Width = width;
	m_Height = activeLeft->m_sourceRect.height;
	m_ActiveLeft = activeLeft;
	m_ActiveRight = activeRight;
	m_ActiveCenter = activeCenter;
	m_InactiveLeft = inactiveLeft;
	m_InactiveRight = inactiveRight;
	m_InactiveCenter = inactiveCenter;
	m_Indent = indent;
	m_String = label;
}

void GuiStretchButton::Draw()
{
	if (!m_Visible)
		return;

	float offset = 1.0f;

	float xmiddle = float(m_InactiveLeft->m_sourceRect.width);
	float xright = float(m_Width - (m_InactiveLeft->m_sourceRect.width + m_InactiveLeft->m_sourceRect.width)) * 1;
	float centerWidth = float(m_Width - (m_InactiveLeft->m_sourceRect.width + m_InactiveRight->m_sourceRect.width));

	Vector2 textDims = MeasureTextEx(*m_Gui->m_Font.get(), m_String.c_str(), m_Gui->m_Font->baseSize / 1, 1);
	float textWidth = textDims.x * .85f;
	float textHeight = textDims.y;

	if (!m_Active)
	{
		if (m_Shadowed)
		{
			m_InactiveLeft->DrawScaled(Rectangle{ m_Gui->m_Pos.x + m_Pos.x + offset, m_Gui->m_Pos.y + offset, m_InactiveLeft->m_sourceRect.width, m_InactiveLeft->m_sourceRect.height },
				Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			m_InactiveCenter->DrawScaled(Rectangle{ m_Gui->m_Pos.x + ((m_Pos.x + 3 + xmiddle)) - 1, m_Gui->m_Pos.y + ((m_Pos.y + 3)), ((xright + 3) / m_InactiveCenter->m_sourceRect.width), 1 }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			m_InactiveRight->DrawScaled(Rectangle{ m_Gui->m_Pos.x + (m_Pos.x + 3 + xmiddle + xright), m_Gui->m_Pos.y + ((m_Pos.y + 3)), 1, 1 }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
		}

		m_InactiveLeft->DrawScaled(Rectangle{ m_Gui->m_Pos.x + m_Pos.x, m_Gui->m_Pos.y, m_InactiveLeft->m_sourceRect.width, m_InactiveLeft->m_sourceRect.height }, Vector2{ 0, 0 }, 0, Color{ 128, 128, 128, 255 });
		m_InactiveCenter->DrawScaled(Rectangle{ m_Gui->m_Pos.x + ((m_Pos.x + xmiddle)) - 1, m_Gui->m_Pos.y + (m_Pos.y), ((xright + 3) / m_InactiveCenter->m_sourceRect.width), m_InactiveCenter->m_sourceRect.height }, Vector2{ 0, 0 }, 0, Color{ 128, 128, 128, 255 });
		m_InactiveRight->DrawScaled(Rectangle{ m_Gui->m_Pos.x + (m_Pos.x + xmiddle + xright), m_Gui->m_Pos.y + (m_Pos.y), 1, m_InactiveRight->m_sourceRect.height }, Vector2{ 0, 0 }, 0, Color{ 128, 128, 128, 255 });
      
      DrawStringCentered(m_Gui->m_Font.get(), m_Gui->m_Font->baseSize , m_String,
			Vector2 {m_Gui->m_Pos.x + int(m_Pos.x) + (m_Width / 2), m_Gui->m_Pos.y + int(m_Pos.y + (m_Height * .6f))});

		//DrawTextEx(*m_Gui->m_Font.get(), m_String.c_str(), Vector2{ m_Gui->m_Pos.x + (m_Pos.x + m_Indent), m_Gui->m_Pos.y + m_Pos.y }, m_Gui->m_Font->baseSize, 1, WHITE);
	}
	else if (m_Hovered || m_Down || m_Clicked)
	{
		if (m_Shadowed)
		{
			//m_ActiveLeft->DrawScaled(Rectangle{ m_Gui->m_Pos.x + ((m_Pos.x + 3)), m_Gui->m_Pos.y + ((m_Pos.y + 3)), 1, 1 }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			//m_ActiveCenter->DrawScaled(Rectangle{ m_Gui->m_Pos.x + ((m_Pos.x + 3 + xmiddle)) - 1, m_Gui->m_Pos.y + ((m_Pos.y + 3)), ((xright + 3) / m_InactiveCenter->m_sourceRect.width), 1 }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			//m_ActiveRight->DrawScaled(Rectangle{ m_Gui->m_Pos.x + (m_Pos.x + 3 + xmiddle + xright), m_Gui->m_Pos.y + ((m_Pos.y + 3)), 1, 1 }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
		}
		if (m_Down)
		{
			m_ActiveLeft->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + offset), (m_Gui->m_Pos.y + m_Pos.y + offset), m_ActiveLeft->m_sourceRect.width * 1, m_ActiveLeft->m_sourceRect.height * 1 });
			m_ActiveCenter->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + xmiddle + offset), (m_Gui->m_Pos.y + m_Pos.y + offset),
				centerWidth * 1, m_ActiveCenter->m_sourceRect.height * 1 });
			m_ActiveRight->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + xmiddle + xright + offset), (m_Gui->m_Pos.y + m_Pos.y + offset),
				m_ActiveRight->m_sourceRect.width * 1, m_ActiveRight->m_sourceRect.height * 1 });

			//m_ActiveLeft->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + offset), (m_Gui->m_Pos.y + m_Pos.y + offset),
			//	m_ActiveLeft->m_sourceRect.width, m_ActiveLeft->m_sourceRect.height }, Vector2{ 0, 0 }, 0.0f, Color{ 128, 128, 128, 255 });
			//m_ActiveCenter->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + xmiddle + offset), (m_Gui->m_Pos.y + m_Pos.y + offset),
			//	centerWidth, m_ActiveCenter->m_sourceRect.height }, Vector2{ 0, 0 }, 0.0f, Color{ 128, 128, 128, 255 });
			//m_ActiveRight->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + xmiddle + xright + offset), (m_Gui->m_Pos.y + m_Pos.y + offset),
			//	m_ActiveRight->m_sourceRect.width, m_ActiveRight->m_sourceRect.height }, Vector2{ 0, 0 }, 0.0f, Color{ 128, 128, 128, 255 });
		}
		else
		{
			m_ActiveLeft->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x), (m_Gui->m_Pos.y + m_Pos.y), m_ActiveLeft->m_sourceRect.width * 1, m_ActiveLeft->m_sourceRect.height * 1 });
			m_ActiveCenter->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + xmiddle), (m_Gui->m_Pos.y + m_Pos.y),
				centerWidth * 1, m_ActiveCenter->m_sourceRect.height * 1 });
			m_ActiveRight->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + xmiddle + xright), (m_Gui->m_Pos.y + m_Pos.y),
				m_ActiveRight->m_sourceRect.width * 1, m_ActiveRight->m_sourceRect.height * 1 });
		}

		if (m_Down)
		{
         DrawStringCentered(m_Gui->m_Font.get(), m_Gui->m_Font->baseSize , m_String,
      		Vector2 {m_Gui->m_Pos.x + int(m_Pos.x) + (m_Width / 2), m_Gui->m_Pos.y + int(m_Pos.y + (m_Height * .6f))});
		}
		else
		{
         DrawStringCentered(m_Gui->m_Font.get(), m_Gui->m_Font->baseSize , m_String,
      		Vector2 {m_Gui->m_Pos.x + int(m_Pos.x) + (m_Width / 2), m_Gui->m_Pos.y + int(m_Pos.y + (m_Height * .6f))});
		}
	}
	else
	{
		if (m_Shadowed)
		{
			m_InactiveLeft->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + offset), (m_Gui->m_Pos.y + m_Pos.y + offset),
				m_InactiveLeft->m_sourceRect.width, m_InactiveLeft->m_sourceRect.height }, Vector2{ 0, 0 }, 0.0f, Color{0, 0, 0, 255});
			m_InactiveCenter->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + xmiddle + offset), (m_Gui->m_Pos.y + m_Pos.y + offset),
				centerWidth, m_InactiveCenter->m_sourceRect.height }, Vector2{ 0, 0 }, 0.0f, Color{ 0, 0, 0, 255 });
			m_InactiveRight->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + xmiddle + xright + offset), (m_Gui->m_Pos.y + m_Pos.y + offset),
				m_InactiveRight->m_sourceRect.width, m_InactiveRight->m_sourceRect.height }, Vector2{ 0, 0 }, 0.0f, Color{ 0, 0, 0, 255 });
		}

		m_InactiveLeft->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x), (m_Gui->m_Pos.y + m_Pos.y), m_InactiveLeft->m_sourceRect.width* 1, m_InactiveLeft->m_sourceRect.height* 1 });
		m_InactiveCenter->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + xmiddle), (m_Gui->m_Pos.y + m_Pos.y),
			centerWidth* 1, m_InactiveCenter->m_sourceRect.height *  1 });
		m_InactiveRight->DrawScaled(Rectangle{ (m_Gui->m_Pos.x + m_Pos.x + xmiddle + xright), (m_Gui->m_Pos.y + m_Pos.y),
			m_InactiveRight->m_sourceRect.width* 1, m_InactiveRight->m_sourceRect.height * 1 });

      DrawStringCentered(m_Gui->m_Font.get(), m_Gui->m_Font->baseSize , m_String,
      	Vector2 {m_Gui->m_Pos.x + int(m_Pos.x) + (m_Width / 2), m_Gui->m_Pos.y + int(m_Pos.y + (m_Height * .6f))});
	}
}

void GuiStretchButton::Update()
{
	Tween::Update();
	m_Clicked = false;
	m_Hovered = false;
	m_Down = false;

	if (!m_Gui->m_AcceptingInput)
		return;

	if (m_Visible && m_Active)
	{
		//  Stretch buttons activate on button down, so there is no "hot" state.
		// if (IsLeftButtonDownInRect({ (m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
		// 	(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
		// 	m_Width * m_Gui->m_InputScale,
		// 	m_Height * m_Gui->m_InputScale }))
		// {
		// 	m_Hovered = false;
		// 	m_Down = true;
		// 	m_Clicked = false; // Not clicked until the button is released.
		// 	m_Gui->m_ActiveElement = m_ID;
		// }
		// else
		
		if (WasLeftButtonClickedInRect(Rectangle{ (m_Gui->m_Pos.x + int(m_Pos.x)) * m_Gui->m_InputScale,
			(m_Gui->m_Pos.y + int(m_Pos.y)) * m_Gui->m_InputScale,
			m_Width * m_Gui->m_InputScale,
			m_Height * m_Gui->m_InputScale }))
		{
			m_Hovered = false;
			m_Down = false;
			m_Clicked = true;
			m_Gui->m_ActiveElement = m_ID;
		}
		else if (IsMouseInRect((m_Gui->m_Pos.x + m_Pos.x),
			(m_Gui->m_Pos.y + m_Pos.y),
			m_Width,
			m_Height))
		{
			m_Hovered = true;
			m_Clicked = false;
		}
	}
}

void GuiList::Init(int ID, int posx, int posy, int width, int height, Font* font,
                   const std::vector<std::string>& items, Color textcolor,
                   Color backgroundcolor, Color bordercolor, int group, int active)
{
    m_ID = ID;
    m_Type = GUI_LIST;
    m_Pos = {static_cast<float>(posx), static_cast<float>(posy)};
    m_Width = static_cast<float>(width);
    m_Height = static_cast<float>(height);
    m_Font = font;
    m_TextColor = textcolor;
    m_BackgroundColor = backgroundcolor;
    m_BorderColor = bordercolor;
    m_Group = group;
    m_Active = active;
    m_Items = items;
    m_SelectedIndex = 0;
}

void GuiList::Update()
{
    if (!m_Active || !m_Visible || !m_Gui) return;

    Vector2 mousePos = GetMousePosition();
    float scaledX = mousePos.x / m_Gui->m_InputScale;
    float scaledY = mousePos.y / m_Gui->m_InputScale;

    // Check if mouse is over the main box
    m_Hovered = (scaledX >= m_Pos.x && scaledX <= m_Pos.x + m_Width &&
                 scaledY >= m_Pos.y && scaledY <= m_Pos.y + m_Height);

    if (m_Hovered && IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) {
        m_IsExpanded = !m_IsExpanded;
        m_Clicked = true;
        m_Gui->m_ActiveElement = m_ID;
    } else if (!m_Hovered && IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) {
        m_IsExpanded = false;
    }

    // Handle selection in expanded list
    if (m_IsExpanded) {
        float itemHeight = m_Height;
        for (int i = 0; i < m_Items.size() && i < m_VisibleItems; ++i) {
            float y = m_Pos.y + (i + 1) * itemHeight;
            if (scaledX >= m_Pos.x && scaledX <= m_Pos.x + m_Width &&
                scaledY >= y && scaledY <= y + itemHeight) {
                if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) {
                    m_SelectedIndex = i;
                    m_IsExpanded = false;
                    m_Clicked = true;
                    m_Gui->m_ActiveElement = m_ID;
                }
            }
        }
    }
}

void GuiList::Draw()
{
    if (!m_Visible) return;

    // Draw main box
    DrawRectangle(static_cast<int>(m_Pos.x), static_cast<int>(m_Pos.y),
                  static_cast<int>(m_Width), static_cast<int>(m_Height), m_BackgroundColor);
    DrawRectangleLines(static_cast<int>(m_Pos.x), static_cast<int>(m_Pos.y),
                       static_cast<int>(m_Width), static_cast<int>(m_Height), m_BorderColor);

    // Draw selected item
    if (!m_Items.empty()) {
        DrawTextEx(*m_Font, m_Items[m_SelectedIndex].c_str(),
                   {m_Pos.x + 5, m_Pos.y + 5}, m_Font->baseSize, 1, m_TextColor);
    }

    // Draw expanded list
    if (m_IsExpanded) {
        float itemHeight = m_Height;
        for (int i = 0; i < m_Items.size() && i < m_VisibleItems; ++i) {
            float y = m_Pos.y + (i + 1) * itemHeight;
            DrawRectangle(static_cast<int>(m_Pos.x), static_cast<int>(y),
                          static_cast<int>(m_Width), static_cast<int>(itemHeight), m_BackgroundColor);
            DrawRectangleLines(static_cast<int>(m_Pos.x), static_cast<int>(y),
                               static_cast<int>(m_Width), static_cast<int>(itemHeight), m_BorderColor);
            DrawTextEx(*m_Font, m_Items[i].c_str(), {m_Pos.x + 5, y + 5},
                       m_Font->baseSize, 1, m_TextColor);
        }
    }
}

void GuiList::AddItem(const std::string& item)
{
    m_Items.push_back(item);
}

void GuiList::SetSelectedIndex(int index)
{
    if (index >= 0 && index < static_cast<int>(m_Items.size())) {
        m_SelectedIndex = index;
    }
}