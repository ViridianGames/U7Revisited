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
};

#endif