#include "Globals.h"
#include <fstream>
#include <string>
#include <sstream>
#include <memory>

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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);

	m_TextColor = textcolor;
	m_BackgroundColor = backgroundcolor;
	m_BorderColor = bordercolor;

	m_String = text;

	if (width == 0)
	{
		m_Width = m_Font->GetStringMetrics(m_String) + 5;
	}
	else
	{
		m_Width = width;
	}

	if (height == 0)
	{
		m_Height = int(m_Font->GetHeight()) + 4;
	}
	else
	{
		m_Height = height;
	}

	m_TextWidth = font->GetStringMetrics(m_String);
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
		if (g_Input->IsMouseInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + m_Width,
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + m_Height))
		{
			m_Hovered = true;
		}

		if (g_Input->IsLButtonDownInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + m_Width,
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + m_Height))
		{
			m_Hovered = false;
			m_Hot = true;
		}

		else if (g_Input->WasLButtonClickedInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + m_Width,
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + m_Height))
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
		g_Display->DrawBox(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Width, m_Height,
			m_BackgroundColor, true);

		g_Display->DrawBox(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Width, m_Height,
			m_BorderColor, false);

		m_Font->DrawStringCentered(m_String,
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + (m_Width / 2),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			Color(0.1f, 0.1f, 0.1f, 1));

		return;
	}

	if (!m_Hot)
	{
		g_Display->DrawBox(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Width, m_Height,
			m_BackgroundColor, true);

		g_Display->DrawBox(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Width, m_Height,
			m_BorderColor, false);

		m_Font->DrawStringCentered(m_String,
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + (m_Width / 2),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_TextColor);
	}
	else
	{
		g_Display->DrawBox(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Width, m_Height,
			m_BorderColor, true);

		g_Display->DrawBox(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Width, m_Height,
			m_BackgroundColor, false);

		m_Font->DrawStringCentered(m_String,
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + (m_Width / 2),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
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

	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);

	m_UpTexture = upbutton;
	m_DownTexture = downbutton;
	m_InactiveTexture = inactivebutton;

	m_String = text;
	m_Font = font;
	m_FontColor = fontcolor;

	m_Width = upbutton->m_Width;
	m_Height = upbutton->m_Height;

	m_Clicked = false;
}

void GuiIconButton::Draw()
{
	if (m_Visible == false)
		return;

	//  Bobbing doesn't actually move the element, it just causes it to be drawn slightly higher or lower on the y axis.  You have to manually set bobbing for the button.
	int yoffset = 0;
	if (m_Bobbing)
		yoffset = int(sin(g_Engine->GameTimeInSeconds() * 10) * m_Height * .025f);

	bool _ReturnState = false;
	//  First off, if it's inactive, draw it inactive and that's it.
	if (!m_Active)
	{
		if (m_InactiveTexture)
		{
			g_Display->DrawImage(m_InactiveTexture->m_Texture,
				m_InactiveTexture->m_PosX, m_InactiveTexture->m_PosY,
				m_InactiveTexture->m_Width, m_InactiveTexture->m_Height,
				m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
				int(m_InactiveTexture->m_Width * m_Parent->m_Scale), int(m_InactiveTexture->m_Height * m_Parent->m_Scale), m_Color);
		}
		else
		{
			g_Display->DrawImage(m_UpTexture->m_Texture,
				m_UpTexture->m_PosX, m_UpTexture->m_PosY,
				m_UpTexture->m_Width, m_UpTexture->m_Height,
				m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
				int(m_UpTexture->m_Width * m_Parent->m_Scale), int(m_UpTexture->m_Height * m_Parent->m_Scale), m_Color);
		}
	}
	else
	{
		if (m_Hot)
		{
			if (m_DownTexture)
			{

				g_Display->DrawImage(m_DownTexture->m_Texture,
					m_DownTexture->m_PosX, m_DownTexture->m_PosY,
					m_DownTexture->m_Width, m_DownTexture->m_Height,
					m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + yoffset,
					int(m_DownTexture->m_Width * m_Parent->m_Scale), int(m_DownTexture->m_Height * m_Parent->m_Scale), m_Color);
			}
			else
			{
				g_Display->DrawImage(m_UpTexture->m_Texture,
					m_UpTexture->m_PosX, m_UpTexture->m_PosY,
					m_UpTexture->m_Width, m_UpTexture->m_Height,
					m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + yoffset,
					int(m_UpTexture->m_Width * m_Parent->m_Scale), int(m_UpTexture->m_Height * m_Parent->m_Scale), m_Color);
			}
		}
		else
		{
			g_Display->DrawImage(m_UpTexture->m_Texture,
				m_UpTexture->m_PosX, m_UpTexture->m_PosY,
				m_UpTexture->m_Width, m_UpTexture->m_Height,
				m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + yoffset,
				int(m_UpTexture->m_Width * m_Parent->m_Scale), int(m_UpTexture->m_Height * m_Parent->m_Scale), m_Color);
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
		if (g_Input->IsMouseInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + int(m_UpTexture->m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + int(m_UpTexture->m_Height * m_Parent->m_Scale)))
		{
			m_Hovered = true;
		}

		if (g_Input->IsLButtonDownInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + int(m_UpTexture->m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + int(m_UpTexture->m_Height * m_Parent->m_Scale)))
		{
			m_Hovered = false;
			m_Hot = true;
		}

		else if (g_Input->WasLButtonClickedInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + int(m_UpTexture->m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + int(m_UpTexture->m_Height * m_Parent->m_Scale)))
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
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

	int adjustedx = m_Parent->m_GuiX + (m_Pos.X * m_Parent->m_Scale);
	int adjustedy = m_Parent->m_GuiY + (m_Pos.Y * m_Parent->m_Scale);

	int adjustedw = m_Width * m_Parent->m_Scale;
	int adjustedh = m_Height * m_Parent->m_Scale;

	if (m_ActiveLeft == nullptr) // No sprites, so draw with colors
	{

		g_Display->DrawBox(adjustedx, adjustedy, adjustedw, adjustedh, m_BackgroundColor, true);

		if (m_Vertical)
		{
			m_SpurLocation = int((float(m_Value) / float(m_ValueRange) * (m_Height - m_Width)) * m_Parent->m_Scale);
			g_Display->DrawBox(adjustedx, adjustedy + m_SpurLocation, int(m_Width * m_Parent->m_Scale), int(m_Width * m_Parent->m_Scale), m_SpurColor, true);
		}
		else
		{
			m_SpurLocation = int((float(m_Value) / float(m_ValueRange) * (adjustedw - adjustedh)));// * m_Parent->m_Scale;
			g_Display->DrawBox(adjustedx + m_SpurLocation, adjustedy, int(m_Height * m_Parent->m_Scale), int(m_Height * m_Parent->m_Scale), m_SpurColor, true);
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

		float xmiddle = float(left->m_Width);
		float xright = float(m_Width - (left->m_Width + right->m_Width));



		if (m_Shadowed)
		{
			g_Display->DrawSpriteScaled(left, int(m_Parent->m_Pos.X + ((m_Pos.X + 3) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
			g_Display->DrawSpriteScaled(center, int(m_Parent->m_Pos.X + ((m_Pos.X + 3 + xmiddle) * m_Parent->m_Scale) - 1), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), ((xright + 3) / m_InactiveCenter->m_Width) * m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
			g_Display->DrawSpriteScaled(right, int(m_Parent->m_Pos.X + (m_Pos.X + 3 + xmiddle + xright) * m_Parent->m_Scale), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
		}

		g_Display->DrawSpriteScaled(left, int(m_Parent->m_Pos.X + (m_Pos.X * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale);
		g_Display->DrawSpriteScaled(center, int(m_Parent->m_Pos.X + ((m_Pos.X + xmiddle) * m_Parent->m_Scale) - 1), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), ((xright + 3) / m_InactiveCenter->m_Width) * m_Parent->m_Scale, m_Parent->m_Scale);
		g_Display->DrawSpriteScaled(right, int(m_Parent->m_Pos.X + (m_Pos.X + xmiddle + xright) * m_Parent->m_Scale), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale);

		//int debugadjustedx = m_Parent->m_GuiX + (m_Pos.X * m_Parent->m_Scale);
		//int debugadjustedy = int(m_Parent->m_Pos.Y + (float(m_Pos.Y) * m_Parent->m_Scale) + (float(m_Height) / 2.0f * m_Parent->m_Scale) - (float(spur->m_Height) / 2.0f * m_Parent->m_Scale));

		//int debugadjustedw = m_Width * m_Parent->m_Scale;
		//int debugadjustedh = m_SpurActive->m_Height * m_Parent->m_Scale;

		//g_Display->DrawBox(debugadjustedx, debugadjustedy, debugadjustedw, debugadjustedh, Color(1, 0, 0, .5), true);

		g_Display->DrawSpriteScaled(spur, int(m_Parent->m_Pos.X + ((m_Pos.X - (float(spur->m_Width) / 2)) * m_Parent->m_Scale)) + ((float(m_Value) / float(m_ValueRange)) * m_Width * m_Parent->m_Scale),
			//int(m_Parent->m_Pos.Y + ((m_Pos.Y + (float(spur->m_Height) / 2)) * m_Parent->m_Scale)),
			int(m_Parent->m_Pos.Y + (float(m_Pos.Y) * m_Parent->m_Scale) + (float(m_Height) / 2.0f * m_Parent->m_Scale) - (float(spur->m_Height) / 2.0f * m_Parent->m_Scale)),
			m_Parent->m_Scale, m_Parent->m_Scale);
	}
}

void GuiScrollBar::Update()
{
	Tween::Update();

	if (!m_Parent->m_AcceptingInput || !m_Active)
		return;

	m_Hovered = false;

	//  Is the LMB down inside the spur?
	int adjustedx = m_Parent->m_GuiX + (m_Pos.X * m_Parent->m_Scale);
	int adjustedy = int(m_Parent->m_Pos.Y + (float(m_Pos.Y) * m_Parent->m_Scale) + (float(m_Height) / 2.0f * m_Parent->m_Scale) - (float(m_SpurActive->m_Height) / 2.0f * m_Parent->m_Scale));

	int adjustedw = m_Width * m_Parent->m_Scale;
	int adjustedh = m_SpurActive->m_Height * m_Parent->m_Scale;

	//  Previously clicked, try for hysterisis
	if (m_Parent->m_LastElement == m_ID)
	{
		if (g_Input->IsLDragging() || g_Input->IsLButtonDownInRegion(adjustedx, adjustedy, adjustedx + adjustedw, adjustedy + adjustedh))
		{
			m_Parent->m_ActiveElement = m_ID; //  This element is still active.
			if (m_Vertical)
			{
				m_Value = std::round((float(g_Input->m_MouseY - adjustedy) / float(adjustedh)) * m_ValueRange);

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
				m_Value = std::round((float(g_Input->m_MouseX - adjustedx) / float(adjustedw)) * m_ValueRange);

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
	else if (m_Parent->m_ActiveElement == -1 && m_Parent->m_LastElement == -1 && g_Input->IsLButtonDownInRegion(adjustedx, adjustedy, adjustedx + adjustedw, adjustedy + adjustedh))
	{
		m_Parent->m_ActiveElement = m_ID;
		if (m_Vertical)
		{
			m_Value = std::round((float(g_Input->m_MouseY - adjustedy) / float(adjustedh)) * m_ValueRange);

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
			m_Value = std::round((float(g_Input->m_MouseX - adjustedx) / float(adjustedw)) * m_ValueRange);

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
	else if (g_Input->IsMouseInRegion(adjustedx, adjustedy, adjustedx + adjustedw, adjustedy + adjustedh))
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
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

	int adjustedx = int(m_Parent->m_GuiX + m_Pos.X);
	int adjustedy = int(m_Parent->m_GuiY + m_Pos.Y);

	g_Display->DrawBox(adjustedx, adjustedy, m_Width, m_Height, m_BackgroundColor, true);
	g_Display->DrawBox(adjustedx, adjustedy, m_Width, m_Height, m_BoxColor, false);

	if (!m_HasFocus)
	{
		m_Font->DrawString(m_String, adjustedx + 2, adjustedy + 2, m_TextColor);
	}
	else
	{
		if (g_Engine->GameTimeInMS() % 1000 > 500)
		{
			m_Font->DrawString(m_String + "|", adjustedx + 2, adjustedy + 2, m_TextColor);
		}
		else
		{
			m_Font->DrawString(m_String, adjustedx + 2, adjustedy + 2, m_TextColor);
		}
	}

	return;
}

void GuiTextInput::Update()
{
	Tween::Update();

	int adjustedx = int(m_Parent->m_GuiX + m_Pos.X);
	int adjustedy = int(m_Parent->m_GuiY + m_Pos.Y);

	if (m_HasFocus && m_Parent->m_LastElement != m_ID)
	{
		m_HasFocus = false;
	}

	if (!m_Parent->m_AcceptingInput)
		return;

	//  If the left button is down, we are CLICKED
	if (g_Input->WasLButtonClickedInRegion(adjustedx, adjustedy, adjustedx + m_Width, adjustedy + m_Height))
	{
		m_HasFocus = true;
		m_Parent->m_ActiveElement = m_ID;
	}


	if (m_HasFocus && (g_Input->WasKeyPressed(KEY_KP_ENTER) || g_Input->WasKeyPressed(KEY_RETURN)))
	{
		m_HasFocus = false;
	}

	if (m_HasFocus && (g_Input->WasKeyPressed(KEY_BACKSPACE)))
	{
		if (m_String.size() > 0)
		{
			m_String = m_String.substr(0, m_String.size() - 1);
		}
	}

	if (m_HasFocus && g_Input->GetLastKeyPressed() >= KEY_SPACE && g_Input->GetLastKeyPressed() <= KEY_z)
	{
		m_String += char(g_Input->GetLastKeyPressed());
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
	m_SelectSprite = selected;
	m_DeselectSprite = unselected;
	m_HoveredSprite = hovered;
	m_HoveredSelectedSprite = hoveredselected;
	m_Color = color;
	m_Width = selected->m_Width;
	m_Height = selected->m_Height;
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
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

	int adjustedx = m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale);
	int adjustedy = m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale);

	int adjustedw = int(m_Width * m_Parent->m_Scale);
	int adjustedh = int(m_Height * m_Parent->m_Scale);

	if (m_SelectSprite == nullptr) // no sprites, just use draw commands to draw it
	{
		if (m_Selected)
		{
			g_Display->DrawBox(adjustedx, adjustedy, adjustedw, adjustedh, Color(1, 1, 1, 1), false);
			g_Display->DrawBox(adjustedx + 2, adjustedy + 2, adjustedw - 4, adjustedh - 4, Color(1, 1, 1, 1), true);
		}
		else
		{
			g_Display->DrawBox(adjustedx, adjustedy, adjustedw, adjustedh, Color(1, 1, 1, 1), false);
		}
	}
	else //  We have sprites, use them.
	{
		if (m_Selected)
		{
			if (m_Hovered || m_Hot)
			{
				g_Display->DrawSpriteScaled(m_HoveredSelectedSprite,
					m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
					m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, m_Color);
			}
			else
			{
				g_Display->DrawSpriteScaled(m_SelectSprite,
					m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
					m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, m_Color);
			}
		}
		else
		{
			if (m_Hovered || m_Hot)
			{
				g_Display->DrawSpriteScaled(m_HoveredSprite,
					m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
					m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, m_Color);

			}
			else
			{
				g_Display->DrawSpriteScaled(m_DeselectSprite,
					m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
					m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, m_Color);
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
		m_Hovered = g_Input->IsMouseInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale));

		m_Hot = g_Input->IsLButtonDownInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale));

		if (g_Input->WasLButtonClickedInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale)))
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
	m_SelectSprite = selected;
	m_DeselectSprite = deselected;
	m_HoveredSprite = hovered;
	m_Color = color;
	m_Width = selected->m_Width;
	m_Height = selected->m_Height;
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
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

	int adjustedx = m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale);
	int adjustedy = m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale);

	int adjustedw = int(m_Width * m_Parent->m_Scale);
	int adjustedh = int(m_Height * m_Parent->m_Scale);

	if (m_SelectSprite == nullptr)
	{
		if (m_Selected)
		{
			g_Display->DrawBox(adjustedx, adjustedy, adjustedw, adjustedh, Color(1, 1, 1, 1), false);
			g_Display->DrawBox(adjustedx + 2, adjustedy + 2, adjustedw - 4, adjustedh - 4, Color(1, 1, 1, 1), true);
		}
		else
		{
			g_Display->DrawBox(adjustedx, adjustedy, adjustedw, adjustedh, Color(1, 1, 1, 1), false);
		}
	}
	else
	{
		if (m_Selected)
		{
			if (m_Shadowed)
			{
				g_Display->DrawSpriteScaled(m_SelectSprite,
					m_Parent->m_GuiX + int((m_Pos.X + 3) * m_Parent->m_Scale), m_Parent->m_GuiY + int((m_Pos.Y + 3) * m_Parent->m_Scale),
					m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, Color(0, 0, 0, 1));
			}
			g_Display->DrawSpriteScaled(m_SelectSprite,
				m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
				m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, m_Color);
		}
		else
		{
			if (m_Hovered && m_HoveredSprite != nullptr)
			{
				if (m_Shadowed)
				{
					g_Display->DrawSpriteScaled(m_HoveredSprite,
						m_Parent->m_GuiX + int((m_Pos.X + 3) * m_Parent->m_Scale), m_Parent->m_GuiY + int((m_Pos.Y + 3) * m_Parent->m_Scale),
						m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, Color(0, 0, 0, 1));
				}
				g_Display->DrawSpriteScaled(m_HoveredSprite,
					m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
					m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, m_Color);
			}
			else
			{
				if (m_Shadowed)
				{
					g_Display->DrawSpriteScaled(m_DeselectSprite,
						m_Parent->m_GuiX + int((m_Pos.X + 3) * m_Parent->m_Scale), m_Parent->m_GuiY + int((m_Pos.Y + 3) * m_Parent->m_Scale),
						m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, Color(0, 0, 0, 1));
				}
				g_Display->DrawSpriteScaled(m_DeselectSprite,
					m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
					m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, m_Color);
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
		if (g_Input->IsMouseInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale)))
		{
			m_Hovered = true;
		}
		else
		{
			m_Hovered = false;
		}

		if (g_Input->WasLButtonClickedInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale)))
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
	m_Width = width;
	m_Height = height;
	m_Color = color;
	m_Filled = filled;
}

void GuiPanel::Draw()
{
	if (!m_Visible)
		return;

	int adjustedx = m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale);
	int adjustedy = m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale);

	int adjustedw = int(m_Width * m_Parent->m_Scale);
	int adjustedh = int(m_Height * m_Parent->m_Scale);

	if (m_Filled)
		g_Display->DrawBox(adjustedx, adjustedy, adjustedw, adjustedh, m_Color, true);
	else
		g_Display->DrawBox(adjustedx, adjustedy, adjustedw, adjustedh, m_Color, false);
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
	m_String = text;
	m_Justified = justified;
	m_Font = font;
	m_Color = color;
	m_Width = width;
	m_Shadowed = shadowed;
	if (m_Width == 0)
		m_Height = int(font->GetHeight());
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
			m_Font->DrawStringRight(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + m_Width + 2) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 2) * m_Parent->m_Scale)), Color(0, 0, 0, 1), m_Parent->m_Scale);

		m_Font->DrawStringRight(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + m_Width) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Color, m_Parent->m_Scale);
	}
	else if (m_Justified == GuiTextArea::CENTERED)
	{
		if (m_Font->GetStringMetrics(m_String) < m_Width)
		{
			int textlength = m_Font->GetStringMetrics(m_String);

			//g_Display->DrawBox(int(m_Parent->m_Pos.X + ((m_Pos.X + (m_Width / 2)) * m_Parent->m_Scale)) - (m_Width / 2), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Width, m_Font->GetHeight(), Color(.5, 0, 0, .75), true);
			if (m_Shadowed)
				m_Font->DrawStringCentered(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 2 + (m_Width / 2)) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 2) * m_Parent->m_Scale)), Color(0, 0, 0, 1));
			m_Font->DrawStringCentered(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + (m_Width / 2)) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Color);
		}
		else
		{
			int textlength = m_Font->GetStringMetrics(m_String);

			//g_Display->DrawBox(int(m_Parent->m_Pos.X + ((m_Pos.X + (m_Width / 2)) * m_Parent->m_Scale) - textlength / 2), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Width * m_Parent->m_Scale, m_Font->GetHeight(), Color(.5, 0, 0, .75), true);
			if (m_Shadowed)
				m_Font->DrawParagraphCentered(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + (m_Width / 2)) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Width * m_Parent->m_Scale, m_Font->GetHeight(), Color(0, 0, 0, 1));
			m_Font->DrawParagraphCentered(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + (m_Width / 2)) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Width * m_Parent->m_Scale, m_Font->GetHeight(), m_Color);
		}
	}
	else
	{
		if (m_Width == 0) // An unset width parameter means "draw as a single string"
		{
			int textWidth = m_Font->GetStringMetrics(m_String);
			//g_Display->DrawBox(int(m_Parent->m_Pos.X + (m_Pos.X * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), textWidth, m_Height, Color(.5, 0, 0, .75), true);
			if (m_Shadowed)
				m_Font->DrawString(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 2) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 2) * m_Parent->m_Scale)), Color(0, 0, 0, 1), m_Parent->m_Scale);
			m_Font->DrawString(m_String, int(m_Parent->m_Pos.X + (m_Pos.X * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Color, m_Parent->m_Scale);
		}
		else
		{
			int height = m_Font->GetStringMetricsHeight(m_String, m_Width);
			//g_Display->DrawBox(int(m_Parent->m_Pos.X + (m_Pos.X * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Width * m_Parent->m_Scale, height, Color(.5, 0, 0, .75), true);
			if (m_Shadowed)
				m_Font->DrawParagraph(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 2) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 2) * m_Parent->m_Scale)), m_Width, m_Height, Color(0, 0, 0, 1), m_Parent->m_Scale);
			m_Font->DrawParagraph(m_String, int(m_Parent->m_Pos.X + (m_Pos.X * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Width, m_Height, m_Color, m_Parent->m_Scale);
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
	m_Sprite = sprite;
	m_Color = color;
	m_Width = sprite->m_Width;
	m_Height = sprite->m_Height;
	m_ScaleX = scalex;
	m_ScaleY = scaley;
}

void GuiSprite::Draw()
{
	if (m_Sprite && m_Active && m_Visible)
	{
		g_Display->DrawSpriteScaled(m_Sprite,
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale), m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_ScaleX * m_Parent->m_Scale, m_ScaleY * m_Parent->m_Scale, m_Color);
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
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

	int x = m_Parent->m_Pos.X + (m_Pos.X * m_Parent->m_Scale);
	int y = m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale);

	//  Find out, in pixels, how wide everything should be and where it should be positioned.
	int cornerWidth = (m_Sprites[0]->m_Width + (m_Parent->m_Scale < 1 ? 1 : 0)) * m_Parent->m_Scale;
	int cornerHeight = (m_Sprites[0]->m_Height + (m_Parent->m_Scale < 1 ? 1 : 0)) * m_Parent->m_Scale;

	int finalWidth = m_Width * m_Parent->m_Scale;
	int finalHeight = m_Height * m_Parent->m_Scale;

	int runnerWidth = finalWidth - (cornerWidth * 2); // Since both components have been scaled, this does not have to be scaled.
	int runnerHeight = finalHeight - (cornerHeight * 2); // Ditto.

	int xmiddle = cornerWidth;
	int xright = cornerWidth + runnerWidth;

	int ymiddle = cornerHeight;
	int ybottom = cornerHeight + runnerHeight;

	//  Center
	g_Display->DrawSpriteScaled(m_Sprites[4], x + cornerWidth, y + cornerHeight, float(runnerWidth) / 2.0f, float(runnerHeight) / 2.0f, m_Color);

	//  Top and bottom bars
	g_Display->DrawSpriteScaled(m_Sprites[1], x + cornerWidth, y, float(runnerWidth) / 2.0f, m_Parent->m_Scale, m_Color);
	g_Display->DrawSpriteScaled(m_Sprites[7], x + cornerWidth, y + cornerHeight + runnerHeight, float(runnerWidth) / 2.0f, m_Parent->m_Scale, m_Color);

	//  Left and right bars
	g_Display->DrawSpriteScaled(m_Sprites[3], x, y + cornerHeight, m_Parent->m_Scale, float(runnerHeight) / 2.0f, m_Color);
	g_Display->DrawSpriteScaled(m_Sprites[5], x + cornerWidth + runnerWidth, y + cornerHeight, m_Parent->m_Scale, float(runnerHeight) / 2.0f, m_Color);

	//  Top corners
	g_Display->DrawSpriteScaled(m_Sprites[0], x, y, m_Parent->m_Scale, m_Parent->m_Scale, m_Color);
	g_Display->DrawSpriteScaled(m_Sprites[2], x + cornerWidth + runnerWidth, y, m_Parent->m_Scale, m_Parent->m_Scale, m_Color);

	//  Bottom corners
	g_Display->DrawSpriteScaled(m_Sprites[6], x, y + cornerHeight + runnerHeight, m_Parent->m_Scale, m_Parent->m_Scale, m_Color);
	g_Display->DrawSpriteScaled(m_Sprites[8], x + cornerWidth + runnerWidth, y + cornerHeight + runnerHeight, m_Parent->m_Scale, m_Parent->m_Scale, m_Color);
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
	m_Pos.X = float(posx);
	m_Pos.Y = float(posy);
	m_Color = color;
	m_Width = width;
	m_Height = activeLeft->m_Height;
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

	if (!m_Active)
	{
		float xmiddle = float(m_InactiveLeft->m_Width);
		float xright = float(m_Width - (m_InactiveLeft->m_Width + m_InactiveRight->m_Width));

		if (m_Shadowed)
		{
			g_Display->DrawSpriteScaled(m_InactiveLeft, int(m_Parent->m_Pos.X + ((m_Pos.X + 3) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
			g_Display->DrawSpriteScaled(m_InactiveCenter, int(m_Parent->m_Pos.X + ((m_Pos.X + 3 + xmiddle) * m_Parent->m_Scale) - 1), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), ((xright + 3) / m_InactiveCenter->m_Width) * m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
			g_Display->DrawSpriteScaled(m_InactiveRight, int(m_Parent->m_Pos.X + (m_Pos.X + 3 + xmiddle + xright) * m_Parent->m_Scale), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
		}

		g_Display->DrawSpriteScaled(m_InactiveLeft, int(m_Parent->m_Pos.X + (m_Pos.X * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(.5, .5, .5, 1));
		g_Display->DrawSpriteScaled(m_InactiveCenter, int(m_Parent->m_Pos.X + ((m_Pos.X + xmiddle) * m_Parent->m_Scale) - 1), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), ((xright + 3) / m_InactiveCenter->m_Width) * m_Parent->m_Scale, m_Parent->m_Scale, Color(.5, .5, .5, 1));
		g_Display->DrawSpriteScaled(m_InactiveRight, int(m_Parent->m_Pos.X + (m_Pos.X + xmiddle + xright) * m_Parent->m_Scale), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(.5, .5, .5, 1));

		m_Parent->m_Font->DrawString(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 18) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 8) * m_Parent->m_Scale)), Color(0, 0, 0, 1));
		m_Parent->m_Font->DrawString(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 16) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 7) * m_Parent->m_Scale)), Color(.5, .5, .5, 1));
	}
	else if (m_Hovered || m_Hot || m_Clicked)
	{
		float xmiddle = float(m_ActiveLeft->m_Width);
		float xright = float(m_Width - (m_ActiveLeft->m_Width + m_ActiveRight->m_Width));

		if (m_Shadowed)
		{
			g_Display->DrawSpriteScaled(m_ActiveLeft, int(m_Parent->m_Pos.X + (m_Indent * m_Parent->m_Scale) + ((m_Pos.X + 3) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
			g_Display->DrawSpriteScaled(m_ActiveCenter, int(m_Parent->m_Pos.X + (m_Indent * m_Parent->m_Scale) + ((m_Pos.X + 3 + xmiddle) * m_Parent->m_Scale) - 1), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), ((xright + 3) / m_ActiveCenter->m_Width) * m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
			g_Display->DrawSpriteScaled(m_ActiveRight, int(m_Parent->m_Pos.X + (m_Indent * m_Parent->m_Scale) + (m_Pos.X + 3 + xmiddle + xright) * m_Parent->m_Scale), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
		}
		if (m_Hot || m_Clicked)
		{
			g_Display->DrawSpriteScaled(m_ActiveLeft, int(m_Parent->m_Pos.X + (m_Indent * m_Parent->m_Scale) + ((m_Pos.X + 3) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(1, 1, 1, 1));
			g_Display->DrawSpriteScaled(m_ActiveCenter, int(m_Parent->m_Pos.X + (m_Indent * m_Parent->m_Scale) + ((m_Pos.X + 3 + xmiddle) * m_Parent->m_Scale) - 1), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), ((xright + 3) / m_ActiveCenter->m_Width) * m_Parent->m_Scale, m_Parent->m_Scale, Color(1, 1, 1, 1));
			g_Display->DrawSpriteScaled(m_ActiveRight, int(m_Parent->m_Pos.X + (m_Indent * m_Parent->m_Scale) + (m_Pos.X + 3 + xmiddle + xright) * m_Parent->m_Scale), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(1, 1, 1, 1));
		}
		else
		{
			g_Display->DrawSpriteScaled(m_ActiveLeft, int(m_Parent->m_Pos.X + (m_Indent * m_Parent->m_Scale) + (m_Pos.X * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale);
			g_Display->DrawSpriteScaled(m_ActiveCenter, int(m_Parent->m_Pos.X + (m_Indent * m_Parent->m_Scale) + ((m_Pos.X + xmiddle) * m_Parent->m_Scale) - 1), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), ((xright + 3) / m_ActiveCenter->m_Width) * m_Parent->m_Scale, m_Parent->m_Scale);
			g_Display->DrawSpriteScaled(m_ActiveRight, int(m_Parent->m_Pos.X + (m_Indent * m_Parent->m_Scale) + (m_Pos.X + xmiddle + xright) * m_Parent->m_Scale), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale);
		}

		if (m_Hot || m_Clicked)
		{
			m_Parent->m_Font->DrawString(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 18 + 3 + m_Indent) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 8 + 3) * m_Parent->m_Scale)), Color(0, 0, 0, 1));
			m_Parent->m_Font->DrawString(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 16 + 3 + m_Indent) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 7 + 3) * m_Parent->m_Scale)), Color(1, 1, 1, 1));
		}
		else
		{
			m_Parent->m_Font->DrawString(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 18 + m_Indent) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 8) * m_Parent->m_Scale)), Color(0, 0, 0, 1));
			m_Parent->m_Font->DrawString(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 16 + m_Indent) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 7) * m_Parent->m_Scale)), Color(1, 1, 1, 1));
		}
	}
	else
	{
		float xmiddle = float(m_InactiveLeft->m_Width);
		float xright = float(m_Width - (m_InactiveLeft->m_Width + m_InactiveRight->m_Width));

		if (m_Shadowed)
		{
			g_Display->DrawSpriteScaled(m_InactiveLeft, int(m_Parent->m_Pos.X + ((m_Pos.X + 3) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
			g_Display->DrawSpriteScaled(m_InactiveCenter, int(m_Parent->m_Pos.X + ((m_Pos.X + 3 + xmiddle) * m_Parent->m_Scale) - 1), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), ((xright + 3) / m_InactiveCenter->m_Width) * m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
			g_Display->DrawSpriteScaled(m_InactiveRight, int(m_Parent->m_Pos.X + (m_Pos.X + 3 + xmiddle + xright) * m_Parent->m_Scale), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 3) * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale, Color(0, 0, 0, 1));
		}

		g_Display->DrawSpriteScaled(m_InactiveLeft, int(m_Parent->m_Pos.X + (m_Pos.X * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale);
		g_Display->DrawSpriteScaled(m_InactiveCenter, int(m_Parent->m_Pos.X + ((m_Pos.X + xmiddle) * m_Parent->m_Scale) - 1), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), ((xright + 3) / m_InactiveCenter->m_Width) * m_Parent->m_Scale, m_Parent->m_Scale);
		g_Display->DrawSpriteScaled(m_InactiveRight, int(m_Parent->m_Pos.X + (m_Pos.X + xmiddle + xright) * m_Parent->m_Scale), int(m_Parent->m_Pos.Y + (m_Pos.Y * m_Parent->m_Scale)), m_Parent->m_Scale, m_Parent->m_Scale);

		m_Parent->m_Font->DrawString(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 18) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 8) * m_Parent->m_Scale)), Color(0, 0, 0, 1));
		m_Parent->m_Font->DrawString(m_String, int(m_Parent->m_Pos.X + ((m_Pos.X + 16) * m_Parent->m_Scale)), int(m_Parent->m_Pos.Y + ((m_Pos.Y + 7) * m_Parent->m_Scale)), Color(1, 1, 1, 1));
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
		if (g_Input->WasLButtonJustClickedInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale)))
		{
			m_Hovered = false;
			m_Clicked = true;
			m_Parent->m_ActiveElement = m_ID;
		}
		else if (g_Input->IsMouseInRegion(m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale),
			m_Parent->m_GuiX + int(m_Pos.X * m_Parent->m_Scale) + int(m_Width * m_Parent->m_Scale),
			m_Parent->m_GuiY + int(m_Pos.Y * m_Parent->m_Scale) + int(m_Height * m_Parent->m_Scale)))
		{
			m_Hovered = true;
			m_Clicked = false;
		}
	}
}