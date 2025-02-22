#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "raylib.h"
#include "OptionsState.h"

#include <list>
#include <string>
#include <sstream>
#include <math.h>
#include <fstream>
#include <algorithm>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  OptionsState
////////////////////////////////////////////////////////////////////////////////

OptionsState::~OptionsState()
{
	 Shutdown();
}

void OptionsState::Init(const string& configfile)
{

}

void OptionsState::OnEnter()
{

}

void OptionsState::OnExit()
{

}

void OptionsState::Shutdown()
{

}

void OptionsState::Update()
{
	 if( IsKeyPressed(KEY_ESCAPE) )
	 {
			g_Engine->m_Done = true;
	 }

}


void OptionsState::Draw()
{

}

