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

#include <fstream>

#include "U7Globals.h"
#include "Terrain.h"

#include <iostream>

#include "raymath.h"

using namespace std;

Terrain::Terrain()
{ 
   m_height = 3072;
   m_width = 3072;

	m_terrainTiles = LoadTextureFromImage(GenImageColor(2048, 256, Color{ 0, 0, 0, 0 }));
	m_currentTerrain = LoadRenderTexture(1024, 1024);

	m_cellModel = LoadModelFromMesh(GenMeshPlane(TILEWIDTH, TILEHEIGHT, 1, 1));
	SetMaterialTexture(&m_cellModel.materials[0], MATERIAL_MAP_DIFFUSE, m_currentTerrain.texture);
}

Terrain::~Terrain()
{
	UnloadModel(m_cellModel);
	UnloadRenderTexture(m_currentTerrain);
}

void Terrain::Init()
{

}

void Terrain::UpdateTerrainTexture(Image img)
{
	m_terrainTiles = LoadTextureFromImage(img);
}

void Terrain::Draw()
{
	DrawModel(m_cellModel, {float(int(g_camera.target.x)), 0, float(int(g_camera.target.z))}, 1, WHITE);
}

void Terrain::Shutdown()
{

}

void Terrain::Update()
{
	UpdateTerrainTiles();
}

void Terrain::CalculateLighting()
{
	//  Calculate lighting grid
	for (int i = g_camera.target.x - (TILEWIDTH / 2); i <= g_camera.target.x + (TILEWIDTH / 2 - 1); i++)
	{
		for (int j = g_camera.target.z - (TILEHEIGHT / 2); j <= g_camera.target.z + (TILEHEIGHT / 2 - 1); j++)
		{
			int cellx = (TILEWIDTH / 2) + i - int(g_camera.target.x);
			int celly = (TILEHEIGHT / 2) + j - int(g_camera.target.z);
			m_cellLighting[cellx][celly] = g_dayNightColor;
		}
	}

	int lightrangesquared = 36;
	for (auto object : g_sortedVisibleObjects)
	{
		if (object.get()->m_objectData->m_isLightSource)
		{
			U7Object* obj = object.get();

			for (int i = g_camera.target.x - (TILEWIDTH / 2); i <= g_camera.target.x + (TILEWIDTH / 2 - 1); i++)
			{
				for (int j = g_camera.target.z - (TILEHEIGHT / 2); j <= g_camera.target.z + (TILEHEIGHT / 2 - 1); j++)
				{
					int cellx = (TILEWIDTH / 2) + i - int(g_camera.target.x);
					int celly = (TILEHEIGHT / 2) + j - int(g_camera.target.z);

					if (Vector2DistanceSqr({float(i), float(j)}, {obj->m_Pos.x, obj->m_Pos.z}) < lightrangesquared)
					{
						m_cellLighting[cellx][celly] = WHITE;
					}
				}
			}
		}
	}
}

void Terrain::UpdateTerrainTiles()
{
	//  Create terrain tile texture
	unsigned short prevShape = 0;
	unsigned short prevFrame = 0;

	BeginTextureMode(m_currentTerrain);
	for (int i = g_camera.target.x - (TILEWIDTH / 2); i <= g_camera.target.x + (TILEWIDTH / 2 - 1); i++)
	{
		for (int j = g_camera.target.z - (TILEHEIGHT / 2); j <= g_camera.target.z + (TILEHEIGHT / 2 - 1); j++)
		{
			if (i < 0 || j < 0 || i >= 3072 || j >= 3072)
			{
				continue;
			}

			int cellx = (TILEWIDTH / 2) + i - int(g_camera.target.x);
			int celly = TILEHEIGHT - ((TILEHEIGHT / 2) + j - int(g_camera.target.z));
			unsigned short shapenum = g_World[j][i] & 0x3ff;
			unsigned short framenum = (g_World[j][i] >> 10) & 0x1f;
			if (shapenum >= 150 || framenum >= 32)
			{
				// This is a hole in the terrain, use the previous terrain type
				shapenum = prevShape;
				framenum = prevFrame;
			} else
			{
				prevShape = shapenum;
				prevFrame = framenum;
			}

			DrawTexturePro(m_terrainTiles, { float(shapenum * 8), float(framenum * 8), 8, 8 }, { float(cellx * 8), float(celly * 8), 8, -8 }, { 0, 0 }, 0, m_cellLighting[cellx][128 - celly]);
		}
	}
	EndTextureMode();
}