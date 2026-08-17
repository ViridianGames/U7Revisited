///////////////////////////////////////////////////////////////////////////
//
// Name:     SHAPEDATA.H
// Author:   Anthony Salter
// Date:     3/2/2024
// Purpose:  Defines the drawing data for each shape and can be modified
//				 and serialized/deserialized.
///////////////////////////////////////////////////////////////////////////

#ifndef _SHAPEDATA_H_
#define _SHAPEDATA_H_

#include <vector>
#include "Geist/RaylibModel.h"

struct Texture;

struct coords;

constexpr const char* ShapeDrawTypeStrings[5] = {"Bboard", "Cuboid", "Flat", "Mesh", "Character"};

enum class CuboidTexture
{
	CUBOID_DONT_DRAW = 0,
	CUBOID_DRAW_TOP,
	CUBOID_DRAW_FRONT,
	CUBOID_DRAW_RIGHT,
	CUBOID_DRAW_TOP_INVERTED,
	CUBOID_DRAW_FRONT_INVERTED,
	CUBOID_DRAW_RIGHT_INVERTED,
	CUBOID_DRAW_LAST,
	CUBOID_INVALID,
};

enum class ShapeDrawType
{
	OBJECT_DRAW_BILLBOARD = 0,
	OBJECT_DRAW_CUBOID,
	OBJECT_DRAW_FLAT,
	OBJECT_DRAW_CUSTOM_MESH,
	OBJECT_DRAW_CUSTOM_MESH_DEFER,
	OBJECT_DRAW_ANIMFLAT,
	OBJECT_DRAW_DONT_DRAW,
	//OBJECT_DRAW_UPRIGHTFLAT,
	OBJECT_DRAW_LAST
};

enum class CuboidSides
{
	CUBOID_TOP = 0,
	CUBOID_FRONT,
	CUBOID_RIGHT,
	CUBOID_BOTTOM,
	CUBOID_BACK,
	CUBOID_LEFT,
	CUBOID_LAST
};

class ShapeData
{
public:
	ShapeData();
	~ShapeData()
	{
		m_palettePixels.clear();
		if (m_indexTexture.id > 0)
		{
			UnloadTexture(m_indexTexture);
			m_indexTexture = { 0 };
		}
		if (m_modelIndexTexture.id > 0)
		{
			UnloadTexture(m_modelIndexTexture);
			m_modelIndexTexture = { 0 };
		}
	}

	void Init(int shape, int frame, bool shouldreset = true);

	void SetupDrawTypes();
	void UpdateTextures();

	void Serialize(std::ofstream& outputStream );
	void Deserialize(std::ifstream& inputStream);

	void Draw(const Vector3& pos, float angle, Color color = Color{ 255, 255, 255, 255 }, Vector3 scaling =  Vector3{ 1, 1, 1 });

	// 2D inventory / gump icon (screen-space). Uses palette index + runtime LUT when
	// the shape has glisten pixels so gems/fire/water cycle like world flats/models.
	void DrawInventoryIcon(int x, int y, Color tint = Color{ 255, 255, 255, 255 });

	// Flat mesh origin for DrawModelEx so texture top-left stays hotspot-stable across frames.
	Vector3 GetFlatModelPosition(const Vector3& objectPos) const;

	bool IsValid() { return m_isValid; }
	void SetPixelOffset(int offsetX, int offsetY);
	void CaptureSpecialPaletteReferences(int posX, int posY, int paletteRef);
	void CreateDefaultTexture();

	void SetDefaultTexture(Image image);
	void SetIndexTexture(Image indexImage);
	bool HasPaletteAnimation() const { return m_hasPaletteAnim; }
	Texture2D* GetIndexTexture() { return m_hasPaletteAnim ? &m_indexTexture : nullptr; }

	Image GetDefaultTextureImage() { return m_texture->m_Image; }
	void SetupTextures();
	Texture* GetTexture() { return &m_texture->m_Texture; }
	Texture* GetCuboidTexture() { return &m_cuboidTexture->m_Texture; }

	void SetDrawType(ShapeDrawType drawType) { m_drawType = drawType; }
	ShapeDrawType GetDrawType() { return m_drawType; }

	void SafeAndSane();
	void ResetTopTextureRect();
	void ResetFrontTextureRect();
	void ResetRightTextureRect();

	int GetShape() { return m_shape; }
	int GetFrame() { return m_frame; }

	CuboidTexture GetTextureForSide(CuboidSides side) { return m_sideTextures[static_cast<int>(side)]; }
	void SetTextureForMeshFromSideData(CuboidSides side);
	void SetTextureForSide(CuboidSides side, CuboidTexture texture) { m_sideTextures[static_cast<int>(side)] = texture; }
	void UpdateTextureCoordinates();
	void BuildCuboidMesh();

	// In original pixels
	Rectangle m_topTextureRect;
	Rectangle m_frontTextureRect;
	Rectangle m_rightTextureRect;

	// U7 frame hotspot extents (pixels from origin toward left/above of the bitmap).
	// Stored as passed from SHAPES.VGA (xleft / yabove); bake path uses +1 via m_pixelOffset*.
	int m_xleft = 0;
	int m_yabove = 0;
	int m_pixelOffsetX = 0;
	int m_pixelOffsetY = 0;
	bool m_hasHotspot = false;
	// Sparse list of glisten/cycle pixels 224-243 (terrain/cuboid CPU recolor); full index map is m_indexTexture
	std::vector<std::tuple<int, int, int>> m_palettePixels;

	bool m_isValid;

	int m_shape;
	int m_frame;
	int m_numFrames;

	int m_pointerShape;
	int m_pointerFrame;
	bool m_useShapePointer;

	ShapeDrawType m_drawType;

	Vector3 m_Dims;

	Vector3 m_TweakPos;

	Vector3 m_Scaling;

	Vector3 m_CenterPoint;

	float m_rotation;

	//  Texture for billboard/flat mode; base texture for cuboid mode
	std::unique_ptr<ModTexture> m_texture;
	std::unique_ptr<ModTexture> m_cuboidTexture;

	// Palette-index map (R = index, A = opacity) for GPU palette animation (2D flats/billboards)
	Texture2D m_indexTexture = { 0 };
	bool m_hasPaletteAnim = false;

	// Same idea for CUSTOM_MESH diffuse atlases (e.g. water trough): RGB PNG remapped to
	// palette indices so g_runtimePalette glisten (224-243) animates on the model.
	// Shape editor can disable per shape/frame when nearest-index remap looks wrong.
	Texture2D m_modelIndexTexture = { 0 };
	bool m_hasModelPaletteAnim = false;
	bool m_modelPaletteIndexAttempted = false;
	bool m_modelPaletteCycle = true; // false = always use baked RGB mesh texture

	// Build m_modelIndexTexture from the mesh's .png (if it contains glisten indices).
	bool EnsureModelPaletteIndexTexture();
	void ResetModelPaletteIndexCache();

	std::vector<coords> m_topFaceMods;
	std::vector<coords> m_frontFaceMods;
	std::vector<coords> m_rightFaceMods;

	std::unordered_map<CuboidSides, Vector3> m_faceCenterPoints;

	CuboidTexture m_sideTextures[static_cast<int>(CuboidSides::CUBOID_LAST)];

	std::string m_customMeshName;

	RaylibModel* m_customMesh = nullptr;

	bool m_meshOutline = true;

	std::string m_luaScript;

	RaylibModel* m_flatModel = nullptr;
	RaylibModel* m_uprightFlatModel = nullptr;

};

#endif