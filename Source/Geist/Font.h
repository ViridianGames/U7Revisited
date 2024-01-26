#ifndef _FONT_H_
#define _FONT_H_

#include "Object.h"
#include "Primitives.h"
#include "stb_truetype.h"
#include <string>

//  A font consists of two things:  a font TARGA and a file that stores
//  the width of each character as well as its "offset" - that is, how far
//  away it is from the left edge of the file.  Each font you use should
//  get its own font object - but you do not need multiple objects to just
//  draw one font in different colors.  Because we use OpenGL for our blits,
//  we get colored fonts for free.

#define SC_CURSOR (char)159
#define SC_CURSORRANDOM (char)162
#define SC_MONEY_SYMBOL (char)169
#define SC_KEY_OUTLINE (char)176

#define SC_DPAD_UP (char)161
#define SC_DPAD_DOWN (char)171
#define SC_DPAD_RIGHT (char)172
#define SC_DPAD_LEFT (char)183

#define SC_L_TRIGGER (char)165
#define SC_R_TRIGGER (char)166

#define SC_L_BUMPER (char)184
#define SC_R_BUMPER (char)175

#define SC_L3_BUTTON (char)163
#define SC_R3_BUTTON (char)164

#define SC_A_BUTTON (char)177
#define SC_B_BUTTON (char)168
#define SC_X_BUTTON (char)182
#define SC_Y_BUTTON (char)170

#define SC_SELECT_BUTTON (char)178
#define SC_START_BUTTON (char)179

class Font : public Object
{
public:

	Font() { }

	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& configfile);
	virtual void Init(const std::string& configfile, float height, bool log = false);
	virtual void Update() {};
	virtual void Draw() {};

	void DrawString(std::string texttodraw, int posX, int posY, Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), float scale = 1.0f);
	void DrawStringCentered(std::string texttodraw, int posX, int posY, const Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), float scale = 1.0f);
	void DrawStringRight(std::string texttodraw, int posX, int posY, const Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), float scale = 1.0f);
	int  DrawParagraph(std::string texttodraw, int posX, int posY, int width, int height, const Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), float scale = 1.0f);
	void DrawParagraphCentered(std::string texttodraw, int posX, int posY, int width, int height, const Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), float scale = 1.0f);
	void DrawParagraphRight(std::string texttodraw, int posX, int posY, int width, int height, Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), float scale = 1.0f);
	int  GetStringMetrics(std::string texttodraw, float scale = 1.0f);
	int  GetStringMetricsHeight(std::string texttodraw, int width, float scale = 1.0f);
	float GetHeight() { return m_FontHeight; }
	int  FitStringInLength(std::string texttodraw, int length);
	std::vector<std::string> SplitStrings(std::string _String, int _DesiredWidth, float scale);
	std::vector<std::string> SplitStringsOnCarriageReturn(std::string _String);
	float GetYOffset() { return m_FontData[33].yoff; }
	std::shared_ptr<Texture> m_FontTexture;
	Texture* m_IconTexture;
private:

	stbtt_bakedchar m_FontData[96];
	float m_FontHeight;
};

#endif
