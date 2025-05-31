#include "Globals.h"
#include "Engine.h"
#include "ResourceManager.h"
#include "StateMachine.h"
#include "ScriptingSystem.h"
#include "Primitives.h"

using namespace std;

unique_ptr<Engine>           g_Engine;
unique_ptr<ResourceManager>  g_ResourceManager;
unique_ptr<StateMachine>     g_StateMachine;
unique_ptr<ScriptingSystem>  g_ScriptingSystem;

//  These functions only return true if the mouse is in the rectangle and no mouse button is clicked or held.
bool IsMouseInRect(int x, int y, int w, int h)
{
	Rectangle rect = { float(x), float(y), float(w), float(h) };
	return IsMouseInRect(rect);
}

bool IsMouseInRect(Rectangle rect)
{
	int mouseX = GetMouseX();
	int mouseY = GetMouseY();

	return !IsMouseButtonDown(MOUSE_LEFT_BUTTON) && !IsMouseButtonDown(MOUSE_RIGHT_BUTTON) && !IsMouseButtonDown(MOUSE_MIDDLE_BUTTON) &&
		!IsMouseButtonPressed(MOUSE_LEFT_BUTTON) && !IsMouseButtonPressed(MOUSE_RIGHT_BUTTON) && !IsMouseButtonPressed(MOUSE_MIDDLE_BUTTON) &&
		!IsMouseButtonReleased(MOUSE_LEFT_BUTTON) && !IsMouseButtonReleased(MOUSE_RIGHT_BUTTON) && !IsMouseButtonReleased(MOUSE_MIDDLE_BUTTON) &&
		(mouseX >= rect.x && mouseX <= rect.x + rect.width) && (mouseY >= rect.y && mouseY <= rect.y + rect.height);
}

bool IsLeftButtonDownInRect(int x, int y, int w, int h)
{
	Rectangle rect = { float(x), float(y), float(w), float(h) };
	return IsLeftButtonDownInRect(rect);
}

bool IsLeftButtonDownInRect(Rectangle rect)
{
	int mouseX = GetMouseX();
	int mouseY = GetMouseY();

	return IsMouseButtonDown(MOUSE_LEFT_BUTTON) && (mouseX >= rect.x && mouseX <= rect.x + rect.width) && (mouseY >= rect.y && mouseY <= rect.y + rect.height);
}

bool WasLeftButtonClickedInRect(int x, int y, int w, int h)
{
	Rectangle rect = { float(x), float(y), float(w), float(h) };
	return WasLeftButtonClickedInRect(rect);
}

bool WasLeftButtonClickedInRect(Rectangle rect)
{
	int mouseX = GetMouseX();
	int mouseY = GetMouseY();

	return IsMouseButtonReleased(MOUSE_LEFT_BUTTON) && (mouseX >= rect.x && mouseX <= rect.x + rect.width) && (mouseY >= rect.y && mouseY <= rect.y + rect.height);
}

bool IsLeftButtonDragging()
{
	return IsMouseButtonDown(MOUSE_LEFT_BUTTON) && (GetMouseDelta().x != 0 || GetMouseDelta().y != 0);
}

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
