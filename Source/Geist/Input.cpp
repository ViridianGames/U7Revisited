#include "Globals.h"
#include <deque>
#include <math.h>
#ifdef __APPLE__
#include <SDL2/SDL.h>
#else
#include "SDL.h"
#endif

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <cstring>

using namespace std;

Input::Input()
{

}

void Input::Init(const std::string& configfile)
{
	Log("Starting Input::Init()");

	m_MouseX = g_Display->GetWidth() / 2;
	m_MouseY = g_Display->GetHeight() / 2;
	m_DownX = m_MouseX;
	m_DownY = m_MouseY;

	m_MouseZ = 0;
	m_IsKeyDown = false;
	m_IsLeftButtonDown = false;
	m_IsRightButtonDown = false;
	m_IsMiddleButtonDown = false;
	m_WasLeftButtonDown = false;
	m_WasRightButtonDown = false;
	m_WasMiddleButtonDown = false;
	m_WasLeftButtonClicked = false;
	m_WasRightButtonClicked = false;
	m_WasMiddleButtonClicked = false;
	m_IsLeftDragging = false;
	m_IsRightDragging = false;
	m_IsMiddleDragging = false;
	m_WasControllerJustAdded = false;
	m_WasControllerJustRemoved = false;

	int numberofkeys;
	const Uint8* keyboardState = SDL_GetKeyboardState(&numberofkeys);
	m_KeyboardState = new unsigned char[numberofkeys];
	m_LastKeyboardState = new unsigned char[numberofkeys];

	memset(m_KeyboardState, 0, sizeof(unsigned char) * numberofkeys);
	memset(m_LastKeyboardState, 0, sizeof(unsigned char) * numberofkeys);

	//  Controller stuff! SDL2 doesn't detect controllers that are already connected automatically, so we begin by iterating over every possible controller until we find one we can use.
	m_LXAxis = 0;
	m_LYAxis = 0;
	m_RXAxis = 0;
	m_RYAxis = 0;
	m_LTrigger = 0;
	m_RTrigger = 0;

	m_ControllerState = new unsigned char[BUTTON_LAST];
	m_LastControllerState = new unsigned char[BUTTON_LAST];
	m_ControllerDurations = new unsigned int[BUTTON_LAST];
	memset(m_ControllerState, 0, sizeof(unsigned char) * BUTTON_LAST);
	memset(m_LastControllerState, 0, sizeof(unsigned char) * BUTTON_LAST);

	m_Controller = nullptr;
	m_IsControllerConnected = false;
	for (int i = 0; i < SDL_NumJoysticks(); ++i)
	{
		if (SDL_IsGameController(i))
		{
			m_Controller = SDL_GameControllerOpen(i);
			if (m_Controller)
			{
				m_IsControllerConnected = true;
				m_ControlType = CTRL_CONTROLLER;
				break;  // We only need the first active controller.
			}
		}
	}

	Log("Done With Input::Init()");
}


void Input::Shutdown()
{
	delete[] m_KeyboardState;
	delete[] m_LastKeyboardState;
	delete[] m_ControllerState;
	delete[] m_LastControllerState;
	delete[] m_ControllerDurations;

}

void Input::Update()
{
	m_WasControllerJustAdded = false;
	m_WasControllerJustRemoved = false;
	m_LastMouseZ = m_MouseZ;

	//  Most of our input is done through direct access of the connected peripherals.
	//  This is most compatible with our update-driven, rather than event-drive,
	//  gameplay loop.  But there are a couple things that have to be done with
	//  events...so we do them here.
	SDL_Event event;
	while (SDL_PollEvent(&event))
	{
		switch (event.type)
		{
			//  Mouse stuff
		case SDL_MOUSEWHEEL:
		{
			if (event.wheel.y > 0)
			{
				++m_MouseZ;
			}
			if (event.wheel.y < 0)
			{
				--m_MouseZ;
			}
		}
		break;

		//  Controller stuff
		case SDL_CONTROLLERDEVICEADDED:
		{
			if (!m_IsControllerConnected)
			{
				m_Controller = nullptr;
				m_IsControllerConnected = false;
				for (int i = 0; i < SDL_NumJoysticks(); ++i)
				{
					if (SDL_IsGameController(i))
					{
						m_Controller = SDL_GameControllerOpen(i);
						if (m_Controller)
						{
							m_IsControllerConnected = true;
							m_WasControllerJustAdded = true;
							break;  // We only need the first active controller.
						}
					}
				}
			}
		}
		break;

		case SDL_CONTROLLERDEVICEREMOVED:
		{
			m_Controller = nullptr;
			m_IsControllerConnected = false;
			m_WasControllerJustRemoved = true;
			m_ControlType = CTRL_KEYBOARD;
		}
		break;

		//  General stuff:
		case SDL_QUIT:
		{
			g_Engine->m_Done = true;
		}
		break;

		default:
		{

		}
		break;
		}
	}

	int numberofkeys;
	const Uint8* keyboardState = SDL_GetKeyboardState(&numberofkeys);

	memcpy(m_LastKeyboardState, m_KeyboardState, sizeof(unsigned char) * numberofkeys);
	memcpy(m_KeyboardState, SDL_GetKeyboardState(NULL), sizeof(unsigned char) * numberofkeys);

	m_IsKeyDown = false;
	for (int i = 0; i < 255; ++i)
	{
		m_IsKeyDown |= (m_KeyboardState[i] != 0);
	}

	m_WasLeftButtonClicked = false;
	m_WasRightButtonClicked = false;

	unsigned char flags = SDL_GetMouseState(&m_MouseX, &m_MouseY);
	m_MouseState = flags;

	m_WasLeftButtonDown = m_IsLeftButtonDown;
	m_WasRightButtonDown = m_IsRightButtonDown;
	m_WasMiddleButtonDown = m_IsMiddleButtonDown;

	m_IsLeftButtonDown = ((flags & SDL_BUTTON(1)) != 0);
	m_IsRightButtonDown = ((flags & SDL_BUTTON(3)) != 0);
	m_IsMiddleButtonDown = ((flags & SDL_BUTTON(2)) != 0);

	//  Clicks
	if (m_WasLeftButtonDown && !m_IsLeftButtonDown)
	{
		m_WasLeftButtonClicked = true;
		m_IsLeftDragging = false;
	}
	else
		m_WasLeftButtonClicked = false;

	if (m_WasRightButtonDown && !m_IsRightButtonDown)
	{
		m_WasRightButtonClicked = true;
		m_IsRightDragging = false;
	}
	else
		m_WasRightButtonClicked = false;

	if (m_WasMiddleButtonDown && !m_IsMiddleButtonDown)
	{
		m_WasMiddleButtonClicked = true;
		m_IsMiddleDragging = false;
	}
	else
		m_WasMiddleButtonClicked = false;

	//  We just clicked down a mouse button.
	if (!m_WasLeftButtonDown && m_IsLeftButtonDown ||
		!m_WasRightButtonDown && m_IsRightButtonDown ||
		!m_WasMiddleButtonDown && m_IsMiddleButtonDown
		)
	{
		m_DownX = m_MouseX;
		m_DownY = m_MouseY;
	}
	//  We are still holding down a mouse button.
	else
	{
		if (abs(m_MouseX - m_DownX) > 3)
		{
			m_WasLeftDragging = m_IsLeftDragging;
			if (m_IsLeftButtonDown)
				m_IsLeftDragging = true;

			m_WasRightDragging = m_IsRightDragging;
			if (m_IsRightButtonDown)
				m_IsRightDragging = true;

			m_WasMiddleDragging = m_IsMiddleDragging;
			if (m_IsMiddleButtonDown)
				m_IsMiddleDragging = true;
		}
	}

	// Make the ray   
	float projX;
	float projY;
	float projZ = 1.0f;

	// Convert x from 0 - m_HRes to -1 to 1

	projX = (1 - (float(g_Input->m_MouseX) * 2 / float(g_Display->GetWidth()))) / g_Display->GetProjectionMatrix()[0][0];
	projY = ((float(g_Input->m_MouseY) * 2 / float(g_Display->GetHeight())) - 1) / g_Display->GetProjectionMatrix()[1][1];


	glm::vec4 rayOrigin = glm::vec4(0, 0, 0, 1);
	glm::vec4 rayDirection = glm::vec4(projX, projY, projZ, 0);
	rayDirection = glm::normalize(rayDirection);

	glm::mat4 inv = glm::inverse(g_Display->GetModelViewMatrix());

	rayOrigin = inv * rayOrigin;
	rayDirection = inv * rayDirection;

	rayDirection = glm::normalize(rayDirection);

	m_RayOrigin = glm::vec3(rayOrigin);
	m_RayDirection = glm::vec3(rayDirection);

	//  Update all controller button states
	memcpy(m_LastControllerState, m_ControllerState, sizeof(unsigned char) * BUTTON_LAST);

	if (m_IsControllerConnected)
	{
		//  Buttons!
		for (unsigned int i = BUTTON_A; i <= BUTTON_DPAD_RIGHT; ++i)
		{
			m_ControllerState[i] = SDL_GameControllerGetButton(m_Controller, SDL_GameControllerButton(i));
			if (m_ControllerState[i] && !m_LastControllerState[i]) // Button press started this update
			{
				m_ControllerDurations[i] = g_Engine->LastUpdateInMS();
			}
			else if (m_ControllerDurations[i]) //  Still holding down the button
			{
				m_ControllerDurations[i] += g_Engine->LastUpdateInMS();
			}
		}

		//  Analog sticks and triggers!

		m_LXAxis = float(SDL_GameControllerGetAxis(m_Controller, SDL_CONTROLLER_AXIS_LEFTX)) / 32767.0f;
		m_LYAxis = float(SDL_GameControllerGetAxis(m_Controller, SDL_CONTROLLER_AXIS_LEFTY)) / 32767.0f;
		m_RXAxis = float(SDL_GameControllerGetAxis(m_Controller, SDL_CONTROLLER_AXIS_RIGHTX)) / 32767.0f;
		m_RYAxis = float(SDL_GameControllerGetAxis(m_Controller, SDL_CONTROLLER_AXIS_RIGHTY)) / 32767.0f;

		m_LTrigger = float(SDL_GameControllerGetAxis(m_Controller, SDL_CONTROLLER_AXIS_TRIGGERLEFT)) / 32767.0f;
		m_RTrigger = float(SDL_GameControllerGetAxis(m_Controller, SDL_CONTROLLER_AXIS_TRIGGERRIGHT)) / 32767.0f;

		m_LastControllerState[BUTTON_LEFTTRIGGER] = m_ControllerState[BUTTON_LEFTTRIGGER];
		if (m_LTrigger > 0)
			m_ControllerState[BUTTON_LEFTTRIGGER] = 1;
		else
			m_ControllerState[BUTTON_LEFTTRIGGER] = 0;

		if (m_RTrigger > 0)
			m_ControllerState[BUTTON_RIGHTTRIGGER] = 1;
		else
			m_ControllerState[BUTTON_RIGHTTRIGGER] = 0;


	}
	else // See if a controller was connected this update
	{

	}

	//  Finally, check stats and see what mode we're in.
	m_LastControlType = m_ControlType;
	if (m_ControlType == CTRL_KEYBOARD) // See if we need to switch to controller
	{
		for (int i = 0; i < BUTTON_LAST; ++i)
		{
			if (m_ControllerState[i] != 0)
			{
				m_ControlType = CTRL_CONTROLLER;
				break;
			}
		}
	}
	else if (m_ControlType == CTRL_CONTROLLER)
	{
		for (int i = 0; i < KEY_LAST; ++i)
		{
			if (m_KeyboardState[i] != 0)
			{
				m_ControlType = CTRL_KEYBOARD;
				break;
			}
		}
	}
}

bool Input::WasAnyKeyPressed()
{
	for (int i = 0; i < 256; ++i)
	{
		if (m_LastKeyboardState[i] && !m_KeyboardState[i])
		{
			return true;
		}
	}
	return false;
}

bool Input::WasAnyKeyJustPressed()
{
	for (int i = 0; i < 256; ++i)
	{
		if (!m_LastKeyboardState[i] && m_KeyboardState[i])
		{
			return true;
		}
	}
	return false;
}

int Input::GetLastKeyPressed()
{
	for (int i = 0; i < 256; ++i)
	{
		if (m_LastKeyboardState[i] && !m_KeyboardState[i])
		{
			return i;
		}
	}
	return -1;
}

int Input::GetLastButtonPressed()
{
	for (int i = 0; i < BUTTON_LAST; ++i)
	{
		if (m_LastControllerState[i] && !m_ControllerState[i])
		{
			return i;
		}
	}
	return -1;
}

void Input::DumpInput() //  Dumps all current input, useful when you've captured something that you don't want anything else to use when you're done with.
{
	m_IsKeyDown = false;
	m_IsLeftButtonDown = false;
	m_IsRightButtonDown = false;
	m_IsMiddleButtonDown = false;
	m_WasLeftButtonDown = false;
	m_WasRightButtonDown = false;
	m_WasMiddleButtonDown = false;
	m_WasLeftButtonClicked = false;
	m_WasRightButtonClicked = false;
	m_WasMiddleButtonClicked = false;
	m_IsLeftDragging = false;
	m_IsRightDragging = false;
	m_IsMiddleDragging = false;
	m_WasLeftDragging = false;
	m_WasRightDragging = false;
	m_WasMiddleDragging = false;
	m_IsControllerConnected = false;

	memset(m_KeyboardState, 0, sizeof(char) * 256);
	memset(m_LastKeyboardState, 0, sizeof(char) * 256);
	memset(m_ControllerState, 0, sizeof(char) * BUTTON_LAST);
	memset(m_LastControllerState, 0, sizeof(char) * BUTTON_LAST);
	memset(m_ControllerDurations, 0, sizeof(unsigned int) * BUTTON_LAST);

	m_LXAxis = 0;
	m_LYAxis = 0;
	m_RXAxis = 0;
	m_RYAxis = 0;
	m_LTrigger = 0;
	m_RTrigger = 0;
}

bool Input::WasLDragging()
{
	return m_WasLeftDragging;
}

bool Input::IsLDragging()
{
	return m_IsLeftDragging;
}

bool Input::WasRDragging()
{
	return m_WasRightDragging;
}

bool Input::IsRDragging()
{
	return m_IsRightDragging;
}

bool Input::WasMDragging()
{
	return m_WasMiddleDragging;
}

bool Input::IsMDragging()
{
	return m_IsMiddleDragging;
}

void Input::GetMouseRay(glm::vec3& origin, glm::vec3& pos)
{
	origin = m_RayOrigin;
	pos = m_RayDirection;

}

bool Input::IsControllerConnected()
{
	return false;
}