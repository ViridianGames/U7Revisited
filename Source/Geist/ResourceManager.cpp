#include "ResourceManager.h"
#include "Config.h"
#include "Logging.h"
#include "Globals.h"
#include "raylib.h"
#include "raymath.h"

#include <fstream>
#include <sstream>

using namespace std;

void ResourceManager::Init(const std::string& configfile)
{

}

void ResourceManager::Shutdown()
{
	map<std::string, unique_ptr<Texture> >::iterator node;
	for (node = m_TextureList.begin(); node != m_TextureList.end(); ++node)
	{
		UnloadTexture(*(*node).second);
	}

	map<std::string, unique_ptr<Wave> >::iterator node3;
	for (node3 = m_SoundList.begin(); node3 != m_SoundList.end(); ++node3)
	{
		UnloadWave(*(*node3).second);
	}

	map<std::string, unique_ptr<Music> >::iterator node4;
	for (node4 = m_MusicList.begin(); node4 != m_MusicList.end(); ++node3)
	{
		UnloadMusicStream(*(*node4).second);
	}
}

void ResourceManager::Update()
{

}

bool ResourceManager::DoesFileExist(const std::string& fileName)
{
	map<std::string, unique_ptr<Texture> >::iterator node;
	node = m_TextureList.find(fileName);

	if (node == m_TextureList.end())
	{
		ifstream file(fileName.c_str());
		return file.good();
	}
	else
	{
		return true;
	}
}

bool ResourceManager::DoesTextureExist(const std::string& textureName)
{
	map<std::string, unique_ptr<Texture> >::iterator node;
	node = m_TextureList.find(textureName);

	return (node != m_TextureList.end());
}

void ResourceManager::AddTexture(const std::string& textureName, bool mipmaps)
{
	Log("Loading texture " + textureName);
	m_TextureList[textureName] = std::make_unique<Texture>(LoadTexture(textureName.c_str()));
	Log("Load successful.");	
}

void ResourceManager::AddTexture(Image& image, const std::string& textureName, bool mipmaps)
{
	Log("Loading texture " + textureName);
	m_TextureList[textureName] = std::make_unique<Texture>(LoadTextureFromImage(image));
	Log("Load successful.");
}

void ResourceManager::AddModel(const std::string& modelName)
{
	Log("Loading model " + modelName);
	m_ModelList[modelName] = std::make_unique<RaylibModel>(modelName);
	Log("Load successful.");
}

void ResourceManager::AddSound(const std::string& soundName)
{
	Log("Loading sound " + soundName);
	m_SoundList[soundName] = std::make_unique<Wave>(LoadWave(soundName.c_str()));
	Log("Load successful.");
}

void ResourceManager::AddMusic(const std::string& musicName)
{
	Log("Loading music " + musicName);
	m_MusicList[musicName] = std::make_unique<Music>(LoadMusicStream(musicName.c_str()));
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

RaylibModel* ResourceManager::GetModel(const std::string& modelName)
{
	map<std::string, unique_ptr<RaylibModel> >::iterator node;
	node = m_ModelList.find(modelName);

	if (node != m_ModelList.end())
	{
		return (*node).second.get();
	}
	else
	{
		Log("Loading model " + modelName + " on the fly!");
		AddModel(modelName);
		return m_ModelList[modelName].get();
	}
}

Wave* ResourceManager::GetSound(const std::string& soundName)
{
	map<std::string, unique_ptr<Wave> >::iterator node;
	node = m_SoundList.find(soundName);

	if (node != m_SoundList.end())
	{
		return (*node).second.get();
	}
	else
	{
		Log("Loading sound " + soundName + " on the fly!");
		AddSound(soundName);
		return m_SoundList[soundName].get();
	}
}

Music* ResourceManager::GetMusic(const std::string& musicName)
{
	map<std::string, unique_ptr<Music> >::iterator node;
	node = m_MusicList.find(musicName);

	if (node != m_MusicList.end())
	{
		return (*node).second.get();
	}
	else
	{
		Log("Loading music " + musicName + " on the fly!");
		AddMusic(musicName);
		return m_MusicList[musicName].get();
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

void ResourceManager::AddModel(RaylibModel&& model, const std::string& meshName)
{
	m_ModelList[meshName] = std::make_unique<RaylibModel>(std::move(model));
}
