#include "SpritePickerState.h"
#include "../Geist/Logging.h"
#include "../Geist/StateMachine.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Config.h"
#include "../Geist/Gui.h"
#include "../Geist/GuiElements.h"
#include "GhostSerializer.h"
#include "SpriteUtils.h"
#include "FileChooserState.h"
#include <algorithm>
#include <queue>
#include <set>

extern std::unique_ptr<StateMachine> g_StateMachine;
extern std::unique_ptr<ResourceManager> g_ResourceManager;

// Helper function: Flood fill to find all connected non-transparent pixels
// Returns a bounding box (x, y, width, height) of the filled region
static Rectangle FloodFillBoundingBox(Texture* texture, int startX, int startY)
{
	if (!texture || texture->id == 0)
		return {0, 0, 0, 0};

	// Get pixel data from texture
	Image image = LoadImageFromTexture(*texture);
	Color* pixels = LoadImageColors(image);
	
	int width = image.width;
	int height = image.height;
	
	// Check if start pixel is transparent
	int startIndex = startY * width + startX;
	if (startX < 0 || startX >= width || startY < 0 || startY >= height ||
		pixels[startIndex].a == 0)
	{
		UnloadImageColors(pixels);
		UnloadImage(image);
		return {0, 0, 0, 0};
	}
	
	// Flood fill using BFS
	std::queue<std::pair<int, int>> queue;
	std::set<std::pair<int, int>> visited;
	
	queue.push({startX, startY});
	visited.insert({startX, startY});
	
	int minX = startX;
	int maxX = startX;
	int minY = startY;
	int maxY = startY;
	
	// 4-way connectivity (up, down, left, right)
	int dx[] = {0, 0, -1, 1};
	int dy[] = {-1, 1, 0, 0};
	
	while (!queue.empty())
	{
		auto [x, y] = queue.front();
		queue.pop();
		
		// Update bounding box
		minX = std::min(minX, x);
		maxX = std::max(maxX, x);
		minY = std::min(minY, y);
		maxY = std::max(maxY, y);
		
		// Check all 4 neighbors
		for (int i = 0; i < 4; i++)
		{
			int nx = x + dx[i];
			int ny = y + dy[i];
			
			// Check bounds
			if (nx < 0 || nx >= width || ny < 0 || ny >= height)
				continue;
			
			// Check if already visited
			if (visited.find({nx, ny}) != visited.end())
				continue;
			
			// Check if pixel is non-transparent
			int index = ny * width + nx;
			if (pixels[index].a > 0)
			{
				queue.push({nx, ny});
				visited.insert({nx, ny});
			}
		}
	}
	
	UnloadImageColors(pixels);
	UnloadImage(image);
	
	// Return bounding box
	float boxWidth = static_cast<float>(maxX - minX + 1);
	float boxHeight = static_cast<float>(maxY - minY + 1);
	
	return {static_cast<float>(minX), static_cast<float>(minY), boxWidth, boxHeight};
}

SpritePickerState::~SpritePickerState()
{
}

void SpritePickerState::Init(const std::string& configfile)
{
	Log("SpritePickerState::Init");

	// Create the window - it handles all config loading and GUI setup
	m_window = std::make_unique<GhostWindow>(
		GhostSerializer::GetBaseGhostPath() + "ghost_sprite_dialog.ghost",
		"Data/ghost.cfg",
		g_ResourceManager.get(),
		GetScreenWidth(),
		GetScreenHeight(),
		true);

	if (!m_window->GetGui())
	{
		Log("ERROR: Failed to load sprite picker dialog GUI");
	}
	else
	{
		Log("SpritePickerState: Successfully loaded dialog GUI");
	}
}

void SpritePickerState::Shutdown()
{
	Log("SpritePickerState::Shutdown");
	m_window.reset();
}

void SpritePickerState::OnEnter()
{
	Log("SpritePickerState::OnEnter");
	m_accepted = false;
	// DON'T reset m_waitingForFileChooser here - it needs to persist when returning from FileChooserState

	// Reset zoom and pan
	m_zoom = 1.0f;
	m_panX = 0.0f;
	m_panY = 0.0f;

	// Reload the current spritesheet from disk (in case it was edited externally)
	if (!m_filename.empty())
	{
		std::string spritePath = GhostSerializer::GetBaseSpritePath() + m_filename;
		g_ResourceManager->ReloadTexture(spritePath);
		Log("Reloaded spritesheet: " + spritePath);
	}

	// Make the window visible
	m_window->Show();

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Get texture dimensions to set scrollbar ranges
	int textureWidth = 255;
	int textureHeight = 255;
	if (!m_filename.empty())
	{
		std::string spritePath = GhostSerializer::GetBaseSpritePath() + m_filename;
		Texture* texture = g_ResourceManager->GetTexture(spritePath);
		if (texture)
		{
			textureWidth = texture->width;
			textureHeight = texture->height;
		}
	}

	// Set scrollbar values for x, y, width, height
	Log("OnEnter: Setting scrollbars to x=" + std::to_string(m_x) + " y=" + std::to_string(m_y) +
	    " w=" + std::to_string(m_width) + " h=" + std::to_string(m_height));
	Log("OnEnter: Texture dimensions: " + std::to_string(textureWidth) + "x" + std::to_string(textureHeight));

	int xScrollbarID = m_window->GetElementID("SPRITE_X");
	if (xScrollbarID != -1)
	{
		auto elem = gui->GetElement(xScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(elem.get());
			scrollbar->m_ValueRange = textureWidth;
			scrollbar->m_Value = m_x;
			Log("Set X scrollbar: value=" + std::to_string(scrollbar->m_Value) + " range=" + std::to_string(scrollbar->m_ValueRange));
		}
	}

	int yScrollbarID = m_window->GetElementID("SPRITE_Y");
	if (yScrollbarID != -1)
	{
		auto elem = gui->GetElement(yScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(elem.get());
			scrollbar->m_ValueRange = textureHeight;
			scrollbar->m_Value = m_y;
		}
	}

	int widthScrollbarID = m_window->GetElementID("SPRITE_WIDTH");
	if (widthScrollbarID != -1)
	{
		auto elem = gui->GetElement(widthScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(elem.get());
			scrollbar->m_ValueRange = textureWidth;
			scrollbar->m_Value = m_width;
		}
	}

	int heightScrollbarID = m_window->GetElementID("SPRITE_HEIGHT");
	if (heightScrollbarID != -1)
	{
		auto elem = gui->GetElement(heightScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
		{
			auto scrollbar = static_cast<GuiScrollBar*>(elem.get());
			scrollbar->m_ValueRange = textureHeight;
			scrollbar->m_Value = m_height;
		}
	}

	// Auto-zoom and pan to the current selection if we have valid dimensions
	if (m_width > 0 && m_height > 0 && textureWidth > 0 && textureHeight > 0)
	{
		// Get browser dimensions from the Rectangle (x, y, width, height)
		float browserWidth = 103.0f;   // m_browserBounds.width
		float browserHeight = 408.0f;  // m_browserBounds.height
		
		// Calculate zoom to make the selection fill about 40% of the browser area
		// This gives a nice close-up view while leaving room to see context
		float zoomX = (browserWidth * 0.4f) / m_width;
		float zoomY = (browserHeight * 0.4f) / m_height;
		m_zoom = std::min(zoomX, zoomY);
		
		// Clamp zoom to reasonable limits (at least 4x for small sprites, up to 20x)
		m_zoom = std::max(4.0f, std::min(20.0f, m_zoom));
		
		// Calculate center of selection in texture coordinates
		float selCenterX = m_x + m_width / 2.0f;
		float selCenterY = m_y + m_height / 2.0f;
		
		// Pan so that the selection center appears in the center of the browser
		// Center of browser is at browserWidth/2, browserHeight/2
		// We want: browserCenter = selCenter * zoom + pan
		// So: pan = browserCenter - selCenter * zoom
		m_panX = (browserWidth / 2.0f) - (selCenterX * m_zoom);
		m_panY = (browserHeight / 2.0f) - (selCenterY * m_zoom);
		
		Log("Auto-zoom: zoom=" + std::to_string(m_zoom) + " selection=(" + std::to_string(m_x) + "," + std::to_string(m_y) + "," + std::to_string(m_width) + "," + std::to_string(m_height) + ") pan=(" + std::to_string(m_panX) + "," + std::to_string(m_panY) + ")");
	}
}

void SpritePickerState::OnExit()
{
	Log("SpritePickerState::OnExit");
}

void SpritePickerState::Update()
{
	m_window->Update();

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Check for "Open Image" button click
	int filenameButtonID = m_window->GetElementID("SPRITE_FILENAME");
	if (filenameButtonID != -1)
	{
		auto elem = gui->GetElement(filenameButtonID);
		if (elem && elem->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(elem.get());
			if (button->m_Clicked)
			{
				Log("Opening file chooser for sprite image selection");

				// Determine initial path - use current sprite's directory if valid, otherwise use remembered path
				std::string initialPath = "";
				if (!m_filename.empty() && m_filename != "image.png")
				{
					// Extract directory from current filename
					std::string fullPath = GhostSerializer::GetBaseSpritePath() + m_filename;
					size_t lastSlash = fullPath.find_last_of("/\\");
					if (lastSlash != std::string::npos)
					{
						initialPath = fullPath.substr(0, lastSlash + 1);
					}
				}
				// If initialPath is still empty, SetMode will use the remembered directory

				// Open FileChooserState for image selection, pre-selecting current filename if we have one
				auto fileChooserState = static_cast<FileChooserState*>(g_StateMachine->GetState(3));
				fileChooserState->SetMode(false, ".png|.jpg|.jpeg|.bmp", initialPath, "Select Sprite Image", m_filename);
				g_StateMachine->PushState(3);

				// Set flag so we know to check for results when we resume
				m_waitingForFileChooser = true;
				return;
			}
		}
	}

	// Check if we just returned from FileChooserState
	if (m_waitingForFileChooser)
	{
		Log("SpritePickerState: Checking file chooser results");
		m_waitingForFileChooser = false;  // Clear flag regardless of outcome

		auto fileChooserState = static_cast<FileChooserState*>(g_StateMachine->GetState(3));
		bool wasAccepted = fileChooserState->WasAccepted();
		Log("FileChooser WasAccepted: " + std::string(wasAccepted ? "true" : "false"));

		if (wasAccepted)
		{
			std::string selectedPath = fileChooserState->GetSelectedPath();
			Log("FileChooser selected path: " + selectedPath);

			if (!selectedPath.empty())
				{
					// Convert absolute path to relative path
					std::string basePath = GhostSerializer::GetBaseSpritePath();

					// Normalize paths for comparison (convert backslashes to forward slashes)
					std::string normalizedSelected = selectedPath;
					std::string normalizedBase = basePath;
					std::replace(normalizedSelected.begin(), normalizedSelected.end(), '\\', '/');
					std::replace(normalizedBase.begin(), normalizedBase.end(), '\\', '/');

					// Find the base path in the selected path
					size_t pos = normalizedSelected.find(normalizedBase);
					if (pos != std::string::npos)
					{
						// Extract relative path (everything after basePath)
						m_filename = normalizedSelected.substr(pos + normalizedBase.length());

						// Remove leading slashes
						while (!m_filename.empty() && m_filename[0] == '/')
							m_filename = m_filename.substr(1);

						Log("Selected sprite file: " + m_filename);
					}
					else
					{
						// If not in base path, just use the filename
						size_t lastSlash = normalizedSelected.find_last_of('/');
						if (lastSlash != std::string::npos)
							m_filename = normalizedSelected.substr(lastSlash + 1);
						else
							m_filename = normalizedSelected;

						Log("Selected sprite file (not in base path): " + m_filename);
				}

				// Reload the texture from disk (in case it was edited) and get its dimensions
				std::string spritePath = GhostSerializer::GetBaseSpritePath() + m_filename;
				g_ResourceManager->ReloadTexture(spritePath);
				Texture* texture = g_ResourceManager->GetTexture(spritePath);

				if (texture)
				{
					// Reset coordinates to (0,0) and size to full texture
					m_x = 0;
					m_y = 0;
					m_width = texture->width;
					m_height = texture->height;

					Log("Reset sprite coordinates to full texture: " + std::to_string(texture->width) + "x" + std::to_string(texture->height));

					// Update scrollbar values AND ranges to reflect new texture dimensions
					int xScrollbarID = m_window->GetElementID("SPRITE_X");
					if (xScrollbarID != -1)
					{
						auto xElem = gui->GetElement(xScrollbarID);
						if (xElem && xElem->m_Type == GUI_SCROLLBAR)
						{
							auto scrollbar = static_cast<GuiScrollBar*>(xElem.get());
							scrollbar->m_ValueRange = texture->width;
							scrollbar->m_Value = m_x;
						}
					}

					int yScrollbarID = m_window->GetElementID("SPRITE_Y");
					if (yScrollbarID != -1)
					{
						auto yElem = gui->GetElement(yScrollbarID);
						if (yElem && yElem->m_Type == GUI_SCROLLBAR)
						{
							auto scrollbar = static_cast<GuiScrollBar*>(yElem.get());
							scrollbar->m_ValueRange = texture->height;
							scrollbar->m_Value = m_y;
						}
					}

					int widthScrollbarID = m_window->GetElementID("SPRITE_WIDTH");
					if (widthScrollbarID != -1)
					{
						auto wElem = gui->GetElement(widthScrollbarID);
						if (wElem && wElem->m_Type == GUI_SCROLLBAR)
						{
							auto scrollbar = static_cast<GuiScrollBar*>(wElem.get());
							scrollbar->m_ValueRange = texture->width;
							scrollbar->m_Value = m_width;
						}
					}

					int heightScrollbarID = m_window->GetElementID("SPRITE_HEIGHT");
					if (heightScrollbarID != -1)
					{
						auto hElem = gui->GetElement(heightScrollbarID);
						if (hElem && hElem->m_Type == GUI_SCROLLBAR)
						{
							auto scrollbar = static_cast<GuiScrollBar*>(hElem.get());
							scrollbar->m_ValueRange = texture->height;
							scrollbar->m_Value = m_height;
						}
					}
				}
				else
				{
					Log("ERROR: Failed to load texture for new sprite file: " + spritePath);
				}
			}
		}
	}

	// Handle zoom and drag selection on the browser area
	if (!m_filename.empty())
	{
		std::string spritePath = GhostSerializer::GetBaseSpritePath() + m_filename;
		Texture* texture = g_ResourceManager->GetTexture(spritePath);

		if (texture)
		{
			// Browser bounds at absolute screen coordinates
			float browserX = m_browserBounds.x;
			float browserY = m_browserBounds.y;
			Rectangle bounds = {
				browserX,
				browserY,
				texture->width * m_zoom,
				texture->height * m_zoom
			};

			Vector2 mousePos = GetMousePosition();
			bool mouseInBounds = CheckCollisionPointRec(mousePos, bounds);

			if (mouseInBounds)
			{
				// Mouse wheel zoom
				float wheelMove = GetMouseWheelMove();
				if (wheelMove != 0.0f)
				{
					// Calculate mouse position relative to browser origin
					float mouseRelX = mousePos.x - browserX;
					float mouseRelY = mousePos.y - browserY;
					
					// Calculate which texture coordinate is currently under the mouse
					float texCoordX = (mouseRelX - m_panX) / m_zoom;
					float texCoordY = (mouseRelY - m_panY) / m_zoom;
					
					// Apply zoom
					float oldZoom = m_zoom;
					float zoomFactor = 1.1f;
					if (wheelMove > 0)
						m_zoom *= zoomFactor;
					else
						m_zoom /= zoomFactor;
					
					// Clamp zoom
					m_zoom = std::max(0.1f, std::min(20.0f, m_zoom));
					
					// Adjust pan so the same texture coordinate stays under the mouse
					m_panX = mouseRelX - texCoordX * m_zoom;
					m_panY = mouseRelY - texCoordY * m_zoom;
					
					Log("Zoom: " + std::to_string(m_zoom));
				}

				// Handle middle mouse button panning
				if (IsMouseButtonPressed(MOUSE_MIDDLE_BUTTON))
				{
					m_isPanning = true;
					m_panStartMouseX = mousePos.x;
					m_panStartMouseY = mousePos.y;
					m_panStartX = m_panX;
					m_panStartY = m_panY;
				}

				// Handle mouse clicks - start drag selection or double-click flood fill
				if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON) && !m_isPanning)
				{
					// Calculate texture coordinates accounting for zoom and pan
					float relX = (mousePos.x - bounds.x - m_panX) / m_zoom;
					float relY = (mousePos.y - bounds.y - m_panY) / m_zoom;

					int clickX = static_cast<int>(relX);
					int clickY = static_cast<int>(relY);
					
					// Check for double-click
					double currentTime = GetTime();
					bool isDoubleClick = false;
					
					if (currentTime - m_lastClickTime < m_doubleClickDelay)
					{
						// Check if click is close to previous click position
						int dx = clickX - m_lastClickX;
						int dy = clickY - m_lastClickY;
						if (dx * dx + dy * dy < m_doubleClickRadius * m_doubleClickRadius)
						{
							isDoubleClick = true;
						}
					}
					
					if (isDoubleClick)
					{
						// Perform flood fill to find bounding box
						Rectangle bbox = FloodFillBoundingBox(texture, clickX, clickY);
						
						if (bbox.width > 0 && bbox.height > 0)
						{
							// Update selection to the flood-filled bounding box
							m_x = static_cast<int>(bbox.x);
							m_y = static_cast<int>(bbox.y);
							m_width = static_cast<int>(bbox.width);
							m_height = static_cast<int>(bbox.height);
							
							Log("Flood fill bounding box: x=" + std::to_string(m_x) + " y=" + std::to_string(m_y) +
								" w=" + std::to_string(m_width) + " h=" + std::to_string(m_height));
							
							// Update scrollbars
							int xScrollbarID = m_window->GetElementID("SPRITE_X");
							if (xScrollbarID != -1)
							{
								auto elem = gui->GetElement(xScrollbarID);
								if (elem && elem->m_Type == GUI_SCROLLBAR)
									static_cast<GuiScrollBar*>(elem.get())->m_Value = m_x;
							}

							int yScrollbarID = m_window->GetElementID("SPRITE_Y");
							if (yScrollbarID != -1)
							{
								auto elem = gui->GetElement(yScrollbarID);
								if (elem && elem->m_Type == GUI_SCROLLBAR)
									static_cast<GuiScrollBar*>(elem.get())->m_Value = m_y;
							}

							int widthScrollbarID = m_window->GetElementID("SPRITE_WIDTH");
							if (widthScrollbarID != -1)
							{
								auto elem = gui->GetElement(widthScrollbarID);
								if (elem && elem->m_Type == GUI_SCROLLBAR)
									static_cast<GuiScrollBar*>(elem.get())->m_Value = m_width;
							}

							int heightScrollbarID = m_window->GetElementID("SPRITE_HEIGHT");
							if (heightScrollbarID != -1)
							{
								auto elem = gui->GetElement(heightScrollbarID);
								if (elem && elem->m_Type == GUI_SCROLLBAR)
									static_cast<GuiScrollBar*>(elem.get())->m_Value = m_height;
							}
						}
						
						// Reset double-click tracking
						m_lastClickTime = 0.0;
					}
					else
					{
						// Single click - start drag selection
						m_dragStartX = clickX;
						m_dragStartY = clickY;
						m_dragEndX = m_dragStartX;
						m_dragEndY = m_dragStartY;
						m_isDragging = true;
						
						// Update double-click tracking
						m_lastClickTime = currentTime;
						m_lastClickX = clickX;
						m_lastClickY = clickY;
					}
				}

				// Update drag selection
				if (m_isDragging && IsMouseButtonDown(MOUSE_LEFT_BUTTON))
				{
					float relX = (mousePos.x - bounds.x - m_panX) / m_zoom;
					float relY = (mousePos.y - bounds.y - m_panY) / m_zoom;

					m_dragEndX = static_cast<int>(relX);
					m_dragEndY = static_cast<int>(relY);
				}

				// End drag selection and update scrollbars
				if (m_isDragging && IsMouseButtonReleased(MOUSE_LEFT_BUTTON))
				{
					m_isDragging = false;

					// Calculate selection rectangle
					int selX = std::min(m_dragStartX, m_dragEndX);
					int selY = std::min(m_dragStartY, m_dragEndY);
					int selW = std::abs(m_dragEndX - m_dragStartX);
					int selH = std::abs(m_dragEndY - m_dragStartY);

					// Clamp to texture bounds
					selX = std::max(0, std::min(selX, texture->width - 1));
					selY = std::max(0, std::min(selY, texture->height - 1));
					selW = std::max(1, std::min(selW, texture->width - selX));
					selH = std::max(1, std::min(selH, texture->height - selY));

					// Update sprite coordinates
					m_x = selX;
					m_y = selY;
					m_width = selW;
					m_height = selH;

					Log("Selected rect: x=" + std::to_string(m_x) + " y=" + std::to_string(m_y) +
						" w=" + std::to_string(m_width) + " h=" + std::to_string(m_height));

					// Update scrollbars
					int xScrollbarID = m_window->GetElementID("SPRITE_X");
					if (xScrollbarID != -1)
					{
						auto elem = gui->GetElement(xScrollbarID);
						if (elem && elem->m_Type == GUI_SCROLLBAR)
							static_cast<GuiScrollBar*>(elem.get())->m_Value = m_x;
					}

					int yScrollbarID = m_window->GetElementID("SPRITE_Y");
					if (yScrollbarID != -1)
					{
						auto elem = gui->GetElement(yScrollbarID);
						if (elem && elem->m_Type == GUI_SCROLLBAR)
							static_cast<GuiScrollBar*>(elem.get())->m_Value = m_y;
					}

					int widthScrollbarID = m_window->GetElementID("SPRITE_WIDTH");
					if (widthScrollbarID != -1)
					{
						auto elem = gui->GetElement(widthScrollbarID);
						if (elem && elem->m_Type == GUI_SCROLLBAR)
							static_cast<GuiScrollBar*>(elem.get())->m_Value = m_width;
					}

					int heightScrollbarID = m_window->GetElementID("SPRITE_HEIGHT");
					if (heightScrollbarID != -1)
					{
						auto elem = gui->GetElement(heightScrollbarID);
						if (elem && elem->m_Type == GUI_SCROLLBAR)
							static_cast<GuiScrollBar*>(elem.get())->m_Value = m_height;
					}
				}
			}
		}
	}

	// Update panning (works anywhere, not just in browser bounds)
	if (m_isPanning && IsMouseButtonDown(MOUSE_MIDDLE_BUTTON))
	{
		Vector2 mousePos = GetMousePosition();
		float deltaX = mousePos.x - m_panStartMouseX;
		float deltaY = mousePos.y - m_panStartMouseY;
		m_panX = m_panStartX + deltaX;
		m_panY = m_panStartY + deltaY;
	}

	// End panning
	if (m_isPanning && IsMouseButtonReleased(MOUSE_MIDDLE_BUTTON))
	{
		m_isPanning = false;
	}

	// Read scrollbar values for x, y, width, height
	int xScrollbarID = m_window->GetElementID("SPRITE_X");
	if (xScrollbarID != -1)
	{
		auto elem = gui->GetElement(xScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_x = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int yScrollbarID = m_window->GetElementID("SPRITE_Y");
	if (yScrollbarID != -1)
	{
		auto elem = gui->GetElement(yScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_y = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int widthScrollbarID = m_window->GetElementID("SPRITE_WIDTH");
	if (widthScrollbarID != -1)
	{
		auto elem = gui->GetElement(widthScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_width = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	int heightScrollbarID = m_window->GetElementID("SPRITE_HEIGHT");
	if (heightScrollbarID != -1)
	{
		auto elem = gui->GetElement(heightScrollbarID);
		if (elem && elem->m_Type == GUI_SCROLLBAR)
			m_height = static_cast<GuiScrollBar*>(elem.get())->m_Value;
	}

	// DON'T validate in real-time - let users temporarily set invalid values while adjusting sliders
	// Validation only happens when OK is clicked (line 365)

	// Update the SPRITE_SELECTION element with the current selection (clipped preview)
	int selectionID = m_window->GetElementID("SPRITE_SELECTION");
	if (selectionID != -1 && !m_filename.empty() && m_width > 0 && m_height > 0)
	{
		auto selectionElem = gui->GetElement(selectionID);
		if (selectionElem && selectionElem->m_Type == GUI_SPRITE)
		{
			auto selectionSprite = static_cast<GuiSprite*>(selectionElem.get());

			// Load the sprite texture
			std::string spritePath = GhostSerializer::GetBaseSpritePath() + m_filename;
			Texture* texture = g_ResourceManager->GetTexture(spritePath);

			if (texture)
			{
				// Create a sprite with the current rectangle
				auto sprite = std::make_shared<Sprite>(texture, m_x, m_y, m_width, m_height);
				selectionSprite->m_Sprite = sprite;

				// Update size to show the actual selected sprite at 1:1 scale
				selectionSprite->m_Width = static_cast<float>(m_width);
				selectionSprite->m_Height = static_cast<float>(m_height);
			}
		}
	}


	// Check for OK button click
	int okButtonID = m_window->GetElementID("OK_BUTTON");
	if (okButtonID != -1)
	{
		auto elem = gui->GetElement(okButtonID);
		if (elem && elem->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(elem.get());
			if (button->m_Clicked)
			{
				Log("OK button clicked!");
				ValidateAndApplyFallbacks();
				m_accepted = true;
				g_StateMachine->PopState();
				return;
			}
		}
	}

	// Check for Cancel button click
	int cancelButtonID = m_window->GetElementID("CANCEL_BUTTON");
	if (cancelButtonID != -1)
	{
		auto elem = gui->GetElement(cancelButtonID);
		if (elem && elem->m_Type == GUI_TEXTBUTTON)
		{
			auto button = static_cast<GuiTextButton*>(elem.get());
			if (button->m_Clicked)
			{
				Log("Cancel button clicked!");
				m_accepted = false;
				g_StateMachine->PopState();
				return;
			}
		}
	}
}

void SpritePickerState::Draw()
{
	// Draw a semi-transparent overlay behind the dialog
	int screenWidth = GetScreenWidth();
	int screenHeight = GetScreenHeight();
	DrawRectangle(0, 0, screenWidth, screenHeight, Color{0, 0, 0, 128});

	// Draw the dialog GUI
	m_window->Draw();

	Gui* gui = m_window->GetGui();
	if (!gui) return;

	// Draw zoomed spritesheet and selection rectangles over the browser area
	if (!m_filename.empty())
	{
		// Browser position (absolute screen coordinates, can be outside main panel)
		float browserX = m_browserBounds.x;
		float browserY = m_browserBounds.y;

		// Load the full texture
		std::string spritePath = GhostSerializer::GetBaseSpritePath() + m_filename;
		Texture* texture = g_ResourceManager->GetTexture(spritePath);

		if (texture)
		{
			// Calculate dimensions to fit the zoomed spritesheet
			float browserWidth = texture->width * m_zoom;
			float browserHeight = texture->height * m_zoom;

			// Draw the full zoomed spritesheet in the browser area
			Rectangle sourceRect = {0, 0, static_cast<float>(texture->width), static_cast<float>(texture->height)};
			Rectangle destRect = {
				browserX + m_panX,
				browserY + m_panY,
				browserWidth,
				browserHeight
			};

			// Clip to browser area
			BeginScissorMode(
				static_cast<int>(browserX),
				static_cast<int>(browserY),
				static_cast<int>(browserWidth),
				static_cast<int>(browserHeight)
			);

			DrawTexturePro(*texture, sourceRect, destRect, {0, 0}, 0.0f, WHITE);

			// Draw the current selection rectangle (semi-transparent magenta)
			if (m_width > 0 && m_height > 0)
			{
				Rectangle selectionRect = {
					browserX + m_panX + m_x * m_zoom,
					browserY + m_panY + m_y * m_zoom,
					m_width * m_zoom,
					m_height * m_zoom
				};
				DrawRectangleLinesEx(selectionRect, 2.0f, Color{255, 0, 255, 180});
			}

			// Draw the active drag selection rectangle (brighter magenta)
			if (m_isDragging)
			{
				int dragX = std::min(m_dragStartX, m_dragEndX);
				int dragY = std::min(m_dragStartY, m_dragEndY);
				int dragW = std::abs(m_dragEndX - m_dragStartX);
				int dragH = std::abs(m_dragEndY - m_dragStartY);

				Rectangle dragRect = {
					browserX + m_panX + dragX * m_zoom,
					browserY + m_panY + dragY * m_zoom,
					dragW * m_zoom,
					dragH * m_zoom
				};
				DrawRectangleLinesEx(dragRect, 3.0f, Color{255, 0, 255, 255});
			}

			EndScissorMode();
		}
	}

	// Draw red value text over scrollbars
	std::vector<std::string> scrollbarNames = {
		"SPRITE_X", "SPRITE_Y", "SPRITE_WIDTH", "SPRITE_HEIGHT"
	};

	for (const auto& scrollbarName : scrollbarNames)
	{
		int scrollbarID = m_window->GetElementID(scrollbarName);
		if (scrollbarID != -1)
		{
			auto scrollbarElement = gui->GetElement(scrollbarID);
			if (scrollbarElement && scrollbarElement->m_Type == GUI_SCROLLBAR)
			{
				auto scrollbar = static_cast<GuiScrollBar*>(scrollbarElement.get());

				// Calculate center position for text
				Rectangle bounds = scrollbar->GetBounds();
				int textX = static_cast<int>(gui->m_Pos.x + bounds.x + bounds.width / 2);
				int textY = static_cast<int>(gui->m_Pos.y + bounds.y + bounds.height / 2 - 8);

				// Draw the value in red
				std::string valueText = std::to_string(scrollbar->m_Value);
				DrawText(valueText.c_str(), textX - MeasureText(valueText.c_str(), 16) / 2, textY, 16, RED);
			}
		}
	}
}

void SpritePickerState::SetSprite(const std::string& filename, int x, int y, int width, int height)
{
	Log("SetSprite called with: filename=" + filename + " x=" + std::to_string(x) +
		" y=" + std::to_string(y) + " w=" + std::to_string(width) + " h=" + std::to_string(height));
	m_filename = filename;
	m_x = x;
	m_y = y;
	m_width = width;
	m_height = height;
	Log("SetSprite: member variables now: x=" + std::to_string(m_x) + " y=" + std::to_string(m_y) +
		" w=" + std::to_string(m_width) + " h=" + std::to_string(m_height));
}

void SpritePickerState::ValidateAndApplyFallbacks()
{
	// Use the shared sprite validation utility
	SpriteUtils::ValidateAndApplyFallbacks(
		m_filename,
		m_x,
		m_y,
		m_width,
		m_height,
		GhostSerializer::GetBaseSpritePath(),
		g_ResourceManager.get()
	);
}
