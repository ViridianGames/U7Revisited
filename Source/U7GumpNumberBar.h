#ifndef _GUMPNUMBERBAR_H_
#define _GUMPNUMBERBAR_H_

#include <memory>
#include <string>

#include "Geist/Gui.h"
#include "Geist/GuiElements.h"

class U7Object;

class GumpNumberBar : public Unit2D
{
public:

	GumpNumberBar();
	virtual ~GumpNumberBar();
 
	void				Update() override;
	void				Draw() override;
	virtual void	Init() { Init(std::string("")); }
	void				Init(const std::string& data) override {};
	virtual void	OnExit() { m_IsDead = true; }
	virtual void	OnEnter();
	void				Setup(int min, int max, int step);

	Gui m_gui;

	int m_minAmount;
	int m_maxAmount;
	int m_stepAmount;
	int m_currentAmount;

	bool m_isDragging = false;
};

#endif