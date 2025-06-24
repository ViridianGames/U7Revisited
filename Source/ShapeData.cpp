#include <sstream>
#include <fstream>
#include <string>
#include <utility>
#include <algorithm>

#include "raylib.h"
#include "rlgl.h"

#include "include/glad.h"

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

	m_Scaling = Vector3{1, 1, 1};
	m_TweakPos = Vector3{0, 0, 0};
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

	if (m_texture != nullptr)
	{
		Image image = GenImageColor(m_texture->m_Image.width * 2, m_texture->m_Image.height * 2, Color{ 0, 255, 0, 255 });

		//ImageDraw(&image, m_texture->m_Image, m_topTextureRect,
		//	Rectangle{ 0, 0, m_topTextureRect.width, m_topTextureRect.height }, WHITE);

		//ImageDraw(&image, m_texture->m_Image, Rectangle{ 0, 0, float(m_texture->m_Image.width), float(m_texture->m_Image.height) },
		//	Rectangle{ float(m_texture->m_Image.width), 0, float(m_texture->m_Image.width), float(m_texture->m_Image.height) }, WHITE);

		//ImageDraw(&image, m_texture->m_Image, Rectangle{ 0, 0, float(m_texture->m_Image.width), float(m_texture->m_Image.height) },
		//	Rectangle{ 0, float(m_texture->m_Image.height), float(m_texture->m_Image.width), float(m_texture->m_Image.height) }, WHITE);

		m_cuboidTexture = std::make_unique<ModTexture>(image);

		//m_shapePointerTexture = std::make_unique<ModTexture>();
		//m_shapePointerTexture->AssignImage(g_shapeTable[m_pointerShape][m_pointerFrame].GetDefaultTextureImage());

		m_isValid = true;

		//  We need local copies of this texture for three sides of the cuboid.
		//if (m_topTexture == nullptr)
		//{
		//	m_topTexture = std::make_unique<ModTexture>(m_texture->m_Image);
		//}
		//if (m_frontTexture == nullptr)
		//{
		//	m_frontTexture = std::make_unique<ModTexture>(m_texture->m_Image);
		//}
		//if (m_rightTexture == nullptr)
		//{
		//	m_rightTexture = std::make_unique<ModTexture>(m_texture->m_Image);
		//}

		ObjectData *objectData = &g_objectTable[m_shape];

		//if (shouldreset)
		//{
		//	ResetTopTexture();
		//	ResetFrontTexture();
		//	ResetRightTexture();
		//}

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

void ShapeData::Serialize(ofstream &outStream)
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
	outStream << m_customMeshName << " ";
	outStream << m_meshOutline << " ";
	outStream << m_useShapePointer << " ";
	outStream << m_pointerShape << " ";
	outStream << m_pointerFrame << " ";
	outStream << m_luaScript << " ";
	outStream << endl;

	outStream.flush();
}

void ShapeData::Deserialize(ifstream &inStream)
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

	inStream >> m_useShapePointer;
	inStream >> m_pointerShape;
	inStream >> m_pointerFrame;

	inStream >> m_luaScript;

	Init(m_shape, m_frame, false);
}

void ShapeData::ResetTopTextureRect()
{
	ObjectData *objectData = &g_objectTable[m_shape];

	m_topTextureRect.x = 0;
	m_topTextureRect.y = 0;
	m_topTextureRect.width = objectData->m_width * 8;
	m_topTextureRect.height = objectData->m_depth * 8;

	SafeAndSane();
}

void ShapeData::ResetFrontTextureRect()
{
	ObjectData *objectData = &g_objectTable[m_shape];

	m_frontTextureRect.x = 0;
	m_frontTextureRect.y = objectData->m_depth * 8;
	m_frontTextureRect.width = objectData->m_width * 8;
	m_frontTextureRect.height = m_texture->height - objectData->m_depth * 8;
	
	SafeAndSane();
}

void ShapeData::ResetRightTextureRect()
{
	ObjectData *objectData = &g_objectTable[m_shape];

	m_rightTextureRect.x = objectData->m_width * 8;
	m_rightTextureRect.y = 0;
	m_rightTextureRect.width = m_texture->width - objectData->m_width * 8;
	m_rightTextureRect.height = objectData->m_depth * 8;

	SafeAndSane();
}

void ShapeData::SafeAndSane()
{


	ModTexture *textureToUse = m_texture.get();

	if (m_topTextureRect.width > textureToUse->width)	{ m_topTextureRect.width = textureToUse->width; }
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


	if(m_topTextureRect.x + m_topTextureRect.width > textureToUse->width)
	{
		m_topTextureRect.x = textureToUse->width - m_topTextureRect.width;
	}

	if(m_topTextureRect.y + m_topTextureRect.height > textureToUse->height)
	{
		m_topTextureRect.y = textureToUse->height - m_topTextureRect.y;
	}

	if(m_frontTextureRect.x + m_frontTextureRect.width > textureToUse->width)
	{
		m_frontTextureRect.x = textureToUse->width - m_frontTextureRect.width;
	}

	if(m_frontTextureRect.y + m_frontTextureRect.height > textureToUse->height)
	{
		m_frontTextureRect.y = textureToUse->height - m_frontTextureRect.height;
	}

	if(m_rightTextureRect.x + m_rightTextureRect.width > textureToUse->width)
	{
		m_rightTextureRect.x = textureToUse->width - m_rightTextureRect.width;
	}

	if(m_rightTextureRect.y + m_rightTextureRect.height > textureToUse->height)
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
	ObjectData *objectData = &g_objectTable[m_shape];

	m_Dims = Vector3{objectData->m_width, objectData->m_height, objectData->m_depth};

	if (m_drawType == ShapeDrawType::OBJECT_DRAW_BILLBOARD || m_drawType == ShapeDrawType::OBJECT_DRAW_CHARACTER)
	{
		m_Dims = Vector3{float(m_texture->width) / 8.0f, float(m_texture->height) / 8.0f, 1};
	}
	else if (m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
	{
		m_Dims = Vector3{float(m_texture->width) / 8.0f, 0, float(m_texture->height) / 8.0f};
	}
	else
	{
		m_Dims = Vector3{objectData->m_width, objectData->m_height, objectData->m_depth};
	}

	//  FLAT DRAWING
	m_flatModel = g_ResourceManager->GetModel("Models/3dmodels/flat.obj");

	//  CUBOID DRAWING

	m_cuboidModel = g_ResourceManager->GetModel("Models/3dmodels/cuboidmodel.obj");

	//  CUSTOM MESH
	m_customMesh = g_ResourceManager->GetModel(m_customMeshName);

	UpdateTextures();
};

void ShapeData::UpdateTextures()
{
	//  Fixup the texture for this object.
	ObjectData *objectData = &g_objectTable[m_shape];

	SafeAndSane();

	ModTexture *textureToUse = m_texture.get();

	int startx = 0;
	int starty = 0;

	ImageClearBackground(&m_cuboidTexture->m_Image, {255, 0, 0, 255});
	
	ImageDraw(&m_cuboidTexture->m_Image, m_texture->m_Image, m_topTextureRect,
		{ 0, 0, m_topTextureRect.width, m_topTextureRect.height }, WHITE);

	ImageDraw(&m_cuboidTexture->m_Image, m_texture->m_Image, m_rightTextureRect,
		Rectangle{ m_topTextureRect.width, 0, m_rightTextureRect.width, m_rightTextureRect.height }, WHITE);

	ImageDraw(&m_cuboidTexture->m_Image, m_texture->m_Image, m_frontTextureRect,
		Rectangle{ 0, m_topTextureRect.height, m_frontTextureRect.width, m_frontTextureRect.height }, WHITE);

	m_cuboidTexture->UpdateTexture();

	//  Top face


	//  Front face
	//m_frontTexture->m_Image = ImageFromImage(textureToUse->m_Image, Rectangle{float(m_frontTextureOffsetX), float(m_frontTextureOffsetY),
	//																		  float(textureToUse->m_Image.width - m_frontTextureOffsetX), float(textureToUse->m_Image.height - m_frontTextureOffsetY)});

	//  Shift slanted pixels to unslant
	//int counter = 1;
	//for (int i = 0; i < m_frontTexture->m_Image.height; ++i)
	//{
	//	for (int k = 0; k < counter; ++k)
	//	{
	//		m_frontTexture->MoveImageRowLeft(i);
	//	}
	//	++counter;
	//}

	//m_frontTexture->ResizeImage(m_frontTextureWidth, m_frontTextureHeight);
	//m_frontTexture->UpdateTexture();

	////  Right face
	//m_rightTexture->m_Image = ImageFromImage(textureToUse->m_Image, Rectangle{float(m_rightTextureOffsetX), float(m_rightTextureOffsetY),
	//																		  float(textureToUse->m_Image.width - m_rightTextureOffsetX), float(textureToUse->m_Image.height - m_rightTextureOffsetY)});

	////  Shift slanted pixels to unslant
	//counter = 1;
	//for (int i = 1; i < m_rightTextureWidth; ++i)
	//{
	//	for (int k = 0; k < counter; ++k)
	//	{
	//		m_rightTexture->MoveImageColumnUp(i);
	//	}
	//	++counter;
	//}

	//m_rightTexture->ResizeImage(m_rightTextureWidth, m_rightTextureHeight);
	//m_rightTexture->UpdateTexture();
}

void ShapeData::Draw(const Vector3 &pos, float angle, Color color, Vector3 scaling)
{
	if (m_isValid == false)
	{
		return;
	}

	ObjectData *objectData = &g_objectTable[m_shape];

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
		thisPos = Vector3Add(thisPos, Vector3{ -m_Dims.x + 1, 0, 1 });

		SetMaterialTexture(&m_cuboidModel->GetModel().materials[0], MATERIAL_MAP_DIFFUSE, m_cuboidTexture->m_Texture);
		DrawModelEx(m_cuboidModel->GetModel(), thisPos, Vector3{0, 1, 0}, angle, m_Dims, WHITE);

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

		Vector3 flatScaling = Vector3{ m_Dims.x, m_Dims.y, m_Dims.z };

		// BeginShaderMode(g_alphaDiscard);
		SetMaterialTexture(&m_flatModel->GetModel().materials[0], MATERIAL_MAP_DIFFUSE, m_texture->m_Texture);
		DrawModelEx(m_flatModel->GetModel(), finalPos, { 0, 1, 0 }, 0, flatScaling, WHITE);
		// EndShaderMode();
		break;
	}

	case ShapeDrawType::OBJECT_DRAW_BILLBOARD:
	{
		finalPos = pos;
		finalPos.x += .5f;
		finalPos.z += .5f;
		finalPos.y += m_Dims.y * .60f;

		BeginShaderMode(g_alphaDiscard);
		DrawBillboardPro(g_camera, m_texture->m_Texture, Rectangle{0, 0, float(m_texture->m_Texture.width), float(m_texture->m_Texture.height)}, finalPos, Vector3{0, 1, 0},
						 Vector2{m_Dims.x, m_Dims.y}, Vector2{0, 0}, -45, color);
		EndShaderMode();
		break;
	}

	case ShapeDrawType::OBJECT_DRAW_CHARACTER:
	{
		finalPos = pos;
		finalPos.x += .5f;
		finalPos.z += .5f;
		finalPos.y += m_Dims.y * .85f;

		//g_cameraRotation

		Texture* finalTexture = &g_shapeTable[m_shape][17].m_texture->m_Texture;
		float finalRotation = -45;

		int thisTime = GetTime() * 1000;

		int framerate = 250;

		thisTime = thisTime % (4 * framerate);

		if (thisTime > framerate && thisTime < 2 * framerate)
		{
			finalTexture = &g_shapeTable[m_shape][16].m_texture->m_Texture;
		}
		else if (thisTime >= 2 * framerate && thisTime < 3 * framerate)
		{
			finalTexture = &g_shapeTable[m_shape][18].m_texture->m_Texture;
		}
		else if (thisTime > 3 * framerate)
		{
			finalTexture = &g_shapeTable[m_shape][16].m_texture->m_Texture;
		}


		//if (g_cameraRotation > PI / 2)
		//{
		//	finalTexture = &g_shapeTable[m_shape][1].m_texture->m_Texture;
		//}
		//if (g_cameraRotation > PI )
		//{
		//	finalTexture = &g_shapeTable[m_shape][0].m_texture->m_Texture;
		//	Image image = ImageFromImage(g_shapeTable[m_shape][0].m_texture->m_Image, {0, 0, float(g_shapeTable[m_shape][0].m_texture->m_Image.width), float(g_shapeTable[m_shape][0].m_texture->m_Image.height) });
		//	ImageFlipHorizontal(&image);

		//	finalTexture = &LoadTextureFromImage(image);
		//	finalRotation = 45;
		//	
		//}
		//if (g_cameraRotation > PI * 1.5f)
		//{
		//	finalTexture = &g_shapeTable[m_shape][3].m_texture->m_Texture;
		//}



		Vector3 dims = Vector3{ float(finalTexture->width) / 8.0f, float(finalTexture->height) / 8.0f, 1 };

		BeginShaderMode(g_alphaDiscard);
		DrawBillboardPro(g_camera, *finalTexture, Rectangle{ 0, 0, float(finalTexture->width), float(finalTexture->height) }, finalPos, Vector3{ 0, 1, 0 },
			Vector2{ dims.x, dims.y }, Vector2{ 0, 0 }, finalRotation, color);
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
			DrawModelEx(m_customMesh->GetModel(), finalPos, {0, 1, 0}, m_rotation, m_Scaling, WHITE);

			// Step 2: Draw the outline where stencil is not 1
			glStencilFunc(GL_NOTEQUAL, 1, 0xFF);
			glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);

			// Get the bounding box to find the model's center
			BoundingBox boundingBox = GetModelBoundingBox(m_customMesh->GetModel());
			Vector3 size = Vector3{
				fabs(boundingBox.max.x - boundingBox.min.x),
				fabs(boundingBox.max.y - boundingBox.min.y),
				fabs(boundingBox.max.z - boundingBox.min.z)};
			// Calculate the local center of the model (unscaled)
			Vector3 localCenter = Vector3{
				(boundingBox.min.x + boundingBox.max.x) / 2.0f,
				(boundingBox.min.y + boundingBox.max.y) / 2.0f,
				(boundingBox.min.z + boundingBox.max.z) / 2.0f};

			// Fixed outline thickness in world space
			float outlineThickness = 0.075f;

			// Calculate the outline scale
			Vector3 outlineScale = Vector3{
				m_Scaling.x + (outlineThickness / size.x) * 2.0f,
				m_Scaling.y + (outlineThickness / size.y) * 2.0f,
				m_Scaling.z + (outlineThickness / size.z) * 2.0f};

			// Adjust position to compensate for the pivot offset when scaling
			Vector3 scaledCenter = Vector3{
				localCenter.x * m_Scaling.x,
				localCenter.y * m_Scaling.y,
				localCenter.z * m_Scaling.z};
			Vector3 outlineScaledCenter = Vector3{
				localCenter.x * outlineScale.x,
				localCenter.y * outlineScale.y,
				localCenter.z * outlineScale.z};
			Vector3 centerOffset = Vector3Subtract(scaledCenter, outlineScaledCenter);
			Vector3 outlinePos = Vector3Add(finalPos, centerOffset);

			// Draw the outline with the adjusted position
			glDepthMask(GL_FALSE);
			DrawModelEx(m_customMesh->GetModel(), outlinePos, {0, 1, 0}, m_rotation, outlineScale, BLACK);
			glDepthMask(GL_TRUE);

			glDisable(GL_STENCIL_TEST);
		}
		else
		{
			DrawModelEx(m_customMesh->GetModel(), finalPos, {0, 1, 0}, m_rotation, m_Scaling, WHITE);
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
		SetMaterialTexture(&m_cuboidModel->GetModel().materials[0], MATERIAL_MAP_DIFFUSE, m_cuboidTexture->m_Texture);
		break;
	}
	}
}

//void ShapeData::UpdateShapePointerTexture()
//{
//	if (m_shapePointerTexture == nullptr)
//	{
//		m_shapePointerTexture = std::make_unique<ModTexture>();
//	}
//
//	m_shapePointerTexture->AssignImage(g_shapeTable[m_pointerShape][m_pointerFrame].GetDefaultTextureImage());
//}