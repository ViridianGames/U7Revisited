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

class Gump : public Object
{
public:

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
		{ { 6, 12 },	{ 151, 88 },	{ 47, 31 },		{ 76, 72 }, { 0, 0 }, ContainerType::CONTAINER_BOX },
		{ { 161, 12 },	{ 169, 68 },	{ 54, 19 },	{ 85, 31 }, { 0, 0 }, ContainerType::CONTAINER_CRATE },
		{ {968, 12 },	{ 131, 118 },	{ 27, 26 },	{ 64, 65 }, { 0, 0 }, ContainerType::CONTAINER_BARREL	},
		{ {6, 176 },	{ 155, 97 },	{ 54, 22 },	{ 60, 38 }, { 0, 0 }, ContainerType::CONTAINER_BAG },
		{ {166, 177},	{145, 102},		{45, 38},		{75, 42},	{ 0, 0 }, ContainerType::CONTAINER_BACKPACK },
		{ {316, 176},	{141, 80},		{49, 34},		{66, 26},	{ 0, 0 }, ContainerType::CONTAINER_BASKET },
		{ {735, 176},	{117, 70},		{42, 22},		{61, 35},	{ 0, 0 }, ContainerType::CONTAINER_TREASURECHEST },
		{ {6, 285},		{135, 69},		{43, 15},		{67, 33},	{ 0, 0 }, ContainerType::CONTAINER_DRAWER },
		{ { 6, 576 },	{ 139, 105 },	{ 45, 51 },	{ 76, 37 }, { 0, 0 }, ContainerType::CONTAINER_CORPSE }
	};

	Gump();
	virtual ~Gump();
 
	virtual void Update() override;
	virtual void Draw() override;
	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& data) override {};
	virtual void OnExit() { m_isDone = true; }
	virtual void OnEnter();

	void SetContainerId(int containerId) { m_containerId = containerId; }
	int GetContainerId() { return m_containerId; }
	void SetContainerType(int containerType) { m_containerType = containerType; }

	void SortContainer();

	int m_containerType; // Defines the look of the gump we'll use to show this container's contents
	ContainerData m_containerData; //  The data for the container type
	int m_containerId; //  The container this gump is linked to

	bool m_isSorted;

	Vector2 m_itemsOffset;

	Gui m_gui;

	U7Object* m_containerObject;

	bool m_isDone = false;

	int m_draggedObjectId = -1;
	bool m_draggingObject = false;
	Vector2 m_dragOffset;
	float m_scale = 1.0f;

};

#endif