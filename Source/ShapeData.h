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

class Texture;

struct coords;

enum class CuboidTexture
{
	CUBOID_DONT_DRAW = 0,
	CUBOID_DRAW_TOP,
	CUBOID_DRAW_FRONT,
	CUBOID_DRAW_RIGHT,
	CUBOID_DRAW_LAST
};

enum class ShapeDrawType
{
	OBJECT_DRAW_BILLBOARD = 0,
	OBJECT_DRAW_CUBOID,
	OBJECT_DRAW_FLAT,
	OBJECT_DRAW_CUSTOM_MESH,
	OBJECT_DRAW_TABLE,
	OBJECT_DRAW_HANGINGNS,
	OBJECT_DRAW_HANGINGEW,
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

	void Init(int shape, int frame);

	void SetupDrawTypes();
	void FixupTextures();

	void Serialize();
	void Deserialize();

	void Draw(const glm::vec3& pos, float angle, Color color = Color(1, 1, 1, 1));

	bool IsValid() { return m_isValid; }

	Texture* GetTexture() { return m_defaultTexture; }
	Texture* GetTopTexture() { return m_topTexture.get(); }
	Texture* GetFrontTexture() { return m_frontTexture.get(); }
	Texture* GetRightTexture() { return m_rightTexture.get(); }

	void SetDrawType(ShapeDrawType drawType) { m_drawType = drawType; }
	ShapeDrawType GetDrawType() { return m_drawType; }

private:

	bool m_isValid;

	int m_shape;
	int m_frame;

	ShapeDrawType m_drawType;

	//  The custom shape data will also contain a list of custom modifications to the shape.

	std::vector<coords> m_topFaceMods;
	std::vector<coords> m_frontFaceMods;
	std::vector<coords> m_rightFaceMods;

	//  The custom shape data will also contain a list of which sides of the cuboid to draw and which to not draw,
	//  and which of the three faces to apply to those cuboid sides.

	CuboidTexture m_cuboidTextures[6];

	bool m_sideVisibility[static_cast<int>(CuboidSides::CUBOID_LAST)];

	Texture* m_defaultTexture;
	std::unique_ptr<Texture> m_topTexture;
	std::unique_ptr<Texture> m_frontTexture;
	std::unique_ptr<Texture> m_rightTexture;

	std::array<Mesh*, static_cast<int>(CuboidSides::CUBOID_LAST)> m_meshes;

	glm::vec3 m_Scaling;
};

#endif