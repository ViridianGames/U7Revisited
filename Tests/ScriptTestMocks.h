///////////////////////////////////////////////////////////////////////////
//
// Name:     ScriptTestMocks.h
// Date:     01/26/2025
// Purpose:  Header for mock implementations of game globals
//
///////////////////////////////////////////////////////////////////////////

#ifndef _SCRIPTTESTMOCKS_H_
#define _SCRIPTTESTMOCKS_H_

// Initialize mock global pointers for testing
void InitializeMockGlobals();

// Load essential game data (shapes, objects, NPCs)
bool LoadEssentialGameData();

// Clean up allocated mock globals
void CleanupMockGlobals();

#endif
