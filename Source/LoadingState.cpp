#include "Geist/Globals.h"
#include "Geist/StateMachine.h"
#include "Geist/Logging.h"
#include "Geist/Engine.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"
#include "LoadingState.h"



#include <list>
#include <string>
#include <sstream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <algorithm>
#include <unordered_map>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  LoadingState
////////////////////////////////////////////////////////////////////////////////

LoadingState::~LoadingState()
{
	Shutdown();
}

void LoadingState::Init(const string& configfile)
{
	g_minimapSize = GetRenderWidth() / 6;

	MakeAnimationFrameMeshes();

	m_red = 1.0;
	m_angle = 0.0;

	xSlant = .01;

}

void LoadingState::OnEnter()
{

}

void LoadingState::OnExit()
{

}

void LoadingState::Shutdown()
{

}

void LoadingState::Update()
{
	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_Done = true;
	}

	UpdateLoading();
}


void LoadingState::Draw()
{
	BeginDrawing();

	ClearBackground(BLACK);

	if (m_loadingFailed == true)
	{
		std::string missingDataText = "Ultima VII files not found.  They should go into the " + g_Engine->m_EngineConfig.GetString("data_path") + " folder.";
		DrawTextEx(*g_Font, missingDataText.c_str(), Vector2{0, 0}, g_fontSize, 1, WHITE);
		DrawTextEx(*g_Font, "Press ESC to exit.", Vector2{ 0, g_fontSize * 2 }, g_fontSize, 1, WHITE);
	}
	else
	{
		DrawConsole();
	}

	DrawTexture(*g_Cursor, GetMouseX(), GetMouseY(), WHITE);

	EndDrawing();

}


void LoadingState::UpdateLoading()
{
	if (!m_loadingFailed)
	{
		if (!m_loadingVersion)
		{
			AddConsoleString(std::string("Loading version..."));
			LoadVersion();
			m_loadingVersion = true;
			return;
		}

		if (!m_loadingChunks)
		{
			AddConsoleString(std::string("Loading chunks..."));
			LoadChunks();
			m_loadingChunks = true;
			return;
		}

		if (!m_loadingMap)
		{
			AddConsoleString(std::string("Loading mapfile..."));
			LoadMap();
			m_loadingMap = true;
			return;
		}

		if (!m_loadingObjects)
		{
			AddConsoleString(std::string("Loading objects..."));
			CreateObjectTable();
			m_loadingObjects = true;
			return;
		}

		if(!m_loadingModels)
		{
			AddConsoleString(std::string("Loading models..."));
			LoadModels();
			m_loadingModels = true;
			return;
		}

		if (!m_loadingShapes)
		{
			AddConsoleString(std::string("Loading shapes..."));
			CreateShapeTable();
			m_loadingShapes = true;
			return;
		}

		if (!m_makingMap)
		{
			AddConsoleString(std::string("Making map..."));
			MakeMap();
			m_makingMap = true;
			return;
		}

		if (!m_loadingIFIX)
		{
			AddConsoleString(std::string("Loading IFIX..."));
			LoadIFIX();
			m_loadingIFIX = true;
			return;
		}

		if (!m_loadingIREG)
		{
			AddConsoleString(std::string("Loading IREG..."));
			LoadIREG();
			m_loadingIREG = true;
			return;
		}

		if (!m_loadingInitialGameState)
		{
			AddConsoleString(std::string("Loading Initial Game State..."));
			LoadInitialGameState();
			m_loadingInitialGameState = true;
			return;
		}

	}
	else
	{
		return;
	}

	g_StateMachine->MakeStateTransition(STATE_TITLESTATE);
}

unsigned char LoadingState::ReadU8(istream &buffer)
{
	unsigned char thisData;
	buffer.read((char*)&thisData, sizeof(unsigned char));
	return thisData;
}

unsigned short LoadingState::ReadU16(istream &buffer)
{
	unsigned short thisData;
	buffer.read((char*)&thisData, sizeof(unsigned short));
	return thisData;
}

unsigned int LoadingState::ReadU32(istream &buffer)
{
	unsigned int thisData;
	buffer.read((char*)&thisData, sizeof(unsigned int));
	return thisData;
}

char LoadingState::ReadS8(istream &buffer)
{
	char thisData;
	buffer.read((char*)&thisData, sizeof(char));
	return thisData;
}

short LoadingState::ReadS16(istream &buffer)
{
	short thisData;
	buffer.read((char*)&thisData, sizeof(short));
	return thisData;
}

int LoadingState::ReadS32(istream &buffer)
{
	int thisData;
	buffer.read((char*)&thisData, sizeof(int));
	return thisData;
}

void LoadingState::LoadVersion()
{
	FILE* u7versionfile = fopen("Data/version.txt", "r");
	if (u7versionfile == nullptr)
	{
		// choose a default?
		g_version = "v0.0.1";
		return;
	}

	char buffer[20];
	fgets(buffer, 20, u7versionfile);
	g_version = buffer;

	fclose(u7versionfile);
}

void LoadingState::LoadChunks()
{
	std::string dataPath = g_Engine->m_EngineConfig.GetString("data_path");
	
	//  Load data for all chunks first
	std::string loadingPath(dataPath);
	loadingPath.append("/STATIC/U7CHUNKS");
	FILE* u7chunksfile = fopen(loadingPath.c_str(), "rb");
	if (u7chunksfile == nullptr)
	{
		Log("Ultima VII files not found.  They should go into the Data/U7 folder.");
		m_loadingFailed = true;
		return;
	}

	//  Each chunk should be an ID associated with 16 arrays, each 16 unsigned chars deep.
	for (int i = 0; i < 3072; ++i)
	{
		for (int j = 0; j < 16; ++j)
		{
			for (int k = 0; k < 16; ++k)
			{
				unsigned short thisdata;
				unsigned char frontend;
				unsigned char backend;
				fread(&thisdata, sizeof(unsigned short), 1, u7chunksfile);

				unsigned int shapenum = thisdata & 0x3ff;
				unsigned int framenum = thisdata >> 10;

				g_ChunkTypeList[i][j][k] = thisdata;
			}
			
		}
	}
	fclose(u7chunksfile);
}

void LoadingState::LoadMap()
{
	std::string dataPath = g_Engine->m_EngineConfig.GetString("data_path");
	std::string loadingPath(dataPath);
	loadingPath.append("/STATIC/U7MAP");
	FILE* u7mapfile = fopen(loadingPath.c_str(), "rb");

	//  Untangle the map and chunk files into a single array.
	//  Create the map of chunk ids and chunk data
	int k = 0;
	int l = 0;
	int j = 0;
	int i = 0;
	for (k = 0; k < 12; ++k)
	{
		for (l = 0; l < 12; ++l)
		{
			for (j = 0; j < 16; ++j)
			{
				for (i = 0; i < 16; ++i)
				{
					unsigned short thisdata = 0;
					fread(&thisdata, sizeof(unsigned short), 1, u7mapfile);

					g_chunkTypeMap[l * 16 + i][k * 16 + j] = thisdata;
				}
			}
		}
	}
	fclose(u7mapfile);
}

void LoadingState::LoadIFIX()
{
	std::string dataPath = g_Engine->m_EngineConfig.GetString("data_path");
	std::string loadingPath(dataPath);
	loadingPath.append("/STATIC/");

	for (int superchunky = 0; superchunky < 12; ++superchunky)
	{
		for (int superchunkx = 0; superchunkx < 12; ++superchunkx)
		{
			std::stringstream ss;
			int thissuperchunk = superchunkx + (superchunky * 12);
			if (thissuperchunk < 16)
			{
				ss << "U7IFIX0" << std::hex << thissuperchunk;
			}
			else
			{
				ss << "U7IFIX" << std::hex << thissuperchunk;
			}
			std::string s = ss.str();
            
            std::transform(s.begin(), s.end(), s.begin(), ::toupper);
            
						s.insert(0, loadingPath.c_str());

			FILE* u7thisifix = fopen(s.c_str(), "rb");
            
            if(u7thisifix == nullptr)
            {
                int stopper = 0;
            }

			//  Even though these files don't have an .flx description, 
			//  these are flex files.  Flex files have a header of 80 bytes,
			//  which is the same for every file: "Ultima VII Data File (C) 1992 Origin Inc."
			char header[80];
			fread(&header, sizeof(char), 80, u7thisifix);

			//  This is followed two unsigned ints.  The first unsigned int is always the same, so we can ignore it.
			//  The second is the number of g_objecTable in the file.
			unsigned int throwaway;
			unsigned int entrycount;
			fread(&throwaway, sizeof(unsigned int), 1, u7thisifix);
			fread(&entrycount, sizeof(unsigned int), 1, u7thisifix);

			//  Now we have ten unsigned ints worth of data that we can ignore.
			for (int i = 0; i < 10; ++i)
			{
				fread(&throwaway, sizeof(unsigned int), 1, u7thisifix);
			}

			struct entrydata
			{
				unsigned int offest;
				unsigned int length;
			};

			unordered_map<unsigned int, entrydata> entrymap;
			//  Now we have the data we want.  Each entry is 8 bytes long.
			for (int i = 0; i < entrycount; ++i)
			{
				entrydata thisentry;
				fread(&thisentry.offest, sizeof(unsigned int), 1, u7thisifix);
				fread(&thisentry.length, sizeof(unsigned int), 1, u7thisifix);
				entrymap[i] = thisentry;
			}

			struct ShapeFrameIndex
			{
				unsigned int shape;
				unsigned int frame;
			};

			struct objectdata
			{
				ShapeFrameIndex shapeframe;
				char chunkx;
				char chunky;
			};

			//  Now, having processed the header, we can process the, you know, data.
			for (int chunky = 0; chunky < 16; ++chunky)
			{
				for (int chunkx = 0; chunkx < 16; ++chunkx)
				{
					int thischunk = chunkx + (chunky * 16);

					entrydata thisentry = entrymap[thischunk];
					if (thisentry.offest == 0)
					{
						continue; // Offset of 0 means no object here.
					}
					else
					{
						unsigned short* locationdata;
						locationdata = (unsigned short*)malloc(sizeof(unsigned short) * (thisentry.length / 2));
						fseek(u7thisifix, thisentry.offest * sizeof(char), SEEK_SET);
						fread(locationdata, sizeof(unsigned char), thisentry.length, u7thisifix);

						for (int w = 0; w < (thisentry.length / 2); w += 2)
						{
							unsigned short thisLocationData = locationdata[w];
							unsigned short shapeData = locationdata[w + 1];

							int shape = shapeData & 0x3ff;
							int frame = (shapeData >> 10) & 0x1f;

							int y = thisLocationData & 0xf;
							int x = (thisLocationData >> 4) & 0xf;
							int z = (thisLocationData >> 8) & 0xf;
							
							AddObject(shape, frame, GetNextID(), (superchunkx * 256) + (chunkx * 16) + x, z, (superchunky * 256) + (chunky * 16) + y);
							int stopper = 0;
						}
					}
				}
			}

			int stopper = 0;
			fclose(u7thisifix);
		}
	}
}

void LoadingState::MakeMap()
{
	g_World.resize(3072);
	for (int i = 0; i < 3072; ++i)
	{
		g_World[i].resize(3072);
	}

	//  Now, finally, we can create the world map.
	for (int i = 0; i < 192; ++i)
	{
		for (int j = 0; j < 192; ++j)
		{
			int chunkid = g_chunkTypeMap[i][j];
			for (int k = 0; k < 16; ++k)
			{
				for (int l = 0; l < 16; ++l)
				{
					unsigned int thisdata = g_ChunkTypeList[chunkid][l][k];
					g_World[j * 16 + k][i * 16 + l] = g_ChunkTypeList[chunkid][l][k];


					unsigned short shapenum = thisdata & 0x3ff;
					unsigned short framenum = (thisdata >> 10) & 0x1f;

          if (shapenum >= 150)
          {
            bool addStatic = true;
            bool addAnimated = false;
            ShapeData& shapeData = g_shapeTable[shapenum][framenum];
            int frameCount = shapeData.GetFrameCount();
            if (frameCount > 1) {
              addStatic = false;
              addAnimated = true;
            }
            int interestedShape = 1008;
            
            if (addStatic == true)
            {
              /*if (shapenum == interestedShape)
              {
                printf("  LoadMakeMap chunk(%d %d) calling AddObject Static %d %d\n", l, k, shapenum, framenum);
              }*/
              AddObject(shapenum, framenum, GetNextID(), (i * 16 + k), 0, (j * 16 + l));
            }
            else if (addAnimated == true)
            {
              /*if (shapenum == interestedShape)
              {
                printf("  LoadMakeMap chunk(%d %d) calling AddObject Animated %d %d\n", l, k, shapenum, framenum);
              }*/
              int frameStart = framenum - (framenum % frameCount);
              int frameStop = frameStart + frameCount;
              for (int m = frameStart; m < frameStop; m++)
              {
                /*if (shapenum == interestedShape)
                {
                  printf("    %d\n", m);
                }*/
                AddObject(shapenum, m, GetNextID(), (i * 16 + k), 0, (j * 16 + l));
              }
            }
          }
        }
      }
    }
  }
}

bool LoadingState::ShapeIsEgg(int shapeIdx) {
  bool retVal = false;
  if (shapeIdx == 0) { retVal = true; }
  else if (shapeIdx == 275) { retVal = true; }
  else if (shapeIdx == 607) { retVal = true; }
  return retVal;
}

bool LoadingState::ShapeIsContainer(int shapeIdx) {
    bool retVal = false;
    if (shapeIdx == 283) { retVal = true; }
    else if (shapeIdx == 400) { retVal = true; }
    else if (shapeIdx == 405) { retVal = true; }
    else if (shapeIdx == 406) { retVal = true; }
    else if (shapeIdx == 407) { retVal = true; }
    else if (shapeIdx == 414) { retVal = true; }
    else if (shapeIdx == 416) { retVal = true; }
    else if (shapeIdx == 507) { retVal = true; }
    else if (shapeIdx == 522) { retVal = true; }
    else if (shapeIdx == 679) { retVal = true; }
    else if (shapeIdx == 762) { retVal = true; }
    else if (shapeIdx == 798) { retVal = true; }
    else if (shapeIdx == 799) { retVal = true; }
    else if (shapeIdx == 800) { retVal = true; }
    else if (shapeIdx == 801) { retVal = true; }
    else if (shapeIdx == 802) { retVal = true; }
    else if (shapeIdx == 803) { retVal = true; }
    else if (shapeIdx == 804) { retVal = true; }
    else if (shapeIdx == 819) { retVal = true; }
    else if (shapeIdx == 892) { retVal = true; }
    return retVal;
}

int LoadingState::IREGItem(bool printDebug, int scPos[2], int containerDepth, int dataLen, unsigned char* data)
{
  bool worldObject = false;
  bool isEgg = false;
  int shapeIdx = 0;
  int frameIdx = 0;
  int chunkx = 0;
  int chunky = 0;
  int intx = 0;
  int inty = 0;
  int actualx = 0;
  int actualy = 0;
  float lift1 = 0.0;
  float lift2 = 0.0;
  int thissuperchunk = scPos[0] + (scPos[1] * 12);

  if (containerDepth == 0)
  {
    worldObject = true;
  }
  // now to the actual item load
  if (dataLen == 6)
  {
    // start dataLen 6
    unsigned char x = data[0];
    unsigned char y = data[1];

    chunkx = x >> 4;
    chunky = y >> 4;
    intx = x & 0x0f;
    inty = y & 0x0f;

    actualx = (scPos[0] * 256) + (chunkx * 16) + intx;
    actualy = (scPos[1] * 256) + (chunky * 16) + inty;

    unsigned int sf1 = data[2];
    unsigned int sf2 = data[3];
    if (printDebug == true)
    {
      printf("6 SF1 %d\n", sf1);
      printf("6 SF2 %d\n", sf2);
    }
    shapeIdx = sf1 + ((sf2 & 3) << 8);
    frameIdx = (sf2 >> 2);

    unsigned char z = data[4];
    lift1 = 0.0;
    lift2 = 0.0;
    if (z != 0)
    {
      lift1 = z >> 4;
      lift2 = z & 0x0f;
      //z *= 8;
    }

    unsigned char quality = data[5];

    isEgg = ShapeIsEgg(shapeIdx);
    bool isAnimated = false;
    ShapeData& shapeData = g_shapeTable[shapeIdx][frameIdx];
    int frameCount = shapeData.GetFrameCount();
    if (frameCount > 1) {
      isAnimated = true;
    }

    if (printDebug == true)
    {
      printf("  IREGItem 6 SC(%02x) chunk(%d %d) (%d %d) calling AddObject %d %d C(%d)\n", thissuperchunk, chunkx, chunky, actualx, actualy, shapeIdx, frameIdx, containerDepth);
    }
    if (isEgg == false  && worldObject == true) //  Eggs
    {
      if (isAnimated == false)
      {
        AddObject(shapeIdx, frameIdx, GetNextID(), actualx, lift1, actualy);
      }
      else
      {
        /*if (shapenum == interestedShape)
        {
          printf("  LoadMakeMap chunk(%d %d) calling AddObject Animated %d %d\n", l, k, shapenum, framenum);
        }*/
        int frameStart = frameIdx - (frameIdx % frameCount);
        int frameStop = frameStart + frameCount;
        for (int m = frameStart; m < frameStop; m++)
        {
          AddObject(shapeIdx, m, GetNextID(), actualx, lift1, actualy);
        }
      }
    }
    // end dataLen 6
  }
  else if (dataLen == 12)
  {
    // start dataLen 12
    unsigned char x = data[0];
    unsigned char y = data[1];

    chunkx = x >> 4;
    chunky = y >> 4;
    intx = x & 0x0f;
    inty = y & 0x0f;

    actualx = (scPos[0] * 256) + (chunkx * 16) + intx;
    actualy = (scPos[1] * 256) + (chunky * 16) + inty;

    unsigned int sf1 = data[2];
    unsigned int sf2 = data[3];
    if (printDebug == true)
    {
      printf("12 SF1 %d %02x\n", sf1, sf1);
      printf("12 SF2 %d %02x\n", sf2, sf2);
    }
    shapeIdx = sf1 + ((sf2 & 3) << 8);
    //shapeIdx = sf1 + (256 * (sf2 & 3));
    //shapenum = data[2] + 256 * (data[3] & 3)
    frameIdx = (sf2 >> 2);

    // skipping data[4 - 8]

    unsigned char z = data[9];
    float lift1 = 0;
    float lift2 = 0;
    float lift3 = 0;
    if (z != 0)
    {
      lift1 = z >> 4;
      lift2 = z & 0x0f;
      lift3 = z / 8;

    }

    // skipping data[10 - 11]

    isEgg = ShapeIsEgg(shapeIdx);

    if (printDebug == true)
    {
      printf("  IREGItem 12 SC(%02x) chunk(%d %d) (%d %d) calling AddObject %d %d C(%d)\n", thissuperchunk, chunkx, chunky, actualx, actualy, shapeIdx, frameIdx, containerDepth);
    }
    if (isEgg == false && worldObject == true) //  Eggs
    {
      AddObject(shapeIdx, frameIdx, GetNextID(), actualx, lift1, actualy);
    }
    // end dataLen 12
  }
  else if (dataLen == 18)
  {
    // start dataLen 18
    unsigned char x = data[0];
    unsigned char y = data[1];

    chunkx = x >> 4;
    chunky = y >> 4;
    intx = x & 0x0f;
    inty = y & 0x0f;

    actualx = (scPos[0] * 256) + (chunkx * 16) + intx;
    actualy = (scPos[1] * 256) + (chunky * 16) + inty;

    unsigned int sf1 = data[2];
    unsigned int sf2 = data[3];
    shapeIdx = sf1 + ((sf2 & 3) << 8);
    frameIdx = (sf2 >> 2);

    // skipping data[4 - 8]
    
    unsigned char z = data[9];
    float lift1 = 0;
    float lift2 = 0;
    float lift3 = 0;
    if (z != 0)
    {
      lift1 = z >> 4;
      lift2 = z & 0x0f;
      lift3 = z / 8;
    }

    // skipping data[10 - 17]

    isEgg = ShapeIsEgg(shapeIdx);

    if (printDebug == true)
    {
      printf("  IREGItem SC(%02x) chunk(%d %d) (%d %d) calling AddObject %d %d C(%d)\n", thissuperchunk, chunkx, chunky, actualx, actualy, shapeIdx, frameIdx, containerDepth);
    }
    if (isEgg == false && worldObject == true) //  Eggs
    {
      AddObject(shapeIdx, frameIdx, GetNextID(), actualx, lift1, actualy);
    }
    // end dataLen 18
  }
  return shapeIdx;
}

void LoadingState::LoadIREG()
{
  std::string dataPath = g_Engine->m_EngineConfig.GetString("data_path");
  std::string loadingPath(dataPath);
  loadingPath.append("/GAMEDAT/");

  for (int superchunky = 0; superchunky < 12; ++superchunky)
  {
    for (int superchunkx = 0; superchunkx < 12; ++superchunkx)
    {
      std::stringstream ss;
      int scPos[2];
      scPos[0] = superchunkx;
      scPos[1] = superchunky;
      int thissuperchunk = superchunkx + (superchunky * 12);
      if (thissuperchunk < 16)
      {
        ss << "U7IREG0" << std::hex << thissuperchunk;
      }
      else
      {
        ss << "U7IREG" << std::hex << thissuperchunk;
      }
      std::string s = ss.str();
            
         std::transform(s.begin(), s.end(), s.begin(), ::toupper);
            
      s.insert(0, loadingPath.c_str());

      FILE* u7thisireg = fopen(s.c_str(), "rb");

      if (u7thisireg == nullptr)
      {
        Log("Ultima VII files not found.  They should go into the Data/U7 folder.");
        m_loadingFailed = true;
        return;
      }
      else
      {
        while (!feof(u7thisireg))
        {
          //  Read the length of the object.
          unsigned char length;
          bool inContainer = false;
          fread(&length, sizeof(unsigned char), 1, u7thisireg);
          if (thissuperchunk == 108)
          {
            printf("CUR POS: %02X\n", ftell(u7thisireg));
          }
          if (length == 0)
          {
            if (thissuperchunk == 108)
            {
              printf("  hit a 0, end of chunk\n");
            }
          }
          else if (length == 6) //  Object.
          {
            // start item length 6
            int containerDepth = 0;
            int cShape = 0;
            unsigned char throwaway[6];
            fread(&throwaway, sizeof(unsigned char), 6, u7thisireg);
            if (thissuperchunk == 108)
            {
              cShape = IREGItem(true, scPos, containerDepth, 6, throwaway);
            }
            else
            {
              cShape = IREGItem(false, scPos, containerDepth, 6, throwaway);
            }
            /*
            unsigned char x;
            unsigned char y;
            fread(&x, sizeof(unsigned char), 1, u7thisireg);
            fread(&y, sizeof(unsigned char), 1, u7thisireg);

            int chunkx = x >> 4;
            int chunky = y >> 4;
            int intx = x & 0x0f;
            int inty = y & 0x0f;

            int actualx = (superchunkx * 256) + (chunkx * 16) + intx;
            int actualy = (superchunky * 256) + (chunky * 16) + inty;

            unsigned short shapeData;
            fread(&shapeData, sizeof(unsigned short), 1, u7thisireg);
            int shape = shapeData & 0x3ff;
            int frame = (shapeData >> 10) & 0x1f;

            unsigned char z;
            fread(&z, sizeof(unsigned char), 1, u7thisireg);
            float lift1 = 0;
            float lift2 = 0;
            if (z != 0)
            {
              lift1 = z >> 4;
              lift2 = z & 0x0f;
              //z *= 8;
            }

            
            unsigned char quality;
            fread(&quality, sizeof(unsigned char), 1, u7thisireg);

            if (thissuperchunk == 108) {
              printf("  LoadIREG SC(%02x) chunk(%d %d) (%d %d) calling AddObject %d %d\n", thissuperchunk, chunkx, chunky, actualx, actualy, shape, frame);
            }
            if (shape != 275 && shape != 607 && shape != 0) //  Eggs
            {
              //if (chunkx == 0 && chunky == 5)
              //{
            //if (thissuperchunk == 108) {
              AddObject(shape, frame, GetNextID(), actualx, lift1, actualy);
            //}
              //}
            
            }
            else
            {
              //AddObject(shape, frame, GetNextID(), actualx, lift1, actualy);
            }*/
            // end item length 6
          }
          else if (length == 12) // Container or Egg
          {
            // start item length 12
            //continue;
            /*
            unsigned char x;
            unsigned char y;
            fread(&x, sizeof(unsigned char), 1, u7thisireg); // 1
            fread(&y, sizeof(unsigned char), 1, u7thisireg); // 2

            int chunkx = x >> 4;
            int chunky = y >> 4;
            int intx = x & 0x0f;
            int inty = y & 0x0f;

            int actualx = (superchunkx * 256) + (chunkx * 16) + intx;
            int actualy = (superchunky * 256) + (chunky * 16) + inty;

            unsigned short shapeData;
            fread(&shapeData, sizeof(unsigned short), 1, u7thisireg); // 3, 4
            int shape = shapeData & 0x3ff;
            int frame = (shapeData >> 10) & 0x1f;

            unsigned char sink;
            for (int i = 0; i < 5; ++i)
            {
              fread(&sink, sizeof(unsigned char), 1, u7thisireg); // 5-9
            }

            unsigned char z;
            fread(&z, sizeof(unsigned char), 1, u7thisireg); // 10
            float lift1 = 0;
            float lift2 = 0;
            float lift3 = 0;
            if (z != 0)
            {
              lift1 = z >> 4;
              lift2 = z & 0x0f;
              lift3 = z / 8;
              
            }

            //  Soak up the next 2 bytes.
            unsigned char throwaway[2];
            fread(&throwaway, sizeof(unsigned char), 2, u7thisireg);    // 11

            if (thissuperchunk == 108) {
              printf("  LoadIEGG SC(%02x) chunk(%d %d) (%d %d) calling AddObject %d %d\n", thissuperchunk, chunkx, chunky, actualx, actualy, shape, frame);
            }
            if (shape != 275 && shape != 607 && shape != 0)
            {
              AddObject(shape, frame, GetNextID(), actualx, lift1, actualy);
            }
            //  Egg or container?  01 Egg, 00 container.
            */
            int containerDepth = 0;
            int tShape = 0;
            unsigned char throwaway[12];
            fread(&throwaway, sizeof(unsigned char), 12, u7thisireg);
            if (thissuperchunk == 108)
            {
              tShape = IREGItem(true, scPos, containerDepth, 12, throwaway);
            }
            else
            {
              tShape = IREGItem(false, scPos, containerDepth, 12, throwaway);
            }

            bool isContainer = ShapeIsContainer(tShape);
            if (isContainer == true) {
                containerDepth += 1;
                if (thissuperchunk == 108) {
                  printf("  this is a container %d (%d)\n", tShape, containerDepth);
                }
            }
            while (containerDepth > 0)
            {
              if (thissuperchunk == 108) {
                printf("CUR POS: %02X\n", ftell(u7thisireg));
                printf("  reading container %d\n", containerDepth);
              }
              unsigned char clength;
              fread(&clength, sizeof(unsigned char), 1, u7thisireg);
              if (clength == 0)
              {
                // 0 should mean end of chunk
                if (thissuperchunk == 108) {
                  printf("  hit %d, this container is finished\n", clength);
                }
                containerDepth = 0;
              }
              else if (clength == 1)
              {
                // 1 means end of container
                if (thissuperchunk == 108) {
                printf("  hit %d, this container is finished\n", clength);
                }
                containerDepth -= 1;
              }
              else if (clength == 6)
              {
                // data length 6
                int cShape = 0;
                unsigned char cthrowaway[6];
                fread(&cthrowaway, sizeof(unsigned char), 6, u7thisireg);
                if (thissuperchunk == 108)
                {
                  cShape = IREGItem(true, scPos, containerDepth, 6, cthrowaway);
                }
                else
                {
                  cShape = IREGItem(false, scPos, containerDepth, 6, cthrowaway);
                }
              }
              else if (clength == 12)
              {
                // data length 12
                int cShape = 0;
                unsigned char cthrowaway[12];
                fread(&cthrowaway, sizeof(unsigned char), 12, u7thisireg);
                if (thissuperchunk == 108)
                {
                  cShape = IREGItem(true, scPos, containerDepth, 12, cthrowaway);
                  bool cIsContainer = ShapeIsContainer(cShape);
                  if (cIsContainer == true)
                  {
                    containerDepth += 1;
                  }
                }
                else
                {
                  cShape = IREGItem(false, scPos, containerDepth, 12, cthrowaway);
                  bool cIsContainer = ShapeIsContainer(cShape);
                  if (cIsContainer == true)
                  {
                    containerDepth += 1;
                  }
                }

                /*
                unsigned short cShapeData;
                fread(&cShapeData, sizeof(unsigned short), 1, u7thisireg); // 3, 4
                int cShape = shapeData & 0x3ff;
                int cFrame = (shapeData >> 10) & 0x1f;
                bool cIsContainer = ShapeIsContainer(cShape);
                if (cIsContainer == true) {
                  containerDepth += 1;
                }
                // now burn the other 10
                unsigned char throwaway[10];
                fread(&throwaway, sizeof(unsigned char), 10, u7thisireg);
                */
              }
              else if (clength == 18)
              {
                // data length 18
                //unsigned char throwaway[18];
                //fread(&throwaway, sizeof(unsigned char), 18, u7thisireg);
                int cShape = 0;
                unsigned char cthrowaway[18];
                fread(&cthrowaway, sizeof(unsigned char), 18, u7thisireg);
                if (thissuperchunk == 108)
                {
                  cShape = IREGItem(true, scPos, containerDepth, 18, cthrowaway);
                }
                else
                {
                  cShape = IREGItem(false, scPos, containerDepth, 18, cthrowaway);
                }
                bool cIsContainer = ShapeIsContainer(cShape);
                if (cIsContainer == true) {
                  containerDepth += 1;
                }
              }
              //  Container.  Read in the container's objects.
              
              
            //unsigned char objectflag = 0;
            //  fread(&length, sizeof(unsigned char), 1, u7thisireg);
            //  while (objectflag != 01) //  No more contained objects
            //  {
            //    unsigned char x;
            //    unsigned char y;
            //    fread(&x, sizeof(unsigned char), 1, u7thisireg);
            //    fread(&y, sizeof(unsigned char), 1, u7thisireg);

            //    int chunkx = x >> 4;
            //    int chunky = y >> 4;
            //    int intx = x & 0x0f;
            //    int inty = y & 0x0f;

            //    int actualx = (superchunkx * 256) + (chunkx * 16) + intx;
            //    int actualy = (superchunky * 256) + (chunky * 16) + inty;

            //    unsigned short shapeData;
            //    fread(&shapeData, sizeof(unsigned short), 1, u7thisireg);
            //    int shape = shapeData & 0x3ff;
            //    int frame = (shapeData >> 10) & 0x1f;

            //    unsigned char z;
            //    fread(&z, sizeof(unsigned char), 1, u7thisireg);
            //    float lift1 = 0;
            //    float lift2 = 0;
            //    if (z != 0)
            //    {
            //      lift1 = z >> 4;
            //      lift2 = z & 0x0f;
            //      //z *= 8;
            //    }

            //    AddObject(shape, frame, GetNextID(), actualx, lift1, actualy);
            //    unsigned char quality;
            //    fread(&quality, sizeof(unsigned char), 1, u7thisireg);
            //    fread(&objectflag, sizeof(unsigned char), 1, u7thisireg);
            }
            //}
            //else
            //{
            //  //  Egg.  Do nothing.
            //}
            // end item length 12
          }
          else if (length == 18) // Spellbook
          {
            // start item length 18
            int containerDepth = 0;
            //unsigned char throwaway[18];
            //fread(&throwaway, sizeof(unsigned char), 18, u7thisireg);
            int cShape = 0;
            unsigned char cthrowaway[18];
            fread(&cthrowaway, sizeof(unsigned char), 18, u7thisireg);
            if (thissuperchunk == 108)
            {
              cShape = IREGItem(true, scPos, containerDepth, 18, cthrowaway);
            }
            else
            {
              cShape = IREGItem(false, scPos, containerDepth, 18, cthrowaway);
            }
            bool cIsContainer = ShapeIsContainer(cShape);
            if (cIsContainer == true) {
              containerDepth += 1;
            }
            // end item length 18
          }
        }
      }

      //int stopper = 0;
      fclose(u7thisireg);
    }
  }
}

void LoadingState::CreateShapeTable()
{
	//  Load palette data
	ifstream palette;
	std::string dataPath = g_Engine->m_EngineConfig.GetString("data_path");
	std::string loadingPath(dataPath);
	loadingPath.append("/STATIC/PALETTES.FLX");
	palette.open(loadingPath.c_str(), ios::binary);
	if (!palette.good())
	{
		Log("Ultima VII files not found.  They should go into the Data/U7/blackgate folder.");
		throw("Ultima VII files not found.  They should go into the Data/U7/blackgate folder.");
	}

	vector<FLXEntryData> paletteEntryMap = ParseFLXHeader(palette);

	//  We only want the first palette for now.
	palette.seekg(paletteEntryMap[0].offset);
	unsigned char* paletteData = (unsigned char*)malloc(paletteEntryMap[0].length);
	palette.read((char*)paletteData, paletteEntryMap[1].length);

	//  Currently only loading the base palette.  Other palettes are for lighting effects.
	for (int j = 0; j < 256; ++j)
	{
		unsigned char r = paletteData[j * 3];
		unsigned char g = paletteData[j * 3 + 1];
		unsigned char b = paletteData[j * 3 + 2];
		m_palette[j].r = r * 4;
		m_palette[j].g = g * 4;
		m_palette[j].b = b * 4;
		m_palette[j].a = 255;
	}

	m_palette[254] = Color{ 128, 128, 128, 128 };

	palette.close();

	//  Load shape data
	ifstream shapesFile;
	std::string shapePath = dataPath.append("/STATIC/SHAPES.VGA");
	shapesFile.open(shapePath.c_str(), ios::binary);

	stringstream shapes;
	shapes << shapesFile.rdbuf();
	shapesFile.close();

	vector<FLXEntryData> shapeEntryMap = ParseFLXHeader(shapes);

	bool test = true;

		//  The first 150 entries (0-149) are terrain textures.  They are not
	//  rle-encoded.  Splat them directly to the terrain texture.
	Image& tempImage = g_Terrain->GetTerrainTexture();
	for (int thisShape = 0; thisShape < 150; ++thisShape)
	{
		shapes.seekg(shapeEntryMap[thisShape].offset);
		int numFrames = shapeEntryMap[thisShape].length / 64;
		for (int thisFrame = 0; thisFrame < numFrames; ++thisFrame)
		{
			if (thisShape == 12 && thisFrame == 0)
				continue;
			for (int i = 0; i < 8; ++i)
			{
				for (int j = 0; j < 8; ++j)
				{
					unsigned char Value = ReadU8(shapes);
					ImageDrawPixel(&tempImage, (thisShape * 8) + j, (thisFrame * 8) + i, m_palette[Value]);
				}
			}

		}
	}

	g_Terrain->UpdateTerrainTexture(tempImage);
	g_Terrain->Init();
	Log("Done creating terrain.");

	struct frameData
	{
		unsigned int fileOffset;
		short W2;
		short W1;
		short H1;
		short H2;
		unsigned int width;
		unsigned int height;
		int xDrawOffset;
		int yDrawOffset;
	};

	float profilingTime = GetTime();

	for (int thisShape = 150; thisShape < 1024; ++thisShape)
	{
		//  The next 874 entries (150-1023) are objects.

		//  Read the shape data.

		shapes.seekg(shapeEntryMap[thisShape].offset);
		unsigned int headerStart = shapes.tellg();
		unsigned int firstData = ReadU32(shapes);

		//  If the first data is the same as the length of the shape entry, then this entry is run-length encoded.
		if (firstData == shapeEntryMap[thisShape].length)
		{
			//  Next four bytes tell length of the header.
			unsigned int headerLength = ReadU32(shapes);
			unsigned int frameCount = ((headerLength - 4) / 4);
			std::vector<frameData> frameOffsets;
			frameOffsets.resize(frameCount);
			frameOffsets[0].fileOffset = 0;
			for (int i = 1; i < frameCount; ++i)
			{
				frameOffsets[i].fileOffset = ReadU32(shapes);
			}

			//  Read the frame data.
			for (int i = 0; i < frameCount; ++i)
			{
				ShapeData& shapeData = g_shapeTable[thisShape][i];
				//  Seek to the start of this frame's data.
				if (i > 0)
				{
					shapes.seekg(headerStart + frameOffsets[i].fileOffset);
				}

				frameOffsets[i].W2 = ReadS16(shapes);
				frameOffsets[i].W1 = ReadS16(shapes);
				frameOffsets[i].H1 = ReadS16(shapes);
				frameOffsets[i].H2 = ReadS16(shapes);

				frameOffsets[i].height = frameOffsets[i].H1 + frameOffsets[i].H2 + 1;
				frameOffsets[i].width = frameOffsets[i].W2 + frameOffsets[i].W1 + 1;

				frameOffsets[i].xDrawOffset = frameOffsets[i].W2;
				frameOffsets[i].yDrawOffset = frameOffsets[i].H2;

				shapeData.CreateDefaultTexture();
				Image tempImage = GenImageColor(frameOffsets[i].width, frameOffsets[i].height, Color{ 0, 0, 0, 0 });
				//  Read each span.  Spans can be either RLE or raw pixel data.
				while (true)
				{
					unsigned short blockData = ReadU16(shapes);
					unsigned short spanLength = blockData >> 1;
					unsigned short spanType = blockData & 1;

					if (blockData == 0)
					{
						break; //  There are no more spans; we're done with this frame.
					}

					short xStart = ReadS16(shapes);
					short yStart = ReadS16(shapes);
					xStart += frameOffsets[i].width - frameOffsets[i].xDrawOffset - 1;
					yStart += frameOffsets[i].height - frameOffsets[i].yDrawOffset - 1;

					if (spanType == 0) // Not RLE, raw pixel data.
					{
						for (int i = 0; i < spanLength; ++i)
						{
							unsigned char Value = ReadU8(shapes);
							ImageDrawPixel(&tempImage, xStart + i, yStart, m_palette[Value]);
						}
					}
					else // RLE.
					{
						int endX = xStart + spanLength;

						while (xStart < endX)
						{
							unsigned char runData = ReadU8(shapes);
							int runLength = runData >> 1;
							int runType = runData & 1;

							if (runType == 0) // Once again, non-RLE
							{
								for (int i = 0; i < runLength; ++i)
								{
									unsigned char Value = ReadU8(shapes);
									ImageDrawPixel(&tempImage, xStart + i, yStart, m_palette[Value]);
								}
							}
							else
							{
								unsigned char Value = ReadU8(shapes);
								for (int i = 0; i < runLength; ++i)
								{
									ImageDrawPixel(&tempImage, xStart + i, yStart, m_palette[Value]);
								}
							}
							xStart += runLength;
						}
					}
				}
				shapeData.SetDefaultTexture(tempImage);
			}

			continue;
		}
		else  //  This entry is not encoded.
		{

		}
	}

	ifstream file("Data/shapetable.dat");
	if (file.is_open())
	{
		for (int i = 150; i < 1024; ++i)
		{
			for (int j = 0; j < 32; ++j)
			{
				ShapeData& shapeData = g_shapeTable[i][j];
				shapeData.Deserialize(file);
			}
		}
		file.close();
	}

	profilingTime = GetTime() - profilingTime;
	Log("Time to load shapes: " + std::to_string(profilingTime));
}

void LoadingState::LoadModels()
{
	ifstream directory("Models/3dmodels/modelnames.txt");
	if (!directory.is_open())
	{
		return;
	}

	//Read in file header
	while (!directory.eof())
	{

		std::string m_Filename;
		std::getline(directory, m_Filename);

		if (m_Filename.length() == 0)
			continue;

		//Try to open model file
		std::string objPath = "Models/3dmodels/" + m_Filename + std::string(".obj");
		std::string mtlPath = "Models/3dmodels/" + m_Filename + std::string(".mtl");

		Model model = LoadModel(objPath.c_str());
		int materialCount = 0;
		Material* material = LoadMaterials(mtlPath.c_str(), &materialCount); // Load material
		model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = material[0].maps[0].texture;            // Set map diffuse texture

		g_ResourceManager->AddModel(model, objPath);
	}
}

void LoadingState::CreateObjectTable()
{
	//  Open the two files that define the objects in the object table.
	// Open the two files that define the objects in the object table.
	std::string dataPath = g_Engine->m_EngineConfig.GetString("data_path");

	std::stringstream tfa;
	tfa << dataPath.c_str() << "/STATIC/TFA.DAT";

	ifstream tfafile(tfa.str(), ios::binary);

	std::stringstream wgtvol;
	wgtvol << dataPath.c_str() << "/STATIC/WGTVOL.DAT";

	ifstream wgtvolfile(wgtvol.str(), ios::binary);

	std::stringstream text;
	text << dataPath.c_str() << "/STATIC/TEXT.FLX";

	ifstream textfile(text.str(), ios::binary);

	char header[80];
	textfile.read(header, sizeof(header));

	//  This is followed two unsigned ints.  The first unsigned int is always the same, so we can ignore it.
	//  The second is the number of g_objectTable in the file.
	unsigned int throwaway = 0;
	textfile.read((char*)&throwaway, sizeof(throwaway));

	unsigned int entrycount = 0;
	textfile.read((char*)&entrycount, sizeof(entrycount));

	//  Now we have ten unsigned ints worth of data that we can ignore.
	for (int i = 0; i < 10; ++i)
	{
		textfile.read((char*)&throwaway, sizeof(throwaway));
	}

	std::vector<FLXEntryData> entrymap;
	entrymap.resize(entrycount);
	//  Now we have the data we want.  Each entry is 8 bytes long.
	for (int i = 0; i < entrycount; ++i)
	{
		FLXEntryData thisentry;
		thisentry.length = 0;
		thisentry.offset = 0;
		textfile.read((char*)&thisentry.offset, sizeof(thisentry.offset));
		textfile.read((char*)&thisentry.length, sizeof(thisentry.length));
		entrymap[i] = thisentry;
	}

	std::vector<std::string> shapeNames;
	for (int i = 0; i < entrycount; ++i)
	{
		textfile.seekg(entrymap[i].offset);
		char* thisname = new char[entrymap[i].length];
		textfile.read(thisname, entrymap[i].length);
		shapeNames.push_back(std::string(thisname));
		delete[] thisname;
	}

	//  Read the object table.

	for (int i = 0; i < 1024; ++i)
	{
		//  Read the object table entry.
		ObjectData thisObject;

		// Weight and volume from wgtvol.dat
		unsigned char weight;
		wgtvolfile.read((char*)&weight, sizeof(char));
		g_objectTable[i].m_weight = float(weight) * .10f;
		unsigned char volume;
		wgtvolfile.read((char*)&volume, sizeof(char));
		g_objectTable[i].m_volume = float(volume);

		//  All other data from tfa.dat
		char buffer[3]; // 3 bytes to store the 24 bits
		tfafile.read(buffer, sizeof(buffer));

		g_objectTable[i].m_hasSoundEffect = buffer[0] & 0x01;
		g_objectTable[i].m_rotatable = (buffer[0] >> 1) & 0x01;
		g_objectTable[i].m_isAnimated = (buffer[0] >> 2) & 0x01;
		g_objectTable[i].m_isNotWalkable = (buffer[0] >> 3) & 0x01;
		g_objectTable[i].m_isWater = (buffer[0] >> 4) & 0x01;
		g_objectTable[i].m_height = (buffer[0] >> 5) & 0x07;
		g_objectTable[i].m_shapeType = (buffer[1] >> 4) & 0x0F;
		g_objectTable[i].m_isTrap = (buffer[1] >> 8) & 0x01;
		g_objectTable[i].m_isDoor = (buffer[1] >> 9) & 0x01;
		g_objectTable[i].m_isVehiclePart = (buffer[1] >> 10) & 0x01;
		g_objectTable[i].m_isNotSelectable = (buffer[1] >> 11) & 0x01;
		g_objectTable[i].m_width = ((buffer[2]) & 0x07) + 1;
		g_objectTable[i].m_depth = ((buffer[2] >> 3) & 0x07) + 1;
		g_objectTable[i].m_isLightSource = (buffer[2] >> 6) & 0x01;
		g_objectTable[i].m_isTranslucent = (buffer[2] >> 7) & 0x01;
		g_objectTable[i].m_name = shapeNames[i];
	}
	wgtvolfile.close();
	tfafile.close();
}


//  Most Ultima VII files are flex files.  Thus, a general function that can
//  parse flex file headers.  This function takes a FILE* and returns a vector
//  of FLXEntryData, which is a struct containing the offset and length of
//  each entry in the file.  It moves the file pointers to the point where
//  the calling code can immediately start reading out data.
std::vector<LoadingState::FLXEntryData> LoadingState::ParseFLXHeader(istream &file)
{
	char header[80];
	file.read(header, sizeof(header));

	//  This is followed two unsigned ints.  The first unsigned int is always the same, so we can ignore it.
	//  The second is the number of g_objecTable in the file.
	unsigned int throwaway;
	unsigned int entrycount;
	file.read(reinterpret_cast<char*>(&throwaway), sizeof(throwaway));
	file.read(reinterpret_cast<char*>(&entrycount), sizeof(entrycount));

	//  Now we have ten unsigned ints worth of data that we can ignore.
	for (int i = 0; i < 10; ++i)
	{
		unsigned int throwaway;
		file.read(reinterpret_cast<char*>(&throwaway), sizeof(unsigned int));
	}

	std::vector<FLXEntryData> entrymap;
	entrymap.resize(entrycount);
	//  Now we have the data we want.  Each entry is 8 bytes long.
	for (int i = 0; i < entrycount; ++i)
	{
		FLXEntryData thisentry;
		thisentry.offset = ReadS32(file);
		if (thisentry.offset == 0) //  Offset of 0 means no object here.
		{
			thisentry.length = 0;
			continue;
		}
		thisentry.length = ReadS32(file);
		entrymap[i] = thisentry;
	}

	return entrymap;
}

void LoadingState::LoadInitialGameState()
{
	//  Load shape data
	std::string dataPath = g_Engine->m_EngineConfig.GetString("data_path");
	ifstream initGameFile;
	std::string initGamePath = dataPath.append("/STATIC/INITGAME.DAT");
	initGameFile.open(initGamePath.c_str(), ios::binary);

	stringstream subFiles;
	subFiles << initGameFile.rdbuf();
	initGameFile.close();

	vector<FLXEntryData> subFileMap = ParseFLXHeader(subFiles);
	
	for (auto& node = subFileMap.begin(); node != subFileMap.end(); ++node)
	{
		subFiles.seekg(node->offset);
		//  First thirteen characters are the filename.
		char filename[13];
		subFiles.read(filename, 13);

		//  Based on the filename, do...something.
		if (!strncmp(filename, "npc.dat", 6))
		{
			short npcCount1 = ReadU16(subFiles);
			short npcCount2 = ReadU16(subFiles);
			int fullcount = npcCount1 + npcCount2;
			int filepos = subFiles.tellg();
			Log("File position: " + to_string(filepos));
			for (int i = 0; i < fullcount; ++i)
			{
				if (i == 139) // This NPC is broken and attempting to parse it messes up all NPCs after it.  It's not used anyway so we just skip it.
				{
					Log("Stopper");// subFiles.seekg(2761, ios::cur);
				}

				int size = sizeof(NPCblock);
				Log("NPC block size: " + std::to_string(size));
				NPCblock thisNPC;
				
				thisNPC.x = ReadU8(subFiles);
				thisNPC.y = ReadU8(subFiles);
				thisNPC.shapeId = ReadU16(subFiles);

				unsigned int shapenum = thisNPC.shapeId & 0x3ff;
				unsigned int framenum = thisNPC.shapeId >> 10;

				thisNPC.type = ReadU16(subFiles);
				thisNPC.proba = ReadU8(subFiles);
				thisNPC.data1 = ReadU16(subFiles);
				thisNPC.lift = ReadU8(subFiles);
				thisNPC.data2 = ReadU16(subFiles);

				int chunkx = thisNPC.proba % 12;
				int chunky = thisNPC.proba / 12;

				thisNPC.index = ReadU16(subFiles);
				thisNPC.referent = ReadU16(subFiles);
				thisNPC.status = ReadU16(subFiles);

				AddObject(shapenum, 16, GetNextID(), chunkx * 16 * 16 + thisNPC.x, thisNPC.lift >> 4, chunky * 16 * 16 + thisNPC.y);

				thisNPC.str = ReadU8(subFiles);
				thisNPC.dex = ReadU8(subFiles);
				thisNPC.iq = ReadU8(subFiles);
				thisNPC.combat = ReadU8(subFiles);
				thisNPC.activity = ReadU8(subFiles);
				thisNPC.DAM = ReadU8(subFiles);

				subFiles.read(thisNPC.soak1, 3);

				thisNPC.status2 = ReadU16(subFiles);
				thisNPC.index2 = ReadU8(subFiles);

				subFiles.read(thisNPC.soak2, 2);

				thisNPC.xp = ReadU32(subFiles);
				thisNPC.training = ReadU8(subFiles);
				thisNPC.primary = ReadU16(subFiles);
				thisNPC.secondary = ReadU16(subFiles);
				thisNPC.oppressor = ReadU16(subFiles);
				thisNPC.ivrx = ReadU16(subFiles);
				thisNPC.ivry = ReadU16(subFiles);
				thisNPC.svrx = ReadU16(subFiles);
			   thisNPC.svry = ReadU16(subFiles);
				thisNPC.status3 = ReadU16(subFiles);

				subFiles.read(thisNPC.soak3, 5);

				thisNPC.acty = ReadU8(subFiles);

				subFiles.read(thisNPC.soak4, 29);

				thisNPC.SN = ReadU8(subFiles);
				thisNPC.V1 = ReadU8(subFiles);
				thisNPC.V2 = ReadU8(subFiles);
				thisNPC.food = ReadU8(subFiles);

				subFiles.read(thisNPC.soak5, 9);

				subFiles.read(thisNPC.name, 16);

				int newfilepos = subFiles.tellg();
				Log("File position after avatar: " + to_string(newfilepos));
				Log("Size difference: " + to_string(newfilepos - filepos));
				Log("Iolo starts at 2761 so there are " + to_string(2761 - newfilepos) + " bytes left.");

				if (thisNPC.type != 0 && i != 139) // This NPC has an inventory
				{
					unsigned char length = 99;
					bool incontainer = false;
					while (length != 0)
					{
						int pointerlocation = subFiles.tellg();
						Log("File pointer is at " + to_string(pointerlocation));
						length = ReadU8(subFiles);
						if (length == 6) //  Object.
						{
							for (int i = 0; i < 6; ++i)
							{
								ReadU8(subFiles);
							}
						}
						else if (length == 12) // container or egg
						{
							incontainer = true;
							for (int i = 0; i < 12; ++i)
							{
								ReadU8(subFiles);
							}
						}
						else if(length == 1)
						{
							if (incontainer)
							{
								incontainer = false;
							}
						}
					}
				}
				Log("First block written: ");
			}
			stringstream npcData;
		}
	}
}