#include "GumpManager.h"
#include "U7Gump.h"
#include "Gui.h"
#include "Logging.h"
#include <memory>
#include <algorithm>

#include "U7Globals.h"

using namespace std;

void GumpManager::Init(const std::string& configfile)
{
	Log("Starting GumpManager::Init()");

	m_ConfigFileName = configfile;
	m_GumpManagerConfig.Load(configfile);
	m_draggingObject = false;
	m_draggedObjectId = -1;

	Log("Done with GumpManager::Init()");
}

void GumpManager::Shutdown()
{

}

void GumpManager::Update()
{
	for (vector<std::shared_ptr<Gump>>::iterator Gump = m_GumpList.begin(); Gump != m_GumpList.end();)
	{
		(*Gump).get()->Update();
		if ((*Gump).get()->GetIsDead())
		{
			Gump = m_GumpList.erase(Gump);
		}
		else
		{
			++Gump;
		}
	}
}

void GumpManager::Draw()
{
	for (auto& Gump : m_GumpList)
	{
		Gump.get()->Draw();
	}

	if (m_draggingObject && m_draggedObjectId != -1)
	{
		U7Object* object = GetObjectFromID(m_draggedObjectId);
		Vector2 mousePos = GetMousePosition();
		mousePos.x = int(mousePos.x /= g_DrawScale);
		mousePos.y = int(mousePos.y /= g_DrawScale);
		DrawTextureEx(*object->m_shapeData->GetTexture(), mousePos, 0, 1, Color{255, 255, 255, 255});
	}
}

void GumpManager::AddGump(std::shared_ptr<Gump> Gump)
{
	m_GumpList.push_back(Gump);
}