#include "GumpManager.h"
#include "U7Gump.h"
#include "Gui.h"
#include "Logging.h"
#include <memory>
#include <algorithm>

using namespace std;

void GumpManager::Init(const std::string& configfile)
{
	Log("Starting GumpManager::Init()");

	m_ConfigFileName = configfile;
	m_GumpManagerConfig.Load(configfile);

	Log("Done with GumpManager::Init()");
}

void GumpManager::Shutdown()
{

}

void GumpManager::Update()
{
	for (vector<std::shared_ptr<Unit2D>>::iterator Gump = m_GumpList.begin(); Gump != m_GumpList.end();)
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
}

void GumpManager::AddGump(std::shared_ptr<Unit2D> Gump)
{
	m_GumpList.push_back(Gump);
}