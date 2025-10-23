#include "Geist/Globals.h"
#include "Geist/StateMachine.h"
#include "Geist/Logging.h"
#include "Geist/Engine.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"
#include "LoadingState.h"
#include "Pathfinding.h"

#include <cstring>
#include <list>
#include <string>
#include <sstream>
#include <iomanip>
#include <math.h>
#include <fstream>
#include <algorithm>
#include <unordered_map>
#include <filesystem>

#include <iostream>
#include <fstream>
#include <memory_resource>
#include <sstream>
#include <string>
#include <regex>

using namespace std;
using namespace std::filesystem;

////////////////////////////////////////////////////////////////////////////////
//  LoadingState
////////////////////////////////////////////////////////////////////////////////

LoadingState::~LoadingState()
{
	Shutdown();
}

void LoadingState::Init(const string& configfile)
{
	g_minimapSize = g_Engine->m_RenderWidth / 4.5f;

	MakeAnimationFrameMeshes();

	m_red = 1.0;
	m_angle = 0.0;

	xSlant = .01;

}

void LoadingState::OnEnter()
{
	#ifdef DEBUG_MODE
    AddConsoleString("Debug Build", RED);
    #elif defined(RELEASE_MODE)
    AddConsoleString("Release Build");
    #else
	AddConsoleString("No build defined, please fix this.");
    #endif
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

	BeginTextureMode(g_guiRenderTarget);

	ClearBackground(BLACK);

	if (m_loadingFailed == true)
	{
		std::string missingDataText = "Ultima VII files not found.  They should go into the " + g_Engine->m_EngineConfig.GetString("data_path") + " folder.";
		DrawTextEx(*g_SmallFont, missingDataText.c_str(), Vector2{0, 0}, g_SmallFont->baseSize, 1, WHITE);
		DrawTextEx(*g_SmallFont, "Press ESC to exit.", Vector2{ 0, g_SmallFont->baseSize * 2.0f }, g_SmallFont->baseSize, 1, WHITE);
	}
	else
	{
		DrawConsole();
	}

	DrawTexture(*g_Cursor, 0, 0, WHITE);

	EndTextureMode();

	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	//DrawTexture(*g_Cursor, GetMouseX(), GetMouseY(), WHITE);

	EndDrawing();

}


void LoadingState::UpdateLoading()
{
	
	if (!m_loadingFailed)
	{
		if (!m_loadingVersion)
		{
			AddConsoleString(std::string("Loading version..."));
			//splitUsecodeDis();
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

		if(!m_loadingFaces)
		{
			AddConsoleString(std::string("Loading faces..."));
			LoadFaces();
			m_loadingFaces = true;
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

		if (!m_loadingInitialGameState)
		{
			AddConsoleString(std::string("Loading Initial Game State..."));
			LoadInitialGameState();
			m_loadingInitialGameState = true;
			return;
		}

		if (!m_loadingNPCSchedules)
		{
			AddConsoleString(std::string("Loading NPC Schedules..."));
			LoadNPCSchedules();
			m_loadingNPCSchedules = true;
			return;
		}

		if (!m_buildingPathfindingGrid)
		{
			AddConsoleString(std::string("Building pathfinding grid..."));
			g_pathfindingGrid = new PathfindingGrid();
			g_pathfindingGrid->BuildFromWorld();
			m_buildingPathfindingGrid = true;
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
	unsigned char thisData = 0;
	buffer.read(reinterpret_cast<char*>(&thisData), 1);
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

							int nextId = GetNextID();
							AddObject(shape, frame, nextId, (superchunkx * 256) + (chunkx * 16) + x, z, (superchunky * 256) + (chunky * 16) + y);
							g_objectList[nextId]->m_UnitType = U7Object::UnitTypes::UNIT_TYPE_STATIC;

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

void LoadingState::LoadFaces()
{
	std::string dataPath = g_Engine->m_EngineConfig.GetString("data_path");
	std::string loadingPath(dataPath);
	loadingPath.append("/STATIC/FACES.VGA");
	ifstream shapesFile(loadingPath.c_str(), ios::binary);

	if(shapesFile.fail())
	{
		Log("Ultima VII files not found.  They should go into the Data/U7 folder.");
		m_loadingFailed = true;
		return;
	}

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
	
	stringstream shapes;
	shapes << shapesFile.rdbuf();
	shapesFile.close();

	vector<LoadingState::FLXEntryData> shapeEntryMap = ParseFLXHeader(shapes);

	for (int thisShape = 0; thisShape < shapeEntryMap.size(); ++thisShape)
	{
		//  The next 874 entries (150-1023) are objects.

		//  Read the shape data.
		int thisOffset = shapeEntryMap[thisShape].offset;
		int thisLength = shapeEntryMap[thisShape].length;
		if(thisOffset == 0 && thisLength == 0)
		{
			continue; //  No data for this shape.
		}

		shapes.seekg(thisOffset);
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

					int paletteNumber = 0;

					if (spanType == 0) // Not RLE, raw pixel data.
					{
						for (int i = 0; i < spanLength; ++i)
						{
							unsigned char Value = ReadU8(shapes);
							ImageDrawPixel(&tempImage, xStart + i, yStart, m_palettes[paletteNumber][Value]);
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
									ImageDrawPixel(&tempImage, xStart + i, yStart, m_palettes[paletteNumber][Value]);
								}
							}
							else
							{
								unsigned char Value = ReadU8(shapes);
								for (int i = 0; i < runLength; ++i)
								{
									ImageDrawPixel(&tempImage, xStart + i, yStart, m_palettes[paletteNumber][Value]);
								}
							}
							xStart += runLength;
						}
					}
				}
				g_ResourceManager->AddTexture(tempImage, "U7FACES" + std::to_string(thisShape) + std::to_string(i));
				//shapeData.SetDefaultTexture(tempImage);
			}

			continue;
		}
		else  //  This entry is not encoded.
		{

		}

		
	}

	shapesFile.close();
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
					g_World[j * 16 + l][i * 16 + k] = g_ChunkTypeList[chunkid][l][k];


					unsigned short shapenum = thisdata & 0x3ff;
					unsigned short framenum = (thisdata >> 10) & 0x1f;

					if (shapenum >= 150)
					{
						int nextId = GetNextID();
						AddObject(shapenum, framenum, nextId, (i * 16 + k), 0, (j * 16 + l));
						g_objectList[nextId]->m_UnitType = U7Object::UnitTypes::UNIT_TYPE_STATIC;
					}
				}
			}
		}
	}
}

void LoadingState::ParseIREGFile(stringstream& ireg, int superchunkx, int superchunky)
{
	unsigned char entryBuffer[20];
	unsigned char entryLength = 0;    // Gets entry length.
	vector<int> containerStack; //  Stack of container IDs.

	for (entryLength = ReadU8(ireg); !ireg.eof(); entryLength = ReadU8(ireg))
	{
		if (entryLength != 6 && entryLength != 12 && entryLength != 18)
		{
			if (!containerStack.empty())
			{
				//string logstring;
				//for (int i = 0; i < containerStack.size(); ++i)
				//{
					//logstring.append(">");
				//}
				//logstring.append("Closing container " + std::to_string(containerStack.back()));
				//DebugPrint(logstring);
				containerStack.pop_back();
			}
			continue;
		}

		ireg.read((char*)entryBuffer, entryLength);

		//  The first four bytes are always the position (either the world or gump position) of the object and its
		//  shape and frame data.

		int x = entryBuffer[0];
		int y = entryBuffer[1];

		int chunkx = x >> 4;
		int chunky = y >> 4;
		int intx = x & 0x0f;
		int inty = y & 0x0f;

		int actualx = 0;
		int actualy = 0;
		if (!containerStack.empty())
		{
			actualx = x;
			actualy = y;
		}
		else
		{
			actualx = (superchunkx * 256) + (chunkx * 16) + intx;
			actualy = (superchunky * 256) + (chunky * 16) + inty;
		}

		unsigned short shapeData = *(unsigned short*)&entryBuffer[2];
		int shape = shapeData & 0x3ff;
		int frame = (shapeData >> 10) & 0x1f;

		if (entryLength == 6) //  Object.
		{
			int z = entryBuffer[4];

			float lift1 = 0;
			float lift2 = 0;
			if (z != 0)
			{
				lift1 = z >> 4;
				lift2 = z & 0x0f;
				//z *= 8;
			}

			int quality = entryBuffer[5];

			int objectId = GetNextID();
			if (objectId == 231164)
			{
				int stopper = 0;
			}
			U7Object* newObject = AddObject(shape, frame, objectId, actualx, lift1, actualy);
			newObject->m_Quality = quality;

			if (shape == 607)
			{
				newObject->m_Visible = false;
			}

			if (!containerStack.empty())
			{
				newObject->m_InventoryPos = { static_cast<float>(actualx), static_cast<float>(actualy)};
				newObject->m_isContained = true;
				newObject->m_containingObjectId = containerStack.back();
				GetObjectFromID(containerStack.back())->AddObjectToInventory(objectId);
			}
			string logstring;
			for (int i = 0; i < containerStack.size(); ++i)
			{
				logstring.append(">");
			}
			//logstring.append("Object: " + std::to_string(objectId) + " named " + g_objectDataTable[shape].m_name + " at " + std::to_string(actualx) + ", " + std::to_string(actualy));
			//DebugPrint(logstring);
			continue;
		}
		else if (entryLength == 12) //  Container or Egg
		{
			unsigned char type = entryBuffer[4]; // Byte 5
			unsigned char proba1 = entryBuffer[5];
			unsigned char proba2 = entryBuffer[6]; // Byte 7
			unsigned char quality = entryBuffer[7]; // Byte 8
			unsigned char quantity = entryBuffer[8]; // Byte 9
			unsigned char z = entryBuffer[9]; // Byte 10
			unsigned char resistance = entryBuffer[10]; // Byte 11
			unsigned char flags = entryBuffer[11]; // Byte 12

			float lift1 = 0;
			float lift2 = 0;
			float lift3 = 0;
			if (z != 0)
			{
				lift1 = z >> 4;
				lift2 = z & 0x0f;
				lift3 = z / 8;
			}

			int id = GetNextID();
			if (id == 231164)
			{
				int stopper = 0;
			}

			U7Object* thisObject = AddObject(shape, frame, id, actualx, lift1, actualy);
			thisObject->m_Quality = quality;

			//  Egg or container?  01 Egg, 00 container.
			if (shape == 607)
			{
				thisObject->m_Visible = false;
			}
			if (g_objectDataTable[shape].m_name == "Egg" || g_objectDataTable[shape].m_name == "path" || type == 1)
			{
				thisObject->m_isEgg = true;
				thisObject->m_isContainer = false;

				//DebugPrint("Object: " + std::to_string(id) + " named " + g_objectDataTable[shape].m_name + " located at " + std::to_string(actualx) + ", " + std::to_string(actualy) + " is an egg");
			}
			else
			{
				thisObject->m_isContainer = true;
				if (!containerStack.empty()) //  Container is contained.
				{
					thisObject->m_InventoryPos = { static_cast<float>(actualx), static_cast<float>(actualy)};
					thisObject->m_isContained = true;
					thisObject->m_containingObjectId = containerStack.back();
					GetObjectFromID(containerStack.back())->AddObjectToInventory(id);
				}
				//string logstring;
				//for (int i = 0; i < containerStack.size(); ++i)
				//{
					//logstring.append(">");
				//}
				//logstring.append("Object " + std::to_string(id) + " of type " + std::to_string(type) + " named " +  g_objectDataTable[shape].m_name + " located at " + std::to_string(actualx) + ", " + std::to_string(actualy) + " is a container");
				//DebugPrint(logstring);
				unsigned char emptytest = ireg.peek(); //  Next byte is either 6, 12, or 18 if there are objects in this container.
				if (type == 0 || emptytest != 6 && emptytest != 12 && emptytest != 18)
				{
					//DebugPrint(">Container is empty.");
					continue;
				}
				else
				{
					containerStack.push_back(id);
				}
			}
		}
		else if (entryLength == 18)
		{
			//  Soak all 18 bytes, we're not handling this right now.
			for (int i = 0; i < 18; ++i)
			{
				unsigned char throwaway = ReadU8(ireg);
			}
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

	for(int i = 0; i < paletteEntryMap.size(); ++i)
	{
		if(paletteEntryMap[i].length == 0)
		{
			continue;
		}
		palette.seekg(paletteEntryMap[i].offset);
		unsigned char* paletteData = (unsigned char*)malloc(paletteEntryMap[1].length);
		palette.read((char*)paletteData, paletteEntryMap[1].length);
	
		std::array<Color, 256> thisPalette;
		//  Currently only loading the base palette.  Other palettes are for lighting effects.
		for (int j = 0; j < 256; ++j)
		{
			unsigned char r = paletteData[j * 3];
			unsigned char g = paletteData[j * 3 + 1];
			unsigned char b = paletteData[j * 3 + 2];
			thisPalette[j].r = r * 4;
			thisPalette[j].g = g * 4;
			thisPalette[j].b = b * 4;
			thisPalette[j].a = 255;
		}
	
		thisPalette[254] = Color{ 128, 128, 128, 128 };

		m_palettes.push_back(thisPalette);
	}


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
	Image tempImage = GenImageColor(2048, 256, WHITE);
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
					ImageDrawPixel(&tempImage, (thisShape * 8) + j, (thisFrame * 8) + i, m_palettes[0][Value]);
				}
			}
		}
	}

	g_Terrain->UpdateTerrainTexture(tempImage);
	g_Terrain->Init();
	Log("Done creating terrain.");
	UnloadImage(tempImage);

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
				int paletteNumber = 0;
				// if(thisShape == 508 || thisShape == 512 || (thisShape == 732 && (i == 4 || i == 5))) // Stained glass
				// {
				// 	paletteNumber = 11;
				// }
				// if(thisShape == 912) // Blood
				// {
				// 	paletteNumber = 11;
				// }

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
							ImageDrawPixel(&tempImage, xStart + i, yStart, m_palettes[paletteNumber][Value]);
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
									ImageDrawPixel(&tempImage, xStart + i, yStart, m_palettes[paletteNumber][Value]);
								}
							}
							else
							{
								unsigned char Value = ReadU8(shapes);
								for (int i = 0; i < runLength; ++i)
								{
									ImageDrawPixel(&tempImage, xStart + i, yStart, m_palettes[paletteNumber][Value]);
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
	string directoryPath("Models/3dmodels");

	for (const auto& entry : directory_iterator(directoryPath))
	{
        if (entry.is_regular_file())
		{
            std::string ext = entry.path().extension().string();

            if (ext == ".obj" || ext == ".gltf")
			{
                std::string filepath = entry.path().generic_string();
					g_ResourceManager->AddModel(filepath);
            	RaylibModel* model = g_ResourceManager->GetModel(filepath);
            	if (filepath != "Models/3dmodels/flat.obj")
            	{
            		model->Decenter();
            	}
            }
        }
    }
}

void LoadingState::CreateObjectTable()
{
	//  Open the two files that define the objects in the object table.
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
		g_objectDataTable[i].m_weight = float(weight) * .10f;
		unsigned char volume;
		wgtvolfile.read((char*)&volume, sizeof(char));
		g_objectDataTable[i].m_volume = float(volume);

		//  All other data from tfa.dat
		char buffer[3]; // 3 bytes to store the 24 bits
		tfafile.read(buffer, sizeof(buffer));

		g_objectDataTable[i].m_hasSoundEffect = buffer[0] & 0x01;
		g_objectDataTable[i].m_rotatable = (buffer[0] >> 1) & 0x01;
		g_objectDataTable[i].m_isAnimated = (buffer[0] >> 2) & 0x01;
		g_objectDataTable[i].m_isNotWalkable = (buffer[0] >> 3) & 0x01;
		g_objectDataTable[i].m_isWater = (buffer[0] >> 4) & 0x01;
		g_objectDataTable[i].m_height = (buffer[0] >> 5) & 0x07;
		g_objectDataTable[i].m_shapeType = (buffer[1] >> 4) & 0x0F;
		g_objectDataTable[i].m_isTrap = (buffer[1] >> 8) & 0x01;
		g_objectDataTable[i].m_isDoor = (buffer[1] >> 9) & 0x01;
		g_objectDataTable[i].m_isVehiclePart = (buffer[1] >> 10) & 0x01;
		g_objectDataTable[i].m_isNotSelectable = (buffer[1] >> 11) & 0x01;
		g_objectDataTable[i].m_width = ((buffer[2]) & 0x07) + 1;
		g_objectDataTable[i].m_depth = ((buffer[2] >> 3) & 0x07) + 1;
		g_objectDataTable[i].m_isLightSource = (buffer[2] >> 6) & 0x01;
		g_objectDataTable[i].m_isTranslucent = (buffer[2] >> 7) & 0x01;
		g_objectDataTable[i].m_name = shapeNames[i];
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
			ReadS32(file); //  Soak this data or it will corrupt the next entry.
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

	for (auto node = subFileMap.begin(); node != subFileMap.end(); ++node)
	{
		if (node->length == 0)
		{
			continue; // No actual data at this offset.
		}
		subFiles.seekg(node->offset);
		//  First thirteen characters are the filename.
		char filenamein[13];
		subFiles.read(filenamein, 13);
		string filename = string(filenamein);
		cout << "Loading " << filename << endl;

		//  Based on the filename, do...something.
		if (filename == "npc.dat")
		{
			short npcCount1 = ReadU16(subFiles);
			short npcCount2 = ReadU16(subFiles);
			int fullcount = npcCount1 + npcCount2;
			int filepos = subFiles.tellg();
			
			for (int i = 0; i < 256; ++i)
			{
				//if (i == 139) // This NPC is broken and attempting to parse it messes up all NPCs after it.  It's not used anyway so we just skip it.
				//{
				//	//Log("Stopper");// subFiles.seekg(2761, ios::cur);
				//}

				int size = sizeof(NPCData);
				NPCData thisNPC;
				
				thisNPC.x = ReadU8(subFiles);
				thisNPC.y = ReadU8(subFiles);
				thisNPC.shapeId = ReadU16(subFiles);

				unsigned int shapenum = thisNPC.shapeId & 0x3ff;
				unsigned int framenum = thisNPC.shapeId >> 10;
				if (shapenum == 721)
				{
					if (!g_Player->GetIsMale())
					{
						shapenum = 989;
					}
				}

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

            unsigned int nextID = GetNextID();
				AddObject(shapenum, 16, nextID, chunkx * 16 * 16 + thisNPC.x, thisNPC.lift >> 4, chunky * 16 * 16 + thisNPC.y);
            g_objectList[nextID].get()->m_isContainer = true;
            g_objectList[nextID].get()->m_hasConversationTree = true;

				thisNPC.str = ReadU8(subFiles);
				thisNPC.dex = ReadU8(subFiles);
				thisNPC.iq = ReadU8(subFiles);
				thisNPC.combat = ReadU8(subFiles);
				thisNPC.magic = ReadU8(subFiles);
				thisNPC.DAM = ReadU8(subFiles);

				subFiles.read(thisNPC.soak1, 3);

				thisNPC.status2 = ReadU16(subFiles);
				thisNPC.id = ReadU8(subFiles);

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

				//  Make walk anim frames if necessary.
				thisNPC.m_walkTextures.resize(4);
				for (int f = 0; f < 4; f++)
				{
					thisNPC.m_walkTextures[f].resize(2);
				}

				//  Check if required frames exist for this shape
				if (g_shapeTable[shapenum][0].m_texture == nullptr ||
				    g_shapeTable[shapenum][1].m_texture == nullptr ||
				    g_shapeTable[shapenum][2].m_texture == nullptr ||
				    g_shapeTable[shapenum][16].m_texture == nullptr ||
				    g_shapeTable[shapenum][17].m_texture == nullptr)
				{
					// Skip this NPC - missing required animation frames
					Log("Warning: Skipping NPC with shape " + to_string(shapenum) + " - missing required animation frames");
					continue;
				}

				Image image;

				//  South-west
				thisNPC.m_walkTextures[0][0] = &g_shapeTable[shapenum][16].m_texture->m_Texture;
				thisNPC.m_walkTextures[0][1] = &g_shapeTable[shapenum][17].m_texture->m_Texture;

				//  North-west

				//  Frame 1
				std::string texturename = to_string(shapenum) + "_NW_0";
				if(g_ResourceManager->DoesTextureExist(texturename))
				{
					thisNPC.m_walkTextures[1][0] = g_ResourceManager->GetTexture(texturename);
				}
				else
				{
					image = ImageCopy(g_shapeTable[shapenum][16].m_texture->m_Image);
					ImageFlipHorizontal(&image);
					g_ResourceManager->AddTexture(image, texturename);
					thisNPC.m_walkTextures[1][0] = g_ResourceManager->GetTexture(texturename);
				}

				//  Frame 2

				texturename = to_string(shapenum) + "_NW_1";
				if(g_ResourceManager->DoesTextureExist(texturename))
				{
					thisNPC.m_walkTextures[1][1] = g_ResourceManager->GetTexture(texturename);
				}
				else
				{
					image = ImageCopy(g_shapeTable[shapenum][17].m_texture->m_Image);
					ImageFlipHorizontal(&image);
					g_ResourceManager->AddTexture(image, texturename);
					thisNPC.m_walkTextures[1][1] = g_ResourceManager->GetTexture(texturename);
				}

				//  North-east
				thisNPC.m_walkTextures[2][0] = &g_shapeTable[shapenum][0].m_texture->m_Texture;
				thisNPC.m_walkTextures[2][1] = &g_shapeTable[shapenum][1].m_texture->m_Texture;

				//  South-east

				//  Frame 1
				texturename = to_string(shapenum) + "_SE_0";
				if(g_ResourceManager->DoesTextureExist(texturename))
				{
					thisNPC.m_walkTextures[3][0] = g_ResourceManager->GetTexture(texturename);
				}
				else
				{
					image = ImageCopy(g_shapeTable[shapenum][1].m_texture->m_Image);
					ImageFlipHorizontal(&image);
					g_ResourceManager->AddTexture(image, texturename);
					thisNPC.m_walkTextures[3][0] = g_ResourceManager->GetTexture(texturename);
				}

				//  Frame 2

				texturename = to_string(shapenum) + "_SE_1";
				if(g_ResourceManager->DoesTextureExist(texturename))
				{
					thisNPC.m_walkTextures[3][1] = g_ResourceManager->GetTexture(texturename);
				}
				else
				{
					image = ImageCopy(g_shapeTable[shapenum][2].m_texture->m_Image);
					ImageFlipHorizontal(&image);
					g_ResourceManager->AddTexture(image, texturename);
					thisNPC.m_walkTextures[3][1] = g_ResourceManager->GetTexture(texturename);
				}

				thisNPC.m_objectID = nextID;

				int newfilepos = subFiles.tellg();

				// if (thisNPC.id > 256)
				// 	continue;

				g_NPCData[thisNPC.id] = make_unique<NPCData>(thisNPC);

				g_objectList[nextID].get()->NPCInit(g_NPCData[thisNPC.id].get());
				//g_ObjectList[nextID].get()->m_NPCID = thisNPC.id;
				//g_ObjectList[nextID]->m_isNPC = true;


				if (thisNPC.type != 0 && i != 139 && i != 148) // This NPC has an inventory
				{
					unsigned char length = 99;
					bool incontainer = false;
					while (length != 0)
					{
						int pointerlocation = subFiles.tellg();
						length = ReadU8(subFiles);
						if (length == 6) //  Object.
						{
   						unsigned char x = ReadU8(subFiles);
      					unsigned char y = ReadU8(subFiles);

               		int chunkx = x >> 4;
                  	int chunky = y >> 4;
                     int intx = x & 0x0f;
                     int inty = y & 0x0f;

                     int actualx = (chunkx * 16) + intx;
                     int actualy = (chunky * 16) + inty;

                     unsigned short shapeData = ReadU16(subFiles);
                     int shape = shapeData & 0x3ff;
                     int frame = (shapeData >> 10) & 0x1f;

                     unsigned char z = ReadU8(subFiles);
                     float lift1 = 0;
                     float lift2 = 0;
                     if (z != 0)
                     {
                        lift1 = z >> 4;
                        lift2 = z & 0x0f;
							//z *= 8;
                     }
						
                     unsigned char quality = ReadU8(subFiles);
                     
                     int objectId = GetNextID();
							U7Object* thisObject = AddObject(shape, frame, objectId, actualx, lift1, actualy);
							thisObject->m_isContained = true;
                     
							AddObjectToContainer(objectId, nextID);
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
			}
			stringstream npcData;
		}
		if (filename.substr(0, 6) == "u7ireg")
		{
			//  Get the superchunk coordinates from the filename.
			std::string hex_part = filename.substr(6, 2);

			int coord = std::stoi(hex_part, nullptr, 16);

			int schunkx = coord % 12;
			int schunky = coord / 12;

			//  Load the rest of the data into a stringstream.
			string buffer(node->length - 13, ' ');
			subFiles.read(&buffer[0], node->length - 13);
			stringstream ss(buffer);

			ParseIREGFile(ss, schunkx, schunky);
		}
	}
}

void LoadingState::LoadNPCSchedules()
{
	ifstream file("Data/U7/STATIC/SCHEDULE.DAT", ios::binary);
	if (file.is_open())
	{
		unsigned int npcCount = ReadU32(file); // Should be 256.
		
		unordered_map<unsigned char, unsigned short> schedulesPerNPC;

		int entriesLastIndex = 0;
		for (int i = 0; i < npcCount; ++i)
		{
			unsigned short entryIndex = ReadU16(file);
			unsigned int entriesThisIndex = entryIndex - entriesLastIndex;
			entriesLastIndex = entryIndex;
			schedulesPerNPC[i] = entriesThisIndex;
		}

		int location = file.tellg();

		//  Now that we know how many entries there are for each NPC, we can read the entries.
		for (int i = 1; i < npcCount; ++i)
		{
			unsigned short entryCount = schedulesPerNPC[i];
			for (int j = 0; j < entryCount; ++j)
			{
				NPCSchedule thisEntry;

				unsigned char timeAndActivity = ReadU8(file);
				unsigned char chunkX = ReadU8(file);
				unsigned char chunkY = ReadU8(file);
				unsigned char superChunk = ReadU8(file);

				thisEntry.m_destX = (superChunk % 12) * 256 + (chunkX);
				thisEntry.m_destY = (superChunk / 12) * 256 + (chunkY);

				// Highest 5 bits are the activity number, lowest 3 bits are the time of day.
				thisEntry.m_activity = (timeAndActivity >> 3) & 0x1F;
				thisEntry.m_time = timeAndActivity & 0x07;

				g_NPCSchedules[i].push_back(thisEntry);
				location = file.tellg();
			}
		}

		file.close();
	}
}
