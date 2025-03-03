#include "ObjectEditorState.h"
#include "Geist/Engine.h"
#include "Geist/Globals.h"
#include "U7Globals.h"

#include <algorithm>
#include <string>
#include <fstream>
#include <iomanip>
#include <list>
#include <math.h>
#include <sstream>
#include <unordered_map>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  ObjectEditorState
////////////////////////////////////////////////////////////////////////////////

ObjectEditorState::~ObjectEditorState() { Shutdown(); }

void ObjectEditorState::Init(const string& configfile) {}

void ObjectEditorState::OnEnter() {}

void ObjectEditorState::OnExit() {}

void ObjectEditorState::Shutdown() {}

void ObjectEditorState::Update() {
    if (IsKeyPressed(KEY_ESCAPE)) {
        g_Engine->m_Done = true;
    }
}

void ObjectEditorState::Draw() {
    BeginDrawing();

    ClearBackground(Color{0, 0, 0, 255});

    DrawTextEx(*g_Font,
               "Welcome to the Object Editor!  It will eventually allow you to "
               "create new objects for your game.  It doesn't work yet. Sorry.",
               Vector2{0, 0}, g_Font->baseSize, 0, WHITE);
    DrawTextEx(*g_Font, "Press ESC to exit.", Vector2{0, g_fontSize},
               g_Font->baseSize, 0, WHITE);

    DrawTexture(*g_Cursor, GetMouseX(), GetMouseY(), WHITE);

    EndDrawing();
}
