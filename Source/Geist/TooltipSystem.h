#ifndef _TOOLTIPSYSTEM_H_
#define _TOOLTIPSYSTEM_H_

#include <string>
#include <vector>

#include "Globals.h"
#include "Primitives.h"
#include "raylib.h"

void DrawToolTip(Font* font, float size, std::vector<ColoredString> strings,
                 int x, int y, float lineWidth = 1, int anchorcorner = 0);
void DrawToolTip(Font* font, float size, std::string strings, int x, int y,
                 float lineWidth = 1, int anchorcorner = 0,
                 Color color = Color{255, 255, 255, 255});

#endif
