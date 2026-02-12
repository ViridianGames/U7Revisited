#include <Geist/ResourceManager.h>
#include <Geist/Config.h>
#include <Geist/Logging.h>
#include <Geist/Globals.h>
#include <raylib.h>
#include <raymath.h>

#include <fstream>
#include <sstream>

using namespace std;

// Initialize static members
std::string ResourceManager::s_audioPath = "Audio/";

void ResourceManager::Init(const std::string& configfile)
{
	Config config;
	config.Load(configfile);

	// Load AudioPath from config if present
	std::string audioPath = config.GetString("AudioPath");
	if (!audioPath.empty())
	{
		s_audioPath = audioPath;
		Log("ResourceManager: AudioPath set to: " + s_audioPath);
	}
}

void ResourceManager::Shutdown()
{
	for (auto node = m_TextureList.begin(); node != m_TextureList.end(); ++node)
	{
		UnloadTexture(*(*node).second);
	}

	map<std::string, unique_ptr<Sound> >::iterator node2;
	for (auto node = m_SoundList.begin(); node != m_SoundList.end(); ++node)
	{
		UnloadSound(*(*node).second);
	}

	map<std::string, unique_ptr<Music> >::iterator node4;
	for (auto node = m_MusicList.begin(); node != m_MusicList.end(); ++node)
	{
		UnloadMusicStream(*(*node).second);
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

	// Log texture info to verify it loaded correctly
	Texture* tex = m_TextureList[textureName].get();
	Log("Texture ID: " + std::to_string(tex->id) + ", Width: " + std::to_string(tex->width) + ", Height: " + std::to_string(tex->height));

	if (tex->id == 0 || tex->width == 0 || tex->height == 0)
	{
		Log("WARNING: Texture failed to load properly - file may not exist at path: " + textureName);
	}
	else
	{
		Log("Load successful.");
	}
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
	std::string fullPath = s_audioPath + soundName;
	Log("Loading sound " + fullPath);
	Wave wave = LoadWave(soundName.c_str());
	m_SoundList[soundName] = std::make_unique<Sound>(LoadSoundFromWave(wave));
	UnloadWave(wave);
	Log("Load successful.");
}

void ResourceManager::AddMusic(const std::string& musicName)
{
	Log("Loading music " + musicName);
	m_MusicList[musicName] = std::make_unique<Music>(LoadMusicStream(musicName.c_str()));
	if (m_MusicList[musicName].get()->ctxData == nullptr)
	{
		m_MusicList.erase(musicName);
		Log("Load unsuccessful!");
	}
	else
	{
		Log("Load successful.");
	}
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

Sound* ResourceManager::GetSound(const std::string& soundName)
{
	map<std::string, unique_ptr<Sound> >::iterator node;
	node = m_SoundList.find(soundName);

	if (node != m_SoundList.end())
	{
		return (*node).second.get();
	}
	else
	{
		AddSound(soundName);
		// if (IsSoundReady(*m_SoundList[soundName].get()))
		// {
			return m_SoundList[soundName].get();
		// }
		// else
		// {
		// 	m_SoundList.erase(soundName); // The sound didn't load correctly.
		// 	return nullptr;
		// }
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

	AddMusic(musicName);
	if (m_MusicList.find(musicName) != m_MusicList.end())
	{
		return m_MusicList[musicName].get();
	}

	return nullptr;
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

//  Reloads a specific texture from disk (useful for hot-reloading during development)
void ResourceManager::ReloadTexture(const std::string& textureName)
{
	auto it = m_TextureList.find(textureName);
	if (it != m_TextureList.end())
	{
		Log("Reloading texture: " + textureName);

		// Unload the old texture from GPU
		UnloadTexture(*it->second);

		// Load the new texture from disk and store it IN-PLACE in the same Texture object
		// This preserves the pointer that existing Sprite objects are holding
		*it->second = LoadTexture(textureName.c_str());

		// Verify it loaded correctly
		Texture* tex = it->second.get();
		if (tex->id == 0 || tex->width == 0 || tex->height == 0)
		{
			Log("WARNING: Texture failed to reload - file may not exist at path: " + textureName);
		}
		else
		{
			Log("Reload successful. New size: " + std::to_string(tex->width) + "x" + std::to_string(tex->height));
		}
	}
	else
	{
		Log("WARNING: Cannot reload texture '" + textureName + "' - not currently loaded");
	}
}

//  Reloads all currently loaded textures from disk
void ResourceManager::ReloadAllTextures()
{
	Log("Reloading all textures (" + std::to_string(m_TextureList.size()) + " total)...");

	// Build list of texture names first (to avoid iterator invalidation)
	std::vector<std::string> textureNames;
	for (const auto& [name, texture] : m_TextureList)
	{
		textureNames.push_back(name);
	}

	// Reload each texture
	for (const std::string& name : textureNames)
	{
		ReloadTexture(name);
	}

	Log("All textures reloaded.");
}

void ResourceManager::AddModel(RaylibModel&& model, const std::string& meshName)
{
	m_ModelList[meshName] = std::make_unique<RaylibModel>(std::move(model));
}
