#include "Globals.h"
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
    g_TestMesh = g_ResourceManager->GetMesh("Data/Meshes/standard.txt");

    g_Sprites = g_ResourceManager->GetTexture("Images/sprites.png");

    g_Cursor = g_ResourceManager->GetTexture("Images/cursor.png");

    g_minimapSize = g_Display->GetWidth() / 6;

    g_WalkerTexture = g_ResourceManager->GetTexture("Images/VillagerWalkFixed.png", false);
    g_WalkerMask = g_ResourceManager->GetTexture("Images/VillagerWalkMask.png", false);
    MakeAnimationFrameMeshes();

    m_loadingBackground = g_ResourceManager->GetTexture("Images/loading.png", false);

    m_red = 1.0;
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
   m_red = (g_Engine->GameTimeInSeconds() * 0.5f) - int(g_Engine->GameTimeInSeconds());

   UpdateLoading();
}


void LoadingState::Draw()
{
   g_Display->ClearScreen();

 //  g_Display->DrawImage(m_loadingBackground, 0, 0, g_Display->GetWidth(), g_Display->GetHeight(), Color(1,  m_red, m_red, 1));

   //m_LoadingGui->Draw();
   
   DrawConsole();
   
   g_Display->DrawImage(g_Cursor, g_Input->m_MouseX, g_Input->m_MouseY);

}


void LoadingState::UpdateLoading()
{
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

	if (!m_loadingShapes)
	{
		AddConsoleString(std::string("Loading shapes..."));
		CreateShapeTable();
		m_loadingShapes = true;
		return;
	}

	if (!m_loadingObjects)
	{
		AddConsoleString(std::string("Loading objects..."));
		CreateObjectTable();
		m_loadingObjects = true;
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

	g_StateMachine->MakeStateTransition(STATE_TITLESTATE);
}

void LoadingState::LoadChunks()
{
	//  Load data for all chunks first
	FILE* u7chunksfile = fopen("Data/U7/STATIC/U7CHUNKS", "rb");
	if (u7chunksfile == nullptr)
	{
		Log("Ultima VII files not found.  They should go into the Data/U7 folder.");
		//        throw("Ultima VII files not found.  They should go into the Data/U7 folder.");
	}

	//  Each chunk should be an ID associated with 16 arrays, each 16 unsigned chars deep.
	for (int i = 0; i < 3072; ++i)
	{
		for (int j = 0; j < 16; ++j)
		{
			vector<unsigned short> thisvector;
			for (int k = 0; k < 16; ++k)
			{
				unsigned short thisdata;
				unsigned char frontend;
				unsigned char backend;
				fread(&thisdata, sizeof(unsigned short), 1, u7chunksfile);

				unsigned int shapenum = thisdata & 0x3ff;
				unsigned int framenum = thisdata >> 10;

				thisvector.push_back(thisdata);
			}
			m_Chunkmap[i].push_back(thisvector);
		}
	}
	fclose(u7chunksfile);
}

void LoadingState::LoadMap()
{
	FILE* u7mapfile = fopen("Data/U7/STATIC/U7MAP", "rb");
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

					m_u7map[k * 16 + j][l * 16 + i] = thisdata;
				}
			}
		}
	}
	fclose(u7mapfile);
}

void LoadingState::LoadIFIX()
{
	for (int superchunky = 0; superchunky < 12; ++superchunky)
	{
		for (int superchunkx = 0; superchunkx < 12; ++superchunkx)
		{
			std::stringstream ss;
			int thissuperchunk = superchunkx + (superchunky * 12);
			if (thissuperchunk < 16)
			{
				ss << "Data/U7/STATIC/U7IFIX0" << std::hex << thissuperchunk;
			}
			else
			{
				ss << "Data/U7/STATIC/U7IFIX" << std::hex << thissuperchunk;
			}
			const std::string s = ss.str();

			FILE* u7thisifix = fopen(s.c_str(), "rb");

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

							//AddUnit(0, shape, GetNextID(), (superchunkx * 256) + (chunkx * 16) + x, z + 4, (superchunky * 256) + (chunky * 16) + y);

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
			int chunkid = m_u7map[i][j];
			for (int k = 0; k < 16; ++k)
			{
				for (int l = 0; l < 16; ++l)
				{
					unsigned int thisdata = m_Chunkmap[chunkid][l][k];
					g_World[j * 16 + k][i * 16 + l] = m_Chunkmap[chunkid][l][k];


					unsigned int shapenum = thisdata & 0x3ff;
					unsigned int framenum = thisdata >> 10;

					if (shapenum >= 150)
					{
						if (shapenum == 257)
						{
							int stopper = 0;
						}

						AddUnit(0, shapenum, GetNextID(), (j * 16 + k), 0, (i * 16 + l));

//						int id = AddObject(ObjectDrawTypes::OBJECT_DRAW_CUBOID, GetNextID(), shapenum, framenum, (j * 16 + k) + .5f, 0, (i * 16 + l) + .5f);
//						g_ObjectList[id]->Init("Data/Objects/Cuboid.cfg");

//						g_ObjectList[id]->SetObjectData(shapenum);
					}
				}
			}
		}
	}
}


void LoadingState::LoadIREG()
{
	return;
	for (int superchunky = 0; superchunky < 12; ++superchunky)
	{
		for (int superchunkx = 0; superchunkx < 12; ++superchunkx)
		{
			std::stringstream ss;
			int thissuperchunk = superchunkx + (superchunky * 12);
			if (thissuperchunk < 16)
			{
				ss << "Data/U7/STATIC/U7IREG0" << std::hex << thissuperchunk;
			}
			else
			{
				ss << "Data/U7/STATIC/U7IREG" << std::hex << thissuperchunk;
			}
			const std::string s = ss.str();

			FILE* u7thisireg = fopen(s.c_str(), "rb");

			while (u7thisireg)
			{

			}

			//int stopper = 0;
			fclose(u7thisireg);
		}
	}
}

void LoadingState::CreateShapeTable()
{
	for (int i = 150; i < 1024; ++i)
	{
		std::stringstream filename;
		filename << "Images/Objects/u7shape_" << std::setfill('0') << std::setw(4) << std::to_string(i) << ".png";
		g_shapeTable[i] = g_ResourceManager->GetTexture(filename.str(), false);
	}
}

void LoadingState::CreateObjectTable()
{
	//  Open the two files that define the objects in the object table.
	std::stringstream tfa;

	tfa << "Data/U7/STATIC/tfa.dat";

	ifstream tfafile(tfa.str(), ios::binary);

	std::stringstream wgtvol;

	wgtvol << "Data/U7/STATIC/wgtvol.dat";

	ifstream wgtvolfile(wgtvol.str(), ios::binary);

	std::stringstream text;

	text << "Data/U7/STATIC/text.flx";

	ifstream textfile(text.str(), ios::binary);

	//  Even though these files don't have an .flx description, 
//  these are flex files.  Flex files have a header of 80 bytes,
//  which is the same for every file: "Ultima VII Data File (C) 1992 Origin Inc."
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

	struct entrydata
	{
		unsigned int offset;
		unsigned int length;
	};

	std::vector<entrydata> entrymap;
	entrymap.resize(entrycount);
	//  Now we have the data we want.  Each entry is 8 bytes long.
	for (int i = 0; i < entrycount; ++i)
	{
		entrydata thisentry;
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
		shapeNames.push_back(thisname);
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
		g_objectTable[i].m_weight = float(weight) / .10f;
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