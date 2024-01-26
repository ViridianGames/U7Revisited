#include "TooltipSystem.h"
#include "Globals.h"

using namespace std;

void DrawToolTip(Font* font, std::string strings, int x, int y, float linewidth, int anchorcorner, Color color)
{
	vector<ColoredString> temp;
	ColoredString* newstring = new ColoredString(strings, color);

	temp.push_back(*newstring);
	DrawToolTip(font, temp, x, y, linewidth, anchorcorner);
}

void DrawToolTip(Font* font, std::vector<ColoredString> strings, int x, int y, float linewidth, int anchorcorner)
{
	if (strings.empty())
		return;

	// Find out the legnth of the longest string in the list

	int xwidth = 0;

	for (std::size_t i = 0; i < strings.size(); ++i)
	{
		if (font->GetStringMetrics(strings[i].m_String) > xwidth)
			xwidth = font->GetStringMetrics(strings[i].m_String);
	}

	xwidth += 6;

	int yheight = int(font->GetHeight()) * int(strings.size()) * 1.3f;

	//  Draw the background

	switch (anchorcorner)
	{
	case 0: // Upper-left
	default:
	{
		int posy = y - 1;

		g_Display->DrawBox(x - 1, y - 1, xwidth + 2, yheight + 1, Color(0, 0, 0, .75f), true);

		for (vector<ColoredString>::iterator node = strings.begin(); node != strings.end(); ++node)
		{
			font->DrawString((*node).m_String.c_str(), x + 3, posy, (*node).m_Color);
			posy += font->GetHeight() * 1.2;
			//            posy += 12;
		}

		float linex = x - 1;
		float liney = y - 1;
		float linex2 = (x - 1) + (xwidth + 3);
		float liney2 = (y - 1) + (yheight + 1);

		g_Display->DrawLine(linex, liney, linex, liney2, linewidth);
		g_Display->DrawLine(linex, liney2, linex2, liney2, linewidth);
		g_Display->DrawLine(linex2, liney2, linex2, liney, linewidth);
		g_Display->DrawLine(linex2, liney, linex, liney, linewidth);
	}
	break;

	case 1: //  Upper-right
	{
		int posy = y - 1;

		g_Display->DrawBox(x - xwidth - 1, y - 1, xwidth + 2, yheight + 1, Color(0, 0, 0, .75f), true);

		for (vector<ColoredString>::iterator node = strings.begin(); node != strings.end(); ++node)
		{
			font->DrawString((*node).m_String.c_str(), x + 3 - xwidth, posy, (*node).m_Color);
			posy += font->GetHeight() * 1.2;
			//            posy += 12;
		}

		float linex = x - xwidth - 1;
		float liney = y - 1;
		float linex2 = (x - xwidth - 1) + (xwidth + 3);
		float liney2 = (y - 1) + (yheight + 1);

		g_Display->DrawLine(linex, liney, linex, liney2, linewidth);
		g_Display->DrawLine(linex, liney2, linex2, liney2, linewidth);
		g_Display->DrawLine(linex2, liney2, linex2, liney, linewidth);
		g_Display->DrawLine(linex2, liney, linex, liney, linewidth);
	}
	break;

	case 2: // Lower-right
	{
		int posy = y - yheight - 1;

		g_Display->DrawBox(x - xwidth - 1, y - yheight - 1, xwidth + 2, yheight + 1, Color(0, 0, 0, .75f), true);

		for (vector<ColoredString>::iterator node = strings.begin(); node != strings.end(); ++node)
		{
			font->DrawString((*node).m_String.c_str(), x + 3 - xwidth, posy, (*node).m_Color);
			posy += font->GetHeight() * 1.2;
			//            posy += 12;
		}

		float linex = x - xwidth - 1;
		float liney = y - yheight - 1;
		float linex2 = (x - xwidth - 1) + (xwidth + 3);
		float liney2 = (y - yheight - 1) + (yheight + 1);

		g_Display->DrawLine(linex, liney, linex, liney2, linewidth);
		g_Display->DrawLine(linex, liney2, linex2, liney2, linewidth);
		g_Display->DrawLine(linex2, liney2, linex2, liney, linewidth);
		g_Display->DrawLine(linex2, liney, linex, liney, linewidth);
	}

	break;

	case 3: //  Lower-left
	{
		int posy = y - yheight - 1;

		g_Display->DrawBox(x - 1, y - yheight - 1, xwidth + 2, yheight + 1, Color(0, 0, 0, .75f), true);

		for (vector<ColoredString>::iterator node = strings.begin(); node != strings.end(); ++node)
		{
			font->DrawString((*node).m_String.c_str(), x + 3, posy, (*node).m_Color);
			posy += font->GetHeight() * 1.2;
			//            posy += 12;
		}

		float linex = x - 1;
		float liney = y - yheight - 1;
		float linex2 = (x - 1) + (xwidth + 3);
		float liney2 = (y - yheight - 1) + (yheight + 1);

		g_Display->DrawLine(linex, liney, linex, liney2, linewidth);
		g_Display->DrawLine(linex, liney2, linex2, liney2, linewidth);
		g_Display->DrawLine(linex2, liney2, linex2, liney, linewidth);
		g_Display->DrawLine(linex2, liney, linex, liney, linewidth);
	}
	break;
	}


}
