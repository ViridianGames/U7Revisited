#ifndef _TOOLTIPSYSTEM_H_
#define _TOOLTIPSYSTEM_H_

#include "Globals.h"

void DrawToolTip(Font* font, std::vector<ColoredString> strings, int x, int y, float lineWidth = 1, int anchorcorner = 0);
void DrawToolTip(Font* font, std::string strings, int x, int y, float lineWidth = 1, int anchorcorner = 0, Color color = Color(1.0f, 1.0f, 1.0f, 1.0f));

#endif