#include "TooltipSystem.h"
#include "Globals.h"

using namespace std;

void DrawToolTip(Font* font, float size, std::string strings, int x, int y, float linewidth, int anchorcorner, Color color)
{
	vector<ColoredString> temp;
	ColoredString* newstring = new ColoredString(strings, color);

	temp.push_back(*newstring);
	DrawToolTip(font, size, temp, x, y, linewidth, anchorcorner);
}

void DrawToolTip(Font* font, float size, std::vector<ColoredString> strings, int x, int y, float linewidth, int anchorcorner)
{
	if (strings.empty())
		return;

	// Find out the legnth of the longest string in the list

	int xwidth = 0;

	for (std::size_t i = 0; i < strings.size(); ++i)
	{
		if (MeasureTextEx(*font, strings[i].m_String.c_str(), size, 1).x > xwidth)
			xwidth = MeasureTextEx(*font, strings[i].m_String.c_str(), size, 1).x;
	}

	xwidth += 6;

	int yheight = size * int(strings.size()) * 1.3f;

	//  Draw the background

	switch (anchorcorner)
	{
	case 0: // Upper-left
	default:
	{
		int posy = y - 1;

		DrawRectangle(x - 1, y - 1, xwidth + 2, yheight + 1, Color{0, 0, 0, 255});
		DrawRectangleLines(x - 1, y - 1, xwidth + 2, yheight + 1, Color{ 0, 0, 0, 192 });

		for (vector<ColoredString>::iterator node = strings.begin(); node != strings.end(); ++node)
		{
			DrawTextEx(*font, (*node).m_String.c_str(), Vector2{ (float)x + 3, (float)posy }, size, 1, (*node).m_Color);
			posy += size;
			//            posy += 12;
		}

		float linex = x - 1;
		float liney = y - 1;
		float linex2 = (x - 1) + (xwidth + 3);
		float liney2 = (y - 1) + (yheight + 1);

		DrawLineEx(Vector2{ linex, liney }, Vector2{ linex, liney2 }, linewidth, Color{255, 255, 255, 255});
		DrawLineEx(Vector2{ linex, liney2 }, Vector2{ linex2, liney2 }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex2, liney2 }, Vector2{ linex2, liney }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex2, liney }, Vector2{ linex, liney }, linewidth, Color{ 255, 255, 255, 255 });
	}
	break;

	case 1: //  Upper-right
	{
		int posy = y - 1;

		DrawRectangle(x - xwidth - 1, y - 1, xwidth + 2, yheight + 1, Color{ 0, 0, 0, 192 });

		for (vector<ColoredString>::iterator node = strings.begin(); node != strings.end(); ++node)
		{
			DrawTextEx(*font, (*node).m_String.c_str(), Vector2{ (float)x + 3 - xwidth, (float)posy }, size, 1, (*node).m_Color);
			posy += size * 1.2;
		}

		float linex = x - xwidth - 1;
		float liney = y - 1;
		float linex2 = (x - xwidth - 1) + (xwidth + 3);
		float liney2 = (y - 1) + (yheight + 1);

		DrawLineEx(Vector2{ linex, liney }, Vector2{ linex, liney2 }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex, liney2 }, Vector2{ linex2, liney2 }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex2, liney2 }, Vector2{ linex2, liney }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex2, liney }, Vector2{ linex, liney }, linewidth, Color{ 255, 255, 255, 255 });
	}
	break;

	case 2: // Lower-right
	{
		int posy = y - yheight - 1;

		DrawRectangle(x - xwidth - 1, y - 1, xwidth + 2, yheight + 1, Color{ 0, 0, 0, 192 });

		for (vector<ColoredString>::iterator node = strings.begin(); node != strings.end(); ++node)
		{
			DrawTextEx(*font, (*node).m_String.c_str(), Vector2{ (float)x + 3 - xwidth, (float)posy }, size, 1, (*node).m_Color);
			posy += size * 1.2;
		}

		float linex = x - xwidth - 1;
		float liney = y - yheight - 1;
		float linex2 = (x - xwidth - 1) + (xwidth + 3);
		float liney2 = (y - yheight - 1) + (yheight + 1);

		DrawLineEx(Vector2{ linex, liney }, Vector2{ linex, liney2 }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex, liney2 }, Vector2{ linex2, liney2 }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex2, liney2 }, Vector2{ linex2, liney }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex2, liney }, Vector2{ linex, liney }, linewidth, Color{ 255, 255, 255, 255 });
	}

	break;

	case 3: //  Lower-left
	{
		int posy = y - yheight - 1;

		DrawRectangle(x - 1, y - yheight - 1, xwidth + 2, yheight + 1, Color{ 0, 0, 0, 192 });

		for (vector<ColoredString>::iterator node = strings.begin(); node != strings.end(); ++node)
		{
			DrawTextEx(*font, (*node).m_String.c_str(), Vector2{ (float)x + 3, (float)posy }, size, 1, (*node).m_Color);
			posy += size * 1.2;
		}

		float linex = x - 1;
		float liney = y - yheight - 1;
		float linex2 = (x - 1) + (xwidth + 3);
		float liney2 = (y - yheight - 1) + (yheight + 1);

		DrawLineEx(Vector2{ linex, liney }, Vector2{ linex, liney2 }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex, liney2 }, Vector2{ linex2, liney2 }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex2, liney2 }, Vector2{ linex2, liney }, linewidth, Color{ 255, 255, 255, 255 });
		DrawLineEx(Vector2{ linex2, liney }, Vector2{ linex, liney }, linewidth, Color{ 255, 255, 255, 255 });
	}
	break;
	}


}
