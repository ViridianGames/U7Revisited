///////////////////////////////////////////////////////////////////////////
//
// Name:     CONFIG.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  Configuration file handler.  Each class that has a configuration
//           file should declare a member object of type
//           std::map<std::string, ConfigInfo>.  The class may then load its
//           configuration data into this map by calling
//           LoadConfigFile(map, filename).
//
///////////////////////////////////////////////////////////////////////////

#ifndef _CONFIG_H_
#define _CONFIG_H_

#include <vector>
#include <string>
#include <unordered_map>

struct ConfigInfo
{
	int datatype;
	float numdata;
	std::string stringdata;
};

class Config
{
private:
	std::unordered_map<std::string, ConfigInfo> m_Config;
	std::vector<std::string> m_StringsInOrder;
	std::string m_FileName;

public:
	bool        Load(std::string filename);
	void        Save();
	void        Save(std::string filename);
	float       GetNumber(std::string node);
	std::string GetString(std::string node);
	void        SetNumber(std::string node, float number);
	void        SetString(std::string node, std::string name);

	enum
	{
		DATA_STRING = 0,
		DATA_NUMBER
	};
};

#endif
