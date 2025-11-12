#ifndef _GUMP_H_
#define _GUMP_H_

#include <list>
#include <vector>
#include <memory>
#include <map>
#include <string>

#include "Geist/Object.h"
#include "Geist/Primitives.h"
#include "Geist/Gui.h"
#include "Geist/GuiElements.h"

class U7Object;

class Gump : public Unit2D
{
public:

	enum class GumpType
	{
		GUMP_INVENTORY = 0,
		GUMP_BOOK,
		GUMP_SIGN,
		GUMP_NUMBER_BAR,

	};

	enum class ContainerType
	{
		CONTAINER_BOX = 0,
		CONTAINER_CRATE,
		CONTAINER_BARREL,
		CONTAINER_BAG,
		CONTAINER_BACKPACK,
		CONTAINER_BASKET,
		CONTAINER_TREASURECHEST,
		CONTAINER_DRAWER,
		CONTAINER_CORPSE,
		CONTAINER_LAST
	};

	struct ContainerData
	{
		Vector2 m_texturePos;
		Vector2 m_textureSize;
		Vector2 m_boxOffset;
		Vector2 m_boxSize;
		Vector2 m_checkMarkOffset;
		ContainerType m_containerType;
	};

	static constexpr ContainerData g_containerData[] =
	{
		{ { 9, 18 },    { 228, 132 }, { 72, 48 },   { 114, 108 }, { 0, 0 }, ContainerType::CONTAINER_BOX },
		{ { 242, 18 },  { 254, 102 }, { 82, 30 },   { 128, 48 },  { 0, 0 }, ContainerType::CONTAINER_CRATE },
		{ { 1452, 18 }, { 198, 178 }, { 42, 40 },   { 96, 98 },   { 0, 0 }, ContainerType::CONTAINER_BARREL },
		{ { 9, 264 },   { 234, 146 }, { 82, 34 },   { 90, 58 },   { 0, 0 }, ContainerType::CONTAINER_BAG },
		{ { 250, 266 }, { 218, 154 }, { 68, 58 },   { 114, 64 },  { 0, 0 }, ContainerType::CONTAINER_BACKPACK },
		{ { 474, 264 }, { 212, 120 }, { 74, 52 },   { 100, 40 },   { 0, 0 }, ContainerType::CONTAINER_BASKET },
		{ { 1104, 264 },{ 176, 106 }, { 64, 34 },   { 92, 54 },   { 0, 0 }, ContainerType::CONTAINER_TREASURECHEST },
		{ { 10, 428 },   { 204, 104 }, { 66, 24 },   { 102, 50 },  { 0, 0 }, ContainerType::CONTAINER_DRAWER },
		{ { 10, 864 },   { 210, 158 }, { 68, 77 },   { 114, 56 },  { 0, 0 }, ContainerType::CONTAINER_CORPSE }
	};

	// static constexpr ContainerData g_containerData[] =
	// {
	// 	{ { 6, 12 },	{ 151, 88 },	{ 47, 31 },		{ 76, 72 }, { 0, 0 }, ContainerType::CONTAINER_BOX },
	// 	{ { 161, 12 },	{ 169, 68 },	{ 54, 19 },	{ 85, 31 }, { 0, 0 }, ContainerType::CONTAINER_CRATE },
	// 	{ {968, 12 },	{ 131, 118 },	{ 27, 26 },	{ 64, 65 }, { 0, 0 }, ContainerType::CONTAINER_BARREL	},
	// 	{ {6, 176 },	{ 155, 97 },	{ 54, 22 },	{ 60, 38 }, { 0, 0 }, ContainerType::CONTAINER_BAG },
	// 	{ {166, 177},	{145, 102},		{45, 38},		{75, 42},	{ 0, 0 }, ContainerType::CONTAINER_BACKPACK },
	// 	{ {316, 176},	{141, 80},		{49, 34},		{66, 26},	{ 0, 0 }, ContainerType::CONTAINER_BASKET },
	// 	{ {735, 176},	{117, 70},		{42, 22},		{61, 35},	{ 0, 0 }, ContainerType::CONTAINER_TREASURECHEST },
	// 	{ {6, 285},		{135, 69},		{43, 15},		{67, 33},	{ 0, 0 }, ContainerType::CONTAINER_DRAWER },
	// 	{ { 6, 576 },	{ 139, 105 },	{ 45, 51 },	{ 76, 37 }, { 0, 0 }, ContainerType::CONTAINER_CORPSE }
	// };

	Gump();
	virtual ~Gump();
 
	virtual void Update() override;
	virtual void Draw() override;
	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& data) override {};
	virtual void OnExit() { m_IsDead = true; }
	virtual void OnEnter();

	//  Inventory Gump


	void SetContainerId(int containerId) { m_containerId = containerId; }
	int GetContainerId() { return m_containerId; }
	void SetContainerType(int containerType) { m_containerType = containerType; }

	void SortContainer();

	virtual U7Object* GetObjectUnderMousePointer();

	// Pixel-perfect collision detection - returns true if mouse is over non-transparent pixel
	// Checks the gump's background texture for transparency
	virtual bool IsMouseOverSolidPixel(Vector2 mousePos);

	int m_containerType; // Defines the look of the gump we'll use to show this container's contents
	ContainerData m_containerData; //  The data for the container type
	int m_containerId; //  The container this gump is linked to

	bool m_isSorted;

	Vector2 m_itemsOffset;

	Gui m_gui;

	U7Object* m_containerObject;

	Vector2 m_dragStart;

	//int m_draggedObjectId = -1;
	//bool m_draggingObject = false;
	//Vector2 m_dragOffset;
	//float m_scale = 1.0f;

};

#endif