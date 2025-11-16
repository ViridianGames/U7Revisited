#ifndef _SCRIPTRENAMESTATE_H_
#define _SCRIPTRENAMESTATE_H_

#include "Geist/State.h"
#include "Ghost/GhostWindow.h"
#include <memory>
#include <string>

class ScriptRenameState : public State
{
public:
	ScriptRenameState() { m_RenderStack = true; }
	~ScriptRenameState();

	void Init(const std::string& configfile) override;
	void Shutdown() override;
	void Update() override;
	void Draw() override;
	void OnEnter() override;
	void OnExit() override;

	// Check if OK was pressed (vs Cancel)
	bool WasAccepted() const { return m_accepted; }

	// Get the old and new script names entered by the user
	std::string GetOldName() const { return m_oldName; }
	std::string GetNewName() const { return m_newName; }

private:
	std::unique_ptr<GhostWindow> m_window;

	std::string m_oldName;
	std::string m_newName;
	bool m_accepted = false;
};

#endif
