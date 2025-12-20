#ifndef _TERRAIN_H_
#define _TERRAIN_H_

//#include "Unit.h"
#include "Geist/Globals.h"
#include "Geist/Primitives.h"
#include <string>
#include <array>

//#define M_PI (3.1415926536f)
//#define DEG2RAD(x) (x*(M_PI/180.0))
constexpr int TILEWIDTH = 100;
constexpr int TILEHEIGHT = 100;

struct ChunkData
{
	int m_chunkId;
	bool m_NClear;
	bool m_EClear;
	bool m_SClear;
	bool m_WClear;
	int m_roofLinkId;

};

class Terrain : public Object
{

public:
   
   int m_width;
   int m_height;

	Color m_cellLighting[TILEWIDTH][TILEHEIGHT];

	Model m_cellModel;
	Mesh m_cellMesh;

   Texture m_terrainTiles;
	RenderTexture m_currentTerrain;

	Terrain();
	virtual ~Terrain();

   virtual void Init();
   virtual void Init(const std::string& data) {};

	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	void CalculateLighting();
   void UpdateTerrainTexture(Image img);

	void UpdateTerrainTiles();

	void SetupChunkData();

	ChunkData m_chunkData[192][192];

	ChunkData m_chunkDatabase[3072];

};

#endif