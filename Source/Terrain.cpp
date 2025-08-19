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
#include "raymath.h"

using namespace std;

Terrain::Terrain()
{ 
   m_height = 3072;
   m_width = 3072;
   m_chunkDrawCount = 0;
   for (int i = 0; i < 192; i++) {
	   for (int j = 0; j < 192; j++) {
		   m_chunkVisible[i][j] = false;
		   m_chunkScoot[i][j][0] = 0.0f;
		   m_chunkScoot[i][j][1] = 0.0f;
		   m_chunkLocation[i][j][0] = float(i) * 16.0f + 8.0f;
		   m_chunkLocation[i][j][1] = float(j) * 16.0f + 8.0f;
	   }
   }

	for (int i = 0; i < m_height; i++)
	{
		m_cellLighting.push_back(std::vector<bool>(m_width, false));
		m_cellLighting[i].resize(m_width);
	}


   printf(" OK pre schunkLocation\n");
   m_schunkDrawCount = 0;
   for (int g = 0; g < 12; g++) {
	   for (int h = 0; h < 12; h++) {
		   m_schunkVisible[g][h] = false;
		   m_schunkScoot[g][h][0] = 0.0f;
		   m_schunkScoot[g][h][1] = 0.0f;
		   m_schunkLocation[g][h][0] = 0.0;
		   m_schunkLocation[g][h][1] = 0.0;
		   for (int i = g * 16; i < (g * 16 + 16); i++) {
			   for (int j = h * 16; j < (h * 16 + 16); j++) {
				   //printf("  add chunk location to superchunk %d %d\n", i, j);
				   m_schunkLocation[g][h][0] += m_chunkLocation[i][j][0];
				   m_schunkLocation[g][h][1] += m_chunkLocation[i][j][1];
			   }
		   }
		   m_schunkLocation[g][h][0] /= 256.0f;
		   m_schunkLocation[g][h][1] /= 256.0f;
		   //m_schunkLocation[g][h][0] = float(g) * 256.0f + 128.0f;
		   //m_schunkLocation[g][h][1] = float(h) * 256.0f + 128.0f;
	   }
   }
   m_terrainTiles = GenImageColor(2048, 256, Color{ 0, 0, 0, 0 });
}

Terrain::~Terrain()
{
   Shutdown();
}

double calcSquare(double val, int pwr) {
	double retVal = val;
	int i = 1;
	while (i < pwr) {
		retVal *= val;
		i += 1;
	}
	return retVal;
}

void Terrain::Init()
{
	int meshSizeX = 16;
	int meshSizeY = 16;
	mapSize[0] = 192.0f * float(meshSizeX);
	mapSize[1] = 192.0f * float(meshSizeY);
	m_schunkRadius = sqrt(calcSquare(double(meshSizeX) * 16.0f, 2) + calcSquare(double(meshSizeY) * 16.0f, 2)) * 0.5f;
	m_chunkRadius = sqrt(calcSquare(double(meshSizeX), 2) + calcSquare(double(meshSizeY), 2)) * 0.75f;
   // Create the chunk database

   //  Create a mesh for each chunk
   Mesh mesh = GenMeshPlane(16, 16, 1, 1);

   //  Move the mesh from the center to the corner
	for (int i = 0; i < mesh.vertexCount; ++i)
	{
		mesh.vertices[i * 3] += 8.0f;
		mesh.vertices[i * 3 + 2] += 8.0f;
	}

	UpdateMeshBuffer(mesh, 0, mesh.vertices, sizeof(float) * mesh.vertexCount * 3, 0);

	m_cellMesh = GenMeshPlane(1, 1, 1, 1);
	for (int i = 0; i < m_cellMesh.vertexCount; ++i)
	{
		m_cellMesh.vertices[i * 3] += 1.5f;
		m_cellMesh.vertices[i * 3 + 2] += 1.5f;
	}

	UploadMesh(&m_cellMesh, true);

	m_cellModel = LoadModelFromMesh(m_cellMesh);
	SetMaterialTexture(&m_cellModel.materials[0], MATERIAL_MAP_DIFFUSE, m_terrainTexture);

   unsigned short prevShape = 0;
   unsigned short prevFrame = 0;
   for (unsigned int i = 0; i < 3072; ++i)
   {
		m_chunkModels[i] = make_unique<Model>(LoadModelFromMesh(mesh));

      Image img = GenImageColor(128, 128, BLACK);
      for (int j = 0; j < 16; ++j)
      {
         for (int k = 0; k < 16; ++k)
         {
            unsigned short thisdata = g_ChunkTypeList[i][j][k];
            unsigned short shapenum = thisdata & 0x3ff;
            unsigned short framenum = (thisdata >> 10) & 0x1f;

            if (shapenum <= 150 && framenum < 32)
            {
               ImageDraw(&img, m_terrainTiles, Rectangle{ shapenum * 8.0f, framenum * 8.0f, 8, 8 }, Rectangle{ k * 8.0f, j * 8.0f, 8, 8 }, WHITE);
               prevShape = shapenum;
               prevFrame = framenum;
            }
            else
            {
					ImageDraw(&img, m_terrainTiles, Rectangle{ prevShape * 8.0f, prevFrame * 8.0f, 8, 8 }, Rectangle{ k * 8.0f, j * 8.0f, 8, 8 }, WHITE);
				}
			}
      }

      Texture texture = LoadTextureFromImage(img);
      SetTextureFilter(texture, TEXTURE_FILTER_POINT);

      SetMaterialTexture(&m_chunkModels[i]->materials[0], MATERIAL_MAP_DIFFUSE, texture);

      UnloadImage(img);
	}
}

void Terrain::UpdateTerrainTexture(Image img)
{
	m_terrainTiles = img;
	m_terrainTexture = LoadTextureFromImage(img);
}

void Terrain::Draw()
{
	m_chunkDrawCount = 0;

	unsigned short prevShape = 0;
	unsigned short prevFrame = 0;

	int range = g_cameraDistance * 1.25f;
	int rangesquared = range * range;
	Vector2 centerpoint = {g_camera.target.x, g_camera.target.z};
	for (int x = g_camera.target.x - range; x <= g_camera.target.x + range; ++x)
	{
		for (int y = g_camera.target.z - range; y <= g_camera.target.z + range; ++y)
		{
			if (Vector2DistanceSqr({float(x), float(y)}, centerpoint ) > rangesquared)
			{
				continue;
			}

			unsigned short shapenum = g_World[y][x] & 0x3ff;
			unsigned short framenum = (g_World[y][x] >> 10) & 0x1f;

			if (shapenum < 150 && framenum < 32)
			{
				prevShape = shapenum;
				prevFrame = framenum;
			}
			else
			{
				shapenum = prevShape;
				framenum = prevFrame;
			}

			m_cellModel.meshes[0].texcoords[0] = (shapenum * 8.0f) / m_terrainTexture.width;
			m_cellModel.meshes[0].texcoords[1] = (framenum * 8.0f) / m_terrainTexture.height;
			m_cellModel.meshes[0].texcoords[2] = ((shapenum + 1) * 8.0f) / m_terrainTexture.width;
			m_cellModel.meshes[0].texcoords[3] = (framenum * 8.0f) / m_terrainTexture.height;
			m_cellModel.meshes[0].texcoords[4] = (shapenum * 8.0f) / m_terrainTexture.width;
			m_cellModel.meshes[0].texcoords[5] = ((framenum + 1) * 8.0f) / m_terrainTexture.height;
			m_cellModel.meshes[0].texcoords[6] = ((shapenum + 1) * 8.0f) / m_terrainTexture.width;
			m_cellModel.meshes[0].texcoords[7] = ((framenum + 1) * 8.0f) / m_terrainTexture.height;

			//m_cellMesh.get()->texcoords[0] = shapenum * 8.0f;
			//m_cellMesh.get()->texcoords[1] = framenum * 8.0f;
			//
			//
			//UpdateMeshBuffer(*m_cellMesh.get(), 1, )

			UpdateMeshBuffer(m_cellModel.meshes[0], 1, m_cellModel.meshes[0].texcoords, 4 * 2 * sizeof(float), 0);

			//  Ugh, this is terrible.  Ugh, this is not going to be performant.  Ugh, I hate it.  Wait...

			if (m_cellLighting[x][y] == true)
			{
				DrawModel(m_cellModel, {float(x) + .5f, 0, float(y) + .5f}, 1, WHITE);
			}
			else
			{
				DrawModel(m_cellModel, {float(x) + .5f, 0, float(y) + .5f}, 1, g_dayNightColor);
			}
		}
	}

	for (int i = 0; i < 192; i++)
	{
		for (int j = 0; j < 192; j++)
		{
			if (m_chunkVisible[i][j])
			{
				//DrawModel(*m_chunkModels[g_chunkTypeMap[i][j]], { (i * 16.0f) + m_chunkScoot[i][j][0], 0, (j * 16.0f) + m_chunkScoot[i][j][1] }, 1.0f, g_dayNightColor);
				//DrawModel(*m_chunkModels[g_chunkTypeMap[i][j]], { (i * 16.0f) + m_chunkScoot[i][j][0], 0, (j * 16.0f) + m_chunkScoot[i][j][1] }, 1.0f, g_dayNightColor);
				m_chunkDrawCount += 1;
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

float Terrain::GetChunkLocationX(int pos[2])
{
	float returnVal = 0.0f;
	if ((pos[0] >= 0) && (pos[0] < 192))
	{
		if ((pos[1] >= 0) && (pos[1] < 192))
		{
			returnVal = m_chunkLocation[pos[0]][pos[1]][0];
		}
	}
	return returnVal;
}

float Terrain::GetChunkLocationY(int pos[2])
{
	float returnVal = 0.0f;
	if ((pos[0] >= 0) && (pos[0] < 192))
	{
		if ((pos[1] >= 0) && (pos[1] < 192))
		{
			returnVal = m_chunkLocation[pos[0]][pos[1]][1];
		}
	}
	return returnVal;
}

float Terrain::GetSuperChunkLocationX(int pos[2])
{
	float returnVal = 0.0f;
	if ((pos[0] >= 0) && (pos[0] < 12)) {
		if ((pos[1] >= 0) && (pos[1] < 12)) {
			returnVal = m_schunkLocation[pos[0]][pos[1]][0];
		}
	}
	return returnVal;
}

float Terrain::GetSuperChunkLocationY(int pos[2])
{
	float returnVal = 0.0f;
	if ((pos[0] >= 0) && (pos[0] < 12)) {
		if ((pos[1] >= 0) && (pos[1] < 12)) {
			returnVal = m_schunkLocation[pos[0]][pos[1]][1];
		}
	}
	return returnVal;
}

bool Terrain::IsSuperChunkVisible(int pos[2])
{
	bool retVal = false;
	//double visNowTime = GetTime();
	if ((pos[0] >= 0) && (pos[0] < 12)) {
		if ((pos[1] >= 0) && (pos[1] < 12)) {
			if (m_schunkVisible[pos[0]][pos[1]] == true) {
				retVal = true;
			}
		}
	}
	return retVal;
}

bool Terrain::IsChunkVisible(int pos[2])
{
	bool retVal = false;
	//double visNowTime = GetTime();
	if ((pos[0] >= 0) && (pos[0] < 192))
	{
		if ((pos[1] >= 0) && (pos[1] < 192))
		{
			if (m_chunkVisible[pos[0]][pos[1]] == true)
			{
				retVal = true;
			}
		}
	}
	return retVal;
}

int Terrain::GetSuperChunkDrawCount()
{
	return m_schunkDrawCount;
}

int Terrain::GetChunkDrawCount()
{
	return m_chunkDrawCount;
}

void Terrain::Update()
{
   if (g_CameraMoved)
   {
      FindVisibleChunks();
   }

	g_Terrain->UpdateLighting();
}

void Terrain::FindVisibleChunks()
{
    m_visibleChunks.clear();
	float depthRangeNear = 1.0f;
	float depthRangeFar = 1024.0f;

	int range = g_camera.fovy / 16 + 1;
	int srange = 6;
	Vector3 camPos = { g_camera.position.x,
					   g_camera.position.y,
					   g_camera.position.z };
	Matrix viewMat = MatrixLookAt(g_camera.position, g_camera.target, g_camera.up);
	Vector3 vecFWD = { viewMat.m2, viewMat.m6, viewMat.m10 };
	Vector3 vecRGT = { viewMat.m0, viewMat.m4, viewMat.m8 };
	Vector3 vecUP = { viewMat.m1, viewMat.m5, viewMat.m9 };
	float foView = 1.7777777777777777777777777777778 * g_camera.fovy;
	float halfFOVy = DEG2RAD * (g_camera.fovy * 0.75f);
	float cosHalfFOVy = cos(halfFOVy);
	float tanHalfFOVy = tan(halfFOVy);
	float chunkYD = m_chunkRadius / cosHalfFOVy;
	float chunkYH = 0.0f;
	float schunkYD = m_schunkRadius / cosHalfFOVy;
	float schunkYH = 0.0f;

	float halfFOVz = DEG2RAD * (foView * 0.5f);
	float cosHalfFOVz = cos(halfFOVz);
	float tanHalfFOVz = tan(halfFOVz);
	float chunkZD = m_chunkRadius / cosHalfFOVz;
	float chunkZH = 0.0f;
	float schunkZD = m_schunkRadius / cosHalfFOVz;
	float schunkZH = 0.0f;

	int chunkx = int(camPos.x / 16.0f);
	int chunky = int(camPos.z / 16.0f);
	int schunkx = int(float(chunkx - (chunkx % 16)) / 16.0f);
	int schunky = int(float(chunky - (chunky % 16)) / 16.0f);

	double visCheckTime = GetTime();
	float mapSize[2];
	mapSize[0] = 192.0f * 16.0f;
	mapSize[1] = 192.0f * 16.0f;

	for (int i = 0; i < 12; i++) {
		for (int j = 0; j < 12; j++) {
			m_schunkVisible[i][j] = false;
			m_schunkTested[i][j] = false;
		}
	}
	float dotForward = 0.0f;
	float dotRight = 0.0f;
	float dotUp = 0.0f;
	float maxRight = 0.0f;

	int sxmin = schunkx - srange;
	int symin = schunky - srange;
	int sxmax = schunkx + srange;
	int symax = schunky + srange;

	for (int g = sxmin; g <= sxmax + 1; g++) {
		for (int h = symin; h <= symax + 1; h++) {
			int schPosX = g;
			int schPosY = h;
			float thisScoot[2];
			int scPos[2];
			scPos[0] = g;
			scPos[1] = h;
			thisScoot[0] = 0.0f;
			thisScoot[1] = 0.0f;
			while (schPosX < 0) {
				thisScoot[0] += mapSize[0];
				schPosX += 12;
			}
			while (schPosY < 0) {
				thisScoot[1] += mapSize[1];
				schPosY += 12;
			}
			while (schPosX >= 12) {
				thisScoot[0] -= mapSize[0];
				schPosX -= 12;
			}
			while (schPosY >= 12) {
				thisScoot[1] -= mapSize[1];
				schPosY -= 12;
			}
			if (m_schunkTested[schPosX][schPosY] == false) {
				scPos[0] = schPosX;
				scPos[1] = schPosY;
				Vector3 schunkPos;
				schunkPos.x = GetSuperChunkLocationX(scPos) - thisScoot[0];
				schunkPos.y = 0.0f;
				schunkPos.z = GetSuperChunkLocationY(scPos) - thisScoot[1];
				Vector3 diffPos = { camPos.x - schunkPos.x, camPos.y - schunkPos.y, camPos.z - schunkPos.z };
				dotForward = Vector3DotProduct(vecFWD, diffPos);
				if ((dotForward > depthRangeNear - m_schunkRadius) && (dotForward < depthRangeFar + m_schunkRadius)) {
					// FRUSTUM left / right
					dotRight = fabs(Vector3DotProduct(vecRGT, diffPos));
					schunkZH = dotForward * tanHalfFOVz;
					if (dotRight < schunkZD + schunkZH) {
						// FRUSTUM up / down
						dotUp = fabs(Vector3DotProduct(vecUP, diffPos));
						schunkYH = dotForward * tanHalfFOVy;
						if (dotUp < schunkYD + schunkYH) {
							m_schunkScoot[schPosX][schPosY][0] = -thisScoot[0];
							m_schunkScoot[schPosX][schPosY][1] = -thisScoot[1];
							m_schunkVisible[schPosX][schPosY] = true;
						}
					}
				}
				m_schunkTested[schPosX][schPosY] = true;
				if (m_schunkVisible[schPosX][schPosY] == true) {
					for (int i = schPosX * 16; i < ((schPosX * 16) + 16); i++) {
						for (int j = schPosY * 16; j < ((schPosY * 16) + 16); j++) {
							Vector3 chunkPos = { m_chunkLocation[i][j][0] + -thisScoot[0], 0.0, m_chunkLocation[i][j][1] + -thisScoot[1] };
							Vector3 diffPos = { camPos.x - chunkPos.x, camPos.y - chunkPos.y, camPos.z - chunkPos.z };
							dotForward = Vector3DotProduct(vecFWD, diffPos);
							if ((dotForward > depthRangeNear - m_chunkRadius) && (dotForward < depthRangeFar + m_chunkRadius)) {
								// FRUSTUM left / right
								dotRight = fabs(Vector3DotProduct(vecRGT, diffPos));
								chunkZH = dotForward * tanHalfFOVz;
								if (dotRight < chunkZD + chunkZH) {
									// FRUSTUM up / down
									dotUp = fabs(Vector3DotProduct(vecUP, diffPos));
									chunkYH = dotForward * tanHalfFOVy;
									if (dotUp < chunkYD + chunkYH) {
										m_chunkScoot[i][j][0] = -thisScoot[0];
										m_chunkScoot[i][j][1] = -thisScoot[1];
										m_chunkVisible[i][j] = true;
									}
								}
							}
						}
					}
				}
				else {
					for (int i = schPosX * 16; i < (schPosX * 16 + 16); i++) {
						for (int j = schPosY * 16; j < (schPosY * 16 + 16); j++) {
							m_chunkScoot[i][j][0] = -thisScoot[0];
							m_chunkScoot[i][j][1] = -thisScoot[1];
							m_chunkVisible[i][j] = false;
						}
					}
				}
			}
		}
	}
}

void Terrain::UpdateLighting()
{

	int range = g_cameraDistance * 1.25f;
	int rangesquared = range * range;
	for (int i = g_camera.target.x - range; i <= g_camera.target.x + range; i++)
	{
		for (int j = g_camera.target.z - rangesquared; j <= g_camera.target.z + rangesquared; j++)
		{
			m_cellLighting[i][j] = false;
		}
	}

	int lightrange = 6;
	int lightrangesquared = 36;
	for (auto object : g_sortedVisibleObjects)
	{
		if (object.get()->m_objectData->m_isLightSource)
		{
			U7Object* obj = object.get();

			for (int i = g_camera.target.x - range; i <= g_camera.target.x + range; i++)
			{
				for (int j = g_camera.target.z - rangesquared; j <= g_camera.target.z + rangesquared; j++)
				{
					if (Vector2DistanceSqr({float(i), float(j)}, {obj->m_Pos.x, obj->m_Pos.z}) < lightrangesquared)
					{
						m_cellLighting[i][j] = true;
					}
				}
			}
		}
	}
}