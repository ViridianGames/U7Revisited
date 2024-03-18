///////////////////////////////////////////////////////////////////////////
//
// Name:     MAIN.CPP
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  Contains the Windows-specific WinMain() function, which
//           defines the entry point of the program, and the WndProc()
//           function, which controls the handling of Windows-specific
//           events.  The WinMain() contains the game's main loop.
//
/////////////////////////////////////////////////////////////////////////// 

#include "Globals.h"
#include "U7Globals.h"
#include "MainState.h"
#include "TitleState.h"
#include "OptionsState.h"
#include "LoadingState.h"
#include "ObjectEditorState.h"
#include "WorldEditorState.h"
#include "ShapeData.h"
#include <string>
#include <sstream>

using namespace std;

void CreateObjectTypeDatabase();
// WinMain

int main(int argv, char** argc)
{

   try
   {
      g_Engine = make_unique<Engine>();
      g_Engine->Init("Data/engine.cfg");
      
      //  Initialize globals
      g_Cursor = g_ResourceManager->GetTexture("Images/pointer.png");

      //Texture* g_Ground = g_ResourceManager->GetTexture("Images/Terrain/U7Baseplates/u7map8-3.png");

      g_DrawScale = float(g_Display->GetHeight()) / 180.0f;

      float fontScale = static_cast<int>(8 * g_DrawScale) - (static_cast<int>(8 * g_DrawScale) % 8);

      g_Font = make_shared<Font>();
      g_Font->Init("Data/Fonts/babyblocks.ttf", fontScale * 2);

      g_SmallFont = make_shared<Font>();
      g_SmallFont->Init("Data/Fonts/babyblocks.ttf", fontScale);

//      g_SmallFixedFont = new Font();
//      g_SmallFixedFont->Init("Data/Fonts/font8x8.txt");
//      g_SmallFixedFont->SetFixedWidth();

      g_VitalRNG = make_unique<RNG>();
      g_VitalRNG->SeedRNG(7777);//g_Engine->Time());
      g_NonVitalRNG = make_unique<RNG>();
      g_NonVitalRNG->SeedRNG(g_Engine->Time());

      CreateObjectTypeDatabase();

      Log("Creating terrain.");
      g_Terrain = make_unique<Terrain>();
      g_Terrain->Init("");
      Log("Done creating terrain.");

      //  Initialize states
      Log("Initializing states.");
      State* _titleState = new TitleState;
      _titleState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_TITLESTATE, _titleState);
      
      State* _mainState = new MainState;
      _mainState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_MAINSTATE, _mainState);

      State* _optionsState = new OptionsState;
      _optionsState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_OPTIONSSTATE, _optionsState);

      State* loadingState = new LoadingState;
      loadingState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_LOADINGSTATE, loadingState);

      State* objectEditorState = new ObjectEditorState;
      objectEditorState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_OBJECTEDITORSTATE, objectEditorState);

      State* worldEditorState = new WorldEditorState;
      worldEditorState->Init("engine.cfg");
      g_StateMachine->RegisterState(STATE_WORLDEDITORSTATE, worldEditorState);


      g_StateMachine->MakeStateTransition(STATE_LOADINGSTATE);

      Log("Starting main loop.");
      while (!g_Engine->m_Done)
      {
         g_Engine->Update();
         g_Engine->Draw();
      }
   }

   catch (string errorCode)
   {
      assert(errorCode.c_str());
   }

   if (g_Engine)
   {
      g_Engine.reset();
   }

   return 0;
}

void CreateObjectTypeDatabase()
{
   //  Floor tiles.
   for (int i = 0; i < 1024; ++i)
   {
      g_ObjectTypes[i] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_STATIC);
   }

   g_ObjectTypes[150]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC); //  gangplank
   g_ObjectTypes[153]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC); //  wall
   g_ObjectTypes[154]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC); //  wall
   g_ObjectTypes[154]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE); //  mage
   g_ObjectTypes[155]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE); //  The Ferryman
   g_ObjectTypes[157]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC); //  moongate
   g_ObjectTypes[158]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC); //  stand
   g_ObjectTypes[159]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM); //  pocketwatch
   g_ObjectTypes[163]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC); // rock outcropping 
   g_ObjectTypes[177]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[178]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[181]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[185]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[191]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[192]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[193]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[194]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[197]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[199]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[200]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[201]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[202]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[204]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[205]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[206]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[207]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[208]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[210]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[211]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[212]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[213]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[214]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[215]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[216]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[217]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[218]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[219]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[220]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[221]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[222]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[225]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[226]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[227]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[229]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[229]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[230]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[232]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[233]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[234]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[235]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[236]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[237]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[238]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[239]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[240]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[241]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[242]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[243]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[244]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[245]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[246]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[247]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[248]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[250]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[251]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[252]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[253]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[254]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[255]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[257]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[258]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[259]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[260]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[261]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[263]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[265]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[266]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[268]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[270]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[271]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[272]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[273]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[274]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[275]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[276]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[277]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[279]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[282]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[283]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[284]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[286]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[289]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[290]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[291]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[292]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[293]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_HANGINGNS, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[295]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[296]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[297]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[298]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[299]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[302]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[303]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[304]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[305]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[306]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[307]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[308]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[309]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[310]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[311]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[313]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[314]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[315]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[316]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[317]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[318]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[319]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[320]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[321]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[322]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[323]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[325]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[326]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[327]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[328]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[329]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[330]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_QUEST_ITEM);
   g_ObjectTypes[331]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[332]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[333]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[336]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[337]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[338]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[340]  = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[341] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[342] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[343] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[344] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[345] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[346] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[347] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[348] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[349] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[350] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[351] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[352] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[353] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[354] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[355] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[356] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[357] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[358] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[359] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[360] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[361] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_HANGINGNS, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[362] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[364] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[365] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[366] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[367] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[368] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[369] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[370] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[371] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[372] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[373] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[374] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[375] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[376] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[377] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[378] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[379] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[380] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[381] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[382] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[383] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[385] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[386] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[387] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[388] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[389] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[390] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[391] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[392] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[393] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[394] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[395] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[396] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[401] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[402] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[403] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[404] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[406] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[407] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[409] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[410] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[411] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[412] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[415] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[416] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_CONTAINER);
   g_ObjectTypes[418] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[420] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[421] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[422] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[423] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[425] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[426] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[427] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[428] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[429] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[430] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[431] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[432] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[433] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[434] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[435] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[436] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[437] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[438] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[439] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[441] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[442] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[444] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[445] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[446] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[447] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[448] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[449] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[450] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[451] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[452] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[453] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[454] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[455] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[456] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[457] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[458] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[459] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[460] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[461] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[462] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[463] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[464] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[465] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[466] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[467] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[468] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[469] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[470] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[471] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[472] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[473] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[474] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[475] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[476] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[477] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[478] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[479] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[480] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[481] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[482] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[484] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[485] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[486] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[487] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[488] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[489] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[490] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[491] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[492] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[493] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[494] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[495] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[496] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[497] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[498] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[499] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[500] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[501] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[502] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[503] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[504] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[505] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[506] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[507] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[508] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[510] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[511] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[512] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[513] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[514] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[515] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[517] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[518] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[519] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[520] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[521] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[522] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[523] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[524] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[525] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[526] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[528] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[529] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[530] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[531] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[532] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[533] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[534] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[535] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[536] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[537] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[538] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[539] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[541] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[542] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[543] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[544] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[545] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[546] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[547] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[548] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[549] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[550] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[551] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[552] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[553] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[554] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[555] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[556] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[557] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[558] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[559] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[560] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[561] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[562] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[563] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[564] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[567] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[568] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[569] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[570] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[571] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[572] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[573] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[574] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[575] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[576] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[577] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[578] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[579] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[580] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[581] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[582] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[583] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[584] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[585] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[586] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[587] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[588] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[589] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[590] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[591] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[592] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[593] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[594] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[595] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[596] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[597] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[598] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[599] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[600] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[601] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[602] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[603] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[604] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[605] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[606] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[608] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[609] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[614] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[615] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[616] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[617] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[618] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[619] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[620] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[622] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[623] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[624] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[625] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[626] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[627] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[628] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[629] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[630] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[631] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[633] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[634] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[635] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[636] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[637] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[638] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[640] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[641] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[642] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[643] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[644] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[645] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[646] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[647] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[648] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[649] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[650] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[651] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[652] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[653] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[654] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[655] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[656] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[657] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_HANGINGEW, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[658] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[659] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[660] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[661] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[662] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[663] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[664] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[665] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[666] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[667] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[668] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[669] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[670] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[671] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[672] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[673] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[674] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[675] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[677] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[678] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_HANGINGNS, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[679] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_CONTAINER);
   g_ObjectTypes[680] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[681] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[682] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[683] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[684] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[685] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[686] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ARMOR);
   g_ObjectTypes[687] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[689] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[690] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[691] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[692] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[693] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[694] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[695] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[696] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[697] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[698] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[700] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[701] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[702] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[703] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[704] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[705] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[706] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[707] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[708] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[709] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[710] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[711] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[712] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[713] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[714] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[715] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[716] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[717] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[718] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[719] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[720] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[721] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[722] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[723] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[724] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[725] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[726] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[727] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[728] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[729] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[730] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_QUEST_ITEM);
   g_ObjectTypes[732] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[734] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[735] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[738] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[739] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[740] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[741] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[742] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[743] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[744] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[745] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[746] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[747] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[748] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[749] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[752] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[753] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[754] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[756] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[757] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[759] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[760] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[761] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[763] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[764] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[765] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[766] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[767] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[769] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[770] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[771] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[772] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[773] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[774] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[775] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[776] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[777] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[779] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[781] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[782] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[783] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[784] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[785] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[786] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[787] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[788] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[789] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[790] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[791] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[792] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[795] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[796] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[797] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[798] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[799] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[800] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_CONTAINER);
   g_ObjectTypes[801] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_CONTAINER);
   g_ObjectTypes[802] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_CONTAINER);
   g_ObjectTypes[803] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_CONTAINER);
   g_ObjectTypes[804] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_CONTAINER);
   g_ObjectTypes[805] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[806] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[809] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[810] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[811] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[812] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[813] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[814] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[815] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[817] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[818] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[819] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[820] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[821] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[822] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[823] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[824] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[826] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[827] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[828] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[829] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[830] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[831] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[832] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[833] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[835] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[836] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[837] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[838] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[839] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[841] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[842] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[843] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[845] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[846] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[847] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[848] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[849] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[851] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[852] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[853] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[854] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[855] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[858] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[860] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[861] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[863] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[864] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[865] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[866] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[868] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[869] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[870] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[871] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[872] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[873] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[876] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[877] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[878] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[879] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[880] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[881] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[882] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[883] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[884] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[885] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[887] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[888] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[889] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[890] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[893] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[894] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[896] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[897] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[898] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[899] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[901] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[903] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[904] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[905] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[906] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[909] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[910] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[913] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[914] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[915] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[916] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[917] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[919] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[920] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[921] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[922] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[923] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[924] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[925] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[928] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[929] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[931] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[932] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[933] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[934] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[935] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[936] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[937] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[939] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[940] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[941] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[942] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[943] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[944] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[945] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[946] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[947] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[948] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[949] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[950] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[951] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[952] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[953] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[955] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[957] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[958] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[959] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[960] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[964] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[965] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[967] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[968] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[970] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[971] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[972] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[973] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[974] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[975] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[976] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[977] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[978] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[979] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[980] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[981] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[982] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[984] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[986] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[987] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[988] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[989] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[990] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[991] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[992] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[993] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[994] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[995] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[996] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[997] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[998] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[999] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[999] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1000] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1001] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1002] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1003] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1004] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_FLAT, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[1005] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1006] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1007] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1010] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1011] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1013] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_ITEM);
   g_ObjectTypes[1014] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1015] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_CREATURE);
   g_ObjectTypes[1016] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1017] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1018] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1019] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1021] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_CUBOID, ObjectTypes::OBJECT_STATIC);
   g_ObjectTypes[1023] = make_tuple<ShapeDrawType, ObjectTypes>(ShapeDrawType::OBJECT_DRAW_BILLBOARD, ObjectTypes::OBJECT_STATIC);
}