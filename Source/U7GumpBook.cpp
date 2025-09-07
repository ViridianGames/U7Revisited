#include <fstream>
#include <string>
#include <algorithm>

#include "U7Gump.h"
#include "U7GumpBook.h"
#include "Geist/Config.h"
#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"

#include "raylib.h"
#include "../ThirdParty/raylib/include/raylib.h"

using namespace std;

GumpBook::GumpBook()
{

}

GumpBook::~GumpBook()
{
}

void GumpBook::OnEnter()
{

}

void GumpBook::Setup(const int book_type, const std::vector<std::string>& text)
{
	m_gui.m_PositionFlag = Gui::GUIP_USE_XY;
	m_gui.m_Width = 0;
	m_gui.m_Height = 0;
	m_gui.m_Active = 1;
	m_gui.m_Editing = false;
	m_gui.m_ActiveElement = -1;
	m_gui.m_LastElement = -2;
	m_gui.m_InputScale = 1;
	m_gui.m_Draggable = false;  // Dragging is off by default
	m_gui.m_IsDragging = false;
	m_gui.m_DragOffset = { 0, 0 };
	m_gui.m_DragAreaHeight = 20;  // Default title bar height
	m_gui.m_isDone = false;
	m_IsDead = false;
	m_gui.m_doneButtonId = -3;
	m_bookType = book_type;
	m_gui.m_Font = g_SmallFont;
	m_gui.SetLayout(0, 0, 640, 360, g_DrawScale, Gui::GUIP_USE_XY);

	int bookx = int((580 - m_bookData[m_bookType].m_textureSize.x) / 2);
	int booky = int((360 - m_bookData[m_bookType].m_textureSize.y) / 2);
	int textx = bookx + m_bookData[m_bookType].m_boxOffset.x;
	int texty = booky + m_bookData[m_bookType].m_boxOffset.y;

	m_bookPages.clear();
	string thisPage = "";
	switch (m_bookType)
	{
	case int(BookType::BOOK_BOOK):
		{
			for (int i = 0; i < (int)text.size(); i++)
			{
				if (text[i] == " ")
					thisPage += '\n';
				else
					thisPage.append(text[i]);

				if (thisPage.back() == '*')
				{
					thisPage.pop_back();
					m_bookPages.push_back(thisPage);
					thisPage = "";
				}
				else if (i == (int)text.size() - 1)
				{
					m_bookPages.push_back(thisPage);
					thisPage = "";
				}
			}
		}
		break;

	case int(BookType::BOOK_WOODEN_SIGN):
		{
			//  Signs have text backwards for some reason
			for (auto thistext = text.rbegin(); thistext != text.rend(); ++thistext)
			{
				thisPage.append(*thistext);
				thisPage.append("\n");
			}
			m_bookPages.push_back(thisPage);
			thisPage = "";
		}
		break;

	case int(BookType::BOOK_SCROLL):
		{
			//  Signs have text backwards for some reason
			for (auto thistext = text.begin(); thistext != text.end(); ++thistext)
			{
				std::string formatted = *thistext;
				std::replace(formatted.begin(), formatted.end(), '~', '\n');

				m_bookPages.push_back(formatted);
			}
			thisPage = "";
		}
		break;
	}

	//m_gui.AddTextArea(1009, g_SmallFont.get(),  "", textx, texty, 0, g_SmallFont.get()->baseSize, BLACK);

	//m_gui.GetElement(1009)->m_String = text[0];
}

void GumpBook::Update()
{
	if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT))
	{
		m_bookPages.erase(m_bookPages.begin());
		//  Books have two pages, unlike every other book type
		if (m_bookData[m_bookType].m_bookType == BookType::BOOK_BOOK && !m_bookPages.empty())
		{
			m_bookPages.erase(m_bookPages.begin());
		}

		if (m_bookPages.empty())
		{
			m_IsDead = true;
		}
	}
}

void GumpBook::Draw()
{
	//m_gui.Draw();

	int bookx = int((580 - m_bookData[m_bookType].m_textureSize.x) / 2);
	int booky = int((360 - m_bookData[m_bookType].m_textureSize.y) / 2);
	int textx = bookx + m_bookData[m_bookType].m_boxOffset.x;
	int texty = booky + m_bookData[m_bookType].m_boxOffset.y;

	DrawTextureRec(*g_ResourceManager->GetTexture("Images/GUI/biggumps.png"),
	{m_bookData[m_bookType].m_texturePos.x, m_bookData[m_bookType].m_texturePos.y, m_bookData[m_bookType].m_textureSize.x, m_bookData[m_bookType].m_textureSize.y},
	{ bookx, booky}, 	Color{255, 255, 255, 255});

	switch (m_bookType)
	{
		case int(BookType::BOOK_BOOK):
			{
				DrawParagraph(g_SmallFont, m_bookPages[0], {textx, 90}, 175,
			  g_SmallFont->baseSize, 1, BLACK, false);

				if (m_bookData[m_bookType].m_bookType == BookType::BOOK_BOOK && m_bookPages.size() > 1)
				{
					DrawParagraph(g_SmallFont, m_bookPages[1], {textx + 210, 90}, 175,
									  g_SmallFont->baseSize, 1, BLACK, false);
				}
			}
		break;

		case int(BookType::BOOK_WOODEN_SIGN):
			{
				DrawParagraph(g_ConversationFont, m_bookPages[0], {textx, 90}, 150,
			  g_ConversationFont->baseSize, 1, WHITE, false);
			}
		break;

		case int(BookType::BOOK_SCROLL):
		{
			DrawParagraph(g_SmallFont, m_bookPages[0], {textx, 90}, 210,
		  g_SmallFont->baseSize, 1, BLACK, false);
		}
		break;
	}

}