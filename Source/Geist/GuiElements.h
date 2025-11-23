///////////////////////////////////////////////////////////////////////////
//
// Name:     GUI.H
// Author:   Anthony Salter
// Date:     10/22/05
// Purpose:  Graphic User Interface Object.
//
///////////////////////////////////////////////////////////////////////////

//  About the simplest GUI system you will ever see.  Only handles left-clicks;
//  it's basically just a list of regions.  On every click the list is checked
//  to see if any of the regions has been clicked in; if they have, the system
//  runs the appropriate code.

// REVAMP:  Okay, what do we need here?

//  We need to be able to load GUIs from files.
//  We need to seriously do something about how you handle two-press
//  interactions (that is, you press something on the GUI and then you
//  press something in the game world to drop an object, say).

//  We might be able to handle that by, on press, looking at what USED to
//  be the active button (that is, the last active button).  If we're
//  currently clicking in the world and the last button was "Talk", say, 
//  then we check to see if there is an NPC under the mouse cursor now, and
//  if so, we initiate the "Talk" action on that NPC.  So it all stays
//  here, instead of getting munged up in the input code.

//  That would probably work.

//  GUIs can be declared and used in any subsystem, but will mostly be used
//  inside states.  A state will have a member GUI that it can easily
//  draw and check interactions on.

//  For simplicity's sake, we are going to assume that all buttons are on a
//  single tile sheet.  Button tiles should be arranged in square quads.
//  We will assume that the upper-left tile defines the normal state, the
//  upper-right tile defines the "hot" state, the lower-left tile defines
//  the "clicked" state, and the lower-right tile defines the "inactive"
//  state (greyed out).

#ifndef _GUIELEMENTS_H_
#define _GUIELEMENTS_H_

#include "Object.h"
#include "Primitives.h"
#include "BaseUnits.h"
#include <list>
#include <vector>

class Gui;

enum GuiElementType
{
	//  Actual working elements
	GUI_TEXTBUTTON = 0,
	GUI_ICONBUTTON,
	GUI_SCROLLBAR,
	GUI_RADIOBUTTON,
	GUI_CHECKBOX,
	GUI_TEXTINPUT,
	GUI_PANEL,
	GUI_TEXTAREA,
	GUI_SPRITE,
	GUI_OCTAGONBOX,
	GUI_STRETCHBUTTON,
	GUI_LIST,
	GUI_LISTBOX,
	GUI_CYCLE,

	GUI_LAST
};


class GuiElement : public Tween
{
public:
	GuiElement()
		: m_Type(0)
		, m_ID(0)
		, m_Active(0)
		, m_Group(0)
		, m_Visible(0)
		, m_Width(0.0f)
		, m_Height(0.0f)
		, m_Gui(nullptr)
	{}
	virtual ~GuiElement() {};

	virtual void Init() {};
	virtual void Update() = 0;
	virtual void Draw() = 0;

	virtual int         GetValue() = 0;
	virtual std::string GetString() { return m_String; }

	void SetPos(int x, int y) { m_Pos.x = float(x); m_Pos.y = float(y); }
	void SetSize(int w, int h) { m_Width = float(w); m_Height = float(h); }
	void SetSize(float w, float h) { m_Width = w; m_Height = h; }
	Rectangle GetBounds() const { return Rectangle{ m_Pos.x, m_Pos.y, m_Width, m_Height }; }

	int m_Type;
	int m_ID;
	int m_Active;
	int m_Group;
	int m_Visible;
	float m_Width;
	float m_Height;
	Color m_Color = Color{ 255, 255, 255, 255 };

	bool m_Hovered = false;  //  The mouse is over this element but is not down.  Somne elements will draw differently in this state.
	bool m_Down = false;      //  The mouse is over this element and the left mouse button is down.  The element will draw "clicked".
	bool m_Clicked = false;  //  The mouse is over this element and the left mouse button has JUST been released.  This is usually what you're looking for.  The element will draw normally since this is the end of the interaction.
	bool m_Shadowed = false;
	bool m_Selected = false;

	std::string m_String;

	Gui* m_Gui; // The parent GUI object.
};


//  The TextButton is procedurally generated from a string and a box size.  The colors invert when the
//  button is clicked.
class GuiTextButton : public GuiElement
{
public:

	GuiTextButton(Gui* parent)
		: m_Font(nullptr)
		, m_TextColor{255, 255, 255, 255}
		, m_BackgroundColor{0, 0, 0, 255}
		, m_BorderColor{255, 255, 255, 255}
		, m_TextWidth(0)
	{
		m_Gui = parent;
		m_Visible = true;
	}

	void Init(int ID, int posx, int posy, int width, int height, std::string text, Font* font,
		Color textcolor = Color{ 255, 255, 255, 255 },
		Color backgroundcolor = Color{ 0, 0, 0, 255 },
		Color bordercolor = Color{ 255, 255, 255, 255 }, int group = 0, int active = true);

	void Draw();
	void Update();
	int  GetValue();

	Font* m_Font;

	Color m_TextColor;
	Color m_BackgroundColor;
	Color m_BorderColor;

	int m_TextWidth;
};


//  The Icon Button element uses at least one (and up to three) sprites to
//  define how it looks, but it works exactly the same as a TextButton.
//  It can even have text on top of the icons.  The three icons are
//  normal (required), clicked and inactive.
class GuiIconButton : public GuiElement
{
public:

	GuiIconButton(Gui* parent)
		: m_Font(nullptr)
		, m_FontColor{255, 255, 255, 255}
	{
		m_Gui = parent;
		m_Visible = true;
	}

	void Init(int ID, int posx, int posy, std::shared_ptr<Sprite> upbutton, std::shared_ptr<Sprite> downbutton = NULL,
		std::shared_ptr<Sprite> inactivebutton = NULL, std::string text = "", Font* font = NULL,
		Color fontcolor = (Color{ 255, 255, 255, 255 }), float scale = 1, int group = 0, int active = true, bool canbeheld = false);

	void Draw();
	void Update();
	int GetValue();
	void SetBob(bool value) { m_Bobbing = value; }

	std::shared_ptr<Sprite> m_UpTexture;
	std::shared_ptr<Sprite> m_DownTexture;
	std::shared_ptr<Sprite> m_InactiveTexture;

	Font* m_Font;
	Color m_FontColor;
	float m_Scale = 1;

	bool  m_Bobbing = false;
	bool  m_CanBeHeld = false;
};

//  The CheckBox uses two sprites to define whether the object is
//  set or not.  Otherwise it works like an IconButton.
class GuiCheckBox : public GuiElement
{
public:
	GuiCheckBox(Gui* parent) { m_Gui = parent; m_Visible = true; };

	void Init(int ID, int posx, int posy, std::shared_ptr<Sprite> selectSprite, std::shared_ptr<Sprite> deselectSprite, std::shared_ptr<Sprite> hoveredSprite = nullptr, std::shared_ptr<Sprite> hoveredselected = nullptr,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true);

	void Init(int ID, int posx, int posy, int width, int height,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true);

	void Draw();
	void Update();
	int  GetValue() { if (m_Active) return m_Selected; else return m_Active; }

	Color m_Color = Color{ 255, 255, 255, 255 };
	std::shared_ptr<Sprite> m_SelectSprite;
	std::shared_ptr<Sprite> m_DeselectSprite;
	std::shared_ptr<Sprite> m_HoveredSprite;
	std::shared_ptr<Sprite> m_HoveredSelectedSprite;
	float m_ScaleX = 1;
	float m_ScaleY = 1;
};

//  The ScrollBar draws a spur at the appropriate location, either horizontally
//  or vertically.  The scrollbar draws the spur and contains the data for where
//  in the bar the spur is, but it does not include a background.  Use a panel
//  for the background.
class GuiScrollBar : public GuiElement
{
public:
	GuiScrollBar(Gui* parent)
		: m_Value(0)
		, m_ValueRange(0)
		, m_SpurLocation(0)
		, m_Vertical(false)
		, m_SpurColor{128, 128, 255, 255}
		, m_BackgroundColor{0, 0, 0, 0}
	{
		m_Gui = parent;
		m_Visible = true;
	}

	void Init(int ID, int valuerange, int posx, int posy, int width, int height, bool vertical,
		Color spurcolor = Color{ 128, 128, 255, 255 }, Color backgroundcolor = Color{ 0, 0, 0, 0 }, int group = 0, int active = true, bool shadowed = false);

	void Update();
	void Draw();
	int         GetValue();
	std::string GetString();

	int m_Value;
	int m_ValueRange;
	bool m_Selected = false;

	int m_SpurLocation;

	bool m_Vertical;
	bool m_DebugValue = false;

	Color m_SpurColor;
	Color m_BackgroundColor;

};


//  The TextInput shows a default string at the specified area using a specified
//  font.  Clicking that text makes a cursor appear at the end of that text.  The
//  player can then use backspace to delete the current text and type whatever text
//  he wishes.  No movement within the string will be allowed.  You can specify a
//  border with a color as well as a font color, but if you want a background, use
//  a panel, it's what they are for.
class GuiTextInput : public GuiElement
{
public:
	GuiTextInput(Gui* parent)
		: m_Font(nullptr)
		, m_BoxColor{255, 255, 255, 255}
		, m_BackgroundColor{0, 0, 0, 0}
		, m_TextColor{255, 255, 255, 255}
		, m_HasFocus(0)
	{
		m_Gui = parent;
		m_Visible = true;
	}
	void Init(int ID, int posx, int posy, int width, int height, Font* font,
		std::string initialtext = "", Color textColor = Color{ 255, 255, 255, 255 },
		Color boxcolor = Color{ 255, 255, 255, 255 }, Color backgroundcolor = Color{ 0, 0, 0, 0 },
		int group = 0, int active = true);

	void Update();
	void Draw();
	int         GetValue() { return 0; }

	Font* m_Font;

	Color m_BoxColor;
	Color m_BackgroundColor;
	Color m_TextColor;

	int m_HasFocus;
};


//  Radio buttons are grouped together with a group identifier.  They have
//  an additional "set" flag that shows which of the group is currently
//  active.  Clicking any button in the group sets that button and causes all
//  other buttons in that group to come unset.
class GuiRadioButton : public GuiElement
{
public:
	GuiRadioButton(Gui* parent) { m_Gui = parent; m_Visible = true; };

	void Init(int ID, int posx, int posy, std::shared_ptr<Sprite> selectSprite, std::shared_ptr<Sprite> deselectSprite, std::shared_ptr<Sprite> hoveredSprite = nullptr,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true, bool shadowed = false);

	void Init(int ID, int posx, int posy, int width, int height,
		float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true, bool shadowed = false);

	void Draw();
	void Update();
	int  GetValue() { if (m_Active) return m_Selected; else return m_Active; }

	Color m_Color = Color{ 255, 255, 255, 255 };
	std::shared_ptr<Sprite> m_SelectSprite;
	std::shared_ptr<Sprite> m_DeselectSprite;
	std::shared_ptr<Sprite> m_HoveredSprite;
	float m_ScaleX = 1;
	float m_ScaleY = 1;
};


//  A panel is basically just a box drawn on the screen.  It can be any color,
//  it can be alpha'd and it can be empty or filled.  It can also have a
//  texture, and if you just want to put a texture on the gui this is the way
//  to do it.
class GuiPanel : public GuiElement
{
public:
	GuiPanel(Gui* parent)
		: m_Filled(false)
		, m_Color{255, 255, 255, 255}
	{
		m_Gui = parent;
		m_Visible = true;
	}
	void Init(int ID, int posx, int posy, int width, int height,
		Color color = Color{ 255, 255, 255, 255 }, bool filled = false,
		int group = 0, int active = true);
	void Update();
	void Draw();
	int  GetValue();

	bool m_Filled;

	Color m_Color;

	// Font properties for inheritance to children
	Font* m_Font = nullptr;
	int m_FontSize = 0;
};


//  A textlabel is just text printed at a specific location in a specific color.
class GuiTextArea : public GuiElement
{
public:
	GuiTextArea(Gui* parent)
		: m_Font(nullptr)
		, m_Color{255, 255, 255, 255}
		, m_Justified(LEFT)
	{
		m_Gui = parent;
		m_Visible = true;
	}
	void Init(int ID, Font* font, std::string text, int posx, int posy, int width = 0, int height = 0,
		Color color = Color{ 255, 255, 255, 255 }, int justified = GuiTextArea::LEFT, int group = 0, int active = true, bool shadowed = false);

	void Draw();
	void Update();
	int  GetValue();

	Font* m_Font;
	Color m_Color;
	int   m_Justified;

	enum Justification
	{
		LEFT = 0,
		CENTERED,
		RIGHT
	};
};

//  Just puts an image at a certain location.  Non-interactive.
class GuiSprite : public GuiElement
{
public:
	GuiSprite(Gui* parent) { m_Gui = parent; m_Visible = true; };
	void Init(int ID, int posx, int posy, std::shared_ptr<Sprite> sprite, float scalex = 1.0f, float scaley = 1.0f,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true);

	void Draw();
	void Update();
	int GetValue() { return 0; }
	void SetSprite(std::shared_ptr<Sprite> newSprite)
	{
		m_Sprite = newSprite;
		if (newSprite)
		{
			m_Width = newSprite->m_sourceRect.width;
			m_Height = newSprite->m_sourceRect.height;
		}
	}
	std::shared_ptr<Sprite> GetSprite() { return m_Sprite; }

	Color m_Color = Color{ 255, 255, 255, 255 };
	std::shared_ptr<Sprite> m_Sprite;

	float m_ScaleX = 1;
	float m_ScaleY = 1;
};

//  An "octagon box" is a resizeable box made from eight border sprites and
//  one center sprite. The corners are not scaled (except for the global
//  scale of course), it's the up/down/left/right borders that get scaled so
//  that the box always looks right no matter what size it is.
//
//  Creating an octagon box requires passing in a vector of sprites that
//  represent the borders.  The sprites should be loaded into the vector
//  in this order:
//
//  0 - Top left
//  1 - Top
//  2 - Top right
//  3 - Left
//  4 - Center
//  5 - Right
//  6 - Bottom left
//  7 - Bottom
//  8 - Bottom right
class GuiOctagonBox : public GuiElement
{
public:
	GuiOctagonBox(Gui* parent) { m_Gui = parent; m_Visible = true; m_Width = 0; m_Height = 0; }
	void Init(int ID, int posx, int posy, int width, int height, std::vector<std::shared_ptr<Sprite> > borders,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true);

	void Draw();
	void Update();
	int GetValue() { return 0; }

	Color m_Color = Color{ 255, 255, 255, 255 };
	std::vector<std::shared_ptr<Sprite> > m_Sprites;
};

//  A "stretch button" is an icon button made up of three sprites - a left
//  sprite and a right sprite, which are drawn as provided, and a center sprite
//  that is stretched to fit the requested width.  Thus this button type can
//  use the same sprites to draw buttons of different widths.
class GuiStretchButton : public GuiElement
{
public:
	GuiStretchButton(Gui* parent) { m_Gui = parent; m_Visible = true; m_Width = 0; m_Height = 0; }
	void Init(int ID, int posx, int posy, int width, std::string label,
		std::shared_ptr<Sprite> activeLeft, std::shared_ptr<Sprite> activeRight, std::shared_ptr<Sprite> activeCenter,
		std::shared_ptr<Sprite> inactiveLeft, std::shared_ptr<Sprite> inactiveRight, std::shared_ptr<Sprite> inactiveCenter, int indent = 0,
		Color color = Color{ 255, 255, 255, 255 }, int group = 0, int active = true, bool shadowed = false);

	void Draw();
	void Update();
	int GetValue() { return 0; }

	Color m_Color = Color{ 255, 255, 255, 255 };
	std::shared_ptr<Sprite> m_ActiveLeft;
	std::shared_ptr<Sprite> m_ActiveRight;
	std::shared_ptr<Sprite> m_ActiveCenter;
	std::shared_ptr<Sprite> m_InactiveLeft;
	std::shared_ptr<Sprite> m_InactiveRight;
	std::shared_ptr<Sprite> m_InactiveCenter;

	int m_Indent = 0;
};

class GuiList : public GuiElement
{
public:
	GuiList() : GuiElement()
		, m_Font(nullptr)
		, m_TextColor{255, 255, 255, 255}
		, m_BackgroundColor{0, 0, 0, 255}
		, m_BorderColor{255, 255, 255, 255}
	{
		m_Gui = nullptr;
		m_Visible = true;
	}
	GuiList(Gui* parent) : GuiElement()
		, m_Font(nullptr)
		, m_TextColor{255, 255, 255, 255}
		, m_BackgroundColor{0, 0, 0, 255}
		, m_BorderColor{255, 255, 255, 255}
	{
		m_Gui = parent;
		m_Visible = true;
	}
	void Init(int ID, int posx, int posy, int width, int height, Font* font,
				 const std::vector<std::string>& items, Color textcolor = {255, 255, 255, 255},
				 Color backgroundcolor = {0, 0, 0, 255}, Color bordercolor = {255, 255, 255, 255},
				 int group = 0, int active = true);

	void Update() override;
	void Draw() override;
	int GetValue() override { return m_SelectedIndex; }
	std::string GetString() override { return m_Items.empty() ? "" : m_Items[m_SelectedIndex]; }

	void AddItem(const std::string& item);
	int GetSelectedIndex() const { return m_SelectedIndex; }
	void SetSelectedIndex(int index);
	int GetVisibleItems() const { return m_VisibleItems; }

//private:
	Font* m_Font;
	Color m_TextColor;
	Color m_BackgroundColor;
	Color m_BorderColor;
	std::vector<std::string> m_Items;
	int m_SelectedIndex = 0;
	bool m_IsExpanded = false;
	int m_VisibleItems = 10; // Number of items shown when expanded
};

//  GuiListBox is a scrollable list of text items. Unlike GuiList (which is a dropdown/combobox),
//  this shows all visible items at once in a fixed-height box.
class GuiListBox : public GuiElement
{
public:
	GuiListBox() : GuiElement()
		, m_Font(nullptr)
		, m_TextColor{255, 255, 255, 255}
		, m_BackgroundColor{0, 0, 0, 255}
		, m_BorderColor{255, 255, 255, 255}
	{
		m_Gui = nullptr;
		m_Visible = true;
	}
	GuiListBox(Gui* parent) : GuiElement()
		, m_Font(nullptr)
		, m_TextColor{255, 255, 255, 255}
		, m_BackgroundColor{0, 0, 0, 255}
		, m_BorderColor{255, 255, 255, 255}
	{
		m_Gui = parent;
		m_Visible = true;
	}

	void Init(int ID, int posx, int posy, int width, int height, Font* font,
			  const std::vector<std::string>& items = {},
			  Color textcolor = {255, 255, 255, 255},
			  Color backgroundcolor = {0, 0, 0, 255},
			  Color bordercolor = {255, 255, 255, 255},
			  int group = 0, int active = true);

	void Update() override;
	void Draw() override;
	int GetValue() override { return m_SelectedIndex; }
	std::string GetString() override;

	void AddItem(const std::string& item);
	void Clear();
	int GetSelectedIndex() const { return m_SelectedIndex; }
	void SetSelectedIndex(int index);

	Font* m_Font;
	Color m_TextColor;
	Color m_BackgroundColor;
	Color m_BorderColor;
	std::vector<std::string> m_Items;
	int m_SelectedIndex = -1;  // -1 means no selection
	int m_ScrollOffset = 0;    // First visible item index
	int m_VisibleItemCount = 0; // How many items fit in the box
	float m_ItemHeight = 0;     // Height of each item
	bool m_DoubleClicked = false;  // True if item was double-clicked

private:
	double m_LastClickTime = 0;  // Track time of last click for double-click detection
	int m_LastClickedIndex = -1; // Track which item was last clicked
};

// Helper function: Generate sprite frames from horizontal sprite sheet
// Takes first frame coordinates and count, returns vector of sprites
std::vector<std::shared_ptr<Sprite>> CreateHorizontalSpriteFrames(
	Texture* texture,
	int firstFrameX, int firstFrameY,
	int frameWidth, int frameHeight,
	int frameCount);

// GuiCycle is a clickable control that displays and cycles through sprite frames
// Each click advances to the next frame with wraparound
class GuiCycle : public GuiElement
{
public:
	GuiCycle(Gui* parent);

	void Init(int ID, int posx, int posy,
			  std::vector<std::shared_ptr<Sprite>> frames,
			  float scalex = 1.0f, float scaley = 1.0f,
			  Color color = Color{255, 255, 255, 255},
			  int group = 0, int active = true);

	void Draw() override;
	void Update() override;
	int GetValue() override;  // Returns current frame index

	// Frame control methods
	void SetFrameIndex(int index);
	int GetFrameIndex() const;
	void NextFrame();
	void PreviousFrame();

	// Public members (accessed by GhostSerializer and GhostState)
	std::vector<std::shared_ptr<Sprite>> m_Frames;
	int m_CurrentFrame;
	int m_FrameCount;
	float m_ScaleX;
	float m_ScaleY;
	Color m_Color;
};

#endif