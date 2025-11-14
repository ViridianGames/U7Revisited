#ifndef _U7SCRIPTUTILS_H_
#define _U7SCRIPTUTILS_H_

#include <string>

// Utility functions for script management
namespace U7ScriptUtils
{
	// Rename a Lua script file and update all references in the shape table
	// oldScript: current script name (without .lua extension)
	// newName: new script name (without .lua extension)
	void RenameScript(const std::string& oldScript, const std::string& newName);
}

#endif
