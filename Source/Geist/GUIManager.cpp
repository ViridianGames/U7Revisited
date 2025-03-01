#include "GuiManager.h"
#include "Gui.h"
#include "Logging.h"

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
	for (auto& gui : m_GuiList)
	{
		gui.get()->Update();
	}
}

void GuiManager::Draw()
{
	for (auto& gui : m_GuiList)
	{
		gui.get()->Draw();
	}
}