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

struct NPCblock
{
   unsigned char x;
   unsigned char y;
   unsigned short shapeId;
   unsigned short type;
   unsigned char proba;
   unsigned short data1;
   unsigned char lift;
   unsigned short data2;



   unsigned short index;
   unsigned short referent;
   unsigned short status;
   unsigned char str;
   unsigned char dex;
   unsigned char iq;
   unsigned char combat;
   unsigned char activity;
   unsigned char DAM;
   char soak1[3];
   unsigned short status2;
   unsigned char index2;
   char soak2[2];
   unsigned int xp;
   unsigned char training;
   unsigned short primary;
   unsigned short secondary;
   unsigned short oppressor;
   unsigned short ivrx;
   unsigned short ivry;
   unsigned short svrx;
   unsigned short svry;
   unsigned short status3;
   char soak3[5];
   unsigned char acty;
   char soak4[29];
   unsigned char SN;
   unsigned char V1;
   unsigned char V2;
   unsigned char food;
   char soak5[7];
   char name[16];
};

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

   void SetNPCBlock(NPCblock block);
   
   Vector3 m_Pos;
   Vector3 m_Dest;
   Vector3 m_Direction;
   Vector3 m_Scaling;

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

   bool m_isContainer;
   bool m_isContained;
   bool m_hasConversationTree;
   bool m_hasGump;
   bool m_isEgg;

   NPCblock m_NPCData;

   std::vector<int> m_inventory; //  Each entry is the ID of an object in the object list

};

#endif