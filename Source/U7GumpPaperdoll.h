#ifndef _GUMPPAPERDOLL_H_
#define _GUMPPAPERDOLL_H_

#include <memory>
#include "U7Gump.h"
#include "Geist/Object.h"
#include "Geist/Primitives.h"
#include "Geist/Gui.h"
#include "Geist/GuiElements.h"
#include "Ghost/GhostSerializer.h"

static constexpr const char* GUMPS_TEXTURE_PATH = "Images/GUI/gumps.png";

enum class PaperdollType
{
	PAPERDOLL_MALE_AVATAR = 0,
	PAPERDOLL_FEMALE_AVATAR,
	PAPERDOLL_IOLO,
	PAPERDOLL_SHAMINO,
	PAPERDOLL_DUPRE,
	PAPERDOLL_SPARK,
	PAPERDOLL_SENTRI,
	PAPERDOLL_TSERAMED,
	PAPERDOLL_JAANA,
	PAPERDOLL_KATRINA,
	PAPERDOLL_JULIA,
	PAPERDOLL_LAST
};

class GumpPaperdoll : public Gump
{
public:
	struct PaperdollData
	{
		Vector2 m_texturePos;      // Position in biggumps.png
		Vector2 m_textureSize;     // Size of paperdoll background
		PaperdollType m_paperdollType;
	};

	// Static data array - one entry per paperdoll type
	// TODO: Measure actual coordinates from biggumps.png
	static constexpr PaperdollData m_paperdollData[] =
	{
		// PAPERDOLL_MALE_AVATAR
		{ { 498, 642 }, { 133, 136 }, PaperdollType::PAPERDOLL_MALE_AVATAR },
		// PAPERDOLL_FEMALE_AVATAR
		{ { 631, 642 }, { 133, 136 }, PaperdollType::PAPERDOLL_FEMALE_AVATAR },
		// PAPERDOLL_IOLO
		{ { 764, 642 }, { 133, 136 }, PaperdollType::PAPERDOLL_IOLO },
		// PAPERDOLL_SHAMINO
		{ { 1030, 642 }, { 133, 136 }, PaperdollType::PAPERDOLL_SHAMINO },
		// PAPERDOLL_DUPRE
		{ { 365, 779 }, { 133, 136 }, PaperdollType::PAPERDOLL_DUPRE },
		// PAPERDOLL_SPARK
		{ { 897, 642 }, { 133, 136 }, PaperdollType::PAPERDOLL_SPARK },
		// PAPERDOLL_SENTRI
		{ { 631, 779 }, { 133, 136 }, PaperdollType::PAPERDOLL_SENTRI },
		// PAPERDOLL_TSERAMED
		{ { 1030, 779 }, { 133, 136 }, PaperdollType::PAPERDOLL_TSERAMED },
		// PAPERDOLL_JAANA
		{ { 498, 779 }, { 133, 136 }, PaperdollType::PAPERDOLL_JAANA },
		// PAPERDOLL_KATRINA
		{ { 897, 779 }, { 133, 136 }, PaperdollType::PAPERDOLL_KATRINA },
		// PAPERDOLL_JULIA
		{ { 764, 779 }, { 133, 136 }, PaperdollType::PAPERDOLL_JULIA }
	};

	GumpPaperdoll();
	virtual ~GumpPaperdoll();

	virtual void Update() override;
	virtual void Draw() override;
	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& data) override;
	virtual void OnExit() { m_IsDead = true; }
	virtual void OnEnter();
	virtual U7Object* GetObjectUnderMousePointer() override { return nullptr; }  // Paperdolls don't show container inventory
	virtual bool IsMouseOverSolidPixel(Vector2 mousePos) override;  // Pixel-perfect collision detection

	void Setup(int npcId);  // Configure for specific NPC
	int GetNpcId() const { return m_npcId; }

	// Public for access from GumpManager
	std::unique_ptr<GhostSerializer> m_serializer; // GUI serializer for loading paperdoll.ghost
	std::set<int> m_highlightedSlots;  // Set of slot indices currently highlighted

private:
	int m_npcId;               // Which NPC this paperdoll belongs to
	int m_paperdollType;       // Index into m_paperdollData array
	PaperdollData m_data;      // Cached paperdoll data
	Texture* m_backgroundTexture; // Pointer to biggumps.png texture for pixel checking
	std::vector<std::shared_ptr<Font>> m_loadedFonts; // Keep fonts alive
	// Note: m_gui is inherited from Gump base class

	// Hover text for clicked items
	std::string m_hoverText;
	float m_hoverTextDuration = 0.0f;
	Vector2 m_hoverTextPos = {0, 0};  // Screen position for hover text
};

#endif
