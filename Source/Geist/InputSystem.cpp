#include <Geist/InputSystem.h>
#include <Geist/Config.h>
#include <Geist/Logging.h>
#include <Geist/Globals.h>

using namespace std;

InputSystem::InputSystem()
{

}

void InputSystem::Init(const std::string& configfile)
{
   Log("Starting InputSystem::Init()");

   m_MouseX = 0;
   m_MouseY = 0;
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
   m_WasGamepadJustAdded = false;
   m_WasGamepadJustRemoved = false;

   m_IsGamepadConnected = false;
   if (IsGamepadAvailable(0))
   {
      m_Gamepad = 0;
     m_IsGamepadConnected = true;
     m_ControlType = CTRL_GAMEPAD;
   }
   else
   {
      m_Gamepad = -1;
      m_IsGamepadConnected = false;
      m_ControlType = CTRL_KEYBOARD;
   }

   for (int i = KEY_NULL; i <=KEY_VOLUME_DOWN; ++i )
   {
      m_KeyboardState[i] = false;
   }

   for (int i = 0; i < m_ValidKeys.size(); ++i )
   {
      m_LastKeyboardState[m_ValidKeys[i]] = false;
   }

   Log("Done With InputSystem::Init()");
}


void InputSystem::Shutdown()
{

}

void InputSystem::Update()
{
   UpdateGamepadState();
   UpdateKeyboardState();
   UpdateMouseState();

   // m_IsKeyDown = false;
   // for (int i = 0; i < 255; ++i)
   // {
   //    m_IsKeyDown |= (m_KeyboardState[i] != 0);
   // }

   //  Finally, check stats and see what mode we're in.
   m_LastControlType = m_ControlType;
   if (m_ControlType == CTRL_KEYBOARD) // See if we need to switch to Gamepad
   {
      if (WasAnyGamepadButtonJustPressed())
      {
         m_ControlType = CTRL_GAMEPAD;
      }
   }
   else if (m_ControlType == CTRL_GAMEPAD)
   {
      if (WasAnyKeyJustPressed())
      {
         m_ControlType = CTRL_KEYBOARD;
      }
   }
}

void InputSystem::Draw()
{

}

bool InputSystem::WasAnyKeyPressed()
{
   for (auto validKey : m_ValidKeys)
   {
      if (m_LastKeyboardState[validKey] && m_KeyboardState[validKey])
      {
         return true;
      }
   }

   return false;
}

bool InputSystem::WasAnyKeyJustPressed()
{
   for (auto validKey : m_ValidKeys)
   {
      if (!m_LastKeyboardState[validKey] && m_KeyboardState[validKey])
      {
         return true;
      }
   }

   return false;
}

int InputSystem::GetLastKeyPressed()
{
   for (auto validKey : m_ValidKeys)
   {
      if (m_LastKeyboardState[validKey] && !m_KeyboardState[validKey])
      {
         return validKey;
      }
   }

   return -1;
}

int InputSystem::GetLastButtonPressed()
{
   for (int i = 0; i < GAMEPAD_BUTTON_RIGHT_THUMB; ++i)
   {
      if (m_LastGamepadButtonState[i] && !m_GamepadButtonState[i])
      {
         return i;
      }
   }
   return -1;
}

void InputSystem::DumpInput() //  Dumps all current InputSystem, useful when you've captured something that you don't want anything else to use when you're done with.
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
   m_IsGamepadConnected = false;
   m_LeftSingleClickPending = false;
   m_MiddleSingleClickPending = false;
   m_RightSingleClickPending = false;
   m_WasGamepadJustAdded = false;
   m_WasGamepadJustRemoved = false;
   m_LastControlType = CTRL_KEYBOARD;
   m_ControlType = CTRL_KEYBOARD;
   m_LastMouseZ = 0;
   m_MouseZ = 0;
   m_LastLeftClickTime = 0;
   m_LastRightClickTime = 0;
   m_LastMiddleClickTime = 0;
}

bool InputSystem::WasLDragging() const
{
   return m_WasLeftDragging;
}

bool InputSystem::IsLDragging() const
{
   return m_IsLeftDragging;
}

bool InputSystem::WasRDragging() const
{
   return m_WasRightDragging;
}

bool InputSystem::IsRDragging() const
{
   return m_IsRightDragging;
}

bool InputSystem::WasMDragging() const
{
   return m_WasMiddleDragging;
}

bool InputSystem::IsMDragging() const
{
   return m_IsMiddleDragging;
}

bool InputSystem::IsGamepadConnected() const
{
   return m_IsGamepadConnected;
}

void InputSystem::UpdateGamepadState()
{
   m_WasGamepadJustAdded = false;
   m_WasGamepadJustRemoved = false;

   //  If no Gamepad, look for one.
   if (!m_IsGamepadConnected)
   {
      m_Gamepad = -1;
      m_IsGamepadConnected = false;
      if (IsGamepadAvailable(0))
      {
         m_Gamepad = 0;
         m_IsGamepadConnected = true;
         m_WasGamepadJustAdded = true;
      }
   }

   //  Did we lose the Gamepad this update?  Handle it.
   else if (m_IsGamepadConnected)
   {
      if (!IsGamepadAvailable(m_Gamepad))
      {
         m_Gamepad = -1;
         m_IsGamepadConnected = false;
         m_WasGamepadJustRemoved = true;
         m_ControlType = CTRL_KEYBOARD;
      }
   }

   //  Still connected? Update buttons
   if (m_IsGamepadConnected)
   {
      m_LastGamepadButtonState = m_GamepadButtonState;
      m_GamepadButtonState.clear();
      for (int i = GAMEPAD_BUTTON_LEFT_FACE_UP; i <= GAMEPAD_BUTTON_RIGHT_THUMB; ++i)
      {
         m_GamepadButtonState[i] = IsGamepadButtonDown(m_Gamepad, i);
      }

      //  Update axes
      m_LastGamepadAxisState = m_GamepadAxisState;
      m_GamepadAxisState.clear();
      int axisCount = GetGamepadAxisCount(m_Gamepad);
      for (int i = 0; i < axisCount; ++i)
      {
         m_GamepadAxisState[i] = GetGamepadAxisMovement(m_Gamepad, i);
      }
   }
}

bool InputSystem::WasAnyGamepadButtonJustPressed()
{
   if (m_IsGamepadConnected)
   {
      for (int i = GAMEPAD_BUTTON_LEFT_FACE_UP; i <= GAMEPAD_BUTTON_RIGHT_THUMB; ++i)
      {
         if (m_GamepadButtonState[i] == true && m_LastGamepadButtonState[i] == false)
         {
            return true;
         }
      }
   }

   return false;
}

void InputSystem::UpdateKeyboardState()
{
   m_LastKeyboardState = m_KeyboardState;

   for (auto validKey : m_ValidKeys)
   {
      m_KeyboardState[validKey]= IsKeyDown(validKey);
   }
}

void InputSystem::UpdateMouseState()
{
    m_MouseX = GetMouseX();
    m_MouseY = GetMouseY();

    // Previous frame states
    m_WasLeftButtonDown = m_IsLeftButtonDown;
    m_WasRightButtonDown = m_IsRightButtonDown;
    m_WasMiddleButtonDown = m_IsMiddleButtonDown;

    // Current frame button states
    m_IsLeftButtonDown = IsMouseButtonDown(MOUSE_BUTTON_LEFT);
    m_IsRightButtonDown = IsMouseButtonDown(MOUSE_BUTTON_RIGHT);
    m_IsMiddleButtonDown = IsMouseButtonDown(MOUSE_BUTTON_MIDDLE);

    // Reset click flags
    m_WasLeftButtonClicked = false;
    m_WasRightButtonClicked = false;
    m_WasMiddleButtonClicked = false;

    m_WasLeftButtonDoubleClicked = false;
    m_WasRightButtonDoubleClicked = false;
    m_WasMiddleButtonDoubleClicked = false;

    float currentTime = GetTime();

   if (m_WasLeftButtonDown && !m_IsLeftButtonDown)
   {
      if (currentTime - m_LastLeftClickTime < m_DoubleClickTime)
      {
         m_WasLeftButtonDoubleClicked = true;
         m_LastLeftClickTime = 0.0f;
      }
      else
      {
         m_WasLeftButtonClicked = true;
         m_LastLeftClickTime = currentTime;
      }
      m_IsLeftDragging = false;
   }

    // ==================== RIGHT BUTTON ====================
    if (m_WasRightButtonDown && !m_IsRightButtonDown)
    {
        if (currentTime - m_LastRightClickTime < m_DoubleClickTime)
        {
            m_WasRightButtonDoubleClicked = true;
            m_LastRightClickTime = 0.0f;
        }
        else
        {
            m_WasRightButtonClicked = true;
            m_LastRightClickTime = currentTime;
        }
        m_IsRightDragging = false;
    }

    // ==================== MIDDLE BUTTON ====================
    if (m_WasMiddleButtonDown && !m_IsMiddleButtonDown)
    {
        if (currentTime - m_LastMiddleClickTime < m_DoubleClickTime)
        {
            m_WasMiddleButtonDoubleClicked = true;
            m_LastMiddleClickTime = 0.0f;
        }
        else
        {
            m_WasMiddleButtonClicked = true;
            m_LastMiddleClickTime = currentTime;
        }
        m_IsMiddleDragging = false;
    }

    // ==================== DRAG DETECTION ====================
    if (!m_WasLeftButtonDown && m_IsLeftButtonDown ||
        !m_WasRightButtonDown && m_IsRightButtonDown ||
        !m_WasMiddleButtonDown && m_IsMiddleButtonDown)
    {
        m_DownX = m_MouseX;
        m_DownY = m_MouseY;
    }
    else
    {
        if (abs(m_MouseX - m_DownX) > 3 || abs(m_MouseY - m_DownY) > 3)
        {
            if (m_IsLeftButtonDown)   m_IsLeftDragging = true;
            if (m_IsRightButtonDown)  m_IsRightDragging = true;
            if (m_IsMiddleButtonDown) m_IsMiddleDragging = true;
        }
    }

    // ==================== MOUSE WHEEL ====================
    m_LastMouseZ = m_MouseZ;
    m_MouseZ += GetMouseWheelMove();
}
