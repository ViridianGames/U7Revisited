#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/StateMachine.h"
#include "U7Globals.h"
#include "ObjectEditorState.h"
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
//  ObjectEditorState
////////////////////////////////////////////////////////////////////////////////

ObjectEditorState::~ObjectEditorState()
{
	Shutdown();
}

void ObjectEditorState::Init(const string& configfile)
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

	//  Set up GUI

	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_gui = make_unique<Gui>();

	m_gui->m_Font = g_SmallFont;
	m_gui->m_Pos = Vector2{ 240 * g_DrawScale, 0 };
	m_gui->SetLayout(240 * g_DrawScale, 0, 80, 180, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_gui->AddOctagonBox(GE_PANELBORDER, 0, 0, 80, 180, g_Borders);
	//m_gui->AddPanel(GE_PANELBORDER, 0, 0, 100, 180, g_DarkGray);
	//m_gui->AddPanel(GE_PANEL, 4, 4, 92, 172, g_Brown);

	int yoffset = 10;
	int y = 4;

	m_gui->AddTextButton(GE_SAVEBUTTON, 4, y, "Save", g_SmallFont.get());
	m_gui->AddTextButton(GE_LOADBUTTON, 45, y, "Load", g_SmallFont.get());
	y += yoffset;

	m_gui->AddIconButton(GE_PREVSHAPEBUTTON, 4, y, g_LeftArrow);
	m_gui->AddIconButton(GE_NEXTSHAPEBUTTON, 35, y, g_RightArrow);
	m_gui->AddTextArea(GE_CURRENTSHAPEIDTEXTAREA, g_SmallFont.get(), "S: " + to_string(m_currentShape), 14, y);

	m_gui->AddIconButton(GE_PREVFRAMEBUTTON, 45, y, g_LeftArrow);
	m_gui->AddIconButton(GE_NEXTFRAMEBUTTON, 70, y, g_RightArrow);
	m_gui->AddTextArea(GE_CURRENTFRAMEIDTEXTAREA, g_SmallFont.get(), "F: " + to_string(m_currentFrame), 55, y);

	y += yoffset;

	m_gui->AddIconButton(GE_PREVDRAWTYPEBUTTON, 4, y, g_LeftArrow);
	m_gui->AddIconButton(GE_NEXTDRAWTYPEBUTTON, 68, y, g_RightArrow);
	m_gui->AddTextArea(GE_CURRENTDRAWTYPETEXTAREA, g_SmallFont.get(), g_objectDrawTypeStrings[static_cast<int>(shapeData.GetDrawType())], 14, y);
	y += yoffset;

	m_gui->AddTextArea(GE_TOPTEXTAREA, g_SmallFont.get(), "Top Face", 3, y);
	m_gui->AddTextButton(GE_TOPRESET, 50, y, "Reset", g_SmallFont.get());
	y += yoffset;

	m_gui->AddIconButton(GE_TOPXMINUSBUTTON, 4, y, g_LeftArrow);
	m_gui->AddIconButton(GE_TOPXPLUSBUTTON, 35, y, g_RightArrow);
	m_gui->AddTextArea(GE_TOPXTEXTAREA, g_SmallFont.get(), "X: " + to_string(shapeData.m_topTextureOffsetX), 14, y);

	m_gui->AddIconButton(GE_TOPYMINUSBUTTON, 45, y, g_LeftArrow);
	m_gui->AddIconButton(GE_TOPYPLUSBUTTON, 70, y, g_RightArrow);
	m_gui->AddTextArea(GE_TOPYTEXTAREA, g_SmallFont.get(), "Y: " + to_string(shapeData.m_topTextureOffsetY), 55, y);

	y += yoffset;

	m_gui->AddIconButton(GE_TOPWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_gui->AddIconButton(GE_TOPWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_gui->AddTextArea(GE_TOPWIDTHTEXTAREA, g_SmallFont.get(), "W: " + to_string(shapeData.m_topTextureWidth), 14, y);

	m_gui->AddIconButton(GE_TOPHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_gui->AddIconButton(GE_TOPHEIGHTPLUSBUTTON, 70, y, g_RightArrow);
	m_gui->AddTextArea(GE_TOPHEIGHTTEXTAREA, g_SmallFont.get(), "H: " + to_string(shapeData.m_topTextureHeight), 55, y);

	y += yoffset;

	m_gui->AddTextArea(GE_FRONTTEXTAREA, g_SmallFont.get(), "Front Face", 3, y);
	m_gui->AddTextButton(GE_FRONTRESET, 50, y, "Reset", g_SmallFont.get());
	y += yoffset;

	m_gui->AddIconButton(GE_FRONTXMINUSBUTTON, 4, y, g_LeftArrow);
	m_gui->AddIconButton(GE_FRONTXPLUSBUTTON, 35, y, g_RightArrow);
	m_gui->AddTextArea(GE_FRONTXTEXTAREA, g_SmallFont.get(), "X: " + to_string(shapeData.m_topTextureOffsetX), 14, y);

	m_gui->AddIconButton(GE_FRONTYMINUSBUTTON, 45, y, g_LeftArrow);
	m_gui->AddIconButton(GE_FRONTYPLUSBUTTON, 70, y, g_RightArrow);
	m_gui->AddTextArea(GE_FRONTYTEXTAREA, g_SmallFont.get(), "Y: " + to_string(shapeData.m_topTextureOffsetY), 55, y);

	y += yoffset;

	m_gui->AddIconButton(GE_FRONTWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_gui->AddIconButton(GE_FRONTWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_gui->AddTextArea(GE_FRONTWIDTHTEXTAREA, g_SmallFont.get(), "W: " + to_string(shapeData.m_topTextureWidth), 14, y);

	m_gui->AddIconButton(GE_FRONTHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_gui->AddIconButton(GE_FRONTHEIGHTPLUSBUTTON, 70, y, g_RightArrow);
	m_gui->AddTextArea(GE_FRONTHEIGHTTEXTAREA, g_SmallFont.get(), "H: " + to_string(shapeData.m_topTextureHeight), 55, y);

	y += yoffset;

	m_gui->AddTextArea(GE_RIGHTTEXTAREA, g_SmallFont.get(), "Right Face", 3, y);
	m_gui->AddTextButton(GE_RIGHTRESET, 50, y, "Reset", g_SmallFont.get());
	y += yoffset;

	m_gui->AddIconButton(GE_RIGHTXMINUSBUTTON, 4, y, g_LeftArrow);
	m_gui->AddIconButton(GE_RIGHTXPLUSBUTTON, 35, y, g_RightArrow);
	m_gui->AddTextArea(GE_RIGHTXTEXTAREA, g_SmallFont.get(), "X: " + to_string(shapeData.m_topTextureOffsetX), 14, y);

	m_gui->AddIconButton(GE_RIGHTYMINUSBUTTON, 45, y, g_LeftArrow);
	m_gui->AddIconButton(GE_RIGHTYPLUSBUTTON, 70, y, g_RightArrow);
	m_gui->AddTextArea(GE_RIGHTYTEXTAREA, g_SmallFont.get(), "Y: " + to_string(shapeData.m_topTextureOffsetY), 55, y);

	y += yoffset;

	m_gui->AddIconButton(GE_RIGHTWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_gui->AddIconButton(GE_RIGHTWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_gui->AddTextArea(GE_RIGHTWIDTHTEXTAREA, g_SmallFont.get(), "W: " + to_string(shapeData.m_topTextureWidth), 14, y);

	m_gui->AddIconButton(GE_RIGHTHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_gui->AddIconButton(GE_RIGHTHEIGHTPLUSBUTTON, 70, y, g_RightArrow);
	m_gui->AddTextArea(GE_RIGHTHEIGHTTEXTAREA, g_SmallFont.get(), "H: " + to_string(shapeData.m_topTextureHeight), 55, y);
	
	y += yoffset;

	yoffset = 9;

	m_gui->AddTextArea(GE_TOPSIDETEXTAREA, g_SmallFont.get(), "Top", 3, y);
	m_gui->AddIconButton(GE_PREVTOPBUTTON, 30, y, g_LeftArrow);
	m_gui->AddTextArea(GE_TOPSIDETEXTURETEXTAREA, g_SmallFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP))], 40, y);
	m_gui->AddIconButton(GE_NEXTTOPBUTTON, 70, y, g_RightArrow);
	y += yoffset;

	m_gui->AddTextArea(GE_FRONTSIDETEXTAREA, g_SmallFont.get(), "Front", 3, y);
	m_gui->AddIconButton(GE_PREVFRONTBUTTON, 30, y, g_LeftArrow);
	m_gui->AddTextArea(GE_FRONTSIDETEXTURETEXTAREA, g_SmallFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT))], 40, y);
	m_gui->AddIconButton(GE_NEXTFRONTBUTTON, 70, y, g_RightArrow);
	y += yoffset;
	
	m_gui->AddTextArea(GE_RIGHTSIDETEXTAREA, g_SmallFont.get(), "Right", 3, y);
	m_gui->AddIconButton(GE_PREVRIGHTBUTTON, 30, y, g_LeftArrow);
	m_gui->AddTextArea(GE_RIGHTSIDETEXTURETEXTAREA, g_SmallFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT))], 40, y);
	m_gui->AddIconButton(GE_NEXTRIGHTBUTTON, 70, y, g_RightArrow);
	y += yoffset;
	
	m_gui->AddTextArea(GE_BOTTOMSIDETEXTAREA, g_SmallFont.get(), "Bottom", 3, y);
	m_gui->AddIconButton(GE_PREVBOTTOMBUTTON, 30, y, g_LeftArrow);
	m_gui->AddTextArea(GE_BOTTOMSIDETEXTURETEXTAREA, g_SmallFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM))], 40, y);
	m_gui->AddIconButton(GE_NEXTBOTTOMBUTTON, 70, y, g_RightArrow);
	y += yoffset;

	m_gui->AddTextArea(GE_BACKSIDETEXTAREA, g_SmallFont.get(), "Back", 3, y);
	m_gui->AddIconButton(GE_PREVBACKBUTTON, 30, y, g_LeftArrow);
	m_gui->AddTextArea(GE_BACKSIDETEXTURETEXTAREA, g_SmallFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK))], 40, y);
	m_gui->AddIconButton(GE_NEXTBACKBUTTON, 70, y, g_RightArrow);
	y += yoffset;

	m_gui->AddTextArea(GE_LEFTSIDETEXTAREA, g_SmallFont.get(), "Left", 3, y);
	m_gui->AddIconButton(GE_PREVLEFTBUTTON, 30, y, g_LeftArrow);
	m_gui->AddTextArea(GE_LEFTSIDETEXTURETEXTAREA, g_SmallFont.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT))], 40, y);
	m_gui->AddIconButton(GE_NEXTLEFTBUTTON, 70, y, g_RightArrow);
}

void ObjectEditorState::OnEnter()
{
	ClearConsole();

	m_currentFrame = g_selectedFrame;
	m_currentShape = g_selectedShape;

}

void ObjectEditorState::OnExit()
{

}

void ObjectEditorState::Shutdown()
{

}

void ObjectEditorState::Update()
{
	//  Handle input
	m_gui->Update();
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_Done = true;
	}

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


	if (IsKeyPressed(KEY_A) || m_gui->GetActiveElementID() == GE_PREVSHAPEBUTTON)
	{
		int newShape = m_currentShape - 1;

		if (IsKeyDown(KEY_LEFT_SHIFT))
		{
			newShape -= 9;
		}


		if (newShape < 150)
		{
			newShape = 1023;
		}

		if (g_shapeTable[newShape][0].IsValid())
		{
			m_currentShape = newShape;
		}
		else
		{
			m_currentShape = 0;
		}

		m_currentFrame = 0;
	}

	if (IsKeyPressed(KEY_D) || m_gui->GetActiveElementID() == GE_NEXTSHAPEBUTTON)
	{
		int newShape = m_currentShape + 1;

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
			m_currentShape = newShape;
		}
		else
		{
			m_currentShape = 0;
		}

		m_currentFrame = 0;
	}

	if (IsKeyPressed(KEY_W) || m_gui->GetActiveElementID() == GE_NEXTFRAMEBUTTON)
	{
		int newFrame = m_currentFrame + 1;
		if (newFrame > 31)
		{
			newFrame = 0;
		}

		if (g_shapeTable[m_currentShape][newFrame].IsValid())
		{
			m_currentFrame = newFrame;
		}
	}

	if (IsKeyPressed(KEY_S) || m_gui->GetActiveElementID() == GE_PREVFRAMEBUTTON)
	{
		int newFrame = m_currentFrame - 1;
		if (newFrame < 0)
		{
			newFrame = 31;
		}

		if (g_shapeTable[m_currentShape][newFrame].IsValid())
		{
			m_currentFrame = newFrame;
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

	if (IsKeyPressed(KEY_SPACE) || m_gui->GetActiveElementID() == GE_NEXTDRAWTYPEBUTTON)
	{
		ShapeDrawType newDrawType = static_cast<ShapeDrawType>((static_cast<int>(g_shapeTable[m_currentShape][m_currentFrame].GetDrawType()) + 1) % static_cast<int>(ShapeDrawType::OBJECT_DRAW_LAST));
		g_shapeTable[m_currentShape][m_currentFrame].SetDrawType(newDrawType);
	}

	if (IsKeyPressed(KEY_F1))
	{
		g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
	}

	//  Handle GUI Input
	if (m_gui->GetActiveElementID() == GE_SAVEBUTTON)
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
		}
	}

	if (m_gui->GetActiveElementID() == GE_LOADBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_PREVDRAWTYPEBUTTON)
	{
		int shape = static_cast<int>(g_shapeTable[m_currentShape][m_currentFrame].GetDrawType());
		shape--;
		if (shape < 0)
		{
			shape = static_cast<int>(ShapeDrawType::OBJECT_DRAW_LAST) - 1;
		}

		ShapeDrawType newDrawType = static_cast<ShapeDrawType>(shape);
		g_shapeTable[m_currentShape][m_currentFrame].SetDrawType(newDrawType);
	}

	bool somethingChanged = false;
	if (m_gui->GetActiveElementID() == GE_TOPXMINUSBUTTON) { somethingChanged = true; shapeData.m_topTextureOffsetX--; }
	if (m_gui->GetActiveElementID() == GE_TOPXPLUSBUTTON) { somethingChanged = true; shapeData.m_topTextureOffsetX++; }
	if (m_gui->GetActiveElementID() == GE_TOPYMINUSBUTTON) { somethingChanged = true; shapeData.m_topTextureOffsetY--; }
	if (m_gui->GetActiveElementID() == GE_TOPYPLUSBUTTON) { somethingChanged = true; shapeData.m_topTextureOffsetY++; }
	if (m_gui->GetActiveElementID() == GE_TOPWIDTHMINUSBUTTON) { somethingChanged = true; shapeData.m_topTextureWidth--; }
	if (m_gui->GetActiveElementID() == GE_TOPWIDTHPLUSBUTTON) { somethingChanged = true; shapeData.m_topTextureWidth++; }
	if (m_gui->GetActiveElementID() == GE_TOPHEIGHTMINUSBUTTON) { somethingChanged = true; shapeData.m_topTextureHeight--; }
	if (m_gui->GetActiveElementID() == GE_TOPHEIGHTPLUSBUTTON) { somethingChanged = true; shapeData.m_topTextureHeight++; }

	if (m_gui->GetActiveElementID() == GE_FRONTXMINUSBUTTON) { somethingChanged = true; shapeData.m_frontTextureOffsetX--; }
	if (m_gui->GetActiveElementID() == GE_FRONTXPLUSBUTTON) { somethingChanged = true; shapeData.m_frontTextureOffsetX++; }
	if (m_gui->GetActiveElementID() == GE_FRONTYMINUSBUTTON) { somethingChanged = true; shapeData.m_frontTextureOffsetY--; }
	if (m_gui->GetActiveElementID() == GE_FRONTYPLUSBUTTON) { somethingChanged = true; shapeData.m_frontTextureOffsetY++; }
	if (m_gui->GetActiveElementID() == GE_FRONTWIDTHMINUSBUTTON) { somethingChanged = true; shapeData.m_frontTextureWidth--; }
	if (m_gui->GetActiveElementID() == GE_FRONTWIDTHPLUSBUTTON) { somethingChanged = true; shapeData.m_frontTextureWidth++; }
	if (m_gui->GetActiveElementID() == GE_FRONTHEIGHTMINUSBUTTON) { somethingChanged = true; shapeData.m_frontTextureHeight--; }
	if (m_gui->GetActiveElementID() == GE_FRONTHEIGHTPLUSBUTTON) { somethingChanged = true; shapeData.m_frontTextureHeight++; }

	if (m_gui->GetActiveElementID() == GE_RIGHTXMINUSBUTTON) { somethingChanged = true; shapeData.m_rightTextureOffsetX--; }
	if (m_gui->GetActiveElementID() == GE_RIGHTXPLUSBUTTON) { somethingChanged = true; shapeData.m_rightTextureOffsetX++; }
	if (m_gui->GetActiveElementID() == GE_RIGHTYMINUSBUTTON) { somethingChanged = true; shapeData.m_rightTextureOffsetY--; }
	if (m_gui->GetActiveElementID() == GE_RIGHTYPLUSBUTTON) { somethingChanged = true; shapeData.m_rightTextureOffsetY++; }
	if (m_gui->GetActiveElementID() == GE_RIGHTWIDTHMINUSBUTTON) { somethingChanged = true; shapeData.m_rightTextureWidth--; }
	if (m_gui->GetActiveElementID() == GE_RIGHTWIDTHPLUSBUTTON) { somethingChanged = true; shapeData.m_rightTextureWidth++; }
	if (m_gui->GetActiveElementID() == GE_RIGHTHEIGHTMINUSBUTTON) { somethingChanged = true; shapeData.m_rightTextureHeight--; }
	if (m_gui->GetActiveElementID() == GE_RIGHTHEIGHTPLUSBUTTON) { somethingChanged = true; shapeData.m_rightTextureHeight++; }

	if (m_gui->GetActiveElementID() == GE_TOPRESET) { somethingChanged = true; shapeData.ResetTopTexture(); }
	if (m_gui->GetActiveElementID() == GE_FRONTRESET) { somethingChanged = true; shapeData.ResetFrontTexture(); }
	if (m_gui->GetActiveElementID() == GE_RIGHTRESET) { somethingChanged = true; shapeData.ResetRightTexture(); }

	if (m_gui->GetActiveElementID() == GE_PREVTOPBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_NEXTTOPBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_PREVFRONTBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_NEXTFRONTBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_PREVRIGHTBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_NEXTRIGHTBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_PREVBOTTOMBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_NEXTBOTTOMBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_PREVBACKBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_NEXTBACKBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_PREVLEFTBUTTON)
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

	if (m_gui->GetActiveElementID() == GE_NEXTLEFTBUTTON)
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

	if (somethingChanged)
	{
		shapeData.SafeAndSane();
		shapeData.FixupTextures();
		shapeData.UpdateAllCuboidTextures();
	}

	if (g_CameraMoved)
	{
		Vector3 camPos = { g_cameraDistance, g_cameraDistance, g_cameraDistance };
		camPos = Vector3RotateByAxisAngle(camPos, Vector3{ 0, 1, 0 }, g_cameraRotation);

		g_camera.position = Vector3Add(g_camera.target, camPos);
		g_camera.fovy = g_cameraDistance;
	}	

	//  Update GUI Textareas
	m_gui->GetElement(GE_CURRENTSHAPEIDTEXTAREA)->m_String = "S:" + to_string(m_currentShape);
	m_gui->GetElement(GE_CURRENTFRAMEIDTEXTAREA)->m_String = "F:" + to_string(m_currentFrame);
	m_gui->GetElement(GE_CURRENTDRAWTYPETEXTAREA)->m_String = g_objectDrawTypeStrings[static_cast<int>(g_shapeTable[m_currentShape][m_currentFrame].GetDrawType())];

	m_gui->GetElement(GE_TOPXTEXTAREA)->m_String = "X:" + to_string(shapeData.m_topTextureOffsetX);
	m_gui->GetElement(GE_FRONTXTEXTAREA)->m_String = "X:" + to_string(shapeData.m_frontTextureOffsetX);
	m_gui->GetElement(GE_RIGHTXTEXTAREA)->m_String = "X:" + to_string(shapeData.m_rightTextureOffsetX);

	m_gui->GetElement(GE_TOPYTEXTAREA)->m_String = "Y:" + to_string(shapeData.m_topTextureOffsetY);
	m_gui->GetElement(GE_FRONTYTEXTAREA)->m_String = "Y:" + to_string(shapeData.m_frontTextureOffsetY);
	m_gui->GetElement(GE_RIGHTYTEXTAREA)->m_String = "Y:" + to_string(shapeData.m_rightTextureOffsetY);

	m_gui->GetElement(GE_TOPWIDTHTEXTAREA)->m_String = "W:" + to_string(shapeData.m_topTextureWidth);
	m_gui->GetElement(GE_FRONTWIDTHTEXTAREA)->m_String = "W:" + to_string(shapeData.m_frontTextureWidth);
	m_gui->GetElement(GE_RIGHTWIDTHTEXTAREA)->m_String = "W:" + to_string(shapeData.m_rightTextureWidth);

	m_gui->GetElement(GE_TOPHEIGHTTEXTAREA)->m_String = "H:" + to_string(shapeData.m_topTextureHeight);
	m_gui->GetElement(GE_FRONTHEIGHTTEXTAREA)->m_String = "H:" + to_string(shapeData.m_frontTextureHeight);
	m_gui->GetElement(GE_RIGHTHEIGHTTEXTAREA)->m_String = "H:" + to_string(shapeData.m_rightTextureHeight);

	m_gui->GetElement(GE_TOPSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP))];
	m_gui->GetElement(GE_FRONTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT))];
	m_gui->GetElement(GE_RIGHTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT))];
	m_gui->GetElement(GE_BOTTOMSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM))];
	m_gui->GetElement(GE_BACKSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK))];
	m_gui->GetElement(GE_LEFTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT))];

}


void ObjectEditorState::Draw()
{
	BeginDrawing();

	ClearBackground(Color{ 106, 90, 205, 255 });

	float scale = g_DrawScale;

	Texture* d = g_shapeTable[m_currentShape][m_currentFrame].GetTexture();
	Texture* t = g_shapeTable[m_currentShape][m_currentFrame].GetTopTexture();
	Texture* f = g_shapeTable[m_currentShape][m_currentFrame].GetFrontTexture();
	Texture* r = g_shapeTable[m_currentShape][m_currentFrame].GetRightTexture();

	DrawTextureEx(*d, Vector2{ 0, 0 }                      ,                      0, scale, Color{ 255, 255, 255, 255 });
	DrawTextureEx(*t, Vector2{ 0, (d->height + 2) * scale },                      0, scale, Color{ 255, 255, 255, 255 });
	DrawTextureEx(*r, Vector2{ (t->width + 2) * scale, (d->height + 2) * scale }, 0, scale, Color{ 255, 255, 255, 255 });
	DrawTextureEx(*f, Vector2{ 0, (d->height + d->height + 2) * scale },          0, scale, Color{ 255, 255, 255, 255 });
	
	BeginMode3D(g_camera);

	g_shapeTable[m_currentShape][m_currentFrame].Draw(g_camera.target, g_cameraRotation);

	EndMode3D();
	
	DrawConsole();

	int yOffset = g_smallFontSize;
	int y = -yOffset;

	m_gui->Draw();

	DrawTexture(*g_Cursor, GetMouseX(), GetMouseY(), WHITE);

	EndDrawing();
}
