#include "ParticleSystem.h"
#include "Globals.h"

using namespace std;

void Emitter2D::Init(const std::string& configfile)
{
	m_Started = false;
	m_RNG.SeedRNG(GetTime());
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
			temp.m_Pos.x += temp.m_Speed.x * GetFrameTime();
			temp.m_Pos.y += temp.m_Speed.y * GetFrameTime();
			temp.m_Age += GetFrameTime();

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

		float drawx = (GetPos().x + temp.m_Pos.x - m_DrawOffset.x) * temp.m_Scale + (GetScreenWidth() / 2);
		float drawy = (GetPos().y + temp.m_Pos.y - m_DrawOffset.y) * temp.m_Scale + (GetScreenHeight() / 2);

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

		m_Sprites[temp.m_Sprite]->DrawScaled( Rectangle{drawx, drawy, temp.m_Scale, temp.m_Scale}, Vector2{0, 0}, temp.m_Angle, c);
	}
}

void Emitter2D::AddSprite(shared_ptr<Sprite> sprite)
{
	m_Sprites.push_back(sprite);
}

void Emitter2D::AddParticle(Vector2 pos, Vector2 vel, unsigned int maxage, Color startcolor,
	Color endcolor, float rotation, float scale)
{
	Particle2D temp;

	temp.m_Pos = pos;
	temp.m_Speed = vel;
	temp.m_StartColor = startcolor;
	temp.m_EndColor = endcolor;
	temp.m_Birth = GetTime();
	temp.m_Age = temp.m_Birth;
	temp.m_MaxAge = GetTime() + maxage;
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

/*void Emitter3D::AddParticle(Vector3 pos, Vector3 vel, Vector3 acc,
			 unsigned int maxage, Color startcolor, Color endcolor, float rotation, Vector3 scale )
{
   Particle3D temp;

   temp.m_Pos = m_Pos + pos;
   temp.m_Speed = vel;
   temp.m_ExternalForce = acc;
   temp.m_StartColor = startcolor;
   temp.m_EndColor = endcolor;
   temp.m_Age = GetTime();
   temp.m_MaxAge = GetTime() + maxage;
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
	  if (GetDrawMode() == DM_2D)
	  {
		 DrawImage(m_Texture,
			0, 0,
			m_Texture->width, m_Texture->height,
			(*node).m_Pos.x, (*node).m_Pos.y,
			m_Texture->width * (*node).m_Scale.x, m_Texture->height * (*node).m_Scale.y,
			(*node).m_StartColor, false, (*node).m_Angle);
	  }
	  else
	  {
		 DrawMesh(m_Mesh, (*node).m_Pos, m_Texture, (*node).m_StartColor, Vector3(0, GetCameraAngle() + 45, (*node).m_Angle), (*node).m_Scale);
	  }
   }
}*/