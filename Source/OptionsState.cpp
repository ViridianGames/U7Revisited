#include "OptionsState.h"
#include "Geist/Engine.h"
#include "Geist/Globals.h"
#include "raylib.h"

#include <algorithm>
#include <string>
#include <fstream>
#include <list>
#include <math.h>
#include <sstream>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  OptionsState
////////////////////////////////////////////////////////////////////////////////

OptionsState::~OptionsState() { Shutdown(); }

void OptionsState::Init(const string& configfile) {}

void OptionsState::OnEnter() {}

void OptionsState::OnExit() {}

void OptionsState::Shutdown() {}

void OptionsState::Update() {
    if (IsKeyPressed(KEY_ESCAPE)) {
        g_Engine->m_Done = true;
    }
}

void OptionsState::Draw() {}
