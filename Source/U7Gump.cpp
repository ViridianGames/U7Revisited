#include <fstream>
#include <string>
#include <sstream>

#include "U7Gump.h"
#include "Geist/Config.h"
#include "Geist/Engine.h"
#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"

#include "raylib.h"

using namespace std;

Gump::Gump()
{

	m_PositionFlag = GUIP_USE_XY;
	m_Width = 0;
	m_Height = 0;
	m_Active = 1;
	m_Editing = false;
	m_ActiveElement = -1;
	m_LastElement = -2;
	m_InputScale = 1;
	m_Font = make_shared<Font>(GetFontDefault());
	m_Draggable = false;  // Dragging is off by default
	m_IsDragging = false;
	m_DragOffset = { 0, 0 };
	m_DragAreaHeight = 20;  // Default title bar height
	m_isDone = false;
	m_doneButtonId = -3;
}

Gump::~Gump()
{
}

void Gump::Update()
{
	Gui::Update();		
}

void Gump::Draw()
{
	Gui::Draw();

	shared_ptr<U7Object> thisObject = GetObjectFromID(m_containerId);
	int yoffset = 26;
	int xoffset = 52;

	for (auto& item : thisObject->m_inventory)
	{
		auto object = GetObjectFromID(item);
		DrawTextureEx(*object->m_shapeData->GetTexture(), Vector2{m_Pos.x + xoffset, m_Pos.y + yoffset}, 0, 1, Color{255, 255, 255, 255});
		xoffset += object->m_shapeData->GetTexture()->width + 1;
	}
}

void Gump::LinkContainer(int containerId)
{
	m_containerId = containerId;
}


