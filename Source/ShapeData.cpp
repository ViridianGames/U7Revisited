#include <sstream>
#include <fstream>
#include <string>

#include "Globals.h"
#include "U7Globals.h"
#include "ShapeData.h"
#include "Config.h"

using namespace std;

ShapeData::ShapeData()
{
	m_isValid = false;
	m_shape = 150;
	m_frame = 0;
}

void ShapeData::Init(int shape, int frame)
{
	m_shape = shape;
	m_frame = frame;

	stringstream filename;
	filename << "Images/Objects/" << std::to_string(shape) << "-" << std::to_string(frame) << ".png";
	if (g_ResourceManager->DoesFileExist(filename.str()))
	{
		m_isValid = true;
		m_defaultTexture = g_ResourceManager->GetTexture(filename.str(), false);

      //  We need local copies of this texture for three sides of the cuboid.
      m_topTexture = std::make_unique<Texture>();
      m_topTexture->Create(m_defaultTexture->GetWidth(), m_defaultTexture->GetHeight(), false);
      m_topTexture->SetPixelData(m_defaultTexture->GetPixelData());
      m_frontTexture = std::make_unique<Texture>();
		m_frontTexture->Create(m_defaultTexture->GetWidth(), m_defaultTexture->GetHeight(), false);
      m_frontTexture->SetPixelData(m_defaultTexture->GetPixelData());
      m_rightTexture = std::make_unique<Texture>();
		m_rightTexture->Create(m_defaultTexture->GetWidth(), m_defaultTexture->GetHeight(), false);
      m_rightTexture->SetPixelData(m_defaultTexture->GetPixelData());


      m_drawType = std::get<0>(g_ObjectTypes.at(shape));

      SetupDrawTypes();
	}
   else
   {
      m_isValid = false;
   }
}

void ShapeData::Serialize()
{

}

void ShapeData::Deserialize()
{

}

void ShapeData::SetupDrawTypes()
{
   ObjectData* objectData = &g_objectTable[m_shape];

   if (m_drawType == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
   {
      m_Scaling = glm::vec3(m_defaultTexture->GetWidth() / 8.0f, m_defaultTexture->GetHeight() / 8.0f, 1);
   }
   else if (m_drawType == ShapeDrawType::OBJECT_DRAW_HANGINGEW)
   {
      m_Scaling = glm::vec3(objectData->m_width * 1.5, objectData->m_height, objectData->m_depth);
   }
   else if (m_drawType == ShapeDrawType::OBJECT_DRAW_HANGINGNS)
   {
      m_Scaling = glm::vec3(objectData->m_width, objectData->m_height, objectData->m_depth);
   }
   else if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
   {
      m_Scaling = glm::vec3(-m_defaultTexture->GetWidth() / 8.0f, 0, -m_defaultTexture->GetHeight() / 8.0f);
   }
   else
   {
      m_Scaling = glm::vec3(objectData->m_width, objectData->m_height, objectData->m_depth);
   }

   //  Create the six meshes that we can individually turn on and off (and texture).
   m_meshes[static_cast<int>(CuboidSides::CUBOID_BACK)] = g_ResourceManager->GetMesh("Data/Meshes/cuboidback.txt");
   m_meshes[static_cast<int>(CuboidSides::CUBOID_FRONT)] = g_ResourceManager->GetMesh("Data/Meshes/cuboidfront.txt");
   m_meshes[static_cast<int>(CuboidSides::CUBOID_LEFT)] = g_ResourceManager->GetMesh("Data/Meshes/cuboidleft.txt");
   m_meshes[static_cast<int>(CuboidSides::CUBOID_RIGHT)] = g_ResourceManager->GetMesh("Data/Meshes/cuboidright.txt");
   m_meshes[static_cast<int>(CuboidSides::CUBOID_TOP)] = g_ResourceManager->GetMesh("Data/Meshes/cuboidtop.txt");
   m_meshes[static_cast<int>(CuboidSides::CUBOID_BOTTOM)] = g_ResourceManager->GetMesh("Data/Meshes/cuboidbottom.txt");

   FixupTextures();
};

void ShapeData::FixupTextures()
{

   //  Fixup the texture for this object.

   //  The top-left corner of this texture, up to objectWidth * 8 and objectDepth * 8, are correct.
   //  Below and to the right of this area, the texture needs to be shifted to the left (if below)
   //  and up (if to the right).

   ObjectData* objectData = &g_objectTable[m_shape];

   //  Top face
   int topWidth = objectData->m_width * 8 + 1;
   int topHeight = objectData->m_depth * 8;

   m_topTexture->Resize(topWidth, topHeight);

   //  Front face
   
   if (m_defaultTexture->GetWidth() > topWidth && m_defaultTexture->GetHeight() > topHeight)
   {
      //  Move pixels not part of this face off the texture
      for (int j = 0; j < topHeight; ++j)
      {
         for (int i = 0; i < m_frontTexture->GetWidth(); ++i)
         {
            m_frontTexture->MoveColumnUp(i);
         }
      }

      //  Shift slanted pixels to unslant
      int counter = 1;
      for (int i = 0; i < m_frontTexture->GetHeight() - objectData->m_depth * 8; ++i)
      {
         for (int k = 0; k < counter; ++k)
         {
            m_frontTexture->MoveRowLeft(i);
         }
         ++counter;
      }

      m_frontTexture->Resize(topWidth, m_frontTexture->GetHeight() - objectData->m_depth * 8);
   }

   //  Right face
   if (m_defaultTexture->GetWidth() > topWidth && m_defaultTexture->GetHeight() > topHeight)
   {
      //  Move pixels not part of this face off the texture
      for (int j = 0; j < topWidth; ++j)
      {
         for (int i = 0; i < m_rightTexture->GetHeight(); ++i)
         {
            m_rightTexture->MoveRowLeft(i);
         }
      }

      //  Shift slanted pixels to unslant
      int counter = 1;
      for (int i = 0; i < m_rightTexture->GetWidth() - objectData->m_width * 8; ++i)
      {
         for(int k = 0; k < counter; ++k)
         {
            m_rightTexture->MoveColumnUp(i);
         }
         ++counter;
      }

      m_rightTexture->Resize(m_rightTexture->GetWidth() - objectData->m_width * 8 - 1, topHeight);
   }
}

void ShapeData::Draw(const glm::vec3& pos, float angle, Color color)
{
   if (m_isValid == false)
   {
		return;
	}

   ObjectData* objectData = &g_objectTable[m_shape];

   if (m_drawType == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
   {
      m_Scaling = glm::vec3(m_defaultTexture->GetWidth() / 8.0f, m_defaultTexture->GetHeight() / 8.0f, 1);
   }
   else if (m_drawType == ShapeDrawType::OBJECT_DRAW_HANGINGEW)
   {
      m_Scaling = glm::vec3(objectData->m_width * 1.5, objectData->m_height, objectData->m_depth);
   }
   else if (m_drawType == ShapeDrawType::OBJECT_DRAW_HANGINGNS)
   {
      m_Scaling = glm::vec3(objectData->m_width, objectData->m_height, objectData->m_depth);
   }
   else if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
   {
      m_Scaling = glm::vec3(-m_defaultTexture->GetWidth() / 8.0f, 0, -m_defaultTexture->GetHeight() / 8.0f);
   }
   else
   {
      m_Scaling = glm::vec3(objectData->m_width, objectData->m_height, objectData->m_depth);
   }

   switch (m_drawType)
   {
      case ShapeDrawType::OBJECT_DRAW_CUBOID:
      {
         glm::vec3 thisPos = pos;
         thisPos.x -= m_Scaling.x - 1;
         thisPos.z -= m_Scaling.z - 1;
         thisPos.y += thisPos.y * .01f;
			g_Display->DrawMesh(m_meshes[static_cast<int>(CuboidSides::CUBOID_TOP)], thisPos, m_topTexture.get(), color, glm::vec3(0, 0, 0), m_Scaling);
         g_Display->DrawMesh(m_meshes[static_cast<int>(CuboidSides::CUBOID_BOTTOM)], thisPos, m_topTexture.get(), color, glm::vec3(0, 0, 0), m_Scaling);
         g_Display->DrawMesh(m_meshes[static_cast<int>(CuboidSides::CUBOID_FRONT)], thisPos, m_frontTexture.get(), color, glm::vec3(0, 0, 0), m_Scaling);
         g_Display->DrawMesh(m_meshes[static_cast<int>(CuboidSides::CUBOID_BACK)], thisPos, m_frontTexture.get(), color, glm::vec3(0, 0, 0), m_Scaling);
         g_Display->DrawMesh(m_meshes[static_cast<int>(CuboidSides::CUBOID_RIGHT)], thisPos, m_rightTexture.get(), color, glm::vec3(0, 0, 0), m_Scaling);
         g_Display->DrawMesh(m_meshes[static_cast<int>(CuboidSides::CUBOID_LEFT)], thisPos, m_rightTexture.get(), color, glm::vec3(0, 0, 0), m_Scaling);
         break;
      }

      case ShapeDrawType::OBJECT_DRAW_TABLE:
      {
         glm::vec3 thisPos = pos;
         thisPos.x -= m_Scaling.x - 1;
         thisPos.z -= m_Scaling.z - 1;
         thisPos.y += thisPos.y * .01f;
         for (int i = 1; i < static_cast<int>(CuboidSides::CUBOID_LAST); ++i)
         {
            g_Display->DrawMesh(m_meshes[i], thisPos, m_defaultTexture, color, glm::vec3(0, 0, 0), m_Scaling);
         }
         break;
      }

      case ShapeDrawType::OBJECT_DRAW_HANGINGNS:
      case ShapeDrawType::OBJECT_DRAW_HANGINGEW:
      {
         glm::vec3 thisPos = pos;
         thisPos.x += 1;
         thisPos.z += 1;
         thisPos.y += thisPos.y * .01f;
         g_Display->DrawMesh(m_meshes[static_cast<int>(CuboidSides::CUBOID_BACK)], thisPos, m_defaultTexture, color, glm::vec3(0, 0, 0), m_Scaling);
         break;
      }

      case ShapeDrawType::OBJECT_DRAW_FLAT:
      {
         glm::vec3 thisPos = pos;
         thisPos.x += 1;
         thisPos.z += 1;
         if (thisPos.y > 0)
         {
            thisPos.y += thisPos.y * .01f;
         }
         else
         {
            thisPos.y = .01f;
         }

         g_Display->DrawMesh(m_meshes[static_cast<int>(CuboidSides::CUBOID_BOTTOM)], thisPos, m_defaultTexture, color, glm::vec3(0, 0, 0), m_Scaling);
         break;
      }

      case ShapeDrawType::OBJECT_DRAW_BILLBOARD:
      case ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH:
      {
         float angle = g_Display->GetCameraAngle();
         angle += 45;
         glm::vec3 thisPos = pos;
         //thisPos.x += m_Scaling.x / 4;
         //thisPos.z += m_Scaling.z / 4;
         //thisPos.y += .1f;
         //g_Display->DrawMesh(g_ResourceManager->GetMesh("Data/Meshes/dropshadow.txt"), thisPos, m_DropShadow, Color(1, 1, 1, 1), glm::vec3(0, 0, 0), glm::vec3(m_Scaling.x / 3, 1, m_Scaling.x / 3));
         //thisPos = m_Pos;
         thisPos.x += 0.5f;
         thisPos.z += 0.5f;
         thisPos.y -= .5f;
         g_Display->DrawMesh(g_ResourceManager->GetMesh("Data/Meshes/billboard.txt"), thisPos, m_defaultTexture, color, glm::vec3(0, angle, 0), m_Scaling);
         break;
      }
   }
}