#include "Globals.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "Config.h"
#include "ShapeData.h"

using namespace std;

U7Object::~U7Object()
{
   Shutdown();
}

void U7Object::Init(const string& configfile, int unitType, int frame)
{
   m_Pos = glm::vec3(0, 0, 0);
   m_Dest = glm::vec3(0, 0, 0);
   m_Direction = glm::vec3(0, 0, 0);
   m_Scaling = glm::vec3(1, 1, 1);
   m_ExternalForce = glm::vec3(0, 0, 0);
   m_GravityFlag = true;
   m_ExternalForceFlag = true;
   m_Angle = 0;
   m_Selected = false;
   m_Visible = true;
   m_Mesh = NULL;
   m_ObjectType = unitType;
   SetIsDead(false);
   m_UnitConfig = g_ResourceManager->GetConfig(configfile);
   m_Mesh = g_ResourceManager->GetMesh(m_UnitConfig->GetString("mesh"));
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
   if (m_Pos.y > 4)
   {
      m_Visible = false;
   }
   else
   {
		m_Visible = true;
	}

   //  Visilibity is set by the terrain so it should always be set to false here.
   //m_Visible = false;

   if (m_color != Color(1, 1, 1, 1))
   {
      int stopper = 0;
      m_color.r += 0.1;
      m_color.g += 0.1;
      m_color.b += 0.1;
      m_color.a += 0.1;
      if (m_color.r > 1)
      {
			m_color.r = 1;
		}
      if (m_color.g > 1)
      {
			m_color.g = 1;
		}
      if (m_color.b > 1)
      {
			m_color.b = 1;
		}
      if (m_color.a > 1)
      {
			m_color.a = 1;
		}
	}
   

}

void U7Object::Attack(int _UnitID)
{

}

void U7Object::Shutdown()
{

}

bool U7Object::SelectCheck()
{
   if (m_Mesh->SelectCheck(m_Pos, m_Angle, m_Scaling))
      return true;

   return false;
}

void U7Object::SetDest(glm::vec3 dest)
{
   m_Dest = dest;
   m_Direction = m_Dest - m_Pos;
   m_Direction = glm::normalize(m_Direction);
}