#include <fstream>
#include <string>
#include <sstream>

#include "Globals.h"
#include "Engine.h"
#include "Gui.h"
#include "ResourceManager.h"
#include "Config.h"

#include "raylib.h"

using namespace std;

Gui::Gui()
{
	m_PositionFlag = GUIP_USE_XY;
	m_Width = 0;
	m_Height = 0;
	m_Active = 1;
	m_Editing = false;
	m_ActiveElement = -1;
	m_LastElement = -2;
	m_InputScale = 1;
	m_Font = make_shared<Font>(GetFontDefault());
	m_Draggable = false;
	m_IsDragging = false;
	m_DragOffset = { 0, 0 };
	m_DragAreaHeight = 20;
	m_isDone = false;
	m_doneButtonId = -3;
}

void Gui::AddElement(std::shared_ptr<GuiElement> element)
{
	if (element && element->m_ID >= 0)
	{
		m_GuiElementList.emplace(element->m_ID, element);
	}
}

std::shared_ptr<GuiElement> Gui::GetActiveElement()
{
	if (m_ActiveElement != -1 && m_GuiElementList.find(m_ActiveElement) != m_GuiElementList.end())
		return m_GuiElementList[m_ActiveElement];
	else
		return nullptr;
}

void Gui::Init(const std::string& configfile)
{
	LoadTXT(configfile);
}

void Gui::Update()
{
	if (!m_Active || m_isDone)
		return;

	m_LastElement = m_ActiveElement;
	m_ActiveElement = -1;
	for (auto& node : m_GuiElementList)
	{
		node.second->Update();
	}

	if (m_ActiveElement == m_doneButtonId)
	{
		m_isDone = true;
	}

	if (m_Draggable)
	{
		Vector2 mousePos = GetMousePosition();
		mousePos.x /= m_InputScale;
		mousePos.y /= m_InputScale;

		if (IsMouseInDragArea())
		{
			if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
			{
				m_IsDragging = true;
				m_DragOffset.x = mousePos.x - m_Pos.x;
				m_DragOffset.y = mousePos.y - m_Pos.y;
			}
		}

		if (m_IsDragging && IsMouseButtonReleased(MOUSE_LEFT_BUTTON))
		{
			m_IsDragging = false;
		}

		if (m_IsDragging && IsMouseButtonDown(MOUSE_LEFT_BUTTON))
		{
			m_Pos.x = mousePos.x - m_DragOffset.x;
			m_Pos.y = mousePos.y - m_DragOffset.y;
			m_PositionFlag = GUIP_USE_XY;
		}
	}
}

void Gui::Draw()
{
	if (!m_Active || m_isDone)
		return;

	for (auto& node : m_GuiElementList)
	{
		node.second->Draw();
	}
}

void Gui::SetLayout(int x, int y, int width, int height, float scale, int flag)
{
	m_Pos.x = float(x);
	m_Pos.y = float(y);
	m_Width = float(width);
	m_Height = float(height);
	m_PositionFlag = flag;
	m_InputScale = scale;

	switch (m_PositionFlag)
	{
	case GUIP_USE_XY:
		break;

	case GUIP_UPPERLEFT:
		m_Pos.x = 0;
		m_Pos.y = 0;
		break;

	case GUIP_UPPERRIGHT:
		m_Pos.x = g_Engine.get()->m_RenderWidth - m_Width;
		m_Pos.y = 0;
		break;

	case GUIP_LOWERLEFT:
		m_Pos.x = 0;
		m_Pos.y = g_Engine.get()->m_RenderHeight - m_Height;
		break;

	case GUIP_LOWERRIGHT:
		m_Pos.x = g_Engine.get()->m_RenderWidth - m_Width;
		m_Pos.y = g_Engine.get()->m_RenderHeight - m_Height;
		break;

	case GUIP_FLOATLEFT:
		m_Pos.x = 0;
		m_Pos.y = (g_Engine.get()->m_RenderHeight - m_Height) / 2;
		break;

	case GUIP_FLOATRIGHT:
		m_Pos.x = g_Engine.get()->m_RenderWidth - m_Width;
		m_Pos.y = (g_Engine.get()->m_RenderHeight - m_Height) / 2;
		break;

	case GUIP_FLOATTOP:
		m_Pos.x = (g_Engine.get()->m_RenderWidth - m_Width) / 2;
		m_Pos.y = 0;
		break;

	case GUIP_FLOATBOTTOM:
		m_Pos.x = (g_Engine.get()->m_RenderWidth - m_Width) / 2;
		m_Pos.y = g_Engine.get()->m_RenderHeight - m_Height;
		break;

	case GUIP_CENTER:
		m_Pos.x = (g_Engine.get()->m_RenderWidth - m_Width) / 2;
		m_Pos.y = (g_Engine.get()->m_RenderHeight - m_Height) / 2;
		break;
	}
}

shared_ptr<GuiElement> Gui::GetElement(int ID)
{
	if (m_GuiElementList.find(ID) == m_GuiElementList.end())
		return nullptr;
	else
		return m_GuiElementList[ID];
}

GuiTextButton* Gui::AddTextButton(int ID, int posx, int posy, int width, int height, std::string text, Font* font,
	Color textcolor, Color backgroundcolor,
	Color bordercolor, int group, int active)
{
	shared_ptr<GuiTextButton> textbutton = make_shared<GuiTextButton>(this);
	textbutton->Init(ID, posx, posy, width, height, text, font, textcolor, backgroundcolor, bordercolor,
		group, active);
	m_GuiElementList[ID] = textbutton;
	return textbutton.get();
}

GuiTextButton* Gui::AddTextButton(int ID, int posx, int posy, std::string text, Font* font,	Color textcolor,
	Color backgroundcolor, Color bordercolor, int group, int active)
{
	if (font == nullptr)
	{
		font = m_Font.get();
	}

	Vector2 textDims = MeasureTextEx(*font, text.c_str(), float(font->baseSize) / 2.0f, 1);

	shared_ptr<GuiTextButton> textbutton = make_shared<GuiTextButton>(this);
	textbutton->Init(ID, posx, posy, int(textDims.x), int(textDims.y), text, font, textcolor, backgroundcolor, bordercolor,
		group, active);
	m_GuiElementList[ID] = textbutton;
	return textbutton.get();
}

GuiIconButton* Gui::AddIconButton(int ID, int posx, int posy, shared_ptr<Sprite> upbutton, shared_ptr<Sprite> downbutton,
	shared_ptr<Sprite> inactivebutton, std::string text, Font* font,
	Color fontcolor, float scale, int group, int active, bool canbeheld)
{
	shared_ptr<GuiIconButton> iconbutton = make_shared<GuiIconButton>(this);
	iconbutton->Init(ID, posx, posy, upbutton, downbutton, inactivebutton, text, font, fontcolor, scale, group, active, canbeheld);
	m_GuiElementList[ID] = iconbutton;
	return iconbutton.get();
}

GuiIconButton* Gui::AddIconButton(int ID, Texture* tex, int posx, int posy, int tilex, int tiley, int width, int height, std::string text, Font* font, Color fontcolor, float scale, int group, int active)
{
	shared_ptr<Sprite> upbutton = make_shared<Sprite>(tex, tilex, tiley, width, height);
	shared_ptr<Sprite> downbutton = make_shared<Sprite>(tex, tilex, tiley + height, width, height);
	shared_ptr<Sprite> inactivebutton = make_shared<Sprite>(tex, tilex + width, tiley + height, width, height);

	shared_ptr<GuiIconButton> iconbutton = make_shared<GuiIconButton>(this);
	iconbutton->Init(ID, posx, posy, upbutton, downbutton, inactivebutton, text, font, fontcolor, scale, group, active);
	m_GuiElementList[ID] = iconbutton;
	return iconbutton.get();
}

GuiCheckBox* Gui::AddCheckBox(int ID, int posx, int posy, std::shared_ptr<Sprite> Unselected, std::shared_ptr<Sprite> Selected, std::shared_ptr<Sprite> Hovered, std::shared_ptr<Sprite> HoveredSelected,
	float scalex, float scaley, Color color, int group, int active)
{
	shared_ptr<GuiCheckBox> checkbox = make_shared<GuiCheckBox>(this);
	checkbox->Init(ID, posx, posy, Unselected, Selected, Hovered, HoveredSelected, scalex, scaley, color, group, active);
	m_GuiElementList[ID] = (checkbox);
	return checkbox.get();
}

GuiCheckBox* Gui::AddCheckBox(int ID, int posx, int posy, int width, int height,
	float scalex, float scaley, Color color, int group, int active)
{
	shared_ptr<GuiCheckBox> checkbox = make_shared<GuiCheckBox>(this);
	checkbox->Init(ID, posx, posy, width, height, scalex, scaley, color, group, active);
	m_GuiElementList[ID] = (checkbox);
	return checkbox.get();
}

GuiRadioButton* Gui::AddRadioButton(int ID, int posx, int posy, std::shared_ptr<Sprite> Selected, std::shared_ptr<Sprite> Unselected, std::shared_ptr<Sprite> Hovered,
	float scalex, float scaley, Color color, int group, int active, bool shadowed)
{
	shared_ptr<GuiRadioButton> radioButton = make_shared<GuiRadioButton>(this);
	radioButton->Init(ID, posx, posy, Selected, Unselected, Hovered, scalex, scaley, color, group, active, shadowed);
	m_GuiElementList[ID] = (radioButton);
	return radioButton.get();
}

GuiRadioButton* Gui::AddRadioButton(int ID, int posx, int posy, int width, int height,
	float scalex, float scaley, Color color, int group, int active, bool shadowed)
{
	shared_ptr<GuiRadioButton> radioButton = make_shared<GuiRadioButton>(this);
	radioButton->Init(ID, posx, posy, width, height, scalex, scaley, color, group, active, shadowed);
	m_GuiElementList[ID] = (radioButton);
	return radioButton.get();
}

GuiScrollBar* Gui::AddScrollBar(int ID, int valuerange, int posx, int posy, int width, int height, bool vertical,
	Color spurcolor, Color backgroundcolor, int group, int active, bool shadowed)
{
	shared_ptr<GuiScrollBar> scrollbar = make_shared<GuiScrollBar>(this);
	scrollbar->Init(ID, valuerange, posx, posy, width, height, vertical, spurcolor, backgroundcolor, group, active, shadowed);
	m_GuiElementList[ID] = (scrollbar);
	return scrollbar.get();
}

GuiTextInput* Gui::AddTextInput(int ID, int posx, int posy, int width, int height,
	Font* font, std::string initialtext, Color textcolor, Color boxcolor,
	Color backgroundcolor, int group, int active)
{
	shared_ptr<GuiTextInput> textinput = make_shared<GuiTextInput>(this);
	textinput->Init(ID, posx, posy, width, height, font, initialtext, textcolor,
		boxcolor, backgroundcolor, group, active);
	m_GuiElementList[ID] = (textinput);
	return textinput.get();
}

GuiPanel* Gui::AddPanel(int ID, int posx, int posy, int width, int height,
	Color color, bool filled, int group, int active)
{
	shared_ptr<GuiPanel> panel = make_shared<GuiPanel>(this);
	panel->Init(ID, posx, posy, width, height, color, filled, group, active);
	m_GuiElementList[ID] = (panel);
	return panel.get();
}

GuiTextArea* Gui::AddTextArea(int ID, Font* font, std::string text, int posx, int posy, int width, int height,
	Color color, int justified, int group, int active, bool shadowed)
{
	shared_ptr<GuiTextArea> area = make_shared<GuiTextArea>(this);
	area->Init(ID, font, text, posx, posy, width, height, color, justified, group, active, shadowed);
	m_GuiElementList[ID] = (area);
	return area.get();
}

GuiSprite* Gui::AddSprite(int ID, int posx, int posy, std::shared_ptr<Sprite> sprite, float scalex, float scaley,
	Color color, int group, int active)
{
	shared_ptr<GuiSprite> guiSprite = make_shared<GuiSprite>(this);
	guiSprite->Init(ID, posx, posy, sprite, scalex, scaley, color, group, active);
	m_GuiElementList[ID] = (guiSprite);
	return guiSprite.get();
}

GuiOctagonBox* Gui::AddOctagonBox(int ID, int posx, int posy, int width, int height, std::vector<std::shared_ptr<Sprite> > borders,
	Color color, int group, int active)
{
	shared_ptr<GuiOctagonBox> guiOctagonBox = make_shared<GuiOctagonBox>(this);
	guiOctagonBox->Init(ID, posx, posy, width, height, borders, color, group, active);
	m_GuiElementList[ID] = guiOctagonBox;
	return guiOctagonBox.get();
}

GuiStretchButton* Gui::AddStretchButton(int ID, int posx, int posy, int width, string label,
	std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> activeCenter,
	std::shared_ptr<Sprite> inactiveLeft, std::shared_ptr<Sprite> inactiveRight, std::shared_ptr<Sprite> inactiveCenter, int indent,
	Color color, int group, int active, bool shadowed)
{
	shared_ptr<GuiStretchButton> guiStretchButton = make_shared<GuiStretchButton>(this);
	guiStretchButton->Init(ID, posx, posy, width, label, activeLeft, activeRight, activeCenter, inactiveLeft, inactiveRight, inactiveCenter, indent, color, group, active, shadowed);
	m_GuiElementList[ID] = guiStretchButton;
	return guiStretchButton.get();
}

GuiStretchButton* Gui::AddStretchButtonCentered(int ID, int posy, string label,
	std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> activeCenter,
	std::shared_ptr<Sprite> inactiveLeft, std::shared_ptr<Sprite> inactiveRight, std::shared_ptr<Sprite> inactiveCenter, int indent,
	Color color, int group, int active, bool shadowed)
{
	float textWidth = float(MeasureText(label.c_str(), m_Font->baseSize));
	float width = activeLeft->m_sourceRect.width + textWidth + activeRight->m_sourceRect.width;

	int x = int((m_Width - width) / 2.0f);

	return AddStretchButton(ID, x, posy, int(width), label, activeLeft, activeRight, activeCenter, inactiveLeft, inactiveRight, inactiveCenter, indent, color, group, active, shadowed);
}

GuiList* Gui::AddGuiList(int ID, int posx, int posy, int width, int height, Font* font,
			 const std::vector<std::string>& items, Color textcolor,
			 Color backgroundcolor, Color bordercolor,
			 int group, int active)
{
	shared_ptr<GuiList> guiList = make_shared<GuiList>(this);
	guiList->Init(ID, posx, posy, width, height, font, items, textcolor, backgroundcolor, bordercolor, group, active);
	m_GuiElementList[ID] = guiList;
	return guiList.get();
}

std::string Gui::GetString(int ID)
{
	if (m_GuiElementList.find(ID) == m_GuiElementList.end())
		return "";

	return m_GuiElementList[ID]->GetString();
}

void Gui::LoadTXT(std::string fileName)
{
	ifstream instream(fileName.c_str(), ios::in | ios::binary);
	if (!instream.fail())
	{
		string line;
		stringstream parser;
		instream >> m_Pos.x;
		instream >> m_Pos.y;

		getline(instream, line);
		getline(instream, line);

		if (line.size() > 0)
		{
			if (line.at(line.size() - 1) == '\r')
			{
				line = line.substr(0, line.size() - 1);
			}
		}

		m_Font = make_shared<Font>(LoadFont(line.c_str()));

		while (!instream.eof())
		{
			getline(instream, line);

			if (line.size() > 0)
			{
				if (line.at(line.size() - 1) == '\r')
				{
					line = line.substr(0, line.size() - 1);
				}
			}

			if (line[0] != '#')
			{
				stringstream _LineData;
				_LineData << line;
				int type;
				_LineData >> type;
				switch (type)
				{
				case GUI_ICONBUTTON:
				{
					int buttonid, active, group, tilex, tiley, posx, posy, width, height;
					string Texture;
					_LineData >> buttonid;
					_LineData >> active;
					_LineData >> group;
					_LineData >> tilex;
					_LineData >> tiley;
					_LineData >> posx;
					_LineData >> posy;
					_LineData >> width;
					_LineData >> height;

					string _Buffer;
					_LineData >> _Buffer;
					Texture = _Buffer;

					shared_ptr<Sprite> upbutton = make_shared<Sprite>();
					upbutton->m_texture = g_ResourceManager->GetTexture(Texture);
					upbutton->m_sourceRect.x = float(tilex);
					upbutton->m_sourceRect.y = float(tiley);
					upbutton->m_sourceRect.width = float(width);
					upbutton->m_sourceRect.height = float(height);

					AddIconButton(buttonid, posx, posy, upbutton);
				}
				break;

				case GUI_PANEL:
				{
					int id, active, group, x, y, width, height, r, g, b, a;
					bool filled;
					_LineData >> id;
					_LineData >> active;
					_LineData >> group;
					_LineData >> x;
					_LineData >> y;
					_LineData >> width;
					_LineData >> height;
					_LineData >> filled;
					_LineData >> r;
					_LineData >> g;
					_LineData >> b;
					_LineData >> a;
					shared_ptr<GuiPanel> temp = make_shared<GuiPanel>(this);
					temp->Init(id, x, y, width, height, Color{ static_cast<unsigned char>(r), static_cast<unsigned char>(g), static_cast<unsigned char>(b), static_cast<unsigned char>(a) });
					m_GuiElementList[id] = temp;
				}
				break;

				case GUI_TEXTAREA:
				{
					int id, active, group, x, y, r, g, b, a;
					string initialtext;
					_LineData >> id;
					_LineData >> active;
					_LineData >> group;
					_LineData >> x;
					_LineData >> y;
					_LineData >> r;
					_LineData >> g;
					_LineData >> b;
					_LineData >> a;

					char _Buffer[256];
					_LineData.get(_Buffer, 255, '\n');
					initialtext = _Buffer;
					initialtext.erase(0, 1);

					shared_ptr<GuiTextArea> temp = make_shared<GuiTextArea>(this);
					temp->Init(id, m_Font.get(), initialtext, x, y, 0, 0, Color{ static_cast<unsigned char>(r), static_cast<unsigned char>(g), static_cast<unsigned char>(b), static_cast<unsigned char>(a) });
					m_GuiElementList[id] = temp;
				}
				break;
				}
			}
		}
	}
}

void Gui::HideGroup(int group)
{
	for (auto entry : m_GuiElementList)
	{
		if (entry.second->m_Group == group)
			entry.second->m_Visible = false;
	}
}

void Gui::ShowGroup(int group)
{
	for (auto entry : m_GuiElementList)
	{
		if (entry.second->m_Group == group)
			entry.second->m_Visible = true;
	}
}

bool Gui::IsMouseInDragArea() const
{
	Vector2 mousePos = GetMousePosition();
	float scaledX = mousePos.x / m_InputScale;
	float scaledY = mousePos.y / m_InputScale;
	return (scaledX >= m_Pos.x && scaledX <= m_Pos.x + m_Width &&
		scaledY >= m_Pos.y && scaledY <= m_Pos.y + m_DragAreaHeight);
}