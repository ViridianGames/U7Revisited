#ifndef _GUI_H_
#define _GUI_H_

#include <list>
#include <vector>
#include <memory>
#include <map>
#include <functional>

#include "Object.h"
#include "Primitives.h"
#include "GuiElements.h"

class Gui
{
public:
	Gui();
	virtual ~Gui() {};

	virtual void Init(const std::string& configfile);
	virtual void Update();
	virtual void Draw();

	void SetLayout(int x, int y, int width, int height, float scale, int flag);
	void SetAcceptingInput(bool acceptingInput) { m_AcceptingInput = acceptingInput; }
	bool GetAcceptingInput() { return m_AcceptingInput; }
	Rectangle GetBounds() const { return Rectangle{ m_Pos.x, m_Pos.y, m_Width, m_Height }; }

	// Add a generic element to the GUI
	void AddElement(std::shared_ptr<GuiElement> element);

	// Existing functions
	int GetActiveElementID() { return m_ActiveElement; }
	std::shared_ptr<GuiElement> GetActiveElement();
	std::shared_ptr<GuiElement> GetElement(int ID);

	void SetActive(bool active) { m_Active = active; }
	void SetDoneButtonId(int id) { m_doneButtonId = id; }

	void LoadTXT(std::string fileName);

	GuiTextButton* AddTextButton(int ID, int posx, int posy, int width, int height, std::string text, Font* font,
		Color textcolor = (Color{ 255, 255, 255, 255 }),
		Color backgroundcolor = (Color{ 0, 0, 0, 1 }),
		Color bordercolor = (Color{ 255, 255, 255, 255 }), int group = 0, int active = true);

	GuiTextButton* AddTextButton(int ID, int posx, int posy, std::string text, Font* font,
		Color textcolor = (Color{ 255, 255, 255, 255 }),
		Color backgroundcolor = (Color{ 0, 0, 0, 255 }),
		Color bordercolor = (Color{ 255, 255, 255, 255 }), int group = 0, int active = true);

	GuiIconButton* AddIconButton(int ID, int posx, int posy, std::shared_ptr<Sprite> upbutton, std::shared_ptr<Sprite> downbutton = NULL,
		std::shared_ptr<Sprite> inactivebutton = NULL, std::string text = "", Font* font = NULL,
		Color fontcolor = (Color{ 255, 255, 255, 255 }), float scale = 1, int group = 0, int active = true, bool canbeheld = false);

	GuiIconButton* AddIconButton(int ID, Texture* tex, int posx, int posy, int tilex, int tiley,
		int width, int height, std::string text = "", Font* font = NULL,
		Color fontcolor = (Color{ 255, 255, 255, 255 }), float scale = 1, int group = 0, int active = true);

	GuiCheckBox* AddCheckBox(int ID, int posx, int posy, std::shared_ptr<Sprite> Unselected, std::shared_ptr<Sprite> Selected, std::shared_ptr<Sprite> Hovered = NULL, std::shared_ptr<Sprite> HoveredSelected = NULL,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true);

	GuiCheckBox* AddCheckBox(int ID, int posx, int posy, int width, int height,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true);

	GuiRadioButton* AddRadioButton(int ID, int posx, int posy, std::shared_ptr<Sprite> Selected, std::shared_ptr<Sprite> Unselected, std::shared_ptr<Sprite> Hovered,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true, bool shadowed = false);

	GuiRadioButton* AddRadioButton(int ID, int posx, int posy, int width, int height,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true, bool shadowed = false);

	GuiScrollBar* AddScrollBar(int ID, int valuerange, int posx, int posy, int width, int height, bool vertical,
		Color spurcolor = Color{ 255, 255, 255, 255 }, Color backgroundcolor = Color{ 128, 128, 255, 255 }, int group = 0, int active = true, bool shadowed = false);

	GuiScrollBar* AddScrollBar(int ID, int valuerange, int posx, int posy, int width, int height, bool vertical,
		std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeCenter, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> spurActive,
		std::shared_ptr<Sprite> inactiveLeft = nullptr, std::shared_ptr<Sprite> inactiveCenter = nullptr, std::shared_ptr<Sprite> inactiveRight = nullptr, std::shared_ptr<Sprite> spurInactive = nullptr,
		int group = 0, int active = true, bool shadowed = false);

	GuiTextInput* AddTextInput(int ID, int posx, int posy, int width, int height,
		Font* font, std::string initialtext, Color textcolor = Color{ 255, 255, 255, 255 },
		Color boxcolor = Color{ 255, 255, 255, 255 }, Color backgroundcolor = Color{ 0, 0, 0, 0 },
		int group = 0, int active = true);

	GuiPanel* AddPanel(int ID, int posx, int posy, int width, int height,
		Color color = Color{ 255, 255, 255, 255 }, bool filled = true,
		int group = 0, int active = true);

	GuiTextArea* AddTextArea(int ID, Font* font, std::string text, int posx, int posy, int width = 0, int height = 0,
		Color color = Color{ 255, 255, 255, 255 }, int justified = GuiTextArea::LEFT, int group = 0, int active = true, bool shadowed = false);

	GuiSprite* AddSprite(int ID, int posx, int posy, std::shared_ptr<Sprite> sprite, float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true);

	GuiCycle* AddCycle(int ID, int posx, int posy,
		std::vector<std::shared_ptr<Sprite>> frames,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{255, 255, 255, 255},
		int group = 0, int active = true);

	GuiOctagonBox* AddOctagonBox(int ID, int posx, int posy, int width, int height, std::vector<std::shared_ptr<Sprite> > borders,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true);

	GuiStretchButton* AddStretchButton(int ID, int posx, int posy, int width, std::string label,
		std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> activeCenter,
		std::shared_ptr<Sprite> inactiveLeft, std::shared_ptr<Sprite> inactiveRight, std::shared_ptr<Sprite> inactiveCenter, int indent = 0,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true, bool shadowed = false);

	GuiStretchButton* AddStretchButtonCentered(int ID, int posy, std::string label,
		std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> activeCenter,
		std::shared_ptr<Sprite> inactiveLeft, std::shared_ptr<Sprite> inactiveRight, std::shared_ptr<Sprite> inactiveCenter, int indent = 0,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true, bool shadowed = false);

	GuiList* AddGuiList(int ID, int posx, int posy, int width, int height, Font* font,
			 const std::vector<std::string>& items, Color textcolor = {255, 255, 255, 255},
			 Color backgroundcolor = {0, 0, 0, 255}, Color bordercolor = {255, 255, 255, 255},
			 int group = 0, int active = true);

	GuiListBox* AddListBox(int ID, int posx, int posy, int width, int height, Font* font,
			 const std::vector<std::string>& items = {}, Color textcolor = {255, 255, 255, 255},
			 Color backgroundcolor = {0, 0, 0, 255}, Color bordercolor = {255, 255, 255, 255},
			 int group = 0, int active = true);

	void ShowGroup(int group);
	void HideGroup(int group);

	std::string GetString(int ID);

	std::map<int, std::shared_ptr<GuiElement> > m_GuiElementList;

	int m_PositionFlag;

	Vector2 m_Pos;

	unsigned int m_ID;

	float m_Width;
	float m_Height;

	bool m_Active = true;

	int m_ActiveElement;
	int m_LastElement;

	bool m_Editing;

	bool m_AcceptingInput = true;

	std::shared_ptr<Font> m_Font;

	float m_InputScale;

	enum Positions
	{
		GUIP_USE_XY = 0,
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

	bool m_Draggable = false;
	bool m_IsDragging = false;
	Vector2 m_DragOffset;
	int m_DragAreaHeight = 20;
	virtual bool IsMouseInDragArea() const;

	// Callback for pixel-perfect drag area validation (used by gumps to check transparency)
	std::function<bool(Vector2)> m_DragAreaValidationCallback = nullptr;

	bool m_isDone = false;
	int m_doneButtonId = -3;
};

#endif