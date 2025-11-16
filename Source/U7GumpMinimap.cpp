#include <fstream>
#include <string>

#include "U7Gump.h"
#include "U7GumpMinimap.h"
#include "Geist/Config.h"
#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "Geist/Logging.h"
#include "U7Globals.h"

#include "raylib.h"
#include "../ThirdParty/raylib/include/raylib.h"

using namespace std;

GumpMinimap::GumpMinimap()
	: m_npcId(-1)
	, m_isModal(true)
{
}

GumpMinimap::~GumpMinimap()
{
}

void GumpMinimap::OnEnter()
{
	Log("GumpMinimap::OnEnter()");

	// Disable dragging - modal minimap should stay centered
	m_gui.m_Draggable = false;
}

void GumpMinimap::Init(const std::string& data)
{
	// Load minimap GUI from minimap.ghost file
	m_serializer = std::make_unique<GhostSerializer>();

	if (m_serializer->LoadFromFile("GUI/minimap.ghost", &m_gui))
	{
		Log("GumpMinimap::Init - Successfully loaded minimap.ghost");

		// Keep loaded fonts alive
		m_loadedFonts = m_serializer->GetLoadedFonts();

		// Center the GUI on screen
		m_serializer->CenterLoadedGUI(&m_gui, g_DrawScale);

		m_Pos.x = m_gui.m_Pos.x;
		m_Pos.y = m_gui.m_Pos.y;

		Log("GumpMinimap::Init - Centered at: " + std::to_string(m_gui.m_Pos.x) + "," + std::to_string(m_gui.m_Pos.y));
	}
	else
	{
		Log("GumpMinimap::Init - ERROR: Failed to load minimap.ghost");
	}

	Log("GumpMinimap::Init - Minimap initialized for NPC " + std::to_string(m_npcId));
}

void GumpMinimap::Setup(int npcId)
{
	m_npcId = npcId;
	Log("GumpMinimap::Setup - Set NPC ID to " + std::to_string(npcId));
}

void GumpMinimap::Update()
{
	// Call base class update
	Gump::Update();

	// Modal behavior: close on any mouse click anywhere on screen
	if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
	{
		Log("GumpMinimap::Update - Mouse clicked, closing minimap");
		m_IsDead = true;
	}
}

void GumpMinimap::Draw()
{
	// Only draw the GUI, don't call base Gump::Draw() which tries to draw container inventory
	m_gui.Draw();
}

bool GumpMinimap::IsMouseOverSolidPixel(Vector2 mousePos)
{
	// For now, use simple bounding box collision
	// The minimap is a filled panel, so any point within bounds is solid
	Rectangle bounds = m_gui.GetBounds();
	return CheckCollisionPointRec(mousePos, bounds);
}
