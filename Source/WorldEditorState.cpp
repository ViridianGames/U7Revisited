#include "Globals.h"
#include "U7Globals.h"
#include "WorldEditorState.h"

#include <list>
#include <string>
#include <sstream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <algorithm>
#include <unordered_map>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  WorldEditorState
////////////////////////////////////////////////////////////////////////////////

WorldEditorState::~WorldEditorState()
{
	Shutdown();
}

void WorldEditorState::Init(const string& configfile)
{


}

void WorldEditorState::OnEnter()
{

}

void WorldEditorState::OnExit()
{

}

void WorldEditorState::Shutdown()
{

}

void WorldEditorState::Update()
{
	if (g_Input->WasKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_Done = true;
	}
}


void WorldEditorState::Draw()
{
	g_Display->ClearScreen();

	g_Font->DrawString("Welcome to the World Editor!  It doesn't work yet. :(", 0, 0);
	g_Font->DrawString("Press ESC to exit.", 0, g_Font->GetStringMetrics(" ") * 3);

	g_Display->DrawImage(g_Cursor, g_Input->m_MouseX, g_Input->m_MouseY);

}