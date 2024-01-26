///////////////////////////////////////////////////////////////////////////
//
// Name:     PARICLESYSTEM.H
// Author:   Anthony Salter
// Date:     11/13/2017
// Purpose:  A particle system is a standalone (IE, not part of Engine)
//           subsystem.  Other parts of the code add emitters to it
//           and it updates and draws those emitters (which in turn update
//           and draw their particles).
//
//           Emitters can be 2D, which are sprite-based, or 3D, which use
//           OpenGL point sprites to draw.  You can have 2D and 3D
//           emitters in the same particle system, it doesn't care.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _PARTICLESYSTEM_H_
#define _PARTICLESYSTEM_H_

#include "BaseUnits.h"
#include "Primitives.h"
#include "RNG.h"
#include <memory>

class Particle2D
{
public:
	Point m_Pos;
	Point m_Speed;
	float m_Scale = 1;
	float m_Angle = 0;
	float m_AngularVelocity = 0;
	Color m_StartColor = Color(1, 1, 1, 1);
	Color m_EndColor = Color(1, 1, 1, 1);
	unsigned int m_Birth = 0;
	unsigned int m_Age = 0;
	unsigned int m_MaxAge = 1000;
	bool m_IsDead = false;
	bool m_Perturb;
	int  m_Sprite;
};

class Emitter2D : public Unit2D
{
public:
	Emitter2D() {};
	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& configfile);
	void Shutdown();
	void Update();
	void Draw();
	void Start(); //  Start this emitter emitting;
	void Stop() { m_Started = false; } //  Stop the emitter.  It won't emit any more particles but particles already in existance will still be updated and drawn.
	void AddSprite(std::shared_ptr<Sprite> sprite); // Adds a sprite to the list of sprites that can be used for this emitter. Adding a particle will choose a random sprite from the list.
	void AddParticle(Particle2D particle);
	void AddParticle(Point pos, Point vel, unsigned int maxage, Color startcolor = Color(1, 1, 1, 1),
		Color endcolor = Color(1, 1, 1, 1), float rotation = 0, float scale = 1);
	void SetTexture(Texture* texture) { m_Texture = texture; }
	void SetColorMask(Color color) { m_ColorMask = color; }
	Point                    m_DrawOffset; // Just in case our position doesn't match our screen coordinates.
	std::vector<Particle2D>               m_Particles;
private:
	std::vector<std::shared_ptr<Sprite> > m_Sprites;
	Texture* m_Texture; // The same texture will be used for all particles from this emitter.

	bool  m_Started;
	bool  m_DieOnEmpty; // This emitter will be destroyed when all the particles in it have died.
	RNG   m_RNG;
	Color m_ColorMask = Color(1, 1, 1, 1);
};

/*class Emitter3D : public Unit
{
public:
   Emitter3D();

   void Init(const std::string& configfile);
   void Shutdown() {};
   void Update();
   void Draw();
   void AddParticle(glm::vec3 pos, glm::vec3 vel, glm::vec3 acc,
	  unsigned int maxage, Color startcolor = Color(1, 1, 1, 1),
	  Color endcolor = Color(1, 1, 1, 1), float rotation = 0, glm::vec3 scale = glm::vec3(1, 1, 1));

private:
   std::vector<Particle3D> m_Particles;

};

class Particle3D
{
public:
   glm::vec3 m_Pos;
   glm::vec3 m_Speed;
   glm::vec3 m_ExternalForce;
   glm::vec3 m_Scale;
   float m_Angle;
   float m_AngularVelocity;  //  This is a delta that will be applied per update
   Color m_StartColor;
   Color m_EndColor;
   unsigned int m_Age; //  In milliseconds
   unsigned int m_MaxAge; //  When Age > MaxAge, autodeath
   bool m_IsDead;
   bool m_Perturb;
};



enum PS_UPDATETYPES
{
   PS_NOALTERATION = 0, //  Uses the values just as given
   PS_OSCILLATE,        //  "Drifts" back and forth along the line of the values given.
   PS_LASTUPDATETYPE
};*/

//  Okay, this encapsulates a particle system that uses a single texture
class ParticleSystem : public Object
{
public:
	ParticleSystem() {};
	void Init() { Init(std::string("")); }
	void Init(const std::string& configfile);
	void Shutdown();
	void Update();
	void Draw();
	void AddEmitter(std::shared_ptr<Emitter2D> emitter);
	std::vector<std::shared_ptr<Emitter2D> > m_Emitters;
	void ClearEmitters() { m_Emitters.clear(); }

	Point m_Pos;
};

#endif