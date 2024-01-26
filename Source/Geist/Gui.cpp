#include "Globals.h"
#include <fstream>
#include <string>
#include <sstream>
#include "tinyxml2.h"

using namespace std;

Gui::Gui()
{
	m_PositionFlag = GUIP_USEXY;
	m_OriginalX = 0;
	m_OriginalY = 0;
	m_GuiX = 0;
	m_GuiY = 0;
	m_Width = 0;
	m_Height = 0;
	m_Active = 1;
	m_Editing = false;
	m_ActiveElement = -1;
	m_LastElement = -2;
	m_Scale = 1;
}

std::shared_ptr<GuiElement> Gui::GetActiveElement()
{
	if (m_ActiveElement != -1 && m_GuiList.find(m_ActiveElement) != m_GuiList.end())
		return m_GuiList[m_ActiveElement];
	else
		return nullptr;
}

void Gui::Init(const std::string& configfile)
{
	LoadTXT(configfile);
}

void Gui::Update()
{
	if (!m_Active)
		return;
	//  Relocate the GUI on an update basis so that if the window shrinks or
	//  grows at any time the GUI is appropriately located.
	m_Width = int(m_Scale * m_OriginalWidth);
	m_Height = int(m_Scale * m_OriginalHeight);

	switch (m_PositionFlag)
	{
	case GUIP_USEXY:
		m_GuiX = int(m_Pos.X);
		m_GuiY = int(m_Pos.Y);
		break;

	case GUIP_UPPERLEFT:
		m_GuiX = 0;
		m_GuiY = 0;
		break;

	case GUIP_UPPERRIGHT:
		m_GuiX = g_Display->GetWidth() - m_Width;
		m_GuiY = 0;
		break;

	case GUIP_LOWERLEFT:
		m_GuiX = 0;
		m_GuiY = g_Display->GetHeight() - m_Height;
		break;

	case GUIP_LOWERRIGHT:
		m_GuiX = g_Display->GetWidth() - m_Width;
		m_GuiY = g_Display->GetHeight() - m_Height;
		break;

	case GUIP_FLOATLEFT:
		m_GuiX = 0;
		m_GuiY = (g_Display->GetHeight() - m_Height) / 2;
		break;

	case GUIP_FLOATRIGHT:
		m_GuiX = g_Display->GetWidth() - m_Width;
		m_GuiY = (g_Display->GetHeight() - m_Height) / 2;
		break;

	case GUIP_FLOATTOP:
		m_GuiX = (g_Display->GetWidth() - m_Width) / 2;
		m_GuiY = 0;
		break;

	case GUIP_FLOATBOTTOM:
		m_GuiX = (g_Display->GetWidth() - m_Width) / 2;
		m_GuiY = g_Display->GetHeight() - m_Height;
		break;

	case GUIP_CENTER:
		m_GuiX = (g_Display->GetWidth() - m_Width) / 2;
		m_GuiY = (g_Display->GetHeight() - m_Height) / 2;
		break;

	}

	m_LastElement = m_ActiveElement;
	m_ActiveElement = -1;
	for (auto& node : m_GuiList)
	{
		node.second->Update();
	}
}

void Gui::Draw()
{
	if (!m_Active)
		return;

	for (auto& node : m_GuiList)
	{
		node.second->Draw();
	}
}

void Gui::SetLayout(int x, int y, int width, int height, int flag)
{
	m_OriginalX = x;
	m_GuiX = x;
	m_OriginalY = y;
	m_GuiY = y;
	m_OriginalWidth = width;
	m_Width = width;
	m_OriginalHeight = height;
	m_Height = height;
	m_PositionFlag = flag;
}

shared_ptr<GuiElement> Gui::GetElement(int ID)
{
	if (m_GuiList.find(ID) == m_GuiList.end())
		return nullptr;
	else
		return m_GuiList[ID];
}

void Gui::AddTextButton(int ID, int posx, int posy, int width, int height, std::string text, Font* font,
	Color textcolor, Color backgroundcolor,
	Color bordercolor, int group, int active)
{
	shared_ptr<GuiTextButton> textbutton = make_shared<GuiTextButton>(this);
	textbutton->Init(ID, posx, posy, width, height, text, font, textcolor, backgroundcolor, bordercolor,
		group, active);
	m_GuiList[ID] = textbutton;

}

void Gui::AddTextButton(int ID, int posx, int posy, std::string text, Font* font,
	Color textcolor, Color backgroundcolor,
	Color bordercolor, int group, int active)
{
	shared_ptr<GuiTextButton> textbutton = make_shared<GuiTextButton>(this);
	textbutton->Init(ID, posx, posy, int(font->GetStringMetrics(text)) + 4, int(font->GetHeight()) + 4, text, font, textcolor, backgroundcolor, bordercolor,
		group, active);
	m_GuiList[ID] = textbutton;
}

void Gui::AddIconButton(int ID, int posx, int posy, shared_ptr<Sprite> upbutton, shared_ptr<Sprite> downbutton,
	shared_ptr<Sprite> inactivebutton, std::string text, Font* font,
	Color fontcolor, int group, int active)
{
	shared_ptr<GuiIconButton> iconbutton = make_shared<GuiIconButton>(this);
	iconbutton->Init(ID, posx, posy, upbutton, downbutton, inactivebutton, text, font, fontcolor, group, active);
	m_GuiList[ID] = iconbutton;

}

//  For making a button whose graphics are all on the same texture in standard 2x2 format.
void Gui::AddIconButton(int ID, Texture* tex, int posx, int posy, int tilex, int tiley, int width, int height, std::string text, Font* font, Color fontcolor, int group, int active)
{
	shared_ptr<Sprite> upbutton = make_shared<Sprite>(tex, tilex, tiley, width, height);
	shared_ptr<Sprite> downbutton = make_shared<Sprite>(tex, tilex, tiley + height, width, height);
	shared_ptr<Sprite> inactivebutton = make_shared<Sprite>(tex, tilex + width, tiley + height, width, height);

	shared_ptr<GuiIconButton> iconbutton = make_shared<GuiIconButton>(this);
	iconbutton->Init(ID, posx, posy, upbutton, downbutton, inactivebutton, text, font, fontcolor, group, active);
	m_GuiList[ID] = iconbutton;
}

void Gui::AddCheckBox(int ID, int posx, int posy, std::shared_ptr<Sprite> Unselected, std::shared_ptr<Sprite> Selected, std::shared_ptr<Sprite> Hovered, std::shared_ptr<Sprite> HoveredSelected,
	float scalex, float scaley, Color color, int group, int active)
{
	shared_ptr<GuiCheckBox> checkbox = make_shared<GuiCheckBox>(this);
	checkbox->Init(ID, posx, posy, Unselected, Selected, Hovered, HoveredSelected, scalex, scaley, color, group, active);
	m_GuiList[ID] = (checkbox);
}

void Gui::AddCheckBox(int ID, int posx, int posy, int width, int height,
	float scalex, float scaley, Color color, int group, int active)
{
	shared_ptr<GuiCheckBox> checkbox = make_shared<GuiCheckBox>(this);
	checkbox->Init(ID, posx, posy, width, height, scalex, scaley, color, group, active);
	m_GuiList[ID] = (checkbox);
}

void Gui::AddRadioButton(int ID, int posx, int posy, std::shared_ptr<Sprite> Selected, std::shared_ptr<Sprite> Unselected, std::shared_ptr<Sprite> Hovered,
	float scalex, float scaley, Color color, int group, int active, bool shadowed)
{
	shared_ptr<GuiRadioButton> radioButton = make_shared<GuiRadioButton>(this);
	radioButton->Init(ID, posx, posy, Selected, Unselected, Hovered, scalex, scaley, color, group, active, shadowed);
	m_GuiList[ID] = (radioButton);
}

void Gui::AddRadioButton(int ID, int posx, int posy, int width, int height,
	float scalex, float scaley, Color color, int group, int active, bool shadowed)
{
	shared_ptr<GuiRadioButton> radioButton = make_shared<GuiRadioButton>(this);
	radioButton->Init(ID, posx, posy, width, height, scalex, scaley, color, group, active, shadowed);
	m_GuiList[ID] = (radioButton);
}

void Gui::AddScrollBar(int ID, int valuerange, int posx, int posy, int width, int height, bool vertical,
	Color spurcolor, Color backgroundcolor, int group, int active, bool shadowed)
{
	shared_ptr<GuiScrollBar> scrollbar = make_shared<GuiScrollBar>(this);
	scrollbar->Init(ID, valuerange, posx, posy, width, height, vertical, spurcolor, backgroundcolor, group, active, shadowed);
	m_GuiList[ID] = (scrollbar);

}

void Gui::AddScrollBar(int ID, int valuerange, int posx, int posy, int width, int height, bool vertical,
	shared_ptr<Sprite> activeLeft, shared_ptr<Sprite> activeCenter, shared_ptr<Sprite> activeRight, shared_ptr<Sprite> spurActive,
	shared_ptr<Sprite> inactiveLeft, shared_ptr<Sprite> inactiveCenter, shared_ptr<Sprite> inactiveRight, shared_ptr<Sprite> spurInactive,
	int group, int active, bool shadowed)
{
	shared_ptr<GuiScrollBar> scrollbar = make_shared<GuiScrollBar>(this);
	scrollbar->Init(ID, valuerange, posx, posy, width, height, vertical,
		activeLeft, activeRight, activeCenter, spurActive,
		inactiveLeft, inactiveRight, inactiveCenter, spurInactive,
		group, active, shadowed);
	m_GuiList[ID] = (scrollbar);
}

void Gui::AddTextInput(int ID, int posx, int posy, int width, int height,
	Font* font, std::string initialtext, Color textcolor, Color boxcolor,
	Color backgroundcolor, int group, int active)
{
	shared_ptr<GuiTextInput> textinput = make_shared<GuiTextInput>(this);
	textinput->Init(ID, posx, posy, width, height, font, initialtext, textcolor,
		boxcolor, backgroundcolor, group, active);
	m_GuiList[ID] = (textinput);

}

void Gui::AddPanel(int ID, int posx, int posy, int width, int height,
	Color color, bool filled, int group, int active)
{
	shared_ptr<GuiPanel> panel = make_shared<GuiPanel>(this);
	panel->Init(ID, posx, posy, width, height, color, filled, group, active);
	m_GuiList[ID] = (panel);
}

void Gui::AddTextArea(int ID, Font* font, std::string text, int posx, int posy, int width, int height,
	Color color, int justified, int group, int active, bool shadowed)
{
	shared_ptr<GuiTextArea> area = make_shared<GuiTextArea>(this);
	area->Init(ID, font, text, posx, posy, width, height, color, justified, group, active, shadowed);
	m_GuiList[ID] = (area);
}

shared_ptr<GuiSprite> Gui::AddSprite(int ID, int posx, int posy, std::shared_ptr<Sprite> sprite, float scalex, float scaley,
	Color color, int group, int active)
{
	shared_ptr<GuiSprite> guiSprite = make_shared<GuiSprite>(this);
	guiSprite->Init(ID, posx, posy, sprite, scalex, scaley, color, group, active);
	m_GuiList[ID] = (guiSprite);
	return guiSprite;
}

void Gui::AddOctagonBox(int ID, int posx, int posy, int width, int height, std::vector<std::shared_ptr<Sprite> > borders,
	Color color, int group, int active)
{
	shared_ptr<GuiOctagonBox> guiOctagonBox = make_shared<GuiOctagonBox>(this);
	guiOctagonBox->Init(ID, posx, posy, width, height, borders, color, group, active);
	m_GuiList[ID] = guiOctagonBox;
}

void Gui::AddStretchButton(int ID, int posx, int posy, int width, string label,
	std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> activeCenter,
	std::shared_ptr<Sprite> inactiveLeft, std::shared_ptr<Sprite> inactiveRight, std::shared_ptr<Sprite> inactiveCenter, int indent,
	Color color, int group, int active, bool shadowed)
{
	shared_ptr<GuiStretchButton> guiStretchButton = make_shared<GuiStretchButton>(this);
	guiStretchButton->Init(ID, posx, posy, width, label, activeLeft, activeRight, activeCenter, inactiveLeft, inactiveRight, inactiveCenter, indent, color, group, active, shadowed);
	m_GuiList[ID] = guiStretchButton;
}

std::string Gui::GetString(int ID)
{
	if (m_GuiList.find(ID) == m_GuiList.end())
		return "";

	return m_GuiList[ID]->GetString();
}

//  A file that defines a gui starts with the filename for the buttons for
//  this GUI.  Then each line after that defines a single button.  Example:
//
//  images\\combat.tga
//  ID Active TileX TileY PosX PosY Width Height;

void Gui::LoadTXT(std::string fileName)
{
	ifstream instream(fileName.c_str(), ios::in | ios::binary);
	if (!instream.fail())  //  Open successful!
	{

		string line;


		stringstream parser;
		instream >> m_GuiX;
		instream >> m_GuiY;

		m_Pos.X = m_GuiX;
		m_Pos.Y = m_GuiY;

		getline(instream, line);
		getline(instream, line);

		//#ifdef _WINDOWS
		//#else
		if (line.size() > 0)
		{
			if (line.at(line.size() - 1) == '\r')
			{
				line = line.substr(0, line.size() - 1);
			}
		}
		//#endif  


		m_Font = make_shared<Font>();
		m_Font->Init(line);

		while (!instream.eof())
		{
			getline(instream, line);

			//#ifdef _WINDOWS
			//#else
			if (line.size() > 0)
			{
				if (line.at(line.size() - 1) == '\r')
				{
					line = line.substr(0, line.size() - 1);
				}
			}
			//#endif  


			if (line[0] != '#') //  If this line is not a comment
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
					upbutton->m_Texture = g_ResourceManager->GetTexture(Texture);
					upbutton->m_PosX = tilex;
					upbutton->m_PosY = tiley;
					upbutton->m_Width = width;
					upbutton->m_Height = height;

					AddIconButton(buttonid, posx, posy, upbutton);
				}
				break;

				/*            case GUI_SCROLLBAR:
				{
				int buttonid, active, group, posx, posy, width, height, spurlocation, r, g, b, a;
				string Texture;
				_LineData >> buttonid;
				_LineData >> active;
				_LineData >> group;
				_LineData >> posx;
				_LineData >> posy;
				_LineData >> width;
				_LineData >> height;
				_LineData >> spurlocation;
				_LineData >> r;
				_LineData >> g;
				_LineData >> b;
				_LineData >> a;

				GuiScrollBar *temp = new GuiScrollBar(buttonid, active, group, posx, posy, width, height, spurlocation, r, g, b, a);
				m_GuiList.push_back(temp);
				}
				break;


				case GUI_TEXTINPUT:
				{
				int id, active, x, y, group, width, height, r, g, b, a;
				string initialtext;
				_LineData >> id;
				_LineData >> active;
				_LineData >> group;
				_LineData >> x;
				_LineData >> y;
				_LineData >> width;
				_LineData >> height;
				_LineData >> r;
				_LineData >> g;
				_LineData >> b;
				_LineData >> a;

				char _Buffer[256];
				_LineData.get(_Buffer, 255, '\n');
				initialtext = _Buffer;
				initialtext.erase(0, 1);  //  Kill the leading space.

				GuiTextArea *temp = new GuiTextArea(id, active, group, x, y, width, height, r, g, b, a, initialtext);
				m_GuiList.push_back(temp);
				}
				break;*/



				/*            case GUI_RADIOBUTTON:
				{
				int buttonid, active, group, tilex, tiley, posx, posy, width, height, radiobuttongroup, set;
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
				_LineData >> radiobuttongroup;
				_LineData >> set;

				char _Buffer[256];
				_LineData.get(_Buffer, 255, '\n');
				Texture = _Buffer;
				Texture.erase(0, 1);  //  Kill the leading space.

				GuiRadioButton *temp = new GuiRadioButton(buttonid, active, group, tilex, tiley, posx, posy, width, height, radiobuttongroup, set, Texture);
				m_GuiList.push_back(temp);
				}
				break;*/

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
					temp->Init(id, x, y, width, height, Color(float(r), float(g), float(b), float(a)));
					m_GuiList[id] = temp;
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
					initialtext.erase(0, 1);  //  Kill the leading space.

					shared_ptr<GuiTextArea> temp = make_shared<GuiTextArea>(this);
					temp->Init(id, m_Font.get(), initialtext, x, y, 0, 0, Color(float(r), float(g), float(b), float(a)));
					m_GuiList[id] = temp;
				}
				break;
				}
			}
		}
	}
}

void Gui::LoadXML(std::string fileName)
{
	tinyxml2::XMLDocument doc;
	tinyxml2::XMLError error = doc.LoadFile(fileName.c_str());
	if (doc.Error())
	{
		Log("Error loading GUI xml document: " + fileName);
		return;
	}

	tinyxml2::XMLElement* elem = doc.FirstChildElement()->FirstChildElement();

	string type = elem->Attribute("type");

	if (type == "PANEL")
	{
		int id = 0, posx = 0, posy = 0, width = 0, height = 0;
		Color color = Color(1, 1, 1, 1);
		bool filled = true;
		int group = 0;
		int active = 0;

		string holder;

		if (elem->Attribute("id"))
		{
			holder = elem->Attribute("id");
			id = stoi(holder);
		}

		if (elem->Attribute("posx"))
		{
			holder = elem->Attribute("posx");
			posx = stoi(holder);
		}

		if (elem->Attribute("posy"))
		{
			holder = elem->Attribute("posy");
			posy = stoi(holder);
		}

		if (elem->Attribute("width"))
		{
			holder = elem->Attribute("width");
			width = stoi(holder);
		}

		if (elem->Attribute("height"))
		{
			holder = elem->Attribute("height");
			height = stoi(holder);
		}

		if (elem->Attribute("r"))
		{
			holder = elem->Attribute("r");
			color.r = stof(holder);
		}

		if (elem->Attribute("g"))
		{
			holder = elem->Attribute("g");
			color.g = stof(holder);
		}

		if (elem->Attribute("b"))
		{
			holder = elem->Attribute("b");
			color.b = stof(holder);
		}

		if (elem->Attribute("a"))
		{
			holder = elem->Attribute("a");
			color.a = stof(holder);
		}

		if (elem->Attribute("filled"))
		{
			holder = elem->Attribute("filled");
			filled = (holder == "true");
		}

		if (elem->Attribute("group"))
		{
			holder = elem->Attribute("group");
			group = stoi(holder);
		}

		if (elem->Attribute("active"))
		{
			holder = elem->Attribute("active");
			active = stoi(holder);
		}

		AddPanel(id, posx, posy, width, height, color, filled, group, active);
	}
}

void Gui::HideGroup(int group)
{
	for (auto entry : m_GuiList)
	{
		if (entry.second->m_Group == group)
			entry.second->m_Visible = false;
	}
}

void Gui::ShowGroup(int group)
{
	for (auto entry : m_GuiList)
	{
		if (entry.second->m_Group == group)
			entry.second->m_Visible = true;
	}
}

