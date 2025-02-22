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
#include "Geist/Config.h"
#include "U7Globals.h"
#include "Terrain.h"

using namespace std;

Terrain::Terrain()
{ 
	m_height = 3072;
	m_width = 3072;
	m_chunkDrawCount = 0;
	for (int i = 0; i < 192; i++) {
		for (int j = 0; j < 192; j++) {
			m_chunkVisTime[i][j] = 0.0f;
			m_chunkVisible[i][j] = false;
			m_chunkScoot[i][j][0] = 0.0f;
			m_chunkScoot[i][j][1] = 0.0f;
		}
	}
	m_terrainTexture = GenImageColor(2048, 256, Color{ 0, 0, 0, 0 });
}

Terrain::~Terrain()
{
	Shutdown();
}

void Terrain::Init()
{
	// Create the chunk database
	bool isWater = true;

	//  Create a mesh for each chunk
	Mesh mesh = GenMeshPlane(16, 16, 1, 1);

	//  Move the mesh from the center to the corner
	for (int i = 0; i < mesh.vertexCount; ++i)
	{
		mesh.vertices[i * 3] += 8.0f;
		mesh.vertices[i * 3 + 2] += 8.0f;
	}
	Mesh ocean_mesh = GenMeshPlane(16, 16, 1, 1);

	//  Move the mesh from the center to the corner
	for (int i = 0; i < ocean_mesh.vertexCount; ++i)
	{
		ocean_mesh.vertices[i * 3] += 8.0f;
		ocean_mesh.vertices[i * 3 + 1] = -4.0f;
		ocean_mesh.vertices[i * 3 + 2] += 8.0f;
	}

	UpdateMeshBuffer(mesh, 0, mesh.vertices, sizeof(float) * mesh.vertexCount * 3, 0);
	UpdateMeshBuffer(ocean_mesh, 0, ocean_mesh.vertices, sizeof(float) * ocean_mesh.vertexCount * 3, 0);

	unsigned short prevShape = 0;
	unsigned short prevFrame = 0;
	for (unsigned int i = 0; i < 3072; ++i)
	{
		int thisChunkIndex = i;
		if (ChunkIsWater(i) == true)
		{
			m_chunkModels[i] = make_unique<Model>(LoadModelFromMesh(ocean_mesh));
			thisChunkIndex = 764;
		}
		else
		{
			m_chunkModels[i] = make_unique<Model>(LoadModelFromMesh(mesh));
		}

			Image img = GenImageColor(128, 128, BLACK);
			for (int j = 0; j < 16; ++j)
			{
				for (int k = 0; k < 16; ++k)
				{
						unsigned short thisdata = g_ChunkTypeList[thisChunkIndex][j][k];
						unsigned short shapenum = thisdata & 0x3ff;
						unsigned short framenum = (thisdata >> 10) & 0x1f;

						if (shapenum <= 150 && framenum < 32)
						{
							ImageDraw(&img, m_terrainTexture, Rectangle{ shapenum * 8.0f, framenum * 8.0f, 8, 8 }, Rectangle{ k * 8.0f, j * 8.0f, 8, 8 }, WHITE);
							prevShape = shapenum;
							prevFrame = framenum;
						}
						else
						{
							ImageDraw(&img, m_terrainTexture, Rectangle{ prevShape * 8.0f, prevFrame * 8.0f, 8, 8 }, Rectangle{ k * 8.0f, j * 8.0f, 8, 8 }, WHITE);
						}
				}
			}

			Texture thisTexture = LoadTextureFromImage(img);
			SetTextureFilter(thisTexture, TEXTURE_FILTER_POINT);

			SetMaterialTexture(&m_chunkModels[i]->materials[0], MATERIAL_MAP_DIFFUSE, thisTexture);

			UnloadImage(img);
	}
}

void Terrain::UpdateTerrainTexture(Image img)
{
	m_terrainTexture = img;
}

bool Terrain::ChunkIsWater(int chunkIdx) {
	bool retVal = false;
	if (chunkIdx == 0) { retVal = true; }
	else if (chunkIdx == 4) { retVal = true; }
	else if (chunkIdx == 5) { retVal = true; }
	else if (chunkIdx == 6) { retVal = true; }
	else if (chunkIdx == 45) { retVal = true; }
	else if (chunkIdx == 47) { retVal = true; }
	else if (chunkIdx == 53) { retVal = true; }
	else if (chunkIdx == 55) { retVal = true; }
	else if (chunkIdx == 56) { retVal = true; }
	else if (chunkIdx == 61) { retVal = true; }
	else if (chunkIdx == 64) { retVal = true; }
	else if (chunkIdx == 69) { retVal = true; }
	else if (chunkIdx == 260) { retVal = true; }
	else if (chunkIdx == 285) { retVal = true; }
	else if (chunkIdx == 286) { retVal = true; }
	else if (chunkIdx == 287) { retVal = true; }
	else if (chunkIdx == 909) { retVal = true; }
	else if (chunkIdx == 1580) { retVal = true; }
	else if (chunkIdx == 1581) { retVal = true; }
	else if (chunkIdx == 1582) { retVal = true; }
	else if (chunkIdx == 1583) { retVal = true; }
	else if (chunkIdx == 2023) { retVal = true; }
	else if (chunkIdx == 2136) { retVal = true; }
	else if (chunkIdx == 2137) { retVal = true; }
	else if (chunkIdx == 2138) { retVal = true; }
	else if (chunkIdx == 2667) { retVal = true; }
	else if (chunkIdx == 2670) { retVal = true; }
	else if (chunkIdx == 2940) { retVal = true; }
	else if (chunkIdx == 2941) { retVal = true; }
	else if (chunkIdx == 2942) { retVal = true; }
	else if (chunkIdx == 2943) { retVal = true; }
	else if (chunkIdx == 2956) { retVal = true; }
	else if (chunkIdx == 2957) { retVal = true; }
	else if (chunkIdx == 2958) { retVal = true; }
	else if (chunkIdx == 2959) { retVal = true; }
	else if (chunkIdx == 3008) { retVal = true; }
	else if (chunkIdx == 3009) { retVal = true; }
	else if (chunkIdx == 3010) { retVal = true; }
	else if (chunkIdx == 3011) { retVal = true; }
	else if (chunkIdx == 3012) { retVal = true; }
	else if (chunkIdx == 3013) { retVal = true; }
	else if (chunkIdx == 3014) { retVal = true; }
	else if (chunkIdx == 3015) { retVal = true; }
	else if (chunkIdx == 3029) { retVal = true; }
	else if (chunkIdx == 3035) { retVal = true; }
	else if (chunkIdx == 3036) { retVal = true; }
	else if (chunkIdx == 3045) { retVal = true; }
	else if (chunkIdx == 275) { retVal = true; }
	else if (chunkIdx == 607) { retVal = true; }
	else if (chunkIdx == 719) { retVal = true; }
	else if (chunkIdx == 732) { retVal = true; }
	else if (chunkIdx == 736) { retVal = true; }
	else if (chunkIdx == 737) { retVal = true; }
	else if (chunkIdx == 738) { retVal = true; }
	else if (chunkIdx == 739) { retVal = true; }
	else if (chunkIdx == 740) { retVal = true; }
	else if (chunkIdx == 741) { retVal = true; }
	else if (chunkIdx == 742) { retVal = true; }
	else if (chunkIdx == 743) { retVal = true; }
	else if (chunkIdx == 744) { retVal = true; }
	else if (chunkIdx == 745) { retVal = true; }
	else if (chunkIdx == 746) { retVal = true; }
	else if (chunkIdx == 747) { retVal = true; }
	else if (chunkIdx == 816) { retVal = true; }
	else if (chunkIdx == 1383) { retVal = true; }
	else if (chunkIdx == 1755) { retVal = true; }
	else if (chunkIdx == 1756) { retVal = true; }
	else if (chunkIdx == 1757) { retVal = true; }
	else if (chunkIdx == 1862) { retVal = true; }
	else if (chunkIdx == 2675) { retVal = true; }
	else if (chunkIdx == 2808) { retVal = true; }
	else if (chunkIdx == 2813) { retVal = true; }
	else if (chunkIdx == 2814) { retVal = true; }
	else if (chunkIdx == 2816) { retVal = true; }
	else if (chunkIdx == 2818) { retVal = true; }
	else if (chunkIdx == 2867) { retVal = true; }
	else if (chunkIdx == 2912) { retVal = true; }
	else if (chunkIdx == 2996) { retVal = true; }
	else if (chunkIdx == 2997) { retVal = true; }
	else if (chunkIdx == 2998) { retVal = true; }
	else if (chunkIdx == 2999) { retVal = true; }

	return retVal;
}

void Terrain::SetTerrainType(int pos[2], TerrainType tType)
{
	if (pos[0] > 0 && pos[0] < m_width) {
		if (pos[1] > 0 && pos[1] < m_height) {
			m_type[pos[0]][pos[1]] = tType;
		}
	}
}

TerrainType Terrain::GetTerrainType(int pos[2])
{
	TerrainType retVal = TerrainType::TERRAIN_NONE;
	if (pos[0] > 0 && pos[0] < m_width) {
		if (pos[1] > 0 && pos[1] < m_height) {
			retVal = m_type[pos[0]][pos[1]];
		}
	}
	return retVal;
}

void Terrain::Draw()
{
	bool drawTerrain = true;
	m_chunkDrawCount = 0;
	/*
	int range = g_camera.fovy / 16 + 1;

	int chunkx = g_camera.target.x / 16;
	int chunky = g_camera.target.z / 16;
	//int chunkx = g_camera.position.x / 16;
	//int chunky = g_camera.position.z / 16;
	
	float mapSize[2];
	mapSize[0] = 192.0f * 16.0f;
	mapSize[1] = 192.0f * 16.0f;

	bool l_chunkVisible[192][192];
	*/

	//printf("drawing chunk range %d - %d, %d - %d\n", chunkx - range, chunkx + range, chunky - range, chunky + range);
	for (int i = 0; i < 192; i++)
	{
		for (int j = 0; j < 192; j++)
		{
			if (drawTerrain == true)
			{
				if (m_chunkVisible[i][j])
				{
					DrawModel(*m_chunkModels[g_chunkTypeMap[i][j]], { (i * 16.0f) + m_chunkScoot[i][j][0], 0, (j * 16.0f) + m_chunkScoot[i][j][1] }, 1.0f, WHITE);
					m_chunkDrawCount += 1;
				}
			}
		}
	}
}

void Terrain::Shutdown()
{
	
}

float Terrain::GetChunkScootX(int pos[2])
{
		float returnVal = 0.0f;
		if ((pos[0] >= 0) && (pos[0] < 192))
		{
				if ((pos[1] >= 0) && (pos[1] < 192))
				{
						returnVal = m_chunkScoot[pos[0]][pos[1]][0];
				}
		}
		return returnVal;
}

float Terrain::GetChunkScootY(int pos[2])
{
		float returnVal = 0.0f;
		if ((pos[0] >= 0) && (pos[0] < 192))
		{
				if ((pos[1] >= 0) && (pos[1] < 192))
				{
						returnVal = m_chunkScoot[pos[0]][pos[1]][1];
				}
		}
		return returnVal;
}

bool Terrain::IsChunkVisible(int pos[2])
{
	bool retVal = false;
	double visNowTime = GetTime();
	if ((pos[0] >= 0) && (pos[0] < 192))
	{
		if ((pos[1] >= 0) && (pos[1] < 192))
		{
			if (m_chunkVisible[pos[0]][pos[1]] == true)
			{
				retVal = true;
			}/*
			else
			{
				if ((visNowTime - m_chunkVisTime[pos[0]][pos[1]]) < 0.25)
				{
					//if (pos[0] == 0 && pos[1] == 0)
					//{
						printf("	vis time diff %d %d is %f\n", pos[0], pos[1], visNowTime - m_chunkVisTime[pos[0]][pos[1]]);
					//}
					retVal = true;
				}
			}*/
		}
	}
	return retVal;
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
		bool drawTerrain = true;

		int range = g_camera.fovy / 16 + 1;

		int chunkx = g_camera.target.x / 16;
		int chunky = g_camera.target.z / 16;
		//int chunkx = g_camera.position.x / 16;
		//int chunky = g_camera.position.z / 16;

		double visCheckTime = GetTime();
		float mapSize[2];
		mapSize[0] = 192.0f * 16.0f;
		mapSize[1] = 192.0f * 16.0f;

		//bool l_chunkVisible[192][192];

		//printf("drawing chunk range %d - %d, %d - %d\n", chunkx - range, chunkx + range, chunky - range, chunky + range);
		/*
		for (int i = 0; i < 192; i++)
		{
			for (int j = 0; j < 192; j++)
			{
				m_chunkVisible[i][j] = false;
				//m_chunkScoot[i][j][0] = 0.0;
				//m_chunkScoot[i][j][1] = 0.0;
			}
		}*/
		int xmin = 0;
		int ymin = 0;
		int xmax = 192;
		int ymax = 192;
		if ((chunkx - range) < 0)
		{
			xmin = chunkx - range;
		}
		if ((chunkx + range) > 192)
		{
			xmax = chunkx + range;
		}
		if ((chunky - range) < 0)
		{
			ymin = chunky - range;
		}
		if ((chunky + range) > 192)
		{
			ymax = chunky + range;
		}

		for (int i = xmin; i <= xmax + 1; i++)
		{
			for (int j = ymin; j <= ymax + 1; j++)
			{
				int chPosX = i;
				int chPosY = j;
				float thisScoot[2];
				thisScoot[0] = 0.0f;
				thisScoot[1] = 0.0f;
				while (chPosX < 0)
				{
					thisScoot[0] += mapSize[0];
					chPosX += 192;
				}
				while (chPosY < 0)
				{
					thisScoot[1] += mapSize[1];
					chPosY += 192;
				}

				while (chPosX >= 192)
				{
					thisScoot[0] -= mapSize[0];
					chPosX -= 192;
				}
				while (chPosY >= 192)
				{
					thisScoot[1] -= mapSize[1];
					chPosY -= 192;
				}
				//printf("	chunk %d %d actual %d %d	scoot %f %f\n", i, j, chPosX, chPosY, thisScoot[0], thisScoot[1]);
				bool isVisible = false;
				//l_chunkVisible[chPosX][chPosY] = true;
				if (i >= (chunkx - range) && i <= (chunkx + range + 1)) {
					if (j >= (chunky - range) && j <= (chunky + range + 1)) {
						m_chunkScoot[chPosX][chPosY][0] = -thisScoot[0];
						m_chunkScoot[chPosX][chPosY][1] = -thisScoot[1];
						m_chunkVisible[chPosX][chPosY] = true;
						m_chunkVisTime[chPosX][chPosY] = visCheckTime;
						isVisible = true;
					}
				}
				if (isVisible == false) {
					m_chunkVisible[chPosX][chPosY] = false;
				}
			}
		}
		/*
		//printf("Camera Chunk Pos %d %d\n", chunkx, chunky);
		for (int i = chunkx - range; i <= chunkx + range + 1; i++)
		{
			for (int j = chunky - range; j <= chunky + range + 1; j++)
			{
				int chPosX = i;
				int chPosY = j;
				float thisScoot[2];
				thisScoot[0] = 0.0f;
				thisScoot[1] = 0.0f;
				while (chPosX < 0)
				{
					thisScoot[0] += mapSize[0];
					chPosX += 192;
				}
				while (chPosY < 0)
				{
					thisScoot[1] += mapSize[1];
					chPosY += 192;
				}

				while (chPosX >= 192)
				{
					thisScoot[0] -= mapSize[0];
					chPosX -= 192;
				}
				while (chPosY >= 192)
				{
					thisScoot[1] -= mapSize[1];
					chPosY -= 192;
				}
				//printf("	chunk %d %d actual %d %d	scoot %f %f\n", i, j, chPosX, chPosY, thisScoot[0], thisScoot[1]);

				m_chunkScoot[chPosX][chPosY][0] = -thisScoot[0];
				m_chunkScoot[chPosX][chPosY][1] = -thisScoot[1];

				//l_chunkVisible[chPosX][chPosY] = true;
				m_chunkVisible[chPosX][chPosY] = true;
				m_chunkVisTime[chPosX][chPosY] = visCheckTime;
			}
		}*/
		/*
		for (int i = 0; i < 192; i++)
		{
			for (int j = 0; j < 192; j++)
			{
				if (l_chunkVisible[i][j] == false) {
					m_chunkVisible[i][j] = false;
					m_chunkScoot[i][j][0] = 0.0;
					m_chunkScoot[i][j][1] = 0.0;
				}
				else
				{
					m_chunkVisible[i][j] = true;
				}
			}
		}
		*/
		//printf("	chunk vis fin %d\n", m_chunkDrawCount);
}