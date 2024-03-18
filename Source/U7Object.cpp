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

   ObjectTypes type = std::get<1>(g_ObjectTypes.at(m_ObjectType));
   if (type == ObjectTypes::OBJECT_STATIC)
   {
      return;
   }

   //  If a unit has an external force (something is pushing it) then it cannot move under
   //  its own power.
   if (m_ExternalForce != glm::vec3(0, 0, 0))// && m_ExternalForceFlag )
   {
      if (m_GravityFlag)
      {
         m_ExternalForce -= g_Gravity;
      }

      m_Pos += m_ExternalForce;

      //  If we would bounce this frame, do the bounce.
      if (m_Pos.y < g_Terrain->GetHeight(m_Pos.x, m_Pos.z))
      {
         m_Pos.y = g_Terrain->GetHeight(m_Pos.x, m_Pos.z);
         if (abs(m_ExternalForce.y) < .1)
         {
            m_ExternalForce = glm::vec3(0, 0, 0);
         }
         else
         {
            m_ExternalForce.y = -m_ExternalForce.y;
            m_ExternalForce *= .5f;
         }
      }
   }
   //  Handle normal movement
   else
   {
      if (m_Pos.x != m_Dest.x || m_Pos.z != m_Dest.z)
      {
         if (m_Speed != 0.0f)
         {
            glm::vec3 distance = m_Direction * m_Speed;

            //  If this step would take us past our destination, then stop at
            //  our destination.
            glm::vec3 target = m_Pos + distance;
            if ((m_Pos.x < m_Dest.x && target.x >= m_Dest.x) || (m_Pos.x > m_Dest.x && target.x <= m_Dest.x))
            {
               m_Pos = m_Dest;
               m_Direction = glm::vec3(0, 0, 0);
            }
            else
            {
               m_Pos += distance;
            }
         }
      }

      //  Pop to terrain.  If we're moving under our own power, we should always stay
      //  at the height of the terrain.
      m_Pos.y = g_Terrain->GetHeight(m_Pos.x, m_Pos.z);
   }

   //  Visilibity is set by the terrain so it should always be set to false here.
   m_Visible = false;

   // Handle external force and gravity

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