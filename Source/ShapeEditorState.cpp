#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/StateMachine.h"
#include "Geist/ResourceManager.h"
#include "Geist/ScriptingSystem.h"
#include "U7Globals.h"
#include "ShapeEditorState.h"
#include "rlgl.h"

#include <list>
#include <string>
#include <sstream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <algorithm>
#include <unordered_map>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  ShapeEditorState
////////////////////////////////////////////////////////////////////////////////

ShapeEditorState::~ShapeEditorState()
{
	Shutdown();
}

void ShapeEditorState::Init(const string& configfile)
{
	m_sideDrawStrings[0] = "Hidden";
	m_sideDrawStrings[1] = "Top";
	m_sideDrawStrings[2] = "Front";
	m_sideDrawStrings[3] = "Right";
	m_sideDrawStrings[4] = "Top Inv";
	m_sideDrawStrings[5] = "Front Inv";
	m_sideDrawStrings[6] = "Right Inv";

	m_sideStrings[0] = "Top";
	m_sideStrings[1] = "Front";
	m_sideStrings[2] = "Right";
	m_sideStrings[3] = "Bottom";
	m_sideStrings[4] = "Back";
	m_sideStrings[5] = "Left";

	m_currentShape = 150;
	m_currentFrame = 0;
	m_rotating = false;

	m_objectLibrary.resize(1024);
	for (int i = 0; i < 1024; ++i)
	{
		m_objectLibrary[i].resize(32);
	}

	SetupBboardGui();
	SetupFlatGui();
	SetupCuboidGui();
	SetupMeshGui();
	SetupCharacterGui();
	SetupShapePointerGui();
	SetupDontDrawGui();

	ChangeGui(m_bboardGui.get());
}

void ShapeEditorState::ChangeGui(Gui* newGui)
{
	m_bboardGui->m_ActiveElement = -1;
	m_bboardGui->m_Active = false;
	m_flatGui->m_ActiveElement = -1;
	m_flatGui->m_Active = false;
	m_cuboidGui->m_ActiveElement = -1;
	m_cuboidGui->m_Active = false;
	m_meshGui->m_ActiveElement = -1;
	m_meshGui->m_Active = false;
	m_characterGui->m_ActiveElement = -1;
	m_characterGui->m_Active = false;
	m_shapePointerGui->m_ActiveElement = -1;
	m_shapePointerGui->m_Active = false;
	m_dontDrawGui->m_ActiveElement = -1;
	m_dontDrawGui->m_Active = false;

	newGui->m_Active = true;

	m_currentGui = newGui;
}

void ShapeEditorState::SwitchToGuiForDrawType(ShapeDrawType drawType)
{
	switch (drawType)
	{
	case ShapeDrawType::OBJECT_DRAW_BILLBOARD:
		ChangeGui(m_bboardGui.get());
		break;
	case ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH:
		ChangeGui(m_meshGui.get());
		break;
	case ShapeDrawType::OBJECT_DRAW_CUBOID:
		ChangeGui(m_cuboidGui.get());
		break;
	case ShapeDrawType::OBJECT_DRAW_FLAT:
		ChangeGui(m_flatGui.get());
		break;
	case ShapeDrawType::OBJECT_DRAW_DONT_DRAW:
		ChangeGui(m_dontDrawGui.get());
		break;
	}
}

void ShapeEditorState::OnEnter()
{
	ClearConsole();

	m_currentFrame = g_selectedFrame;
	m_currentShape = g_selectedShape;

	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	for (auto node = g_ResourceManager->m_ModelList.begin(); node != g_ResourceManager->m_ModelList.end(); ++node)
	{
		if (node->first == shapeData.m_customMeshName)
		{
			m_modelIndex = node;
			break;
		}
	}

	m_luaScriptIndex = 0;
	for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
	{
		if (g_ScriptingSystem->m_scriptFiles[i].first == g_shapeTable[m_currentShape][m_currentFrame].m_luaScript)
		{
			m_luaScriptIndex = i;
			break;
		}
	}

	SwitchToGuiForDrawType(shapeData.m_drawType);
}

void ShapeEditorState::OnExit()
{
	g_selectedShape = m_currentShape;
	g_selectedFrame = m_currentFrame;
}

void ShapeEditorState::Shutdown()
{

}

void ShapeEditorState::Update()
{
	//  Handle input
	m_currentGui->Update();
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	unsigned int time = GetTime();
	g_CameraMoved = false;

	float speed = 50;

	if (GetKeyPressed() == 0)
	{
		int stopper = 0;
	}
	if (IsKeyDown(KEY_Q))
	{
		g_CameraRotateSpeed += GetFrameTime() * 50;
		if (g_CameraRotateSpeed > 8)
		{
			g_CameraRotateSpeed = 8;
		}
		g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_E))
	{
		g_CameraRotateSpeed -= GetFrameTime() * 50;
		if (g_CameraRotateSpeed < -8)
		{
			g_CameraRotateSpeed = -8;
		}
		g_CameraMoved = true;
	}

	if (!g_CameraMoved)
	{
		g_CameraRotateSpeed *= .9;
		if (g_CameraRotateSpeed < 1 && g_CameraRotateSpeed > -1)
		{
			g_CameraRotateSpeed = 0;
		}
	}


	if (g_CameraRotateSpeed != 0)
	{
		//SetCameraAngle(GetCameraAngle() + g_CameraRotateSpeed);
		//SetCameraChanged(true);
		g_CameraMoved = true;
	}


	if (IsKeyPressed(KEY_A) || m_currentGui->GetActiveElementID() == GE_PREVSHAPEBUTTON)
	{
		int newShape = m_currentShape - 1;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			newShape -= 9;
		}

		if (IsKeyDown(KEY_LEFT_CONTROL))
		{
			newShape -= 99;
		}

		if (newShape < 150)
		{
			newShape = 1023;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			m_currentShape = newShape;
			m_currentFrame = 0;
			SwitchToGuiForDrawType(g_shapeTable[m_currentShape][m_currentFrame].m_drawType);
		}
		else
		{
			m_currentShape = newShape - 1;
		}
	}

	if (IsKeyPressed(KEY_D) || m_currentGui->GetActiveElementID() == GE_NEXTSHAPEBUTTON)
	{
		int newShape = m_currentShape + 1;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			newShape += 9;
		}

		if (IsKeyDown(KEY_LEFT_CONTROL))
		{
			newShape += 99;
		}

		if (newShape > 1023)
		{
			newShape = 150;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			m_currentShape = newShape;
			SwitchToGuiForDrawType(g_shapeTable[m_currentShape][m_currentFrame].m_drawType);
		}
		else
		{
			m_currentShape = newShape + 1;
		}

		m_currentFrame = 0;

		m_luaScriptIndex = 0;
		for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
		{
			if (g_ScriptingSystem->m_scriptFiles[i].first == g_shapeTable[m_currentShape][m_currentFrame].m_luaScript)
			{
				m_luaScriptIndex = i;
				break;
			}
		}
	}

	if (IsKeyPressed(KEY_W) || m_currentGui->GetActiveElementID() == GE_NEXTFRAMEBUTTON)
	{
		// Find next valid frame, wrapping around
		const int maxFrameIndex = g_shapeTable[m_currentShape].size() - 1;
		int newFrame = m_currentFrame + 1;
		for (int i = 0; i < g_shapeTable[m_currentShape].size(); ++i)
		{
			if (newFrame > maxFrameIndex)
				newFrame = 0;

			if (g_shapeTable[m_currentShape][newFrame].IsValid())
			{
				m_currentFrame = newFrame;
				break;
			}
			newFrame++;
		}
	}

	if (IsKeyPressed(KEY_S) || m_currentGui->GetActiveElementID() == GE_PREVFRAMEBUTTON)
	{
		// Find previous valid frame, wrapping around
		const int maxFrameIndex = g_shapeTable[m_currentShape].size() - 1;
		int newFrame = m_currentFrame - 1;
		for (int i = 0; i < g_shapeTable[m_currentShape].size(); ++i)
		{
			if (newFrame < 0)
				newFrame = maxFrameIndex;

			if (g_shapeTable[m_currentShape][newFrame].IsValid())
			{
				m_currentFrame = newFrame;
				break;
			}
			newFrame--;
		}
	}

	if (IsKeyDown(KEY_Q))
	{
		g_cameraRotation += GetFrameTime() * 5;
		g_CameraMoved = true;
	}

	if (IsKeyDown(KEY_E))
	{
		g_cameraRotation -= GetFrameTime() * 5;
		g_CameraMoved = true;
	}

	if (IsKeyPressed(KEY_F1) || IsKeyPressed(KEY_ESCAPE))
	{
		g_mainState->m_gameMode = MainStateModes::MAIN_STATE_MODE_SANDBOX;
		g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
	}

	if (IsKeyPressed(KEY_F2))
	{
		g_shapeTable[m_currentShape][m_currentFrame].UpdateTextures();
	}

	//  Handle GUI Input
	if (m_currentGui->GetActiveElementID() == GE_SAVEBUTTON)
	{
		ofstream file("Data/shapetable.dat", ios::trunc);
		if (file.is_open())
		{
			for (int i = 150; i < 1024; ++i)
			{
				for (int j = 0; j < 32; ++j)
				{
					ShapeData& shapeData = g_shapeTable[i][j];
					shapeData.Serialize(file);
				}
			}
			file.close();
			AddConsoleString("Saved shapetable.dat successfully!", GREEN);
		}
		else
		{
			AddConsoleString("ERROR: Failed to save shapetable.dat!", RED);
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_LOADBUTTON)
	{
		ifstream file("Data/shapetable.dat");
		if (file.is_open())
		{
			for (int i = 150; i < 1024; ++i)
			{
				for (int j = 0; j < 32; ++j)
				{
					ShapeData& shapeData = g_shapeTable[i][j];
					shapeData.Deserialize(file);
				}
			}
			file.close();
		}
	}

	bool somethingChanged = false;

	if (m_currentGui->GetActiveElementID() == GE_PREVDRAWTYPE)
	{
		shapeData.m_drawType = static_cast<ShapeDrawType>(static_cast<int>(shapeData.m_drawType) - 1);
		if (shapeData.m_drawType < ShapeDrawType::OBJECT_DRAW_BILLBOARD)
		{
			shapeData.m_drawType = ShapeDrawType(int(ShapeDrawType::OBJECT_DRAW_LAST) - 1);
		}
		SwitchToGuiForDrawType(shapeData.m_drawType);
	}

	else if (m_currentGui->GetActiveElementID() == GE_NEXTDRAWTYPE)
	{
		shapeData.m_drawType = static_cast<ShapeDrawType>(static_cast<int>(shapeData.m_drawType) + 1);
		if (shapeData.m_drawType == ShapeDrawType::OBJECT_DRAW_LAST)
		{
			shapeData.m_drawType = ShapeDrawType::OBJECT_DRAW_BILLBOARD;
		}
		SwitchToGuiForDrawType(shapeData.m_drawType);
	}

	if (m_currentGui->GetActiveElementID() == GE_COPYPARAMSFROMFRAME0)
	{
		if (m_currentFrame != 0)
		{
			ShapeData& frame0Data = g_shapeTable[m_currentShape][0];
			shapeData.m_rotation = frame0Data.m_rotation;
			shapeData.m_Scaling = frame0Data.m_Scaling;
			shapeData.m_TweakPos = frame0Data.m_TweakPos;
			shapeData.m_topTextureRect.x = frame0Data.m_topTextureRect.x;
			shapeData.m_topTextureRect.y = frame0Data.m_topTextureRect.y;
			shapeData.m_topTextureRect.width = frame0Data.m_topTextureRect.width;
			shapeData.m_topTextureRect.height = frame0Data.m_topTextureRect.height;
			shapeData.m_frontTextureRect.x = frame0Data.m_frontTextureRect.x;
			shapeData.m_frontTextureRect.y = frame0Data.m_frontTextureRect.y;
			shapeData.m_frontTextureRect.width = frame0Data.m_frontTextureRect.width;
			shapeData.m_frontTextureRect.height = frame0Data.m_frontTextureRect.height;
			shapeData.m_rightTextureRect.x = frame0Data.m_rightTextureRect.x;
			shapeData.m_rightTextureRect.y = frame0Data.m_rightTextureRect.y;
			shapeData.m_rightTextureRect.width = frame0Data.m_rightTextureRect.width;
			shapeData.m_rightTextureRect.height = frame0Data.m_rightTextureRect.height;

			shapeData.m_sideTextures[int(CuboidSides::CUBOID_TOP)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_TOP)];
			shapeData.m_sideTextures[int(CuboidSides::CUBOID_FRONT)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_FRONT)];
			shapeData.m_sideTextures[int(CuboidSides::CUBOID_RIGHT)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_RIGHT)];
			shapeData.m_sideTextures[int(CuboidSides::CUBOID_BOTTOM)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_BOTTOM)];
			shapeData.m_sideTextures[int(CuboidSides::CUBOID_BACK)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_BACK)];
			shapeData.m_sideTextures[int(CuboidSides::CUBOID_LEFT)] = frame0Data.m_sideTextures[int(CuboidSides::CUBOID_LEFT)];

			somethingChanged = true;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_JUMPTOINSTANCE)
	{
		for (unordered_map<int, unique_ptr<U7Object>>::iterator node = g_objectList.begin(); node != g_objectList.end(); ++node)
		{
			if((*node).second->m_shapeData->m_shape == m_currentShape && (*node).second->m_shapeData->m_frame == m_currentFrame && !(*node).second->m_isContained)
			{
				g_camera.target = (*node).second->m_Pos;
				g_camera.position = Vector3Add(g_camera.target, Vector3{ 0, g_cameraDistance, g_cameraDistance });
				g_CameraMoved = true;
				break;
			}
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TOPXMINUSBUTTON)
	{
		if (shapeData.m_topTextureRect.x + shapeData.m_topTextureRect.width - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureRect.x--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPXPLUSBUTTON)
	{
		if (shapeData.m_topTextureRect.x + shapeData.m_topTextureRect.width < shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_topTextureRect.x++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPYMINUSBUTTON)
	{
		if (shapeData.m_topTextureRect.y + shapeData.m_topTextureRect.height >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureRect.y--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPYPLUSBUTTON)
	{
		if (shapeData.m_topTextureRect.y + shapeData.m_topTextureRect.height < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_topTextureRect.y++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPWIDTHMINUSBUTTON)
	{
		if (shapeData.m_topTextureRect.x + shapeData.m_topTextureRect.width >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureRect.width--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPWIDTHPLUSBUTTON)
	{
		if (shapeData.m_topTextureRect.x + shapeData.m_topTextureRect.width <= shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_topTextureRect.width++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPHEIGHTMINUSBUTTON)
	{
		if (shapeData.m_topTextureRect.y + shapeData.m_topTextureRect.height >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureRect.height--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPHEIGHTPLUSBUTTON)
	{
		if (shapeData.m_topTextureRect.y + shapeData.m_topTextureRect.height < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_topTextureRect.height++;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_FRONTXMINUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.x + shapeData.m_frontTextureRect.width - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.x--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTXPLUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.x + shapeData.m_frontTextureRect.width + 1 < shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.x++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTYMINUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.y + shapeData.m_frontTextureRect.height - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.y--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTYPLUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.y + shapeData.m_frontTextureRect.height < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.y++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTWIDTHMINUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.x + shapeData.m_frontTextureRect.width >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.width--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTWIDTHPLUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.x + shapeData.m_frontTextureRect.width < shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.width++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTHEIGHTMINUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.y + shapeData.m_frontTextureRect.height >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.height--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTHEIGHTPLUSBUTTON)
	{
		if (shapeData.m_frontTextureRect.y + shapeData.m_frontTextureRect.height < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_frontTextureRect.height++;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_RIGHTXMINUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.x + shapeData.m_rightTextureRect.width - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.x--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTXPLUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.x + shapeData.m_rightTextureRect.width + 1 < shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.x++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTYMINUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.y + shapeData.m_rightTextureRect.height - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.y--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTYPLUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.y + shapeData.m_rightTextureRect.height + 1 < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.y++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTWIDTHMINUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.x + shapeData.m_rightTextureRect.width - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.width--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTWIDTHPLUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.x + shapeData.m_rightTextureRect.width < shapeData.m_texture->width)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.width++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTHEIGHTMINUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.y + shapeData.m_rightTextureRect.height - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.height--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTHEIGHTPLUSBUTTON)
	{
		if (shapeData.m_rightTextureRect.y + shapeData.m_rightTextureRect.height + 1 < shapeData.m_texture->height)
		{
			somethingChanged = true; shapeData.m_rightTextureRect.height++;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TOPRESET) { somethingChanged = true; shapeData.ResetTopTextureRect(); }
	if (m_currentGui->GetActiveElementID() == GE_FRONTRESET) { somethingChanged = true; shapeData.ResetFrontTextureRect(); }
	if (m_currentGui->GetActiveElementID() == GE_RIGHTRESET) { somethingChanged = true; shapeData.ResetRightTextureRect(); }

	if (m_currentGui->GetActiveElementID() == GE_PREVTOPBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_TOP, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTTOPBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_TOP, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVFRONTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_FRONT, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTFRONTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_FRONT, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVRIGHTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_RIGHT, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTRIGHTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_RIGHT, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVBOTTOMBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_BOTTOM, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTBOTTOMBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_BOTTOM, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVBACKBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_BACK, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTBACKBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_BACK, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVLEFTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT));
		sideTexture--;
		if (sideTexture < 0)
		{
			sideTexture = 0;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_LEFT, static_cast<CuboidTexture>(sideTexture));
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTLEFTBUTTON)
	{
		somethingChanged = true;
		int sideTexture = static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT));
		sideTexture++;
		if (sideTexture > 6)
		{
			sideTexture = 6;
		}
		shapeData.SetTextureForSide(CuboidSides::CUBOID_LEFT, static_cast<CuboidTexture>(sideTexture));
	}


	//  Tweak dimensions

	if (m_currentGui->GetActiveElementID() == GE_TWEAKWIDTHPLUSBUTTON)
	{
		somethingChanged = true;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.x -= .5f;
		}
		else
		{
			shapeData.m_Scaling.x -= .05f;
		}
	
		if(shapeData.m_Scaling.x < -9.9f) shapeData.m_Scaling.x = -9.9f;

		if(abs(shapeData.m_Scaling.x) < 0.01f)
		{
			shapeData.m_Scaling.x = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKWIDTHMINUSBUTTON)
	{
		somethingChanged = true;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.x += .5f;
		}
		else
		{
			shapeData.m_Scaling.x += .05f;
		}

		if (shapeData.m_Scaling.x > 9.9) shapeData.m_Scaling.x = 9.9;

		if (abs(shapeData.m_Scaling.x) < 0.01f)
		{
			shapeData.m_Scaling.x = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKHEIGHTMINUSBUTTON)
	{
		somethingChanged = true;
		if(IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.y += .5f;
		}
		else
		{
			shapeData.m_Scaling.y += .05f;
		}
		if (shapeData.m_Scaling.y > 9.9) shapeData.m_Scaling.y = 9.9;

		if (abs(shapeData.m_Scaling.y) < 0.01f)
		{
			shapeData.m_Scaling.y = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKHEIGHTPLUSBUTTON)
	{
		somethingChanged = true;
		if(IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.y -= .5f;
		}
		else
		{
			shapeData.m_Scaling.y -= .05f;
		}
		if (shapeData.m_Scaling.y < -9.9f) shapeData.m_Scaling.y = 9.9f;

		if (abs(shapeData.m_Scaling.y) < 0.01f)
		{
			shapeData.m_Scaling.y = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKDEPTHMINUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.z += .5f;
		}
		else
		{
			shapeData.m_Scaling.z += .05f;
		}
		if (shapeData.m_Scaling.z < 0) shapeData.m_Scaling.z = 0;

		if (abs(shapeData.m_Scaling.z) < 0.01f)
		{
			shapeData.m_Scaling.z = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKDEPTHPLUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_Scaling.z -= .5f;
		}
		else
		{
			shapeData.m_Scaling.z -= .05f;
		}
		if (shapeData.m_Scaling.z < -9.9) shapeData.m_Scaling.z = -9.9;

		if (abs(shapeData.m_Scaling.z) < 0.01f)
		{
			shapeData.m_Scaling.z = 0;
		}
	}

	//  Tweak Position
		if (m_currentGui->GetActiveElementID() == GE_TWEAKXPLUSBUTTON)
	{
		somethingChanged = true;
		if(IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.x -= .5f;
		}
		else
		{
			shapeData.m_TweakPos.x -= .05f;
		}
		if(shapeData.m_TweakPos.x < -9.9) shapeData.m_TweakPos.x = -9.9;

		if (abs(shapeData.m_TweakPos.x) < 0.01f)
		{
			shapeData.m_TweakPos.x = 0;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKXMINUSBUTTON)
	{
		somethingChanged = true;
		if(IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.x += .5f;
		}
		else
		{
			shapeData.m_TweakPos.x += .05f;
		}
		if (shapeData.m_TweakPos.x > 9.9) shapeData.m_TweakPos.x = 9.9;

		if (abs(shapeData.m_TweakPos.x) < 0.01f)
		{
			shapeData.m_TweakPos.x = 0;
		}

	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKYMINUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.y += .5f;
		}
		else
		{
			shapeData.m_TweakPos.y += .05f;
		}
		if (shapeData.m_TweakPos.y > 9.9) shapeData.m_TweakPos.y = 9.9;

		if (abs(shapeData.m_TweakPos.y) < 0.01f)
		{
			shapeData.m_TweakPos.y = 0;
		}

	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKYPLUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.y -= .5f;
		}
		else
		{
			shapeData.m_TweakPos.y -= .05f;
		}
		if (shapeData.m_TweakPos.y < -9.9) shapeData.m_TweakPos.y = -9.9;

		if (abs(shapeData.m_TweakPos.y) < 0.01f)
		{
			shapeData.m_TweakPos.y = 0;
		}

	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKZMINUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.z += .5f;
		}
		else
		{
			shapeData.m_TweakPos.z += .05f;
		}
		if (shapeData.m_TweakPos.z > 9.9) shapeData.m_TweakPos.z = 9.9;

		if (abs(shapeData.m_TweakPos.z) < 0.01f)
		{
			shapeData.m_TweakPos.z = 0;
		}

	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKZPLUSBUTTON)
	{
		somethingChanged = true;
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			shapeData.m_TweakPos.z -= .5f;
		}
		else
		{
			shapeData.m_TweakPos.z -= .05f;
		}
		if (shapeData.m_TweakPos.z < -9.9) shapeData.m_TweakPos.z = -9.9;

		if (abs(shapeData.m_TweakPos.z) < 0.01f)
		{
			shapeData.m_TweakPos.z = 0;
		}

	}

	if (m_currentGui->GetActiveElementID() == GE_MESHOUTLINECHECKBOX)
	{
		somethingChanged = true;
		shapeData.m_meshOutline = m_currentGui->GetActiveElement()->m_Selected;
	}

	if (m_currentGui->GetActiveElementID() == GE_USESHAPEPOINTERCHECKBOX)
	{
		somethingChanged = true;
		shapeData.m_useShapePointer = m_currentGui->GetActiveElement()->m_Selected;

		shapeData.UpdateTextures();
		shapeData.SafeAndSane();
	}

	// Tweak Rotation
	if (m_currentGui->GetActiveElementID() == GE_TWEAKROTATIONPLUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_rotation += 1.0f;
		if (shapeData.m_rotation > 360) shapeData.m_rotation = 0;
		if (shapeData.m_rotation < 0) shapeData.m_rotation = 360;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKROTATIONMINUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_rotation -= 1.0f;
		if (shapeData.m_rotation > 360) shapeData.m_rotation = 0;
		if (shapeData.m_rotation < 0) shapeData.m_rotation = 360;
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTMODELBUTTON)
	{
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			for(int i = 0; i < 10; ++i)
			{
				m_modelIndex++;
				if (m_modelIndex == g_ResourceManager->m_ModelList.end())
				{
					m_modelIndex = g_ResourceManager->m_ModelList.begin();
				}
			}
		}
		else
		{
			m_modelIndex++;
			if (m_modelIndex == g_ResourceManager->m_ModelList.end())
			{
				m_modelIndex = g_ResourceManager->m_ModelList.begin();
			}
		}

		g_shapeTable[m_currentShape][m_currentFrame].m_customMesh = (*m_modelIndex).second.get();
		g_shapeTable[m_currentShape][m_currentFrame].m_customMeshName = (*m_modelIndex).first;
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVMODELBUTTON)
	{
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			for(int i = 0; i < 10; ++i)
			{
				if (m_modelIndex == g_ResourceManager->m_ModelList.begin())
				{
					m_modelIndex = g_ResourceManager->m_ModelList.end();
				}
				m_modelIndex--;
			}
		}
		else
		{
			if (m_modelIndex == g_ResourceManager->m_ModelList.begin())
			{
				m_modelIndex = g_ResourceManager->m_ModelList.end();
			}
			m_modelIndex--;
		}

		g_shapeTable[m_currentShape][m_currentFrame].m_customMeshName = (*m_modelIndex).first;
		g_shapeTable[m_currentShape][m_currentFrame].m_customMesh = (*m_modelIndex).second.get();
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTLUASCRIPTBUTTON)
	{
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			for(int i = 0; i < 10; ++i)
			{
				m_luaScriptIndex++;
				if (m_luaScriptIndex > g_ScriptingSystem->m_scriptFiles.size())
				{
					m_luaScriptIndex = 0;
				}
			}
		}
		else
		{
			m_luaScriptIndex++;
			if (m_luaScriptIndex > g_ScriptingSystem->m_scriptFiles.size())
			{
				m_luaScriptIndex = 0;
			}
		}

		g_shapeTable[m_currentShape][m_currentFrame].m_luaScript = (g_ScriptingSystem->m_scriptFiles[m_luaScriptIndex].first);
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVLUASCRIPTBUTTON)
	{
		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			for(int i = 0; i < 10; ++i)
			{
				m_luaScriptIndex--;
				if (m_luaScriptIndex < 0)
				{
					m_luaScriptIndex = g_ScriptingSystem->m_scriptFiles.size();
				}
			}
		}
		else
		{
			m_luaScriptIndex--;
			if (m_luaScriptIndex < 0)
			{
				m_luaScriptIndex = g_ScriptingSystem->m_scriptFiles.size();
			}
		}

		g_shapeTable[m_currentShape][m_currentFrame].m_luaScript = (g_ScriptingSystem->m_scriptFiles[m_luaScriptIndex].first);
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVSHAPEPOINTERBUTTON)
	{
		int pointerShape = shapeData.m_pointerShape;
		int newShape = pointerShape - 1;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			newShape -= 9;
		}

		if (newShape < 0)
		{
			newShape = 1023;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			shapeData.m_pointerShape = newShape;
			if (shapeData.m_useShapePointer)
			{
				somethingChanged = true;
			}
		}
		else
		{
			shapeData.m_pointerShape = 0;
		}

		shapeData.m_pointerFrame = 0;
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTSHAPEPOINTERBUTTON)
	{
		int pointerShape = shapeData.m_pointerShape;
		int newShape = pointerShape + 1;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			newShape += 9;
		}

		if (newShape > 1023)
		{
			newShape = 150;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			shapeData.m_pointerShape = newShape;
			if (shapeData.m_useShapePointer)
			{
				somethingChanged = true;
			}
		}
		else
		{
			shapeData.m_pointerShape = 0;
		}

		shapeData.m_pointerFrame = 0;
	}

	if (m_currentGui->GetActiveElementID() == GE_NEXTFRAMEPOINTERBUTTON)
	{
		int newFrame = shapeData.m_pointerFrame + 1;
		if (newFrame > 31)
		{
			newFrame = 0;
		}

		if (g_shapeTable[shapeData.m_pointerShape][newFrame].IsValid())
		{
			shapeData.m_pointerFrame = newFrame;
			if (shapeData.m_useShapePointer)
			{
				somethingChanged = true;
			}
		}
	}

	if (IsKeyPressed(KEY_S) || m_currentGui->GetActiveElementID() == GE_PREVFRAMEPOINTERBUTTON)
	{
		int newFrame = shapeData.m_pointerFrame - 1;
		if (newFrame < 0)
		{
			newFrame = 31;
		}

		if (g_shapeTable[m_currentShape][newFrame].IsValid())
		{
			shapeData.m_pointerFrame = newFrame;
			if (shapeData.m_useShapePointer)
			{
				somethingChanged = true;
			}
		}
	}

	if(m_currentGui->GetActiveElementID() == GE_OPENLUASCRIPTBUTTON)
	{
		std::string filePath = g_ScriptingSystem->m_scriptFiles[m_luaScriptIndex].second;

		// Open the file with the default system application
		#ifdef _WIN32
			system(("start \"\" \"" + std::string(filePath) + "\"").c_str());
		#elif __APPLE__
			system(("open \"" + std::string(filePath) + "\"").c_str());
		#else // Linux and others
			system(("xdg-open \"" + std::string(filePath) + "\"").c_str());
		#endif
	}

	if(m_currentGui->GetActiveElementID() == GE_SETLUASCRIPTTOSHAPEIDBUTTON)
	{
		stringstream ss;
		ss << std::uppercase << std::hex << m_currentShape;
		std::string funcName = "func_0" + ss.str();

		int newScriptIndex = 0;
		for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
		{
			if (g_ScriptingSystem->m_scriptFiles[i].first == funcName)
			{
				newScriptIndex = i;
				break;
			}
		}

		// If exact match not found, search for any script ending with _xxxx
		if (newScriptIndex == 0)
		{
			std::string suffix = "_" + ss.str();
			for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
			{
				const std::string& scriptName = g_ScriptingSystem->m_scriptFiles[i].first;
				if (scriptName.length() >= suffix.length() &&
					scriptName.compare(scriptName.length() - suffix.length(), suffix.length(), suffix) == 0)
				{
					newScriptIndex = i;
					AddConsoleString("Using script: " + scriptName);
					break;
				}
			}
		}

		if(newScriptIndex != 0)
		{
			m_luaScriptIndex = newScriptIndex;
			g_shapeTable[m_currentShape][m_currentFrame].m_luaScript = (g_ScriptingSystem->m_scriptFiles[m_luaScriptIndex].first);
		}
		else
		{
			AddConsoleString("No script found for shape ID: " + std::to_string(m_currentShape));
		}
	}

	if (somethingChanged)
	{
		shapeData.SafeAndSane();
		shapeData.UpdateTextures();
		shapeData.UpdateTextureCoordinates();
	}

	if (g_CameraMoved)
	{
		Vector3 camPos = { g_cameraDistance, g_cameraDistance, g_cameraDistance };
		camPos = Vector3RotateByAxisAngle(camPos, Vector3{ 0, 1, 0 }, g_cameraRotation);

		g_camera.position = Vector3Add(g_camera.target, camPos);
		g_camera.fovy = g_cameraDistance;
	}	

	//  Update GUI Textareas
	std::stringstream ss;
    ss << std::uppercase << std::hex << m_currentShape;
	m_currentGui->GetElement(GE_CURRENTSHAPEIDTEXTAREA)->m_String = "S:" + to_string(m_currentShape) + " (" + ss.str() + ")";

	// Find max valid frame for this shape
	int maxFrame = 0;
	const int maxFrameIndex = g_shapeTable[m_currentShape].size() - 1;
	for (int i = maxFrameIndex; i >= 0; --i)
	{
		if (g_shapeTable[m_currentShape][i].IsValid())
		{
			maxFrame = i;
			break;
		}
	}
	m_currentGui->GetElement(GE_CURRENTFRAMEIDTEXTAREA)->m_String = "F:" + to_string(m_currentFrame) + "/" + to_string(maxFrame);
	
	if (m_currentGui == m_cuboidGui.get())
	{

		m_currentGui->GetElement(GE_TOPXTEXTAREA)->m_String = "X:" + to_string(int(shapeData.m_topTextureRect.x));
		m_currentGui->GetElement(GE_FRONTXTEXTAREA)->m_String = "X:" + to_string(int(shapeData.m_frontTextureRect.x));
		m_currentGui->GetElement(GE_RIGHTXTEXTAREA)->m_String = "X:" + to_string(int(shapeData.m_rightTextureRect.x));

		m_currentGui->GetElement(GE_TOPYTEXTAREA)->m_String = "Y:" + to_string(int(shapeData.m_topTextureRect.y));
		m_currentGui->GetElement(GE_FRONTYTEXTAREA)->m_String = "Y:" + to_string(int(shapeData.m_frontTextureRect.y));
		m_currentGui->GetElement(GE_RIGHTYTEXTAREA)->m_String = "Y:" + to_string(int(shapeData.m_rightTextureRect.y));

		m_currentGui->GetElement(GE_TOPWIDTHTEXTAREA)->m_String = "W:" + to_string(int(shapeData.m_topTextureRect.width));
		m_currentGui->GetElement(GE_FRONTWIDTHTEXTAREA)->m_String = "W:" + to_string(int(shapeData.m_frontTextureRect.width));
		m_currentGui->GetElement(GE_RIGHTWIDTHTEXTAREA)->m_String = "W:" + to_string(int(shapeData.m_rightTextureRect.width));

		m_currentGui->GetElement(GE_TOPHEIGHTTEXTAREA)->m_String = "H:" + to_string(int(shapeData.m_topTextureRect.height));
		m_currentGui->GetElement(GE_FRONTHEIGHTTEXTAREA)->m_String = "H:" + to_string(int(shapeData.m_frontTextureRect.height));
		m_currentGui->GetElement(GE_RIGHTHEIGHTTEXTAREA)->m_String = "H:" + to_string(int(shapeData.m_rightTextureRect.height));

		m_currentGui->GetElement(GE_TOPSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP))];
		m_currentGui->GetElement(GE_FRONTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT))];
		m_currentGui->GetElement(GE_RIGHTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT))];
		m_currentGui->GetElement(GE_BOTTOMSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM))];
		m_currentGui->GetElement(GE_BACKSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK))];
		m_currentGui->GetElement(GE_LEFTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT))];
	}

	if(m_currentGui == m_shapePointerGui.get())
	{
		m_currentGui->GetElement(GE_CURRENTSHAPEPOINTERIDTEXTAREA)->m_String = "PS:" + to_string(shapeData.m_pointerShape);
		m_currentGui->GetElement(GE_CURRENTFRAMEPOINTERIDTEXTAREA)->m_String = "PF:" + to_string(shapeData.m_pointerFrame);
	}

	std::ostringstream out;
	out.precision(2);
	out << std::fixed << shapeData.m_Scaling.x;
	m_currentGui->GetElement(GE_TWEAKWIDTHTEXTAREA)->m_String = "W:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_Scaling.y;
	m_currentGui->GetElement(GE_TWEAKHEIGHTTEXTAREA)->m_String = "H:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_Scaling.z;
	m_currentGui->GetElement(GE_TWEAKDEPTHTEXTAREA)->m_String = "D:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_TweakPos.x;
	m_currentGui->GetElement(GE_TWEAKXTEXTAREA)->m_String = "X:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_TweakPos.y;
	m_currentGui->GetElement(GE_TWEAKYTEXTAREA)->m_String = "Y:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_TweakPos.z;
	m_currentGui->GetElement(GE_TWEAKZTEXTAREA)->m_String = "Z:" + out.str();

	out.str("");
	out.precision(2);
	out << std::fixed << shapeData.m_rotation;
	m_currentGui->GetElement(GE_TWEAKROTATIONTEXTAREA)->m_String = out.str();

	if (m_currentGui == m_meshGui.get())
	{
		m_currentGui->GetElement(GE_MESHOUTLINECHECKBOX)->m_Selected = shapeData.m_meshOutline;
	}

	if (m_currentGui == m_meshGui.get())
	{
		std::string newStr = g_shapeTable[m_currentShape][m_currentFrame].m_customMeshName.substr(16);
		m_currentGui->GetElement(GE_MODELNAMETEXTAREA)->m_String = newStr;
	}

	m_currentGui->GetElement(GE_LUASCRIPTTEXTAREA)->m_String = g_shapeTable[m_currentShape][m_currentFrame].m_luaScript;

	// Update item name (how it appears in barks)
	m_currentGui->GetElement(GE_ITEMNAMETEXTAREA)->m_String = GetShapeFrameName(m_currentShape, m_currentFrame, 1);
}


void ShapeEditorState::Draw()
{
	BeginDrawing();

	ClearBackground(Color{ 106, 90, 205, 255 });

	ShapeData* shapeData = &g_shapeTable[m_currentShape][m_currentFrame];

	BeginMode3D(g_camera);

	Vector3 cuboidScaling = shapeData->m_Scaling;
	cuboidScaling.x *= 2.5;
	cuboidScaling.y *= 2.5;
	cuboidScaling.z *= 2.5;

	Vector3 finalPos = Vector3Add(Vector3Add(g_camera.target, shapeData->m_TweakPos), Vector3{ shapeData->m_Dims.x / 2 - 1, 0, shapeData->m_Dims.z / 2 - 1 });

	shapeData->Draw(finalPos, g_cameraRotation, Color{255, 255, 255, 255}, cuboidScaling);

	DrawSphere(Vector3Add(shapeData->m_CenterPoint, finalPos), 0.15f, RED);

	EndMode3D();
	
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({ 0, 0, 0, 0 });

	float scale = 2;

	//  Draw the minimap and marker

	if (shapeData->GetDrawType() == ShapeDrawType::OBJECT_DRAW_CUBOID)
	{
		Texture* d = shapeData->GetTexture();
		

		//  Draw original texture with label and border
		DrawTextEx(*g_guiFont.get(), "Original Texture", { 0, 0 }, g_guiFontSize, 1, WHITE);
		float yoffset = (g_guiFontSize + 2);
		DrawRectangleLinesEx({ 0, yoffset, float(d->width) * scale + scale + scale, float(d->height) * scale + scale + scale }, scale, WHITE);
		yoffset += scale;
		DrawTextureEx(*d, Vector2{ scale, yoffset }, 0, 2, Color{ 255, 255, 255, 255 });

		//  Draw rects on original texture showing top, front and right dimensions
		Rectangle fixedTopRect = shapeData->m_topTextureRect;
		fixedTopRect.x *= scale;
		fixedTopRect.x += scale - 1;
		fixedTopRect.y *= scale;
		fixedTopRect.y += yoffset - 1;
		fixedTopRect.width *= scale;
		fixedTopRect.width += scale;
		fixedTopRect.height *= scale;
		fixedTopRect.height += scale;

		DrawRectangleLinesEx(fixedTopRect, 1, RED);

		Rectangle fixedFrontRect = shapeData->m_frontTextureRect;
		fixedFrontRect.x += 1;
		fixedFrontRect.y *= scale;
		fixedFrontRect.y += yoffset - 2;
		fixedFrontRect.width *= scale;
		fixedFrontRect.width += scale;
		fixedFrontRect.height *= scale;
		fixedFrontRect.height += scale;

		DrawRectangleLinesEx(fixedFrontRect, 1, GREEN);

		Rectangle fixedRightRect = shapeData->m_rightTextureRect;
		fixedRightRect.x *= scale;
		fixedRightRect.x += scale - 1;
		//fixedRightRect.x += 1;
		fixedRightRect.y *= scale;
		fixedRightRect.y += yoffset - 1;
		fixedRightRect.width *= scale;
		fixedRightRect.width += scale;
		fixedRightRect.height *= scale;
		fixedRightRect.height += scale;

		DrawRectangleLinesEx(fixedRightRect, 1, BLUE);

		DrawTextureEx(*g_shapeTable[m_currentShape][m_currentFrame].GetCuboidTexture(), Vector2{ scale, yoffset + 10 + (d->height * scale) }, 0, 2, Color{ 255, 255, 255, 255 });

		////  Draw top texture with labels and borders
		Rectangle cuboidTopRect = shapeData->m_topTextureRect;
		cuboidTopRect.x = 1;
		cuboidTopRect.y = yoffset + 10 + (d->height * scale) - 1;
		cuboidTopRect.width *= scale;
		cuboidTopRect.width += scale;
		cuboidTopRect.height *= scale;
		cuboidTopRect.height += scale;

		DrawRectangleLinesEx(cuboidTopRect, 1, RED);

		Rectangle cuboidFrontRect = shapeData->m_frontTextureRect;
		cuboidFrontRect.x = 1;
		cuboidFrontRect.y = yoffset + 10 + (d->height * scale) - 1 + cuboidTopRect.height;
		cuboidFrontRect.width *= scale;
		cuboidFrontRect.width += scale;
		cuboidFrontRect.height *= scale;
		cuboidFrontRect.height += scale;

		DrawRectangleLinesEx(cuboidFrontRect, 1, GREEN);

		Rectangle cuboidRightRect = shapeData->m_rightTextureRect;
		cuboidRightRect.x = 1 + cuboidTopRect.width;
		cuboidRightRect.y = yoffset + 10 + (d->height * scale) - 1;
		cuboidRightRect.width *= scale;
		cuboidRightRect.width += scale;
		cuboidRightRect.height *= scale;
		cuboidRightRect.height += scale;

		DrawRectangleLinesEx(cuboidRightRect, 1, BLUE);
	}

	if (shapeData->GetDrawType() == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
	{
		Texture* d = shapeData->GetTexture();
		DrawTextureEx(*d, Vector2{ 0, 0 }, 0, scale, Color{ 255, 255, 255, 255 });
	}


	DrawConsole();

	int yOffset = g_guiFontSize;
	int y = -yOffset;

	m_currentGui->Draw();

	//  Draw any tooltips
	EndTextureMode();
	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	DrawTextureEx(*g_Cursor, { float(GetMouseX()), float(GetMouseY()) }, 0, g_DrawScale, WHITE);

	EndDrawing();
}

void ShapeEditorState::SetupBboardGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_bboardGui = make_unique<Gui>();

	m_bboardGui->m_Font = g_guiFont;
	m_bboardGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_bboardGui->m_InputScale = g_DrawScale;

	m_bboardGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_bboardGui.get());

	//  Billboard specific setup

	m_bboardGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "BBoard";
}

void ShapeEditorState::SetupFlatGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_flatGui = make_unique<Gui>();

	m_flatGui->m_Font = g_guiFont;
	m_flatGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_flatGui->m_InputScale = g_DrawScale;

	m_flatGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_flatGui.get());

	//  Flat specific setup

	int yoffset = 13;
	
	m_flatGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Flat";
}

void ShapeEditorState::SetupCuboidGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_cuboidGui = make_unique<Gui>();

	m_cuboidGui->m_Font = g_guiFont;
	m_cuboidGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_cuboidGui->m_InputScale = g_DrawScale;

	m_cuboidGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_cuboidGui.get());

	//  Cuboid specific setup

	m_cuboidGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Cuboid";

	int yoffset = 13;

	m_cuboidGui->AddTextArea(GE_TOPTEXTAREA, g_guiFont.get(), "Top Face", 3, y, 0, 0, RED);
	m_cuboidGui->AddTextButton(GE_TOPRESET, 60, y - 2, "Reset", g_guiFont.get());
	y += yoffset * .8f;

	m_cuboidGui->AddIconButton(GE_TOPXMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPXPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPXTEXTAREA, g_guiFont.get(), "X: " + to_string(int(shapeData.m_topTextureRect.x)), 14, y);

	m_cuboidGui->AddIconButton(GE_TOPYMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPYPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPYTEXTAREA, g_guiFont.get(), "Y: " + to_string(int(shapeData.m_topTextureRect.y)), 55, y);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_TOPWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPWIDTHTEXTAREA, g_guiFont.get(), "W: " + to_string(int(shapeData.m_topTextureRect.width)), 14, y);

	m_cuboidGui->AddIconButton(GE_TOPHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPHEIGHTPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPHEIGHTTEXTAREA, g_guiFont.get(), "H: " + to_string(int(shapeData.m_topTextureRect.height)), 55, y);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_FRONTTEXTAREA, g_guiFont.get(), "Front Face", 3, y, 0, 0, GREEN);
	m_cuboidGui->AddTextButton(GE_FRONTRESET, 60, y - 2, "Reset", g_guiFont.get());
	y += yoffset * .8f;

	m_cuboidGui->AddIconButton(GE_FRONTXMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTXPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTXTEXTAREA, g_guiFont.get(), "X: " + to_string(int(shapeData.m_topTextureRect.x)), 14, y);

	m_cuboidGui->AddIconButton(GE_FRONTYMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTYPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTYTEXTAREA, g_guiFont.get(), "Y: " + to_string(int(shapeData.m_topTextureRect.y)), 55, y);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_FRONTWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTWIDTHTEXTAREA, g_guiFont.get(), "W: " + to_string(int(shapeData.m_topTextureRect.width)), 14, y);

	m_cuboidGui->AddIconButton(GE_FRONTHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTHEIGHTPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTHEIGHTTEXTAREA, g_guiFont.get(), "H: " + to_string(int(shapeData.m_topTextureRect.height)), 55, y);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_RIGHTTEXTAREA, g_guiFont.get(), "Right Face", 3, y, 0, 0, BLUE);
	m_cuboidGui->AddTextButton(GE_RIGHTRESET, 60, y - 2, "Reset", g_guiFont.get());
	y += yoffset * .8f;

	m_cuboidGui->AddIconButton(GE_RIGHTXMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTXPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTXTEXTAREA, g_guiFont.get(), "X: " + to_string(int(shapeData.m_topTextureRect.x)), 14, y);

	m_cuboidGui->AddIconButton(GE_RIGHTYMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTYPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTYTEXTAREA, g_guiFont.get(), "Y: " + to_string(int(shapeData.m_topTextureRect.y)), 55, y);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_RIGHTWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTWIDTHTEXTAREA, g_guiFont.get(), "W: " + to_string(int(shapeData.m_topTextureRect.width)), 14, y);

	m_cuboidGui->AddIconButton(GE_RIGHTHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTHEIGHTPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTHEIGHTTEXTAREA, g_guiFont.get(), "H: " + to_string(int(shapeData.m_topTextureRect.height)), 55, y);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_TEXTUREASSIGNMENTTEXTAREA, g_guiFont.get(), "Texture Assignment:", 2, y);

	y += yoffset * .7f;

	m_cuboidGui->AddTextArea(GE_TOPSIDETEXTAREA, g_guiFont.get(), "Top", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVTOPBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_TOPSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTTOPBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_FRONTSIDETEXTAREA, g_guiFont.get(), "Front", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVFRONTBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_FRONTSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTFRONTBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_RIGHTSIDETEXTAREA, g_guiFont.get(), "Right", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVRIGHTBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTRIGHTBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_BOTTOMSIDETEXTAREA, g_guiFont.get(), "Bottom", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVBOTTOMBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_BOTTOMSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTBOTTOMBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_BACKSIDETEXTAREA, g_guiFont.get(), "Back", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVBACKBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_BACKSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTBACKBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_LEFTSIDETEXTAREA, g_guiFont.get(), "Left", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVLEFTBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_LEFTSIDETEXTURETEXTAREA, g_guiFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTLEFTBUTTON, 95, y, g_RightArrow);
}

void ShapeEditorState::SetupMeshGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_meshGui = make_unique<Gui>();

	m_meshGui->m_Font = g_guiFont;
	m_meshGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_meshGui->m_InputScale = g_DrawScale;

	m_meshGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_meshGui.get());

	//  Mesh specific setup

	m_meshGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Mesh";

	int yoffset = 13;

	m_meshGui->AddTextArea(GE_MODELTEXTAREA, g_guiFont.get(), "Model:", 2, y);

	y += yoffset;

	m_meshGui->AddIconButton(GE_PREVMODELBUTTON, 2, y, g_LeftArrow);
	m_meshGui->AddTextArea(GE_MODELNAMETEXTAREA, g_guiFont.get(), shapeData.m_customMeshName, 12, y);
	m_meshGui->AddIconButton(GE_NEXTMODELBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	m_meshGui->AddCheckBox(GE_MESHOUTLINECHECKBOX, 4, y, g_guiFont->baseSize, g_guiFont->baseSize);
	m_meshGui->GetElement(GE_MESHOUTLINECHECKBOX)->m_Selected = shapeData.m_meshOutline;
	m_meshGui->AddTextArea(GE_MESHOUTLINETEXTAREA, g_guiFont.get(), "Use Mesh Outline", 22, y);

}

void ShapeEditorState::SetupCharacterGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_characterGui = make_unique<Gui>();

	m_characterGui->m_Font = g_guiFont;
	m_characterGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_characterGui->m_InputScale = g_DrawScale;

	m_characterGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_characterGui.get());

	//  Character specific setup
	m_characterGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Character";
}

void ShapeEditorState::SetupShapePointerGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_shapePointerGui = make_unique<Gui>();

	m_shapePointerGui->m_Font = g_guiFont;
	m_shapePointerGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_shapePointerGui->m_InputScale = g_DrawScale;

	m_shapePointerGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int y = SetupCommonGui(m_shapePointerGui.get());

	//  Shape Pointer specific setup

	m_shapePointerGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Pointer";

	int yoffset = 13;

	m_shapePointerGui->AddIconButton(GE_PREVSHAPEPOINTERBUTTON, 2, y, g_LeftArrow);
	m_shapePointerGui->AddIconButton(GE_NEXTSHAPEPOINTERBUTTON, 50, y, g_RightArrow);
	m_shapePointerGui->AddTextArea(GE_CURRENTSHAPEPOINTERIDTEXTAREA, g_guiFont.get(), "PS: " + to_string(m_currentShape), 12, y);

	m_shapePointerGui->AddIconButton(GE_PREVFRAMEPOINTERBUTTON, 62, y, g_LeftArrow);
	m_shapePointerGui->AddIconButton(GE_NEXTFRAMEPOINTERBUTTON, 110, y, g_RightArrow);
	m_shapePointerGui->AddTextArea(GE_CURRENTFRAMEPOINTERIDTEXTAREA, g_guiFont.get(), "PF: " + to_string(m_currentFrame), 71, y);

}

void ShapeEditorState::SetupDontDrawGui()
{
	//  Universal setup
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_dontDrawGui = make_unique<Gui>();

	m_dontDrawGui->m_Font = g_guiFont;
	m_dontDrawGui->SetLayout(0, 0, 120, 360, 1, Gui::GUIP_UPPERRIGHT);
	m_dontDrawGui->m_InputScale = g_DrawScale;

	m_dontDrawGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	SetupCommonGui(m_dontDrawGui.get());

	//  Dont Draw specific setup
	m_dontDrawGui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = "Don't Draw";
}

int ShapeEditorState::SetupCommonGui(Gui* gui)
{
	int yoffset = 13;
	int y = 4;

	gui->AddTextButton(GE_SAVEBUTTON, 8, y - 2, "  Save  ", g_guiFont.get());
	gui->AddTextButton(GE_LOADBUTTON, 64, y - 2, "  Load  ", g_guiFont.get());
	y += yoffset;

	gui->AddIconButton(GE_PREVSHAPEBUTTON, 2, y, g_LeftArrow);
	gui->AddIconButton(GE_NEXTSHAPEBUTTON, 60, y, g_RightArrow);
	std::stringstream ss;
    ss << std::uppercase << std::hex << m_currentShape;
	gui->AddTextArea(GE_CURRENTSHAPEIDTEXTAREA, g_guiFont.get(), "S:" + to_string(m_currentShape) + " (" + ss.str() + ")", 12, y);

	gui->AddIconButton(GE_PREVFRAMEBUTTON, 70, y, g_LeftArrow);
	gui->AddIconButton(GE_NEXTFRAMEBUTTON, 110, y, g_RightArrow);
	gui->AddTextArea(GE_CURRENTFRAMEIDTEXTAREA, g_guiFont.get(), "F:" + to_string(m_currentFrame), 80, y);

	y += yoffset;

	gui->AddTextArea(GE_DRAWTYPELABEL, g_guiFont.get(), "DrawType: ", 2, y);
	gui->AddIconButton(GE_PREVDRAWTYPE, 45, y, g_LeftArrow);
	gui->AddIconButton(GE_NEXTDRAWTYPE, 110, y, g_RightArrow);

	gui->AddTextArea(GE_CURRENTDRAWTYPETEXTAREA, g_guiFont.get(), "", 54, y);

	y += yoffset;

	gui->AddTextButton(GE_COPYPARAMSFROMFRAME0, 8, y - 2, "Copy From Frame 0", g_guiFont.get());

	y += yoffset;
	gui->AddTextArea(GE_TWEAKPOSITIONTEXTAREA, g_guiFont.get(), "Tweak Pos: ", 2, y);
	gui->AddTextArea(GE_TWEAKDIMENSIONSTEXTAREA, g_guiFont.get(), "Tweak Dims: ", 62, y);

	y += yoffset * .7f;

	gui->AddIconButton(GE_TWEAKXPLUSBUTTON, 2, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKXTEXTAREA, g_guiFont.get(), "X:", 11, y);
	gui->AddIconButton(GE_TWEAKXMINUSBUTTON, 50, y, g_RightArrow);

	std::ostringstream out;

	out.precision(1);
	gui->AddIconButton(GE_TWEAKWIDTHPLUSBUTTON, 62, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKWIDTHTEXTAREA, g_guiFont.get(), "W:", 71, y);
	gui->AddIconButton(GE_TWEAKWIDTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;

	gui->AddIconButton(GE_TWEAKYPLUSBUTTON, 2, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKYTEXTAREA, g_guiFont.get(), "Y:", 11, y);
	gui->AddIconButton(GE_TWEAKYMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	gui->AddIconButton(GE_TWEAKHEIGHTPLUSBUTTON, 62, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKHEIGHTTEXTAREA, g_guiFont.get(), "H:", 71, y);
	gui->AddIconButton(GE_TWEAKHEIGHTMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;

	gui->AddIconButton(GE_TWEAKZPLUSBUTTON, 2, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKZTEXTAREA, g_guiFont.get(), "Z:", 11, y);
	gui->AddIconButton(GE_TWEAKZMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	gui->AddIconButton(GE_TWEAKDEPTHPLUSBUTTON, 62, y, g_LeftArrow);
	gui->AddTextArea(GE_TWEAKDEPTHTEXTAREA, g_guiFont.get(), "D:", 71, y);
	gui->AddIconButton(GE_TWEAKDEPTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	out.str("");
	out.precision(1);
	gui->AddTextArea(GE_TWEAKROTATIONTITLEAREA, g_guiFont.get(), "Tweak Rot:", 2, y);
	gui->AddIconButton(GE_TWEAKROTATIONPLUSBUTTON, 62, y, g_LeftArrow, g_LeftArrow, g_LeftArrow, "", g_guiFont.get(), Color{ 255, 255, 255, 255 }, 1, 1, true, true);
	gui->AddTextArea(GE_TWEAKROTATIONTEXTAREA, g_guiFont.get(), " ", 71, y);
	gui->AddIconButton(GE_TWEAKROTATIONMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset;
	gui->AddTextButton(GE_JUMPTOINSTANCE, 8, y - 2, "Jump To Instance", g_guiFont.get());

	y += yoffset;

	gui->AddTextArea(GE_LUASCRIPTLABEL, g_guiFont.get(), "Lua Script:", 2, y);
	gui->AddTextButton(GE_OPENLUASCRIPTBUTTON, 60, y - 2, "Open Script", g_guiFont.get());

	y += yoffset;

	gui->AddIconButton(GE_PREVLUASCRIPTBUTTON, 2, y, g_LeftArrow);
	gui->AddTextArea(GE_LUASCRIPTTEXTAREA, g_guiFont.get(), "", 12, y);
	gui->AddIconButton(GE_NEXTLUASCRIPTBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	gui->AddTextButton(GE_SETLUASCRIPTTOSHAPEIDBUTTON, 4, y - 2, "Set Script to ShapeID", g_guiFont.get());

	y += yoffset;

	// Display the item name (how it appears in barks) - updated dynamically in Update()
	gui->AddTextArea(GE_ITEMNAMETEXTLABEL, g_guiFont.get(), "Bark:", 2, y);
	gui->AddTextArea(GE_ITEMNAMETEXTAREA, g_guiFont.get(), "", 38, y);

	y += yoffset;

	return y;

}