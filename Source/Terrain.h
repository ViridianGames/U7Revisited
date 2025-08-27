#ifndef _TERRAIN_H_
#define _TERRAIN_H_

//#include "Unit.h"
#include "Geist/Globals.h"
#include "Geist/Primitives.h"
#include <string>
#include <array>

//#define M_PI (3.1415926536f)
//#define DEG2RAD(x) (x*(M_PI/180.0))
constexpr int TILEWIDTH = 90;
constexpr int TILEHEIGHT = 90;

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
};

#endif