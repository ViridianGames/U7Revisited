#ifndef _LOADINGSTATE_H_
#define _LOADINGSTATE_H_

#include "State.h"
#include "Gui.h"
#include <list>
#include <deque>
#include <math.h>

class LoadingState : public State
{
public:
   LoadingState(){};
   ~LoadingState();


   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void OnEnter();
   virtual void OnExit();
   
   void CreateTitleGUI();
   void UpdateLoading();

   void LoadChunks();
   void LoadMap();
   void CreateShapeTable();
   void CreateObjectTable();
   void LoadIFIX();
   void LoadIREG();
   void MakeMap();
   
   Gui* m_LoadingGui;

   Texture* m_loadingBackground;

   float m_red;

   std::unordered_map<int, std::vector< std::vector<unsigned short> > > m_Chunkmap;
   unsigned short m_u7map[192][192];

   unsigned int m_currentChunk = 0;

   bool m_loadingChunks = false;
   bool m_loadingMap = false;
   bool m_loadingShapes = false;
   bool m_loadingObjects = false;
   bool m_loadingIFIX = false;
   bool m_loadingIREG = false;
   bool m_makingMap = false;

};

#endif