#include "ResourceManager.h"
#include "Globals.h"
#include "Primitives.h"
#include "Config.h"
#include "Logging.h"
#include "soloud_wav.h"

#include <fstream>
#include <sstream>

using namespace std;
using namespace SoLoud;

void ResourceManager::Init(const std::string& configfile)
{

}

void ResourceManager::Shutdown()
{
	for (auto& node : m_SoundList)
	{
		delete node.second;
	}
}

void ResourceManager::Update()
{

}

bool ResourceManager::DoesFileExist(const std::string& textureName)
{
	ifstream file(textureName.c_str());
	return file.good();
}

void ResourceManager::AddTexture(const std::string& textureName, bool mipmaps)
{
	Log("Loading texture " + textureName);
	m_TextureList[textureName] = std::make_unique<Texture>();
	m_TextureList[textureName]->Load(textureName, mipmaps);
	Log("Load successful.");
}

void ResourceManager::AddMesh(const std::string& meshName)
{
	Log("Loading mesh " + meshName);
	m_MeshList[meshName] = std::make_unique<Mesh>();
	m_MeshList[meshName]->Load(meshName);
	Log("Load successful.");
}

void ResourceManager::AddSound(const std::string& soundName)
{
	Log("Loading sound " + soundName);
	m_SoundList[soundName] = new SoLoud::Wav;
	m_SoundList[soundName]->load(soundName.c_str());
	Log("Load successful.");
}

void ResourceManager::AddConfig(const std::string& configName)
{
	Log("Loading config " + configName);
	m_configList[configName] = std::make_unique<Config>();
	m_configList[configName]->Load(configName);
	Log("Load successful.");
}

Texture* ResourceManager::GetTexture(const std::string& Texturename, bool mipmaps)
{
	map<std::string, unique_ptr<Texture> >::iterator node;
	node = m_TextureList.find(Texturename);

	if (node != m_TextureList.end())
	{
		return (*node).second.get();
	}
	else
	{
		Log("Loading texture " + Texturename + " on the fly!");
		AddTexture(Texturename, mipmaps);
		return m_TextureList[Texturename].get();
	}
}

void ResourceManager::ReloadTextures()
{
	map<string, unique_ptr<Texture>>::iterator node = m_TextureList.begin();

	for (node; node != m_TextureList.end(); ++node)
	{
		if ((*node).second->WasLoaded())
			(*node).second->Load((*node).first, (*node).second->IsMipMapped());
	}
}

Mesh* ResourceManager::GetMesh(const std::string& meshName)
{
	map<std::string, unique_ptr<Mesh> >::iterator node;
	node = m_MeshList.find(meshName);

	if (node != m_MeshList.end())
	{
		return (*node).second.get();
	}
	else
	{
		Log("Loading mesh " + meshName + " on the fly!");
		AddMesh(meshName);
		return m_MeshList[meshName].get();
	}
}

SoLoud::Wav* ResourceManager::GetSound(const std::string& soundName)
{
	map<std::string, SoLoud::Wav* >::iterator node;
	node = m_SoundList.find(soundName);

	if (node != m_SoundList.end())
	{
		return (*node).second;
	}
	else
	{
		Log("Loading sound " + soundName + " on the fly!");
		AddSound(soundName);
		return m_SoundList[soundName];
	}
}

Config* ResourceManager::GetConfig(const std::string& configName)
{
	map<std::string, unique_ptr<Config> >::iterator node;
	node = m_configList.find(configName);
	if (node != m_configList.end())
	{
		return (*node).second.get();
	}
	else
	{
		Log("Loading config " + configName + " on the fly!");
		AddConfig(configName);
		return m_configList[configName].get();
	}
}

//  Dumps the current texture list so it can be recreated (on res change or whatever)
void ResourceManager::ClearTextures()
{
	m_TextureList.clear();
}
