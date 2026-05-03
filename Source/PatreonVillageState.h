#ifndef _PatreonVillageState_H_
#define _PatreonVillageState_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
#include "Geist/GuiManager.h"
#include <list>
#include <deque>
#include <math.h>

class GuiManager;

class PatreonVillageState : public State
{
public:
   PatreonVillageState() { m_DrawCursor = false; }  // PatreonVillageState draws cursor only after mouse moves
   ~PatreonVillageState();


   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void OnEnter();
   virtual void OnExit();

   void FadeOut(float fadeTime);
   void FadeIn(float fadeTime);
   
   float m_LastUpdate;

   bool m_mouseMoved;

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
   bool m_fadingOut = false;
   float m_cameraTimer = 10.0f; // Ten seconds at each waypoint.
   std::vector<Vector3> m_waypoints = {



      {2229, 0, 1903}, // - Alagnar's lab
      {2154, 0, 2037}, // - Triscle's house
{2027, 0, 2178}, // - Tavern
{2152, 0, 2336}, // - Horse's conference
      {2132, 0, 2164}, // - town hall
      {2262, 0, 2253}, // - Majuular's shipwreck
      {2264, 0, 2407}, // - Greenhouse
      {2211, 0, 2187}, // - Kat & Lora
      {2292, 0, 1881} // - Pirate ship

   };

   int m_currentWaypoint = 0;

   std::vector<U7Object*> m_customNPCs;
};

#endif