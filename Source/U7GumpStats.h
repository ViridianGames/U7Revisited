#ifndef _GUMPSTATS_H_
#define _GUMPSTATS_H_

#include <memory>
#include "U7Gump.h"
#include "Geist/Object.h"
#include "Geist/Primitives.h"
#include "Geist/Gui.h"
#include "Geist/GuiElements.h"
#include "Ghost/GhostSerializer.h"

class GumpStats : public Gump
{
public:
	GumpStats();
	virtual ~GumpStats();

	virtual void Update() override;
	virtual void Draw() override;
	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& data) override;
	virtual void OnExit() override;
	virtual void OnEnter();
	virtual U7Object* GetObjectUnderMousePointer() override { return nullptr; }  // Stats gumps don't show objects
	virtual bool IsMouseOverSolidPixel(Vector2 mousePos) override;  // Pixel-perfect collision detection

	void Setup(int npcId);  // Configure for specific NPC
	int GetNpcId() const { return m_npcId; }

	// Public for access from GumpManager
	std::unique_ptr<GhostSerializer> m_serializer; // GUI serializer for loading stats.ghost

private:
	int m_npcId;               // Which NPC this stats gump belongs to
	Texture* m_backgroundTexture; // Pointer to gumps.png texture for pixel checking
	std::vector<std::shared_ptr<Font>> m_loadedFonts; // Keep fonts alive
	// Note: m_gui is inherited from Gump base class
};

#endif
