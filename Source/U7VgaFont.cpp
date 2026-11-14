#include "U7VgaFont.h"

#include "Geist/Engine.h"
#include "Geist/Globals.h"
#include "Geist/Logging.h"

#include <cstdint>
#include <fstream>
#include <sstream>
#include <vector>

namespace
{

struct FlexEntry
{
	int offset = 0;
	int length = 0;
};

unsigned int ReadU32(std::istream& in)
{
	unsigned int value = 0;
	in.read(reinterpret_cast<char*>(&value), 4);
	return value;
}

int ReadS32(std::istream& in)
{
	int value = 0;
	in.read(reinterpret_cast<char*>(&value), 4);
	return value;
}

unsigned short ReadU16(std::istream& in)
{
	unsigned short value = 0;
	in.read(reinterpret_cast<char*>(&value), 2);
	return value;
}

short ReadS16(std::istream& in)
{
	short value = 0;
	in.read(reinterpret_cast<char*>(&value), 2);
	return value;
}

std::vector<FlexEntry> ReadFlexEntries(std::istream& in)
{
	char title[80];
	in.read(title, 80);
	ReadU32(in);
	const unsigned int count = ReadU32(in);
	for (int i = 0; i < 10; ++i)
	{
		ReadU32(in);
	}

	std::vector<FlexEntry> entries(count);
	for (unsigned int i = 0; i < count; ++i)
	{
		FlexEntry entry;
		entry.offset = ReadS32(in);
		if (entry.offset == 0)
		{
			ReadS32(in);
			continue;
		}
		entry.length = ReadS32(in);
		entries[i] = entry;
	}
	return entries;
}

} // namespace

bool U7VgaFont::Load(const std::string& path, int shapeIndex, const std::array<Color, 256>& palette, int hLead)
{
	for (Glyph& glyph : m_glyphs)
	{
		if (glyph.present)
		{
			UnloadTexture(glyph.texture);
		}
	}
	m_glyphs.clear();
	m_loaded = false;
	m_hLead = hLead;
	m_baseline = 0;
	m_lineHeight = 0;

	std::ifstream file(path, std::ios::binary);
	if (!file.good())
	{
		Log("FONTS.VGA not found at: " + path);
		return false;
	}

	std::stringstream data;
	data << file.rdbuf();
	file.close();

	const std::vector<FlexEntry> entries = ReadFlexEntries(data);
	if (shapeIndex < 0 || shapeIndex >= static_cast<int>(entries.size()))
	{
		return false;
	}
	const FlexEntry& entry = entries[static_cast<size_t>(shapeIndex)];
	if (entry.offset == 0 || entry.length < 8)
	{
		return false;
	}

	data.seekg(entry.offset);
	const std::streampos headerStart = data.tellg();
	const unsigned int dataLength = ReadU32(data);
	const bool rle = (dataLength == static_cast<unsigned int>(entry.length))
		|| ((entry.length % 2) == 0 && dataLength == static_cast<unsigned int>(entry.length - 1));
	if (!rle)
	{
		Log("FONTS.VGA shape " + std::to_string(shapeIndex) + " is not an RLE shape");
		return false;
	}

	const unsigned int headerLength = ReadU32(data);
	if (headerLength < 4)
	{
		return false;
	}
	const unsigned int frameCount = (headerLength - 4) / 4;
	if (frameCount == 0 || frameCount > 512)
	{
		return false;
	}

	std::vector<unsigned int> frameOffset(frameCount, headerLength);
	for (unsigned int i = 1; i < frameCount; ++i)
	{
		frameOffset[i] = ReadU32(data);
	}

	m_glyphs.resize(frameCount);
	int highest = 0;
	int lowest = 0;
	bool haveExtents = false;
	int loaded = 0;

	for (unsigned int frame = 0; frame < frameCount; ++frame)
	{
		data.seekg(headerStart + static_cast<std::streamoff>(frameOffset[frame]));
		const short xRight = ReadS16(data);
		const short xLeft = ReadS16(data);
		const short yAbove = ReadS16(data);
		const short yBelow = ReadS16(data);
		const int width = static_cast<int>(xLeft) + static_cast<int>(xRight) + 1;
		const int height = static_cast<int>(yAbove) + static_cast<int>(yBelow) + 1;
		if (width <= 0 || height <= 0 || width > 128 || height > 128)
		{
			continue;
		}

		const std::streampos frameEnd = (frame + 1 < frameCount)
			? headerStart + static_cast<std::streamoff>(frameOffset[frame + 1])
			: headerStart + static_cast<std::streamoff>(entry.length);

		Image image = GenImageColor(width, height, Color{ 0, 0, 0, 0 });

		while (data.good() && data.tellg() < frameEnd)
		{
			const unsigned short block = ReadU16(data);
			if (block == 0)
			{
				break;
			}
			const unsigned short spanLength = block >> 1;
			const unsigned short spanType = block & 1;
			short xStart = ReadS16(data);
			short yStart = ReadS16(data);
			xStart = static_cast<short>(xStart + width - xRight - 1);
			yStart = static_cast<short>(yStart + height - yBelow - 1);

			if (spanType == 0)
			{
				for (int i = 0; i < spanLength; ++i)
				{
					const unsigned char value = static_cast<unsigned char>(data.get());
					const int px = xStart + i;
					if (px >= 0 && yStart >= 0 && px < width && yStart < height)
					{
						ImageDrawPixel(&image, px, yStart, palette[value]);
					}
				}
			}
			else
			{
				int x = xStart;
				const int endX = xStart + spanLength;
				while (x < endX && data.good())
				{
					const unsigned char runData = static_cast<unsigned char>(data.get());
					const int runLength = runData >> 1;
					const int runType = runData & 1;
					if (runType == 0)
					{
						for (int i = 0; i < runLength; ++i)
						{
							const unsigned char value = static_cast<unsigned char>(data.get());
							const int px = x + i;
							if (px >= 0 && yStart >= 0 && px < width && yStart < height)
							{
								ImageDrawPixel(&image, px, yStart, palette[value]);
							}
						}
					}
					else
					{
						const unsigned char value = static_cast<unsigned char>(data.get());
						for (int i = 0; i < runLength; ++i)
						{
							const int px = x + i;
							if (px >= 0 && yStart >= 0 && px < width && yStart < height)
							{
								ImageDrawPixel(&image, px, yStart, palette[value]);
							}
						}
					}
					x += runLength;
				}
			}
		}

		// A blank frame (the space glyph) still has a width and must advance the pen.
		Glyph& glyph = m_glyphs[frame];
		glyph.texture = LoadTextureFromImage(image);
		SetTextureFilter(glyph.texture, TEXTURE_FILTER_POINT);
		UnloadImage(image);
		glyph.width = width;
		glyph.height = height;
		glyph.xLeft = xLeft;
		glyph.yAbove = yAbove;
		glyph.present = true;
		++loaded;

		if (!haveExtents)
		{
			highest = yAbove;
			lowest = yBelow;
			haveExtents = true;
		}
		else
		{
			if (yAbove > highest)
			{
				highest = yAbove;
			}
			if (yBelow > lowest)
			{
				lowest = yBelow;
			}
		}
	}

	if (!haveExtents)
	{
		return false;
	}

	m_baseline = highest;
	m_lineHeight = highest + lowest + 1;
	m_loaded = true;
	Log("FONTS.VGA shape " + std::to_string(shapeIndex) + ": " + std::to_string(loaded)
		+ " glyphs, line " + std::to_string(m_lineHeight));
	return true;
}

void U7VgaFont::Draw(const std::string& text, int x, int y) const
{
	int pen = x;
	for (unsigned char ch : text)
	{
		if (ch >= m_glyphs.size() || !m_glyphs[ch].present)
		{
			continue;
		}
		const Glyph& glyph = m_glyphs[ch];
		DrawTexture(glyph.texture, pen - glyph.xLeft, y + (m_baseline - glyph.yAbove), WHITE);
		pen += glyph.width + m_hLead;
	}
}

int U7VgaFont::Measure(const std::string& text) const
{
	int width = 0;
	for (unsigned char ch : text)
	{
		if (ch >= m_glyphs.size() || !m_glyphs[ch].present)
		{
			continue;
		}
		width += m_glyphs[ch].width + m_hLead;
	}
	return width;
}

namespace
{

U7VgaFont g_vgaFonts[11];

} // namespace

bool LoadU7VgaFonts(const std::array<Color, 256>& palette)
{
	if (!g_Engine)
	{
		return false;
	}
	const std::string path = g_Engine->m_EngineConfig.GetString("data_path") + "/STATIC/FONTS.VGA";
	// Horizontal lead from the fonts.vga table. Sign faces are -1.
	const int lead[11] = { -2, -1, 0, -1, 0, 0, -1, -2, -1, -1, 0 };
	bool any = false;
	for (int shape : { 1, 3, 6 })
	{
		if (g_vgaFonts[shape].Load(path, shape, palette, lead[shape]))
		{
			any = true;
		}
	}
	return any;
}

const U7VgaFont* GetU7VgaFont(int shapeIndex)
{
	if (shapeIndex < 0 || shapeIndex >= 11 || !g_vgaFonts[shapeIndex].IsLoaded())
	{
		return nullptr;
	}
	return &g_vgaFonts[shapeIndex];
}

std::string ExpandSignText(const std::string& text)
{
	std::string out;
	out.reserve(text.size() * 2);
	for (unsigned char ch : text)
	{
		switch (ch)
		{
			case '(':
				out += "TH";
				break;
			case ')':
				out += "EE";
				break;
			case '*':
				out += "NG";
				break;
			case '+':
				out += "EA";
				break;
			case ',':
				out += "ST";
				break;
			case '|':
				out += ' ';
				break;
			default:
				if (ch >= 'a' && ch <= 'z')
				{
					out += static_cast<char>(ch - 'a' + 'A');
				}
				else
				{
					out += static_cast<char>(ch);
				}
				break;
		}
	}
	return out;
}
