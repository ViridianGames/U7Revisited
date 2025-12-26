#include <Geist/GuiManager.h>
#include <Geist/Gui.h>
#include <Geist/Logging.h>
#include <memory>
#include <algorithm>

using namespace std;

void GuiManager::Init(const std::string& configfile)
{
	Log("Starting GUIManager::Init()");

	m_ConfigFileName = configfile;
	m_GUIManagerConfig.Load(configfile);

	Log("Done with GUIManager::Init()");
}

void GuiManager::Shutdown()
{

}

void GuiManager::Update()
{
	for (vector<std::shared_ptr<Gui>>::iterator gui = m_GuiList.begin(); gui != m_GuiList.end();)
	{
		(*gui).get()->Update();
		if ((*gui).get()->m_isDone)
		{
			gui = m_GuiList.erase(gui);
		}
		else
		{
			++gui;
		}
	}
}

void GuiManager::Draw()
{
	for (auto& gui : m_GuiList)
	{
		gui.get()->Draw();
	}
}

void GuiManager::AddGui(std::shared_ptr<Gui>& gui)
{
	m_GuiList.push_back(gui);
}

bool GuiManager::IsMouseOverAnyGui() const
{
	for (const auto& gui : m_GuiList)
	{
		if (gui->IsMouseOverGui())
			return true;
	}
	return false;
}