#ifndef _GEISTGLOBALS_H_
#define _GEISTGLOBALS_H_

#include <memory>
#include <string>
#include "raylib.h"

class Engine;
class ResourceManager;
class StateMachine;
class ScriptingSystem;
class Sprite;
class SoundSystem;
class InputSystem;

//  Global pointers

extern std::unique_ptr<Engine>           g_Engine;
extern std::unique_ptr<ResourceManager>  g_ResourceManager;
extern std::unique_ptr<StateMachine>     g_StateMachine;
extern std::unique_ptr<ScriptingSystem>  g_ScriptingSystem;
extern std::unique_ptr<SoundSystem>      g_SoundSystem;
extern std::unique_ptr<InputSystem>      g_InputSystem;

//  Global functions
void DrawStringCentered(Font* font, float fontsize, std::string text, float centerx, float centery,  Color color = WHITE);
void DrawStringCentered(Font* font, float fontsize, std::string text, Vector2 center, Color color = WHITE);
void DrawStringCentered(Font* font, float fontsize, char* text, float centerx, float centery, Color color = WHITE);
void DrawStringCentered(Font* font, float fontsize, char* text, Vector2 center, Color color = WHITE);
void DrawStringRight(Font* font, float fontsize, std::string text, float rightx, float y, Color color = WHITE);
void DrawStringRight(Font* font, float fontsize, char* text, float rightx, float y, Color color = WHITE);
void DebugPrint(std::string msg);

#endif