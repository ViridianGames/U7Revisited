#ifndef _GUMPMINIMAP_H_
#define _GUMPMINIMAP_H_

#include <string>
#include <memory>
#include "U7Gump.h"
#include "Ghost/GhostSerializer.h"

/// @brief Modal minimap gump UI class
/// Displays the minimap in the center of the screen. Closes when clicked anywhere.
class GumpMinimap : public Gump
{
public:
	GumpMinimap();
	virtual ~GumpMinimap();

	void Update() override;
	void Draw() override;
	void Init() override { Init(std::string("")); }
	void Init(const std::string& data) override;
	void OnExit() override { m_IsDead = true; }
	void OnEnter() override;

	/// @brief Set up the minimap for a specific NPC
	/// @param npcId The NPC ID who owns this minimap
	void Setup(int npcId);

	/// @brief Get the NPC ID who owns this minimap
	/// @return The NPC ID
	int GetNpcId() const { return m_npcId; }

	/// @brief Check if mouse is over a non-transparent pixel in the minimap texture
	/// @param mousePos The mouse position to check
	/// @return true if the mouse is over a solid pixel
	bool IsMouseOverSolidPixel(Vector2 mousePos) override;

private:
	int m_npcId;                      // Owner of this minimap
	bool m_isModal;                   // Modal flag (always true for minimap)
	std::unique_ptr<GhostSerializer> m_serializer; // GUI serializer for loading minimap.ghost
	std::vector<std::shared_ptr<Font>> m_loadedFonts; // Keep fonts alive
};

#endif
