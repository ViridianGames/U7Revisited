///////////////////////////////////////////////////////////////////////////
//
// Name:     INPUT.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  The Input subsystem, which grabs DirectInput events from the
//           mouse and keyboard, matches them up with our in-game events,
//           and then sends the appropriate in-game event to whatever
//           subsystem needs to update itself based on it.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _INPUT_H_
#define _INPUT_H_

//#include <deque>
#include "Object.h"
#ifdef __APPLE__
#include <SDL2/SDL.h>
#else
#include "SDL.h"
#endif

enum InputKeys
{
	/* The keyboard syms have been cleverly chosen to map to ASCII */
	KEY_UNKNOWN = SDL_SCANCODE_UNKNOWN,

	KEY_a = SDL_SCANCODE_A,
	KEY_b = SDL_SCANCODE_B,
	KEY_c = SDL_SCANCODE_C,
	KEY_d = SDL_SCANCODE_D,
	KEY_e = SDL_SCANCODE_E,
	KEY_f = SDL_SCANCODE_F,
	KEY_g = SDL_SCANCODE_G,
	KEY_h = SDL_SCANCODE_H,
	KEY_i = SDL_SCANCODE_I,
	KEY_j = SDL_SCANCODE_J,
	KEY_k = SDL_SCANCODE_K,
	KEY_l = SDL_SCANCODE_L,
	KEY_m = SDL_SCANCODE_M,
	KEY_n = SDL_SCANCODE_N,
	KEY_o = SDL_SCANCODE_O,
	KEY_p = SDL_SCANCODE_P,
	KEY_q = SDL_SCANCODE_Q,
	KEY_r = SDL_SCANCODE_R,
	KEY_s = SDL_SCANCODE_S,
	KEY_t = SDL_SCANCODE_T,
	KEY_u = SDL_SCANCODE_U,
	KEY_v = SDL_SCANCODE_V,
	KEY_w = SDL_SCANCODE_W,
	KEY_x = SDL_SCANCODE_X,
	KEY_y = SDL_SCANCODE_Y,
	KEY_z = SDL_SCANCODE_Z,

	KEY_1 = SDL_SCANCODE_1,
	KEY_2 = SDL_SCANCODE_2,
	KEY_3 = SDL_SCANCODE_3,
	KEY_4 = SDL_SCANCODE_4,
	KEY_5 = SDL_SCANCODE_5,
	KEY_6 = SDL_SCANCODE_6,
	KEY_7 = SDL_SCANCODE_7,
	KEY_8 = SDL_SCANCODE_8,
	KEY_9 = SDL_SCANCODE_9,
	KEY_0 = SDL_SCANCODE_0,

	KEY_RETURN = SDL_SCANCODE_RETURN,
	KEY_ESCAPE = SDL_SCANCODE_ESCAPE,
	KEY_BACKSPACE = SDL_SCANCODE_BACKSPACE,
	KEY_TAB = SDL_SCANCODE_TAB,
	KEY_SPACE = SDL_SCANCODE_SPACE,

	KEY_MINUS = SDL_SCANCODE_MINUS,
	KEY_EQUALS = SDL_SCANCODE_EQUALS,
	KEY_LEFTBRACKET = SDL_SCANCODE_LEFTBRACKET,
	KEY_RIGHTBRACKET = SDL_SCANCODE_RIGHTBRACKET,
	KEY_BACKSLASH = SDL_SCANCODE_BACKSLASH,

	KEY_SEMICOLON = SDL_SCANCODE_SEMICOLON,
	KEY_APOSTROPHE = SDL_SCANCODE_APOSTROPHE,
	KEY_GRAVE = SDL_SCANCODE_GRAVE,

	KEY_COMMA = SDL_SCANCODE_COMMA,
	KEY_PERIOD = SDL_SCANCODE_PERIOD,
	KEY_SLASH = SDL_SCANCODE_SLASH,

	KEY_CAPSLOCK = SDL_SCANCODE_CAPSLOCK,

	KEY_F1 = SDL_SCANCODE_F1,
	KEY_F2 = SDL_SCANCODE_F2,
	KEY_F3 = SDL_SCANCODE_F3,
	KEY_F4 = SDL_SCANCODE_F4,
	KEY_F5 = SDL_SCANCODE_F5,
	KEY_F6 = SDL_SCANCODE_F6,
	KEY_F7 = SDL_SCANCODE_F7,
	KEY_F8 = SDL_SCANCODE_F8,
	KEY_F9 = SDL_SCANCODE_F9,
	KEY_F10 = SDL_SCANCODE_F10,
	KEY_F11 = SDL_SCANCODE_F11,
	KEY_F12 = SDL_SCANCODE_F12,

	KEY_PRINTSCREEN = SDL_SCANCODE_PRINTSCREEN,
	KEY_SCROLLOCK = SDL_SCANCODE_SCROLLLOCK,
	KEY_PAUSE = SDL_SCANCODE_PAUSE,
	KEY_INSERT = SDL_SCANCODE_INSERT,

	KEY_HOME = SDL_SCANCODE_HOME,
	KEY_PAGEUP = SDL_SCANCODE_PAGEUP,
	KEY_DELETE = SDL_SCANCODE_DELETE,
	KEY_END = SDL_SCANCODE_END,
	KEY_PAGEDOWN = SDL_SCANCODE_PAGEDOWN,
	KEY_RIGHT = SDL_SCANCODE_RIGHT,
	KEY_LEFT = SDL_SCANCODE_LEFT,
	KEY_DOWN = SDL_SCANCODE_DOWN,
	KEY_UP = SDL_SCANCODE_UP,

	KEY_NUMLOCK = SDL_SCANCODE_NUMLOCKCLEAR,

	KEY_KP_DIVIDE = SDL_SCANCODE_KP_DIVIDE,
	KEY_KP_MULTIPLY = SDL_SCANCODE_KP_MULTIPLY,
	KEY_KP_MINUS = SDL_SCANCODE_KP_MINUS,
	KEY_KP_PLUS = SDL_SCANCODE_KP_PLUS,
	KEY_KP_ENTER = SDL_SCANCODE_KP_ENTER,
	KEY_KP1 = SDL_SCANCODE_KP_1,
	KEY_KP2 = SDL_SCANCODE_KP_2,
	KEY_KP3 = SDL_SCANCODE_KP_3,
	KEY_KP4 = SDL_SCANCODE_KP_4,
	KEY_KP5 = SDL_SCANCODE_KP_5,
	KEY_KP6 = SDL_SCANCODE_KP_6,
	KEY_KP7 = SDL_SCANCODE_KP_7,
	KEY_KP8 = SDL_SCANCODE_KP_8,
	KEY_KP9 = SDL_SCANCODE_KP_9,
	KEY_KP0 = SDL_SCANCODE_KP_0,
	KEY_KP_PERIOD = SDL_SCANCODE_KP_PERIOD,
	KEY_KP_EQUALS = SDL_SCANCODE_KP_EQUALS,

	KEY_RSHIFT = SDL_SCANCODE_RSHIFT,
	KEY_LSHIFT = SDL_SCANCODE_LSHIFT,
	KEY_RCTRL = SDL_SCANCODE_RCTRL,
	KEY_LCTRL = SDL_SCANCODE_LCTRL,
	KEY_RALT = SDL_SCANCODE_RALT,
	KEY_LALT = SDL_SCANCODE_LALT,

	KEY_LAST
};

enum InputControllerButtons
{
	BUTTON_NOBUTTON = SDL_CONTROLLER_BUTTON_INVALID,
	BUTTON_A = SDL_CONTROLLER_BUTTON_A,
	BUTTON_B = SDL_CONTROLLER_BUTTON_B,
	BUTTON_X = SDL_CONTROLLER_BUTTON_X,
	BUTTON_Y = SDL_CONTROLLER_BUTTON_Y,
	BUTTON_BACK = SDL_CONTROLLER_BUTTON_BACK,
	BUTTON_GUIDE = SDL_CONTROLLER_BUTTON_GUIDE,
	BUTTON_START = SDL_CONTROLLER_BUTTON_START,
	BUTTON_LEFTSTICK = SDL_CONTROLLER_BUTTON_LEFTSTICK,
	BUTTON_RIGHTSTICK = SDL_CONTROLLER_BUTTON_RIGHTSTICK,
	BUTTON_LEFTSHOULDER = SDL_CONTROLLER_BUTTON_LEFTSHOULDER,
	BUTTON_RIGHTSHOULDER = SDL_CONTROLLER_BUTTON_RIGHTSHOULDER,
	BUTTON_DPAD_UP = SDL_CONTROLLER_BUTTON_DPAD_UP,
	BUTTON_DPAD_DOWN = SDL_CONTROLLER_BUTTON_DPAD_DOWN,
	BUTTON_DPAD_LEFT = SDL_CONTROLLER_BUTTON_DPAD_LEFT,
	BUTTON_DPAD_RIGHT = SDL_CONTROLLER_BUTTON_DPAD_RIGHT,
	BUTTON_LEFTTRIGGER,
	BUTTON_RIGHTTRIGGER,
	BUTTON_LAST
};

class Input : public Object
{

public:
	Input();

	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw() {};

	// Keyboard

	int  GetLastKeyPressed();
	bool WasKeyPressed(unsigned int key) { return(m_LastKeyboardState[key] && !m_KeyboardState[key]); }  //  Returns true when a key is released.
	bool IsKeyDown(unsigned int key) { return (m_KeyboardState[key] != 0); } //  Returns true as long as a key is down.
	bool JustPressed(unsigned int key) { return(!m_LastKeyboardState[key] && m_KeyboardState[key]); } // Returns true only on the first frame a key is down
	bool WasAnyKeyPressed();  //  Returns true on any keyboard activity this frame.
	bool WasAnyKeyJustPressed();  //  Returns true on any keyboard activity this frame.

	//  Mouse

	bool WasLButtonClicked() { return m_WasLeftButtonClicked; }  //  These functions return true when the corresponding mouse button is released.
	bool WasRButtonClicked() { return m_WasRightButtonClicked; }
	bool WasMButtonClicked() { return m_WasMiddleButtonClicked; }

	bool WasLButtonJustClicked() { return m_IsLeftButtonDown && !m_WasLeftButtonDown; }
	bool WasRButtonJustClicked() { return m_IsRightButtonDown && !m_WasRightButtonDown; }
	bool WasMButtonJustClicked() { return m_IsMiddleButtonDown && !m_WasMiddleButtonDown; }

	//  These functions return true when the corresponding mouse button is released inside the given quad.
	bool WasLButtonClickedInRegion(int x, int y, int endx, int endy) { return m_WasLeftButtonClicked && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
	bool WasRButtonClickedInRegion(int x, int y, int endx, int endy) { return m_WasRightButtonClicked && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
	bool WasMButtonClickedInRegion(int x, int y, int endx, int endy) { return m_WasMiddleButtonClicked && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }

	//  These functions return true if the corresponding mouse button was pushed down this update inside the given quad.
	bool WasLButtonJustClickedInRegion(int x, int y, int endx, int endy) { return m_IsLeftButtonDown && !m_WasLeftButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
	bool WasRButtonJustClickedInRegion(int x, int y, int endx, int endy) { return m_IsRightButtonDown && !m_WasRightButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
	bool WasMButtonJustClickedInRegion(int x, int y, int endx, int endy) { return m_IsMiddleButtonDown && !m_WasMiddleButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }

	//  These functions return true when the corresponding mouse button is held down inside the given quad.
	bool IsLButtonDownInRegion(int x, int y, int endx, int endy) { return m_IsLeftButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
	bool IsRButtonDownInRegion(int x, int y, int endx, int endy) { return m_IsRightButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
	bool IsMButtonDownInRegion(int x, int y, int endx, int endy) { return m_IsMiddleButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }

	//  These functions handle mouse dragging (that is, pressing a button and then moving the mouse with the button down)
	bool WasDragStartedInRegion(int x, int y, int endx, int endy) { return (m_DownX >= x && m_DownX <= endx) && (m_DownY >= y && m_DownY <= endy); }

	bool IsLDragging();
	bool IsRDragging();
	bool IsMDragging();

	bool WasLDragging();
	bool WasRDragging();
	bool WasMDragging();

	//  The functions handle the mouse wheel
	bool MouseWheelUp() { return (m_LastMouseZ > m_MouseZ); }
	bool MouseWheelDown() { return (m_LastMouseZ < m_MouseZ); }

	//  This function returns true only if the mouse is inside the given rect with no interaction (useful for "hot" states)
	bool IsMouseInRegion(int x, int y, int endx, int endy) {
		return !m_WasLeftButtonClicked && !m_WasRightButtonClicked && !m_WasMiddleButtonClicked && !m_IsLeftButtonDown && !m_IsRightButtonDown && !m_IsMiddleButtonDown &&
			(m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy);
	}

	//  This version doesn't care about interaction and just does the bounds check.
	bool IsMouseInRegionRaw(int x, int y, int endx, int endy) {
		return (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy);
	}

	//  Get the current mouse ray, it's used for visibility testing.
	void GetMouseRay(glm::vec3& origin, glm::vec3& pos);

	//  Controller
	bool  IsControllerConnected();
	bool  WasControllerJustAdded() { return m_WasControllerJustAdded; }
	bool  WasControllerJustRemoved() { return m_WasControllerJustRemoved; }
	bool  JoyButtonIsDown(int button) { if (button == -1) return false; else return m_ControllerState[button]; }
	bool  JoyButtonJustPressed(int button) { if (button == -1) return false; else return (!m_LastControllerState[button] && m_ControllerState[button]); }
	bool  JoyButtonWasPressed(int button) { if (button == -1) return false; else  return (m_LastControllerState[button] && !m_ControllerState[button]); }
	int   GetLastButtonPressed();
	//  This can be called for both "pressed" and "down" states. For "pressed",
	//  it returns the duration of the last button press.  For "down", it returns
	//  how long the button has been held down.  Result is in milliseconds.
	unsigned int JoyButtonPressDuration(unsigned int button) { return m_ControllerDurations[button]; }

	//  Axes run from -1 to 1.  Triggers run from 0 to 1;
	float JoyLXAxis() { return m_LXAxis; }
	float JoyLYAxis() { return m_LYAxis; }
	float JoyRXAxis() { return m_RXAxis; }
	float JoyRYAxis() { return m_RYAxis; }
	float JoyLTrigger() { return m_LTrigger; }
	float JoyRTrigger() { return m_RTrigger; }

	void DumpInput();

	int GetControlType() { return m_ControlType; }
	bool DidControlTypeChange() { return m_LastControlType != m_ControlType; }

	int m_DownX, m_DownY;
	int m_MouseX, m_MouseY, m_MouseZ;
	int m_LastMouseZ;

	bool m_IsKeyDown,
		m_IsLeftButtonDown,
		m_IsRightButtonDown,
		m_IsMiddleButtonDown,
		m_WasLeftButtonDown,
		m_WasRightButtonDown,
		m_WasMiddleButtonDown,
		m_WasLeftButtonClicked,
		m_WasRightButtonClicked,
		m_WasMiddleButtonClicked,
		m_IsLeftDragging,
		m_IsRightDragging,
		m_IsMiddleDragging,
		m_WasLeftDragging,
		m_WasRightDragging,
		m_WasMiddleDragging,
		m_IsControllerConnected,
		m_WasControllerJustAdded,
		m_WasControllerJustRemoved;

	Uint8* m_KeyboardState;
	Uint8* m_LastKeyboardState;


	unsigned char m_MouseState;

	glm::vec3 m_RayOrigin;
	glm::vec3 m_RayDirection;


	SDL_GameController* m_Controller;
	Uint8* m_ControllerState;
	Uint8* m_LastControllerState;
	unsigned int* m_ControllerDurations;
	float m_LXAxis;
	float m_LYAxis;
	float m_RXAxis;
	float m_RYAxis;
	float m_LTrigger;
	float m_RTrigger;

	enum ControlTypes
	{
		CTRL_KEYBOARD = 0, // Actually mouse and keyboard but I don't feel like typing CTRL_MOUSEANDKEYBOARD over and over
		CTRL_CONTROLLER,
		CTRL_LASTINPUTTYPE
	};

	int m_ControlType = CTRL_KEYBOARD; // How the game is currently being controlled: mouse and keyboard or controller.
	int m_LastControlType = CTRL_KEYBOARD;

	std::unordered_map<int, std::string> m_KeyNames =
	{
	   {KEY_UNKNOWN, "None" },
	   {KEY_a, "A"},
	   {KEY_b, "B"},
	   {KEY_c, "C"},
	   {KEY_d, "D"},
	   {KEY_e, "E"},
	   {KEY_f, "F"},
	   {KEY_g, "G"},
	   {KEY_h, "H"},
	   {KEY_i, "I"},
	   {KEY_j, "J"},
	   {KEY_k, "K"},
	   {KEY_l, "L"},
	   {KEY_m, "M"},
	   {KEY_n, "N"},
	   {KEY_o, "O"},
	   {KEY_p, "P"},
	   {KEY_q, "Q"},
	   {KEY_r, "R"},
	   {KEY_s, "S"},
	   {KEY_t, "T"},
	   {KEY_u, "U"},
	   {KEY_v, "V"},
	   {KEY_w, "W"},
	   {KEY_x, "X"},
	   {KEY_y, "Y"},
	   {KEY_z, "Z"},
	   {KEY_1, "1"},
	   {KEY_2, "2"},
	   {KEY_3, "3"},
	   {KEY_4, "4"},
	   {KEY_5, "5"},
	   {KEY_6, "6"},
	   {KEY_7, "7"},
	   {KEY_8, "8"},
	   {KEY_9, "9"},
	   {KEY_0, "0"},
	   {KEY_RETURN, "Enter"},
	   {KEY_ESCAPE, "Esc"},
	   {KEY_BACKSPACE, "Backspace"},
	   {KEY_TAB, "Tab"},
	   {KEY_SPACE, "Space"},
	   {KEY_MINUS, "-"},
	   {KEY_EQUALS, "="},
	   {KEY_LEFTBRACKET, "["},
	   {KEY_RIGHTBRACKET, "]"},
	   {KEY_BACKSLASH, "\\"},
	   {KEY_SEMICOLON, ";"},
	   {KEY_APOSTROPHE, "'"},
	   {KEY_GRAVE, "`"},
	   {KEY_COMMA, ","},
	   {KEY_PERIOD, "."},
	   {KEY_SLASH, "/"},
	   {KEY_CAPSLOCK, "CapsLock"},
	   {KEY_F1, "F1"},
	   {KEY_F2, "F2"},
	   {KEY_F3, "F3"},
	   {KEY_F4, "F4"},
	   {KEY_F5, "F5"},
	   {KEY_F6, "F6"},
	   {KEY_F7, "F7"},
	   {KEY_F8, "F8"},
	   {KEY_F9, "F9"},
	   {KEY_F10, "F10"},
	   {KEY_F11, "F11"},
	   {KEY_F12, "F12"},
	   {KEY_PRINTSCREEN, "Print Screen"},
	   {KEY_SCROLLOCK, "Scroll Lock"},
	   {KEY_PAUSE, "Pause"},
	   {KEY_INSERT, "Ins"},
	   {KEY_HOME, "Home"},
	   {KEY_PAGEUP, "PageUp"},
	   {KEY_DELETE, "Del"},
	   {KEY_END, "End"},
	   {KEY_PAGEDOWN, "PageDown"},
	   {KEY_RIGHT, "Right"},
	   {KEY_LEFT, "Left"},
	   {KEY_DOWN, "Down"},
	   {KEY_UP, "Up"},
	   {KEY_NUMLOCK, "NumLock"},
	   {KEY_KP_DIVIDE, "KP /"},
	   {KEY_KP_MULTIPLY, "KP *"},
	   {KEY_KP_MINUS, "KP -"},
	   {KEY_KP_PLUS, "KP +"},
	   {KEY_KP_ENTER, "KP Enter"},
	   {KEY_KP1, "KP 1"},
	   {KEY_KP2, "KP 2"},
	   {KEY_KP3, "KP 3"},
	   {KEY_KP4, "KP 4"},
	   {KEY_KP5, "KP 5"},
	   {KEY_KP6, "KP 6"},
	   {KEY_KP7, "KP 7"},
	   {KEY_KP8, "KP 8"},
	   {KEY_KP9, "KP 9"},
	   {KEY_KP0, "KP 0"},
	   {KEY_KP_PERIOD, "KP ."},
	   {KEY_KP_EQUALS, "KP ="},
	   {KEY_RSHIFT, "RShift"},
	   {KEY_LSHIFT, "LShift"},
	   {KEY_RCTRL, "RCtrl"},
	   {KEY_LCTRL, "LCtrl"},
	   {KEY_RALT, "RAlt"},
	   {KEY_LALT, "LAlt"}
	};

	std::unordered_map<int, std::string> m_ControllerNames =
	{
	   { BUTTON_NOBUTTON, " "},
	   { BUTTON_A, std::string(1, SC_A_BUTTON) },
	   { BUTTON_B, std::string(1, SC_B_BUTTON) },
	   { BUTTON_X, std::string(1, SC_X_BUTTON) },
	   { BUTTON_Y, std::string(1, SC_Y_BUTTON) },
	   { BUTTON_LEFTSTICK, std::string(1, SC_L3_BUTTON) },
	   { BUTTON_RIGHTSTICK, std::string(1, SC_R3_BUTTON) },
	   { BUTTON_LEFTSHOULDER, std::string(1, SC_L_BUMPER) },
	   { BUTTON_RIGHTSHOULDER, std::string(1, SC_R_BUMPER) },
	   { BUTTON_LEFTTRIGGER, std::string(1, SC_L_TRIGGER) },
	   { BUTTON_RIGHTTRIGGER, std::string(1, SC_R_TRIGGER) },
	   { BUTTON_DPAD_UP, std::string(1, SC_DPAD_UP) },
	   { BUTTON_DPAD_DOWN, std::string(1, SC_DPAD_DOWN) },
	   { BUTTON_DPAD_LEFT, std::string(1, SC_DPAD_LEFT) },
	   { BUTTON_DPAD_RIGHT, std::string(1, SC_DPAD_RIGHT) }
	};

};

#endif