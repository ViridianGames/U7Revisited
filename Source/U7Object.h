#ifndef _U7OBJECT_H_
#define _U7OBJECT_H_

#include "Geist/Globals.h"
#include "Geist/BaseUnits.h"
#include <string>
#include <list>
#include "lua.h"

enum class ObjectTypes;
enum class ShapeDrawType;
class ShapeData;
struct NPCData;

class U7Object : public Unit3D
{

public:

   U7Object() {};
   virtual ~U7Object();

   virtual void Init(const std::string& configfile, int unitType, int frame);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void Attack(int unitid);

   virtual Vector3 GetPos() { return m_Pos; }
   virtual Vector3 GetDest() { return m_Dest; }
   virtual float GetSpeed() { return m_speed; }

   void SetInitialPos(Vector3 pos) { SetPos(pos); SetDest(pos); }
   virtual void SetPos(Vector3 pos);
   virtual void SetDest(Vector3 pos);
   virtual void SetSpeed(float speed) { m_speed = speed; }

   void Interact(int event);


   float Pick(); //  Returns distance if hit, -1 if no hit

   bool AddObjectToInventory(int objectid);
   bool RemoveObjectFromInventory(int objectid);

   bool IsInInventory(int objectid);
   bool IsInInventory(int shape, int frame);

   void NPCUpdate();
   void NPCDraw();
   void NPCInit(NPCData* npcData);
  
   Vector3 m_Pos;
   Vector3 m_Dest;
   Vector3 m_Direction;
   Vector3 m_Scaling;
   Vector3 m_anchorPos;
   bool m_isMoving = false;

   Vector3 m_ExternalForce;

   float m_Angle;

   int m_ObjectType;
   int m_Frame;
   int m_Quality;

   bool m_Visible;
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

   double m_distanceFromCamera;

   Color m_color = WHITE;

   BoundingBox m_boundingBox;

   bool m_isNPC;
   bool m_isContainer;
   bool m_isContained;
   bool m_hasConversationTree;
   bool m_hasGump;
   bool m_isEgg;

   int m_NPCID;

   Vector2 m_GumpPos;
   bool m_isSorted = false;
   bool m_shouldBeSorted = true;

	NPCData* m_NPCData = nullptr;

   int m_lastSchedule = -1;


   std::vector<int> m_inventory; //  Each entry is the ID of an object in the object list

};

#endif