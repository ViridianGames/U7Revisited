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

#include "Geist/Primitives.h"
#include "U7Object.h"
#include <array>
#include <vector>

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
	OBJECT_DRAW_CHARACTER,
	OBJECT_DRAW_LAST
};

enum class CuboidSides
{
	CUBOID_BOTTOM = 0,
	CUBOID_FRONT,
	CUBOID_BACK,
	CUBOID_RIGHT,
	CUBOID_LEFT,
	CUBOID_TOP,
	CUBOID_LAST
};

class ShapeData
{
public:
	ShapeData();
	~ShapeData() {};

	void Init(int shape, int frame, bool shouldreset = true);

	void SetupDrawTypes();
	void FixupTextures();

	void Serialize(std::ofstream& outputStream );
	void Deserialize(std::ifstream& inputStream);

	void Draw(const Vector3& pos, float angle, Color color = Color{ 255, 255, 255, 255 }, Vector3 scaling =  Vector3{ 1, 1, 1 });

	bool IsValid() { return m_isValid; }

	void CreateDefaultTexture();

	void SetDefaultTexture(Image image);

	Image GetDefaultTextureImage() { return m_originalTexture->m_Image; }
	void SetupTextures();
	Texture* GetTexture() { return &m_originalTexture->m_Texture; }
	Texture* GetTopTexture() { return &m_topTexture->m_Texture; }
	Texture* GetFrontTexture() { return &m_frontTexture->m_Texture; }
	Texture* GetRightTexture() { return &m_rightTexture->m_Texture; }

	void SetDrawType(ShapeDrawType drawType) { m_drawType = drawType; }
	ShapeDrawType GetDrawType() { return m_drawType; }

	void SafeAndSane();
	void ResetTopTexture();
	void ResetFrontTexture();
	void ResetRightTexture();

	int GetShape() { return m_shape; }
	int GetFrame() { return m_frame; }

	CuboidTexture GetTextureForSide(CuboidSides side) { return m_sideTextures[static_cast<int>(side)]; }
	void SetTextureForMeshFromSideData(CuboidSides side);
	void SetTextureForSide(CuboidSides side, CuboidTexture texture) { m_sideTextures[static_cast<int>(side)] = texture; }
	void UpdateAllCuboidTextures();
	void UpdateShapePointerTexture();

	bool Pick(Vector3 thisPos);

	// In original pixels
	int m_topTextureOffsetX;
	int m_topTextureOffsetY;
	int m_topTextureWidth;
	int m_topTextureHeight;

	int m_frontTextureOffsetX;
	int m_frontTextureOffsetY;
	int m_frontTextureWidth;
	int m_frontTextureHeight;

	int m_rightTextureOffsetX;
	int m_rightTextureOffsetY;
	int m_rightTextureWidth;
	int m_rightTextureHeight;

	bool m_isValid;

	int m_shape;
	int m_frame;

	int m_pointerShape;
	int m_pointerFrame;
	bool m_useShapePointer;

	ShapeDrawType m_drawType;

	Vector3 m_Dims;

	Vector3 m_TweakPos;

	Vector3 m_Scaling;

	float m_rotation;

	//  Texture for billboard/flat mode; base texture for cuboid mode

	std::unique_ptr<ModTexture> m_originalTexture;

	//  For drawing in billboard mode

	//Model m_billboardModel;
	//std::unique_ptr<ModTexture> m_billboardTexture;

	//  For drawing in flat mode

	Model m_flatModel;

	//  For drawing in cuboid mode

	std::unique_ptr<ModTexture> m_topTexture;
	std::unique_ptr<ModTexture> m_frontTexture;
	std::unique_ptr<ModTexture> m_rightTexture;
	std::unique_ptr<ModTexture> m_shapePointerTexture;

	std::vector<coords> m_topFaceMods;
	std::vector<coords> m_frontFaceMods;
	std::vector<coords> m_rightFaceMods;

	std::unordered_map<CuboidSides, Vector3> m_faceCenterPoints;

	CuboidTexture m_sideTextures[static_cast<int>(CuboidSides::CUBOID_LAST)];

	std::array<Model, static_cast<int>(CuboidSides::CUBOID_LAST)> m_cuboidModels;

	std::string m_customMeshName;

	Model* m_customMesh = nullptr;

	bool m_meshOutline = true;
};

#endif