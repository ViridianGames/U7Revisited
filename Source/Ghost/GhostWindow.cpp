#include "GhostWindow.h"
#include "GhostSerializer.h"
#include "../Geist/Logging.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Config.h"

GhostWindow::GhostWindow(const std::string& ghostFilePath, const std::string& configPath,
                         ResourceManager* resourceManager, int screenWidth, int screenHeight, bool modal, float scale, float inputScale)
	: m_gui(nullptr)
	, m_serializer(nullptr)
	, m_visible(false)
	, m_modal(modal)
	, m_valid(false)
{
	// Create GUI and serializer
	m_gui = new Gui();
	m_serializer = new GhostSerializer();

	// Configure GUI layout with provided scale
	// Use GUIP_USE_XY to keep Gui m_Pos at (0,0) - elements have absolute screen positions
	m_gui->SetLayout(0, 0, screenWidth, screenHeight, scale, Gui::GUIP_USE_XY);
	m_gui->m_InputScale = inputScale;  // Input scale for converting screen coords to render coords
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
	if (m_gui && m_serializer)
	{
		// Get the root panel element and move it
		int rootID = m_serializer->GetRootElementID();
		if (rootID != -1)
		{
			auto rootElement = m_gui->GetElement(rootID);
			if (rootElement)
			{
				rootElement->m_Pos.x = static_cast<float>(x);
				rootElement->m_Pos.y = static_cast<float>(y);

				// Reflow children to update their absolute positions
				m_serializer->ReflowPanel(rootID, m_gui);
			}
		}
	}
}

void GhostWindow::GetSize(int& width, int& height) const
{
	width = 0;
	height = 0;

	if (m_serializer && m_gui)
	{
		// Get the root element (first panel loaded from .ghost file)
		int rootID = m_serializer->GetRootElementID();
		if (rootID != -1)
		{
			auto rootElement = m_gui->GetElement(rootID);
			if (rootElement)
			{
				width = static_cast<int>(rootElement->m_Width);
				height = static_cast<int>(rootElement->m_Height);
			}
		}
	}
}

Rectangle GhostWindow::GetBounds() const
{
	Rectangle bounds = { 0, 0, 0, 0 };

	if (m_serializer && m_gui)
	{
		// Get the root element (first panel loaded from .ghost file)
		int rootID = m_serializer->GetRootElementID();
		if (rootID != -1)
		{
			auto rootElement = m_gui->GetElement(rootID);
			if (rootElement)
			{
				bounds.x = rootElement->m_Pos.x;
				bounds.y = rootElement->m_Pos.y;
				bounds.width = rootElement->m_Width;
				bounds.height = rootElement->m_Height;
			}
		}
	}

	return bounds;
}

int GhostWindow::GetElementID(const std::string& elementName)
{
	if (m_serializer)
	{
		return m_serializer->GetElementID(elementName);
	}
	return -1;
}
