#pragma warning(disable:4786)

#ifndef _Terrain_H_
#define _Terrain_H_

//#include "Unit.h"
#include "Globals.h"
#include <string>

//  Terrain is broken up into a series of cells, each of which is rendered as
//  either two or four triangles, depending on how the terrain is drawn.

//  Because of fenceposting, the actual dataset of vertices will be one more
//  than the number of cells.  Thus, a 64x64 cell terrain will have 65x65
//  vertices.

//  We'll have two different data structures for this - a 64x64 (for example)
//  array of cell data.  The cell type is initially set, but then is altered
//  based on the height data and game events.  The cells are a cell structure
//  that sets the cell type and any additional data.

//  The height data consists of a 65x65 (for example) array of floating
//  point values.  These will actually be used as the vertices of the terrain
//  when drawing.
	

//  The structure for a single terrain cell.
struct Cell
{
   bool m_Flipped;  //  For the terrain flipping system.
   int m_Modifier;  //  If any additional data is needed it'll be here.
   unsigned int m_Timer; //  If this is greater than 0, then the cell currently has an
                //  abnormal type.  When this timer runs out, recalculate the
                //  terrain type.  Time is in MS.
};

class Terrain : public Object
{

public:
   
   int m_CellWidth;
   int m_CellHeight;
   
   int m_VertexWidth;
   int m_VertexHeight;
   
   float* m_Vertices;
   Cell*  m_Cells;

	Terrain();
	virtual ~Terrain();

	virtual void Init(const std::string& configfile);
   virtual void Init(int x, int y);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	virtual void Attack(int unitid);

	virtual bool SelectCheck();
   
   //  Direct height manipulation
   virtual float GetHeight(int x, int y);  //  Gets the height at those exact coordinates
   virtual float GetHeight(float x, float y);  //  Gets interpolated height within the cell
   float GetCenter(int x, int y);  //  Gets the height of the centerpoint of the cell
	virtual void  SetHeight(int x, int y, float value);  //  Sets the height at those exact coordinates
	virtual void  OffsetHeight(int x, int y, float value);  //  Offsets (raises or lowers) the height at those exact coordinates.

   //  Terrain generation functions
   void InitializeMap(int seed);
   
   bool IsCellVisible(float x, float y);
 
   bool IsPointVisible(glm::vec3 point);
   
   Color GetTriLighting(glm::vec3 v1, glm::vec3 v2, glm::vec3 v3);
	Color GetTriLighting(int x1, int y1, int x2, int y2, int x3, int y3);
   Color GetCellLighting(float x, float y);
   
   Color GetBeachLighting(float x, float y);
   float GetBeachShading(float x, float y);
   
   std::vector<Vertex> CreateTerrainCell(int i, int j);

   void InitializeTerrainMesh5();
   void InitializeTerrainMesh();
   
   int  DetermineTerrainType(int x, int y);
   
   void  UpdateWater();
   float GetWaterHeight(float x, float y);
   
   void FindVisibleCells();
   int GetNumberOfVisibleCells() { return m_VisibleCells.size(); }

   void UpdateTerrainMesh();
   void UpdateIndexBuffers();

   Color GetEdgeLighting(int x, int y, Color inColor);

   Texture* m_Minimap;
   Texture* m_MinimapTerrain;
   Texture* m_TerrainTexture;
   Texture* m_WaterTexture;

   //  Terrain meshes
   Mesh* m_TerrainMesh;

   //  Water, skybox meshes   
   Mesh* m_Water;
   Mesh* m_SkyBox;
   
   //  Highlight
   Mesh* m_Highlight;

   bool m_TerrainChanged;
   
   int m_CellsDrawnThisFrame;
   
   std::vector<std::pair <float, float> > m_VisibleCells;

   std::vector<std::pair <float, float> > m_StraightCells;
   std::vector<std::pair <float, float> > m_FlippedCells;
   
   std::vector<Vertex> m_WaterVector;

   int m_HitX, m_HitY;
   float m_FloatHitX, m_FloatHitY;
   
   bool m_DebugTerrain;

   unsigned int m_LimitedUpdate;
   
   unsigned int m_DurationOfVisibleTest;

   //ModelFrame3D* m_Model;
};

#endif