#include <cmath>
#include <string>

#include "U7Gump.h"
#include "U7GumpBook.h"
#include "U7VgaFont.h"

#include "InputSystem.h"
#include "Geist/Config.h"
#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"

#include "raylib.h"
#include "../ThirdParty/raylib/include/raylib.h"

using namespace std;

GumpBook::GumpBook()
{

}

GumpBook::~GumpBook()
{
}

void GumpBook::OnEnter()
{

}

void GumpBook::Setup(const int book_type, const std::vector<std::string>& text)
{
	m_gui.m_PositionFlag = Gui::GUIP_USE_XY;
	m_gui.m_Width = 0;
	m_gui.m_Height = 0;
	m_gui.m_Active = 1;
	m_gui.m_Editing = false;
	m_gui.m_ActiveElement = -1;
	m_gui.m_LastElement = -2;
	m_gui.m_InputScale = 1;
	m_gui.m_Draggable = false;  // Dragging is off by default
	m_gui.m_IsDragging = false;
	m_gui.m_DragOffset = { 0, 0 };
	m_gui.m_DragAreaHeight = 20;  // Default title bar height
	m_gui.m_isDone = false;
	m_IsDead = false;
	m_gui.m_doneButtonId = -3;
	m_bookType = book_type;
	m_gui.m_Font = g_SmallFont;
	m_gui.SetLayout(0, 0, 640, 360, g_DrawScale, Gui::GUIP_USE_XY);

	m_signLines.clear();
	m_text.clear();
	m_pageTop = 0;
	switch (m_bookType)
	{
	case int(BookType::BOOK_BOOK):
	case int(BookType::BOOK_SCROLL):
		{
			// A new chunk continues the paragraph unless the previous one ended on a page break.
			for (const std::string& chunk : text)
			{
				if (!m_text.empty() && m_text.back() != '*')
				{
					m_text.push_back('~');
				}
				m_text += chunk;
			}
		}
		break;

	case int(BookType::BOOK_WOODEN_SIGN):
		{
			// Decompiled tables list the bottom line first.
			// Leave the shorthand alone. In font 1, lowercase is the runic
			// alphabet and ( ) * + , | are the ligatures.
			m_signLines.clear();
			for (auto thistext = text.rbegin(); thistext != text.rend(); ++thistext)
			{
				m_signLines.push_back(*thistext);
			}
		}
		break;

	case int(BookType::BOOK_GRAVESTONE):
	case int(BookType::BOOK_PLAQUE):
		{
			// Decompiled tables list the bottom line first.
			m_signLines.clear();
			for (auto thistext = text.rbegin(); thistext != text.rend(); ++thistext)
			{
				m_signLines.push_back(ExpandSignText(*thistext));
			}
		}
		break;

	default:
		break;
	}
}

void GumpBook::Update()
{
	if (!g_InputSystem->WasLButtonClicked())
	{
		return;
	}

	const BookType kind = m_bookData[m_bookType].m_bookType;
	if (kind == BookType::BOOK_WOODEN_SIGN || kind == BookType::BOOK_GRAVESTONE || kind == BookType::BOOK_PLAQUE)
	{
		m_IsDead = true;
		return;
	}

	const int end = VisibleEnd(m_pageTop);
	if (end >= static_cast<int>(m_text.size()))
	{
		m_IsDead = true;
		return;
	}

	m_pageTop = end;
	while (m_pageTop < static_cast<int>(m_text.size()) && m_text[static_cast<size_t>(m_pageTop)] == '~')
	{
		++m_pageTop;
	}
	if (m_pageTop >= static_cast<int>(m_text.size()))
	{
		m_IsDead = true;
	}
}

void GumpBook::BookOrigin(int& bookX, int& bookY) const
{
	const BookData& data = m_bookData[m_bookType];
	bookX = static_cast<int>((580 - data.m_textureSize.x) / 2);
	bookY = static_cast<int>((360 - data.m_textureSize.y) / 2);
}

int GumpBook::VisibleEnd(int start) const
{
	const BookData& data = m_bookData[m_bookType];
	int bookX = 0;
	int bookY = 0;
	BookOrigin(bookX, bookY);
	int end = PaintPage(
		bookX + static_cast<int>(data.m_boxOffset.x),
		bookY + static_cast<int>(data.m_boxOffset.y),
		static_cast<int>(data.m_boxSize.x),
		static_cast<int>(data.m_boxSize.y),
		start,
		false);
	if (data.m_bookType == BookType::BOOK_BOOK)
	{
		end = PaintPage(
			bookX + static_cast<int>(data.m_secondOffset.x),
			bookY + static_cast<int>(data.m_secondOffset.y),
			static_cast<int>(data.m_secondSize.x),
			static_cast<int>(data.m_secondSize.y),
			end,
			false);
	}
	return end;
}

namespace
{

// Same face and line spacing as the rest of the interface.
int UiBookLineStep()
{
	if (!g_SmallFont)
	{
		return 0;
	}
	const int step = static_cast<int>(g_SmallFont->baseSize * 1.2f);
	return step > 0 ? step : 1;
}

int MeasureUiBook(const std::string& text)
{
	if (!g_SmallFont || text.empty())
	{
		return 0;
	}
	return static_cast<int>(std::ceil(MeasureTextEx(*g_SmallFont, text.c_str(), g_SmallFont->baseSize, 1.f).x));
}

// Fits a chunk into the page. A positive return is the height used.
// A negative return is the byte offset of the first character that did not fit.
int PaintUiBookText(const char* text, int length, int x, int y, int w, int h, bool draw)
{
	const int lineStep = UiBookLineStep();
	if (lineStep <= 0 || h < lineStep)
	{
		return 0;
	}
	if (text == nullptr || length <= 0)
	{
		return lineStep;
	}

	const char* const start = text;
	const char* const end = text + length;
	const int maxLines = h / lineStep;
	// Stop short of the box so the last glyph does not sit on the page edge.
	const int wrapWidth = w > 8 ? w - 6 : w;
	std::vector<std::string> lines(static_cast<size_t>(maxLines));
	int curLine = 0;

	while (text < end)
	{
		const unsigned char ch = static_cast<unsigned char>(*text);
		if (ch == '\n')
		{
			++text;
			++curLine;
			if (curLine >= maxLines)
			{
				break;
			}
			continue;
		}
		if (ch == '\r')
		{
			++text;
			continue;
		}
		if (ch == ' ' || ch == '\t')
		{
			const char* run = text;
			while (run < end && (*run == ' ' || *run == '\t'))
			{
				++run;
			}
			const int spaces = static_cast<int>(run - text);
			if (curLine < maxLines)
			{
				lines[static_cast<size_t>(curLine)].append(static_cast<size_t>(spaces), ' ');
			}
			text = run;
			if (text >= end)
			{
				break;
			}
		}
		if (curLine >= maxLines)
		{
			break;
		}

		const bool upperNext = (*text == '^');
		const char* word = text;
		if (upperNext)
		{
			++word;
			if (word >= end)
			{
				text = end;
				break;
			}
		}
		const char* wordEnd = word;
		while (wordEnd < end)
		{
			const char wordChar = *wordEnd;
			if (wordChar == ' ' || wordChar == '\t' || wordChar == '\n' || wordChar == '\r' || wordChar == '^')
			{
				break;
			}
			++wordEnd;
		}
		if (wordEnd == word)
		{
			text = word;
			continue;
		}

		std::string piece;
		if (upperNext)
		{
			unsigned char upper = static_cast<unsigned char>(*word);
			if (upper >= 'a' && upper <= 'z')
			{
				upper = static_cast<unsigned char>(upper - 'a' + 'A');
			}
			piece.push_back(static_cast<char>(upper));
			if (wordEnd > word + 1)
			{
				piece.append(word + 1, wordEnd);
			}
		}
		else
		{
			piece.assign(word, wordEnd);
		}

		// Measure the line as it will be drawn. Adding word widths misses the gaps between them.
		const std::string candidate = lines[static_cast<size_t>(curLine)] + piece;
		if (!lines[static_cast<size_t>(curLine)].empty() && MeasureUiBook(candidate) > wrapWidth)
		{
			++curLine;
			if (curLine >= maxLines)
			{
				break;
			}
		}

		lines[static_cast<size_t>(curLine)] += piece;
		text = wordEnd;
	}

	const bool truncated = (text < end);
	int lastLine = curLine;
	if (truncated && curLine >= maxLines)
	{
		lastLine = curLine - 1;
	}
	if (draw && g_SmallFont)
	{
		for (int i = 0; i <= lastLine; ++i)
		{
			std::string& line = lines[static_cast<size_t>(i)];
			while (!line.empty() && (line.back() == ' ' || line.back() == '\t'))
			{
				line.pop_back();
			}
			DrawTextEx(
				*g_SmallFont,
				line.c_str(),
				Vector2{ static_cast<float>(x), static_cast<float>(y + i * lineStep) },
				g_SmallFont->baseSize,
				1.f,
				BLACK);
		}
	}
	if (truncated)
	{
		int used = static_cast<int>(text - start);
		if (used < 1)
		{
			used = 1;
		}
		return -used;
	}
	return (curLine + 1) * lineStep;
}

}

int GumpBook::PaintPage(int x, int y, int w, int h, int start, bool draw) const
{
	const int len = static_cast<int>(m_text.size());
	if (start < 0)
	{
		start = 0;
	}
	if (start >= len || w <= 0 || h <= 0)
	{
		return start > len ? len : start;
	}

	const int textHeight = UiBookLineStep();
	if (textHeight <= 0)
	{
		return len;
	}
	const bool isScroll = m_bookData[m_bookType].m_bookType == BookType::BOOK_SCROLL;
	int pos = start;
	int ypos = 0;

	auto FindChar = [&](int from, char ch) -> int
	{
		if (from < 0 || from > len)
		{
			return -1;
		}
		const size_t found = m_text.find(ch, static_cast<size_t>(from));
		if (found == std::string::npos)
		{
			return -1;
		}
		return static_cast<int>(found);
	};
	auto FindToken = [&](int from, const char* token) -> int
	{
		if (from < 0 || from > len)
		{
			return -1;
		}
		const size_t found = m_text.find(token, static_cast<size_t>(from));
		if (found == std::string::npos)
		{
			return -1;
		}
		return static_cast<int>(found);
	};

	if (draw)
	{
		BeginScissorMode(x, y, w, h);
	}

	int guard = 0;
	while (pos < len && ypos + textHeight <= h)
	{
		if (++guard > len + 2)
		{
			if (pos < len)
			{
				++pos;
			}
			break;
		}

		const int lineBreak = FindChar(pos, '~');
		const int pageBreak = FindChar(pos, '*');
		int extraBreak = -1;
		if (isScroll)
		{
			extraBreak = FindToken(pos, " ~~");
			// "~~ ~~" is spacing, not another page break.
			if (extraBreak >= 2 && m_text[static_cast<size_t>(extraBreak - 2)] == '~' && m_text[static_cast<size_t>(extraBreak - 1)] == '~')
			{
				extraBreak = -1;
			}
		}

		int epage = -1;
		int eol = -1;
		if (extraBreak >= 0 && lineBreak >= 0 && extraBreak + 1 == lineBreak)
		{
			epage = extraBreak;
			eol = extraBreak;
		}
		else if (pageBreak >= 0 && (lineBreak < 0 || pageBreak < lineBreak))
		{
			epage = pageBreak;
			eol = pageBreak;
		}
		else
		{
			eol = lineBreak;
		}
		if (eol < 0)
		{
			eol = len;
		}

		const int endoff = PaintUiBookText(m_text.c_str() + pos, eol - pos, x, y + ypos, w, h - ypos, draw);
		if (endoff > 0)
		{
			if (epage >= 0)
			{
				if (isScroll)
				{
					const int remaining = h - (ypos + endoff);
					bool stay = false;
					if (remaining >= 2 * textHeight)
					{
						int available = remaining - (2 * textHeight);
						if (available < 0)
						{
							available = 0;
						}
						const int markerLen = (epage == extraBreak) ? 3 : 1;
						int peekFrom = eol + markerLen;
						if (peekFrom > len)
						{
							peekFrom = len;
						}
						int peekEnd = len;
						const int nextLine = FindChar(peekFrom, '~');
						const int nextStar = FindChar(peekFrom, '*');
						const int nextExtra = FindToken(peekFrom, " ~~");
						if (nextLine >= 0 && nextLine < peekEnd)
						{
							peekEnd = nextLine;
						}
						if (nextStar >= 0 && nextStar < peekEnd)
						{
							peekEnd = nextStar;
						}
						if (nextExtra >= 0 && nextExtra < peekEnd)
						{
							peekEnd = nextExtra;
						}
						const int peekHeight = PaintUiBookText(
							m_text.c_str() + peekFrom,
							peekEnd - peekFrom,
							x,
							y,
							w,
							available,
							false);
						if (peekHeight > 0 && peekHeight <= available + 5)
						{
							stay = true;
						}
					}
					if (stay)
					{
						// Keep a trailing '~' from " ~~" so the next block starts on a new line.
						pos = eol + ((epage == extraBreak) ? 2 : 1);
						if (pos > len)
						{
							pos = len;
						}
						ypos += endoff;
						continue;
					}
					pos = eol + ((epage == extraBreak) ? 3 : 1);
					if (pos > len)
					{
						pos = len;
					}
					break;
				}

				pos = eol + 1;
				if (pos > len)
				{
					pos = len;
				}
				break;
			}

			if (eol < len && m_text[static_cast<size_t>(eol)] == '~')
			{
				++eol;
			}
			ypos += endoff;
			pos = eol;
			if (pos < len && m_text[static_cast<size_t>(pos)] == ' ')
			{
				++pos;
			}
		}
		else
		{
			int used = -endoff;
			if (used < 1)
			{
				used = 1;
			}
			pos += used;
			if (pos > len)
			{
				pos = len;
			}
			break;
		}
	}

	if (draw)
	{
		EndScissorMode();
	}
	return pos;
}

void GumpBook::Draw()
{
	int bookX = 0;
	int bookY = 0;
	BookOrigin(bookX, bookY);
	const BookData& data = m_bookData[m_bookType];

	DrawTextureRec(*g_ResourceManager->GetTexture("Images/GUI/biggumps.png"),
	{ data.m_texturePos.x, data.m_texturePos.y, data.m_textureSize.x, data.m_textureSize.y },
	{ float(bookX), float(bookY) }, Color{ 255, 255, 255, 255 });

	const BookType kind = data.m_bookType;
	if (kind == BookType::BOOK_WOODEN_SIGN || kind == BookType::BOOK_GRAVESTONE || kind == BookType::BOOK_PLAQUE)
	{
		DrawSignLines(bookX, bookY);
		return;
	}

	const int end = PaintPage(
		bookX + static_cast<int>(data.m_boxOffset.x),
		bookY + static_cast<int>(data.m_boxOffset.y),
		static_cast<int>(data.m_boxSize.x),
		static_cast<int>(data.m_boxSize.y),
		m_pageTop,
		true);
	if (kind == BookType::BOOK_BOOK)
	{
		PaintPage(
			bookX + static_cast<int>(data.m_secondOffset.x),
			bookY + static_cast<int>(data.m_secondOffset.y),
			static_cast<int>(data.m_secondSize.x),
			static_cast<int>(data.m_secondSize.y),
			end,
			true);
	}
}

void GumpBook::DrawSignLines(int bookX, int bookY)
{
	int fontShape = 1;
	if (m_bookType == int(BookType::BOOK_PLAQUE))
	{
		fontShape = 6;
	}
	else if (m_bookType == int(BookType::BOOK_GRAVESTONE))
	{
		fontShape = 3;
	}

	const U7VgaFont* font = GetU7VgaFont(fontShape);
	if (!font || m_signLines.empty())
	{
		return;
	}

	const BookData& data = m_bookData[m_bookType];
	const int boxX = bookX + static_cast<int>(data.m_boxOffset.x);
	const int boxY = bookY + static_cast<int>(data.m_boxOffset.y);
	const int boxW = static_cast<int>(data.m_boxSize.x);
	const int boxH = static_cast<int>(data.m_boxSize.y);
	const int lineCount = static_cast<int>(m_signLines.size());
	const int lineHeight = font->LineHeight();
	int gap = (boxH - lineCount * lineHeight) / (lineCount + 1);
	if (gap < 0)
	{
		gap = 0;
	}

	int y = boxY;
	for (const std::string& line : m_signLines)
	{
		y += gap;
		if (line.empty())
		{
			continue;
		}
		const int textWidth = font->Measure(line);
		const int x = boxX + (boxW - textWidth) / 2;
		font->Draw(line, x, y);
		y += lineHeight;
	}
}