#include <sstream>
#include <fstream>
#include <string>

#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "Geist/Config.h"
#include "U7Globals.h"
#include "ShapeData.h"

using namespace std;

ShapeData::ShapeData()
{
	m_isValid = false;
	m_shape = 150;
	m_frame = 0;

   for (int i = 0; i < 6; ++i)
   {
		m_sideTexture[i] = CuboidTexture::CUBOID_INVALID;
	}
}

void ShapeData::Init(int shape, int frame, bool shouldreset)
{
	m_shape = shape;
	m_frame = frame;

   if(m_defaultTexture != nullptr)
	{
		m_isValid = true;

      //  We need local copies of this texture for three sides of the cuboid.
      if (m_topTexture == nullptr)
      {
         m_topTexture = std::make_unique<ModTexture>(m_defaultTexture->m_Image);
      }
      if (m_frontTexture == nullptr)
      {
         m_frontTexture = std::make_unique<ModTexture>(m_defaultTexture->m_Image);
      }
      if (m_rightTexture == nullptr)
      {
         m_rightTexture = std::make_unique<ModTexture>(m_defaultTexture->m_Image);
      }

      ObjectData* objectData = &g_objectTable[m_shape];

      if (shouldreset)
      {
			ResetTopTexture();
			ResetFrontTexture();
			ResetRightTexture();
		}

      for (int i = 0; i < 6; ++i)
      {
         if (m_sideTexture[i] == CuboidTexture::CUBOID_INVALID)
         {
            switch (static_cast<CuboidSides>(i))
            {
               case CuboidSides::CUBOID_TOP:
               case CuboidSides::CUBOID_BOTTOM:
						m_sideTexture[i] = CuboidTexture::CUBOID_DRAW_TOP;
						break;
               case CuboidSides::CUBOID_LEFT:
               case CuboidSides::CUBOID_RIGHT:
   					m_sideTexture[i] = CuboidTexture::CUBOID_DRAW_RIGHT;
						break;
               case CuboidSides::CUBOID_BACK:
               case CuboidSides::CUBOID_FRONT:
						m_sideTexture[i] = CuboidTexture::CUBOID_DRAW_FRONT;
						break;
            }
         }
      }

      //m_sideTexture[static_cast<int>(CuboidSides::CUBOID_TOP)] = CuboidTexture::CUBOID_DRAW_TOP;
      //m_sideTexture[static_cast<int>(CuboidSides::CUBOID_BOTTOM)] = CuboidTexture::CUBOID_DRAW_TOP;
      //m_sideTexture[static_cast<int>(CuboidSides::CUBOID_FRONT)] = CuboidTexture::CUBOID_DRAW_FRONT;
      //m_sideTexture[static_cast<int>(CuboidSides::CUBOID_BACK)] = CuboidTexture::CUBOID_DRAW_FRONT;
      //m_sideTexture[static_cast<int>(CuboidSides::CUBOID_LEFT)] = CuboidTexture::CUBOID_DRAW_RIGHT;
      //m_sideTexture[static_cast<int>(CuboidSides::CUBOID_RIGHT)] = CuboidTexture::CUBOID_DRAW_RIGHT;

      SetupDrawTypes();
	}
   else
   {
      m_isValid = false;
   }
}

void ShapeData::SetDefaultTexture(Image image)
{
   if (m_defaultTexture == nullptr)
   {
		m_defaultTexture = std::make_unique<ModTexture>(image);
	}
   else
   {
		m_defaultTexture->AssignImage(image);
	}
}

void ShapeData::CreateDefaultTexture()
{
   if (m_defaultTexture == nullptr)
   {
		m_defaultTexture = std::make_unique<ModTexture>();
	}
}

void ShapeData::Serialize(ofstream& outStream)
{
   outStream << m_shape << " ";
   outStream << m_frame << " ";
   outStream << m_topTextureOffsetX << " ";
   outStream << m_topTextureOffsetY << " ";
   outStream << m_topTextureWidth << " ";
   outStream << m_topTextureHeight << " ";
   outStream << m_frontTextureOffsetX << " ";
   outStream << m_frontTextureOffsetY << " ";
   outStream << m_frontTextureWidth << " ";
   outStream << m_frontTextureHeight << " ";
   outStream << m_rightTextureOffsetX << " ";
   outStream << m_rightTextureOffsetY << " ";
   outStream << m_rightTextureWidth << " ";
   outStream << m_rightTextureHeight << " ";
   outStream << static_cast<int>(m_drawType) << " ";
   outStream << m_Scaling.x << " ";
   outStream << m_Scaling.y << " ";
   outStream << m_Scaling.z << " ";
   outStream << static_cast<int>(m_sideTexture[0]) << " ";
   outStream << static_cast<int>(m_sideTexture[1]) << " ";
   outStream << static_cast<int>(m_sideTexture[2]) << " ";
   outStream << static_cast<int>(m_sideTexture[3]) << " ";
   outStream << static_cast<int>(m_sideTexture[4]) << " ";
   outStream << static_cast<int>(m_sideTexture[5]) << " ";
   outStream << endl;

   outStream.flush();
}

void ShapeData::Deserialize(ifstream& inStream)
{
   inStream >> m_shape;
	inStream >> m_frame;
	inStream >> m_topTextureOffsetX;
	inStream >> m_topTextureOffsetY;
	inStream >> m_topTextureWidth;
	inStream >> m_topTextureHeight;
	inStream >> m_frontTextureOffsetX;
	inStream >> m_frontTextureOffsetY;
	inStream >> m_frontTextureWidth;
	inStream >> m_frontTextureHeight;
	inStream >> m_rightTextureOffsetX;
	inStream >> m_rightTextureOffsetY;
	inStream >> m_rightTextureWidth;
	inStream >> m_rightTextureHeight;
	int drawType;
	inStream >> drawType;
	m_drawType = static_cast<ShapeDrawType>(drawType);
	inStream >> m_Scaling.x;
	inStream >> m_Scaling.y;
	inStream >> m_Scaling.z;
	int sideTexture;
	inStream >> sideTexture;
	m_sideTexture[0] = static_cast<CuboidTexture>(sideTexture);
	inStream >> sideTexture;
	m_sideTexture[1] = static_cast<CuboidTexture>(sideTexture);
	inStream >> sideTexture;
	m_sideTexture[2] = static_cast<CuboidTexture>(sideTexture);
	inStream >> sideTexture;
	m_sideTexture[3] = static_cast<CuboidTexture>(sideTexture);
	inStream >> sideTexture;
	m_sideTexture[4] = static_cast<CuboidTexture>(sideTexture);
	inStream >> sideTexture;
	m_sideTexture[5] = static_cast<CuboidTexture>(sideTexture);

   Init(m_shape, m_frame, false);

}

void ShapeData::ResetTopTexture()
{
   ObjectData* objectData = &g_objectTable[m_shape];

   m_topTextureOffsetX = 0;
   m_topTextureOffsetY = 0;
   m_topTextureWidth = objectData->m_width * 8;
   m_topTextureHeight = objectData->m_depth * 8;

   SafeAndSane();
}

void ShapeData::ResetFrontTexture()
{
   ObjectData* objectData = &g_objectTable[m_shape];

   m_frontTextureOffsetX = 0;
   m_frontTextureOffsetY = objectData->m_depth * 8;
   m_frontTextureWidth = objectData->m_width * 8;
   m_frontTextureHeight = m_defaultTexture->height - objectData->m_depth * 8;

   SafeAndSane();
}


void ShapeData::ResetRightTexture()
{
   ObjectData* objectData = &g_objectTable[m_shape];

   m_rightTextureOffsetX = objectData->m_width * 8;
   m_rightTextureOffsetY = 0;
   m_rightTextureWidth = m_defaultTexture->width - objectData->m_width * 8;
   m_rightTextureHeight = objectData->m_depth * 8;

   SafeAndSane();
}


void ShapeData::SafeAndSane()
{
   if (m_topTextureWidth < 0) { m_topTextureWidth = 0; }
   if (m_topTextureHeight < 0) { m_topTextureHeight = 0; }
   if (m_frontTextureWidth < 0) { m_frontTextureWidth = 0; }
   if (m_frontTextureHeight < 0) { m_frontTextureHeight = 0; }
   if (m_rightTextureWidth < 0) { m_rightTextureWidth = 0; }
   if (m_rightTextureHeight < 0) { m_rightTextureHeight = 0; }

   if (m_topTextureWidth > m_defaultTexture->width) { m_topTextureWidth = m_defaultTexture->width; }
   if (m_topTextureHeight > m_defaultTexture->height) { m_topTextureHeight = m_defaultTexture->height; }
   if (m_frontTextureWidth > m_defaultTexture->width) { m_frontTextureWidth = m_defaultTexture->width; }
   if (m_frontTextureHeight > m_defaultTexture->height) { m_frontTextureHeight = m_defaultTexture->height; }
   if (m_rightTextureWidth > m_defaultTexture->width) { m_rightTextureWidth = m_defaultTexture->width; }
   if (m_rightTextureHeight > m_defaultTexture->height) { m_rightTextureHeight = m_defaultTexture->height; }

   if (m_topTextureOffsetX < 0) { m_topTextureOffsetX = 0; }
   if (m_topTextureOffsetY < 0) { m_topTextureOffsetY = 0; }
   if (m_frontTextureOffsetX < 0) { m_frontTextureOffsetX = 0; }
   if (m_frontTextureOffsetY < 0) { m_frontTextureOffsetY = 0; }
   if (m_rightTextureOffsetX < 0) { m_rightTextureOffsetX = 0; }
   if (m_rightTextureOffsetY < 0) { m_rightTextureOffsetY = 0; }

   if (m_topTextureOffsetX > m_defaultTexture->width) { m_topTextureOffsetX = m_defaultTexture->width; }
   if (m_topTextureOffsetY > m_defaultTexture->height) { m_topTextureOffsetY = m_defaultTexture->height; }
   if (m_frontTextureOffsetX > m_defaultTexture->width) { m_frontTextureOffsetX = m_defaultTexture->width; }
   if (m_frontTextureOffsetY > m_defaultTexture->height) { m_frontTextureOffsetY = m_defaultTexture->height; }
   if (m_rightTextureOffsetX > m_defaultTexture->width) { m_rightTextureOffsetX = m_defaultTexture->width; }
   if (m_rightTextureOffsetY > m_defaultTexture->height) { m_rightTextureOffsetY = m_defaultTexture->height; }


}

void ShapeData::SetupDrawTypes()
{
   ObjectData* objectData = &g_objectTable[m_shape];

   if (m_drawType == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
   {
      m_Scaling = Vector3{ m_defaultTexture->width / 8.0f, m_defaultTexture->height / 8.0f, 1 };
   }
   else if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
   {
      m_Scaling = Vector3{ -m_defaultTexture->width / 8.0f, 0, -m_defaultTexture->height / 8.0f };
   }
   else
   {
      m_Scaling = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
   }

   for(int i = 0; i < 6; ++i)
   {
      m_models[i] = nullptr;
	}  

   //Mesh mesh = GenMeshPlane(m_defaultTexture->width / 8.0f, m_defaultTexture->height / 8.0f, 1, 1);

   //  Create the six meshes that we can individually turn on and off (and texture).
   m_models[static_cast<int>(CuboidSides::CUBOID_BACK)] = &LoadModelFromMesh(GenMeshPlane(m_defaultTexture->width / 8.0f, m_defaultTexture->height / 8.0f, 1, 1));
   m_models[static_cast<int>(CuboidSides::CUBOID_FRONT)] = &LoadModelFromMesh(GenMeshPlane(m_defaultTexture->width / 8.0f, m_defaultTexture->height / 8.0f, 1, 1));
   m_models[static_cast<int>(CuboidSides::CUBOID_LEFT)] = &LoadModelFromMesh(GenMeshPlane(m_defaultTexture->width / 8.0f, m_defaultTexture->height / 8.0f, 1, 1));
   m_models[static_cast<int>(CuboidSides::CUBOID_RIGHT)] = &LoadModelFromMesh(GenMeshPlane(m_defaultTexture->width / 8.0f, m_defaultTexture->height / 8.0f, 1, 1));
   m_models[static_cast<int>(CuboidSides::CUBOID_TOP)] = &LoadModelFromMesh(GenMeshPlane(m_defaultTexture->width / 8.0f, m_defaultTexture->height / 8.0f, 1, 1));
   m_models[static_cast<int>(CuboidSides::CUBOID_BOTTOM)] = &LoadModelFromMesh(GenMeshPlane(m_defaultTexture->width / 8.0f, m_defaultTexture->height / 8.0f, 1, 1));

   //m_models[static_cast<int>(CuboidSides::CUBOID_BOTTOM)]->materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = m_defaultTexture->m_Texture;


   FixupTextures();
};

void ShapeData::FixupTextures()
{
   //  Fixup the texture for this object.

   ObjectData* objectData = &g_objectTable[m_shape];

   //  Reset all textures
   m_topTexture->Reset();
   m_frontTexture->Reset();
   m_rightTexture->Reset();

   //  Top face
   //  Move pixels not part of this face off the texture
   for (int j = 0; j < m_topTextureOffsetY; ++j)
   {
      for (int i = 0; i < m_topTexture->width; ++i)
      {
         m_topTexture->MoveColumnUp(i);
      }
   }

   for (int j = 0; j < m_topTextureOffsetX; ++j)
   {
      for (int i = 0; i < m_topTexture->height; ++i)
      {
         m_topTexture->MoveRowLeft(i);
      }
   }

   m_topTexture->Resize(m_topTextureWidth, m_topTextureHeight);

   //  Front face
   //  Move pixels not part of this face off the texture
   for (int j = 0; j < m_frontTextureOffsetY; ++j)
   {
      for (int i = 0; i < m_frontTexture->width; ++i)
      {
        // m_frontTexture->MoveColumnUp(i);
      }
   }

   for (int j = 0; j < m_frontTextureOffsetX; ++j)
   {
      for (int i = 0; i < m_frontTexture->height; ++i)
      {
         //m_frontTexture->MoveRowLeft(i);
      }
   }

   //  Shift slanted pixels to unslant
   int counter = 1;
   for (int i = 0; i < m_frontTexture->height; ++i)
   {
      for (int k = 0; k < counter; ++k)
      {
         //m_frontTexture->MoveRowLeft(i);
      }
      ++counter;
   }

   //m_frontTexture->Resize(m_frontTextureWidth, m_frontTextureHeight);

   //  Right face
   //  Move pixels not part of this face off the texture
   for (int j = 0; j < m_rightTextureOffsetY; ++j)
   {
      for (int i = 0; i < m_rightTexture->width; ++i)
      {
         //m_rightTexture->MoveColumnUp(i);
      }
   }

   for (int j = 0; j < m_rightTextureOffsetX; ++j)
   {
      for (int i = 0; i < m_rightTexture->height; ++i)
      {
         //m_rightTexture->MoveRowLeft(i);
      }
   }

   //  Shift slanted pixels to unslant
   counter = 1;
   for (int i = 0; i < m_rightTextureWidth; ++i)
   {
      for(int k = 0; k < counter; ++k)
      {
         //m_rightTexture->MoveColumnUp(i);
      }
      ++counter;
   }

   //m_rightTexture->Resize(m_rightTextureWidth, m_rightTextureHeight);

}

void ShapeData::Draw(const Vector3& pos, float angle, Color color)
{
   if (m_isValid == false)
   {
		return;
	}

   ObjectData* objectData = &g_objectTable[m_shape];

   if (m_drawType == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
   {
      m_Scaling = Vector3{ m_defaultTexture->width / 8.0f, m_defaultTexture->height / 8.0f, 1 };
   }
   else if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
   {
      m_Scaling = Vector3{ -m_defaultTexture->width / 8.0f, 0, -m_defaultTexture->height / 8.0f };
   }
   else
   {
      m_Scaling = Vector3{ float(m_topTexture->width) / 8.0f, objectData->m_height, objectData->m_depth };
      //m_Scaling = Vector3(objectData->m_width, objectData->m_height, objectData->m_depth);
   }

   switch (m_drawType)
   {
      case ShapeDrawType::OBJECT_DRAW_CUBOID:
      {
         //DrawCube(pos, m_Scaling.x, m_Scaling.y, m_Scaling.z, BLUE);     // Draw a blue wall

         //Vector3 thisPos = pos;
         //thisPos.x -= m_Scaling.x - 1;
         //thisPos.z -= m_Scaling.z - 1;
         //thisPos.y += thisPos.y * .01f;

         //DrawSide(CuboidSides::CUBOID_TOP, thisPos, color, m_Scaling);
         //DrawSide(CuboidSides::CUBOID_BOTTOM, thisPos, color, m_Scaling);
         //DrawSide(CuboidSides::CUBOID_FRONT, thisPos, color, m_Scaling);
         //DrawSide(CuboidSides::CUBOID_BACK, thisPos, color, m_Scaling);
         //DrawSide(CuboidSides::CUBOID_RIGHT, thisPos, color, m_Scaling);
         //DrawSide(CuboidSides::CUBOID_LEFT, thisPos, color, m_Scaling);

         break;
      }

      case ShapeDrawType::OBJECT_DRAW_FLAT:
      {
         Vector3 thisPos = pos;
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

         DrawPlane(thisPos, Vector2{ m_Scaling.x, m_Scaling.z }, BLUE);
         //if(m_models[static_cast<int>(CuboidSides::CUBOID_BOTTOM)] != nullptr)
         //   DrawModel(*m_models[static_cast<int>(CuboidSides::CUBOID_BOTTOM)], pos, 1, WHITE);
         break;
      }

      case ShapeDrawType::OBJECT_DRAW_BILLBOARD:
      case ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH:
      {
         //float angle = GetCameraAngle();
         //angle += 45;
         Vector3 thisPos = pos;
         thisPos.x += (m_Scaling.x / 2.0f);
         //thisPos.z += 0.5f;
         thisPos.y += (m_Scaling.y / 2.0f) * 1.3;
         //DrawMesh(g_ResourceManager->GetMesh("Data/Meshes/billboard.txt"), thisPos, m_defaultTexture.get(), color, Vector3(0, angle, 0), m_Scaling);
         DrawBillboardPro(g_camera, m_defaultTexture->m_Texture, Rectangle{ 0, 0, float(m_defaultTexture->m_Texture.width), float(m_defaultTexture->m_Texture.height) }, thisPos, Vector3{ 0, 1, 0 }, Vector2{ m_Scaling.x, m_Scaling.y }, Vector2{ 0, 0 }, -45, color);
         break;
      }

      
   }
}

void ShapeData::DrawSide(CuboidSides side, Vector3 pos, Color color, Vector3 scaling)
{
   if (m_sideTexture[static_cast<int>(side)] != CuboidTexture::CUBOID_DONT_DRAW)
   {
      ModTexture* thisTexture;
      Vector3 thisRotation = Vector3{ 0, 0, 0 };
      switch (m_sideTexture[static_cast<int>(side)])
      {
      case CuboidTexture::CUBOID_DRAW_TOP:
         thisTexture = m_topTexture.get();
         break;
      case CuboidTexture::CUBOID_DRAW_FRONT:
         thisTexture = m_frontTexture.get();
         break;
      case CuboidTexture::CUBOID_DRAW_RIGHT:
         thisTexture = m_rightTexture.get();
         break;
      case CuboidTexture::CUBOID_DRAW_FRONT_INVERTED:
         thisTexture = m_frontTexture.get();
         thisRotation = Vector3{ 0, 180, 0 };
         break;
      case CuboidTexture::CUBOID_DRAW_RIGHT_INVERTED:
         thisTexture = m_rightTexture.get();
         thisRotation = Vector3{ 0, 180, 0 };
         break;
      case CuboidTexture::CUBOID_DRAW_TOP_INVERTED:
         thisTexture = m_topTexture.get();
         thisRotation = Vector3{ 0, 180, 0 };
         break;
      default:
         thisTexture = m_topTexture.get();
         break;
      }
      //DrawMesh(m_meshes[static_cast<int>(side)], pos, thisTexture, color, thisRotation, m_Scaling);
   }
}

bool ShapeData::Pick(Vector3 thisPos, float angle)
{
   bool picked = false;

 //  for (int i = 0; i < static_cast<int>(CuboidSides::CUBOID_LAST); ++i)
 //  {
 //     if (m_meshes[i] != nullptr && m_meshes[i]->SelectCheck(thisPos, angle, m_Scaling))
 //     {
	//		picked = true;
 //        break;
	//	}
	//}

   return picked;

}
