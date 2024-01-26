#include "ParticleSystem.h"
#include "Globals.h"

using namespace std;

void Emitter2D::Init(const std::string& configfile)
{
	m_Started = false;
	m_RNG.SeedRNG(g_Engine->GameTimeInMS());
}

void Emitter2D::Shutdown()
{
	m_Sprites.clear();
	m_Particles.clear();
};

void Emitter2D::Update()
{
	if (m_Started)
	{
		vector<Particle2D>::iterator node = m_Particles.begin();

		for (node; node != m_Particles.end(); )
		{
			Particle2D& temp = (*node);

			temp.m_Angle += temp.m_AngularVelocity;
			temp.m_Pos.X += temp.m_Speed.X * g_Engine->LastUpdateInSeconds();
			temp.m_Pos.Y += temp.m_Speed.Y * g_Engine->LastUpdateInSeconds();
			temp.m_Age += g_Engine->LastUpdateInMS();

			if (temp.m_Age > temp.m_MaxAge)
			{
				temp.m_IsDead = true;
			}

			if (temp.m_IsDead)
			{
				node = m_Particles.erase(node);
			}
			else
				++node;
		}
	}
}

void Emitter2D::Start()
{
	m_Started = true;
}

void Emitter2D::Draw()
{
	if (!m_Started)
		return;
	vector<Particle2D>::iterator node = m_Particles.begin();
	for (node; node != m_Particles.end(); ++node)
	{
		Particle2D& temp = (*node);

		float drawx = (m_Pos.X + temp.m_Pos.X - m_DrawOffset.X) * temp.m_Scale + (g_Display->GetWidth() / 2);
		float drawy = (m_Pos.Y + temp.m_Pos.Y - m_DrawOffset.Y) * temp.m_Scale + (g_Display->GetHeight() / 2);

		Color c;
		float pct = 0;
		if (temp.m_MaxAge > 0)
			pct = (float)(temp.m_Age - temp.m_Birth) / (float)(temp.m_MaxAge - temp.m_Birth);
		if (pct > 1.0f) pct = 1.0f;
		if (pct < 0) pct = 0;
		c.r = (temp.m_StartColor.r * (1.0f - pct) + temp.m_EndColor.r * pct) * m_ColorMask.r;
		c.g = (temp.m_StartColor.g * (1.0f - pct) + temp.m_EndColor.g * pct) * m_ColorMask.g;
		c.b = (temp.m_StartColor.b * (1.0f - pct) + temp.m_EndColor.b * pct) * m_ColorMask.b;
		c.a = (temp.m_StartColor.a * (1.0f - pct) + temp.m_EndColor.a * pct) * m_ColorMask.a;

		g_Display->DrawSpriteScaled(m_Sprites[temp.m_Sprite], drawx, drawy, temp.m_Scale, temp.m_Scale, c, false, temp.m_Angle);
	}
}

void Emitter2D::AddSprite(shared_ptr<Sprite> sprite)
{
	m_Sprites.push_back(sprite);
}

void Emitter2D::AddParticle(Point pos, Point vel, unsigned int maxage, Color startcolor,
	Color endcolor, float rotation, float scale)
{
	Particle2D temp;

	temp.m_Pos = pos;
	temp.m_Speed = vel;
	temp.m_StartColor = startcolor;
	temp.m_EndColor = endcolor;
	temp.m_Birth = g_Engine->Time();
	temp.m_Age = temp.m_Birth;
	temp.m_MaxAge = g_Engine->Time() + maxage;
	temp.m_IsDead = false;
	temp.m_Scale = scale;
	temp.m_AngularVelocity = rotation;
	temp.m_Angle = 0;

	m_Particles.push_back(temp);
}

void Emitter2D::AddParticle(Particle2D particle)
{
	particle.m_Sprite = m_RNG.Random(int(m_Sprites.size()) - 1); // Assign a random sprite to this particle
	m_Particles.push_back(particle);
}

/*void Emitter3D::AddParticle(glm::vec3 pos, glm::vec3 vel, glm::vec3 acc,
			 unsigned int maxage, Color startcolor, Color endcolor, float rotation, glm::vec3 scale )
{
   Particle3D temp;

   temp.m_Pos = m_Pos + pos;
   temp.m_Speed = vel;
   temp.m_ExternalForce = acc;
   temp.m_StartColor = startcolor;
   temp.m_EndColor = endcolor;
   temp.m_Age = g_Engine->Time();
   temp.m_MaxAge = g_Engine->Time() + maxage;
   temp.m_IsDead = false;
   temp.m_Scale = scale;
   temp.m_AngularVelocity = rotation;
   temp.m_Angle = 0;

   m_Particles.push_back(temp);
   ++m_NumParticles;
}*/

void ParticleSystem::Init(const std::string& configfile)
{

}

void ParticleSystem::Shutdown()
{
	m_Emitters.clear();
}

void ParticleSystem::Update()
{
	vector<shared_ptr<Emitter2D> >::iterator node = m_Emitters.begin();

	for (node; node != m_Emitters.end(); )
	{
		(*node)->m_DrawOffset = m_Pos;
		(*node)->Update();
		if ((*node)->GetIsDead())
			node = m_Emitters.erase(node);
		else
			++node;
	}
}

void ParticleSystem::Draw()
{
	vector<shared_ptr<Emitter2D> >::iterator node = m_Emitters.begin();

	for (node; node != m_Emitters.end(); ++node)
	{
		(*node)->Draw();
	}
}

void ParticleSystem::AddEmitter(shared_ptr<Emitter2D> emitter)
{
	m_Emitters.push_back(emitter);
}

/*   vector<Particle>::iterator node = m_Particles.begin();

   for(node; node != m_Particles.end(); ++node)
   {
	  if (g_Display->GetDrawMode() == DM_2D)
	  {
		 g_Display->DrawImage(m_Texture,
			0, 0,
			m_Texture->GetWidth(), m_Texture->GetHeight(),
			(*node).m_Pos.x, (*node).m_Pos.y,
			m_Texture->GetWidth() * (*node).m_Scale.x, m_Texture->GetHeight() * (*node).m_Scale.y,
			(*node).m_StartColor, false, (*node).m_Angle);
	  }
	  else
	  {
		 g_Display->DrawMesh(m_Mesh, (*node).m_Pos, m_Texture, (*node).m_StartColor, glm::vec3(0, g_Display->GetCameraAngle() + 45, (*node).m_Angle), (*node).m_Scale);
	  }
   }
}*/