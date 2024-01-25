#include <fstream>

#include "Globals.h"
#include "U7Globals.h"
#include "Terrain.h"
#include "Config.h"

using namespace std;

Terrain::Terrain()
{
   m_Vertices = NULL;

   m_Minimap = NULL;
   m_MinimapTerrain = NULL;
   m_TerrainChanged = false;

   m_HitX = 0;
   m_HitY = 0;
   m_FloatHitX = 0;
   m_FloatHitY = 0;

   m_LimitedUpdate = 0;

   m_DebugTerrain = false;
}

Terrain::~Terrain()
{
   Shutdown();
}

void Terrain::Init(const string& configfile)
{

}

void Terrain::Init(int width, int height)
{

   //  Ultima VII's map consistes of 12x12 "superchunks", each of which is 16x16 "chunks".
   //
   //  A chunk consists of 16x16 cells.
   //
   //  So the world consists of a 192x192 map of chunks, each of which has 16x16 tiles.
   //  
   //  Which means that there are 36,864 chunks in the map.  But there are only 3072 unique chunks,
   //  which means some are repeated as necessary.
   //
   //  So the first thing we need to do is create a mesh for each of the 3072 chunks.



   m_CellWidth = width;
   m_CellHeight = height;

   m_VertexWidth = width + 1;
   m_VertexHeight = height + 1;

   if (m_Cells != NULL)
      delete [] m_Cells;

   if (m_Vertices != NULL)
      delete [] m_Vertices;

   m_Cells = new Cell[m_CellWidth * m_CellHeight];
   m_Vertices = new float[m_VertexWidth * m_VertexHeight];

   //  These are the coordinates for the vertices of a non-flipped cell.
   m_StraightCells.push_back(make_pair<float, float>(0, 0));
   m_StraightCells.push_back(make_pair<float, float>(1, 0));
   m_StraightCells.push_back(make_pair<float, float>(1, 1));
   m_StraightCells.push_back(make_pair<float, float>(1, 1));
   m_StraightCells.push_back(make_pair<float, float>(0, 1));
   m_StraightCells.push_back(make_pair<float, float>(0, 0));
   

   //  These are the coordinates for the vertices of a flipped cell.
   m_FlippedCells.push_back(make_pair<float, float>(1, 0));
   m_FlippedCells.push_back(make_pair<float, float>(1, 1));
   m_FlippedCells.push_back(make_pair<float, float>(0, 1));
   m_FlippedCells.push_back(make_pair<float, float>(0, 1));
   m_FlippedCells.push_back(make_pair<float, float>(0, 0));
   m_FlippedCells.push_back(make_pair<float, float>(1, 0));



   m_Minimap = new Texture();
   m_Minimap->Create(128, 128, false);

   m_MinimapTerrain = new Texture();
   m_MinimapTerrain->Create(128, 128, false);

   m_TerrainMesh = new Mesh();
   
   m_Water = new Mesh();
   m_SkyBox = new Mesh();
   
   m_Highlight = new Mesh();

   vector<Vertex> highlight;
   highlight.push_back(CreateVertex(0, 0, 0, 1, 1, 1, 1, 0, 0 ));
   highlight.push_back(CreateVertex(0, 0, 0, 1, 1, 1, 1, 0, 0 ));
   highlight.push_back(CreateVertex(0, 0, 0, 1, 1, 1, 1, 0, 0 ));
   highlight.push_back(CreateVertex(0, 0, 0, 1, 1, 1, 1, 0, 0 ));
   highlight.push_back(CreateVertex(0, 0, 0, 1, 1, 1, 1, 0, 0 ));
   highlight.push_back(CreateVertex(0, 0, 0, 1, 1, 1, 1, 0, 0 ));

   m_Highlight->Init(highlight);
   


}

void Terrain::Draw()
{
//   g_Display->m_Debugging = m_DebugTerrain;
   g_Display->DrawMesh(m_TerrainMesh, glm::vec3(0, 0, 0), &m_TerrainTexture);
//   g_Display->DrawMesh(m_BeachMesh, glm::vec3(0, 0, 0), m_TerrainTexture);
//   g_Display->DrawMesh(m_Highlight, glm::vec3(0, 0, 0), NULL);

   //g_Display->DrawMesh(m_Water, glm::vec3(0, 0, 0), m_WaterTexture);
}

void Terrain::Attack(int _UnitID)
{
   
}

void Terrain::Shutdown()
{
   
}

bool Terrain::SelectCheck()
{
   return false;
}

void Terrain::InitializeMap(int seed)
{
   RNG localRNG;
   localRNG.SeedRNG(seed);

   float _LowestHeight = 9999;
   float _HeighestHeight = -9999;
   float _HeightRange = 0;

   memset(m_Vertices, 0, sizeof(float) * m_VertexWidth * m_VertexHeight);

   for (int i = 0; i < m_VertexWidth; ++i)
   {
      for (int j = 0; j < m_VertexHeight; ++j)
      {
         SetHeight(i, j, GetHeight(i, j) * 1);
      }
   }
}

Color Terrain::GetEdgeLighting(int x, int y, Color inColor)
{
    Color retColor = inColor;
    if (x == 0 || x == m_CellWidth || y == 0 || y == m_CellHeight)
    {
        retColor.a = 0;
    }

    return retColor;
}

vector<Vertex> Terrain::CreateTerrainCell(int i, int j)
{
	float u, v;
	std::vector<Vertex> cellVertices;

	u = 0;
	v = 1;

	// Beach tiles are drawn with one half as grass, if that half is above the water level.
	// The tile is still considered beach, this is just to make it look better.
    unsigned short data = g_World[i][j];

    unsigned short shapenum = data & 0x3ff;
    unsigned short framenum = (data >> 10) & 0x1f;

    if (shapenum >= 150)
    {
        int stopper = 0;
    }

    float u1 = float(shapenum * 8) / 2048.0f;
    float v1 = float(framenum * 8) / 256.0f;

    float u2 = float((shapenum + 1) * 8) / 2048.0f;
    float v2 = float((framenum + 1) * 8) / 256.0f;


	float diffA = abs(GetHeight(i, j) - GetHeight(i - 1, j - 1));
	float diffB = abs(GetHeight(i, j - 1) - GetHeight(i - 1, j));
    bool triFlip = false;// diffA > diffB;

	//if (!triFlip)
	//{
		// Tri lighting
		Color lighting = GetTriLighting(i, j, i + 1, j, i + 1, j + 1);

		//	float kicker = float(g_NonVitalRNG->Random(100)) / 1600.0f - .03125f;

		//	lighting1.r += kicker;
		//	lighting1.g += kicker;
		//	lighting1.b += kicker;
		//	lighting1.b += kicker;

        float onetick = 1.0f / 256.0f;

		cellVertices.push_back(CreateVertex(i, 0, j, GetEdgeLighting(i + 1, j, lighting), u1, v1)); //0
		cellVertices.push_back(CreateVertex(i + 1, 0, j, GetEdgeLighting(i + 1, j, lighting), u2, v1)); //1
		cellVertices.push_back(CreateVertex(i + 1, 0, j + 1, GetEdgeLighting(i + 1, j, lighting), u2, v2)); //2

		lighting = GetTriLighting(i + 1, j + 1, i, j + 1, i, j);

		//         kicker = float(g_NonVitalRNG->Random(100)) / 1600.0f - .03125f;

		cellVertices.push_back(CreateVertex(i + 1, 0, j + 1, GetEdgeLighting(i + 1, j + 1, lighting), u2, v2)); //2
		cellVertices.push_back(CreateVertex(i, 0, j + 1, GetEdgeLighting(i, j + 1, lighting), u1, v2)); //3
        cellVertices.push_back(CreateVertex(i, 0, j, GetEdgeLighting(i + 1, j, lighting), u1, v1)); //0

		return cellVertices;
	//}
//	else
//	{
//
//// Tri lighting
//		Color lighting = GetTriLighting(i + 1, j, i + 1, j + 1, i, j + 1);
//
//		//	float kicker = float(g_NonVitalRNG->Random(100)) / 1600.0f - .03125f;
//
//		cellVertices.push_back(CreateVertex(i + 1, GetHeight(i + 1, j), j, GetEdgeLighting(i + 1, j, lighting), u + .25f, v)); //1
//		cellVertices.push_back(CreateVertex(i + 1, GetHeight(i + 1, j + 1), j + 1, GetEdgeLighting(i + 1, j + 1, lighting), u + .25f, v + .25f)); //2
//		cellVertices.push_back(CreateVertex(i, GetHeight(i, j + 1), j + 1, GetEdgeLighting(i, j + 1, lighting), u, v + .25f)); //3
//
//		lighting = GetTriLighting(i, j + 1, i, j, i + 1, j);
//
//		//         kicker = float(g_NonVitalRNG->Random(100)) / 1600.0f - .03125f;
//
//		cellVertices.push_back(CreateVertex(i, GetHeight(i, j + 1), j + 1, GetEdgeLighting(i, j + 1, lighting), u, v + .25f)); //3
//		cellVertices.push_back(CreateVertex(i, GetHeight(i, j), j, GetEdgeLighting(i, j, lighting), u, v)); //0
//		cellVertices.push_back(CreateVertex(i + 1, GetHeight(i + 1, j), j, GetEdgeLighting(i + 1, j, lighting), u + .25f, v)); //1
//
//		return cellVertices;
//	}
}

//  Designed to be called ONCE, after the map heightfield is created.
//  Initializes the verts of the entire map.  After this function, small changes
//  will be made using other functions when the terrain changes.
void Terrain::InitializeTerrainMesh()
{
   //  Initialize the mesh based on the new map data.
   std::vector<Vertex> terrainVertices;

   FindVisibleCells();

   //  Create the four outer points of the quads.
   for (int i = 0; i < m_VisibleCells.size(); ++i)
   {
    	vector<Vertex> thisCell = CreateTerrainCell(m_VisibleCells[i].first, m_VisibleCells[i].second);
		terrainVertices.insert(terrainVertices.end(), thisCell.begin(), thisCell.end());
   }
   
   m_TerrainMesh->Init(terrainVertices, MT_DYNAMIC);
   UpdateIndexBuffers();
   
   //  Und now ze vater!
   //terrainVertices.clear();
   //for (int j = 0; j < m_CellHeight; ++j)
   //{
   //   for (int i = 0; i < m_CellWidth; ++i)
   //   {
   //      float time = g_Engine->m_GameTimeInSeconds / 8;
   //      float base = .1f;
   //      float spread = .25f;
   //      float trans = .7f;
   //      float span = 4;
   //      
   //      float u, v;
   //      u = 0;
   //      v = 0;

   //      terrainVertices.push_back(CreateVertex(i    , GetWaterHeight(i    , j    ) + base, j    , Color(1, 1, 1, .75), u       , v      )); //0
   //      terrainVertices.push_back(CreateVertex(i + 1, GetWaterHeight(i + 1, j    ) + base, j    , Color(1, 1, 1, .75), u + 1, v      )); //1
   //      terrainVertices.push_back(CreateVertex(i + 1, GetWaterHeight(i + 1, j + 1) + base, j + 1, Color(1, 1, 1, .75), u + 1, v + 1)); //2
   //      
   //      terrainVertices.push_back(CreateVertex(i + 1, GetWaterHeight(i + 1, j + 1) + base, j + 1, Color(1, 1, 1, .75), u + 1, v + 1)); //2
   //      terrainVertices.push_back(CreateVertex(i    , GetWaterHeight(i    , j + 1) + base, j + 1, Color(1, 1, 1, .75), u       , v + 1)); //3
   //      terrainVertices.push_back(CreateVertex(i    , GetWaterHeight(i    , j    ) + base, j    , Color(1, 1, 1, .75), u       , v      )); //0
   //   }
   //}
   //
   //m_Water->Init(terrainVertices, MT_DYNAMIC);

   //UpdateWater();
  
}

void Terrain::UpdateTerrainMesh()
{
   
}

Color Terrain::GetCellLighting(float x, float y)
{
   Color cell1 = GetTriLighting( glm::vec3(x, GetHeight(x, y), y),
      glm::vec3(x + 1, GetHeight(x + 1.0f, y), y),
      glm::vec3(x, GetHeight(x, y + 1.0f), y + 1));      
   Color cell2 = GetTriLighting(glm::vec3(x + 1, GetHeight(x + 1, y), y),
      glm::vec3(x, GetHeight(x, y + 1), y + 1),
      glm::vec3(x, GetHeight(x, y), y));

   cell1.r += cell2.r; cell1.r /= 2;
   cell1.g += cell2.g; cell1.g /= 2;
   cell1.b += cell2.b; cell1.b /= 2;
   cell1.a += cell2.a; cell1.a /= 2;

   return cell1;
}

//  This allows us to plug coordinate data straight in and get lighting data.
Color Terrain::GetTriLighting(int x1, int y1, int x2, int y2, int x3, int y3)
{
	Color lighting = GetTriLighting(glm::vec3(x1, GetHeight(x1, y1), y1),
		glm::vec3(x2, GetHeight(x2, y2), y2),
		glm::vec3(x3, GetHeight(x3, y3), y3));

	return lighting;
}

Color Terrain::GetTriLighting(glm::vec3 v1, glm::vec3 v2, glm::vec3 v3)
{
   glm::vec3 directionToLight = glm::vec3(1, 1, 1);
   directionToLight = glm::normalize(directionToLight);

   glm::vec3 n;

   glm::vec3 a = v1;
   glm::vec3 b = v2;
   glm::vec3 c = v3;

   n = glm::normalize(glm::cross(c - a, b - a));

   float cosine = glm::dot(n, directionToLight);

   //   cosine = GetHeight(x, y) / 8.0f;
   if(cosine < 0)
      cosine = 0;

   cosine *= .5;
   cosine += .5;
   
   return Color(cosine, cosine, cosine, 1);
}

Color Terrain::GetBeachLighting(float x, float y)
{
   glm::vec3 directionToLight = glm::vec3(1, 1, 1);
   directionToLight = glm::normalize(directionToLight);

   glm::vec3 n;

   glm::vec3 a = glm::vec3(x, GetHeight(x, y), y);
   glm::vec3 b = glm::vec3(x + 1, GetHeight(x + 1.0f, y), y);
   glm::vec3 c = glm::vec3(x, GetHeight(x, y + 1.0f), y + 1);      

   n = glm::normalize(glm::cross(c - a, b - a));

   float cosine = glm::dot(n, directionToLight);

   //   cosine = GetHeight(x, y) / 8.0f;
   if(cosine < 0)
      cosine = 0;

   cosine *= .5;
   cosine += .5;
   
   return Color(cosine, cosine, cosine, GetBeachShading(x, y));
}

float Terrain::GetBeachShading(float x, float y)
{
/*   float height = GetHeight(x, y);
   
   if( height >= .5f )
   {
      return 1.0f;
   }

   return height * 2;*/



   float alphacomponent = 1;

	if(GetHeight(x, y) < .2f)
	{
		alphacomponent = 0;
	}

	else if(GetHeight(x, y) > .5f)
	{
		alphacomponent = 1;
	}
	else
	{
		float alphamult = (GetHeight(x, y) - .2f) * 3.333333333;
		alphacomponent = alphamult;
	}

	return alphacomponent;
}

void Terrain::Update()
{
   //  Update camera position by finding the indices of the new cells to draw.
   if (g_CameraMoved)
   {
      FindVisibleCells();

      //  Create the four outer points of the quads.
      m_updateVector.clear();
      for (int i = 0; i < m_VisibleCells.size(); ++i)
      {
          vector<Vertex> thisCell = CreateTerrainCell(m_VisibleCells[i].first, m_VisibleCells[i].second);
          for (int j = 0; j < thisCell.size(); ++j)
          {
             m_updateVector.emplace_back(thisCell[j]);
          }
      }

      m_TerrainMesh->Init(m_updateVector);


      UpdateIndexBuffers();
   }

   if( m_TerrainChanged )
   {
      m_TerrainChanged = false;
   }
   

   glm::vec3 tri1, tri2, tri3, tri4;
   //  Get terrain hit for highlight mesh
   //for (auto& node : m_VisibleCells)
   //{
   //   float x = node.first;
   //   float z = node.second;
   //   float y = GetHeight(x, z);

   //   tri1 = glm::vec3(x, y, z);
   //   tri2 = glm::vec3(x + 1, GetHeight(x + 1, z), z);
   //   tri3 = glm::vec3(x, GetHeight(x, z + 1), z + 1);
   //   tri4 = glm::vec3(x + 1, GetHeight(x + 1, z+ 1), z + 1);

   //   double distance;

   //   double u, v;

   //   if( PickWithUV(g_Input->m_RayOrigin, g_Input->m_RayDirection, tri1, tri2, tri3, distance, u, v ) ||
   //      PickWithUV(g_Input->m_RayOrigin, g_Input->m_RayDirection, tri4, tri3, tri2, distance, u, v ) )
   //   {
   //      glm::vec3 final = g_Input->m_RayOrigin + ( glm::vec3(g_Input->m_RayDirection.x * distance,
   //         g_Input->m_RayDirection.y * distance, g_Input->m_RayDirection.z * distance));

   //      m_HitX = x;
   //      m_HitY = z;
   //      m_FloatHitX = final.x;
   //      m_FloatHitY = final.z;
   //      break;
   //   }
   //}

   //  Update highlight
   //vector<Vertex> highlight;
   //highlight.push_back(CreateVertex(m_FloatHitX    , GetHeight(m_FloatHitX    , m_FloatHitY    ) + .05, m_FloatHitY    , 1, 1, 1, 1, 0, 0 ));
   //highlight.push_back(CreateVertex(m_FloatHitX + 1, GetHeight(m_FloatHitX + 1, m_FloatHitY    ) + .05, m_FloatHitY    , 1, 1, 1, 1, 0, 0 ));
   //highlight.push_back(CreateVertex(m_FloatHitX    , GetHeight(m_FloatHitX    , m_FloatHitY + 1) + .05, m_FloatHitY + 1, 1, 1, 1, 1, 0, 0 ));
   //highlight.push_back(CreateVertex(m_FloatHitX + 1, GetHeight(m_FloatHitX + 1, m_FloatHitY + 1) + .05, m_FloatHitY + 1, 1, 1, 1, 1, 0, 0 ));
   //highlight.push_back(CreateVertex(m_FloatHitX    , GetHeight(m_FloatHitX    , m_FloatHitY + 1) + .05, m_FloatHitY + 1, 1, 1, 1, 1, 0, 0 ));
   //highlight.push_back(CreateVertex(m_FloatHitX + 1, GetHeight(m_FloatHitX + 1, m_FloatHitY    ) + .05, m_FloatHitY    , 1, 1, 1, 1, 0, 0 ));

   //m_Highlight->UpdateVertices(highlight);

   //if (g_Engine->Time() - m_LimitedUpdate > 50)
   //{
   //   //UpdateWater();
   //   //UpdateMinimapTexture();

   //   m_LimitedUpdate = g_Engine->Time();
   //}
}

float Terrain::GetHeight(int x, int y)
{
   if (x >= 0 && x < m_VertexWidth && y >= 0 && y < m_VertexHeight)
   {
      return m_Vertices[x + (y * m_VertexWidth)];
   }
   else
   {
      return 0;
   }
}

float Terrain::GetCenter(int x, int y)
{
   float ul = GetHeight(x, y);
   float ur = GetHeight(x + 1, y);
   float ll = GetHeight(x, y + 1);
   float lr = GetHeight(x + 1, y + 1);

   return ( ul + ur + ll + lr ) / 4.0f;
}

float Terrain::GetHeight(float x, float z)
{
   if (x < 0 || x > m_VertexWidth - 1 || z < 0 || z > m_VertexHeight - 1)
   {
      return -9999;
   }

   //  This function uses lerp.  If we're just getting a whole number value (even though it's a float)
   //  use the int version so we don't have to lerp unnecessarily.
   if( int(x) == x && int(z) == z )
   {
      return GetHeight(int(x), int(z));
   }


   int _XWhole = int(x);
   int _ZWhole = int(z);

   float A = GetHeight(_XWhole, _ZWhole);
   float B = GetHeight(_XWhole + 1, _ZWhole);
   float C = GetHeight(_XWhole, _ZWhole + 1);
   float D = GetHeight(_XWhole + 1, _ZWhole + 1);
   //	float E = (A + B + C + D) / 4;

   float _XFrac = x - _XWhole;
   float _ZFrac = z - _ZWhole;

   float height = 0.0f;

   if (_ZFrac + _XFrac < 1.0)// && _ZFrac + (1.0 - _XFrac) > 1.0)  // Upper triangle ABE
   {
      float uy = B - A; // A->B
      float vy = C - A; // A->C
      height = A + Lerp(0.0f, uy, _XFrac) + Lerp(0.0f, vy, _ZFrac);
   }

   else // Lower triangle CDE
   {
      float uy = C - D; // D->C
      float vy = B - D; // D->B
      height = D + Lerp(0.0f, uy, 1.0f - _XFrac) + Lerp(0.0f, vy, 1.0f - _ZFrac);
   }

   return height;
}

void Terrain::SetHeight(int x, int y, float value)
{
   if (x >= 0 && x < m_VertexWidth && y >= 0 && y < m_VertexHeight)
   {
      m_Vertices[x + (y * m_VertexWidth)] = value;
   }
}

void Terrain::OffsetHeight(int x, int y, float height)
{
   SetHeight(x, y, GetHeight(x, y) + height);
}

bool Terrain::IsCellVisible(float x, float y)
{
   return(IsPointVisible(glm::vec3(x, GetHeight(x, y), y))
      || IsPointVisible(glm::vec3(x + 1, GetHeight(x + 1, y), y))
      || IsPointVisible(glm::vec3(x + 1, GetHeight(x + 1, y + 1), y + 1))
      || IsPointVisible(glm::vec3(x, GetHeight(x, y + 1), y + 1))
      );

}

bool Terrain::IsPointVisible(glm::vec3 point)
{
   glm::vec3 final = glm::project( point, g_Display->GetModelViewMatrix(), g_Display->GetProjectionMatrix(),
      glm::vec4(0, 0, g_Display->GetWidth(), g_Display->GetHeight()));

   if(final.x <= g_Display->GetWidth()
      && final.x >= 0
      && final.y <= g_Display->GetHeight()
      && final.y >= 0)
      return true;
   else
      return false;
}

void Terrain::UpdateWater()
{
   float height;
   float time = g_Engine->m_GameTimeInSeconds / 8;
   float base = .1f;
   float spread = .25f;
   float trans = .7f;
   float span = 1;
   
   
   for( vector< pair<float, float> >::iterator node = m_VisibleCells.begin(); node != m_VisibleCells.end(); ++node)
   {
      float kicker = float(g_NonVitalRNG->Random(100)) / 400.0f - .125f;
      m_WaterVector.clear();
      int i = (*node).first;
      int j = (*node).second;
      
      float u = i % 4 * .25;
      float v = j % 4 * .25;
      
      Color color = GetTriLighting(glm::vec3(i,     base + (GetWaterHeight(i, j) * 10), j),
         glm::vec3(i + span, base + (GetWaterHeight(i + span, j    ) * 10), j),
         glm::vec3(i + span, base + (GetWaterHeight(i + span, j + span) * 10), j + span));
//      color.r += kicker;
//      color.g += kicker;
//      color.b += kicker;
      if (i == 0 || j == 0 || i == m_CellWidth || j == m_CellHeight)
      {
          color.a = 0;
      }
      else
      {
          color.a = trans;
      }
   
      height = GetWaterHeight(i, j);
      m_WaterVector.push_back(CreateVertex(i,     base + height, j,     color,  u + height + time, v + .25 + height + time ));

      if (i + span == 0 || j == 0 || i + span == m_CellWidth || j == m_CellHeight)
      {
          color.a = 0;
      }
      else
      {
          color.a = trans;
      }

      height = GetWaterHeight(i + span, j    );
      m_WaterVector.push_back(CreateVertex(i + span, base + height, j,     color, u + .25 + height + time,  v + .25 + height + time ));

      if (i + span == 0 || j + span == 0 || i + span == m_CellWidth || j + span == m_CellHeight)
      {
          color.a = 0;
      }
      else
      {
          color.a = trans;
      }

      height = GetWaterHeight(i + span, j + span);
      m_WaterVector.push_back(CreateVertex(i + span, base + height, j + span, color, u + .25 + height + time, v + .5 + height + time));
         
      kicker = float(g_NonVitalRNG->Random(100)) / 400.0f - .125f;
      color = GetTriLighting(glm::vec3(i + span, base + (GetWaterHeight(i + span, j + span) * 10), j + span),
         glm::vec3(i,     base + (GetWaterHeight(i    , j + span) * 10), j + span),
         glm::vec3(i,     base + (GetWaterHeight(i    , j    ) * 10), j));

      if (i + span == 0 || j + span == 0 || i + span == m_CellWidth || j + span == m_CellHeight)
      {
          color.a = 0;
      }
      else
      {
          color.a = trans;
      }

      height = GetWaterHeight(i + span, j + span);
      m_WaterVector.push_back(CreateVertex(i + span, base + height, j + span, color, u + .25 + height + time, v + .5 + height + time));

      if (i == 0 || j + span == 0 || i == m_CellWidth || j + span == m_CellHeight)
      {
          color.a = 0;
      }
      else
      {
          color.a = trans;
      }

      height = GetWaterHeight(i    , j + span);
      m_WaterVector.push_back(CreateVertex(i,     base + height, j + span, color,  u + 0 + height + time, v + .5 + height + time ));

      if (i == 0 || j == 0 || i == m_CellWidth || j == m_CellHeight)
      {
          color.a = 0;
      }
      else
      {
          color.a = trans;
      }

      height = GetWaterHeight(i    , j    );
      m_WaterVector.push_back(CreateVertex(i,     base + height, j,    color,  u + 0 + height + time, v + .25 + height + time));
         
      m_Water->UpdateVertices((j * m_CellWidth + (i)) * 6, m_WaterVector);
   }
}

float Terrain::GetWaterHeight(float x, float y)
{
//	float animation = cos((x + y + gp_Engine->m_GameTimeInSeconds) * 3);//float(int(x * x + y * x + gp_Engine->m_GameTimeInMS) % 1000) / 1000.0f;

	float _gt = g_Engine->m_GameTimeInSeconds;
	float _i = x;
	float _j = y;
	float animation = ( sin(2*(_gt)+1.3f*(_i)+0.7f*(_j)) + cos(3*(_gt)+1.5f*(_i)-1.5f*(_j)) );

	animation *= .02f;

	return animation;
}

void Terrain::FindVisibleCells()
{
    m_DurationOfVisibleTest = g_Engine->Time();
    m_VisibleCells.clear();

    //  First pass - only find the cells that are close enough and within the
    //  view arc.

    int x = g_Display->GetCameraLookAtPoint().x;
    int y = g_Display->GetCameraLookAtPoint().z;
    int range = g_Display->GetCameraDistance() / 2.25;

    int x1 = x - range;
    if(x1 < 0 ) x1 = 0;

    int x2 = x + range;
    if(x2 >= m_CellWidth) x2 = m_CellWidth - 1;

    int y1 = y - range;
    if(y1 < 0 ) y1 = 0;

    int y2 = y + range;
    if(y2 >= m_CellHeight) y2 = m_CellHeight - 1;




    glm::vec3 campos = glm::vec3(g_Display->GetCameraPosition().x, 0, g_Display->GetCameraPosition().z);

    int debugcounter = 0;



    for (int i = x1; i <= x2; ++i)
    {
        for (int j = y1; j < y2; ++j)
        {
            m_VisibleCells.push_back(make_pair(i, j));
        }
    }

    m_DurationOfVisibleTest = g_Engine->Time() - m_DurationOfVisibleTest;
}

void Terrain::UpdateIndexBuffers()
{
   vector<unsigned int> verts;
   verts.clear();
   
   vector<pair<float, float> >::iterator node = m_VisibleCells.begin();
   int indexcounter = 0;
   for(node; node != m_VisibleCells.end(); ++node)
   {
      int x = (*node).first;
      int y = (*node).second;
      
      verts.push_back(indexcounter);
      ++indexcounter;
      verts.push_back(indexcounter);
      ++indexcounter;
      verts.push_back(indexcounter);
      ++indexcounter;
      verts.push_back(indexcounter);
      ++indexcounter;
      verts.push_back(indexcounter);
      ++indexcounter;
      verts.push_back(indexcounter);
      ++indexcounter;
      
   }
   
   
   
   m_TerrainMesh->UpdateIndices(verts);
   m_Water->UpdateIndices(verts);

}