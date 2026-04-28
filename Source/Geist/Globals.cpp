#include <Geist/Globals.h>
#include <Geist/Engine.h>
#include <Geist/ResourceManager.h>
#include <Geist/StateMachine.h>
#include <Geist/ScriptingSystem.h>
#include <Geist/SoundSystem.h>
#include <Geist/InputSystem.h>
#include <Geist/Primitives.h>
#include <Geist/Logging.h>
#include <iostream>

using namespace std;

unique_ptr<Engine>           g_Engine;
unique_ptr<ResourceManager>  g_ResourceManager;
unique_ptr<StateMachine>     g_StateMachine;
unique_ptr<ScriptingSystem>  g_ScriptingSystem;
unique_ptr<SoundSystem>      g_SoundSystem;
unique_ptr<InputSystem>      g_InputSystem;

void DrawStringCentered(Font* font, float fontsize, std::string text, float centerx, float centery, Color color)
{
	DrawStringCentered(font, fontsize, text, Vector2{centerx, centery}, color);
}

void DrawStringCentered(Font* font, float fontsize, std::string text, Vector2 center, Color color)
{
	DrawStringCentered(font, fontsize, (char*)text.c_str(), center, color);
}

void DrawStringCentered(Font* font, float fontsize, char* text, float centerx, float centery, Color color)
{
	DrawStringCentered(font, fontsize, text, Vector2{centerx, centery}, color);
}

void DrawStringCentered(Font* font, float fontsize, char* text, Vector2 center, Color color)
{
	Vector2 dims = MeasureTextEx(*font, text, fontsize, 1);
	center.x -= dims.x / 2;
	center.y -= dims.y / 2;

	//  Make sure we're on a whole pixel.
	int centerx = int(center.x);
	int centery = int(center.y);

	DrawTextEx(*font, text, {float(centerx), float(centery)}, fontsize, 1, color);
}

void DrawStringRight(Font* font, float fontsize, std::string text, float rightx, float y, Color color)
{
	DrawStringRight(font, fontsize, (char*)text.c_str(), rightx, y, color);
}

void DrawStringRight(Font* font, float fontsize, char* text, float rightx, float y, Color color)
{
	Vector2 dims = MeasureTextEx(*font, text, fontsize, 1);
	DrawTextEx(*font, text, Vector2{ rightx - dims.x, y }, fontsize, 1, color);
}

void DebugPrint(std::string msg)
{
	Log(msg, "debuglog.txt", true);
	// Don't print to cout here - Log() already does it when suppressdatetime=true
}


void NPCDebugPrint(std::string msg)
{
	Log(msg, "npcdebug.log", true);
}
