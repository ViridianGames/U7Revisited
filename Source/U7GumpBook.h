#ifndef _GUMPBOOK_H_
#define _GUMPBOOK_H_

#include <string>

#include "Geist/Gui.h"
#include "Geist/GuiElements.h"

class Gump;

enum class BookType
{
	BOOK_BOOK = 0,
	BOOK_WOODEN_SIGN,
	BOOK_GRAVESTONE,
	BOOK_PLAQUE,
	BOOK_SCROLL,
};

struct BookData
{
	Vector2 m_texturePos;
	Vector2 m_textureSize;
	Vector2 m_boxOffset;
	Vector2 m_boxSize;
	// Facing page of a book. Signs and scrolls leave this empty.
	Vector2 m_secondOffset;
	Vector2 m_secondSize;
	BookType m_bookType;
};

class GumpBook : public Gump
{
public:
	static constexpr BookData m_bookData[] =
	{
		// Text boxes are the original page areas, scaled onto biggumps.png.
		{ { 572, 428 }, { 421, 220 }, { 14, 11 }, { 186, 190 }, { 222, 11 }, { 186, 190 }, BookType::BOOK_BOOK },
		{ { 581, 653 }, { 285, 147 }, { 0, 6 },   { 285, 139 }, { 0, 0 },    { 0, 0 },     BookType::BOOK_WOODEN_SIGN },
		{ { 871, 653 }, { 292, 192 }, { 0, 12 },  { 292, 169 }, { 0, 0 },    { 0, 0 },     BookType::BOOK_GRAVESTONE },
		{ { 1208, 653 },{ 272, 156 }, { 0, 6 },   { 272, 145 }, { 0, 0 },    { 0, 0 },     BookType::BOOK_PLAQUE },
		{ { 250, 863 }, { 310, 261 }, { 48, 52 }, { 214, 158 }, { 0, 0 },    { 0, 0 },     BookType::BOOK_SCROLL },
	};

	GumpBook();
	virtual ~GumpBook();
 
	void				Update();
	void				Draw();
	virtual void	Init() { Init(std::string("")); }
	void				Init(const std::string& data) {};
	virtual void	OnExit() { m_IsDead = true; }
	virtual void	OnEnter();
	void				Setup(const int book_type, const std::vector<std::string>& text);
	void				DrawSignLines(int bookX, int bookY);
	void				BookOrigin(int& bookX, int& bookY) const;
	// Paint one page starting at 'start'. Returns the index where the next page begins.
	int					PaintPage(int x, int y, int w, int h, int start, bool draw) const;
	int					VisibleEnd(int start) const;

	Gui m_gui;

	int m_bookType;

	// One entry per line, top line first. Signs, plaques, and gravestones.
	std::vector<std::string> m_signLines;
	// Books and scrolls. '~' starts a line. '*' ends a page. A click continues from m_pageTop.
	std::string m_text;
	int m_pageTop = 0;

	bool m_isDragging = false;
};

#endif