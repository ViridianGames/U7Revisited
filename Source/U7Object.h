#ifndef _U7OBJECT_H_
#define _U7OBJECT_H_

#include "Geist/Globals.h"
#include "Geist/BaseUnits.h"
#include <string>
#include <list>
#include "lua.h"
#include "U7Globals.h"

struct ObjectData;
enum class ObjectTypes;
enum class ShapeDrawType;
class ShapeData;
struct NPCData;

class U7Object : public Unit3D
{
public:

	enum class UnitTypes
	{
		UNIT_TYPE_STATIC = 0, // Static objects cannot be changed.  They cannot be moved, created or destroyed. They may have animations or lighting effects but are otherwise unchanging.  They do not have inventories or scripts.
		UNIT_TYPE_OBJECT,     // Generic object, can be moved, created and destroyed.  May have an inventory.  May have an attached Lua script.  Clever use of scripts can make these objects behave like NPCs, but that should be discouraged.
		UNIT_TYPE_NPC,        // Non-player character, can move, can have schedules and conversations, and has an inventory.  May have an attached Lua script.  Monsters are considered NPCs.
		UNIT_TYPE_EGG,        // "Eggs" are what would be called "triggers" in later games.  They are invisible, intangible objects that "hatch" and run scripts when the player interacts with them or enters their bounding box.
		UNIT_TYPE_LAST
	};

   U7Object() {};
   virtual ~U7Object();

   virtual void Init(const std::string& configfile, int unitType, int frame);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void Attack(int unitid);

   virtual Vector3 GetPos() { return m_Pos; }
	virtual Vector2 GetChunkPos() { return Vector2{ floor(m_Pos.x / 16), floor(m_Pos.z / 16) }; }
   virtual Vector3 GetDest() { return m_Dest; }
   virtual float GetSpeed() { return m_speed; }

   void SetInitialPos(Vector3 pos);
   virtual void SetPos(Vector3 pos);
   virtual void SetDest(Vector3 pos);
   void PathfindToDest(Vector3 dest);  // Use A* pathfinding to reach dest
   virtual void SetSpeed(float speed) { m_speed = speed; }
   void SetFrame(int frame);  // Change object frame (e.g., for doors)

   void Interact(int event);

   float Pick(); //  Returns distance if hit, -1 if no hit
	float PickXYZ(Vector3& pos); // Returns distance and hit point in pos.

   bool AddObjectToInventory(int objectid);
   bool RemoveObjectFromInventory(int objectid);

   bool IsInInventoryById(int objectid);
   bool IsInInventory(int shape, int frame = -1, int quality = -1);

   void NPCUpdate();
   void NPCDraw();
   void NPCInit(NPCData* npcData);
   void TryOpenDoorAtCurrentPosition();

	void CheckLighting();

	bool IsLocked();
	bool IsMagicLocked();

	void SetFrames(int framex, int framey) { m_currentFrameX = framex; m_currentFrameY = framey; }
  
   Vector3 m_Pos;
   Vector3 m_Dest;
   Vector3 m_Direction;
   Vector3 m_Scaling;
   Vector3 m_anchorPos;
   bool m_isMoving = false;

   // Pathfinding
   std::vector<Vector3> m_pathWaypoints;  // Queue of waypoints to follow
   int m_currentWaypointIndex = 0;         // Which waypoint we're moving toward

   Vector3 m_ExternalForce;

   float m_Angle;

	UnitTypes m_UnitType = UnitTypes::UNIT_TYPE_OBJECT;
   int m_ObjectType;
   int m_Frame;
   int m_Quality;

   bool m_Visible; // This is set to false for objects that are out of range or otherwise not visible
	bool m_ShouldDraw = true; // This is an override that can be set in a Lua script.
   bool m_Selected;

   float m_BaseSpeed;
   float m_BaseMaxHP;
   float m_BaseHP;
   float m_BaseAttack;
   float m_BaseDefense;
   float m_BaseTeam;

   float m_speed;
   float m_hp;
   float m_combat;
   float m_magic;
   int m_Team;

   bool m_GravityFlag;
   bool m_ExternalForceFlag;
   bool m_BounceFlag;

   Mesh* m_Mesh;
   Texture* m_Texture;
   Texture* m_DropShadow;
   std::unique_ptr<Mesh> m_customMesh = nullptr;

   Config* m_ObjectConfig;

   ShapeDrawType m_drawType;
   ShapeData* m_shapeData;
	ObjectData* m_objectData;

   double m_distanceFromCamera;

   Color m_color = WHITE;

   BoundingBox m_boundingBox;
	Vector3 m_terrainCenterPoint;
	Vector3 m_centerPoint;

   bool m_isNPC;
   bool m_isContainer;
   bool m_isContained;
	int m_containingObjectId;
   bool m_hasConversationTree;
   bool m_hasGump;
   bool m_isEgg;

   int m_NPCID;

	bool m_isLit = true;

   Vector2 m_InventoryPos;
   bool m_isSorted = false;
   bool m_shouldBeSorted = true;

	NPCData* m_NPCData = nullptr;

	bool m_followingSchedule = false;
   int m_lastSchedule = -1;
	int m_currentFrameX = 0;
	int m_currentFrameY = 0;

   std::vector<int> m_inventory; //  Each entry is the ID of an object in the object list
};

#endif