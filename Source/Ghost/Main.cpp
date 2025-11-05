#include "../Geist/Globals.h"
#include "../Geist/Engine.h"
#include "../Geist/StateMachine.h"
#include "../Geist/ResourceManager.h"
#include "../Geist/Logging.h"
#include "GhostState.h"
#include "ColorPickerState.h"
#include "raylib.h"

using namespace std;

int main()
{
	try
	{
		Log("Ghost - Geist GUI Editor starting...");

		// Create window FIRST - this is the only thing before the main loop
		SetConfigFlags(FLAG_WINDOW_RESIZABLE);
		InitWindow(1280, 720, "Ghost - Geist GUI Editor");
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
