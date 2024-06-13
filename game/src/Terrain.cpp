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

#include "Geist/Globals.h"
#include "Geist/RNG.h"
#include "U7Globals.h"
#include "Terrain.h"
#include "Config.h"

using namespace std;

Terrain::Terrain()
{ 
   int m_height = 3072;
   int m_width = 3072;
}

Terrain::~Terrain()
{
   Shutdown();
}

void Terrain::Init()
{
	// Create the chunk database
   for (int i = 0; i < 3072; ++i)
   {
		m_chunkModels[i] = make_unique<Model>(LoadModelFromMesh(GenMeshPlane(16, 16, 1, 1)));
	}


}

void Terrain::Draw()
{
   DrawModel(*m_chunkModels[0], {0, 0, 0}, 1.0f, WHITE);
}

void Terrain::Shutdown()
{
   
}

bool Terrain::IsChunkVisible(int x, int y)
{
   return false;
}

void Terrain::Update()
{
   if (g_CameraMoved)
   {
      FindVisibleChunks();
   }
}

void Terrain::FindVisibleChunks()
{
    m_visibleChunks.clear();
}