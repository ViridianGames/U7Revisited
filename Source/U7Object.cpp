#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Config.h"
#include "Geist/ScriptingSystem.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "ShapeData.h"
#include "LoadingState.h"

#include <iostream>
#include <string>
#include <sstream>
#include <format>
#include <iomanip>

using namespace std;

U7Object::~U7Object()
{
   Shutdown();
}

void U7Object::Init(const string& configfile, int unitType, int frame)
{
   m_Pos = Vector3{ 0, 0, 0 };
   m_Dest = Vector3{ 0, 0, 0 };
   m_Direction = Vector3{ 0, 0, 0 };
   m_Scaling = Vector3{ 1, 1, 1 };
   m_ExternalForce = Vector3{ 0, 0, 0 };
   m_GravityFlag = true;
   m_ExternalForceFlag = true;
   m_Angle = 0;
   m_Selected = false;
   m_Visible = true;
   m_Mesh = NULL;
   m_ObjectType = unitType;
   SetIsDead(false);
   m_UnitConfig = g_ResourceManager->GetConfig(configfile);
   m_Frame = frame;
   m_shapeData = &g_shapeTable[m_ObjectType][m_Frame];
   m_drawType = m_shapeData->GetDrawType();
   m_isContainer = false;
   m_isContained = false;
   m_isEgg = false;
   m_hasGump = false;
   m_inventory.clear();
}

void U7Object::Draw()
{
   if (!(g_StateMachine->GetCurrentState() == STATE_OBJECTEDITORSTATE))
   {
      if (!m_Visible || m_isContained || m_isEgg) 
      {
         return;
      }
	}

   m_shapeData->Draw(m_Pos, m_Angle, m_color);

   if (g_Engine->m_debugDrawing)
   {
		DrawBoundingBox(m_boundingBox, MAGENTA);
	}
}

void U7Object::Update()
{

}

void U7Object::Attack(int _UnitID)
{

}

void U7Object::Shutdown()
{

}

void U7Object::SetPos(Vector3 pos)
{
   m_Pos = pos;

   Vector3 dims = Vector3{ 0, 0, 0 };
   Vector3 boundingBoxAnchorPoint = Vector3{ 0, 0, 0 };

   ObjectData* objectData = &g_objectTable[m_shapeData->GetShape()];

   if (m_drawType == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
   {
      dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
      boundingBoxAnchorPoint = Vector3Add(m_Pos, Vector3{ 0, 0, 0 });
   }
   else if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
   {
      dims = Vector3{ float(m_shapeData->m_originalTexture->width) / 8.0f, 0, float(m_shapeData->m_originalTexture->height) / 8.0f };
      boundingBoxAnchorPoint = Vector3Add(m_Pos, Vector3{ -dims.x + 1, 0, -dims.z + 1 });
   }
   else
   {
      dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
      boundingBoxAnchorPoint = Vector3Add(m_Pos, Vector3{ -dims.x + 1, 0, -dims.z + 1 });
   }

   m_boundingBox = { boundingBoxAnchorPoint, Vector3Add(boundingBoxAnchorPoint, dims) };
}

float U7Object::Pick()
{
   Ray ray = GetMouseRay(GetMousePosition(), g_camera);

   RayCollision collision = GetRayCollisionBox(ray, m_boundingBox);

   if(collision.hit)
   {
      return collision.distance;
   }
   else
   {
      return -1;
   }
}

void U7Object::SetDest(Vector3 dest)
{
   m_Dest = dest;
   m_Direction = Vector3Subtract(m_Dest, m_Pos);
   m_Direction = Vector3Normalize(m_Direction);
}

bool U7Object::AddObjectToInventory(int objectid)
{
   if (m_isContainer)
   {
      m_inventory.push_back(objectid);
      return true;
   }

   return false;
}

bool U7Object::RemoveObjectFromInventory(int objectid)
{
   if (m_isContainer)
   {
      for (int i = 0; i < m_inventory.size(); i++)
      {
         if (m_inventory[i] == objectid)
         {
            GetObjectFromID(objectid)->m_isContained = true;
            m_inventory.erase(m_inventory.begin() + i);
            return true;
         }
      }
   }

   return false;
}

void U7Object::SetNPCBlock(NPCblock block)
{
   m_NPCData = block;
}

void U7Object::Interact(int event)
{
   if(m_hasConversationTree)
   {

      int NPCId = static_cast<int>(m_NPCData.index2);

      g_ConversationState->SetNPC(NPCId);

      string scriptName = "func_04";

      stringstream ss;
      ss << std::setw(2) << std::setfill('0') << std::hex << std::uppercase << NPCId;

      scriptName += ss.str();

      g_ConversationState->SetLuaFunction(scriptName);

      AddConsoleString(g_ScriptingSystem->CallScript(scriptName, {event, NPCId}));  
   }
   else
   {
      AddConsoleString(g_ScriptingSystem->CallScript(m_shapeData->m_luaScript, { event, m_ID }));
   }
}

bool U7Object::IsInInventory(int objectid)
{
   for (int i = 0; i < m_inventory.size(); i++)
   {
      if (m_inventory[i] == objectid)
      {
         return true;
      }
   }

   return false;
}

bool U7Object::IsInInventory(int shape, int frame)
{
   for (int i = 0; i < m_inventory.size(); i++)
   {
      if(GetObjectFromID(m_inventory[i])->m_shapeData->m_shape == shape &&
         GetObjectFromID(m_inventory[i])->m_shapeData->m_frame == frame)
      {
         return true;
      }
      else
      {
         return true;
      }
   }

   return false;
}