#pragma warning(disable:4786)

#ifndef _U7Object_H_
#define _U7Object_H_

#include "Globals.h"
#include "BaseUnits.h"
#include <string>
#include <list>

struct Buff;

class U7Object : public Unit3D
{

public:

	U7Object(){};
	virtual ~U7Object();

	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	virtual void Attack(int unitid);

	virtual bool SelectCheck();
   
   virtual glm::vec3 GetPos() { return m_Pos; }
   virtual glm::vec3 GetDest() { return m_Dest; }
   virtual float GetSpeed() { return m_Speed; }
   
   virtual void SetInitialPos(glm::vec3 pos) { m_Pos = pos; m_Dest = pos; }
   virtual void SetPos(glm::vec3 pos) { m_Pos = pos; }
   virtual void SetDest(glm::vec3 pos);
   virtual void SetSpeed(float speed) { m_Speed = speed; }
   
   glm::vec3 m_Pos;
   glm::vec3 m_Dest;
   glm::vec3 m_Direction;
   glm::vec3 m_Scaling;
   
   glm::vec3 m_ExternalForce;
   
   float m_Angle;
   
   unsigned int m_UnitType;
   
   bool m_Visible;
   bool m_Selected;
   
   float m_BaseSpeed;
   float m_BaseMaxHP;
   float m_BaseHP;
   float m_BaseAttack;
   float m_BaseDefense;
   float m_BaseTeam;
   
   float m_Speed;
   float m_HP;
   float m_Attack;
   float m_Defense;
   int m_Team;
   
   bool m_GravityFlag;
   bool m_ExternalForceFlag;
   bool m_BounceFlag;
   
   Mesh* m_Mesh;
   Texture* m_Texture;
   
   std::list<Buff> m_Buffs;
   
   void AddBuff(Buff buff);
};

#endif