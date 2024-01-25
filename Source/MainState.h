#ifndef _MainState_H_
#define _MainState_H_

#include "State.h"
#include "SDL.h"
#include <list>
#include <deque>
#include <array>
#include <math.h>

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


   
   Gui* m_Gui;
   Gui* m_SpellsPanel;
   Gui* m_ArmyPanel;
   
   Gui* m_OptionsGui;
   
   GuiElement* m_ManaBar;

   unsigned int m_LastUpdate;
   
   int m_NumberOfVisibleUnits;
   
   int m_GuiMode;
   
   bool m_DrawMarker;
   float m_MarkerRadius;
   
   ParticleSystem m_Particles;
   
//   SDL_Rect** m_Resolutions;
//   int m_CurrentRes;
   
   // Game options
   unsigned int m_NumberOfPlayers;
   unsigned int m_PlayerID;
   unsigned int m_GameType;
   unsigned int m_RNGSeed;
   
   bool m_ArePlayersSetUp;

   // Networking
   bool m_SentServerEvents;
   unsigned int m_RespondedClients;
   unsigned int m_TurnLength;
   unsigned int m_ClientAuthorizedUpdate;
   unsigned int m_NextTurnUpdate;



   //Texture* m_TerrainTexture;
   Texture* m_Minimap;

   

   bool m_showObjects;

   int m_numberofDrawnUnits = 0;

   int m_cameraUpdateTime = 0;

   int m_terrainUpdateTime = 0;

   unsigned int m_terrainDrawHeight = 0;


};

#endif