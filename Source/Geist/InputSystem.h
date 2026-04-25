///////////////////////////////////////////////////////////////////////////
//
// Name:     InputSystem.h
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  The InputSystem subsystem, which uses Raylib's direct memory
// access, but keeps track of the system's state to properly parse input.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _INPUTSYSTEM_H_
#define _INPUTSYSTEM_H_

#include "Object.h"
#include "raylib.h"
#include <memory>
#include <unordered_map>
#include <vector>
#include <string>

class InputSystem : public Object
{

public:
   InputSystem();

   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   // Keyboard
   void UpdateKeyboardState();

   int  GetLastKeyPressed();
   bool WasKeyPressed(unsigned int key) { return(m_LastKeyboardState[key] && !m_KeyboardState[key]); }  //  Returns true when a key is released.
   bool IsKeyDown(unsigned int key) { return (m_KeyboardState[key] != 0); } //  Returns true as long as a key is down.
   bool JustPressed(unsigned int key) { return(!m_LastKeyboardState[key] && m_KeyboardState[key]); } // Returns true only on the first frame a key is down
   bool WasAnyKeyPressed();  //  Returns true on any keyboard activity this frame.
   bool WasAnyKeyJustPressed();  //  Returns true on any keyboard activity this frame.

   //  Mouse
   void UpdateMouseState();

   bool WasLButtonClicked() { return m_WasLeftButtonClicked; }  //  These functions return true when the corresponding mouse button is released.
   bool WasRButtonClicked() { return m_WasRightButtonClicked; }
   bool WasMButtonClicked() { return m_WasMiddleButtonClicked; }

   bool WasLButtonJustClicked() { return m_IsLeftButtonDown && !m_WasLeftButtonDown; }
   bool WasRButtonJustClicked() { return m_IsRightButtonDown && !m_WasRightButtonDown; }
   bool WasMButtonJustClicked() { return m_IsMiddleButtonDown && !m_WasMiddleButtonDown; }

   //  These functions return true when the corresponding mouse button is released inside the given quad.
   bool WasLButtonClickedInRegion(int x, int y, int endx, int endy) { return m_WasLeftButtonClicked && IsMouseInRegion(x, y, endx, endy); }
   bool WasRButtonClickedInRegion(int x, int y, int endx, int endy) { return m_WasRightButtonClicked && IsMouseInRegion(x, y, endx, endy); }
   bool WasMButtonClickedInRegion(int x, int y, int endx, int endy) { return m_WasMiddleButtonClicked && IsMouseInRegion(x, y, endx, endy); }

   bool WasLButtonDoubleClicked() { return m_WasLeftButtonDoubleClicked; }
   bool WasRButtonDoubleClicked() { return m_WasRightButtonDoubleClicked; }
   bool WasMButtonDoubleClicked() { return m_WasMiddleButtonDoubleClicked; }

   bool WasLButtonDoubleClickedInRegion(int x, int y, int endx, int endy) { return m_WasLeftButtonDoubleClicked && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
   bool WasRButtonDoubleClickedInRegion(int x, int y, int endx, int endy) { return m_WasRightButtonDoubleClicked && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
   bool WasMButtonDoubleClickedInRegion(int x, int y, int endx, int endy) { return m_WasMiddleButtonDoubleClicked && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }


   //  These functions return true if the corresponding mouse button was pushed down this update inside the given quad.
   bool WasLButtonJustClickedInRegion(int x, int y, int endx, int endy) { return m_IsLeftButtonDown && !m_WasLeftButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
   bool WasRButtonJustClickedInRegion(int x, int y, int endx, int endy) { return m_IsRightButtonDown && !m_WasRightButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
   bool WasMButtonJustClickedInRegion(int x, int y, int endx, int endy) { return m_IsMiddleButtonDown && !m_WasMiddleButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }

   //  These functions return true when the corresponding mouse button is held down inside the given quad.
   bool IsLButtonDownInRegion(int x, int y, int endx, int endy) { return m_IsLeftButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
   bool IsRButtonDownInRegion(int x, int y, int endx, int endy) { return m_IsRightButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }
   bool IsMButtonDownInRegion(int x, int y, int endx, int endy) { return m_IsMiddleButtonDown && (m_MouseX >= x && m_MouseX <= endx) && (m_MouseY >= y && m_MouseY <= endy); }

   bool IsLButtonDown() { return m_IsLeftButtonDown; }
   bool IsRButtonDown() { return m_IsRightButtonDown; }
   bool IsMButtonDown() { return m_IsMiddleButtonDown; }

   //  These functions handle mouse dragging (that is, pressing a button and then moving the mouse with the button down)
   bool WasDragStartedInRegion(int x, int y, int endx, int endy) { return (m_DownX >= x && m_DownX <= endx) && (m_DownY >= y && m_DownY <= endy); }

   bool IsLDragging() const;
   bool IsRDragging() const;
   bool IsMDragging() const;

   bool WasLDragging() const;
   bool WasRDragging() const;
   bool WasMDragging() const;

   //  The functions handle the mouse wheel
   bool MouseWheelUp() { return (m_LastMouseZ > m_MouseZ); }
   bool MouseWheelDown() { return (m_LastMouseZ < m_MouseZ); }

   //  This function returns true only if the mouse is inside the given rect with no interaction (useful for "hot" states)
   bool IsMouseInRegionNoButtons(int x, int y, int endx, int endy) {
      return !m_WasLeftButtonClicked && !m_WasRightButtonClicked && !m_WasMiddleButtonClicked && !m_IsLeftButtonDown && !m_IsRightButtonDown && !m_IsMiddleButtonDown &&
         (m_MouseX >= x && m_MouseX <= x + endx) && (m_MouseY >= y && m_MouseY <= y + endy);
   }

   bool IsMouseInRegionNoButtons(Rectangle rect) {
      return !m_WasLeftButtonClicked && !m_WasRightButtonClicked && !m_WasMiddleButtonClicked && !m_IsLeftButtonDown && !m_IsRightButtonDown && !m_IsMiddleButtonDown &&
         (m_MouseX >= rect.x && m_MouseX <= rect.x + rect.width) && (m_MouseY >= rect.y && m_MouseY <= rect.y + rect.height);
   }

   //  This version doesn't care about interaction and just does the bounds check.
   bool IsMouseInRegion(int x, int y, int endx, int endy) {
      return (m_MouseX >= x && m_MouseX <= x + endx) && (m_MouseY >= y && m_MouseY <= y + endy);
   }

   bool IsMouseInRegion(Rectangle rect) {
      return (m_MouseX >= rect.x && m_MouseX <= rect.x + rect.width) && (m_MouseY >= rect.y && m_MouseY <= rect.y + rect.height);
   }

   //  Gamepad
   void UpdateGamepadState();

   bool WasAnyGamepadButtonJustPressed();

   bool  IsGamepadConnected() const;
   bool  WasGamepadJustAdded() { return m_WasGamepadJustAdded; }
   bool  WasGamepadJustRemoved() { return m_WasGamepadJustRemoved; }
   bool  JoyButtonIsDown(int button) { if (button == -1) return false; else return m_GamepadButtonState[button]; }
   bool  JoyButtonJustPressed(int button) { if (button == -1) return false; else return (!m_LastGamepadButtonState[button] && m_GamepadButtonState[button]); }
   bool  JoyButtonWasPressed(int button) { if (button == -1) return false; else  return (m_LastGamepadButtonState[button] && !m_GamepadButtonState[button]); }
   int   GetLastButtonPressed();
   //  This can be called for both "pressed" and "down" states. For "pressed",
   //  it returns the duration of the last button press.  For "down", it returns
   //  how long the button has been held down.  Result is in milliseconds.
   //unsigned int JoyButtonPressDuration(unsigned int button) { return m_GamepadDurations[button]; }

   //  Axes run from -1 to 1.  Triggers run from 0 to 1;
   float JoyLXAxis() { return m_GamepadAxisState[0]; }
   float JoyLYAxis() { return m_GamepadAxisState[1]; }
   float JoyRXAxis() { return m_GamepadAxisState[2]; }
   float JoyRYAxis() { return m_GamepadAxisState[3]; }

   void DumpInput();

   int GetControlType() { return m_ControlType; }
   bool DidControlTypeChange() { return m_LastControlType != m_ControlType; }

   std::unordered_map<int, bool> m_KeyboardState;
   std::unordered_map<int, bool> m_LastKeyboardState;

   int m_DownX, m_DownY;
   int m_MouseX, m_MouseY, m_MouseZ;
   int m_LastMouseZ;

   // Double click timing (in seconds)
   float m_DoubleClickTime = 0.25f;   // 350ms is a good default

   // Last click time for each button
   float m_LastLeftClickTime = 0.0f;
   float m_LastRightClickTime = 0.0f;
   float m_LastMiddleClickTime = 0.0f;

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
      m_WasLeftButtonDoubleClicked,
      m_WasRightButtonDoubleClicked,
      m_WasMiddleButtonDoubleClicked,
      m_IsLeftDragging,
      m_IsRightDragging,
      m_IsMiddleDragging,
      m_WasLeftDragging,
      m_WasRightDragging,
      m_WasMiddleDragging,
      m_IsGamepadConnected,
      m_WasGamepadJustAdded,
      m_WasGamepadJustRemoved,
      m_LeftSingleClickPending,
      m_MiddleSingleClickPending,
      m_RightSingleClickPending;

   std::unordered_map<int, bool> m_MouseState;

   int m_Gamepad;
   std::unordered_map<int, bool> m_GamepadButtonState;
   std::unordered_map<int, bool> m_LastGamepadButtonState;
   std::unordered_map<int, float> m_GamepadAxisState;
   std::unordered_map<int, float> m_LastGamepadAxisState;

   enum ControlTypes
   {
      CTRL_KEYBOARD = 0, // Actually mouse and keyboard but I don't feel like typing CTRL_MOUSEANDKEYBOARD over and over
      CTRL_GAMEPAD,
      CTRL_LASTINPUTTYPE
   };

   int m_ControlType = CTRL_KEYBOARD; // How the game is currently being controlled: mouse and keyboard or Gamepad.
   int m_LastControlType = CTRL_KEYBOARD;

   std::unordered_map<int, std::string> m_KeyNames = 
   {
      {KEY_NULL, "None" },
      {KEY_A, "A"},
      {KEY_B, "B"},
      {KEY_C, "C"},
      {KEY_D, "D"},
      {KEY_E, "E"},
      {KEY_F, "F"},
      {KEY_G, "G"},
      {KEY_H, "H"},
      {KEY_I, "I"},
      {KEY_J, "J"},
      {KEY_K, "K"},
      {KEY_L, "L"},
      {KEY_M, "M"},
      {KEY_N, "N"},
      {KEY_O, "O"},
      {KEY_P, "P"},
      {KEY_Q, "Q"},
      {KEY_R, "R"},
      {KEY_S, "S"},
      {KEY_T, "T"},
      {KEY_U, "U"},
      {KEY_V, "V"},
      {KEY_W, "W"},
      {KEY_X, "X"},
      {KEY_Y, "Y"},
      {KEY_Z, "Z"},
      {KEY_ONE, "1"},
      {KEY_TWO, "2"},
      {KEY_THREE, "3"},
      {KEY_FOUR, "4"},
      {KEY_FIVE, "5"},
      {KEY_SIX, "6"},
      {KEY_SEVEN, "7"},
      {KEY_EIGHT, "8"},
      {KEY_NINE, "9"},
      {KEY_ZERO, "0"},
      {KEY_ENTER, "Enter"},
      {KEY_ESCAPE, "Esc"},
      {KEY_BACKSPACE, "Backspace"},
      {KEY_TAB, "Tab"},
      {KEY_SPACE, "Space"},
      {KEY_MINUS, "-"},
      {KEY_EQUAL, "="},
      {KEY_LEFT_BRACKET, "["},
      {KEY_RIGHT_BRACKET, "]"},
      {KEY_BACKSLASH, "\\"},
      {KEY_SEMICOLON, ";"},
      {KEY_APOSTROPHE, "'"},
      {KEY_GRAVE, "`"},
      {KEY_COMMA, ","},
      {KEY_PERIOD, "."},
      {KEY_SLASH, "/"},
      {KEY_CAPS_LOCK, "CapsLock"},
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
      {KEY_PRINT_SCREEN, "Print Screen"},
      {KEY_SCROLL_LOCK, "Scroll Lock"},
      {KEY_PAUSE, "Pause"},
      {KEY_INSERT, "Ins"},
      {KEY_HOME, "Home"},
      {KEY_PAGE_UP, "PageUp"},
      {KEY_DELETE, "Del"},
      {KEY_END, "End"},
      {KEY_PAGE_DOWN, "PageDown"},
      {KEY_RIGHT, "Right"},
      {KEY_LEFT, "Left"},
      {KEY_DOWN, "Down"},
      {KEY_UP, "Up"},
      {KEY_NUM_LOCK, "NumLock"},
      {KEY_KP_DIVIDE, "KP /"},
      {KEY_KP_MULTIPLY, "KP *"},
      {KEY_KP_SUBTRACT, "KP -"},
      {KEY_KP_ADD, "KP +"},
      {KEY_KP_ENTER, "KP Enter"},
      {KEY_KP_1, "KP 1"},
      {KEY_KP_2, "KP 2"},
      {KEY_KP_3, "KP 3"},
      {KEY_KP_4, "KP 4"},
      {KEY_KP_5, "KP 5"},
      {KEY_KP_6, "KP 6"},
      {KEY_KP_7, "KP 7"},
      {KEY_KP_8, "KP 8"},
      {KEY_KP_9, "KP 9"},
      {KEY_KP_0, "KP 0"},
      {KEY_KP_DECIMAL, "KP ."},
      {KEY_KP_EQUAL, "KP ="},
      {KEY_RIGHT_SHIFT, "RShift"},
      {KEY_LEFT_SHIFT, "LShift"},
      {KEY_RIGHT_CONTROL, "RCtrl"},
      {KEY_LEFT_CONTROL, "LCtrl"},
      {KEY_RIGHT_ALT, "RAlt"},
      {KEY_LEFT_ALT, "LAlt"}
   };

   std::unordered_map<int, std::string> m_GamepadNames =
   {
      { GAMEPAD_BUTTON_UNKNOWN, " "},

      { GAMEPAD_BUTTON_RIGHT_FACE_DOWN, "A" },
      { GAMEPAD_BUTTON_RIGHT_FACE_RIGHT, "B" },
      { GAMEPAD_BUTTON_RIGHT_FACE_LEFT, "X" },
      { GAMEPAD_BUTTON_RIGHT_FACE_UP, "Y" },

      { GAMEPAD_BUTTON_LEFT_THUMB, "L3" },
      { GAMEPAD_BUTTON_RIGHT_THUMB, "R3" },
      { GAMEPAD_BUTTON_LEFT_TRIGGER_1, "Left Shoulder" },
      { GAMEPAD_BUTTON_RIGHT_TRIGGER_1, "Right Shoulder" },
	   { GAMEPAD_BUTTON_LEFT_TRIGGER_2, "Left Trigger" },
	   { GAMEPAD_BUTTON_RIGHT_TRIGGER_1, "Right Trigger" },
      { GAMEPAD_BUTTON_LEFT_FACE_UP, "Up" },
      { GAMEPAD_BUTTON_LEFT_FACE_DOWN, "Down" },
      { GAMEPAD_BUTTON_LEFT_FACE_LEFT, "Left" },
      { GAMEPAD_BUTTON_LEFT_FACE_RIGHT, "Right" }
   };

   //  Keyboard keycodes aren't contiguous, so we need this
   const std::vector<KeyboardKey> m_ValidKeys =
   {
      KEY_APOSTROPHE,
      KEY_COMMA,
      KEY_MINUS,
      KEY_PERIOD,
      KEY_SLASH,
      KEY_ZERO,
      KEY_ONE,
      KEY_TWO,
      KEY_THREE,
      KEY_FOUR,
      KEY_FIVE,
      KEY_SIX,
      KEY_SEVEN,
      KEY_EIGHT,
      KEY_NINE,
      KEY_SEMICOLON,
      KEY_EQUAL,
      KEY_A,
      KEY_B,
      KEY_C,
      KEY_D,
      KEY_E,
      KEY_F,
      KEY_G,
      KEY_H,
      KEY_I,
      KEY_J,
      KEY_K,
      KEY_L,
      KEY_M,
      KEY_N,
      KEY_O,
      KEY_P,
      KEY_Q,
      KEY_R,
      KEY_S,
      KEY_T,
      KEY_U,
      KEY_V,
      KEY_W,
      KEY_X,
      KEY_Y,
      KEY_Z,
      KEY_LEFT_BRACKET,
      KEY_BACKSLASH,
      KEY_RIGHT_BRACKET,
      KEY_GRAVE,
      KEY_SPACE,
      KEY_ESCAPE,
      KEY_ENTER,
      KEY_TAB,
      KEY_BACKSPACE,
      KEY_INSERT,
      KEY_DELETE,
      KEY_RIGHT,
      KEY_LEFT,
      KEY_DOWN,
      KEY_UP,
      KEY_PAGE_UP,
      KEY_PAGE_DOWN,
      KEY_HOME,
      KEY_END,
      KEY_CAPS_LOCK,
      KEY_SCROLL_LOCK,
      KEY_NUM_LOCK,
      KEY_PRINT_SCREEN,
      KEY_PAUSE,
      KEY_F1,
      KEY_F2,
      KEY_F3,
      KEY_F4,
      KEY_F5,
      KEY_F6,
      KEY_F7,
      KEY_F8,
      KEY_F9,
      KEY_F10,
      KEY_F11,
      KEY_F12,
      KEY_LEFT_SHIFT,
      KEY_LEFT_CONTROL,
      KEY_LEFT_ALT,
      KEY_LEFT_SUPER,
      KEY_RIGHT_SHIFT,
      KEY_RIGHT_CONTROL,
      KEY_RIGHT_ALT,
      KEY_RIGHT_SUPER,
      KEY_KB_MENU,
      KEY_KP_0,
      KEY_KP_1,
      KEY_KP_2,
      KEY_KP_3,
      KEY_KP_4,
      KEY_KP_5,
      KEY_KP_6,
      KEY_KP_7,
      KEY_KP_8,
      KEY_KP_9,
      KEY_KP_DECIMAL,
      KEY_KP_DIVIDE,
      KEY_KP_MULTIPLY,
      KEY_KP_SUBTRACT,
      KEY_KP_ADD,
      KEY_KP_ENTER,
      KEY_KP_EQUAL,
      KEY_BACK,
      KEY_MENU,
      KEY_VOLUME_UP,
      KEY_VOLUME_DOWN
  };

};

#endif