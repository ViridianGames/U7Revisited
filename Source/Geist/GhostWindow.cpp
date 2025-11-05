#include "GhostWindow.h"
#include "Ghost/GhostSerializer.h"
#include "Logging.h"
#include "ResourceManager.h"
#include "Config.h"

GhostWindow::GhostWindow(const std::string& ghostFilePath, const std::string& configPath,
                         ResourceManager* resourceManager, int screenWidth, int screenHeight, bool modal)
	: m_gui(nullptr)
	, m_serializer(nullptr)
	, m_visible(false)
	, m_modal(modal)
	, m_valid(false)
{
	// Create GUI and serializer
	m_gui = new Gui();
	m_serializer = new GhostSerializer();

	// Configure GUI layout for screen space
	// .ghost files are designed at screen resolution, not render resolution
	m_gui->SetLayout(0, 0, screenWidth, screenHeight, 1.0f, Gui::GUIP_CENTER);
	m_gui->m_InputScale = 1.0f;  // No scaling needed - working in screen space
	m_gui->m_AcceptingInput = true;  // GUI accepts input (interactive)

	// Get font path from config
	std::string fontPath;
	Config* config = resourceManager->GetConfig(configPath);
	if (config)
	{
		fontPath = config->GetString("FontPath");
	}
	if (fontPath.empty())
	{
		fontPath = "Data/Fonts/";
		Log("FontPath not found in config, using default: " + fontPath);
	}
	GhostSerializer::SetBaseFontPath(fontPath);

	// Load the .ghost file
	ghost_json json = m_serializer->ReadJsonFromFile(ghostFilePath);
	if (!json.empty() && m_serializer->ParseJson(json, m_gui))
	{
		m_valid = true;
		Log("GhostWindow: Successfully loaded " + ghostFilePath);
	}
	else
	{
		Log("ERROR: GhostWindow failed to load " + ghostFilePath);
	}
}

GhostWindow::~GhostWindow()
{
	delete m_gui;
	delete m_serializer;
}

void GhostWindow::Update()
{
	if (m_visible && m_gui && m_valid)
	{
		m_gui->Update();
	}
}

void GhostWindow::Draw()
{
	if (m_visible && m_gui && m_valid)
	{
		m_gui->Draw();
	}
}

void GhostWindow::Show()
{
	m_visible = true;
}

void GhostWindow::Hide()
{
	m_visible = false;
}

void GhostWindow::Toggle()
{
	m_visible = !m_visible;
}

void GhostWindow::MoveTo(int x, int y)
{
	if (m_gui)
	{
		m_gui->m_Pos.x = static_cast<float>(x);
		m_gui->m_Pos.y = static_cast<float>(y);
	}
}

int GhostWindow::GetElementID(const std::string& elementName)
{
	if (m_serializer)
	{
		return m_serializer->GetElementID(elementName);
	}
	return -1;
}
