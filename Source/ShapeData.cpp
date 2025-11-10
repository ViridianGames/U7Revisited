#include <sstream>
#include <fstream>
#include <string>
#include <utility>
#include <algorithm>

#include "raylib.h"
#include "rlgl.h"

#include "glad.h"

#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "Geist/Config.h"
#include "Geist/Engine.h"
#include "U7Globals.h"
#include "ShapeData.h"

using namespace std;

ShapeData::ShapeData()
{
	m_isValid = false;
	m_shape = 150;
	m_frame = 0;

	for (int i = 0; i < 6; ++i)
	{
		m_sideTextures[i] = CuboidTexture::CUBOID_INVALID;
	}

	m_Scaling = Vector3{ 1, 1, 1 };
	m_TweakPos = Vector3{ 0, 0, 0 };
	m_rotation = 0;
	m_customMeshName = "Models/3dmodels/zzwrongcube.obj";
	m_meshOutline = true;
	m_useShapePointer = false;
	m_luaScript = "default";
	m_texture = nullptr;
	m_cuboidTexture = nullptr;
}

void ShapeData::Init(int shape, int frame, bool shouldreset)
{
	m_shape = shape;
	m_frame = frame;

	//  A 1-pixel texture denotes a default texture that was never loaded
	if (m_texture == nullptr || (m_texture.get()->width == 1 && m_texture.get()->height == 1) ||
		m_texture->m_Image.width <= 0 || m_texture->m_Image.height <= 0)
	{
		m_isValid = false;
	}
	else
	{
		Image image = GenImageColor(m_texture->m_Image.width * 2, m_texture->m_Image.height * 2, Color{ 0, 0, 0, 0 });

		m_cuboidTexture = std::make_unique<ModTexture>(image);

		m_isValid = true;

		ObjectData* objectData = &g_objectDataTable[m_shape];

		for (int i = 0; i < 6; ++i)
		{
			if (m_sideTextures[i] == CuboidTexture::CUBOID_INVALID)
			{
				switch (static_cast<CuboidSides>(i))
				{
				case CuboidSides::CUBOID_TOP:
				case CuboidSides::CUBOID_BOTTOM:
					m_sideTextures[i] = CuboidTexture::CUBOID_DRAW_TOP;
					break;
				case CuboidSides::CUBOID_LEFT:
				case CuboidSides::CUBOID_RIGHT:
					m_sideTextures[i] = CuboidTexture::CUBOID_DRAW_RIGHT;
					break;
				case CuboidSides::CUBOID_BACK:
				case CuboidSides::CUBOID_FRONT:
					m_sideTextures[i] = CuboidTexture::CUBOID_DRAW_FRONT;
					break;
				}
			}
		}

		SetupDrawTypes();
	}

	m_customMesh = g_ResourceManager->GetModel(m_customMeshName);
	BuildCuboidMesh();
}

void ShapeData::SetDefaultTexture(Image image)
{
	if (m_texture == nullptr)
	{
		m_texture = std::make_unique<ModTexture>(image);
	}
	else
	{
		m_texture->AssignImage(image);
	}
}

void ShapeData::CreateDefaultTexture()
{
	if (m_texture == nullptr)
	{
		m_texture = std::make_unique<ModTexture>();
	}
}

void ShapeData::SetupTextures()
{
}

void ShapeData::Serialize(ofstream& outStream)
{
	outStream << m_shape << " ";
	outStream << m_frame << " ";
	outStream << int(m_topTextureRect.x) << " ";
	outStream << int(m_topTextureRect.y) << " ";
	outStream << int(m_topTextureRect.width) << " ";
	outStream << int(m_topTextureRect.height) << " ";

	outStream << int(m_frontTextureRect.x) << " ";
	outStream << int(m_frontTextureRect.y) << " ";
	outStream << int(m_frontTextureRect.width) << " ";
	outStream << int(m_frontTextureRect.height) << " ";

	outStream << int(m_rightTextureRect.x) << " ";
	outStream << int(m_rightTextureRect.y) << " ";
	outStream << int(m_rightTextureRect.width) << " ";
	outStream << int(m_rightTextureRect.height) << " ";

	outStream << static_cast<int>(m_drawType) << " ";
	outStream << m_Scaling.x << " ";
	outStream << m_Scaling.y << " ";
	outStream << m_Scaling.z << " ";
	outStream << m_TweakPos.x << " ";
	outStream << m_TweakPos.y << " ";
	outStream << m_TweakPos.z << " ";
	outStream << m_rotation << " ";
	outStream << static_cast<int>(m_sideTextures[0]) << " ";
	outStream << static_cast<int>(m_sideTextures[1]) << " ";
	outStream << static_cast<int>(m_sideTextures[2]) << " ";
	outStream << static_cast<int>(m_sideTextures[3]) << " ";
	outStream << static_cast<int>(m_sideTextures[4]) << " ";
	outStream << static_cast<int>(m_sideTextures[5]) << " ";
	std::replace(m_customMeshName.begin(), m_customMeshName.end(), '\\', '/');
	outStream << m_customMeshName << " ";
	outStream << m_meshOutline << " ";
	outStream << m_useShapePointer << " ";
	outStream << m_pointerShape << " ";
	outStream << m_pointerFrame << " ";
	outStream << m_luaScript << " ";
	outStream << endl;

	outStream.flush();
}

void ShapeData::Deserialize(ifstream& inStream)
{
	inStream >> m_shape;
	inStream >> m_frame;
	inStream >> m_topTextureRect.x;
	inStream >> m_topTextureRect.y;
	inStream >> m_topTextureRect.width;
	inStream >> m_topTextureRect.height;

	inStream >> m_frontTextureRect.x;
	inStream >> m_frontTextureRect.y;
	inStream >> m_frontTextureRect.width;
	inStream >> m_frontTextureRect.height;

	inStream >> m_rightTextureRect.x;
	inStream >> m_rightTextureRect.y;
	inStream >> m_rightTextureRect.width;
	inStream >> m_rightTextureRect.height;

	int drawType;
	inStream >> drawType;
	m_drawType = static_cast<ShapeDrawType>(drawType);
	inStream >> m_Scaling.x;
	if (abs(m_Scaling.x) < .01f) { m_Scaling.x = 0; }
	inStream >> m_Scaling.y;
	if (abs(m_Scaling.y) < .01f) { m_Scaling.y = 0; }
	inStream >> m_Scaling.z;
	if (abs(m_Scaling.z) < .01f) { m_Scaling.z = 0; }
	inStream >> m_TweakPos.x;
	if (abs(m_TweakPos.x) < .01f) { m_TweakPos.x = 0; }
	inStream >> m_TweakPos.y;
	if (abs(m_TweakPos.y) < .01f) { m_TweakPos.y = 0; }
	inStream >> m_TweakPos.z;
	if (abs(m_TweakPos.z) < .01f) { m_TweakPos.z = 0; }
	inStream >> m_rotation;
	int sideTexture;
	inStream >> sideTexture;
	m_sideTextures[0] = static_cast<CuboidTexture>(sideTexture);
	inStream >> sideTexture;
	m_sideTextures[1] = static_cast<CuboidTexture>(sideTexture);
	inStream >> sideTexture;
	m_sideTextures[2] = static_cast<CuboidTexture>(sideTexture);
	inStream >> sideTexture;
	m_sideTextures[3] = static_cast<CuboidTexture>(sideTexture);
	inStream >> sideTexture;
	m_sideTextures[4] = static_cast<CuboidTexture>(sideTexture);
	inStream >> sideTexture;
	m_sideTextures[5] = static_cast<CuboidTexture>(sideTexture);

	if (m_shape == 191)
	{
		int stopper = 0;
	}

	inStream >> m_customMeshName;
	std::replace(m_customMeshName.begin(), m_customMeshName.end(), '\\', '/');
	inStream >> m_meshOutline;

	inStream >> m_useShapePointer;
	inStream >> m_pointerShape;
	inStream >> m_pointerFrame;

	inStream >> m_luaScript;

	Init(m_shape, m_frame, false);
}

void ShapeData::ResetTopTextureRect()
{
	ObjectData* objectData = &g_objectDataTable[m_shape];

	m_topTextureRect.x = 0;
	m_topTextureRect.y = 0;
	m_topTextureRect.width = objectData->m_width * 8;
	m_topTextureRect.height = objectData->m_depth * 8;

	SafeAndSane();
}

void ShapeData::ResetFrontTextureRect()
{
	ObjectData* objectData = &g_objectDataTable[m_shape];

	m_frontTextureRect.x = 0;
	m_frontTextureRect.y = objectData->m_depth * 8;
	m_frontTextureRect.width = objectData->m_width * 8;
	m_frontTextureRect.height = m_texture->height - objectData->m_depth * 8;

	SafeAndSane();
}

void ShapeData::ResetRightTextureRect()
{
	ObjectData* objectData = &g_objectDataTable[m_shape];

	m_rightTextureRect.x = objectData->m_width * 8;
	m_rightTextureRect.y = 0;
	m_rightTextureRect.width = m_texture->width - objectData->m_width * 8;
	m_rightTextureRect.height = objectData->m_depth * 8;

	SafeAndSane();
}

void ShapeData::SafeAndSane()
{


	ModTexture* textureToUse = m_texture.get();

	if (m_topTextureRect.width > textureToUse->width) { m_topTextureRect.width = textureToUse->width; }
	if (m_topTextureRect.height > textureToUse->height) { m_topTextureRect.height = textureToUse->height; }
	if (m_frontTextureRect.width > textureToUse->width) { m_frontTextureRect.width = textureToUse->width; }
	if (m_frontTextureRect.height > textureToUse->height) { m_frontTextureRect.height = textureToUse->height; }
	if (m_rightTextureRect.width > textureToUse->width) { m_rightTextureRect.width = textureToUse->width; }
	if (m_rightTextureRect.height > textureToUse->height) { m_rightTextureRect.height = textureToUse->height; }

	if (m_topTextureRect.width < 1) { m_topTextureRect.width = 1; }
	if (m_topTextureRect.height < 1) { m_topTextureRect.height = 1; }
	if (m_frontTextureRect.width < 1) { m_frontTextureRect.width = 1; }
	if (m_frontTextureRect.height < 1) { m_frontTextureRect.height = 1; }
	if (m_rightTextureRect.width < 1) { m_rightTextureRect.width = 1; }
	if (m_rightTextureRect.height < 1) { m_rightTextureRect.height = 1; }


	if (m_topTextureRect.x + m_topTextureRect.width > textureToUse->width)
	{
		m_topTextureRect.x = textureToUse->width - m_topTextureRect.width;
	}

	if (m_topTextureRect.y + m_topTextureRect.height > textureToUse->height)
	{
		m_topTextureRect.y = textureToUse->height - m_topTextureRect.y;
	}

	if (m_frontTextureRect.x + m_frontTextureRect.width > textureToUse->width)
	{
		m_frontTextureRect.x = textureToUse->width - m_frontTextureRect.width;
	}

	if (m_frontTextureRect.y + m_frontTextureRect.height > textureToUse->height)
	{
		m_frontTextureRect.y = textureToUse->height - m_frontTextureRect.height;
	}

	if (m_rightTextureRect.x + m_rightTextureRect.width > textureToUse->width)
	{
		m_rightTextureRect.x = textureToUse->width - m_rightTextureRect.width;
	}

	if (m_rightTextureRect.y + m_rightTextureRect.height > textureToUse->height)
	{
		m_rightTextureRect.y = textureToUse->height - m_rightTextureRect.height;
	}

	if (m_topTextureRect.x < 0) { m_topTextureRect.x = 0; }
	if (m_topTextureRect.y < 0) { m_topTextureRect.y = 0; }

	if (m_frontTextureRect.x < 0) { m_frontTextureRect.x = 0; }
	if (m_frontTextureRect.y < 0) { m_frontTextureRect.y = 0; }

	if (m_rightTextureRect.x < 0) { m_rightTextureRect.x = 0; }
	if (m_rightTextureRect.y < 0) { m_rightTextureRect.y = 0; }
}

void ShapeData::SetupDrawTypes()
{
	ObjectData* objectData = &g_objectDataTable[m_shape];

	m_Dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };

	if (m_drawType == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
	{
		m_Dims = Vector3{ float(m_texture->width) / 8.0f, float(m_texture->height) / 8.0f, 1 };
	}
	else if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
	{
		m_Dims = Vector3{ float(m_texture->width) / 8.0f, 0, float(m_texture->height) / 8.0f };
	}
	else
	{
		m_Dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
	}

	//m_CenterPoint = Vector3{ m_Dims.x / 2, m_Dims.y / 2, m_Dims.z / 2 };

	//  FLAT DRAWING
	m_flatModel = g_ResourceManager->GetModel("Models/3dmodels/flat.obj");
	//m_flatModel = g_ResourceManager->GetModel("Models/3dmodels/uprightflat.obj");

	//  CUBOID DRAWING

	//m_cuboidModel = g_ResourceManager->GetModel("Models/3dmodels/cuboidmodel.obj");

	//  CUSTOM MESH
	m_customMesh = g_ResourceManager->GetModel(m_customMeshName);

	UpdateTextures();
};

void ShapeData::UpdateTextures()
{
	if (!g_shapeTable[m_shape][m_frame].IsValid())
		return;

	// If cuboid texture hasn't been created yet, skip update
	if (m_cuboidTexture == nullptr)
		return;

	//  Fixup the texture for this object.
	ObjectData* objectData = &g_objectDataTable[m_shape];

	SafeAndSane();

	ModTexture* textureToUse = m_texture.get();

	int startx = 0;
	int starty = 0;

	ImageClearBackground(&m_cuboidTexture->m_Image, { 0, 0, 0, 0 });

	ImageDraw(&m_cuboidTexture->m_Image, m_texture->m_Image, m_topTextureRect,
		{ 0, 0, m_topTextureRect.width, m_topTextureRect.height }, WHITE);

	//  Front face unslant
	int counter = 0;
	for (int i = m_frontTextureRect.y; i < m_frontTextureRect.y + m_frontTextureRect.height; ++i)
	{
		//  Count empty pixels at the beginning of this line
		int offset = 0;
		for (int j = m_frontTextureRect.x; j < m_texture.get()->width; ++j)
		{
			Color thisPixel = GetImageColor(m_texture->m_Image, j, i);
			if (thisPixel.a == 0 && thisPixel.r == 0 && thisPixel.g == 0 && thisPixel.b == 0)
				++offset;
			else
				break;
		}

		if (offset == m_texture->width)
		{
			//  There were no pixels to copy on this line
			continue;
		}

		float finalwidth = m_frontTextureRect.width;
		if (m_frontTextureRect.x + offset + m_frontTextureRect.width >= m_texture->width)
		{
			finalwidth = m_texture.get()->width - (m_frontTextureRect.x + offset);
		}

		ImageDraw(&m_cuboidTexture->m_Image, m_texture->m_Image,
			{ m_frontTextureRect.x + offset, m_frontTextureRect.y + counter, finalwidth, 1 }, //  Source rect
			{ 0, m_topTextureRect.height + counter + 1, finalwidth, 1 }, //  Dest rect
			WHITE
		);

		++counter;
	}

	//  Right face unslant
	counter = 0;
	for (int i = m_rightTextureRect.x; i < m_rightTextureRect.x + m_rightTextureRect.width; ++i)
	{
		//  Count empty pixels at the beginning of this line
		int offset = 0;
		for (int j = m_rightTextureRect.y; j < m_texture.get()->height; ++j)
		{
			Color thisPixel = GetImageColor(m_texture->m_Image, i, j);
			if (thisPixel.a == 0 && thisPixel.r == 0 && thisPixel.g == 0 && thisPixel.b == 0)
				++offset;
			else
				break;
		}

		if (offset == m_texture->height)
		{
			//  There were no pixels to copy on this line
			continue;
		}

		float finalheight = m_rightTextureRect.height;
		if (m_rightTextureRect.y + offset + m_rightTextureRect.height >= m_texture->height)
		{
			finalheight = m_texture.get()->height - (m_rightTextureRect.y + offset);
		}

		ImageDraw(&m_cuboidTexture->m_Image, m_texture->m_Image,
		{ m_rightTextureRect.x + counter, m_rightTextureRect.y + offset, 1, finalheight }, //  Source rect
		{ m_topTextureRect.width + counter + 1, m_rightTextureRect.y, 1, finalheight }, //  Dest rect
			WHITE
		);

		++counter;
	}

	m_cuboidTexture->UpdateTexture();
	UpdateTextureCoordinates();

}

void ShapeData::UpdateTextureCoordinates()
{
	if (g_CuboidModel == nullptr)
		return;

	//  Top face
	float topUVCoords[6 * 2] =
	{
		0.0,	0.0f,
		m_topTextureRect.width / m_cuboidTexture.get()->width,	0.0f,
		0.0f, m_topTextureRect.height / m_cuboidTexture.get()->height,

		m_topTextureRect.width / m_cuboidTexture.get()->width, m_topTextureRect.height / m_cuboidTexture.get()->height,
		0.0f, m_topTextureRect.height / m_cuboidTexture.get()->height,
		m_topTextureRect.width / m_cuboidTexture.get()->width,	0.0f,
	};

	//  Front face
	float frontUVCoords[6 * 2] =
	{
		0, (m_topTextureRect.height + 1) / m_cuboidTexture.get()->height,
		m_frontTextureRect.width / m_cuboidTexture.get()->width, (m_topTextureRect.height + 1) / m_cuboidTexture.get()->height,
		0, (m_topTextureRect.height + 1 + m_frontTextureRect.height) / m_cuboidTexture.get()->height,

		m_frontTextureRect.width / m_cuboidTexture.get()->width, (m_topTextureRect.height + 1 + m_frontTextureRect.height) / m_cuboidTexture.get()->height,
		0, (m_topTextureRect.height + 1 + m_frontTextureRect.height) / m_cuboidTexture.get()->height,
		m_frontTextureRect.width / m_cuboidTexture.get()->width, (m_topTextureRect.height + 1) / m_cuboidTexture.get()->height,
	};

	//  Right face
	float rightUVCoords[6 * 2] =
	{
		(m_topTextureRect.width + 1) / m_cuboidTexture.get()->width, 	m_rightTextureRect.height / m_cuboidTexture.get()->height,
		(m_topTextureRect.width + 1) / m_cuboidTexture.get()->width,	0,
		(m_topTextureRect.width + 1 + m_rightTextureRect.width) / m_cuboidTexture.get()->width, m_rightTextureRect.height / m_cuboidTexture.get()->height,

		(m_topTextureRect.width + 1 + m_rightTextureRect.width) / m_cuboidTexture.get()->width,	0.0f,
		(m_topTextureRect.width + 1 + m_rightTextureRect.width) / m_cuboidTexture.get()->width, m_rightTextureRect.height / m_cuboidTexture.get()->height,
		(m_topTextureRect.width + 1) / m_cuboidTexture.get()->width,	0,
	};

	//  Top inverted
	float topInvertedUVCoords[6 * 2] =
	{
		m_topTextureRect.width / m_cuboidTexture.get()->width, 0.0f,
		0.0f, 0.0f,
		m_topTextureRect.width / m_cuboidTexture.get()->width, m_topTextureRect.height / m_cuboidTexture.get()->height,

		0.0f, m_topTextureRect.height / m_cuboidTexture.get()->height,
		m_topTextureRect.width / m_cuboidTexture.get()->width, m_topTextureRect.height / m_cuboidTexture.get()->height,
		0.0f, 0.0f,
	};

	//  Front inverted
	float frontInvertedUVCoords[6 * 2] =
	{
		m_frontTextureRect.width / m_cuboidTexture.get()->width, (m_topTextureRect.height + 1) / m_cuboidTexture.get()->height,
		0, (m_topTextureRect.height + 1) / m_cuboidTexture.get()->height,
		m_frontTextureRect.width / m_cuboidTexture.get()->width, (m_topTextureRect.height + 1 + m_frontTextureRect.height) / m_cuboidTexture.get()->height,

		0, (m_topTextureRect.height + 1 + m_frontTextureRect.height) / m_cuboidTexture.get()->height,
		m_frontTextureRect.width / m_cuboidTexture.get()->width, (m_topTextureRect.height + 1 + m_frontTextureRect.height) / m_cuboidTexture.get()->height,
		0, (m_topTextureRect.height + 1) / m_cuboidTexture.get()->height,
	};

	//  Right inverted
	float rightInvertedUVCoords[6 * 2] =
	{
		(m_topTextureRect.width + 1) / m_cuboidTexture.get()->width, 	0,
		(m_topTextureRect.width + 1) / m_cuboidTexture.get()->width,	m_rightTextureRect.height / m_cuboidTexture.get()->height,
		(m_topTextureRect.width + 1 + m_rightTextureRect.width) / m_cuboidTexture.get()->width, 0,

		(m_topTextureRect.width + 1 + m_rightTextureRect.width) / m_cuboidTexture.get()->width,m_rightTextureRect.height / m_cuboidTexture.get()->height,
		(m_topTextureRect.width + 1 + m_rightTextureRect.width) / m_cuboidTexture.get()->width, 0,
		(m_topTextureRect.width + 1) / m_cuboidTexture.get()->width,m_rightTextureRect.height / m_cuboidTexture.get()->height,
	};

	float dontdrawUVCoords[6 * 2] = {
	.75f,	.75f,
	1.0f,	.75f,
	.75f,	1.0f,
	1.0f,	1.0f,
	.75f,	1.0f,
	1.0f,	.75f,
	};

	for (int i = 0; i < 6; ++i)
	{
		switch (GetTextureForSide(CuboidSides(i)))
		{
		case CuboidTexture::CUBOID_DRAW_TOP:
		{
			UpdateMeshBuffer(g_CuboidModel.get()->meshes[0], 1, topUVCoords, 6 * 2 * sizeof(float), i * 6 * 2 * sizeof(float));
			break;
		}
		case CuboidTexture::CUBOID_DRAW_FRONT:
		{
			UpdateMeshBuffer(g_CuboidModel.get()->meshes[0], 1, frontUVCoords, 6 * 2 * sizeof(float), i * 6 * 2 * sizeof(float));
			break;
		}
		case CuboidTexture::CUBOID_DRAW_RIGHT:
		{
			UpdateMeshBuffer(g_CuboidModel.get()->meshes[0], 1, rightUVCoords, 6 * 2 * sizeof(float), i * 6 * 2 * sizeof(float));
			break;
		}
		case CuboidTexture::CUBOID_DRAW_FRONT_INVERTED:
		{
			UpdateMeshBuffer(g_CuboidModel.get()->meshes[0], 1, frontInvertedUVCoords, 6 * 2 * sizeof(float), i * 6 * 2 * sizeof(float));
			break;
		}
		case CuboidTexture::CUBOID_DRAW_RIGHT_INVERTED:
		{
			UpdateMeshBuffer(g_CuboidModel.get()->meshes[0], 1, rightInvertedUVCoords, 6 * 2 * sizeof(float), i * 6 * 2 * sizeof(float));
			break;
		}
		case CuboidTexture::CUBOID_DRAW_TOP_INVERTED:
		{
			UpdateMeshBuffer(g_CuboidModel.get()->meshes[0], 1, topInvertedUVCoords, 6 * 2 * sizeof(float), i * 6 * 2 * sizeof(float));
			break;
		}
		case CuboidTexture::CUBOID_DONT_DRAW:
		{
			UpdateMeshBuffer(g_CuboidModel.get()->meshes[0], 1, dontdrawUVCoords, 6 * 2 * sizeof(float), i * 6 * 2 * sizeof(float));
			break;
		}
		}
	}
}

void ShapeData::Draw(const Vector3& pos, float angle, Color color, Vector3 scaling)
{
	if (m_isValid == false)
	{
		return;
	}

	ObjectData* objectData = &g_objectDataTable[m_shape];

	Vector3 cuboidScaling = m_Scaling;
	cuboidScaling.x = m_Scaling.x * scaling.x;
	cuboidScaling.y = m_Scaling.y * scaling.y;
	cuboidScaling.z = m_Scaling.z * scaling.z;

	Vector3 finalPos = Vector3Add(pos, m_TweakPos);

	switch (m_drawType)
	{
	case ShapeDrawType::OBJECT_DRAW_CUBOID:
	{
		Vector3 thisPos = pos;

		thisPos = Vector3Add(thisPos, m_TweakPos);
		thisPos = Vector3Add(thisPos, Vector3{ -m_Dims.x + 1, 0, -m_Dims.z + 1 });

		SetMaterialTexture(&g_CuboidModel.get()->materials[0], MATERIAL_MAP_DIFFUSE, m_cuboidTexture->m_Texture);
		UpdateTextureCoordinates();
		DrawModelEx(*g_CuboidModel.get(), thisPos, Vector3{ 0, 1, 0 }, angle, { m_Dims.x * m_Scaling.x, m_Dims.y * m_Scaling.y, m_Dims.z * m_Scaling.z }, color);

		break;
	}

	case ShapeDrawType::OBJECT_DRAW_FLAT:
	{
		finalPos = pos;
		if (pos.y == 0)
		{
			finalPos.y = .01f; //  Otherwise, z-fighting.
		}
		else
		{
			finalPos.y = pos.y * 1.01f;
		}

		finalPos = Vector3Add(finalPos, m_TweakPos);
		finalPos = Vector3Add(finalPos, Vector3{ -m_Dims.x + 1, 0, 1 });

		Vector3 flatScaling = Vector3{ m_Dims.x, 1, m_Dims.z };

		//BeginShaderMode(g_alphaDiscard);
		SetMaterialTexture(&m_flatModel->GetModel().materials[0], MATERIAL_MAP_DIFFUSE, m_texture->m_Texture);
		DrawModelEx(m_flatModel->GetModel(), finalPos, { 0, 1, 0 }, 0, flatScaling, color);
		//EndShaderMode();
		break;
	}

	case ShapeDrawType::OBJECT_DRAW_BILLBOARD:
	{
		finalPos = Vector3Add(pos, m_TweakPos);
		finalPos.x += .5f;
		finalPos.z += .5f;
		finalPos.y += m_Dims.y * .60f;

		BeginShaderMode(g_alphaDiscard);
		DrawBillboardPro(g_camera, m_texture->m_Texture, Rectangle{ 0, 0, float(m_texture->m_Texture.width), float(m_texture->m_Texture.height) }, finalPos, Vector3{ 0, 1, 0 },
			Vector2{ m_Dims.x, m_Dims.y }, Vector2{ 0, 0 }, -45, color);
		EndShaderMode();
		break;
	}

	case ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH:
	{
		m_customMesh->UpdateAnim("idle");

		if (m_meshOutline && !g_pixelated)
		{
			glClearStencil(0);
			glClear(GL_STENCIL_BUFFER_BIT);
			glEnable(GL_STENCIL_TEST);

			// Step 1: Draw the original model, mark stencil with 1
			glStencilFunc(GL_ALWAYS, 1, 0xFF);
			glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
			DrawModelEx(m_customMesh->GetModel(), finalPos, { 0, 1, 0 }, m_rotation, m_Scaling, color);

			// Step 2: Draw the outline where stencil is not 1
			glStencilFunc(GL_NOTEQUAL, 1, 0xFF);
			glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);

			// Get the bounding box to find the model's center
			BoundingBox boundingBox = GetModelBoundingBox(m_customMesh->GetModel());
			Vector3 size = Vector3{
				fabs(boundingBox.max.x - boundingBox.min.x),
				fabs(boundingBox.max.y - boundingBox.min.y),
				fabs(boundingBox.max.z - boundingBox.min.z) };
			// Calculate the local center of the model (unscaled)
			Vector3 localCenter = Vector3{
				(boundingBox.min.x + boundingBox.max.x) / 2.0f,
				(boundingBox.min.y + boundingBox.max.y) / 2.0f,
				(boundingBox.min.z + boundingBox.max.z) / 2.0f };

			// Fixed outline thickness in world space
			float outlineThickness = 0.075f;

			// Calculate the outline scale
			Vector3 outlineScale = Vector3{
				m_Scaling.x + (outlineThickness / size.x) * 2.0f,
				m_Scaling.y + (outlineThickness / size.y) * 2.0f,
				m_Scaling.z + (outlineThickness / size.z) * 2.0f };

			// Adjust position to compensate for the pivot offset when scaling
			Vector3 scaledCenter = Vector3{
				localCenter.x * m_Scaling.x,
				localCenter.y * m_Scaling.y,
				localCenter.z * m_Scaling.z };
			Vector3 outlineScaledCenter = Vector3{
				localCenter.x * outlineScale.x,
				localCenter.y * outlineScale.y,
				localCenter.z * outlineScale.z };
			Vector3 centerOffset = Vector3Subtract(scaledCenter, outlineScaledCenter);
			Vector3 outlinePos = Vector3Add(finalPos, centerOffset);

			// Draw the outline with the adjusted position
			glDepthMask(GL_FALSE);
			DrawModelEx(m_customMesh->GetModel(), outlinePos, { 0, 1, 0 }, m_rotation, outlineScale, BLACK);
			glDepthMask(GL_TRUE);

			glDisable(GL_STENCIL_TEST);
		}
		else
		{
			DrawModelEx(m_customMesh->GetModel(), finalPos, { 0, 1, 0 }, m_rotation, m_Scaling, color);
		}
		break;
	}

	default:
	{
		break;
	}
	}
}

void ShapeData::SetTextureForMeshFromSideData(CuboidSides side)
{
	switch (m_sideTextures[static_cast<int>(side)])
	{
	case CuboidTexture::CUBOID_INVALID:
	{
		return;
	}
	case CuboidTexture::CUBOID_DRAW_TOP:
	case CuboidTexture::CUBOID_DRAW_FRONT:
	case CuboidTexture::CUBOID_DRAW_RIGHT:
	case CuboidTexture::CUBOID_DRAW_TOP_INVERTED:
	case CuboidTexture::CUBOID_DRAW_FRONT_INVERTED:
	case CuboidTexture::CUBOID_DRAW_RIGHT_INVERTED:
	{
		SetMaterialTexture(&g_CuboidModel.get()->materials[0], MATERIAL_MAP_DIFFUSE, m_cuboidTexture->m_Texture);
		break;
	}
	}
}

void ShapeData::BuildCuboidMesh()
{
	if (g_CuboidModel != nullptr)
		return;

	Mesh mesh = { 0 };
	mesh.triangleCount = 12;
	mesh.vertexCount = mesh.triangleCount * 3;
	mesh.vertices = (float*)MemAlloc(mesh.vertexCount * 3 * sizeof(float));
	mesh.texcoords = (float*)MemAlloc(mesh.vertexCount * 2 * sizeof(float));
	mesh.normals = (float*)MemAlloc(mesh.vertexCount * 3 * sizeof(float));

	mesh.colors = (unsigned char*)MemAlloc(mesh.vertexCount * 4 * sizeof(unsigned char));
	mesh.animNormals = nullptr;
	mesh.animVertices = nullptr;
	mesh.boneIds = nullptr;
	mesh.boneWeights = nullptr;
	mesh.tangents = nullptr;
	mesh.indices = nullptr;
	mesh.texcoords2 = nullptr;
	//  Vertices

	//  Top
	int vertexCount = 0;
	mesh.vertices[vertexCount + 0] = 0; mesh.vertices[vertexCount + 1] = 1;	mesh.vertices[vertexCount + 2] = 0;
	mesh.vertices[vertexCount + 3] = 1; mesh.vertices[vertexCount + 4] = 1;	mesh.vertices[vertexCount + 5] = 0;
	mesh.vertices[vertexCount + 6] = 0; mesh.vertices[vertexCount + 7] = 1;	mesh.vertices[vertexCount + 8] = 1;
	mesh.vertices[vertexCount + 9] = 1; mesh.vertices[vertexCount + 10] = 1;	mesh.vertices[vertexCount + 11] = 1;
	mesh.vertices[vertexCount + 12] = 0; mesh.vertices[vertexCount + 13] = 1;	mesh.vertices[vertexCount + 14] = 1;
	mesh.vertices[vertexCount + 15] = 1; mesh.vertices[vertexCount + 16] = 1;	mesh.vertices[vertexCount + 17] = 0;

	//  Front
	vertexCount = 18;
	mesh.vertices[vertexCount + 0] = 0; mesh.vertices[vertexCount + 1] = 1;	mesh.vertices[vertexCount + 2] = 1;
	mesh.vertices[vertexCount + 3] = 1; mesh.vertices[vertexCount + 4] = 1;	mesh.vertices[vertexCount + 5] = 1;
	mesh.vertices[vertexCount + 6] = 0; mesh.vertices[vertexCount + 7] = 0;	mesh.vertices[vertexCount + 8] = 1;
	mesh.vertices[vertexCount + 9] = 1; mesh.vertices[vertexCount + 10] = 0;	mesh.vertices[vertexCount + 11] = 1;
	mesh.vertices[vertexCount + 12] = 0; mesh.vertices[vertexCount + 13] = 0;	mesh.vertices[vertexCount + 14] = 1;
	mesh.vertices[vertexCount + 15] = 1; mesh.vertices[vertexCount + 16] = 1;	mesh.vertices[vertexCount + 17] = 1;

	//  Right
	vertexCount = 36;
	mesh.vertices[vertexCount + 0] = 1; mesh.vertices[vertexCount + 1] = 1;	mesh.vertices[vertexCount + 2] = 1;
	mesh.vertices[vertexCount + 3] = 1; mesh.vertices[vertexCount + 4] = 1;	mesh.vertices[vertexCount + 5] = 0;
	mesh.vertices[vertexCount + 6] = 1; mesh.vertices[vertexCount + 7] = 0;	mesh.vertices[vertexCount + 8] = 1;
	mesh.vertices[vertexCount + 9] = 1; mesh.vertices[vertexCount + 10] = 0;	mesh.vertices[vertexCount + 11] = 0;
	mesh.vertices[vertexCount + 12] = 1; mesh.vertices[vertexCount + 13] = 0;	mesh.vertices[vertexCount + 14] = 1;
	mesh.vertices[vertexCount + 15] = 1; mesh.vertices[vertexCount + 16] = 1;	mesh.vertices[vertexCount + 17] = 0;

	//  Bottom
	vertexCount = 54;
	mesh.vertices[vertexCount + 0] = 0; mesh.vertices[vertexCount + 1] = 0;	mesh.vertices[vertexCount + 2] = 0;
	mesh.vertices[vertexCount + 3] = 1; mesh.vertices[vertexCount + 4] = 0;	mesh.vertices[vertexCount + 5] = 0;
	mesh.vertices[vertexCount + 6] = 0; mesh.vertices[vertexCount + 7] = 0;	mesh.vertices[vertexCount + 8] = 1;
	mesh.vertices[vertexCount + 9] = 1; mesh.vertices[vertexCount + 10] = 0;	mesh.vertices[vertexCount + 11] = 1;
	mesh.vertices[vertexCount + 12] = 0; mesh.vertices[vertexCount + 13] = 0;	mesh.vertices[vertexCount + 14] = 1;
	mesh.vertices[vertexCount + 15] = 1; mesh.vertices[vertexCount + 16] = 0;	mesh.vertices[vertexCount + 17] = 0;

	////  Back
	vertexCount = 72;
	mesh.vertices[vertexCount + 0] = 1; mesh.vertices[vertexCount + 1] = 1;	mesh.vertices[vertexCount + 2] = 0;
	mesh.vertices[vertexCount + 3] = 0; mesh.vertices[vertexCount + 4] = 1;	mesh.vertices[vertexCount + 5] = 0;
	mesh.vertices[vertexCount + 6] = 1; mesh.vertices[vertexCount + 7] = 0;	mesh.vertices[vertexCount + 8] = 0;
	mesh.vertices[vertexCount + 9] = 0; mesh.vertices[vertexCount + 10] = 0;	mesh.vertices[vertexCount + 11] = 0;
	mesh.vertices[vertexCount + 12] = 1; mesh.vertices[vertexCount + 13] = 0;	mesh.vertices[vertexCount + 14] = 0;
	mesh.vertices[vertexCount + 15] = 0; mesh.vertices[vertexCount + 16] = 1;	mesh.vertices[vertexCount + 17] = 0;

	//  Left
	vertexCount = 90;
	mesh.vertices[vertexCount + 0] = 0; mesh.vertices[vertexCount + 1] = 1;	mesh.vertices[vertexCount + 2] = 0;
	mesh.vertices[vertexCount + 3] = 0; mesh.vertices[vertexCount + 4] = 1;	mesh.vertices[vertexCount + 5] = 1;
	mesh.vertices[vertexCount + 6] = 0; mesh.vertices[vertexCount + 7] = 0;	mesh.vertices[vertexCount + 8] = 0;
	mesh.vertices[vertexCount + 9] = 0; mesh.vertices[vertexCount + 10] = 0;	mesh.vertices[vertexCount + 11] = 1;
	mesh.vertices[vertexCount + 12] = 0; mesh.vertices[vertexCount + 13] = 0;	mesh.vertices[vertexCount + 14] = 0;
	mesh.vertices[vertexCount + 15] = 0; mesh.vertices[vertexCount + 16] = 1;	mesh.vertices[vertexCount + 17] = 1;

	//  Normals
	for (int i = 0; i < 36; ++i)
	{
		int start = i * 3;
		mesh.normals[start] = 0;
		mesh.normals[start + 1] = 1;
		mesh.normals[start + 2] = 0;
	}

	//  Colors
	for (int i = 0; i < 6; ++i) // faces
	{
		for (int j = 0; j < 6; ++j) // verts
		{
			int start = ((i * 6) + j) * 4;
			mesh.colors[start] = WHITE.r;
			mesh.colors[start + 1] = WHITE.g;
			mesh.colors[start + 2] = WHITE.b;
			mesh.colors[start + 3] = WHITE.a;
			continue;

			switch (i)
			{
			case 0: // Top
			{
				int start = ((i * 6) + j) * 4;
				mesh.colors[start] = RED.r;
				mesh.colors[start + 1] = RED.g;
				mesh.colors[start + 2] = RED.b;
				mesh.colors[start + 3] = RED.a;
				break;
			}
			case 1: // Front
			{
				int start = ((i * 6) + j) * 4;
				mesh.colors[start] = GREEN.r;
				mesh.colors[start + 1] = GREEN.g;
				mesh.colors[start + 2] = GREEN.b;
				mesh.colors[start + 3] = GREEN.a;
				break;
			}

			case 2: // Right
			{
				int start = ((i * 6) + j) * 4;
				mesh.colors[start] = BLUE.r;
				mesh.colors[start + 1] = BLUE.g;
				mesh.colors[start + 2] = BLUE.b;
				mesh.colors[start + 3] = BLUE.a;
				break;
			}

			case 3: // Bottom
			{
				int start = ((i * 6) + j) * 4;
				mesh.colors[start] = YELLOW.r;
				mesh.colors[start + 1] = YELLOW.g;
				mesh.colors[start + 2] = YELLOW.b;
				mesh.colors[start + 3] = YELLOW.a;
				break;
			}

			case 4: // Back
			{
				int start = ((i * 6) + j) * 4;
				mesh.colors[start] = PURPLE.r;
				mesh.colors[start + 1] = PURPLE.g;
				mesh.colors[start + 2] = PURPLE.b;
				mesh.colors[start + 3] = PURPLE.a;
				break;
			}

			case 5: // Left
			{
				int start = ((i * 6) + j) * 4;
				mesh.colors[start] = ORANGE.r;
				mesh.colors[start + 1] = ORANGE.g;
				mesh.colors[start + 2] = ORANGE.b;
				mesh.colors[start + 3] = ORANGE.a;
				break;
			}

			}
		}
	}

	//  Texture Coords
	for (int i = 0; i < 6; ++i)
	{
		int start = i * 12;
		mesh.texcoords[start] = 0; mesh.texcoords[start + 1] = 0;
		mesh.texcoords[start + 2] = 1; mesh.texcoords[start + 3] = 0;
		mesh.texcoords[start + 4] = 0; mesh.texcoords[start + 5] = 1;
		mesh.texcoords[start + 6] = 1; mesh.texcoords[start + 7] = 1;
		mesh.texcoords[start + 8] = 0; mesh.texcoords[start + 9] = 1;
		mesh.texcoords[start + 10] = 1; mesh.texcoords[start + 11] = 0;
	}

	UploadMesh(&mesh, true);

	g_CuboidModel = make_unique<Model>(LoadModelFromMesh(mesh));

	//UploadMesh(&g_CuboidModel.get()->meshes[0], false);
}
