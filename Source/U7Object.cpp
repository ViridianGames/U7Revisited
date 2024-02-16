#include "Globals.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "Config.h"

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
   m_drawType = ObjectDrawTypes::OBJECT_DRAW_LAST;

   m_Texture = nullptr;

   if (g_shapeTable[unitType][frame] != nullptr)
   {
      m_Texture = g_shapeTable[unitType][frame];
	}
   else
   {
      for (int i = 0; i < 32; ++i)
      {
         if(g_shapeTable[unitType][i] != nullptr)
         m_Texture = g_shapeTable[unitType][i];
      }
   }

   //  Still nullptr?  Default back to the dropshadow.
   if (m_Texture == nullptr)
   {
      m_Texture = g_ResourceManager->GetTexture("Images/dropshadow.png", false);
	}

   m_DropShadow = g_ResourceManager->GetTexture("Images/dropshadow.png", false);

   m_distanceFromCamera = 0;

   ObjectDrawTypes drawType = std::get<0>(g_ObjectTypes.at(m_ObjectType));

   SetupDrawType(drawType, false);
 
}

void U7Object::SetupDrawType(ObjectDrawTypes drawType, bool reloadTexture)
{
   ObjectData* objectData = &g_objectTable[m_ObjectType];

   if (m_drawType == drawType && !reloadTexture)
   {
		return;
	}

   m_drawType = drawType;

   if (m_drawType == ObjectDrawTypes::OBJECT_DRAW_BILLBOARD)
   {
      m_Scaling = glm::vec3(m_Texture->GetWidth() / 8.0f, m_Texture->GetHeight() / 8.0f, 1);
   }
   else if (m_drawType == ObjectDrawTypes::OBJECT_DRAW_FLAT)
   {
      m_Scaling = glm::vec3(-m_Texture->GetWidth() / 8.0f, 0, -m_Texture->GetHeight() / 8.0f);
   }
   else
   {
      m_Scaling = glm::vec3(objectData->m_width, objectData->m_height, objectData->m_depth);
   }

   //  If this is a static cuboid object, we need to set the UV coordinates based on the texture.
   if (m_drawType == ObjectDrawTypes::OBJECT_DRAW_CUBOID)
   {
      if (objectData->m_mesh == nullptr || reloadTexture)
      {
         objectData->m_mesh = std::make_unique<Mesh>();
         objectData->m_mesh->Load("Data/Meshes/cuboid.txt");

         float squareX = (objectData->m_width * 8.0f) / float(m_Texture->GetWidth());
         float squareY = (objectData->m_depth * 8.0f) / float(m_Texture->GetHeight());

         float   slantX = 1;
         float   slantY = 1;
         float   slantOffset = 1 - squareX;

         vector<Vertex> customVertices;

         customVertices.push_back(CreateVertex(0, 0.0f, 0, 1, 1, 1, 1, 0.0f, 0.0f)); // bottom face
         customVertices.push_back(CreateVertex(0, 0.0f, -1, 1, 1, 1, 1, 0.0f, squareY));
         customVertices.push_back(CreateVertex(-1, 0.0f, -1, 1, 1, 1, 1, squareX, squareY));
         customVertices.push_back(CreateVertex(-1, 0.0f, -1, 1, 1, 1, 1, squareX, squareY));
         customVertices.push_back(CreateVertex(-1, 0.0f, 0, 1, 1, 1, 1, squareX, 0.0f));
         customVertices.push_back(CreateVertex(0, 0.0f, 0, 1, 1, 1, 1, 0.0f, 0.0f));

         customVertices.push_back(CreateVertex(0, 1, 0, 1, 1, 1, 1, squareX, squareY)); // front face
         customVertices.push_back(CreateVertex(0, 0.0f, 0, 1, 1, 1, 1, squareX, 1));
         customVertices.push_back(CreateVertex(-1, 0, 0, 1, 1, 1, 1, 0, 1));
         customVertices.push_back(CreateVertex(-1, 0, 0, 1, 1, 1, 1, 0, 1));
         customVertices.push_back(CreateVertex(-1, 1, 0, 1, 1, 1, 1, 0, squareY));
         customVertices.push_back(CreateVertex(0, 1, 0, 1, 1, 1, 1, squareX, squareY));

         customVertices.push_back(CreateVertex(0, 1, -1, 1, 1, 1, 1, 0.0f, squareY)); // back face
         customVertices.push_back(CreateVertex(0, 0, -1, 1, 1, 1, 1, 0.0f, 1));
         customVertices.push_back(CreateVertex(-1, 0, -1, 1, 1, 1, 1, squareX, 1));
         customVertices.push_back(CreateVertex(-1, 0, -1, 1, 1, 1, 1, squareX, 1));
         customVertices.push_back(CreateVertex(-1, 1, -1, 1, 1, 1, 1, squareX, squareY));
         customVertices.push_back(CreateVertex(0, 1, -1, 1, 1, 1, 1, 0.0f, squareY));

         customVertices.push_back(CreateVertex(-1, 1.0f, -1, 1, 1, 1, 1, squareX, squareY)); // right face
         customVertices.push_back(CreateVertex(-1, 0.0f, -1, 1, 1, 1, 1, 1, squareY));
         customVertices.push_back(CreateVertex(-1, 0.0f, 0, 1, 1, 1, 1, 1, 0));
         customVertices.push_back(CreateVertex(-1, 0.0f, 0, 1, 1, 1, 1, 1, 0));
         customVertices.push_back(CreateVertex(-1, 1.0f, 0, 1, 1, 1, 1, squareX, 0));
         customVertices.push_back(CreateVertex(-1, 1.0f, -1, 1, 1, 1, 1, squareX, squareY));

         customVertices.push_back(CreateVertex(0, 0.0f, 0, 1, 1, 1, 1, 1, squareY)); // left face
         customVertices.push_back(CreateVertex(0, 1.0f, 0, 1, 1, 1, 1, squareX, squareY));
         customVertices.push_back(CreateVertex(0, 1.0f, -1, 1, 1, 1, 1, squareX, 0));
         customVertices.push_back(CreateVertex(0, 1.0f, -1, 1, 1, 1, 1, squareX, 0));
         customVertices.push_back(CreateVertex(0, 0.0f, -1, 1, 1, 1, 1, 1, 0.0f));
         customVertices.push_back(CreateVertex(0, 0.0f, 0, 1, 1, 1, 1, 1, squareY));

         customVertices.push_back(CreateVertex(0, 1.0f, 0, 1, 1, 1, 1, squareX, squareY)); // top face
         customVertices.push_back(CreateVertex(0, 1.0f, -1, 1, 1, 1, 1, squareX, 0));
         customVertices.push_back(CreateVertex(-1, 1.0f, -1, 1, 1, 1, 1, 0, 0));
         customVertices.push_back(CreateVertex(-1, 1.0f, -1, 1, 1, 1, 1, 0, 0));
         customVertices.push_back(CreateVertex(-1, 1.0f, 0, 1, 1, 1, 1, 0, squareY));
         customVertices.push_back(CreateVertex(0, 1.0f, 0, 1, 1, 1, 1, squareX, squareY));

         objectData->m_mesh->UpdateVertices(customVertices);

         FixupTextureCuboid();
      }
   }

   if (m_drawType == ObjectDrawTypes::OBJECT_DRAW_TABLE)
   {
      if (objectData->m_mesh == nullptr || reloadTexture )
      {
         objectData->m_mesh = std::make_unique<Mesh>();
         objectData->m_mesh->Load("Data/Meshes/cuboid.txt");

         float squareX = (objectData->m_width * 8.0f) / float(m_Texture->GetWidth());
         float squareY = (objectData->m_depth * 8.0f) / float(m_Texture->GetHeight());

         float   slantX = 1;
         float   slantY = 1;
         float   slantOffset = 1 - squareX;

         vector<Vertex> customVertices;

         customVertices.push_back(CreateVertex(0, 1, 0, 1, 1, 1, 1, squareX, squareY)); // front face
         customVertices.push_back(CreateVertex(0, 0, 0, 1, 1, 1, 1, squareX, 1));
         customVertices.push_back(CreateVertex(-1, 0, 0, 1, 1, 1, 1, 0, 1));
         customVertices.push_back(CreateVertex(-1, 0, 0, 1, 1, 1, 1, 0, 1));
         customVertices.push_back(CreateVertex(-1, 1, 0, 1, 1, 1, 1, 0, squareY));
         customVertices.push_back(CreateVertex(0, 1, 0, 1, 1, 1, 1, squareX, squareY));

         customVertices.push_back(CreateVertex(0, 1, -1, 1, 1, 1, 1, 0.0f, squareY)); // back face
         customVertices.push_back(CreateVertex(0, 0, -1, 1, 1, 1, 1, 0.0f, 1));
         customVertices.push_back(CreateVertex(-1, 0, -1, 1, 1, 1, 1, squareX, 1));
         customVertices.push_back(CreateVertex(-1, 0, -1, 1, 1, 1, 1, squareX, 1));
         customVertices.push_back(CreateVertex(-1, 1, -1, 1, 1, 1, 1, squareX, squareY));
         customVertices.push_back(CreateVertex(0, 1, -1, 1, 1, 1, 1, 0.0f, squareY));

         customVertices.push_back(CreateVertex(-1, 1.0f, -1, 1, 1, 1, 1, squareX, squareY)); // right face
         customVertices.push_back(CreateVertex(-1, 0.0f, -1, 1, 1, 1, 1, 1, squareY));
         customVertices.push_back(CreateVertex(-1, 0.0f, 0, 1, 1, 1, 1, 1, 0));
         customVertices.push_back(CreateVertex(-1, 0.0f, 0, 1, 1, 1, 1, 1, 0));
         customVertices.push_back(CreateVertex(-1, 1.0f, 0, 1, 1, 1, 1, squareX, 0));
         customVertices.push_back(CreateVertex(-1, 1.0f, -1, 1, 1, 1, 1, squareX, squareY));

         customVertices.push_back(CreateVertex(0, 0.0f, 0, 1, 1, 1, 1, 1, squareY)); // left face
         customVertices.push_back(CreateVertex(0, 1.0f, 0, 1, 1, 1, 1, squareX, squareY));
         customVertices.push_back(CreateVertex(0, 1.0f, -1, 1, 1, 1, 1, squareX, 0));
         customVertices.push_back(CreateVertex(0, 1.0f, -1, 1, 1, 1, 1, squareX, 0));
         customVertices.push_back(CreateVertex(0, 0.0f, -1, 1, 1, 1, 1, 1, 0.0f));
         customVertices.push_back(CreateVertex(0, 0.0f, 0, 1, 1, 1, 1, 1, squareY));

         customVertices.push_back(CreateVertex(0, 1.0f, 0, 1, 1, 1, 1, squareX, squareY)); // top face
         customVertices.push_back(CreateVertex(0, 1.0f, -1, 1, 1, 1, 1, squareX, 0));
         customVertices.push_back(CreateVertex(-1, 1.0f, -1, 1, 1, 1, 1, 0, 0));
         customVertices.push_back(CreateVertex(-1, 1.0f, -1, 1, 1, 1, 1, 0, 0));
         customVertices.push_back(CreateVertex(-1, 1.0f, 0, 1, 1, 1, 1, 0, squareY));
         customVertices.push_back(CreateVertex(0, 1.0f, 0, 1, 1, 1, 1, squareX, squareY));

         objectData->m_mesh->UpdateVertices(customVertices);

         FixupTextureCuboid();
      }
   }

   if (m_drawType == ObjectDrawTypes::OBJECT_DRAW_HANGINGEW)
   {
      if (objectData->m_mesh == nullptr)
      {
         objectData->m_mesh = std::make_unique<Mesh>();
         objectData->m_mesh->Load("Data/Meshes/cuboid.txt");
         FixupTextureHangingNS();
      }

      float squareX = (objectData->m_width * 8.0f) / float(m_Texture->GetWidth());
      float squareY = (objectData->m_depth * 8.0f) / float(m_Texture->GetHeight());

      float   slantX = 1;
      float   slantY = 1;
      float   slantOffset = 1 - squareX;

      vector<Vertex> customVertices;

      customVertices.push_back(CreateVertex(-1, 1.0f, -1, 1, 1, 1, 1, squareX, squareY)); // right face
      customVertices.push_back(CreateVertex(-1, 0.0f, -1, 1, 1, 1, 1, 1, squareY));
      customVertices.push_back(CreateVertex(-1, 0.0f, 0, 1, 1, 1, 1, 1, 0));
      customVertices.push_back(CreateVertex(-1, 0.0f, 0, 1, 1, 1, 1, 1, 0));
      customVertices.push_back(CreateVertex(-1, 1.0f, 0, 1, 1, 1, 1, squareX, 0));
      customVertices.push_back(CreateVertex(-1, 1.0f, -1, 1, 1, 1, 1, squareX, squareY));

      objectData->m_mesh->UpdateVertices(customVertices);
   }

   if (m_drawType == ObjectDrawTypes::OBJECT_DRAW_HANGINGEW)
   {
      if (objectData->m_mesh == nullptr)
      {
         objectData->m_mesh = std::make_unique<Mesh>();
         objectData->m_mesh->Load("Data/Meshes/cuboid.txt");
         FixupTextureHangingEW();
      }

      float squareX = (objectData->m_width * 8.0f) / float(m_Texture->GetWidth());
      float squareY = (objectData->m_depth * 8.0f) / float(m_Texture->GetHeight());

      float   slantX = 1;
      float   slantY = 1;
      float   slantOffset = 1 - squareX;

      vector<Vertex> customVertices;

      customVertices.push_back(CreateVertex( 0, 1, 0, 1, 1, 1, 1, squareX, squareY)); // front face
      customVertices.push_back(CreateVertex( 0, 0, 0, 1, 1, 1, 1, squareX, 1));
      customVertices.push_back(CreateVertex(-1, 0, 0, 1, 1, 1, 1, 0, 1));
      customVertices.push_back(CreateVertex(-1, 0, 0, 1, 1, 1, 1, 0, 1));
      customVertices.push_back(CreateVertex(-1, 1, 0, 1, 1, 1, 1, 0, squareY));
      customVertices.push_back(CreateVertex( 0, 1, 0, 1, 1, 1, 1, squareX, squareY));

      objectData->m_mesh->UpdateVertices(customVertices);
   }

};

void U7Object::FixupTextureCuboid()
{
   //  Fixup the texture for this object.

   //  The top-left corner of this texture, up to objectWidth * 8 and objectDepth * 8, are correct.
   //  Below and to the right of this area, the texture needs to be shifted to the left (if below)
   //  and up (if to the right).

   ObjectData* objectData = &g_objectTable[m_ObjectType];

   //  Front face
   for (int theseFrames = 0; theseFrames < 32; ++theseFrames)
   {
      Texture* workingTexture = g_shapeTable[m_ObjectType][theseFrames];
      if (workingTexture == nullptr)
      {
         continue;
      }

      int countery = objectData->m_depth * 8 + 1;
      for (int i = countery; i < workingTexture->GetHeight(); ++i)
      {
         int counterx = 0;
         for (int y = i; y < workingTexture->GetHeight(); ++y)
         {
            for (int x = counterx; x < counterx + objectData->m_width * 8; ++x)
            {
               Color pixel = workingTexture->GetPixel(x + 1, y);
               workingTexture->PutPixel(x, y, pixel);
            }

            workingTexture->PutPixel(counterx + objectData->m_width * 8, y, Color(0, 0, 0, 0));
            ++counterx;
         }
      }

      //  Right face
      int counterx = objectData->m_width * 8 + 1;
      for (int i = counterx; i < workingTexture->GetWidth(); ++i)
      {
         int countery = 1;
         for (int x = i; x < workingTexture->GetWidth(); ++x)
         {
            for (int y = countery; y < countery + objectData->m_depth * 8; ++y)
            {
               Color pixel = workingTexture->GetPixel(x, y + 1);
               workingTexture->PutPixel(x, y, pixel);
            }

            workingTexture->PutPixel(x, countery + objectData->m_depth * 8, Color(0, 0, 0, 0));
            ++countery;
         }
      }

      workingTexture->UpdateData();
   }
}

void U7Object::Draw()
{
   if (!(g_StateMachine->GetCurrentState() == STATE_OBJECTEDITORSTATE))
   {
      if (m_Pos.y > 4)
         return;
	}
   //if (m_ObjectType != 191)
   //   return;
   ObjectData* objectData = &g_objectTable[m_ObjectType];
   static float zrotation = 0;
   if (m_Visible)
   {
      switch (m_drawType)
      {
      case ObjectDrawTypes::OBJECT_DRAW_CUBOID:
      case ObjectDrawTypes::OBJECT_DRAW_TABLE:
      {
         //g_Display->DrawMesh(g_ResourceManager->GetMesh("Data/Meshes/dropshadow.txt"), m_Pos, m_DropShadow, Color(1, 1, 1, 1), glm::vec3(0, 0, 0));
         glm::vec3 thisPos = m_Pos;
         thisPos.x += 1;
         thisPos.z += 1;
         thisPos.y += thisPos.y * .01f;
         g_Display->DrawMesh(objectData->m_mesh.get(), thisPos, m_Texture, Color(1, 1, 1, 1), glm::vec3(0, 0, 0), m_Scaling);
         break;
      }

      case ObjectDrawTypes::OBJECT_DRAW_FLAT:
      {
         glm::vec3 thisPos = m_Pos;
         thisPos.x += 1;
         thisPos.z += 1;
         if(thisPos.y > 0)
         {
             thisPos.y += thisPos.y * .01f;
         }
         else
         {
             thisPos.y = .01f;
         }

         g_Display->DrawMesh(g_ResourceManager->GetMesh("Data/Meshes/dropshadow.txt"), thisPos, m_Texture, Color(1, 1, 1, 1), glm::vec3(0, 0, 0), m_Scaling);
         break;
      }

      case ObjectDrawTypes::OBJECT_DRAW_BILLBOARD:
      case ObjectDrawTypes::OBJECT_DRAW_CUSTOM_MESH:
      {
         float angle = g_Display->GetCameraAngle();
         angle += 45;
         glm::vec3 thisPos = m_Pos;
         //thisPos.x += m_Scaling.x / 4;
         //thisPos.z += m_Scaling.z / 4;
         //thisPos.y += .1f;
         //g_Display->DrawMesh(g_ResourceManager->GetMesh("Data/Meshes/dropshadow.txt"), thisPos, m_DropShadow, Color(1, 1, 1, 1), glm::vec3(0, 0, 0), glm::vec3(m_Scaling.x / 3, 1, m_Scaling.x / 3));
         //thisPos = m_Pos;
         thisPos.x += 0.5f;
         thisPos.z += 0.5f;
         thisPos.y -= .5f;
         g_Display->DrawMesh(g_ResourceManager->GetMesh("Data/Meshes/billboard.txt"), thisPos, m_Texture, Color(1, 1, 1, 1), glm::vec3(0, angle, 0), m_Scaling);
         break;
      }

      }

   }
   zrotation += 0.01f;
}

void U7Object::SetShapeAndFrame(unsigned int shape, unsigned int frame)
{
   m_ObjectType = shape;
   m_Frame = frame;
}

void U7Object::Update()
{
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