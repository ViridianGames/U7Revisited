#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/ResourceManager.h"
#include "Geist/StateMachine.h"
#include "Geist/Config.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "ShapeData.h"

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
   //m_Mesh = g_ResourceManager->GetMesh(m_UnitConfig->GetString("mesh"));
   m_Frame = frame;
   m_shapeData = &g_shapeTable[m_ObjectType][m_Frame];
   m_drawType = m_shapeData->GetDrawType();
   m_frameCount = m_shapeData->GetFrameCount();
   if (m_frameCount > 1) {
       m_isAnimated = true;
   }
   else
   {
       m_isAnimated = false;
   }
}

void U7Object::Draw()
{
  if (!(g_StateMachine->GetCurrentState() == STATE_OBJECTEDITORSTATE))
  {
    if (!m_Visible)
    {
      return;
    }
  }

  if (g_StateMachine->GetCurrentState() == STATE_MAINSTATE) {
    m_shapeData->Draw(m_DrawPos, m_Angle, m_color);
  }
  else {
    m_shapeData->Draw(m_Pos, m_Angle, m_color);
  }

   bool drawDebugBox = true;
   if (drawDebugBox == true) {
      if (g_Engine->m_debugDrawing)
      {
         DrawBoundingBox(m_boundingBox, MAGENTA);
      }
   }
}

void U7Object::Update()
{
  if (m_isAnimated) {
    if ((m_Frame % m_frameCount) == g_StateMachine->GetAnimFrame(m_frameCount)) {
      m_Visible = true;
    }
    else
    {
      m_Visible = false;
    }
  }
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
   m_DrawPos = pos;
   m_chunkOwn[0] = int(m_Pos.x / 16);
   m_chunkOwn[1] = int(m_Pos.z / 16);

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

void U7Object::SetDrawPos(Vector3 pos)
{
  m_DrawPos = pos;
}

bool U7Object::Pick()
{
   bool picked = false;

   Ray ray = GetMouseRay(GetMousePosition(), g_camera);

   RayCollision collision = GetRayCollisionBox(ray, m_boundingBox);

   return collision.hit;
}

void U7Object::SetDest(Vector3 dest)
{
   m_Dest = dest;
   m_Direction = Vector3Subtract(m_Dest, m_Pos);
   m_Direction = Vector3Normalize(m_Direction);
}