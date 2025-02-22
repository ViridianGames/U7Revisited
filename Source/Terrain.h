#ifndef _Terrain_H_
#define _Terrain_H_

//#include "Unit.h"
#include "Geist/Globals.h"
#include "Geist/Primitives.h"
#include <string>

enum class TerrainType
{
	TERRAIN_NONE = 0,
	TERRAIN_LAND,
	TERRAIN_COAST,
	TERRAIN_RIVER,
	TERRAIN_OCEAN,
	TERRAIN_CAVERN,
	TERRAIN_CAVERN_ENTRANCE,
	TERRAIN_SECRET,
	TERRAIN_LAST
};

class Terrain : public Object
{

public:
	 
	 int m_width;
	 int m_height;

	 int m_chunkDrawCount;
	 double m_chunkVisTime[192][192];
	 bool m_chunkVisible[192][192];
	 float m_chunkScoot[192][192][2];
	 TerrainType m_type[192][192];

	 std::vector<std::pair <float, float> > m_visibleChunks;

	 std::array<std::unique_ptr<Model>, 3072> m_chunkModels;

	 Image m_terrainTexture;
	 
	Terrain();
	virtual ~Terrain();

	 virtual void Init();
	 virtual void Init(const std::string& data) {};

	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	bool ChunkIsWater(int chunkIdx);
	void SetTerrainType(int pos[2], TerrainType tType);
	TerrainType GetTerrainType(int pos[2]);

	 bool IsChunkVisible(int pos[2]);
	 float GetChunkScootX(int pos[2]);
	 float GetChunkScootY(int pos[2]);
 
	 void FindVisibleChunks();
	 int GetNumberOfVisibleChunks() { return m_visibleChunks.size(); }

	 void UpdateTerrainTexture(Image img);

	 Image& GetTerrainTexture() { return m_terrainTexture; }

};

#endif