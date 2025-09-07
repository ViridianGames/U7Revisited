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
	BookType m_bookType;
};

class GumpBook : public Gump
{
public:
	static constexpr BookData m_bookData[] =
	{
		{ { 572, 428 }, { 421, 220 }, { 12, 7 },   { 188, 199 }, BookType::BOOK_BOOK },
		{ { 581, 653 }, { 285, 147 }, { 82, 30 },   { 128, 48 },  BookType::BOOK_WOODEN_SIGN },
		{ { 871, 653 }, { 292, 192 }, { 42, 40 },   { 96, 98 },   BookType::BOOK_GRAVESTONE },
		{ { 1208, 653 },{ 272, 156 }, { 82, 34 },   { 90, 58 },   BookType::BOOK_PLAQUE },
		{ { 250, 863 }, { 310, 261 }, { 54, 58 },   { 114, 64 },  BookType::BOOK_SCROLL },
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

	Gui m_gui;

	int m_bookType;

	std::vector<std::string> m_bookPages;

	bool m_isDragging = false;
};

#endif