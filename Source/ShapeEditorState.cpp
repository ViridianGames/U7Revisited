#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/StateMachine.h"
#include "Geist/ResourceManager.h"
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

	ChangeGui(m_bboardGui.get());
}

void ShapeEditorState::ChangeGui(Gui* newGui)
{
	m_bboardGui->m_Active = false;
	m_flatGui->m_Active = false;
	m_cuboidGui->m_Active = false;
	m_meshGui->m_Active = false;
	m_characterGui->m_Active = false;

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
	case ShapeDrawType::OBJECT_DRAW_CHARACTER:
		ChangeGui(m_characterGui.get());
		break;
	}
}

void ShapeEditorState::SetupBboardGui()
{
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_bboardGui = make_unique<Gui>();

	m_bboardGui->m_Font = g_Font;
	m_bboardGui->m_Pos = Vector2{ 480 * g_DrawScale, 0 };
	m_bboardGui->SetLayout(GetRenderWidth() - 120 * g_DrawScale, 0, 120, 360, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_bboardGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int yoffset = 15;
	int y = 4;

	m_bboardGui->AddTextButton(GE_SAVEBUTTON, 8, y, "Save", g_Font.get());
	m_bboardGui->AddTextButton(GE_LOADBUTTON, 60, y, "Load", g_Font.get());
	y += yoffset;

	m_bboardGui->AddIconButton(GE_PREVSHAPEBUTTON, 4, y, g_LeftArrow);
	m_bboardGui->AddIconButton(GE_NEXTSHAPEBUTTON, 45, y, g_RightArrow);
	m_bboardGui->AddTextArea(GE_CURRENTSHAPEIDTEXTAREA, g_Font.get(), "Shape: " + to_string(m_currentShape), 15, y);

	m_bboardGui->AddIconButton(GE_PREVFRAMEBUTTON, 55, y, g_LeftArrow);
	m_bboardGui->AddIconButton(GE_NEXTFRAMEBUTTON, 90, y, g_RightArrow);
	m_bboardGui->AddTextArea(GE_CURRENTFRAMEIDTEXTAREA, g_Font.get(), "Frame: " + to_string(m_currentFrame), 65, y);

	y += yoffset;

	m_bboardGui->AddTextArea(GE_DRAWTYPELABEL, g_Font.get(), "DrawType: ", 2, y);
	m_bboardGui->AddIconButton(GE_PREVDRAWTYPE, 55, y, g_LeftArrow);
	m_bboardGui->AddIconButton(GE_NEXTDRAWTYPE, 90, y, g_RightArrow);
	m_bboardGui->AddTextArea(GE_CURRENTDRAWTYPETEXTAREA, g_Font.get(), "BBoard", 65, y);

	y += yoffset;
	m_bboardGui->AddTextArea(GE_TWEAKPOSITIONTEXTAREA, g_Font.get(), "Tweak Pos: ", 2, y);
	m_bboardGui->AddTextArea(GE_TWEAKDIMENSIONSTEXTAREA, g_Font.get(), "Tweak Dims: ", 62, y);

	y += yoffset * .7f;

	m_bboardGui->AddIconButton(GE_TWEAKXPLUSBUTTON, 2, y, g_LeftArrow);
	m_bboardGui->AddTextArea(GE_TWEAKXTEXTAREA, g_Font.get(), "X:" + to_string(shapeData.m_topTextureWidth), 11, y);
	m_bboardGui->AddIconButton(GE_TWEAKXMINUSBUTTON, 50, y, g_RightArrow);

	std::ostringstream out;

	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.x;
	m_bboardGui->AddIconButton(GE_TWEAKWIDTHPLUSBUTTON, 62, y, g_LeftArrow);
	m_bboardGui->AddTextArea(GE_TWEAKWIDTHTEXTAREA, g_Font.get(), "W:" + out.str(), 71, y);
	m_bboardGui->AddIconButton(GE_TWEAKWIDTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;

	m_bboardGui->AddIconButton(GE_TWEAKYPLUSBUTTON, 2, y, g_LeftArrow);
	m_bboardGui->AddTextArea(GE_TWEAKYTEXTAREA, g_Font.get(), "Y:" + to_string(shapeData.m_topTextureHeight), 11, y);
	m_bboardGui->AddIconButton(GE_TWEAKYMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.y;
	m_bboardGui->AddIconButton(GE_TWEAKHEIGHTPLUSBUTTON, 62, y, g_LeftArrow);
	m_bboardGui->AddTextArea(GE_TWEAKHEIGHTTEXTAREA, g_Font.get(), "H:" + out.str(), 71, y);
	m_bboardGui->AddIconButton(GE_TWEAKHEIGHTMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;


	m_bboardGui->AddIconButton(GE_TWEAKZPLUSBUTTON, 2, y, g_LeftArrow);
	m_bboardGui->AddTextArea(GE_TWEAKZTEXTAREA, g_Font.get(), "Z:" + to_string(shapeData.m_topTextureHeight), 11, y);
	m_bboardGui->AddIconButton(GE_TWEAKZMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.z;
	m_bboardGui->AddIconButton(GE_TWEAKDEPTHPLUSBUTTON, 62, y, g_LeftArrow);
	m_bboardGui->AddTextArea(GE_TWEAKDEPTHTEXTAREA, g_Font.get(), "D:" + out.str(), 71, y);
	m_bboardGui->AddIconButton(GE_TWEAKDEPTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_rotation;
	m_bboardGui->AddTextArea(GE_TWEAKROTATIONTITLEAREA, g_Font.get(), "Tweak Rotation:", 2, y);
	m_bboardGui->AddIconButton(GE_TWEAKROTATIONPLUSBUTTON, 62, y, g_LeftArrow, g_LeftArrow, g_LeftArrow, "", g_Font.get(), Color{ 255, 255, 255, 255 }, 0, 1, true);
	m_bboardGui->AddTextArea(GE_TWEAKROTATIONTEXTAREA, g_Font.get(), out.str(), 71, y);
	m_bboardGui->AddIconButton(GE_TWEAKROTATIONMINUSBUTTON, 110, y, g_RightArrow);

}

void ShapeEditorState::SetupFlatGui()
{
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_flatGui = make_unique<Gui>();

	m_flatGui->m_Font = g_Font;
	m_flatGui->m_Pos = Vector2{ 480 * g_DrawScale, 0 };
	m_flatGui->SetLayout(GetRenderWidth() - 120 * g_DrawScale, 0, 120, 360, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_flatGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int yoffset = 15;
	int y = 4;

	m_flatGui->AddTextButton(GE_SAVEBUTTON, 8, y, "Save", g_Font.get());
	m_flatGui->AddTextButton(GE_LOADBUTTON, 60, y, "Load", g_Font.get());
	y += yoffset;

	m_flatGui->AddIconButton(GE_PREVSHAPEBUTTON, 4, y, g_LeftArrow);
	m_flatGui->AddIconButton(GE_NEXTSHAPEBUTTON, 45, y, g_RightArrow);
	m_flatGui->AddTextArea(GE_CURRENTSHAPEIDTEXTAREA, g_Font.get(), "Shape: " + to_string(m_currentShape), 15, y);

	m_flatGui->AddIconButton(GE_PREVFRAMEBUTTON, 55, y, g_LeftArrow);
	m_flatGui->AddIconButton(GE_NEXTFRAMEBUTTON, 90, y, g_RightArrow);
	m_flatGui->AddTextArea(GE_CURRENTFRAMEIDTEXTAREA, g_Font.get(), "Frame: " + to_string(m_currentFrame), 65, y);

	y += yoffset;

	m_flatGui->AddTextArea(GE_DRAWTYPELABEL, g_Font.get(), "DrawType: ", 2, y);
	m_flatGui->AddIconButton(GE_PREVDRAWTYPE, 55, y, g_LeftArrow);
	m_flatGui->AddIconButton(GE_NEXTDRAWTYPE, 90, y, g_RightArrow);
	m_flatGui->AddTextArea(GE_CURRENTDRAWTYPETEXTAREA, g_Font.get(), "Flat", 65, y);

	y += yoffset;
	m_flatGui->AddTextArea(GE_TWEAKPOSITIONTEXTAREA, g_Font.get(), "Tweak Pos: ", 2, y);
	m_flatGui->AddTextArea(GE_TWEAKDIMENSIONSTEXTAREA, g_Font.get(), "Tweak Dims: ", 62, y);

	y += yoffset * .7f;

	m_flatGui->AddIconButton(GE_TWEAKXPLUSBUTTON, 2, y, g_LeftArrow);
	m_flatGui->AddTextArea(GE_TWEAKXTEXTAREA, g_Font.get(), "X:" + to_string(shapeData.m_topTextureWidth), 11, y);
	m_flatGui->AddIconButton(GE_TWEAKXMINUSBUTTON, 50, y, g_RightArrow);

	std::ostringstream out;

	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.x;
	m_flatGui->AddIconButton(GE_TWEAKWIDTHPLUSBUTTON, 62, y, g_LeftArrow);
	m_flatGui->AddTextArea(GE_TWEAKWIDTHTEXTAREA, g_Font.get(), "W:" + out.str(), 71, y);
	m_flatGui->AddIconButton(GE_TWEAKWIDTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;

	m_flatGui->AddIconButton(GE_TWEAKYPLUSBUTTON, 2, y, g_LeftArrow);
	m_flatGui->AddTextArea(GE_TWEAKYTEXTAREA, g_Font.get(), "Y:" + to_string(shapeData.m_topTextureHeight), 11, y);
	m_flatGui->AddIconButton(GE_TWEAKYMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.y;
	m_flatGui->AddIconButton(GE_TWEAKHEIGHTPLUSBUTTON, 62, y, g_LeftArrow);
	m_flatGui->AddTextArea(GE_TWEAKHEIGHTTEXTAREA, g_Font.get(), "H:" + out.str(), 71, y);
	m_flatGui->AddIconButton(GE_TWEAKHEIGHTMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;


	m_flatGui->AddIconButton(GE_TWEAKZPLUSBUTTON, 2, y, g_LeftArrow);
	m_flatGui->AddTextArea(GE_TWEAKZTEXTAREA, g_Font.get(), "Z:" + to_string(shapeData.m_topTextureHeight), 11, y);
	m_flatGui->AddIconButton(GE_TWEAKZMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.z;
	m_flatGui->AddIconButton(GE_TWEAKDEPTHPLUSBUTTON, 62, y, g_LeftArrow);
	m_flatGui->AddTextArea(GE_TWEAKDEPTHTEXTAREA, g_Font.get(), "D:" + out.str(), 71, y);
	m_flatGui->AddIconButton(GE_TWEAKDEPTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_rotation;
	m_flatGui->AddTextArea(GE_TWEAKROTATIONTITLEAREA, g_Font.get(), "Tweak Rotation:", 2, y);
	m_flatGui->AddIconButton(GE_TWEAKROTATIONPLUSBUTTON, 62, y, g_LeftArrow, g_LeftArrow, g_LeftArrow, "", g_Font.get(), Color{ 255, 255, 255, 255 }, 0, 1, true);
	m_flatGui->AddTextArea(GE_TWEAKROTATIONTEXTAREA, g_Font.get(), out.str(), 71, y);
	m_flatGui->AddIconButton(GE_TWEAKROTATIONMINUSBUTTON, 110, y, g_RightArrow);
}

void ShapeEditorState::SetupCuboidGui()
{
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_cuboidGui = make_unique<Gui>();

	m_cuboidGui->m_Font = g_Font;
	m_cuboidGui->m_Pos = Vector2{ 480 * g_DrawScale, 0 };
	m_cuboidGui->SetLayout(GetRenderWidth() - 120 * g_DrawScale, 0, 120, 360, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_cuboidGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int yoffset = 15;
	int y = 4;

	m_cuboidGui->AddTextButton(GE_SAVEBUTTON, 8, y, "Save", g_Font.get());
	m_cuboidGui->AddTextButton(GE_LOADBUTTON, 60, y, "Load", g_Font.get());
	y += yoffset;

	m_cuboidGui->AddIconButton(GE_PREVSHAPEBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_NEXTSHAPEBUTTON, 45, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_CURRENTSHAPEIDTEXTAREA, g_Font.get(), "Shape: " + to_string(m_currentShape), 15, y);

	m_cuboidGui->AddIconButton(GE_PREVFRAMEBUTTON, 55, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_NEXTFRAMEBUTTON, 90, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_CURRENTFRAMEIDTEXTAREA, g_Font.get(), "Frame: " + to_string(m_currentFrame), 65, y);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_DRAWTYPELABEL, g_Font.get(), "DrawType: ", 2, y);
	m_cuboidGui->AddIconButton(GE_PREVDRAWTYPE, 55, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_NEXTDRAWTYPE, 90, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_CURRENTDRAWTYPETEXTAREA, g_Font.get(), "Cuboid", 65, y);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_TOPTEXTAREA, g_Font.get(), "Top Face", 3, y);
	m_cuboidGui->AddTextButton(GE_TOPRESET, 60, y, "Reset", g_Font.get());
	y += yoffset * .8f;

	m_cuboidGui->AddIconButton(GE_TOPXMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPXPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPXTEXTAREA, g_Font.get(), "X: " + to_string(shapeData.m_topTextureOffsetX), 14, y);

	m_cuboidGui->AddIconButton(GE_TOPYMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPYPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPYTEXTAREA, g_Font.get(), "Y: " + to_string(shapeData.m_topTextureOffsetY), 55, y);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_TOPWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPWIDTHTEXTAREA, g_Font.get(), "W: " + to_string(shapeData.m_topTextureWidth), 14, y);

	m_cuboidGui->AddIconButton(GE_TOPHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_TOPHEIGHTPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_TOPHEIGHTTEXTAREA, g_Font.get(), "H: " + to_string(shapeData.m_topTextureHeight), 55, y);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_FRONTTEXTAREA, g_Font.get(), "Front Face", 3, y);
	m_cuboidGui->AddTextButton(GE_FRONTRESET, 60, y, "Reset", g_Font.get());
	y += yoffset * .8f;

	m_cuboidGui->AddIconButton(GE_FRONTXMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTXPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTXTEXTAREA, g_Font.get(), "X: " + to_string(shapeData.m_topTextureOffsetX), 14, y);

	m_cuboidGui->AddIconButton(GE_FRONTYMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTYPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTYTEXTAREA, g_Font.get(), "Y: " + to_string(shapeData.m_topTextureOffsetY), 55, y);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_FRONTWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTWIDTHTEXTAREA, g_Font.get(), "W: " + to_string(shapeData.m_topTextureWidth), 14, y);

	m_cuboidGui->AddIconButton(GE_FRONTHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_FRONTHEIGHTPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_FRONTHEIGHTTEXTAREA, g_Font.get(), "H: " + to_string(shapeData.m_topTextureHeight), 55, y);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_RIGHTTEXTAREA, g_Font.get(), "Right Face", 3, y);
	m_cuboidGui->AddTextButton(GE_RIGHTRESET, 60, y, "Reset", g_Font.get());
	y += yoffset * .8f;

	m_cuboidGui->AddIconButton(GE_RIGHTXMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTXPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTXTEXTAREA, g_Font.get(), "X: " + to_string(shapeData.m_topTextureOffsetX), 14, y);

	m_cuboidGui->AddIconButton(GE_RIGHTYMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTYPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTYTEXTAREA, g_Font.get(), "Y: " + to_string(shapeData.m_topTextureOffsetY), 55, y);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_RIGHTWIDTHMINUSBUTTON, 4, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTWIDTHPLUSBUTTON, 35, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTWIDTHTEXTAREA, g_Font.get(), "W: " + to_string(shapeData.m_topTextureWidth), 14, y);

	m_cuboidGui->AddIconButton(GE_RIGHTHEIGHTMINUSBUTTON, 45, y, g_LeftArrow);
	m_cuboidGui->AddIconButton(GE_RIGHTHEIGHTPLUSBUTTON, 80, y, g_RightArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTHEIGHTTEXTAREA, g_Font.get(), "H: " + to_string(shapeData.m_topTextureHeight), 55, y);

	y += yoffset;
	m_cuboidGui->AddTextArea(GE_TWEAKPOSITIONTEXTAREA, g_Font.get(), "Tweak Pos: ", 2, y);
	m_cuboidGui->AddTextArea(GE_TWEAKDIMENSIONSTEXTAREA, g_Font.get(), "Tweak Dims: ", 62, y);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_TWEAKXPLUSBUTTON, 2, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_TWEAKXTEXTAREA, g_Font.get(), "X:" + to_string(shapeData.m_topTextureWidth), 11, y);
	m_cuboidGui->AddIconButton(GE_TWEAKXMINUSBUTTON, 50, y, g_RightArrow);

	std::ostringstream out;

	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.x;
	m_cuboidGui->AddIconButton(GE_TWEAKWIDTHPLUSBUTTON, 62, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_TWEAKWIDTHTEXTAREA, g_Font.get(), "W:" + out.str(), 71, y);
	m_cuboidGui->AddIconButton(GE_TWEAKWIDTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;

	m_cuboidGui->AddIconButton(GE_TWEAKYPLUSBUTTON, 2, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_TWEAKYTEXTAREA, g_Font.get(), "Y:" + to_string(shapeData.m_topTextureHeight), 11, y);
	m_cuboidGui->AddIconButton(GE_TWEAKYMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.y;
	m_cuboidGui->AddIconButton(GE_TWEAKHEIGHTPLUSBUTTON, 62, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_TWEAKHEIGHTTEXTAREA, g_Font.get(), "H:" + out.str(), 71, y);
	m_cuboidGui->AddIconButton(GE_TWEAKHEIGHTMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;


	m_cuboidGui->AddIconButton(GE_TWEAKZPLUSBUTTON, 2, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_TWEAKZTEXTAREA, g_Font.get(), "Z:" + to_string(shapeData.m_topTextureHeight), 11, y);
	m_cuboidGui->AddIconButton(GE_TWEAKZMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.z;
	m_cuboidGui->AddIconButton(GE_TWEAKDEPTHPLUSBUTTON, 62, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_TWEAKDEPTHTEXTAREA, g_Font.get(), "D:" + out.str(), 71, y);
	m_cuboidGui->AddIconButton(GE_TWEAKDEPTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_rotation;
	m_cuboidGui->AddTextArea(GE_TWEAKROTATIONTITLEAREA, g_Font.get(), "Tweak Rotation:", 2, y);
	m_cuboidGui->AddIconButton(GE_TWEAKROTATIONPLUSBUTTON, 62, y, g_LeftArrow, g_LeftArrow, g_LeftArrow, "", g_Font.get(), Color{ 255, 255, 255, 255 }, 0, 1, true);
	m_cuboidGui->AddTextArea(GE_TWEAKROTATIONTEXTAREA, g_Font.get(), out.str(), 71, y);
	m_cuboidGui->AddIconButton(GE_TWEAKROTATIONMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	m_cuboidGui->AddTextArea(GE_TEXTUREASSIGNMENTTEXTAREA, g_Font.get(), "Texture Assignment:", 2, y);

	y += yoffset * .7f;

	m_cuboidGui->AddTextArea(GE_TOPSIDETEXTAREA, g_Font.get(), "Top", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVTOPBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_TOPSIDETEXTURETEXTAREA, g_Font.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTTOPBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_FRONTSIDETEXTAREA, g_Font.get(), "Front", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVFRONTBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_FRONTSIDETEXTURETEXTAREA, g_Font.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTFRONTBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_RIGHTSIDETEXTAREA, g_Font.get(), "Right", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVRIGHTBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_RIGHTSIDETEXTURETEXTAREA, g_Font.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTRIGHTBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_BOTTOMSIDETEXTAREA, g_Font.get(), "Bottom", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVBOTTOMBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_BOTTOMSIDETEXTURETEXTAREA, g_Font.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTBOTTOMBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_BACKSIDETEXTAREA, g_Font.get(), "Back", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVBACKBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_BACKSIDETEXTURETEXTAREA, g_Font.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTBACKBUTTON, 95, y, g_RightArrow);
	y += yoffset * .8f;

	m_cuboidGui->AddTextArea(GE_LEFTSIDETEXTAREA, g_Font.get(), "Left", 3, y);
	m_cuboidGui->AddIconButton(GE_PREVLEFTBUTTON, 40, y, g_LeftArrow);
	m_cuboidGui->AddTextArea(GE_LEFTSIDETEXTURETEXTAREA, g_Font.get(), m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT))], 50, y);
	m_cuboidGui->AddIconButton(GE_NEXTLEFTBUTTON, 95, y, g_RightArrow);
}

void ShapeEditorState::SetupMeshGui()
{
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_meshGui = make_unique<Gui>();

	m_meshGui->m_Font = g_Font;
	m_meshGui->m_Pos = Vector2{ 480 * g_DrawScale, 0 };
	m_meshGui->SetLayout(GetRenderWidth() - 120 * g_DrawScale, 0, 120, 360, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_meshGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int yoffset = 15;
	int y = 4;

	m_meshGui->AddTextButton(GE_SAVEBUTTON, 8, y, "Save", g_Font.get());
	m_meshGui->AddTextButton(GE_LOADBUTTON, 60, y, "Load", g_Font.get());
	y += yoffset;

	m_meshGui->AddIconButton(GE_PREVSHAPEBUTTON, 4, y, g_LeftArrow);
	m_meshGui->AddIconButton(GE_NEXTSHAPEBUTTON, 45, y, g_RightArrow);
	m_meshGui->AddTextArea(GE_CURRENTSHAPEIDTEXTAREA, g_Font.get(), "Shape: " + to_string(m_currentShape), 15, y);

	m_meshGui->AddIconButton(GE_PREVFRAMEBUTTON, 55, y, g_LeftArrow);
	m_meshGui->AddIconButton(GE_NEXTFRAMEBUTTON, 90, y, g_RightArrow);
	m_meshGui->AddTextArea(GE_CURRENTFRAMEIDTEXTAREA, g_Font.get(), "Frame: " + to_string(m_currentFrame), 65, y);

	y += yoffset;

	m_meshGui->AddTextArea(GE_DRAWTYPELABEL, g_Font.get(), "DrawType: ", 2, y);
	m_meshGui->AddIconButton(GE_PREVDRAWTYPE, 55, y, g_LeftArrow);
	m_meshGui->AddIconButton(GE_NEXTDRAWTYPE, 90, y, g_RightArrow);
	m_meshGui->AddTextArea(GE_CURRENTDRAWTYPETEXTAREA, g_Font.get(), "Mesh", 65, y);

	y += yoffset;

	m_meshGui->AddIconButton(GE_PREVMODELBUTTON, 4, y, g_LeftArrow);
	m_meshGui->AddTextArea(GE_MODELNAMETEXTAREA, g_Font.get(), "Model: " + shapeData.m_customMeshName, 12, y);
	m_meshGui->AddIconButton(GE_NEXTMODELBUTTON, 88, y, g_RightArrow);

	y += yoffset;

	m_meshGui->AddCheckBox(GE_MESHOUTLINECHECKBOX, 4, y, 16, 16);
	m_meshGui->GetElement(GE_MESHOUTLINECHECKBOX)->m_Selected = shapeData.m_meshOutline;
	m_meshGui->AddTextArea(GE_MESHOUTLINETEXTAREA, g_Font.get(), "Use Mesh Outline", 22, y);

	y += yoffset;
	m_meshGui->AddTextArea(GE_TWEAKPOSITIONTEXTAREA, g_Font.get(), "Tweak Pos: ", 2, y);
	m_meshGui->AddTextArea(GE_TWEAKDIMENSIONSTEXTAREA, g_Font.get(), "Tweak Dims: ", 62, y);

	y += yoffset * .7f;

	m_meshGui->AddIconButton(GE_TWEAKXPLUSBUTTON, 2, y, g_LeftArrow);
	m_meshGui->AddTextArea(GE_TWEAKXTEXTAREA, g_Font.get(), "X:" + to_string(shapeData.m_topTextureWidth), 11, y);
	m_meshGui->AddIconButton(GE_TWEAKXMINUSBUTTON, 50, y, g_RightArrow);

	std::ostringstream out;

	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.x;
	m_meshGui->AddIconButton(GE_TWEAKWIDTHPLUSBUTTON, 62, y, g_LeftArrow);
	m_meshGui->AddTextArea(GE_TWEAKWIDTHTEXTAREA, g_Font.get(), "W:" + out.str(), 71, y);
	m_meshGui->AddIconButton(GE_TWEAKWIDTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;

	m_meshGui->AddIconButton(GE_TWEAKYPLUSBUTTON, 2, y, g_LeftArrow);
	m_meshGui->AddTextArea(GE_TWEAKYTEXTAREA, g_Font.get(), "Y:" + to_string(shapeData.m_topTextureHeight), 11, y);
	m_meshGui->AddIconButton(GE_TWEAKYMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.y;
	m_meshGui->AddIconButton(GE_TWEAKHEIGHTPLUSBUTTON, 62, y, g_LeftArrow);
	m_meshGui->AddTextArea(GE_TWEAKHEIGHTTEXTAREA, g_Font.get(), "H:" + out.str(), 71, y);
	m_meshGui->AddIconButton(GE_TWEAKHEIGHTMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;


	m_meshGui->AddIconButton(GE_TWEAKZPLUSBUTTON, 2, y, g_LeftArrow);
	m_meshGui->AddTextArea(GE_TWEAKZTEXTAREA, g_Font.get(), "Z:" + to_string(shapeData.m_topTextureHeight), 11, y);
	m_meshGui->AddIconButton(GE_TWEAKZMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.z;
	m_meshGui->AddIconButton(GE_TWEAKDEPTHPLUSBUTTON, 62, y, g_LeftArrow);
	m_meshGui->AddTextArea(GE_TWEAKDEPTHTEXTAREA, g_Font.get(), "D:" + out.str(), 71, y);
	m_meshGui->AddIconButton(GE_TWEAKDEPTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_rotation;
	m_meshGui->AddTextArea(GE_TWEAKROTATIONTITLEAREA, g_Font.get(), "Tweak Rotation:", 2, y);
	m_meshGui->AddIconButton(GE_TWEAKROTATIONPLUSBUTTON, 62, y, g_LeftArrow, g_LeftArrow, g_LeftArrow, "", g_Font.get(), Color{ 255, 255, 255, 255 }, 0, 1, true);
	m_meshGui->AddTextArea(GE_TWEAKROTATIONTEXTAREA, g_Font.get(), out.str(), 71, y);
	m_meshGui->AddIconButton(GE_TWEAKROTATIONMINUSBUTTON, 110, y, g_RightArrow);
}

void ShapeEditorState::SetupCharacterGui()
{
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	m_characterGui = make_unique<Gui>();

	m_characterGui->m_Font = g_Font;
	m_characterGui->m_Pos = Vector2{ 480 * g_DrawScale, 0 };
	m_characterGui->SetLayout(GetRenderWidth() - 120 * g_DrawScale, 0, 120, 360, g_DrawScale, Gui::GUIP_UPPERRIGHT);

	m_characterGui->AddOctagonBox(GE_PANELBORDER, 0, 0, 120, 360, g_Borders);

	int yoffset = 15;
	int y = 4;

	m_characterGui->AddTextButton(GE_SAVEBUTTON, 8, y, "Save", g_Font.get());
	m_characterGui->AddTextButton(GE_LOADBUTTON, 60, y, "Load", g_Font.get());
	y += yoffset;

	m_characterGui->AddIconButton(GE_PREVSHAPEBUTTON, 4, y, g_LeftArrow);
	m_characterGui->AddIconButton(GE_NEXTSHAPEBUTTON, 45, y, g_RightArrow);
	m_characterGui->AddTextArea(GE_CURRENTSHAPEIDTEXTAREA, g_Font.get(), "Shape: " + to_string(m_currentShape), 15, y);

	m_characterGui->AddIconButton(GE_PREVFRAMEBUTTON, 55, y, g_LeftArrow);
	m_characterGui->AddIconButton(GE_NEXTFRAMEBUTTON, 90, y, g_RightArrow);
	m_characterGui->AddTextArea(GE_CURRENTFRAMEIDTEXTAREA, g_Font.get(), "Frame: " + to_string(m_currentFrame), 65, y);

	y += yoffset;

	m_characterGui->AddTextArea(GE_DRAWTYPELABEL, g_Font.get(), "DrawType: ", 2, y);
	m_characterGui->AddIconButton(GE_PREVDRAWTYPE, 55, y, g_LeftArrow);
	m_characterGui->AddIconButton(GE_NEXTDRAWTYPE, 90, y, g_RightArrow);
	m_characterGui->AddTextArea(GE_CURRENTDRAWTYPETEXTAREA, g_Font.get(), "Character", 65, y);

	y += yoffset;
	m_characterGui->AddTextArea(GE_TWEAKPOSITIONTEXTAREA, g_Font.get(), "Tweak Pos: ", 2, y);
	m_characterGui->AddTextArea(GE_TWEAKDIMENSIONSTEXTAREA, g_Font.get(), "Tweak Dims: ", 62, y);

	y += yoffset * .7f;

	m_characterGui->AddIconButton(GE_TWEAKXPLUSBUTTON, 2, y, g_LeftArrow);
	m_characterGui->AddTextArea(GE_TWEAKXTEXTAREA, g_Font.get(), "X:" + to_string(shapeData.m_topTextureWidth), 11, y);
	m_characterGui->AddIconButton(GE_TWEAKXMINUSBUTTON, 50, y, g_RightArrow);

	std::ostringstream out;

	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.x;
	m_characterGui->AddIconButton(GE_TWEAKWIDTHPLUSBUTTON, 62, y, g_LeftArrow);
	m_characterGui->AddTextArea(GE_TWEAKWIDTHTEXTAREA, g_Font.get(), "W:" + out.str(), 71, y);
	m_characterGui->AddIconButton(GE_TWEAKWIDTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;

	m_characterGui->AddIconButton(GE_TWEAKYPLUSBUTTON, 2, y, g_LeftArrow);
	m_characterGui->AddTextArea(GE_TWEAKYTEXTAREA, g_Font.get(), "Y:" + to_string(shapeData.m_topTextureHeight), 11, y);
	m_characterGui->AddIconButton(GE_TWEAKYMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.y;
	m_characterGui->AddIconButton(GE_TWEAKHEIGHTPLUSBUTTON, 62, y, g_LeftArrow);
	m_characterGui->AddTextArea(GE_TWEAKHEIGHTTEXTAREA, g_Font.get(), "H:" + out.str(), 71, y);
	m_characterGui->AddIconButton(GE_TWEAKHEIGHTMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset * .7f;


	m_characterGui->AddIconButton(GE_TWEAKZPLUSBUTTON, 2, y, g_LeftArrow);
	m_characterGui->AddTextArea(GE_TWEAKZTEXTAREA, g_Font.get(), "Z:" + to_string(shapeData.m_topTextureHeight), 11, y);
	m_characterGui->AddIconButton(GE_TWEAKZMINUSBUTTON, 50, y, g_RightArrow);

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.z;
	m_characterGui->AddIconButton(GE_TWEAKDEPTHPLUSBUTTON, 62, y, g_LeftArrow);
	m_characterGui->AddTextArea(GE_TWEAKDEPTHTEXTAREA, g_Font.get(), "D:" + out.str(), 71, y);
	m_characterGui->AddIconButton(GE_TWEAKDEPTHMINUSBUTTON, 110, y, g_RightArrow);

	y += yoffset;

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_rotation;
	m_characterGui->AddTextArea(GE_TWEAKROTATIONTITLEAREA, g_Font.get(), "Tweak Rotation:", 2, y);
	m_characterGui->AddIconButton(GE_TWEAKROTATIONPLUSBUTTON, 62, y, g_LeftArrow, g_LeftArrow, g_LeftArrow, "", g_Font.get(), Color{ 255, 255, 255, 255 }, 0, 1, true);
	m_characterGui->AddTextArea(GE_TWEAKROTATIONTEXTAREA, g_Font.get(), out.str(), 71, y);
	m_characterGui->AddIconButton(GE_TWEAKROTATIONMINUSBUTTON, 110, y, g_RightArrow);
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

	SwitchToGuiForDrawType(shapeData.m_drawType);
}

void ShapeEditorState::OnExit()
{

}

void ShapeEditorState::Shutdown()
{

}

void ShapeEditorState::Update()
{
	//  Handle input
	m_currentGui->Update();
	ShapeData& shapeData = g_shapeTable[m_currentShape][m_currentFrame];

	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
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


	if (IsKeyPressed(KEY_A) || m_currentGui->GetActiveElementID() == GE_PREVSHAPEBUTTON)
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

	if (IsKeyPressed(KEY_D) || m_currentGui->GetActiveElementID() == GE_NEXTSHAPEBUTTON)
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

	if (IsKeyPressed(KEY_W) || m_currentGui->GetActiveElementID() == GE_NEXTFRAMEBUTTON)
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

	if (IsKeyPressed(KEY_S) || m_currentGui->GetActiveElementID() == GE_PREVFRAMEBUTTON)
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

	if (IsKeyPressed(KEY_F1))
	{
		g_StateMachine->MakeStateTransition(STATE_MAINSTATE);
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

	if (m_currentGui->GetActiveElementID() == GE_TOPXMINUSBUTTON)
	{
		if (shapeData.m_topTextureOffsetX + shapeData.m_topTextureWidth - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureOffsetX--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPXPLUSBUTTON)
	{
		if (shapeData.m_topTextureOffsetX + shapeData.m_topTextureWidth < shapeData.m_originalTexture->width)
		{
			somethingChanged = true; shapeData.m_topTextureOffsetX++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPYMINUSBUTTON)
	{
		if (shapeData.m_topTextureOffsetY + shapeData.m_topTextureHeight >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureOffsetY--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPYPLUSBUTTON)
	{
		if (shapeData.m_topTextureOffsetY + shapeData.m_topTextureHeight < shapeData.m_originalTexture->height)
		{
			somethingChanged = true; shapeData.m_topTextureOffsetY++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPWIDTHMINUSBUTTON)
	{
		if (shapeData.m_topTextureOffsetX + shapeData.m_topTextureWidth >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureWidth--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPWIDTHPLUSBUTTON)
	{
		if (shapeData.m_topTextureOffsetX + shapeData.m_topTextureWidth <= shapeData.m_originalTexture->width)
		{
			somethingChanged = true; shapeData.m_topTextureWidth++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPHEIGHTMINUSBUTTON)
	{
		if (shapeData.m_topTextureOffsetY + shapeData.m_topTextureHeight >= 0)
		{
			somethingChanged = true; shapeData.m_topTextureHeight--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_TOPHEIGHTPLUSBUTTON)
	{
		if (shapeData.m_topTextureOffsetY + shapeData.m_topTextureHeight < shapeData.m_originalTexture->height)
		{
			somethingChanged = true; shapeData.m_topTextureHeight++;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_FRONTXMINUSBUTTON)
	{
		if (shapeData.m_frontTextureOffsetX + shapeData.m_frontTextureWidth - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureOffsetX--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTXPLUSBUTTON)
	{
		if (shapeData.m_frontTextureOffsetX + shapeData.m_frontTextureWidth + 1 < shapeData.m_originalTexture->width)
		{
			somethingChanged = true; shapeData.m_frontTextureOffsetX++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTYMINUSBUTTON)
	{
		if (shapeData.m_frontTextureOffsetY + shapeData.m_frontTextureHeight - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureOffsetY--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTYPLUSBUTTON)
	{
		if (shapeData.m_frontTextureOffsetY + shapeData.m_frontTextureHeight < shapeData.m_originalTexture->height)
		{
			somethingChanged = true; shapeData.m_frontTextureOffsetY++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTWIDTHMINUSBUTTON)
	{
		if (shapeData.m_frontTextureOffsetX + shapeData.m_frontTextureWidth >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureWidth--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTWIDTHPLUSBUTTON)
	{
		if (shapeData.m_frontTextureOffsetX + shapeData.m_frontTextureWidth < shapeData.m_originalTexture->width)
		{
			somethingChanged = true; shapeData.m_frontTextureWidth++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTHEIGHTMINUSBUTTON)
	{
		if (shapeData.m_frontTextureOffsetY + shapeData.m_frontTextureHeight >= 0)
		{
			somethingChanged = true; shapeData.m_frontTextureHeight--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_FRONTHEIGHTPLUSBUTTON)
	{
		if (shapeData.m_frontTextureOffsetY + shapeData.m_frontTextureHeight < shapeData.m_originalTexture->height)
		{
			somethingChanged = true; shapeData.m_frontTextureHeight++;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_RIGHTXMINUSBUTTON)
	{
		if (shapeData.m_rightTextureOffsetX + shapeData.m_rightTextureWidth - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureOffsetX--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTXPLUSBUTTON)
	{
		if (shapeData.m_rightTextureOffsetX + shapeData.m_rightTextureWidth + 1 < shapeData.m_originalTexture->width)
		{
			somethingChanged = true; shapeData.m_rightTextureOffsetX++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTYMINUSBUTTON)
	{
		if (shapeData.m_rightTextureOffsetY + shapeData.m_rightTextureHeight - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureOffsetY--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTYPLUSBUTTON)
	{
		if (shapeData.m_rightTextureOffsetY + shapeData.m_rightTextureHeight + 1 < shapeData.m_originalTexture->height)
		{
			somethingChanged = true; shapeData.m_rightTextureOffsetY++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTWIDTHMINUSBUTTON)
	{
		if (shapeData.m_rightTextureOffsetX + shapeData.m_rightTextureWidth - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureWidth--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTWIDTHPLUSBUTTON)
	{
		if (shapeData.m_rightTextureOffsetX + shapeData.m_rightTextureWidth + 1 < shapeData.m_originalTexture->width)
		{
			somethingChanged = true; shapeData.m_rightTextureWidth++;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTHEIGHTMINUSBUTTON)
	{
		if (shapeData.m_rightTextureOffsetY + shapeData.m_rightTextureHeight - 1 >= 0)
		{
			somethingChanged = true; shapeData.m_rightTextureHeight--;
		}
	}
	if (m_currentGui->GetActiveElementID() == GE_RIGHTHEIGHTPLUSBUTTON)
	{
		if (shapeData.m_rightTextureOffsetY + shapeData.m_rightTextureHeight + 1 < shapeData.m_originalTexture->height)
		{
			somethingChanged = true; shapeData.m_rightTextureHeight++;
		}
	}

	if (m_currentGui->GetActiveElementID() == GE_TOPRESET) { somethingChanged = true; shapeData.ResetTopTexture(); }
	if (m_currentGui->GetActiveElementID() == GE_FRONTRESET) { somethingChanged = true; shapeData.ResetFrontTexture(); }
	if (m_currentGui->GetActiveElementID() == GE_RIGHTRESET) { somethingChanged = true; shapeData.ResetRightTexture(); }

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
		shapeData.m_Scaling.x -= .1f;
		if(shapeData.m_Scaling.x < -9.9f) shapeData.m_Scaling.x = -9.9f;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKWIDTHMINUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_Scaling.x += .1f;
		if (shapeData.m_Scaling.x > 9.9) shapeData.m_Scaling.x = 9.9;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKHEIGHTMINUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_Scaling.y += .1f;
		if (shapeData.m_Scaling.y > 9.9) shapeData.m_Scaling.y = 9.9;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKHEIGHTPLUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_Scaling.y -= .1f;
		if (shapeData.m_Scaling.y < -9.9f) shapeData.m_Scaling.y = 9.9f;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKDEPTHMINUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_Scaling.z += .1f;
		if (shapeData.m_Scaling.z < 0) shapeData.m_Scaling.z = 0;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKDEPTHPLUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_Scaling.z -= .1f;
		if (shapeData.m_Scaling.z < -9.9) shapeData.m_Scaling.z = -9.9;
	}

	//  Tweak Position
		if (m_currentGui->GetActiveElementID() == GE_TWEAKXPLUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_TweakPos.x -= .1f;
		if(shapeData.m_TweakPos.x < -9.9) shapeData.m_TweakPos.x = -9.9;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKXMINUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_TweakPos.x += .1f;
		if (shapeData.m_TweakPos.x > 9.9) shapeData.m_TweakPos.x = 9.9;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKYMINUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_TweakPos.y += .1f;
		if (shapeData.m_TweakPos.y > 9.9) shapeData.m_TweakPos.y = 9.9;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKYPLUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_TweakPos.y -= .1f;
		if (shapeData.m_TweakPos.y < -9.9) shapeData.m_TweakPos.y = -9.9;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKZMINUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_TweakPos.z += .1f;
		if (shapeData.m_TweakPos.z > 9.9) shapeData.m_TweakPos.z = 9.9;
	}

	if (m_currentGui->GetActiveElementID() == GE_TWEAKZPLUSBUTTON)
	{
		somethingChanged = true;
		shapeData.m_TweakPos.z -= .1f;
		if (shapeData.m_TweakPos.z < -9.9) shapeData.m_TweakPos.z = -9.9;
	}

	if (m_currentGui->GetActiveElementID() == GE_MESHOUTLINECHECKBOX)
	{
		somethingChanged = true;
		shapeData.m_meshOutline = m_currentGui->GetActiveElement()->m_Selected;
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
		m_modelIndex++;
		if (m_modelIndex == g_ResourceManager->m_ModelList.end())
		{
			m_modelIndex = g_ResourceManager->m_ModelList.begin();
		}
		g_shapeTable[m_currentShape][m_currentFrame].m_customMesh = (*m_modelIndex).second.get();
		g_shapeTable[m_currentShape][m_currentFrame].m_customMeshName = (*m_modelIndex).first;
	}

	if (m_currentGui->GetActiveElementID() == GE_PREVMODELBUTTON)
	{
		if (m_modelIndex != g_ResourceManager->m_ModelList.begin())
		{
			m_modelIndex--;
			g_shapeTable[m_currentShape][m_currentFrame].m_customMeshName = (*m_modelIndex).first;
			g_shapeTable[m_currentShape][m_currentFrame].m_customMesh = (*m_modelIndex).second.get();
		}
		else
		{
			m_modelIndex = g_ResourceManager->m_ModelList.end();
			m_modelIndex--;
			g_shapeTable[m_currentShape][m_currentFrame].m_customMeshName = (*m_modelIndex).first;
			g_shapeTable[m_currentShape][m_currentFrame].m_customMesh = (*m_modelIndex).second.get();
		}
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
	m_currentGui->GetElement(GE_CURRENTSHAPEIDTEXTAREA)->m_String = "S:" + to_string(m_currentShape);
	m_currentGui->GetElement(GE_CURRENTFRAMEIDTEXTAREA)->m_String = "F:" + to_string(m_currentFrame);
	
	if (m_currentGui == m_cuboidGui.get())
	{

		m_currentGui->GetElement(GE_TOPXTEXTAREA)->m_String = "X:" + to_string(shapeData.m_topTextureOffsetX);
		m_currentGui->GetElement(GE_FRONTXTEXTAREA)->m_String = "X:" + to_string(shapeData.m_frontTextureOffsetX);
		m_currentGui->GetElement(GE_RIGHTXTEXTAREA)->m_String = "X:" + to_string(shapeData.m_rightTextureOffsetX);

		m_currentGui->GetElement(GE_TOPYTEXTAREA)->m_String = "Y:" + to_string(shapeData.m_topTextureOffsetY);
		m_currentGui->GetElement(GE_FRONTYTEXTAREA)->m_String = "Y:" + to_string(shapeData.m_frontTextureOffsetY);
		m_currentGui->GetElement(GE_RIGHTYTEXTAREA)->m_String = "Y:" + to_string(shapeData.m_rightTextureOffsetY);

		m_currentGui->GetElement(GE_TOPWIDTHTEXTAREA)->m_String = "W:" + to_string(shapeData.m_topTextureWidth);
		m_currentGui->GetElement(GE_FRONTWIDTHTEXTAREA)->m_String = "W:" + to_string(shapeData.m_frontTextureWidth);
		m_currentGui->GetElement(GE_RIGHTWIDTHTEXTAREA)->m_String = "W:" + to_string(shapeData.m_rightTextureWidth);

		m_currentGui->GetElement(GE_TOPHEIGHTTEXTAREA)->m_String = "H:" + to_string(shapeData.m_topTextureHeight);
		m_currentGui->GetElement(GE_FRONTHEIGHTTEXTAREA)->m_String = "H:" + to_string(shapeData.m_frontTextureHeight);
		m_currentGui->GetElement(GE_RIGHTHEIGHTTEXTAREA)->m_String = "H:" + to_string(shapeData.m_rightTextureHeight);

		m_currentGui->GetElement(GE_TOPSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_TOP))];
		m_currentGui->GetElement(GE_FRONTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_FRONT))];
		m_currentGui->GetElement(GE_RIGHTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_RIGHT))];
		m_currentGui->GetElement(GE_BOTTOMSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BOTTOM))];
		m_currentGui->GetElement(GE_BACKSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_BACK))];
		m_currentGui->GetElement(GE_LEFTSIDETEXTURETEXTAREA)->m_String = m_sideDrawStrings[static_cast<int>(shapeData.GetTextureForSide(CuboidSides::CUBOID_LEFT))];
	}

	std::ostringstream out;
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.x;
	m_currentGui->GetElement(GE_TWEAKWIDTHTEXTAREA)->m_String = "W:" + out.str();

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.y;
	m_currentGui->GetElement(GE_TWEAKHEIGHTTEXTAREA)->m_String = "H:" + out.str();

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_Scaling.z;
	m_currentGui->GetElement(GE_TWEAKDEPTHTEXTAREA)->m_String = "D:" + out.str();

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_TweakPos.x;
	m_currentGui->GetElement(GE_TWEAKXTEXTAREA)->m_String = "X:" + out.str();

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_TweakPos.y;
	m_currentGui->GetElement(GE_TWEAKYTEXTAREA)->m_String = "Y:" + out.str();

	out.str("");
	out.precision(1);
	out << std::fixed << shapeData.m_TweakPos.z;
	m_currentGui->GetElement(GE_TWEAKZTEXTAREA)->m_String = "Z:" + out.str();

	out.str("");
	out.precision(1);
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
}


void ShapeEditorState::Draw()
{
	BeginDrawing();

	ClearBackground(Color{ 106, 90, 205, 255 });

	float scale = g_DrawScale * 2;

	if (g_shapeTable[m_currentShape][m_currentFrame].GetDrawType() == ShapeDrawType::OBJECT_DRAW_CUBOID)
	{
		Texture* d = g_shapeTable[m_currentShape][m_currentFrame].GetTexture();
		Texture* t = g_shapeTable[m_currentShape][m_currentFrame].GetTopTexture();
		Texture* f = g_shapeTable[m_currentShape][m_currentFrame].GetFrontTexture();
		Texture* r = g_shapeTable[m_currentShape][m_currentFrame].GetRightTexture();

		DrawTextureEx(*d, Vector2{ 0, 0 }, 0, scale, Color{ 255, 255, 255, 255 });
		DrawTextureEx(*t, Vector2{ 0, (d->height + 2) * scale }, 0, scale, Color{ 255, 255, 255, 255 });
		DrawTextureEx(*r, Vector2{ (t->width + 2) * scale, (d->height + 2) * scale }, 0, scale, Color{ 255, 255, 255, 255 });
		DrawTextureEx(*f, Vector2{ 0, (d->height + d->height + 2) * scale }, 0, scale, Color{ 255, 255, 255, 255 });

		//  Draw rectangles denoting texture offsets

		Rectangle topRect = { 0, 0, static_cast<float>(t->width) * scale, static_cast<float>(t->height) * scale };
		//DrawRectangleLinesEx(topRect, scale, RED);

		Rectangle frontRect = { 0, 0, static_cast<float>(f->width), static_cast<float>(f->height) };
		//DrawRectangleLinesEx(topRect, scale, RED);
		Rectangle rightRect = { 0, 0, static_cast<float>(r->width), static_cast<float>(r->height) };
	}

	if (g_shapeTable[m_currentShape][m_currentFrame].GetDrawType() == ShapeDrawType::OBJECT_DRAW_BILLBOARD)
	{
		Texture* d = g_shapeTable[m_currentShape][m_currentFrame].GetTexture();
		Texture* b = g_shapeTable[m_currentShape][m_currentFrame].GetBillboardTexture();
		DrawTextureEx(*d, Vector2{ 0, 0 }, 0, scale, Color{ 255, 255, 255, 255 });
		DrawTextureEx(*b, Vector2{ 0, (d->height + 2) * scale }, 0, scale, Color{ 255, 255, 255, 255 });
	}

	BeginMode3D(g_camera);

	Vector3 cuboidScaling = g_shapeTable[m_currentShape][m_currentFrame].m_Scaling;
	cuboidScaling.x *= 2.5;
	cuboidScaling.y *= 2.5;
	cuboidScaling.z *= 2.5;

	Vector3 finalPos = Vector3Add(Vector3Add(g_camera.target, g_shapeTable[m_currentShape][m_currentFrame].m_TweakPos), Vector3{ g_shapeTable[m_currentShape][m_currentFrame].m_Dims.x / 2 - 1, 0, g_shapeTable[m_currentShape][m_currentFrame].m_Dims.z / 2 - 1 });

	g_shapeTable[m_currentShape][m_currentFrame].Draw(finalPos, g_cameraRotation, Color{255, 255, 255, 255}, cuboidScaling);

	EndMode3D();
	

	DrawConsole();

	int yOffset = g_fontSize;
	int y = -yOffset;

	m_currentGui->Draw();

	DrawTexture(*g_Cursor, GetMouseX(), GetMouseY(), WHITE);

	EndDrawing();
}


