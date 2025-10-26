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
   void ParseIREGFile(std::stringstream& ireg, int superchunkx, int superchunky);
   void LoadFaces();
   void LoadVersion();
   void MakeMap();
   void LoadModels();
   void LoadInitialGameState();
   void LoadNPCSchedules();

   unsigned char ReadU8(std::istream &buffer);
   unsigned short ReadU16(std::istream &buffer);
   unsigned int  ReadU32(std::istream &buffer);
   char ReadS8(std::istream &buffer);
   short ReadS16(std::istream &buffer);
   int  ReadS32(std::istream &buffer);

   struct FLXEntryData
   {
      unsigned int offset;
      unsigned int length;
   };

   std::vector<FLXEntryData> ParseFLXHeader(std::istream &file);

   std::vector<std::array<Color, 256>> m_palettes;
   
   Gui* m_LoadingGui = nullptr;

   Texture* m_loadingBackground = nullptr;

   float m_red;

   float m_angle = 0;

   float xSlant = 0;

   bool m_startRotating = false;

   unsigned int m_currentChunk = 0;

   bool m_loadingChunks = false;
   bool m_loadingMap = false;
   bool m_loadingShapes = false;
   bool m_loadingFaces = false;
   bool m_loadingObjects = false;
   bool m_loadingIFIX = false;
   bool m_loadingIREG = false;
   bool m_loadingInitialGameState = false;
   bool m_loadingVersion = false;
   bool m_loadingModels = false;
   bool m_makingMap = false;
   bool m_loadingNPCSchedules = false;
   bool m_buildingPathfindingGrid = false;

   bool m_loadingFailed = false;

   unsigned int m_currentShape = 0;
   unsigned int m_currentFrame = 0;
   unsigned int m_currentFace = 0;

   bool m_objectViewing = true;

   std::unique_ptr<U7Object> m_currentObject = nullptr;
};

#endif