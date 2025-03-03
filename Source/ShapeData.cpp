#include <sstream>
#include <fstream>
#include <string>
#include <utility>
#include <algorithm>

#include "raylib.h"
#include "rlgl.h"

#include "external/glad.h"

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
}

void ShapeData::Init(int shape, int frame, bool shouldreset)
{
	m_shape = shape;
	m_frame = frame;

	if (m_originalTexture != nullptr)
	{
		m_shapePointerTexture = std::make_unique<ModTexture>();
		m_shapePointerTexture->AssignImage(g_shapeTable[m_pointerShape][m_pointerFrame].GetDefaultTextureImage());

		m_isValid = true;

		//  We need local copies of this texture for three sides of the cuboid.
		if (m_topTexture == nullptr)
		{
			m_topTexture = std::make_unique<ModTexture>(m_originalTexture->m_Image);
		}
		if (m_frontTexture == nullptr)
		{
			m_frontTexture = std::make_unique<ModTexture>(m_originalTexture->m_Image);
		}
		if (m_rightTexture == nullptr)
		{
			m_rightTexture = std::make_unique<ModTexture>(m_originalTexture->m_Image);
		}

		ObjectData* objectData = &g_objectTable[m_shape];

		if (shouldreset)
		{
			ResetTopTexture();
			ResetFrontTexture();
			ResetRightTexture();
		}

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
	else
	{
		m_isValid = false;
	}

	m_customMesh = g_ResourceManager->GetModel(m_customMeshName);
}

void ShapeData::SetDefaultTexture(Image image)
{
	if (m_originalTexture == nullptr)
	{
		m_originalTexture = std::make_unique<ModTexture>(image);
	}
	else
	{
		m_originalTexture->AssignImage(image);
	}

}

void ShapeData::CreateDefaultTexture()
{
	if (m_originalTexture == nullptr)
	{
		m_originalTexture = std::make_unique<ModTexture>();
	}
}

void ShapeData::SetupTextures()
{

}

void ShapeData::Serialize(ofstream& outStream)
{
	outStream << m_shape << " ";
	outStream << m_frame << " ";
	outStream << m_topTextureOffsetX << " ";
	outStream << m_topTextureOffsetY << " ";
	outStream << m_topTextureWidth << " ";
	outStream << m_topTextureHeight << " ";
	outStream << m_frontTextureOffsetX << " ";
	outStream << m_frontTextureOffsetY << " ";
	outStream << m_frontTextureWidth << " ";
	outStream << m_frontTextureHeight << " ";
	outStream << m_rightTextureOffsetX << " ";
	outStream << m_rightTextureOffsetY << " ";
	outStream << m_rightTextureWidth << " ";
	outStream << m_rightTextureHeight << " ";
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
	outStream << m_customMeshName << " ";
	outStream << m_meshOutline << " ";
	outStream << m_useShapePointer << " ";
	outStream << m_pointerShape << " ";
	outStream << m_pointerFrame << " ";
	outStream << endl;

	outStream.flush();
}

void ShapeData::Deserialize(ifstream& inStream)
{
	inStream >> m_shape;
	inStream >> m_frame;
	inStream >> m_topTextureOffsetX;
	inStream >> m_topTextureOffsetY;
	inStream >> m_topTextureWidth;
	inStream >> m_topTextureHeight;
	inStream >> m_frontTextureOffsetX;
	inStream >> m_frontTextureOffsetY;
	inStream >> m_frontTextureWidth;
	inStream >> m_frontTextureHeight;
	inStream >> m_rightTextureOffsetX;
	inStream >> m_rightTextureOffsetY;
	inStream >> m_rightTextureWidth;
	inStream >> m_rightTextureHeight;
	int drawType;
	inStream >> drawType;
	m_drawType = static_cast<ShapeDrawType>(drawType);
	inStream >> m_Scaling.x;
	inStream >> m_Scaling.y;
	inStream >> m_Scaling.z;
	inStream >> m_TweakPos.x;
	inStream >> m_TweakPos.y;
	inStream >> m_TweakPos.z;
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
	inStream >> m_meshOutline;

	inStream >>  m_useShapePointer;
	inStream >> m_pointerShape;
	inStream >> m_pointerFrame;

	Init(m_shape, m_frame, false);

}

void ShapeData::ResetTopTexture()
{
	ObjectData* objectData = &g_objectTable[m_shape];

	m_topTextureOffsetX = 0;
	m_topTextureOffsetY = 0;
	m_topTextureWidth = objectData->m_width * 8;
	m_topTextureHeight = objectData->m_depth * 8;

	SafeAndSane();
}

void ShapeData::ResetFrontTexture()
{
	ObjectData* objectData = &g_objectTable[m_shape];

	m_frontTextureOffsetX = 0;
	m_frontTextureOffsetY = objectData->m_depth * 8;
	m_frontTextureWidth = objectData->m_width * 8;
	m_frontTextureHeight = m_originalTexture->height - objectData->m_depth * 8;

	SafeAndSane();
}


void ShapeData::ResetRightTexture()
{
	ObjectData* objectData = &g_objectTable[m_shape];

	m_rightTextureOffsetX = objectData->m_width * 8;
	m_rightTextureOffsetY = 0;
	m_rightTextureWidth = m_originalTexture->width - objectData->m_width * 8;
	m_rightTextureHeight = objectData->m_depth * 8;

	SafeAndSane();
}


void ShapeData::SafeAndSane()
{
	if (m_topTextureWidth < 0) { m_topTextureWidth = 0; }
	if (m_topTextureHeight < 0) { m_topTextureHeight = 0; }
	if (m_frontTextureWidth < 0) { m_frontTextureWidth = 0; }
	if (m_frontTextureHeight < 0) { m_frontTextureHeight = 0; }
	if (m_rightTextureWidth < 0) { m_rightTextureWidth = 0; }
	if (m_rightTextureHeight < 0) { m_rightTextureHeight = 0; }

	if (m_topTextureOffsetX < 0) { m_topTextureOffsetX = 0; }
	if (m_topTextureOffsetY < 0) { m_topTextureOffsetY = 0; }
	if (m_frontTextureOffsetX < 0) { m_frontTextureOffsetX = 0; }
	if (m_frontTextureOffsetY < 0) { m_frontTextureOffsetY = 0; }
	if (m_rightTextureOffsetX < 0) { m_rightTextureOffsetX = 0; }
	if (m_rightTextureOffsetY < 0) { m_rightTextureOffsetY = 0; }

	ModTexture* textureToUse = m_originalTexture.get();
	if (m_useShapePointer)
	{
		textureToUse = m_shapePointerTexture.get();
	}

	if (m_topTextureWidth > textureToUse->width) { m_topTextureWidth = textureToUse->width; }
	if (m_topTextureHeight > textureToUse->height) { m_topTextureHeight = textureToUse->height; }
	if (m_frontTextureWidth > textureToUse->width) { m_frontTextureWidth = textureToUse->width; }
	if (m_frontTextureHeight > textureToUse->height) { m_frontTextureHeight = textureToUse->height; }
	if (m_rightTextureWidth > textureToUse->width) { m_rightTextureWidth = textureToUse->width; }
	if (m_rightTextureHeight > textureToUse->height) { m_rightTextureHeight = textureToUse->height; }

	if (m_topTextureOffsetX + m_topTextureWidth > textureToUse->width) { m_topTextureOffsetX = textureToUse->width; }
	if (m_topTextureOffsetY + m_topTextureHeight > textureToUse->height) { m_topTextureOffsetY = textureToUse->height; }
	if (m_frontTextureOffsetX + m_frontTextureWidth > textureToUse->width) { m_frontTextureOffsetX = textureToUse->width; }
	if (m_frontTextureOffsetY + m_frontTextureHeight > textureToUse->height) { m_frontTextureOffsetY = textureToUse->height; }
	if (m_rightTextureOffsetX + m_rightTextureWidth > textureToUse->width) { m_rightTextureOffsetX = textureToUse->width; }
	if (m_rightTextureOffsetY + m_rightTextureHeight > textureToUse->height) { m_rightTextureOffsetY = textureToUse->height; }


}

void ShapeData::SetupDrawTypes()
{
	ObjectData* objectData = &g_objectTable[m_shape];

	m_Dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };

	if (m_drawType == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
	{
		m_Dims = Vector3{ float(m_originalTexture->width) / 8.0f, float(m_originalTexture->height) / 8.0f, 1 };
	}
	else if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
	{
		m_Dims = Vector3{ float(m_originalTexture->width) / 8.0f, 0, float(m_originalTexture->height) / 8.0f };
	}
	else
	{
		m_Dims = Vector3{ objectData->m_width, objectData->m_height, objectData->m_depth };
	}

	FixupTextures();

	//  FLAT DRAWING

	Mesh flatMesh = GenMeshPlane(m_Dims.x, m_Dims.z, 1, 1);

	//  Move the mesh from the center to the corner
	for (int i = 0; i < flatMesh.vertexCount; ++i)
	{
		flatMesh.vertices[i * 3] -= ((m_Dims.x / 2) - 1);
		flatMesh.vertices[i * 3 + 2] -= ((m_Dims.z / 2) - 1);
	}

	UpdateMeshBuffer(flatMesh, 0, flatMesh.vertices, sizeof(float) * flatMesh.vertexCount * 3, 0);

	m_flatModel = LoadModelFromMesh(flatMesh);
	SetMaterialTexture(&m_flatModel.materials[0], MATERIAL_MAP_DIFFUSE, m_originalTexture->m_Texture);

	//  CUBOID DRAWING

	//  Very similar to flat drawing, we need to build six custom meshes to represent the sides.
	Mesh cuboidMesh = GenMeshCube(m_Dims.x, m_Dims.y, m_Dims.z);

	//  Move the mesh from the center to the corner
	for (int i = 0; i < cuboidMesh.vertexCount; ++i)
	{
		cuboidMesh.vertices[i * 3] -= ((m_Dims.x / 2) - 1);
		cuboidMesh.vertices[i * 3 + 1] += (m_Dims.y / 2);
		cuboidMesh.vertices[i * 3 + 2] -= ((m_Dims.z / 2) - 1);
	}

	UpdateMeshBuffer(cuboidMesh, 0, cuboidMesh.vertices, sizeof(float) * cuboidMesh.vertexCount * 3, 0);

	//  Now that we have made the cuboid mesh, split those vertices and UV coordinates into separate meshes for each side.

	float fixedX = -(m_Dims.x) + 1;
	float fixedY = m_Dims.y;
	float fixedZ = -(m_Dims.z) + 1;

	//  BOTTOM MESH
	Mesh bottomMesh = GenMeshPlane(m_Dims.x, m_Dims.z, 1, 1);

	bottomMesh.vertices[0] = fixedX;
	bottomMesh.vertices[1] = .01f;
	bottomMesh.vertices[2] = fixedZ;

	bottomMesh.vertices[3] = 1;
	bottomMesh.vertices[4] = .01f;
	bottomMesh.vertices[5] = fixedZ;

	bottomMesh.vertices[6] = fixedX;
	bottomMesh.vertices[7] = .01f;
	bottomMesh.vertices[8] = 1;

	bottomMesh.vertices[9] = 1;
	bottomMesh.vertices[10] = .01f;
	bottomMesh.vertices[11] = 1;

	m_faceCenterPoints[CuboidSides::CUBOID_BOTTOM] = Vector3{
		(bottomMesh.vertices[0] + bottomMesh.vertices[3] + bottomMesh.vertices[6] + bottomMesh.vertices[9]) / 4,
		(bottomMesh.vertices[1] + bottomMesh.vertices[4] + bottomMesh.vertices[7] + bottomMesh.vertices[10]) / 4,
		(bottomMesh.vertices[2] + bottomMesh.vertices[5] + bottomMesh.vertices[8] + bottomMesh.vertices[11]) / 4,
	};

	UpdateMeshBuffer(bottomMesh, 0, bottomMesh.vertices, sizeof(float) * bottomMesh.vertexCount * 3, 0);
	m_cuboidModels[static_cast<int>(CuboidSides::CUBOID_BOTTOM)] = LoadModelFromMesh(bottomMesh);
	SetTextureForMeshFromSideData(CuboidSides::CUBOID_BOTTOM);

	//  TOP MESH
	Mesh topMesh = GenMeshPlane(m_Dims.x, m_Dims.z, 1, 1);

	topMesh.vertices[0] = fixedX;
	topMesh.vertices[1] = fixedY;
	topMesh.vertices[2] = fixedZ;

	topMesh.vertices[3] = 1;
	topMesh.vertices[4] = fixedY;
	topMesh.vertices[5] = fixedZ;

	topMesh.vertices[6] = fixedX;
	topMesh.vertices[7] = fixedY;
	topMesh.vertices[8] = 1;

	topMesh.vertices[9] = 1;
	topMesh.vertices[10] = fixedY;
	topMesh.vertices[11] = 1;

	m_faceCenterPoints[CuboidSides::CUBOID_TOP] = Vector3{
	(topMesh.vertices[0] + topMesh.vertices[3] + topMesh.vertices[6] + topMesh.vertices[9]) / 4,
	(topMesh.vertices[1] + topMesh.vertices[4] + topMesh.vertices[7] + topMesh.vertices[10]) / 4,
	(topMesh.vertices[2] + topMesh.vertices[5] + topMesh.vertices[8] + topMesh.vertices[11]) / 4,
	};

	UpdateMeshBuffer(topMesh, 0, topMesh.vertices, sizeof(float) * topMesh.vertexCount * 3, 0);
	m_cuboidModels[static_cast<int>(CuboidSides::CUBOID_TOP)] = LoadModelFromMesh(topMesh);
	SetTextureForMeshFromSideData(CuboidSides::CUBOID_TOP);

	//  LEFT MESH
	Mesh leftMesh = GenMeshPlane(m_Dims.x, m_Dims.z, 1, 1);

	leftMesh.vertices[0] = fixedX;
	leftMesh.vertices[1] = fixedY;
	leftMesh.vertices[2] = 1;

	leftMesh.vertices[3] = fixedX;
	leftMesh.vertices[4] = 0.01f;
	leftMesh.vertices[5] = 1;

	leftMesh.vertices[6] = fixedX;
	leftMesh.vertices[7] = fixedY;
	leftMesh.vertices[8] = fixedZ;

	leftMesh.vertices[9] = fixedX;
	leftMesh.vertices[10] = 0.01f;
	leftMesh.vertices[11] = fixedZ;

	m_faceCenterPoints[CuboidSides::CUBOID_LEFT] = Vector3{
	(leftMesh.vertices[0] + leftMesh.vertices[3] + leftMesh.vertices[6] + leftMesh.vertices[9]) / 4,
	(leftMesh.vertices[1] + leftMesh.vertices[4] + leftMesh.vertices[7] + leftMesh.vertices[10]) / 4,
	(leftMesh.vertices[2] + leftMesh.vertices[5] + leftMesh.vertices[8] + leftMesh.vertices[11]) / 4,
	};

	UpdateMeshBuffer(leftMesh, 0, leftMesh.vertices, sizeof(float) * leftMesh.vertexCount * 3, 0);
	m_cuboidModels[static_cast<int>(CuboidSides::CUBOID_LEFT)] = LoadModelFromMesh(leftMesh);
	SetTextureForMeshFromSideData(CuboidSides::CUBOID_LEFT);

	//  RIGHT MESH
	Mesh rightMesh = GenMeshPlane(m_Dims.x, m_Dims.z, 1, 1);

	rightMesh.vertices[0] = 1;
	rightMesh.vertices[1] = fixedY;
	rightMesh.vertices[2] = fixedZ;

	rightMesh.vertices[3] = 1;
	rightMesh.vertices[4] = 0.01f;
	rightMesh.vertices[5] = fixedZ;

	rightMesh.vertices[6] = 1;
	rightMesh.vertices[7] = fixedY;
	rightMesh.vertices[8] = 1;

	rightMesh.vertices[9] = 1;
	rightMesh.vertices[10] = 0.01f;
	rightMesh.vertices[11] = 1;

	m_faceCenterPoints[CuboidSides::CUBOID_RIGHT] = Vector3{
	(rightMesh.vertices[0] + rightMesh.vertices[3] + rightMesh.vertices[6] + rightMesh.vertices[9]) / 4,
	(rightMesh.vertices[1] + rightMesh.vertices[4] + rightMesh.vertices[7] + rightMesh.vertices[10]) / 4,
	(rightMesh.vertices[2] + rightMesh.vertices[5] + rightMesh.vertices[8] + rightMesh.vertices[11]) / 4,
	};

	UpdateMeshBuffer(rightMesh, 0, rightMesh.vertices, sizeof(float) * rightMesh.vertexCount * 3, 0);
	m_cuboidModels[static_cast<int>(CuboidSides::CUBOID_RIGHT)] = LoadModelFromMesh(rightMesh);
	SetTextureForMeshFromSideData(CuboidSides::CUBOID_RIGHT);

	//  FRONT MESH
	Mesh frontMesh = GenMeshPlane(m_Dims.x, m_Dims.z, 1, 1);

	frontMesh.vertices[0] = fixedX;
	frontMesh.vertices[1] = fixedY;
	frontMesh.vertices[2] = 1;

	frontMesh.vertices[3] = 1;
	frontMesh.vertices[4] = fixedY;
	frontMesh.vertices[5] = 1;

	frontMesh.vertices[6] = fixedX;
	frontMesh.vertices[7] = 0.01f;
	frontMesh.vertices[8] = 1;

	frontMesh.vertices[9] = 1;
	frontMesh.vertices[10] = 0.01f;
	frontMesh.vertices[11] = 1;

	m_faceCenterPoints[CuboidSides::CUBOID_FRONT] = Vector3{
	(frontMesh.vertices[0] + frontMesh.vertices[3] + frontMesh.vertices[6] + frontMesh.vertices[9]) / 4,
	(frontMesh.vertices[1] + frontMesh.vertices[4] + frontMesh.vertices[7] + frontMesh.vertices[10]) / 4,
	(frontMesh.vertices[2] + frontMesh.vertices[5] + frontMesh.vertices[8] + frontMesh.vertices[11]) / 4,
	};

	UpdateMeshBuffer(frontMesh, 0, frontMesh.vertices, sizeof(float) * frontMesh.vertexCount * 3, 0);
	m_cuboidModels[static_cast<int>(CuboidSides::CUBOID_FRONT)] = LoadModelFromMesh(frontMesh);
	SetTextureForMeshFromSideData(CuboidSides::CUBOID_FRONT);

	//  BACK MESH
	Mesh backMesh = GenMeshPlane(m_Dims.x, m_Dims.z, 1, 1);

	backMesh.vertices[0] = 1;
	backMesh.vertices[1] = fixedY;
	backMesh.vertices[2] = fixedZ;

	backMesh.vertices[3] = fixedX;
	backMesh.vertices[4] = fixedY;
	backMesh.vertices[5] = fixedZ;

	backMesh.vertices[6] = 1;
	backMesh.vertices[7] = 0.01f;
	backMesh.vertices[8] = fixedZ;

	backMesh.vertices[9] = fixedX;
	backMesh.vertices[10] = 0.01f;
	backMesh.vertices[11] = fixedZ;

	m_faceCenterPoints[CuboidSides::CUBOID_BACK] = Vector3{
	(backMesh.vertices[0] + backMesh.vertices[3] + backMesh.vertices[6] + backMesh.vertices[9]) / 4,
	(backMesh.vertices[1] + backMesh.vertices[4] + backMesh.vertices[7] + backMesh.vertices[10]) / 4,
	(backMesh.vertices[2] + backMesh.vertices[5] + backMesh.vertices[8] + backMesh.vertices[11]) / 4,
	};

	UpdateMeshBuffer(backMesh, 0, backMesh.vertices, sizeof(float) * backMesh.vertexCount * 3, 0);
	m_cuboidModels[static_cast<int>(CuboidSides::CUBOID_BACK)] = LoadModelFromMesh(backMesh);
	SetTextureForMeshFromSideData(CuboidSides::CUBOID_BACK);

	//  CUSTOM MESH
	m_customMesh = g_ResourceManager->GetModel(m_customMeshName);

};

void ShapeData::FixupTextures()
{
	//  Fixup the texture for this object.

	ObjectData* objectData = &g_objectTable[m_shape];

	UpdateShapePointerTexture();

	//  Reset all textures
	m_topTexture->Reset();
	m_frontTexture->Reset();
	m_rightTexture->Reset();

	ModTexture* textureToUse = m_originalTexture.get();
	if (m_useShapePointer)
	{
		textureToUse = m_shapePointerTexture.get();
	}

	//  Top face
	m_topTexture->m_Image = ImageFromImage(textureToUse->m_Image, Rectangle{ float(m_topTextureOffsetX), float(m_topTextureOffsetY), float(m_topTextureWidth), float(m_topTextureHeight) });
	m_topTexture->UpdateTexture();

	//  Front face
	m_frontTexture->m_Image = ImageFromImage(textureToUse->m_Image, Rectangle{ float(m_frontTextureOffsetX), float(m_frontTextureOffsetY),
		float(textureToUse->m_Image.width - m_frontTextureOffsetX), float(textureToUse->m_Image.height - m_frontTextureOffsetY) });

	//  Shift slanted pixels to unslant
	int counter = 1;
	for (int i = 0; i < m_frontTexture->m_Image.height; ++i)
	{
		for (int k = 0; k < counter; ++k)
		{
			m_frontTexture->MoveImageRowLeft(i);
		}
		++counter;
	}

	m_frontTexture->ResizeImage(m_frontTextureWidth, m_frontTextureHeight);
	m_frontTexture->UpdateTexture();

	//  Right face
	m_rightTexture->m_Image = ImageFromImage(textureToUse->m_Image, Rectangle{ float(m_rightTextureOffsetX), float(m_rightTextureOffsetY),
		float(textureToUse->m_Image.width - m_rightTextureOffsetX), float(textureToUse->m_Image.height - m_rightTextureOffsetY) });

	//  Shift slanted pixels to unslant
	counter = 1;
	for (int i = 1; i < m_rightTextureWidth; ++i)
	{
		for (int k = 0; k < counter; ++k)
		{
			m_rightTexture->MoveImageColumnUp(i);
		}
		++counter;
	}

	m_rightTexture->ResizeImage(m_rightTextureWidth, m_rightTextureHeight);
	m_rightTexture->UpdateTexture();
}

void ShapeData::Draw(const Vector3& pos, float angle, Color color, Vector3 scaling)
{
	if (m_isValid == false)
	{
		return;
	}

	ObjectData* objectData = &g_objectTable[m_shape];

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

		float leftDistance = Vector3Distance(g_camera.position, Vector3Add(m_faceCenterPoints[CuboidSides::CUBOID_LEFT], pos));
		float rightDistance = Vector3Distance(g_camera.position, Vector3Add(m_faceCenterPoints[CuboidSides::CUBOID_RIGHT], pos));
		float topDistance = Vector3Distance(g_camera.position, Vector3Add(m_faceCenterPoints[CuboidSides::CUBOID_TOP], pos));
		float bottomDistance = Vector3Distance(g_camera.position, Vector3Add(m_faceCenterPoints[CuboidSides::CUBOID_BOTTOM], pos));
		float frontDistance = Vector3Distance(g_camera.position, Vector3Add(m_faceCenterPoints[CuboidSides::CUBOID_FRONT], pos));
		float backDistance = Vector3Distance(g_camera.position, Vector3Add(m_faceCenterPoints[CuboidSides::CUBOID_BACK], pos));

		vector<pair<CuboidSides, float>> distances = {
		make_pair(CuboidSides::CUBOID_LEFT, leftDistance), make_pair(CuboidSides::CUBOID_RIGHT, rightDistance),
			make_pair(CuboidSides::CUBOID_TOP, topDistance), make_pair(CuboidSides::CUBOID_BOTTOM, bottomDistance),
			make_pair(CuboidSides::CUBOID_FRONT, frontDistance), make_pair(CuboidSides::CUBOID_BACK, backDistance) };

		sort(distances.begin(), distances.end(), [](const pair<CuboidSides, float>& a, const pair<CuboidSides, float>& b) { return a.second > b.second; });

		for (int i = 0; i < distances.size(); ++i)
		{
			if (m_sideTextures[static_cast<int>(distances[i].first)] != CuboidTexture::CUBOID_DONT_DRAW)
			{
				DrawModelEx(m_cuboidModels[static_cast<int>(distances[i].first)], finalPos, Vector3{ 0, 1, 0 }, angle, cuboidScaling, WHITE);
			}
		}

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

		//BeginShaderMode(g_alphaDiscard);
		DrawModel(m_flatModel, finalPos, 1, WHITE);
		//EndShaderMode();
		break;
	}

	case ShapeDrawType::OBJECT_DRAW_BILLBOARD:
	{
		finalPos = pos;
		finalPos.x += .5f;
		finalPos.z += .5f;
		finalPos.y += m_Dims.y * .60f;

		BeginShaderMode(g_alphaDiscard);
		DrawBillboardPro(g_camera, m_originalTexture->m_Texture, Rectangle{ 0, 0, float(m_originalTexture->m_Texture.width), float(m_originalTexture->m_Texture.height) }, finalPos, Vector3{ 0, 1, 0 },
			Vector2{ m_Dims.x, m_Dims.y }, Vector2{ 0, 0 }, -45, color);
		EndShaderMode();
		break;
	}

	case ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH:
	{
		if (m_meshOutline)
		{
			glClearStencil(0);
			glClear(GL_STENCIL_BUFFER_BIT);
			glEnable(GL_STENCIL_TEST);
			glStencilFunc(GL_ALWAYS, 1, -1);
			glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);

			DrawModelEx(*m_customMesh, finalPos, { 0, 1, 0 }, m_rotation, m_Scaling, WHITE);

			glStencilFunc(GL_NOTEQUAL, 1, -1);
			glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
			if (g_pixelated)
			{
				glLineWidth(.1f);
			}
			else
			{
				glLineWidth(2.5f * g_DrawScale);
			}
			glEnable(GL_LINE_SMOOTH);
			glPolygonMode(GL_FRONT, GL_LINE);

			DrawModelEx(*m_customMesh, finalPos, { 0, 1, 0 }, m_rotation, m_Scaling, BLACK);

			glPolygonMode(GL_FRONT, GL_FILL);
			glDisable(GL_STENCIL_TEST);
		}
		else
		{
			DrawModelEx(*m_customMesh, finalPos, { 0, 1, 0 }, m_rotation, m_Scaling, WHITE);
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
	{
		SetMaterialTexture(&m_cuboidModels[static_cast<int>(side)].materials[0], MATERIAL_MAP_DIFFUSE, m_topTexture->m_Texture);
		break;
	}
	case CuboidTexture::CUBOID_DRAW_FRONT:
	{
		SetMaterialTexture(&m_cuboidModels[static_cast<int>(side)].materials[0], MATERIAL_MAP_DIFFUSE, m_frontTexture->m_Texture);
		break;
	}
	case CuboidTexture::CUBOID_DRAW_RIGHT:
	{
		SetMaterialTexture(&m_cuboidModels[static_cast<int>(side)].materials[0], MATERIAL_MAP_DIFFUSE, m_rightTexture->m_Texture);
		break;
	}
	case CuboidTexture::CUBOID_DRAW_TOP_INVERTED:
	{
		Image image = m_topTexture->m_Image;
		ImageFlipHorizontal(&image);
		SetMaterialTexture(&m_cuboidModels[static_cast<int>(side)].materials[0], MATERIAL_MAP_DIFFUSE, LoadTextureFromImage(image));
		break;
	}
	case CuboidTexture::CUBOID_DRAW_FRONT_INVERTED:
	{
		Image image = m_frontTexture->m_Image;
		ImageFlipHorizontal(&image);
		SetMaterialTexture(&m_cuboidModels[static_cast<int>(side)].materials[0], MATERIAL_MAP_DIFFUSE, LoadTextureFromImage(image));
		break;
	}
	case CuboidTexture::CUBOID_DRAW_RIGHT_INVERTED:
	{
		Image image = m_rightTexture->m_Image;
		ImageFlipVertical(&image);
		SetMaterialTexture(&m_cuboidModels[static_cast<int>(side)].materials[0], MATERIAL_MAP_DIFFUSE, LoadTextureFromImage(image));
		break;
	}
	}
}

void ShapeData::UpdateAllCuboidTextures()
{
	for (int i = 0; i < 6; ++i)
	{
		SetTextureForMeshFromSideData(static_cast<CuboidSides>(i));
	}
}

void ShapeData::UpdateShapePointerTexture()
{
	if (m_shapePointerTexture == nullptr)
	{
		m_shapePointerTexture = std::make_unique<ModTexture>();
	}

	m_shapePointerTexture->AssignImage(g_shapeTable[m_pointerShape][m_pointerFrame].GetDefaultTextureImage());
}