#include "../Geist/Globals.h"
#include "../Geist/Engine.h"
#include "../Geist/StateMachine.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Logging.h"
#include "GhostState.h"
#include "ColorPickerState.h"
#include "SpritePickerState.h"
#include "FileChooserState.h"
#include "raylib.h"

#ifdef _WIN32
// Forward declare Windows types and functions we need
typedef void* HWND;
typedef void* HICON;
typedef void* HMODULE;
typedef void* HINSTANCE;
typedef long LONG_PTR;
typedef LONG_PTR LRESULT;
typedef LONG_PTR LPARAM;
typedef unsigned int UINT;

#define MAKEINTRESOURCE(i) ((char*)((unsigned long long)((unsigned short)(i))))
#define WM_SETICON 0x0080
#define ICON_SMALL 0
#define ICON_BIG 1

extern "C" {
	__declspec(dllimport) HWND __stdcall GetActiveWindow(void);
	__declspec(dllimport) HICON __stdcall LoadIconA(HINSTANCE hInstance, const char* lpIconName);
	__declspec(dllimport) HMODULE __stdcall GetModuleHandleA(const char* lpModuleName);
	__declspec(dllimport) LRESULT __stdcall SendMessageA(HWND hWnd, UINT Msg, LPARAM wParam, LPARAM lParam);
}

#define LoadIcon LoadIconA
#define GetModuleHandle GetModuleHandleA
#define SendMessage SendMessageA
#endif

using namespace std;

int main()
{
	try
	{
		Log("Ghost - Geist GUI Editor starting...");

		// Create window FIRST - this is the only thing before the main loop
		SetConfigFlags(FLAG_WINDOW_RESIZABLE);
		InitWindow(1280, 720, "Ghost - Geist GUI Editor");

		// Set window icon from embedded resource on Windows
		#ifdef _WIN32
		HWND hwnd = GetActiveWindow();
		if (hwnd)
		{
			// Load icon from exe resources (ID 1 is what we used in ghost.rc)
			HICON hIcon = LoadIcon(GetModuleHandle(NULL), MAKEINTRESOURCE(1));
			if (hIcon)
			{
				SendMessage(hwnd, WM_SETICON, ICON_BIG, (LPARAM)hIcon);
				SendMessage(hwnd, WM_SETICON, ICON_SMALL, (LPARAM)hIcon);
			}
		}
		#endif

		ShowCursor();

		bool initialized = false;

		Log("Starting Ghost main loop.");
		while (!WindowShouldClose())
		{
			BeginDrawing();
			ClearBackground(Color{40, 40, 40, 255});

			// Do initialization on first frame
			if (!initialized)
			{
				DrawText("Initializing...", 10, 10, 20, WHITE);
			}
			else
			{
				// Check if state wants to exit
				if (g_Engine->m_Done)
				{
					EndDrawing();
					break;
				}

				g_StateMachine->Update();
				g_StateMachine->Draw();
			}

			EndDrawing();

			// Do initialization after first frame is drawn
			if (!initialized)
			{
				// Now initialize minimal engine components
				g_Engine = make_unique<Engine>();
				g_Engine->m_Done = false;
				g_Engine->m_ScreenWidth = 1280;
				g_Engine->m_ScreenHeight = 720;
				g_Engine->m_RenderWidth = 1280;
				g_Engine->m_RenderHeight = 720;
				g_Engine->m_GameUpdates = 0;
				g_Engine->m_CurrentFrame = 0;
				g_Engine->m_debugDrawing = false;

				// Initialize only what we need
				g_ResourceManager = make_unique<ResourceManager>();
				g_StateMachine = make_unique<StateMachine>();

				// Create and register Ghost state
				State* ghostState = new GhostState;
				ghostState->Init("");
				g_StateMachine->RegisterState(0, ghostState, "GHOST_STATE");

				// Create and register ColorPicker state
				State* colorPickerState = new ColorPickerState;
				colorPickerState->Init("");
				g_StateMachine->RegisterState(1, colorPickerState, "COLOR_PICKER_STATE");

				// Create and register SpritePicker state
				State* spritePickerState = new SpritePickerState;
				spritePickerState->Init("");
				g_StateMachine->RegisterState(2, spritePickerState, "SPRITE_PICKER_STATE");

				// Create and register FileChooser state
				State* fileChooserState = new FileChooserState;
				fileChooserState->Init("");
				g_StateMachine->RegisterState(3, fileChooserState, "FILE_CHOOSER_STATE");

				// Start with Ghost state
				g_StateMachine->MakeStateTransition(0);

				// Set FPS limit AFTER initialization is done
				SetTargetFPS(60);

				initialized = true;
			}
		}

		Log("Ghost shutting down.");
		CloseWindow();
	}
	catch (string errorCode)
	{
		Log("Error: " + errorCode);
		return 1;
	}

	return 0;
}
