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

   m_shapeData->Draw(m_Pos, m_Angle, m_color);
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

void U7Object::SetDest(Vector3 dest)
{
   m_Dest = dest;
   m_Direction = Vector3Subtract(m_Dest, m_Pos);
   m_Direction = Vector3Normalize(m_Direction);
}