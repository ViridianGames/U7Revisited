///////////////////////////////////////////////////////////////////////////
//
// Name:     TestDataLoader.h
// Date:     01/26/2025
// Purpose:  Minimal game data loader for script testing (headless mode)
//
///////////////////////////////////////////////////////////////////////////

#ifndef _TESTDATALOADER_H_
#define _TESTDATALOADER_H_

#include <string>

// Load essential game data without requiring graphics initialization
// This is a simplified version of LoadingState that works in headless mode
class TestDataLoader
{
public:
    TestDataLoader();
    ~TestDataLoader();

    // Load the minimum data needed for scripts to run
    bool LoadEssentialData();

private:
    // Helper functions for loading specific data files
    bool LoadShapeTableMetadata();  // Load shapetable.dat (text file, no graphics needed)
    bool LoadNPCData();              // Load NPC data from INITGAME.DAT
    bool CreateBasicObjects();       // Create minimal objects in g_objectList

    std::string m_dataPath;
};

#endif
