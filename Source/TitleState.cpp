#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/StateMachine.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"
#include "TitleState.h"

#include <list>
#include <string>
#include <sstream>
#include <math.h>
#include <fstream>
#include <algorithm>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  TitleState
////////////////////////////////////////////////////////////////////////////////

TitleState::~TitleState()
{
   Shutdown();
}

void TitleState::Init(const string& configfile)
{
   CreateTitleGUI();
   m_title = g_ResourceManager->GetTexture("Images/title.png");
}

void TitleState::OnEnter()
{
   ClearConsole();
   m_LastUpdate = 0;
}

void TitleState::OnExit()
{

}

void TitleState::Shutdown()
{

}

void TitleState::Update()
{
   if (GetTime() - m_LastUpdate > GetFrameTime())
   {
      g_CurrentUpdate++;

      m_sortedVisibleObjects.clear();
      float drawRange = g_cameraDistance * 1.5f;
      for (unordered_map<int, shared_ptr<U7Object>>::iterator node = g_ObjectList.begin(); node != g_ObjectList.end(); ++node)
      {
         (*node).second->Update();
         float distance = Vector3Distance((*node).second->m_Pos, g_camera.target);
         distance -= (*node).second->m_Pos.y;
         if (distance < drawRange && (*node).second->m_Pos.y <= 4.0f)
         {
            double distanceFromCamera = Vector3Distance((*node).second->m_Pos, g_camera.position) - (*node).second->m_Pos.y;
            (*node).second->m_distanceFromCamera = distanceFromCamera;
            m_sortedVisibleObjects.push_back((*node).second);
         }
      }

      std::sort(m_sortedVisibleObjects.begin(), m_sortedVisibleObjects.end(), [](shared_ptr<U7Object> a, shared_ptr<U7Object> b) { return a->m_distanceFromCamera > b->m_distanceFromCamera; });

      m_LastUpdate = GetTime();
   }

   //  Slow rotate on the title screen
   g_CameraRotateSpeed = 0.001f;
   g_cameraRotation += g_CameraRotateSpeed;

   Vector3 current = g_camera.target;

   Vector3 finalmovement = Vector3RotateByAxisAngle(g_CameraMovementSpeed, Vector3{ 0, 1, 0 }, g_cameraRotation);

   current = Vector3Add(current, finalmovement);

   if (current.x < 0) current.x = 0;
   if (current.x > 3072) current.x = 3072;
   if (current.z < 0) current.z = 0;
   if (current.z > 3072) current.z = 3072;

   Vector3 camPos = { g_cameraDistance, g_cameraDistance, g_cameraDistance };
   camPos = Vector3RotateByAxisAngle(camPos, Vector3{ 0, 1, 0 }, g_cameraRotation);

   g_camera.target = current;
   g_camera.position = Vector3Add(current, camPos);
   g_camera.fovy = g_cameraDistance;
	
   g_Terrain->Update();
   UpdateTitle();
   TestUpdate();

   if (IsKeyPressed(KEY_F1))
   {
      g_StateMachine->MakeStateTransition(STATE_SHAPEEDITORSTATE);

   }
}


void TitleState::Draw()
{
   BeginDrawing();

   ClearBackground(Color {0, 0, 0, 255});

   BeginMode3D(g_camera);

   //  Draw the terrain
   g_Terrain->Draw();

   //  Draw the objects
   for (auto& unit : m_sortedVisibleObjects)
   {
      unit->Draw();
   }

   EndMode3D();

   //  Draw GUI overlay
   BeginTextureMode(g_guiRenderTarget);
   ClearBackground({ 0, 0, 0, 0 });

   //  Draw the minimap and marker

   DrawConsole();

   if (m_mouseMoved)
   {
      m_guiManager.Draw();
   }

   //  Draw any tooltips
   EndTextureMode();
   DrawTexturePro(g_guiRenderTarget.texture,
      { 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
      { 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
      { 0, 0 }, 0, WHITE);

   //  Draw version number in lower-right
   DrawTextEx(*g_Font, g_version.c_str(), Vector2{ GetRenderWidth() * .92f, GetRenderHeight() * .94f }, g_fontSize, 1, WHITE);

   //DrawTexture(*m_title, 0, 0, WHITE);

   DrawTexturePro(*m_title, Rectangle{ 0, 0, float(m_title->width), float(m_title->height) }, Rectangle{ 0, 0, float(m_title->width * g_DrawScale * .5f), float(m_title->height * g_DrawScale * .5f) }, { 0,0 }, 0, WHITE);

   if (m_mouseMoved)
   {
      DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);
   }

   EndDrawing();
}

////////////////////////////////////////////////////////////////////////////////
///  CREATORS
////////////////////////////////////////////////////////////////////////////////

void TitleState::CreateTitleGUI()
{
   m_TitleGui = make_shared<Gui>();
   m_TitleGui->m_Font = g_SmallFont;

   m_TitleGui->SetLayout(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, g_DrawScale, Gui::GUIP_USE_XY);
   m_TitleGui->AddOctagonBox(GUI_TITLE_PANEL2, 220, 180, 200, 160, g_Borders);
   //m_TitleGui->AddTextArea(GUI_TITLE_TITLE, g_Font.get(), "Ultima VII: Revisited", (320 - (MeasureText("Ultima VII: Revisited", g_Font->baseSize * g_DrawScale))) / 2, 20,
   //   (MeasureText("Ultima VII: Revisited", g_Font->baseSize * g_DrawScale)), 0, Color{255, 255, 255, 255}, true);

   m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_SINGLE_PLAYER, 190, "Begin",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_SHAPE_EDITOR, 220, "Shape Editor",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_OBJECT_EDITOR, 250, "Object Editor",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_WORLD_EDITOR, 280, "World Editor",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->AddStretchButtonCentered(GUI_TITLE_BUTTON_QUIT, 310, "Quit",
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM,
      g_ActiveButtonL, g_ActiveButtonR, g_ActiveButtonM, 0);

   m_TitleGui->m_Active = true;

   m_TitleGui->m_Draggable = true;

   m_guiManager.AddGui(m_TitleGui);
}

////////////////////////////////////////////////////////////////////////////////
///  UPDATERS
////////////////////////////////////////////////////////////////////////////////

void TitleState::UpdateTitle()
{
   m_guiManager.Update();
   //m_TitleGui->Update();
   
   if(!m_TitleGui->m_Active)
      return;
   
   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_QUIT)
   {
      g_Engine->m_Done = true;
   }
   
   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_SINGLE_PLAYER)
   {
      g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
   }
   
   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_SHAPE_EDITOR)
   {
      g_StateMachine->MakeStateTransition(STATE_SHAPEEDITORSTATE);
   }

   if (m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_OBJECT_EDITOR)
   {
      g_StateMachine->MakeStateTransition(STATE_OBJECTEDITORSTATE);
   }

   if(m_TitleGui->m_ActiveElement == GUI_TITLE_BUTTON_WORLD_EDITOR)
   {
      g_StateMachine->MakeStateTransition(STATE_WORLDEDITORSTATE);
      
   }

   if (IsKeyPressed(KEY_ESCAPE))
   {
		g_Engine->m_Done = true;
	}

   if (GetMouseDelta().x != 0 || GetMouseDelta().y != 0)
   {
		m_mouseMoved = true;
	}
}

void TitleState::TestUpdate()
{
   ModTexture& modTexture = *g_shapeTable[150][0].m_topTexture;
   if (IsKeyPressed(KEY_A))
   {
      modTexture.ResizeImage(modTexture.m_Image.width - 1, modTexture.m_Image.height);
      modTexture.UpdateTexture();
	}

   if (IsKeyPressed(KEY_D))
   {
		modTexture.ResizeImage(modTexture.m_Image.width + 1, modTexture.m_Image.height);
		modTexture.UpdateTexture();
	}

   if (IsKeyPressed(KEY_W))
   {
		modTexture.ResizeImage(modTexture.m_Image.width, modTexture.m_Image.height - 1);
		modTexture.UpdateTexture();
	}

   if (IsKeyPressed(KEY_S))
   {
		modTexture.ResizeImage(modTexture.m_Image.width, modTexture.m_Image.height + 1);
		modTexture.UpdateTexture();
	}

	
}

void TitleState::TestDraw()
{
   DrawTexture(g_shapeTable[150][0].m_topTexture->m_Texture, 0, 0, WHITE);
}