#ifndef _Terrain_H_
#define _Terrain_H_

//#include "Unit.h"
#include "Geist/Globals.h"
#include "Geist/Primitives.h"
#include <string>

class Terrain : public Object
{

public:
   
   int m_width;
   int m_height;

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

   bool IsChunkVisible(int x, int y);
 
   void FindVisibleChunks();
   int GetNumberOfVisibleChunks() { return m_visibleChunks.size(); }
};

#endif