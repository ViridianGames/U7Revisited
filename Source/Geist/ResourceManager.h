///////////////////////////////////////////////////////////////////////////
//
// Name:     RESOURCEMANAGER.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  The ResourceManager subsystem.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _RESOURCEMANAGER_H_
#define _RESOURCEMANAGER_H_

#include "Object.h"
#include "RaylibModel.h"
#include "raylib.h"
#include <memory>
#include <map>

class Config;

class ResourceManager : public Object
{
public:
	ResourceManager() {};

	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw() {};

	void ClearTextures();

	std::map<std::string, std::unique_ptr<Texture> > m_TextureList;
	std::map<std::string, std::unique_ptr<RaylibModel>> m_ModelList;
	std::map<std::string, std::unique_ptr<Wave> > m_SoundList;
	std::map<std::string, std::unique_ptr<Music> > m_MusicList;
	std::map<std::string, std::unique_ptr<Config> > m_configList;

	void AddTexture(const std::string& textureName, bool mipmaps = true);
	void AddTexture(Image& image, const std::string& textureName, bool mipmaps = true);
	void AddModel(const std::string& meshName);
	void AddModel(RaylibModel&& model, const std::string& meshName);
	void AddSound(const std::string& soundName);
	void AddMusic(const std::string& musicName);
	void AddConfig(const std::string& configName);

	//  The pointers that these functions hand out are for access ONLY.  Do not
	//  delete them.  You didn't make these resources, you have no business
	//  deleting them.
	Texture* GetTexture(const std::string& textureName, bool mipmaps = true);
	RaylibModel* GetModel(const std::string& meshname);
	Wave* GetSound(const std::string& soundname);
	Music* GetMusic(const std::string& musicname);
	Config* GetConfig(const std::string& configname);

	//  Utilities
	bool DoesFileExist(const std::string& filename);
	bool DoesTextureExist(const std::string& textureName);
};

#endif