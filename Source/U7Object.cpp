#include "Globals.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "Config.h"

using namespace std;

U7Object::~U7Object()
{
	Shutdown();
}

void U7Object::Init(const string& configfile)
{
	m_Pos = glm::vec3(0, 0, 0);
	m_Scaling = glm::vec3(1, 1, 1);
	m_Angle = 0;
	m_Mesh = NULL;
	SetIsDead(false);

	m_UnitConfig = g_ResourceManager->GetConfig(configfile);

	m_Mesh = g_ResourceManager->GetMesh(m_UnitConfig->GetString("mesh"));
	m_Texture = g_ResourceManager->GetTexture(m_UnitConfig->GetString("normaltexture"));
	
}

void U7Object::SetObjectData(int objectType)
{
	m_objectData = &g_objectTable[objectType];

	if(m_objectData->m_height == 0)
			m_objectData->m_height = 1;

	m_Scaling = glm::vec3(m_objectData->m_width, m_objectData->m_height, m_objectData->m_depth);
	
}

void U7Object::Draw()
{
	if (m_isVisible && m_Mesh != NULL)
	{
		float angle = g_Display->GetCameraAngle() + 45.0f;
		g_Display->DrawMesh(m_Mesh, m_Pos, m_Texture, Color(1, 1, 1, 1), glm::vec3(0, angle, 0), m_Scaling);
	}
}

void U7Object::SetShapeAndFrame(unsigned int shape, unsigned int frame)
{

}

void U7Object::Update()
{
	//  Visilibity is set by the terrain so it should always be set to false here.
	m_isVisible = false;
}

void U7Object::Shutdown()
{

}

bool U7Object::SelectCheck()
{
	if (m_Mesh->SelectCheck(m_Pos, m_Angle, m_Scaling))
		return true;

	return false;
}