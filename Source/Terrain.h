#ifndef _Terrain_H_
#define _Terrain_H_

//#include "Unit.h"
#include "Geist/Globals.h"
#include "Geist/Primitives.h"
#include <string>

//#define M_PI (3.1415926536f)
//#define DEG2RAD(x) (x*(M_PI/180.0))

class Terrain : public Object
{

public:
   
   int m_width;
   int m_height;
   float mapSize[2];
   float m_schunkRadius;
   float m_chunkRadius;

   int m_schunkDrawCount;
   bool m_schunkTested[12][12];
   bool m_schunkVisible[12][12];
   float m_schunkScoot[12][12][2];
   float m_schunkLocation[12][12][2];

   int m_chunkDrawCount;
   bool m_chunkVisible[192][192];
   float m_chunkScoot[192][192][2];
   float m_chunkLocation[192][192][2];

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

   bool IsChunkVisible(int pos[2]);
   bool IsSuperChunkVisible(int pos[2]);
   int GetChunkDrawCount();
   int GetSuperChunkDrawCount();
   float GetChunkScootX(int pos[2]);
   float GetChunkScootY(int pos[2]);
   float GetChunkLocationX(int pos[2]);
   float GetChunkLocationY(int pos[2]);
   float GetSuperChunkLocationX(int pos[2]);
   float GetSuperChunkLocationY(int pos[2]);
 
   void FindVisibleChunks();
   int GetNumberOfVisibleChunks() { return m_visibleChunks.size(); }

   void UpdateTerrainTexture(Image img);

   Image& GetTerrainTexture() { return m_terrainTexture; }

};

#endif