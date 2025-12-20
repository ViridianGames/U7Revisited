#include <raylib.h>
#include <list>
#include <Geist/Globals.h>
#include <Geist/ResourceManager.h>
#include <Geist/Config.h>
#include <Geist/BaseUnits.h>

using namespace std;

//  Unit2D
void Unit2D::Init(const string& configfile)
{
	m_UnitConfig = g_ResourceManager->GetConfig(configfile);
}

void Unit2D::Update()
{

}

void Unit2D::Draw()
{

}

void Unit2D::Shutdown()
{

}

//  Unit3D
void Unit3D::Init(const string& configfile)
{
	m_UnitConfig = g_ResourceManager->GetConfig(configfile);
}

void Unit3D::Update()
{

}

void Unit3D::Draw()
{

}

void Unit3D::Shutdown()
{

}