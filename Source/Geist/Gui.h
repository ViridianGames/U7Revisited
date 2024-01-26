///////////////////////////////////////////////////////////////////////////
//
// Name:     Gui.H
// Author:   Anthony Salter
// Date:     10/22/05
// Purpose:  Graphic User Interface Object.
//
///////////////////////////////////////////////////////////////////////////////

//  This file defines an immediate-mode Gui that works with our
//  Init/Update/Draw/Shutdown system.  The GUI has its own X/Y coords that
//  every element inside the GUI offsets from. 
//
//  All GuiElements are derived from Tween (just like Gui itself) because
//  we want that programmable movement embedded in the system.  You'd be
//  amazed at how often Guis and their elements need to move around.
//
//  The entire gui can be scaled by setting m_Scale to something other
//  than 1; this makes it easier to make a single gui work in multiple
//  resolutions.
//
//  Guis can be created two ways: programmatically, or by loading in an XML
//  file.  To create a gui programmatically, first start by defining
//  constants that represent the IDs of the gui elements.  Then create the
//  gui object itself.  Then call the "AddXElement" functions on that object
//  to add elements of that type to the gui.  You'll need to feed those
//  functions the constants you created so that you can then access the
//  elements later during your update functions.
//
//  In the Update() function of your state, call Gui::Update() first so that
//  all the elements in the gui can be set to the appropriate state based on
//  where the mouse is and the state of the mouse buttons. Then you can call
//  Gui::GetActiveElement() to find the element in the gui that was most
//  recently manipulated by the user. It's not possible for more than one
//  element in a gui to be "active", so this is all you need.  You can then
//  access that element in the element list to find out exactly what its
//  state is, then act accordingly.



#ifndef _GUI_H_
#define _GUI_H_

#include "Object.h"
#include "Primitives.h"
#include "Font.h"
#include "GUIElements.h"
#include <list>
#include <vector>
#include <memory>
#include <map>

class Gui : public Tween
{
public:
	Gui();

	virtual void Init(const std::string& configfile);
	void Update();
	void Draw();

	void SetLayout(int x, int y, int width, int height, int flag = GUIP_USEXY);
	void SetAcceptingInput(bool acceptingInput) { m_AcceptingInput = acceptingInput; }
	bool GetAcceptingInput() { return m_AcceptingInput; }

	//  These functions are used by other code to find out the current state
	//  of the gui, so 
	int GetActiveElementID() { return m_ActiveElement; } // For most elements, all you need to know is the ID of the most recently active element.
	std::shared_ptr<GuiElement> GetActiveElement();
	std::shared_ptr<GuiElement> GetElement(int ID); //  Use this to get the complete state of a specific element.

	//  Load a complete GUI from a file.
	void LoadTXT(std::string fileName);
	void LoadXML(std::string fileName);

	//  Programatically add elements to a GUI
	void AddTextButton(int ID, int posx, int posy, int width, int height, std::string text, Font* font,
		Color textcolor = (Color(1, 1, 1, 1)),
		Color backgroundcolor = (Color(0, 0, 0, 1)),
		Color bordercolor = (Color(1, 1, 1, 1)), int group = 0, int active = true);

	void AddTextButton(int ID, int posx, int posy, std::string text, Font* font,
		Color textcolor = (Color(1, 1, 1, 1)),
		Color backgroundcolor = (Color(0, 0, 0, 1)),
		Color bordercolor = (Color(1, 1, 1, 1)), int group = 0, int active = true);

	void AddIconButton(int ID, int posx, int posy, std::shared_ptr<Sprite> upbutton, std::shared_ptr<Sprite> downbutton = NULL,
		std::shared_ptr<Sprite> inactivebutton = NULL, std::string text = "", Font* font = NULL,
		Color fontcolor = (Color(1, 1, 1, 1)), int group = 0, int active = true);

	void AddIconButton(int ID, Texture* tex, int posx, int posy, int tilex, int tiley,
		int width, int height, std::string text = "", Font* font = NULL,
		Color fontcolor = (Color(1, 1, 1, 1)), int group = 0, int active = true);

	void AddCheckBox(int ID, int posx, int posy, std::shared_ptr<Sprite> Unselected, std::shared_ptr<Sprite> Selected, std::shared_ptr<Sprite> Hovered = NULL, std::shared_ptr<Sprite> HoveredSelected = NULL,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), int group = 0, int active = true);

	void AddCheckBox(int ID, int posx, int posy, int width, int height,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), int group = 0, int active = true);

	void AddRadioButton(int ID, int posx, int posy, std::shared_ptr<Sprite> Selected, std::shared_ptr<Sprite> Unselected = NULL, std::shared_ptr<Sprite> Hovered = NULL,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), int group = 0, int active = true, bool shadowed = false);

	void AddRadioButton(int ID, int posx, int posy, int width, int height,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), int group = 0, int active = true, bool shadowed = false);

	void AddScrollBar(int ID, int valuerange, int posx, int posy, int width, int height, bool vertical,
		Color spurcolor = Color(1.0f, 1.0f, 1.0f, 1.0f), Color backgroundcolor = Color(.5f, .5f, 1.0f, 1.0f), int group = 0, int active = true, bool shadowed = false);

	void AddScrollBar(int ID, int valuerange, int posx, int posy, int width, int height, bool vertical,
		std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeCenter, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> spurActive,
		std::shared_ptr<Sprite> inactiveLeft = nullptr, std::shared_ptr<Sprite> inactiveCenter = nullptr, std::shared_ptr<Sprite> inactiveRight = nullptr, std::shared_ptr<Sprite> spurInactive = nullptr,
		int group = 0, int active = true, bool shadowed = false);

	void AddTextInput(int ID, int posx, int posy, int width, int height,
		Font* font, std::string initialtext, Color textcolor = Color(1, 1, 1, 1),
		Color boxcolor = Color(1, 1, 1, 1), Color backgroundcolor = Color(0, 0, 0, 0),
		int group = 0, int active = true);

	void AddPanel(int ID, int posx, int posy, int width, int height,
		Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), bool filled = true,
		int group = 0, int active = true);

	void AddTextArea(int ID, Font* font, std::string text, int posx, int posy, int width = 0, int height = 0,
		Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), int justified = GuiTextArea::LEFT, int group = 0, int active = true, bool shadowed = false);

	std::shared_ptr<GuiSprite> AddSprite(int ID, int posx, int posy, std::shared_ptr<Sprite> sprite, float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), int group = 0, int active = true);

	void AddOctagonBox(int ID, int posx, int posy, int width, int height, std::vector<std::shared_ptr<Sprite> > borders,
		Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), int group = 0, int active = true);

	void AddStretchButton(int ID, int posx, int posy, int width, std::string label,
		std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> activeCenter,
		std::shared_ptr<Sprite> inactiveLeft, std::shared_ptr<Sprite> inactiveRight, std::shared_ptr<Sprite> inactiveCenter, int indent = 0,
		Color color = Color(1, 1, 1, 1), int group = 0, int active = true, bool shadowed = false);

	virtual void ShowGroup(int group);
	virtual void HideGroup(int group);

	std::string GetString(int ID);

	std::map<int, std::shared_ptr<GuiElement> > m_GuiList;

	int m_PositionFlag;

	//  These do not change after initialization; they are for reference.
	int m_OriginalX;
	int m_OriginalY;
	int m_OriginalWidth;
	int m_OriginalHeight;

	//  These can be affected by scaling and repositioning; they are for drawing.
	int m_GuiX;
	int m_GuiY;
	int m_Width;
	int m_Height;

	int m_Active;

	int m_ActiveElement;
	int m_LastElement;

	bool m_Editing;

	bool m_AcceptingInput = true;

	std::shared_ptr<Font> m_Font;

	float m_Scale;

	enum Positions
	{
		GUIP_USEXY = 0, //  That's "Use XY", not "U SEXY"
		GUIP_UPPERLEFT,
		GUIP_UPPERRIGHT,
		GUIP_LOWERLEFT,
		GUIP_LOWERRIGHT,
		GUIP_FLOATLEFT,
		GUIP_FLOATRIGHT,
		GUIP_FLOATTOP,
		GUIP_FLOATBOTTOM,
		GUIP_CENTER,

		GUIP_LASTPOSITION
	};
};

#endif