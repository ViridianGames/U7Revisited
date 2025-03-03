#ifndef _LOADINGSTATE_H_
#define _LOADINGSTATE_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
#include "U7Object.h"
#include <array>
#include <list>
#include <deque>
#include <math.h>

struct NPCblock
{
   unsigned char x;
   unsigned char y;
   unsigned short shapeId;
   unsigned short type;
   unsigned char proba;
   unsigned short data1;
   unsigned char lift;
   unsigned short data2;



   unsigned short index;
   unsigned short referent;
   unsigned short status;
   unsigned char str;
   unsigned char dex;
   unsigned char iq;
   unsigned char combat;
   unsigned char activity;
   unsigned char DAM;
   char soak1[3];
   unsigned short status2;
   unsigned char index2;
   char soak2[2];
   unsigned int xp;
   unsigned char training;
   unsigned short primary;
   unsigned short secondary;
   unsigned short oppressor;
   unsigned short ivrx;
   unsigned short ivry;
   unsigned short svrx;
   unsigned short svry;
   unsigned short status3;
   char soak3[5];
   unsigned char acty;
   char soak4[29];
   unsigned char SN;
   unsigned char V1;
   unsigned char V2;
   unsigned char food;
   char soak5[7];
   char name[16];
};

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
   void LoadModels();
   //void MakeCSVFile();
   void LoadInitialGameState();

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

   std::array<Color, 256> m_palette;
   
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
   bool m_loadingObjects = false;
   bool m_loadingIFIX = false;
   bool m_loadingIREG = false;
   bool m_loadingInitialGameState = false;
   bool m_loadingVersion = false;
   bool m_loadingModels = false;
   bool m_makingMap = false;

   bool m_loadingFailed = false;

   unsigned int m_currentShape = 0;
   unsigned int m_currentFrame = 0;

   bool m_objectViewing = true;

   std::unique_ptr<U7Object> m_currentObject = nullptr;
};

#endif