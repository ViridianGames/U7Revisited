#ifndef _GUMPPAPERDOLL_H_
#define _GUMPPAPERDOLL_H_

#include <memory>
#include "U7Gump.h"
#include "Geist/Object.h"
#include "Geist/Primitives.h"
#include "Geist/Gui.h"
#include "Geist/GuiElements.h"
#include "Ghost/GhostSerializer.h"

static constexpr const char* GUMPS_TEXTURE_PATH = "Images/GUI/biggumps.png";

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

enum class EquipmentSlot
{
	SLOT_HEAD = 0,
	SLOT_NECK,
	SLOT_TORSO,
	SLOT_LEGS,
	SLOT_HANDS,
	SLOT_FEET,
	SLOT_LEFT_HAND,    // Shield
	SLOT_RIGHT_HAND,   // Weapon
	SLOT_AMMO,
	SLOT_LEFT_RING,
	SLOT_RIGHT_RING,
	SLOT_BELT,
	SLOT_BACKPACK,
	SLOT_COUNT
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

	// Slot rectangles - same for all paperdolls
	// NOTE: These coordinates include the 5-pixel panel padding from paperdoll.ghost
	// static constexpr Rectangle m_slotRects[static_cast<int>(EquipmentSlot::SLOT_COUNT)] =
	// {
	// 	{ 175, 9, 16, 16 },    // SLOT_HEAD
	// 	{ 50, 32, 16, 16 },    // SLOT_NECK
	// 	{ 50, 51, 16, 16 },    // SLOT_TORSO
	// 	{ 175, 121, 16, 16 },  // SLOT_LEGS
	// 	{ 175, 100, 16, 16 },   // SLOT_HANDS
	// 	{ 115, 146, 16, 16 },  // SLOT_FEET
	// 	{ 175, 77, 16, 16 },   // SLOT_LEFT_HAND
	// 	{ 50, 77, 16, 16 },    // SLOT_RIGHT_HAND
	// 	{ 50, 9, 16, 16 },     // SLOT_AMMO
	// 	{ 175, 100, 16, 16 },   // SLOT_LEFT_RING
	// 	{ 50, 101, 16, 16 },   // SLOT_RIGHT_RING
	// 	{ 175, 51, 16, 16 },   // SLOT_BELT
	// 	{ 175, 31, 16, 16 }    // SLOT_BACKPACK
	// };

	// Static data array - one entry per paperdoll type
	// TODO: Measure actual coordinates from biggumps.png
	static constexpr PaperdollData m_paperdollData[] =
	{
		// PAPERDOLL_MALE_AVATAR
		{ { 746, 963 }, { 200, 205 }, PaperdollType::PAPERDOLL_MALE_AVATAR },
		// PAPERDOLL_FEMALE_AVATAR
		{ { 946, 963 }, { 200, 205 }, PaperdollType::PAPERDOLL_FEMALE_AVATAR },
		// PAPERDOLL_IOLO
		{ { 1146, 963 }, { 200, 205 }, PaperdollType::PAPERDOLL_IOLO },
		// PAPERDOLL_SHAMINO
		{ { 1546, 963 }, { 200, 205 }, PaperdollType::PAPERDOLL_SHAMINO },
		// PAPERDOLL_DUPRE
		{ { 546, 1168 }, { 200, 205 }, PaperdollType::PAPERDOLL_DUPRE },
		// PAPERDOLL_SPARK
		{ { 1346, 963 }, { 200, 205 }, PaperdollType::PAPERDOLL_SPARK },
		// PAPERDOLL_SENTRI
		{ { 946, 1168 }, { 200, 205 }, PaperdollType::PAPERDOLL_SENTRI },
		// PAPERDOLL_TSERAMED
		{ { 1546, 1168 }, { 200, 205 }, PaperdollType::PAPERDOLL_TSERAMED },
		// PAPERDOLL_JAANA
		{ { 746, 1168 }, { 200, 205 }, PaperdollType::PAPERDOLL_JAANA },
		// PAPERDOLL_KATRINA
		{ { 1346, 1168 }, { 200, 205 }, PaperdollType::PAPERDOLL_KATRINA },
		// PAPERDOLL_JULIA
		{ { 1146, 1168 }, { 200, 205 }, PaperdollType::PAPERDOLL_JULIA }
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

private:
	int m_npcId;               // Which NPC this paperdoll belongs to
	int m_paperdollType;       // Index into m_paperdollData array
	PaperdollData m_data;      // Cached paperdoll data
	Texture* m_backgroundTexture; // Pointer to biggumps.png texture for pixel checking
	std::unique_ptr<GhostSerializer> m_serializer; // GUI serializer for loading paperdoll.ghost
	std::vector<std::shared_ptr<Font>> m_loadedFonts; // Keep fonts alive
	// Note: m_gui is inherited from Gump base class
};

#endif
