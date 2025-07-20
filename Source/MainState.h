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

class MainState : public State
{
public:
   MainState(){};
   ~MainState();

   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void OnEnter();
   virtual void OnExit();
   
   void SetupGame();

   void OpenGump(int id);

   void DrawStats();
   void UpdateStats();

   Gui* m_Gui;
   Gui* m_SpellsPanel;
   Gui* m_ArmyPanel;
   
   Gui* m_OptionsGui;

   Gui* m_toolTipGui;
   
   GuiElement* m_ManaBar;

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
   

   bool m_showObjects;

   int m_numberofDrawnUnits = 0;

   int m_cameraUpdateTime = 0;

   int m_terrainUpdateTime = 0;

   unsigned int m_terrainDrawHeight = 0;

   unsigned int m_selectedObject = 0;

   float m_heightCutoff = 4.0f;

   bool m_isPopupShowing = false;  //  If true, the game is paused and a popup is showing

   bool m_paused = false;

   bool m_notDay = false;

   std::unique_ptr<GumpManager> m_GumpManager;
};

#endif