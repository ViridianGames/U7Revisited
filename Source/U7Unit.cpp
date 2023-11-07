#include "Globals.h"
#include "U7Globals.h"
#include "U7Unit.h"
#include "Config.h"

using namespace std;

U7Unit::~U7Unit()
{
	Shutdown();
}

void U7Unit::Init(const string& configfile, int unitType)
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
   m_UnitType = unitType;
   SetIsDead(false);
   m_UnitConfig = g_ResourceManager->GetConfig(configfile);
   m_Mesh = g_ResourceManager->GetMesh(m_UnitConfig->GetString("mesh"));
   m_Texture = g_shapeTable[unitType][0];

   ObjectData *objectData = &g_objectTable[unitType];
   m_drawType = std::get<0>(g_ObjectTypes.at(m_UnitType));

   if (m_drawType == ObjectDrawTypes::OBJECT_DRAW_BILLBOARD)
   {
      m_Scaling = glm::vec3(m_Texture->GetWidth() / 8.0f, m_Texture->GetHeight() / 8.0f, 1);
   }
   else
   {
      m_Scaling = glm::vec3(objectData->m_width, objectData->m_height, objectData->m_depth);
   }

}

void U7Unit::Draw()
{
   static float zrotation = 0;
   if( m_Visible)
   {
      //  Draw the unit, then the colored shirt on top of it.
      ObjectDrawTypes type = std::get<0>(g_ObjectTypes.at(m_UnitType));
      switch (type)
      {
      case ObjectDrawTypes::OBJECT_DRAW_CUBOID:
         g_Display->DrawMesh(g_ResourceManager->GetMesh("Data/Meshes/cuboid.txt"), m_Pos, m_Texture, Color(1, 1, 1, 1), glm::vec3(0, 0, 0), m_Scaling);
         break;

      case ObjectDrawTypes::OBJECT_DRAW_BILLBOARD:
         //if (m_UnitType == 181)
         //{
            float angle = g_Display->GetCameraAngle();
            angle += 45;
            //angle /= m_Scaling.y;
            g_Display->DrawMesh(g_ResourceManager->GetMesh("Data/Meshes/billboard.txt"), m_Pos, m_Texture, Color(1, 1, 1, 1), glm::vec3(0, angle, 0), m_Scaling);
         //}
         break;


      }



      
   }
   zrotation += 0.01f;
}

void U7Unit::SetShapeAndFrame(unsigned int shape, unsigned int frame)
{

}

void U7Unit::Update()
{
   ObjectTypes type = std::get<1>(g_ObjectTypes.at(m_UnitType));
   if (type == ObjectTypes::OBJECT_STATIC)
   {
      return;
   }
   
   //  If a unit has an external force (something is pushing it) then it cannot move under
   //  its own power.
   if( m_ExternalForce != glm::vec3(0, 0, 0) )// && m_ExternalForceFlag )
   {
      if( m_GravityFlag )
      {
         m_ExternalForce -= g_Gravity;
      }

      m_Pos += m_ExternalForce;

      //  If we would bounce this frame, do the bounce.
      if( m_Pos.y < g_Terrain->GetHeight( m_Pos.x, m_Pos.z ) )
      {
         m_Pos.y = g_Terrain->GetHeight(m_Pos.x, m_Pos.z);
         if( abs( m_ExternalForce.y ) < .1 )
         {
            m_ExternalForce = glm::vec3( 0, 0, 0 );
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
      if( m_Pos.x != m_Dest.x || m_Pos.z != m_Dest.z )
      {
         if (m_Speed != 0.0f)
         {
            glm::vec3 distance = m_Direction * m_Speed;
            
            //  If this step would take us past our destination, then stop at
            //  our destination.
            glm::vec3 target = m_Pos + distance;
            if( (m_Pos.x < m_Dest.x && target.x >= m_Dest.x ) || (m_Pos.x > m_Dest.x && target.x <= m_Dest.x ) )
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

void U7Unit::Attack(int _UnitID)
{

}

void U7Unit::Shutdown()
{
	
}

bool U7Unit::SelectCheck()
{
   if( m_Mesh->SelectCheck( m_Pos, m_Angle, m_Scaling) ) 
      return true;
   
   return false;
}

void U7Unit::SetDest(glm::vec3 dest)
{
   m_Dest = dest;
   m_Direction = m_Dest - m_Pos;
   m_Direction = glm::normalize(m_Direction);
}