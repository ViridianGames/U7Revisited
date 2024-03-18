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
	g_minimapSize = g_Display->GetWidth() / 6;

	MakeAnimationFrameMeshes();

	m_tree = g_ResourceManager->GetTexture("Images/Objects/453-0.png", false);

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
	if (g_Input->WasKeyPressed(KEY_ESCAPE))
	{
		g_Engine->m_Done = true;
	}

	//static int y = m_tree->GetHeight() - 1;
	//static int x = m_tree->GetWidth();

	//static int numsteps = 0;
	//static int maxnumsteps = m_tree->GetWidth() * .5 - 1;

	if (m_startRotating)
	{
		
		//Color c = m_tree->GetPixel(m_tree->GetWidth() - 1, y);
		//for (int i = (m_tree->GetWidth() - 1); i >=0; --i)
		//{
		//	Color c = m_tree->GetPixel(i - 1, y);
		//	m_tree->PutPixel(i, y, c);
		//}
		//m_tree->PutPixel(0, y, c);

		//++numsteps;
		//if(numsteps > maxnumsteps)
		//{
		//	//m_startRotating = false;
		//	--y;
		//	++maxnumsteps;
		//	numsteps = 0;
		//}
		

		//m_tree->UpdateData();
	}

	UpdateLoading();
}


void LoadingState::Draw()
{
	g_Display->ClearScreen();

	if (m_loadingFailed == true)
	{
		g_Font->DrawString("Ultima VII files not found.  They should go into the Data/U7 folder.", 0, 0);
		g_Font->DrawString("Press ESC to exit.", 0, g_Font->GetStringMetrics(" ") * 3);
	}
	else
	{
		DrawConsole();
	}

	if (m_objectViewing)
	{

	}

	g_Display->DrawImage(g_Cursor, g_Input->m_MouseX, g_Input->m_MouseY);

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
	}
	else
	{
		return;
	}

	g_StateMachine->MakeStateTransition(STATE_TITLESTATE);
}

unsigned char LoadingState::ReadU8(FILE* buffer)
{
	unsigned char thisData;
	fread(&thisData, sizeof(unsigned char), 1, buffer);
	return thisData;
}

unsigned short LoadingState::ReadU16(FILE* buffer)
{
	unsigned short thisData;
	fread(&thisData, sizeof(unsigned short), 1, buffer);
	return thisData;
}

unsigned int LoadingState::ReadU32(FILE* buffer)
{
	unsigned int b0 = ReadU8(buffer);
	unsigned int b1 = ReadU8(buffer);
	unsigned int b2 = ReadU8(buffer);
	unsigned int b3 = ReadU8(buffer);
	return (b3 << 24) | (b2 << 16) | (b1 << 8) | b0;
}

char LoadingState::ReadS8(FILE* buffer)
{
	char thisData;
	fread(&thisData, sizeof(char), 1, buffer);
	return thisData;
}

short LoadingState::ReadS16(FILE* buffer)
{
	short thisData;
	fread(&thisData, sizeof(short), 1, buffer);
	return thisData;
}

int LoadingState::ReadS32(FILE* buffer)
{
	return static_cast<signed int>(ReadU32(buffer));
}

void LoadingState::LoadVersion()
{
	FILE* u7versionfile = fopen("version.txt", "r");
	if (u7versionfile == nullptr)
	{
		// choose a default?
		g_VERSION = "v0.0.1";
		return;
	}

	char buffer[20];
	fgets(buffer, 20, u7versionfile);
	g_VERSION = buffer;

	fclose(u7versionfile);
}

void LoadingState::LoadChunks()
{
	//  Load data for all chunks first
	FILE* u7chunksfile = fopen("Data/U7/STATIC/U7CHUNKS", "rb");
	if (u7chunksfile == nullptr)
	{
		Log("Ultima VII files not found.  They should go into the Data/U7 folder.");
		m_loadingFailed = true;
		return;
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

					m_u7chunkmap[k * 16 + j][l * 16 + i] = thisdata;
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
				ss << "U7IFIX0" << std::hex << thissuperchunk;
			}
			else
			{
				ss << "U7IFIX" << std::hex << thissuperchunk;
			}
			std::string s = ss.str();
            
            std::transform(s.begin(), s.end(), s.begin(), ::toupper);
            
            s.insert(0, "Data/U7/STATIC/");

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
			int chunkid = m_u7chunkmap[i][j];
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
						AddObject(shapenum, framenum, GetNextID(), (j * 16 + k), 0, (i * 16 + l));
					}
				}
			}
		}
	}
}

void LoadingState::LoadIREG()
{
	for (int superchunky = 0; superchunky < 12; ++superchunky)
	{
		for (int superchunkx = 0; superchunkx < 12; ++superchunkx)
		{
            std::stringstream ss;
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
            
            s.insert(0, "Data/U7/GAMEDAT/");

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
					fread(&length, sizeof(unsigned char), 1, u7thisireg);
					if (length == 6) //  Object.
					{
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

						AddObject(shape, frame, GetNextID(), actualx, 0, actualy);
						unsigned char quality;
						fread(&quality, sizeof(unsigned char), 1, u7thisireg);
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
	int counter = 0;
	for (int i = 150; i < 1024; ++i)
	{
		for (int j = 0; j < 32; ++j)
		{
			g_shapeTable[i][j].Init(i, j);
			if (g_shapeTable[i][j].IsValid())
			{
				++counter;
			}
		}
	}

	//  Load palette data
	FILE* palette = fopen("Data/U7/STATIC/PALETTES.FLX", "rb");
	if (palette == nullptr)
	{
		Log("Ultima VII files not found.  They should go into the Data/U7 folder.");
		throw("Ultima VII files not found.  They should go into the Data/U7 folder.");
	}

	vector<FLXEntryData> paletteEntryMap = ParseFLXHeader(palette);

	//  We only want the first palette for now.
	fseek(palette, paletteEntryMap[0].offset, SEEK_SET);
	unsigned char* paletteData = (unsigned char*)malloc(paletteEntryMap[0].length);
	fread(paletteData, sizeof(unsigned char), paletteEntryMap[0].length, palette);

	//  Currently only loading the base palette.  Other palettes are for lighting effects.
	for (int j = 0; j < 256; ++j)
	{
		unsigned char r = paletteData[j * 3];
		unsigned char g = paletteData[j * 3 + 1];
		unsigned char b = paletteData[j * 3 + 2];
		m_palette[j] = Color(r * 4, g * 4, b * 4, 255);
	}

	fclose(palette);

	//  Load shape data
	FILE* shapes = fopen("Data/U7/STATIC/SHAPES.VGA", "rb");

	vector<FLXEntryData> shapeEntryMap = ParseFLXHeader(shapes);

	//  The first 150 entries (0-149) are terrain textures.  They are not
	//  rle-encoded.  Splat them directly to the terrain texture.
	g_Terrain->m_TerrainTexture.Create(2048, 256, false);
	for (int thisShape = 0; thisShape < 150; ++thisShape)
	{
		fseek(shapes, shapeEntryMap[thisShape].offset, SEEK_SET);
		int numFrames = shapeEntryMap[thisShape].length / 64;
		for (int thisFrame = 0; thisFrame < numFrames; ++thisFrame)
		{
			for (int i = 0; i < 8; ++i)
			{
				for (int j = 0; j < 8; ++j)
				{
					unsigned char Value = ReadU8(shapes);
					g_Terrain->m_TerrainTexture.PutPixel((thisShape * 8) + j, (thisFrame * 8) + i, m_palette[Value]);
				}
			}

		}
	}
	g_Terrain->m_TerrainTexture.UpdateData();
	
	 
//
//	for (int thisShape = 150; thisShape < 1024; ++thisShape)
//	{
//		//  The next 874 entries (150-1023) are objects.
//
//		//  Read the shape data.
//		fseek(shapes, shapeEntryMap[thisShape].offset, SEEK_SET);
//
//		unsigned int fileSize = ReadU32(shapes);
//		unsigned int firstOffset = ReadU32(shapes);
//
//		unsigned int frameCount = ((firstOffset - 4) / 4);
//		std::vector<unsigned int> frameOffsets;
//		frameOffsets.resize(frameCount);
//		frameOffsets[0] = 0;
//		for (int i = 1; i < frameCount; ++i)
//		{
//			frameOffsets[i] = ReadU32(shapes);
//		}
//
//		//  Read the frame data.
//		for (int thisFrame = 0; thisFrame < frameCount; ++thisFrame)
//		{
//			fseek(shapes, shapeEntryMap[thisShape].offset + frameOffsets[thisFrame], SEEK_SET);
//
//			unsigned short MaxX = ReadU16(shapes);
//			unsigned short OffsetX = ReadU16(shapes);
//			unsigned short OffsetY = ReadU16(shapes);
//			unsigned short MaxY = ReadU16(shapes);
//
//			int height = MaxY + OffsetY + 1;
//			int width = MaxX + OffsetX + 1;
//
//			g_shapeTable[thisShape][thisFrame] = new Texture();
//
//			g_shapeTable[thisShape][thisFrame]->Create(width, height, false);
//
//			// Read each span.  Spans can be either RLE or raw pixel data.
//			// We do not know the number of spans in advance, so we read until we hit a span of length 0.
//			int pixelCounter = 0;
//			while (true)
//			{
//				unsigned short spanData = ReadU16(shapes);
//				unsigned short spanLength = spanData >> 1;
//				unsigned short spanType = spanData & 1;
//
//				if (spanData == 0)
//				{
//					g_shapeTable[thisShape][thisFrame]->UpdateData();
//					break; //  There are no more spans; we're done with this frame.
//				}
//
//				short xStart = ReadS16(shapes);
//				short YStart = ReadS16(shapes);
//
//				if (spanType == 0) // Not RLE, raw pixel data.
//				{
//					for (int i = 0; i < spanLength; ++i)
//					{
//						unsigned char Value = ReadU8(shapes);
///*						int x = pixelCounter % width;
//						int y = pixelCounter / height;
//						g_shapeTable[thisShape][thisFrame]->PutPixel(x, y, m_palette[Value]);
//						++pixelCounter*/;
//					}
//				}
//				else // RLE.
//				{
//					int endX = xStart + spanLength;
//
//					while (xStart < endX)
//					{
//						unsigned char RunData = ReadU8(shapes);
//						int RunLength = RunData >> 1;
//						int RunType = RunData & 1;
//
//						if (RunType == 0) // Once again, non-RLE
//						{
//							for (int i = 0; i < RunLength; ++i)
//							{
//								unsigned char Value = ReadU8(shapes);
//								//int x = pixelCounter % width;
//								//int y = pixelCounter / height;
//								//g_shapeTable[thisShape][thisFrame]->PutPixel(x, y, m_palette[Value]);
//								//++pixelCounter;
//							}
//						}
//						else
//						{
//							unsigned char Value = ReadU8(shapes);
//							//for (int i = 0; i < RunLength; ++i)
//							//{
//							//	int x = pixelCounter % width;
//							//	int y = pixelCounter / height;
//							//	g_shapeTable[thisShape][thisFrame]->PutPixel(x, y, m_palette[RunData]);
//							//	++pixelCounter;
//							//}
//						}
//
//						xStart += RunLength;
//					}
//				}
//			}
//		}
//	}
}

//void LoadingState::ReadImage(int OffsetX, int OffsetY, int BlockLength)
//{
//	for (int i = 0; i < BlockLength; ++i)
//	{
//		unsigned char Value = ReadU8(shapes);
//		int x = OffsetX + i;
//		int y = OffsetY;
//		g_shapeTable[thisShape][0]->PutPixel(x, y, m_palette[Value]);
//	}
//}

void LoadingState::CreateObjectTable()
{
	//  Open the two files that define the objects in the object table.
	std::stringstream tfa;

	tfa << "Data/U7/STATIC/TFA.DAT";

	ifstream tfafile(tfa.str(), ios::binary);

	std::stringstream wgtvol;

	wgtvol << "Data/U7/STATIC/WGTVOL.DAT";

	ifstream wgtvolfile(wgtvol.str(), ios::binary);

	std::stringstream text;

	text << "Data/U7/STATIC/TEXT.FLX";

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


//  Most Ultima VII files are flex files.  Thus, a general function that can
//  parse flex file headers.  This function takes a FILE* and returns a vector
//  of FLXEntryData, which is a struct containing the offset and length of
//  each entry in the file.  It moves the file pointers to the point where
//  the calling code can immediately start reading out data.
std::vector<LoadingState::FLXEntryData> LoadingState::ParseFLXHeader(FILE* file)
{
	char header[80];
	fread(&header, sizeof(char), 80, file);

	//  This is followed two unsigned ints.  The first unsigned int is always the same, so we can ignore it.
	//  The second is the number of g_objecTable in the file.
	unsigned int throwaway;
	unsigned int entrycount;
	fread(&throwaway, sizeof(unsigned int), 1, file);
	fread(&entrycount, sizeof(unsigned int), 1, file);

	//  Now we have ten unsigned ints worth of data that we can ignore.
	for (int i = 0; i < 10; ++i)
	{
		fread(&throwaway, sizeof(unsigned int), 1, file);
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
