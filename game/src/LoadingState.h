#ifndef _LOADINGSTATE_H_
#define _LOADINGSTATE_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
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
   void LoadVersion();
   void MakeMap();

   unsigned char ReadU8(std::ifstream &buffer);
   unsigned short ReadU16(std::ifstream &buffer);
   unsigned int  ReadU32(std::ifstream &buffer);
   char ReadS8(std::ifstream &buffer);
   short ReadS16(std::ifstream &buffer);
   int  ReadS32(std::ifstream &buffer);

   struct FLXEntryData
   {
      unsigned int offset;
      unsigned int length;
   };

   std::vector<FLXEntryData> ParseFLXHeader(std::ifstream &file);

   std::array<Color, 256> m_palette;
   
   Gui* m_LoadingGui = nullptr;

   Texture* m_loadingBackground = nullptr;

   float m_red;

   float m_angle = 0;

   float xSlant = 0;

   bool m_startRotating = false;

   std::unordered_map<int, std::vector< std::vector<unsigned short> > > m_Chunkmap;
   unsigned short m_u7chunkmap[192][192];

   unsigned int m_currentChunk = 0;

   bool m_loadingChunks = false;
   bool m_loadingMap = false;
   bool m_loadingShapes = false;
   bool m_loadingObjects = false;
   bool m_loadingIFIX = false;
   bool m_loadingIREG = false;
   bool m_loadingVersion = false;
   bool m_makingMap = false;

   bool m_loadingFailed = false;

   unsigned int m_currentShape = 0;
   unsigned int m_currentFrame = 0;

   bool m_objectViewing = true;

   std::unique_ptr<U7Object> m_currentObject = nullptr;

   //std::unique_ptr<Texture> m_testTexture;

};

#endif