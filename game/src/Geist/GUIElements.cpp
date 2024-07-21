#include <fstream>
#include <string>
#include <sstream>
#include <memory>

#include "Gui.h"
#include "GUIElements.h"
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
	m_Hot = false;

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

	m_Width = textDims.x / m_Parent->m_Scale * 1.25f; //  Add a little padding for the button left/right sides
	m_Height = textDims.y / m_Parent->m_Scale;

	m_TextWidth = textDims.x;
}

void GuiTextButton::Update()
{
	Tween::Update();
	m_Hovered = false;
	m_Clicked = false;
	m_Hot = false;

	if (!m_Parent->m_AcceptingInput)
		return;

	if (m_Visible && m_Active)
	{
		if (IsMouseInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Width * m_Parent->m_Scale,
			m_Height * m_Parent->m_Scale))
		{
			m_Hovered = true;
		}

		if (IsLeftButtonDownInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Width * m_Parent->m_Scale,
			m_Height * m_Parent->m_Scale))
		{
			m_Hovered = false;
			m_Hot = true;
		}

		else if (WasLeftButtonClickedInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Width * m_Parent->m_Scale,
			m_Height * m_Parent->m_Scale))
		{
			m_Hot = false;
			m_Hovered = false;
			m_Clicked = true;
			m_Parent->m_ActiveElement = m_ID;
		}
	}
}

void GuiTextButton::Draw()
{
	if (m_Visible == false)
		return;

	if (!m_Active)
	{
		DrawRectangleRounded(Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
		m_Width * m_Parent->m_Scale, m_Height * m_Parent->m_Scale },
			0.5f, 1, m_BackgroundColor);

		DrawRectangleRoundedLines(Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Width * m_Parent->m_Scale, m_Height * m_Parent->m_Scale },
			0.5f, 1, m_BorderColor);

		DrawStringCentered(m_Parent->m_Font.get(), m_Parent->m_Font.get()->baseSize, m_String,
			Vector2 {m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale) + (m_Width / 2 * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale + (m_Height / 2 * m_Parent->m_Scale))},
			Color{ 25, 25, 25, 255 });

		return;
	}

	if (!m_Hot)
	{
		DrawRectangleRounded(Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Width * m_Parent->m_Scale, m_Height * m_Parent->m_Scale },
			0.5f, 1, m_BackgroundColor);

		DrawRectangleRoundedLines(Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Width * m_Parent->m_Scale, m_Height * m_Parent->m_Scale },
			0.5f, 1, m_BorderColor);

		DrawStringCentered(m_Parent->m_Font.get(), m_Parent->m_Font.get()->baseSize, m_String,
			Vector2 {m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale) + (m_Width / 2 * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale + (m_Height / 2 * m_Parent->m_Scale))},
			m_TextColor);
	}
	else
	{
		DrawRectangleRounded(Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Width * m_Parent->m_Scale, m_Height * m_Parent->m_Scale },
			0.5f, 1, m_BorderColor);

		DrawRectangleRoundedLines(Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Width * m_Parent->m_Scale, m_Height * m_Parent->m_Scale },
			0.5f, 1, m_BackgroundColor);

		DrawStringCentered(m_Parent->m_Font.get(), m_Parent->m_Font.get()->baseSize, m_String,
			Vector2 {m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale) + (m_Width / 2 * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale + (m_Height / 2 * m_Parent->m_Scale))},
			m_BackgroundColor);
	}
};

int GuiTextButton::GetValue()
{
	return m_Clicked;
}

//  GUIICONBUTTON

void GuiIconButton::Init(int ID, int posx, int posy, shared_ptr<Sprite> upbutton, shared_ptr<Sprite> downbutton,
	shared_ptr<Sprite> inactivebutton, std::string text, Font* font, Color fontcolor, int group, int active)
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
				Rectangle{ m_Parent->m_GuiX + (m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + (m_Pos.y * m_Parent->m_Scale), m_InactiveTexture->m_sourceRect.width * m_Parent->m_Scale, m_InactiveTexture->m_sourceRect.height * m_Parent->m_Scale },
				Vector2{ 0, 0 }, 0, m_Color);
		}
		else
		{
			m_UpTexture->DrawScaled(
				Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale), m_UpTexture->m_sourceRect.width * m_Parent->m_Scale, m_UpTexture->m_sourceRect.height * m_Parent->m_Scale },
				Vector2{ 0, 0 }, 0, m_Color);
		}
	}
	else
	{
		if (m_Hot)
		{
			if (m_DownTexture)
			{

				m_DownTexture->DrawScaled(
					Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale) + yoffset, m_DownTexture->m_sourceRect.width * m_Parent->m_Scale, m_DownTexture->m_sourceRect.height * m_Parent->m_Scale },
					Vector2{ 0, 0 }, 0, m_Color);
			}
			else
			{
				m_UpTexture->DrawScaled(
					Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale) + yoffset, m_UpTexture->m_sourceRect.width * m_Parent->m_Scale, m_UpTexture->m_sourceRect.height * m_Parent->m_Scale },
					Vector2{ 0, 0 }, 0, m_Color);
			}
		}
		else
		{
			m_UpTexture->DrawScaled(
				Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale) + yoffset, m_UpTexture->m_sourceRect.width * m_Parent->m_Scale, m_UpTexture->m_sourceRect.height * m_Parent->m_Scale },
				Vector2{ 0, 0 }, 0, m_Color);
		}
	}
};

void GuiIconButton::Update()
{
	Tween::Update();
	m_Hovered = false;
	m_Clicked = false;
	m_Hot = false;

	if (!m_Parent->m_AcceptingInput)
		return;

	if (m_Visible && m_Active)
	{
		if (IsMouseInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			int(m_UpTexture->m_sourceRect.width * m_Parent->m_Scale),
			int(m_UpTexture->m_sourceRect.height * m_Parent->m_Scale)))
		{
			m_Hovered = true;
		}

		if (IsLeftButtonDownInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			int(m_UpTexture->m_sourceRect.width * m_Parent->m_Scale),
			int(m_UpTexture->m_sourceRect.height * m_Parent->m_Scale)))
		{
			m_Hovered = false;
			m_Hot = true;
		}

		else if (WasLeftButtonClickedInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			int(m_UpTexture->m_sourceRect.width * m_Parent->m_Scale),
			int(m_UpTexture->m_sourceRect.height * m_Parent->m_Scale)))
		{
			m_Hot = false;
			m_Hovered = false;
			m_Clicked = true;
			m_Parent->m_ActiveElement = m_ID;
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

void GuiScrollBar::Init(int ID, int valuerange, int posx, int posy, int width, int height, bool vertical,
	std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> activeCenter, std::shared_ptr<Sprite> spurActive,
	std::shared_ptr<Sprite> inactiveLeft, std::shared_ptr<Sprite> inactiveRight, std::shared_ptr<Sprite> inactiveCenter,
	std::shared_ptr<Sprite> spurInactive, int group, int active, bool shadowed)
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
	m_ActiveLeft = activeLeft;
	m_ActiveRight = activeRight;
	m_ActiveCenter = activeCenter;
	m_InactiveLeft = inactiveLeft;
	m_InactiveRight = inactiveRight;
	m_InactiveCenter = inactiveCenter;
	m_SpurActive = spurActive;
	m_SpurInactive = spurInactive;
	m_Shadowed = shadowed;
}


void GuiScrollBar::Draw()
{
	if (m_Visible == false)
		return;

	int adjustedx = m_Parent->m_GuiX + (m_Pos.x * m_Parent->m_Scale);
	int adjustedy = m_Parent->m_GuiY + (m_Pos.y * m_Parent->m_Scale);

	int adjustedw = m_Width * m_Parent->m_Scale;
	int adjustedh = m_Height * m_Parent->m_Scale;

	if (m_ActiveLeft == nullptr) // No sprites, so draw with colors
	{
		DrawRectangle(adjustedx, adjustedy, adjustedw, adjustedh, m_BackgroundColor);

		if (m_Vertical)
		{
			m_SpurLocation = int((float(m_Value) / float(m_ValueRange) * (m_Height - m_Width)) * m_Parent->m_Scale);
			DrawRectangle(adjustedx, adjustedy + m_SpurLocation, int(m_Width * m_Parent->m_Scale), int(m_Width * m_Parent->m_Scale), m_SpurColor);
		}
		else
		{
			m_SpurLocation = int((float(m_Value) / float(m_ValueRange) * (adjustedw - adjustedh)));// * m_Parent->m_Scale;
			DrawRectangle(adjustedx + m_SpurLocation, adjustedy, int(m_Height * m_Parent->m_Scale), int(m_Height * m_Parent->m_Scale), m_SpurColor);
		}
	}
	else
	{
		shared_ptr<Sprite> left;
		shared_ptr<Sprite> center;
		shared_ptr<Sprite> right;
		shared_ptr<Sprite> spur;
		if (!m_Selected && m_InactiveLeft != nullptr) //  not active and we have inactive sprites
		{
			left = m_InactiveLeft;
			center = m_InactiveCenter;
			right = m_InactiveRight;
			spur = m_SpurInactive;
		}
		else
		{
			left = m_ActiveLeft;
			center = m_ActiveCenter;
			right = m_ActiveRight;
			spur = m_SpurActive;
		}

		float xmiddle = float(left->m_sourceRect.width);
		float xright = float(m_Width - (left->m_sourceRect.width + right->m_sourceRect.width));



		if (m_Shadowed)
		{
			left->DrawScaled(Rectangle{m_Parent->m_Pos.x + ((m_Pos.x + 3) * m_Parent->m_Scale), m_Parent->m_Pos.y + ((m_Pos.y + 3) * m_Parent->m_Scale), m_Parent->m_Scale, m_Parent->m_Scale},
				Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			center->DrawScaled(Rectangle{ m_Parent->m_Pos.x + ((m_Pos.x + 3 + xmiddle) * m_Parent->m_Scale) - 1, m_Parent->m_Pos.y + ((m_Pos.y + 3) * m_Parent->m_Scale), ((xright + 3) / m_InactiveCenter->m_sourceRect.width) * m_Parent->m_Scale, m_Parent->m_Scale },
				Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			right->DrawScaled(Rectangle{ m_Parent->m_Pos.x + (m_Pos.x + 3 + xmiddle + xright) * m_Parent->m_Scale, m_Parent->m_Pos.y + ((m_Pos.y + 3) * m_Parent->m_Scale), m_Parent->m_Scale, m_Parent->m_Scale },
				Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
		}

		left->DrawScaled(Rectangle{ m_Parent->m_Pos.x + (m_Pos.x * m_Parent->m_Scale), m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale), m_Parent->m_Scale, m_Parent->m_Scale });
		center->DrawScaled(Rectangle{ m_Parent->m_Pos.x + ((m_Pos.x + xmiddle) * m_Parent->m_Scale) - 1, m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale), ((xright + 3) / m_InactiveCenter->m_sourceRect.width) * m_Parent->m_Scale, m_Parent->m_Scale });
		right->DrawScaled(Rectangle{ m_Parent->m_Pos.x + (m_Pos.x + xmiddle + xright) * m_Parent->m_Scale, m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale), m_Parent->m_Scale, m_Parent->m_Scale });

		//int debugadjustedx = m_Parent->m_GuiX + (m_Pos.x * m_Parent->m_Scale);
		//int debugadjustedy = int(m_Parent->m_Pos.y + (float(m_Pos.y) * m_Parent->m_Scale) + (float(m_Height) / 2.0f * m_Parent->m_Scale) - (float(spur->m_sourceRect.height) / 2.0f * m_Parent->m_Scale));

		//int debugadjustedw = m_Width * m_Parent->m_Scale;
		//int debugadjustedh = m_SpurActive->m_sourceRect.height * m_Parent->m_Scale;

		//DrawRectangle(debugadjustedx, debugadjustedy, debugadjustedw, debugadjustedh, Color(1, 0, 0, .5), true);

		spur->DrawScaled(Rectangle{ m_Parent->m_Pos.x + ((m_Pos.x - (float(spur->m_sourceRect.width) / 2)) * m_Parent->m_Scale) + ((float(m_Value) / float(m_ValueRange)) * m_Width * m_Parent->m_Scale),
			//int(m_Parent->m_Pos.y + ((m_Pos.y + (float(spur->m_sourceRect.height) / 2)) * m_Parent->m_Scale)),
			m_Parent->m_Pos.y + (float(m_Pos.y) * m_Parent->m_Scale) + (float(m_Height) / 2.0f * m_Parent->m_Scale) - (float(spur->m_sourceRect.height) / 2.0f * m_Parent->m_Scale), m_Parent->m_Scale, m_Parent->m_Scale });
	}
}

void GuiScrollBar::Update()
{
	Tween::Update();

	if (!m_Parent->m_AcceptingInput || !m_Active)
		return;

	m_Hovered = false;

	//  Is the LMB down inside the spur?
	int adjustedx = m_Parent->m_GuiX + (m_Pos.x * m_Parent->m_Scale);
	int adjustedy = int(m_Parent->m_Pos.y + (float(m_Pos.y) * m_Parent->m_Scale) + (float(m_Height) / 2.0f * m_Parent->m_Scale) - (float(m_SpurActive->m_sourceRect.height) / 2.0f * m_Parent->m_Scale));

	int adjustedw = m_Width * m_Parent->m_Scale;
	int adjustedh = m_SpurActive->m_sourceRect.height * m_Parent->m_Scale;

	//  Previously clicked, try for hysterisis
	if (m_Parent->m_LastElement == m_ID)
	{
		if (IsLeftButtonDragging() || IsLeftButtonDownInRect(adjustedx, adjustedy, adjustedx + adjustedw, adjustedy + adjustedh))
		{
			m_Parent->m_ActiveElement = m_ID; //  This element is still active.
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
		else //  No longer dragging, which means this element is no longer active.
		{
			m_Parent->m_ActiveElement = -1;
		}
	}
	else if (m_Parent->m_ActiveElement == -1 && m_Parent->m_LastElement == -1 && IsLeftButtonDownInRect(adjustedx, adjustedy, adjustedx + adjustedw, adjustedy + adjustedh))
	{
		m_Parent->m_ActiveElement = m_ID;
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

	float adjustedx = m_Parent->m_GuiX + m_Pos.x;
	float adjustedy = m_Parent->m_GuiY + m_Pos.y;

	DrawRectangle(adjustedx, adjustedy, m_Width, m_Height, m_BackgroundColor);
	DrawRectangleLines(adjustedx, adjustedy, m_Width, m_Height, m_BoxColor);

	if (!m_HasFocus)
	{
		DrawTextEx(*m_Font, m_String.c_str(), Vector2{ adjustedx + 2, adjustedy + 2 }, m_Parent->m_fontSize, 1, m_TextColor);
	}
	else
	{
		if (GetTime() > 500)
		{
			DrawTextEx(*m_Font, (m_String + "|").c_str(), Vector2{adjustedx + 2, adjustedy + 2}, m_Parent->m_fontSize, 1, m_TextColor);
		}
		else
		{
			DrawTextEx(*m_Font, m_String.c_str(), Vector2{ adjustedx + 2, adjustedy + 2 }, m_Parent->m_fontSize, 1, m_TextColor);
		}
	}

	return;
}

void GuiTextInput::Update()
{
	Tween::Update();

	int adjustedx = int(m_Parent->m_GuiX + m_Pos.x);
	int adjustedy = int(m_Parent->m_GuiY + m_Pos.y);

	if (m_HasFocus && m_Parent->m_LastElement != m_ID)
	{
		m_HasFocus = false;
	}

	if (!m_Parent->m_AcceptingInput)
		return;

	//  If the left button is down, we are CLICKED
	if (WasLeftButtonClickedInRect(adjustedx, adjustedy, adjustedx + m_Width, adjustedy + m_Height))
	{
		m_HasFocus = true;
		m_Parent->m_ActiveElement = m_ID;
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
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);
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
}

//  If the user doesn't specify textures, just use a simple "box in box" system.
void GuiCheckBox::Draw()
{
	if (!m_Visible)
		return;

	int adjustedx = m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale);
	int adjustedy = m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale);

	int adjustedw = int(m_Width * m_Parent->m_Scale);
	int adjustedh = int(m_Height * m_Parent->m_Scale);

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
			if (m_Hovered || m_Hot)
			{
				m_HoveredSelectedSprite->DrawScaled(
					Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
					m_ScaleX* m_Parent->m_Scale, m_ScaleY* m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
			}
			else
			{
				m_SelectSprite->DrawScaled(
					Rectangle{m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
					m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
			}
		}
		else
		{
			if (m_Hovered || m_Hot)
			{
				m_HoveredSprite->DrawScaled(
					Rectangle {m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
					m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);

			}
			else
			{
				m_DeselectSprite->DrawScaled(
					Rectangle { m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
					m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
			}
		}
	}
}

void GuiCheckBox::Update()
{
	Tween::Update();

	if (!m_Parent->m_AcceptingInput)
		return;

	if (m_Visible)
	{
		m_Hovered = IsMouseInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale));

		m_Hot = IsLeftButtonDownInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale));

		if (WasLeftButtonClickedInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale)))
		{
			m_Selected = !m_Selected;
			m_Parent->m_ActiveElement = m_ID;
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

	int adjustedx = m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale);
	int adjustedy = m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale);

	int adjustedw = int(m_Width * m_Parent->m_Scale);
	int adjustedh = int(m_Height * m_Parent->m_Scale);

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
					Rectangle{ m_Parent->m_GuiX + int((m_Pos.x + 3) * m_Parent->m_Scale), m_Parent->m_GuiY + int((m_Pos.y + 3) * m_Parent->m_Scale),
					m_ScaleX* m_Parent->m_Scale, m_ScaleY* m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			}
			m_SelectSprite->DrawScaled(
				Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
				m_ScaleX* m_Parent->m_Scale, m_ScaleY* m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
		}
		else
		{
			if (m_Hovered && m_HoveredSprite != nullptr)
			{
				if (m_Shadowed)
				{
					m_HoveredSprite->DrawScaled(
						Rectangle{ m_Parent->m_GuiX + int((m_Pos.x + 3) * m_Parent->m_Scale), m_Parent->m_GuiY + int((m_Pos.y + 3) * m_Parent->m_Scale),
						m_ScaleX* m_Parent->m_Scale, m_ScaleY* m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
				}
				m_HoveredSprite->DrawScaled(
					Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
					m_ScaleX* m_Parent->m_Scale, m_ScaleY* m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
			}
			else
			{
				if (m_Shadowed)
				{
					m_DeselectSprite->DrawScaled(
						Rectangle{ m_Parent->m_GuiX + int((m_Pos.x + 3) * m_Parent->m_Scale), m_Parent->m_GuiY + int((m_Pos.y + 3) * m_Parent->m_Scale),
						m_ScaleX* m_Parent->m_Scale, m_ScaleY* m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
				}
				m_DeselectSprite->DrawScaled(
					Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
					m_ScaleX* m_Parent->m_Scale, m_ScaleY* m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
			}
		}
	}
}

void GuiRadioButton::Update()
{
	Tween::Update();

	if (!m_Parent->m_AcceptingInput)
		return;

	if (m_Visible)
	{
		if (IsMouseInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale)))
		{
			m_Hovered = true;
		}
		else
		{
			m_Hovered = false;
		}

		if (WasLeftButtonClickedInRect(m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale)))
		{
			if (!m_Selected)
			{
				m_Selected = !m_Selected;

				//  Deselect all other buttons in this radio button group.
				for (auto& node : m_Parent->m_GuiList)
				{
					if (node.second->m_Group == m_Group && node.second.get() != this)// && node.second->m_Type == GUI_RADIOBUTTON)
					{
						node.second->m_Selected = false;
					}
				}
			}
			m_Parent->m_ActiveElement = m_ID;
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

	int adjustedx = m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale);
	int adjustedy = m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale);

	int adjustedw = int(m_Width * m_Parent->m_Scale);
	int adjustedh = int(m_Height * m_Parent->m_Scale);

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
	m_Type = GUI_TEXTAREA;
	m_ID = ID;
	m_Active = active;
	m_Group = group;
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);
	m_String = text;
	m_Justified = justified;
	m_Font = font;
	m_Color = color;
	m_Width = width;
	m_Shadowed = shadowed;
	if (m_Width == 0)
		m_Height = int(m_Parent->m_fontSize);
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
			DrawStringRight(m_Font, m_Parent->m_fontSize * m_Parent->m_Scale, m_String, m_Parent->m_Pos.x + ((m_Pos.x + m_Width + 2) * m_Parent->m_Scale), m_Parent->m_Pos.y + ((m_Pos.y + 2) * m_Parent->m_Scale), Color{0, 0, 0, 255});

		DrawStringRight(m_Font, m_Parent->m_fontSize * m_Parent->m_Scale, m_String, m_Parent->m_Pos.x + ((m_Pos.x + m_Width) * m_Parent->m_Scale), m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale), m_Color);

	}
	else if (m_Justified == GuiTextArea::CENTERED)
	{
		if (MeasureTextEx(*m_Font, m_String.c_str(), m_Parent->m_fontSize, 1).x < m_Width)
		{
			int textlength = MeasureTextEx(*m_Parent->m_Font.get(), m_String.c_str(), m_Parent->m_fontSize, 1).x;

			//DrawRectangle(int(m_Parent->m_Pos.x + ((m_Pos.x + (m_Width / 2)) * m_Parent->m_Scale)) - (m_Width / 2), int(m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale)), m_Width, m_Font->height, Color(.5, 0, 0, .75), true);
			if (m_Shadowed)
				DrawStringCentered(m_Font, m_Parent->m_fontSize * m_Parent->m_Scale, m_String, int(m_Parent->m_Pos.x + ((m_Pos.x + 2 + (m_Width / 2)) * m_Parent->m_Scale)), int(m_Parent->m_Pos.y + ((m_Pos.y + 2) * m_Parent->m_Scale)), Color{ 0, 0, 0, 255 });
			DrawStringCentered(m_Font, m_Parent->m_fontSize * m_Parent->m_Scale, m_String, int(m_Parent->m_Pos.x + ((m_Pos.x + (m_Width / 2)) * m_Parent->m_Scale)), int(m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale)), m_Color);
		}
		else
		{
			int textlength = MeasureTextEx(*m_Parent->m_Font.get(), m_String.c_str(), m_Parent->m_fontSize * m_Parent->m_Scale, 1).x;

			//DrawRectangle(int(m_Parent->m_Pos.x + ((m_Pos.x + (m_Width / 2)) * m_Parent->m_Scale) - textlength / 2), int(m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale)), m_Width * m_Parent->m_Scale, m_Font->height, Color(.5, 0, 0, .75), true);
			//if (m_Shadowed)
			//	m_Font->DrawParagraphCentered(m_String, int(m_Parent->m_Pos.x + ((m_Pos.x + (m_Width / 2)) * m_Parent->m_Scale)), int(m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale)), m_Width * m_Parent->m_Scale, m_Font->height, Color{ 0, 0, 0, 255 });
			//m_Font->DrawParagraphCentered(m_String, int(m_Parent->m_Pos.x + ((m_Pos.x + (m_Width / 2)) * m_Parent->m_Scale)), int(m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale)), m_Width * m_Parent->m_Scale, m_Font->height, m_Color);
		}
	}
	else
	{
		if (m_Width == 0) // An unset width parameter means "draw as a single string"
		{
			int textlength = MeasureTextEx(*m_Parent->m_Font.get(), m_String.c_str(), m_Parent->m_fontSize * m_Parent->m_Scale, 1).x;
			//DrawRectangle(int(m_Parent->m_Pos.x + (m_Pos.x * m_Parent->m_Scale)), int(m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale)), textWidth, m_Height, Color(.5, 0, 0, .75), true);
			if (m_Shadowed)
				DrawTextEx(*m_Parent->m_Font.get(), m_String.c_str(), Vector2{ m_Parent->m_Pos.x + ((m_Pos.x + 2) * m_Parent->m_Scale), m_Parent->m_Pos.y + ((m_Pos.y + 2) * m_Parent->m_Scale) }, m_Parent->m_fontSize * m_Parent->m_Scale, 1, Color{ 0, 0, 0, 255 });
			DrawTextEx(*m_Parent->m_Font.get(), m_String.c_str(), Vector2{ m_Parent->m_Pos.x + (m_Pos.x * m_Parent->m_Scale), m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale) }, m_Parent->m_fontSize * m_Parent->m_Scale, 1, m_Color);
		}
		else
		{
			int height = m_Parent->m_fontSize * m_Parent->m_Scale;
			//DrawRectangle(int(m_Parent->m_Pos.x + (m_Pos.x * m_Parent->m_Scale)), int(m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale)), m_Width * m_Parent->m_Scale, height, Color(.5, 0, 0, .75), true);
			//if (m_Shadowed)
			//	m_Font->DrawParagraph(m_String, int(m_Parent->m_Pos.x + ((m_Pos.x + 2) * m_Parent->m_Scale)), int(m_Parent->m_Pos.y + ((m_Pos.y + 2) * m_Parent->m_Scale)), m_Width, m_Height, Color{ 0, 0, 0, 255 }, m_Parent->m_Scale);
			//m_Font->DrawParagraph(m_String, int(m_Parent->m_Pos.x + (m_Pos.x * m_Parent->m_Scale)), int(m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale)), m_Width, m_Height, m_Color, m_Parent->m_Scale);
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
		m_Sprite->DrawScaled(Rectangle{ m_Parent->m_GuiX + int(m_Pos.x * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.y * m_Parent->m_Scale),
			m_ScaleX* m_Parent->m_Scale, m_ScaleY* m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
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
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);
	m_Color = color;
	m_Width = width;
	m_Height = height;
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

	float x = m_Parent->m_Pos.x + (m_Pos.x * m_Parent->m_Scale);
	float y = m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale);

	//  Find out, in pixels, how wide everything should be and where it should be positioned.
	float cornerWidth = (m_Sprites[0]->m_sourceRect.width + (m_Parent->m_Scale < 1 ? 1 : 0)) * m_Parent->m_Scale;
	float cornerHeight = (m_Sprites[0]->m_sourceRect.height + (m_Parent->m_Scale < 1 ? 1 : 0)) * m_Parent->m_Scale;

	float finalWidth = m_Width * m_Parent->m_Scale;
	float finalHeight = m_Height * m_Parent->m_Scale;

	float runnerWidth = finalWidth - (cornerWidth * 2); // Since both components have been scaled, this does not have to be scaled.
	float runnerHeight = finalHeight - (cornerHeight * 2); // Ditto.

	float xmiddle = cornerWidth;
	float xright = cornerWidth + runnerWidth;

	float ymiddle = cornerHeight;
	float ybottom = cornerHeight + runnerHeight;

	//  Center
	m_Sprites[4].get()->DrawScaled( Rectangle{x + cornerWidth, y + cornerHeight, float(runnerWidth), float(runnerHeight)}, Vector2{0, 0}, 0, m_Color);

	//  Top and bottom bars
	m_Sprites[1].get()->DrawScaled( Rectangle{ x + cornerWidth, y, float(runnerWidth), m_Sprites[1].get()->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
	m_Sprites[7].get()->DrawScaled( Rectangle{ x + cornerWidth, y + cornerHeight + runnerHeight, float(runnerWidth), m_Sprites[7].get()->m_sourceRect.height * m_Parent->m_Scale}, Vector2{0, 0}, 0, m_Color);
	//  Left and right bars
	m_Sprites[3].get()->DrawScaled( Rectangle{ x, y + cornerHeight, m_Sprites[3].get()->m_sourceRect.width * m_Parent->m_Scale, float(runnerHeight) }, Vector2{ 0, 0 }, 0, m_Color);
	m_Sprites[5].get()->DrawScaled( Rectangle{ x + cornerWidth + runnerWidth, y + cornerHeight, m_Sprites[5].get()->m_sourceRect.height * m_Parent->m_Scale, float(runnerHeight) }, Vector2{ 0, 0 }, 0, m_Color);

	//  Top corners
	m_Sprites[0].get()->DrawScaled( Rectangle{ x, y, m_Sprites[0].get()->m_sourceRect.width * m_Parent->m_Scale, m_Sprites[0].get()->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
	m_Sprites[2].get()->DrawScaled( Rectangle{ x + cornerWidth + runnerWidth, y, m_Sprites[2].get()->m_sourceRect.width * m_Parent->m_Scale, m_Sprites[2].get()->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);

	//  Bottom corners
	m_Sprites[6].get()->DrawScaled( Rectangle{ x, y + cornerHeight + runnerHeight, m_Sprites[6].get()->m_sourceRect.width * m_Parent->m_Scale, m_Sprites[6].get()->m_sourceRect.width * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
	m_Sprites[8].get()->DrawScaled( Rectangle{ x + cornerWidth + runnerWidth, y + cornerHeight + runnerHeight, m_Parent->m_Scale * m_Sprites[8].get()->m_sourceRect.width, m_Sprites[8].get()->m_sourceRect.width * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, m_Color);
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
	m_Pos.x = float(posx);
	m_Pos.y = float(posy);
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

	float offset = 1.0f * m_Parent->m_Scale;

	float xmiddle = float(m_InactiveLeft->m_sourceRect.width);
	float xright = float(m_Width - (m_InactiveLeft->m_sourceRect.width + m_InactiveLeft->m_sourceRect.width));
	float centerWidth = float(m_Width - (m_InactiveLeft->m_sourceRect.width + m_InactiveRight->m_sourceRect.width));

	Vector2 textDims = MeasureTextEx(*m_Parent->m_Font.get(), m_String.c_str(), m_Parent->m_Font->baseSize, 1);
	float textWidth = textDims.x / m_Parent->m_Scale;
	float textHeight = textDims.y / m_Parent->m_Scale;

	if (!m_Active)
	{
		if (m_Shadowed)
		{
			m_InactiveLeft->DrawScaled(Rectangle{ m_Parent->m_Pos.x + m_Pos.x + offset, m_Parent->m_Pos.y + offset, m_InactiveLeft->m_sourceRect.width * m_Parent->m_Scale, m_InactiveLeft->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			m_InactiveCenter->DrawScaled(Rectangle{ m_Parent->m_Pos.x + ((m_Pos.x + 3 + xmiddle) * m_Parent->m_Scale) - 1, m_Parent->m_Pos.y + ((m_Pos.y + 3) * m_Parent->m_Scale), ((xright + 3) / m_InactiveCenter->m_sourceRect.width) * m_Parent->m_Scale, m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			m_InactiveRight->DrawScaled(Rectangle{ m_Parent->m_Pos.x + (m_Pos.x + 3 + xmiddle + xright) * m_Parent->m_Scale, m_Parent->m_Pos.y + ((m_Pos.y + 3) * m_Parent->m_Scale), m_Parent->m_Scale, m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
		}

		m_InactiveLeft->DrawScaled(Rectangle{ m_Parent->m_Pos.x + m_Pos.x, m_Parent->m_Pos.y, m_InactiveLeft->m_sourceRect.width * m_Parent->m_Scale, m_InactiveLeft->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 128, 128, 128, 255 });
		m_InactiveCenter->DrawScaled(Rectangle{ m_Parent->m_Pos.x + ((m_Pos.x + xmiddle) * m_Parent->m_Scale) - 1, m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale), ((xright + 3) / m_InactiveCenter->m_sourceRect.width) * m_Parent->m_Scale, m_InactiveCenter->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 128, 128, 128, 255 });
		m_InactiveRight->DrawScaled(Rectangle{ m_Parent->m_Pos.x + (m_Pos.x + xmiddle + xright) * m_Parent->m_Scale, m_Parent->m_Pos.y + (m_Pos.y * m_Parent->m_Scale), m_Parent->m_Scale, m_InactiveRight->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 128, 128, 128, 255 });

		DrawTextEx(*m_Parent->m_Font.get(), m_String.c_str(), Vector2{ m_Parent->m_Pos.x + (m_Pos.x + m_Indent) * m_Parent->m_Scale, m_Parent->m_Pos.y + m_Pos.y * m_Parent->m_Scale }, m_Parent->m_fontSize * m_Parent->m_Scale, 1, WHITE);
	}
	else if (m_Hovered || m_Hot || m_Clicked)
	{
		if (m_Shadowed)
		{
			m_ActiveLeft->DrawScaled(Rectangle{ m_Parent->m_Pos.x + ((m_Pos.x + 3) * m_Parent->m_Scale), m_Parent->m_Pos.y + ((m_Pos.y + 3) * m_Parent->m_Scale), m_Parent->m_Scale, m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			m_ActiveCenter->DrawScaled(Rectangle{ m_Parent->m_Pos.x + ((m_Pos.x + 3 + xmiddle) * m_Parent->m_Scale) - 1, m_Parent->m_Pos.y + ((m_Pos.y + 3) * m_Parent->m_Scale), ((xright + 3) / m_InactiveCenter->m_sourceRect.width) * m_Parent->m_Scale, m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
			m_ActiveRight->DrawScaled(Rectangle{ m_Parent->m_Pos.x + (m_Pos.x + 3 + xmiddle + xright) * m_Parent->m_Scale, m_Parent->m_Pos.y + ((m_Pos.y + 3) * m_Parent->m_Scale), m_Parent->m_Scale, m_Parent->m_Scale }, Vector2{ 0, 0 }, 0, Color{ 0, 0, 0, 255 });
		}
		if (m_Hot)
		{
			m_ActiveLeft->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x + offset) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y + offset) * m_Parent->m_Scale,
				m_ActiveLeft->m_sourceRect.width * m_Parent->m_Scale, m_ActiveLeft->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0.0f, Color{ 128, 128, 128, 255 });
			m_ActiveCenter->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x + xmiddle + offset) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y + offset) * m_Parent->m_Scale,
				centerWidth * m_Parent->m_Scale, m_ActiveCenter->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0.0f, Color{ 128, 128, 128, 255 });
			m_ActiveRight->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x + xmiddle + xright + offset) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y + offset) * m_Parent->m_Scale,
				m_ActiveRight->m_sourceRect.width * m_Parent->m_Scale, m_ActiveRight->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0.0f, Color{ 128, 128, 128, 255 });
		}
		else
		{
			m_ActiveLeft->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale,
				m_ActiveLeft->m_sourceRect.width * m_Parent->m_Scale, m_ActiveLeft->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0.0f, WHITE);
			m_ActiveCenter->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x + xmiddle) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale,
				centerWidth * m_Parent->m_Scale, m_ActiveCenter->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0.0f, WHITE);
			m_ActiveRight->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x + xmiddle + xright) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale,
				m_ActiveRight->m_sourceRect.width * m_Parent->m_Scale, m_ActiveRight->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0.0f, WHITE);
		}

		if (m_Hot)
		{
			DrawTextEx(*m_Parent->m_Font.get(), m_String.c_str(), Vector2{ ((m_Parent->m_Pos.x + m_Pos.x + offset) * m_Parent->m_Scale) + ((m_Width - textWidth) / 2) * m_Parent->m_Scale, ((m_Parent->m_Pos.y + m_Pos.y + offset) * m_Parent->m_Scale) + ((m_ActiveLeft->m_sourceRect.height - textHeight) / 2) * m_Parent->m_Scale }, m_Parent->m_fontSize * m_Parent->m_Scale, 1, WHITE);
		}
		else
		{
			DrawTextEx(*m_Parent->m_Font.get(), m_String.c_str(), Vector2{ ((m_Parent->m_Pos.x + m_Pos.x) * m_Parent->m_Scale) + ((m_Width - textWidth) / 2) * m_Parent->m_Scale, ((m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale) + ((m_ActiveLeft->m_sourceRect.height - textHeight) / 2) * m_Parent->m_Scale }, m_Parent->m_fontSize * m_Parent->m_Scale, 1, WHITE);
		}
	}
	else
	{
		if (m_Shadowed)
		{
			m_InactiveLeft->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x + offset) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y + offset) * m_Parent->m_Scale,
				m_InactiveLeft->m_sourceRect.width * m_Parent->m_Scale, m_InactiveLeft->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0.0f, Color{0, 0, 0, 255});
			m_InactiveCenter->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x + xmiddle + offset) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y + offset) * m_Parent->m_Scale,
				centerWidth * m_Parent->m_Scale, m_InactiveCenter->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0.0f, Color{ 0, 0, 0, 255 });
			m_InactiveRight->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x + xmiddle + xright + offset) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y + offset) * m_Parent->m_Scale,
				m_InactiveRight->m_sourceRect.width * m_Parent->m_Scale, m_InactiveRight->m_sourceRect.height * m_Parent->m_Scale }, Vector2{ 0, 0 }, 0.0f, Color{ 0, 0, 0, 255 });
		}

		m_InactiveLeft->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale,
			m_InactiveLeft->m_sourceRect.width * m_Parent->m_Scale, m_InactiveLeft->m_sourceRect.height * m_Parent->m_Scale });
		m_InactiveCenter->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x + xmiddle) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale,
			centerWidth * m_Parent->m_Scale, m_InactiveCenter->m_sourceRect.height *  m_Parent->m_Scale });
		m_InactiveRight->DrawScaled(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x + xmiddle + xright) * m_Parent->m_Scale, (m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale,
			m_InactiveRight->m_sourceRect.width * m_Parent->m_Scale, m_InactiveRight->m_sourceRect.height * m_Parent->m_Scale });

		DrawTextEx(*m_Parent->m_Font.get(), m_String.c_str(), Vector2{ ((m_Parent->m_Pos.x + m_Pos.x) * m_Parent->m_Scale) + ((m_Width - textWidth) / 2) * m_Parent->m_Scale, ((m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale) + ((m_ActiveLeft->m_sourceRect.height - textHeight) / 2) * m_Parent->m_Scale}, m_Parent->m_fontSize * m_Parent->m_Scale, 1, WHITE);
	}
}

void GuiStretchButton::Update()
{
	Tween::Update();
	m_Clicked = false;
	m_Hovered = false;
	m_Hot = false;

	if (!m_Parent->m_AcceptingInput)
		return;

	if (m_Visible && m_Active)
	{
		//  Stretch buttons activate on button down, so there is no "hot" state.
		if (IsLeftButtonDownInRect(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x) * m_Parent->m_Scale,
			(m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale,
			m_Width * m_Parent->m_Scale,
			m_Height * m_Parent->m_Scale }))
		{
			m_Hovered = false;
			m_Hot = true;
			m_Clicked = false; // Not clicked until the button is released.
			m_Parent->m_ActiveElement = m_ID;
		}
		else if (WasLeftButtonClickedInRect(Rectangle{ (m_Parent->m_Pos.x + m_Pos.x) * m_Parent->m_Scale,
			(m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale,
			m_Width * m_Parent->m_Scale,
			m_Height * m_Parent->m_Scale }))
		{
			m_Hovered = false;
			m_Hot = false;
			m_Clicked = true;
			m_Parent->m_ActiveElement = m_ID;
		}
		else if (IsMouseInRect((m_Parent->m_Pos.x + m_Pos.x) * m_Parent->m_Scale,
			(m_Parent->m_Pos.y + m_Pos.y) * m_Parent->m_Scale,
			m_Width * m_Parent->m_Scale,
			m_Height * m_Parent->m_Scale))
		{
			m_Hovered = true;
			m_Clicked = false;
		}
	}
}