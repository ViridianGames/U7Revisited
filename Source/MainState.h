#ifndef _MainState_H_
#define _MainState_H_

#include "Geist/State.h"
//#include "GumpManager.h"
#include <list>
#include <deque>
#include <array>
#include <math.h>

class ParticleSystem;
class Gui;
class GuiElement;
class GumpManager;

enum class MainStateModes
{
	MAIN_STATE_MODE_SANDBOX = 0,
	MAIN_STATE_MODE_TRINSIC_DEMO,
	MAIN_STATE_MODE_LAST
};

class MainState : public State
{
public:
   MainState(){};
   ~MainState();

   void Init(const std::string& configfile) override;
   void Shutdown() override;
   void Update() override;
   void Draw() override;

   void OnEnter() override;
	void OnExit() override;
   
   void SetupGame();

   void OpenGump(int id);

   void DrawStats();
   void UpdateStats();
	void UpdateInput();
	void UpdateTime();

	void SetLuaFunction(const std::string& func_name) { m_luaFunction = func_name; }
	void StartObjectSelectionMode() { m_objectSelectionMode = true; }

	void Bark(U7Object* object, const std::string& text, float duration = 3.0f);

	void NPCBark(int npc_id, const std::string& text, float duration = 3.0f);

	void Wait(float seconds); // Wait while not blocking, called by Lua scripts.

	float m_waitTime = 0;

   Gui* m_Gui;

   Gui* m_OptionsGui;

   Gui* m_toolTipGui;

	Gui* m_numberBarGui;

	std::string m_luaFunction;

	//  Bark variables.
	U7Object* m_barkObject = nullptr;
	std::string m_barkText = "";
	float m_barkDuration = 0;;
   
   float m_LastUpdate;
   
   int m_NumberOfVisibleUnits;
   
   int m_GuiMode;
   
   bool m_DrawMarker;
   float m_MarkerRadius;
   
   ParticleSystem* m_Particles;
   
//   SDL_Rect** m_Resolutions;
//   int m_CurrentRes;
   
   // Game options
   unsigned int m_NumberOfPlayers;
   unsigned int m_PlayerID;
   unsigned int m_GameType;
   unsigned int m_RNGSeed;
   
   //Texture* m_TerrainTexture;
   Texture* m_Minimap;
   Texture* m_MinimapArrow;
	Texture* m_usePointer;
   

   bool m_showObjects;

	bool m_objectSelectionMode = false;

	int m_numberofObjects = 0;
	int m_numberofObjectsPassingFirstCheck = 0;
   int m_numberofDrawnObjects = 0;

   int m_cameraUpdateTime = 0;

   int m_terrainUpdateTime = 0;

	bool m_doingObjectSelection = false;

   unsigned int m_terrainDrawHeight = 0;

   unsigned int m_selectedObject = 0;

   float m_heightCutoff = 4.0f;

   bool m_isPopupShowing = false;  //  If true, the game is paused and a popup is showing

   bool m_paused = false;

	Vector2 m_dragStart;

	bool m_allowInput = true;

	MainStateModes m_gameMode = MainStateModes::MAIN_STATE_MODE_SANDBOX;

	enum class FadeState
	{
		FADE_NONE = 0,
		FADE_OUT,
		FADE_IN
	};

	FadeState m_fadeState = FadeState::FADE_NONE; // 0 = no fade, 1 = fade out, 2 = fade in
	float m_fadeDuration = 0; // 0.0 to 1.0
	float m_fadeTime = 0;
	unsigned char m_currentFadeAlpha = 255;

	bool m_ranIolosScript = false;
	bool m_iolosScriptRunning = false;
	bool m_ranFinnigansScript = false;

	bool m_showUIElements = true;
};

#endif