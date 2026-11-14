#ifndef _U7VGAFONT_H_
#define _U7VGAFONT_H_

#include <array>
#include <string>
#include <vector>

#include "raylib.h"

// One fonts.vga shape. Each frame is a character (frame index == character code).
// Shape 1 is the wood-grain sign face. Shape 3 is the gravestone face. Shape 6 is the gold plaque face.
class U7VgaFont
{
public:
	bool Load(const std::string& path, int shapeIndex, const std::array<Color, 256>& palette, int hLead);
	bool IsLoaded() const { return m_loaded; }

	// y is the top of the line. Glyphs share a baseline inside that line.
	void Draw(const std::string& text, int x, int y) const;
	int Measure(const std::string& text) const;
	int LineHeight() const { return m_lineHeight; }

private:
	struct Glyph
	{
		Texture2D texture{};
		int width = 0;
		int height = 0;
		int xLeft = 0;
		int yAbove = 0;
		bool present = false;
	};

	std::vector<Glyph> m_glyphs;
	int m_hLead = 0;
	int m_baseline = 0;
	int m_lineHeight = 0;
	bool m_loaded = false;
};

// Loads the sign, gravestone, and plaque faces from STATIC/FONTS.VGA.
bool LoadU7VgaFonts(const std::array<Color, 256>& palette);
const U7VgaFont* GetU7VgaFont(int shapeIndex);

// Plaques and gravestones spell the shorthand out: ( th, ) ee, * ng, + ea, , st, | space.
// Wooden signs do not. Font 1 draws lowercase as runes.
std::string ExpandSignText(const std::string& text);

#endif
