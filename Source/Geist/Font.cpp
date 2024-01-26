#define STB_TRUETYPE_IMPLEMENTATION
#include "Font.h"
#include "SDL.h"
#include "stb_image.h"
#include "ResourceManager.h"
#include "Globals.h"
#include <fstream>

using namespace std;

void Font::Init(const std::string& configfile)
{
	Init(configfile, 30.0f);
}

void Font::Init(const std::string& configfile, float height, bool log)
{
	Log("Creating font " + configfile + ", size " + to_string(height));
	int size = 1024;

	unsigned char* temp_bitmap = new unsigned char[size * size];
	unsigned char* temp_bitmap2 = new unsigned char[size * size * 4];
	unsigned char* ttf_buffer = new unsigned char[1 << 20];

	ifstream instream(configfile, ios::in | ios::binary);
	if (instream.fail())
	{
		throw ("Could not open " + configfile);
	}

	instream.read((char*)ttf_buffer, 1 << 20);

	//   fread(ttf_buffer, 1, 1 << 20, fopen(configfile.c_str(), "rb"));
	stbtt_BakeFontBitmap(ttf_buffer, 0, height, temp_bitmap, size, size, 32, 96, m_FontData);

	m_FontTexture = make_shared<Texture>();

	// Convert bitmap from 8-bit to 32-bit, this will allow color masking
	for (int i = 0; i < size * size; ++i)
	{
		temp_bitmap2[i * 4] = temp_bitmap[i];
		temp_bitmap2[i * 4 + 1] = temp_bitmap[i];
		temp_bitmap2[i * 4 + 2] = temp_bitmap[i];
		temp_bitmap2[i * 4 + 3] = temp_bitmap[i];
	}

	m_FontTexture->Create(size, size, false);
	memcpy(m_FontTexture->GetPixelData(), temp_bitmap2, sizeof(unsigned int) * size * size);
	m_FontTexture->UpdateData();
	m_FontHeight = height;

	delete[] temp_bitmap;
	delete[] temp_bitmap2;
	delete[] ttf_buffer;

	if (log)
	{
		for (int i = 0; i < 95; ++i)
		{
			stbtt_bakedchar* b = m_FontData + i;

			float width = float(b->x1 - b->x0);
			float height = float(b->y1 - b->y0);

			Log("Char: " + std::string(1, char(i + 32)) + " Width: " + to_string(width) + " Height: " + to_string(height));
		}
	}

	m_IconTexture = g_ResourceManager->GetTexture("Images/gamepad_buttons.png");
	Log("Done creating font " + configfile);
}

//  This function returns the length in pixels of the string if it had been
//  printed.  It does not actually print anything.  Useful for writing
//  word-wrapping functions.
int Font::GetStringMetrics(std::string texttodraw, float scale)
{
	int _finalWidth = 0;
	int longestWid = 0;
	for (int i = 0; i < (int)texttodraw.length(); ++i)
	{
		if (texttodraw[i] >= 32 && texttodraw[i] < 128)
		{
			stbtt_bakedchar* b = m_FontData + (texttodraw[i] - 32);

			_finalWidth += int(b->xadvance) * scale;
		}
		else if (texttodraw[i] == (char)176)
		{
			_finalWidth += int(m_FontHeight);
			i++;	// consume the next character, it will be drawn inside this one
		}
		else if (texttodraw[i] == char(13))
		{
			if (_finalWidth > longestWid)
				longestWid = _finalWidth;
			_finalWidth = 0;
		}
		else if (texttodraw[i] == SC_CURSOR || texttodraw[i] == SC_CURSORRANDOM)
		{
			_finalWidth += int(m_FontHeight / 2 + 1);
		}
		else
			_finalWidth += int(m_FontHeight);	// all images get stretched to the height of the font in width
	}
	_finalWidth -= 2 * scale; //  Remove the after-character space from the last character.
	if (_finalWidth > longestWid)
		longestWid = _finalWidth;
	return longestWid;
}

int Font::FitStringInLength(std::string texttodraw, int length)
{
	if (texttodraw.length() == 0)
		return 0;
	int i = 0;
	for (i; i <= (int)texttodraw.length(); ++i)
	{
		if (GetStringMetrics(texttodraw.substr(0, i)) > length)
		{
			break;
		}
	}
	return i - 1;
}

void Font::DrawString(std::string texttodraw, int posX, int posY, Color color, float scale)
{
	float iconYOffset = ((m_FontData + 1)->yoff + m_FontHeight) * .25f;
	float startX = posX;

	for (int i = 0; i < (int)texttodraw.length(); ++i)
	{
		if (texttodraw[i] >= 32 && texttodraw[i] < 128)
		{
			//  Normal, batchable text.
			stbtt_bakedchar* b = m_FontData + (texttodraw[i] - 32);

			float width = float(b->x1 - b->x0);
			float height = float(b->y1 - b->y0);

			g_Display->DrawFontText(m_FontTexture.get(),
				b->x0, b->y0, // Source X and Y
				int(width), int(height), // Source width and height
				int(posX + b->xoff), int(posY + b->yoff + m_FontHeight),  //  Dest X and Y
				int(width), int(height),
				color);

			posX += int(b->xadvance);
		}
		else if (texttodraw[i] == char(13))	// carriage return
		{
			posX = startX;
			posY += GetHeight();
		}
		else if (texttodraw[i] == SC_KEY_OUTLINE) // a keyboard key. Tricky because we need to squeeze a letter into it
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 32, 32, 16, 16, posX, posY + int(iconYOffset), int(m_FontHeight), int(m_FontHeight), color);
			i++;	// skip to the next character, it's the one to print in here
			stbtt_bakedchar* b = m_FontData + (texttodraw[i] - 32);

			float width = float(b->x1 - b->x0);
			float height = float(b->y1 - b->y0);

			float outwidth, outheight;
			if (width > height)	// we want it to fill the space on its bigger axis, but maintain its aspect ratio
			{
				outwidth = m_FontHeight * 0.8f;
				outheight = outwidth * (height / width);
			}
			else
			{
				outheight = m_FontHeight * 0.8f;
				outwidth = outheight * (width / height);
			}
			g_Display->DrawImage(m_FontTexture.get(),
				b->x0, b->y0, // Source X and Y
				int(width), int(height), // Source width and height
				int(posX + m_FontHeight / 2 - outwidth / 2), int(posY + m_FontHeight + b->yoff * (outheight / height)),  //  Dest X and Y is centered in the square
				int(outwidth), int(outheight),
				color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_CURSOR) // white square, half-width (a cursor)
		{
			g_Display->DrawBox(posX, posY + int(iconYOffset), m_FontHeight / 2, m_FontHeight, color, true);
			posX += int(m_FontHeight / 2 + 1);
		}
		else if (texttodraw[i] == SC_CURSORRANDOM) // randomized white square, half-width (a cursor)
		{
			int start = rand() % (int)(m_FontHeight / 2 + 1);
			int height = rand() % (int)(m_FontHeight - start + 1);

			g_Display->DrawBox(posX, posY + int(iconYOffset) + start, m_FontHeight / 2, height, color, true);
			posX += int(m_FontHeight / 2 + 1);
		}
		else if (texttodraw[i] == SC_MONEY_SYMBOL) // $ symbol, animating!
		{
			int frame = (g_Engine->GameTimeInMS() / 66) % 4;
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), frame * 8, 32, 8, 9, posX, posY + int(iconYOffset), int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}

		else if (texttodraw[i] == SC_DPAD_UP) // Dpad-up character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 48, 16, 16, 16, posX, posY + int(iconYOffset), int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_DPAD_DOWN) // Dpad-down character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 16, 16, 16, 16, posX, posY + int(iconYOffset), int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_DPAD_LEFT) // Dpad-left character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 32, 16, 16, 16, posX, posY + int(iconYOffset), int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_DPAD_RIGHT) // Dpad-right character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 0, 16, 16, 16, posX, posY + int(iconYOffset), int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}

		else if (texttodraw[i] == SC_A_BUTTON) // A-button character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 0, 0, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_B_BUTTON) // B-button character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 16, 0, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_X_BUTTON) // X-button character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 32, 0, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_Y_BUTTON) // Y-button character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 48, 0, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}

		else if (texttodraw[i] == SC_L_TRIGGER) // Left Trigger character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 64, 16, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_R_TRIGGER) // Right Trigger character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 80, 16, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_L_BUMPER) // Left bumper character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 64, 0, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_R_BUMPER) // Right bumper character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 80, 0, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_L3_BUTTON) // L3 character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 96, 0, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_R3_BUTTON) // R3 character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 112, 0, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}

		else if (texttodraw[i] == SC_SELECT_BUTTON) // Select Button
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 96, 16, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}
		else if (texttodraw[i] == SC_START_BUTTON) // Start character
		{
			g_Display->DrawImage(g_ResourceManager->GetTexture("Images/gamepad_buttons.png"), 112, 16, 16, 16, posX, posY + int(iconYOffset) + 2, int(m_FontHeight), int(m_FontHeight), color);
			posX += int(m_FontHeight);
		}

	}
}

void Font::DrawParagraphRight(std::string texttodraw, int posX, int posY, int width, int height, Color color, float scale)
{
	vector<string> paragraphs = SplitStringsOnCarriageReturn(texttodraw);
	vector<string> finalstrings;
	for (unsigned int i = 0; i < paragraphs.size(); i++)
	{
		vector<string> temp = SplitStrings(paragraphs[i], width, scale);
		finalstrings.insert(finalstrings.end(), temp.begin(), temp.end());
	}

	for (unsigned int i = 0; i < finalstrings.size(); ++i)
	{
		DrawStringRight(finalstrings[i], posX, posY + i * height, color, scale);
	}
}

int Font::DrawParagraph(std::string texttodraw, int posX, int posY, int width, int height, Color color, float scale)
{
	vector<string> paragraphs = SplitStringsOnCarriageReturn(texttodraw);
	vector<string> finalstrings;
	for (unsigned int i = 0; i < paragraphs.size(); i++)
	{
		vector<string> temp = SplitStrings(paragraphs[i], width, scale);
		finalstrings.insert(finalstrings.end(), temp.begin(), temp.end());
	}

	for (unsigned int i = 0; i < finalstrings.size(); ++i)
	{
		DrawString(finalstrings[i], posX, posY + i * height, color, scale);
	}

	return (int)finalstrings.size(); // Return how many lines we drew.
}

int Font::GetStringMetricsHeight(std::string texttodraw, int width, float scale)
{
	vector<string> paragraphs = SplitStringsOnCarriageReturn(texttodraw);
	vector<string> finalstrings;
	for (unsigned int i = 0; i < paragraphs.size(); i++)
	{
		vector<string> temp = SplitStrings(paragraphs[i], width, scale);
		finalstrings.insert(finalstrings.end(), temp.begin(), temp.end());
	}

	return m_FontHeight * finalstrings.size();
}

void Font::DrawParagraphCentered(std::string texttodraw, int posX, int posY, int width, int height, Color color, float scale)
{
	vector<string> paragraphs = SplitStringsOnCarriageReturn(texttodraw);
	vector<string> finalstrings;
	for (unsigned int i = 0; i < paragraphs.size(); i++)
	{
		vector<string> temp = SplitStrings(paragraphs[i], width, scale);
		finalstrings.insert(finalstrings.end(), temp.begin(), temp.end());
	}
	for (unsigned int i = 0; i < finalstrings.size(); ++i)
	{
		DrawStringCentered(finalstrings[i], posX, posY + i * height, color, scale);
	}
}

void Font::DrawStringCentered(std::string texttodraw, int posX, int posY, Color color, float scale)
{
	int textlength = GetStringMetrics(texttodraw);
	posX -= (textlength / 2);

	DrawString(texttodraw, posX, posY, color, scale);
}

void Font::DrawStringRight(std::string texttodraw, int posX, int posY, Color color, float scale)
{
	int textlength = GetStringMetrics(texttodraw);
	posX -= (textlength);

	DrawString(texttodraw, posX, posY, color, scale);
}

//  This function takes a string and splits it up in a word-wrap fashion,
//  returning a vector of strings that are all shorter than the specified
//  width.

vector<string> Font::SplitStrings(string _String, int _DesiredWidth, float scale)
{
	vector<string> _ReturnStrings;

	int _TotalWidth = GetStringMetrics(_String);

	if (_TotalWidth <= _DesiredWidth * scale)
	{
		_ReturnStrings.push_back(_String);
		return _ReturnStrings;
	}
	else
	{
		int _Start = 0;
		int _CurrentSpace = 0;
		int _LastSpace = 0;
		//  Scan for spaces.
		for (unsigned int i = 0; i <= _String.size(); ++i)
		{
			//  Found a space?
			if (_String[i] == 32 || i == _String.size())
			{
				_LastSpace = _CurrentSpace;
				_CurrentSpace = i;
				string _TempString = _String.substr(_Start, i - _Start);

				if (i == _String.size() && _LastSpace == 0)
				{
					_ReturnStrings.push_back(_String);	// if the entire string is too long for this line, but it can't be broken up, just spit it back out
					return _ReturnStrings;
				}
				if (GetStringMetrics(_TempString) > _DesiredWidth * scale)
				{
					_ReturnStrings.push_back(_String.substr(_Start, _LastSpace - _Start));
					_Start = _LastSpace + 1;
					i = _LastSpace + 1;
				}
				else if (i == _String.size())
				{
					_ReturnStrings.push_back(_String.substr(_Start, _CurrentSpace - _Start));
				}
			}
		}

		return _ReturnStrings;
	}
}

vector<string> Font::SplitStringsOnCarriageReturn(string _String)
{
	vector<string> _ReturnStrings;

	int _Start = 0;
	int _CurrentSpace = 0;
	int _LastSpace = 0;
	//  Scan for carriage returns.
	for (unsigned int i = 0; i <= _String.size(); ++i)
	{
		if (_String[i] == char(13) || i == _String.size())
		{
			_LastSpace = _CurrentSpace;
			_CurrentSpace = i;

			_ReturnStrings.push_back(_String.substr(_Start, _CurrentSpace - _Start));
			_Start = i + 1;
		}
	}

	return _ReturnStrings;
}
