#include "Globals.h"
#include "U7Globals.h"
#include "MainState.h"
#include "Logging.h"

#include <list>
#include <string>
#include <sstream>
#include <math.h>
#include <fstream>
#include <algorithm>
#include <unordered_map>

using namespace std;

////////////////////////////////////////////////////////////////////////////////
//  MainState
////////////////////////////////////////////////////////////////////////////////

MainState::~MainState()
{
   SaveReplay();
   Shutdown();
}

void MainState::Init(const string& configfile)
{
   g_TestMesh = g_ResourceManager->GetMesh("Data/Meshes/standard.txt");

   g_Sprites = g_ResourceManager->GetTexture("Images/sprites.png");
   
   g_WalkerTexture = g_ResourceManager->GetTexture("Images/VillagerWalkFixed.png", false);
   g_WalkerMask = g_ResourceManager->GetTexture("Images/VillagerWalkMask.png", false);
   MakeAnimationFrameMeshes();

   m_Gui = new Gui();
   
   m_Gui->SetLayout(0, 0, 138, 384, Gui::GUIP_UPPERRIGHT);
   
   m_Gui->AddPanel(1000, 0, 0, 138, 384, Color(.56, .50, .375, 1.0));
   
   m_Gui->AddPanel( 1002, 18, 136, 100, 8, Color(0, 0, 0, 1));
   
   m_Gui->AddPanel( 1003, 18, 136, 100, 8, Color(.5, 1, .5, 1));
   
   m_Gui->AddPanel( 1004, 18, 136, 100, 8, Color(1, 1, 1, 1), false);
   
   m_ManaBar = m_Gui->GetElement(1003).get();

   m_Gui->m_Scale = float(g_Display->GetHeight()) / float(m_Gui->m_Height);

   m_SpellsPanel = new Gui();

   m_SpellsPanel->SetLayout(0, 0, 138, 384, Gui::GUIP_UPPERRIGHT);
   
   m_SpellsPanel->m_Scale = float(g_Display->GetHeight()) / float(m_Gui->m_Height);
   
   m_OptionsGui = new Gui();
   
   m_OptionsGui->m_Active = false;
   
   m_OptionsGui->SetLayout(0, 0, 250, 320, Gui::GUIP_CENTER);
   m_OptionsGui->AddPanel(1000, 0, 0, 250, 320, Color(0, 0, 0, .75));
   m_OptionsGui->AddPanel(9999, 0, 0, 250, 320, Color(1, 1, 1, 1), false);
   m_OptionsGui->AddTextArea(1001, g_SmallFont.get(), "", 125, 100, 0, 0, Color(1, 1, 1, 1), GuiTextArea::CENTERED);
   m_OptionsGui->AddTextButton(1002, 70, 98, "<-", g_SmallFont.get(), Color(1, 1, 1, 1), Color(0, 0, 0, .75), Color(1, 1, 1, 1));
   m_OptionsGui->AddTextButton(1003, 170, 98, "->", g_SmallFont.get(), Color(1, 1, 1, 1), Color(0, 0, 0, .75), Color(1, 1, 1, 1));
   
   m_LastUpdate = 0;

   int stopper = 0;

   m_NumberOfVisibleUnits = 0;
   
   g_CameraMoved = true;
   
   m_DrawMarker = false;
   m_MarkerRadius = 1.0f;
   
   // Find all SDL resolutions.
//   m_Resolutions = SDL_ListModes(NULL, SDL_FULLSCREEN|SDL_HWSURFACE);
//   m_CurrentRes = 0;
   
   m_GuiMode = 0;
   
   //  Networking
   m_ArePlayersSetUp = false;
   m_TurnLength = g_Engine->m_EngineConfig.GetNumber("turn_length");
   g_CurrentUpdate = 1;
   m_NextTurnUpdate = g_CurrentUpdate + m_TurnLength;
   m_ClientAuthorizedUpdate = g_CurrentUpdate + (2 * m_TurnLength);
   m_SentServerEvents = false;

//   AddConsoleString("Welcome to Planitia!", Color(0, 1, 0, 1));
}

void MainState::OnEnter()
{
}

void MainState::OnExit()
{

}

void MainState::Shutdown()
{
   
}

void MainState::Update()
{
   //  Before the game begins proper, we must set up the players.  We can't start
   //  running the main game loop until we do, which means that until
   //  SetupPlayers() must return true;
   if( !m_ArePlayersSetUp )
   {
      SetupGame();
      return;
   }
   
   //  NETWORKING
   
   //  Get events from server.
   //  Since we cannot write these functions in a blocking fashion, we call
   //  them over and over until the functions themselves tell us that they're
   //  done.
   
   bool canupdate = false;
   
   //Only update 30 times a second.
   if (g_Engine->Time() - m_LastUpdate > g_Engine->m_MSBetweenUpdates)
   {
      g_CurrentUpdate++;

      m_NumberOfVisibleUnits = 0;

      //  Update all units, this will result in more events on the stack.
      for (unordered_map<int, shared_ptr<U7Unit>>::iterator node = g_UnitList.begin(); node != g_UnitList.end(); ++node)
      {
         (*node).second->Update();
      }

      //  Kill units that are now dead because they updated.
      for (unordered_map<int, shared_ptr<U7Unit>>::iterator node = g_UnitList.begin(); node != g_UnitList.end();)
      {
         if((*node).second->GetIsDead())
            node = g_UnitList.erase(node);
         else
            ++node;
      }
      
      //  Do unit visibility.

      for(auto& unit : g_UnitList)
      {
          unit.second->m_Visible = true;
      }
      
      m_LastUpdate = g_Engine->Time();
   }

   DoCameraMovement();
   g_Terrain->Update();


   //  Updating the main GUI
   m_Gui->Update();

  
   m_SpellsPanel->Update();

   if( m_GuiMode != -1)
   {
      //  Flatten needs button down, everything else uses button press.
   }
   
   if( g_Input->WasRButtonClicked() )
   {
      m_GuiMode = -1;
      m_DrawMarker = false;
   }

   //  Updating the Options Gui
   m_OptionsGui->Update();
   stringstream temp;
//   temp << m_Resolutions[m_CurrentRes]->w << "x" << m_Resolutions[m_CurrentRes]->h; 
//   dynamic_cast<GuiTextArea*>(m_OptionsGui->GetElement(1001))->m_String = temp.str();

   //  Handle special keyboard keys
   if (g_Input->WasKeyPressed(KEY_ESCAPE))
   {

      g_Engine->m_Done = true;
   }

   if(g_Input->WasKeyPressed(KEY_SPACE))
   {
      //g_ResourceManager->ReloadTextures();
   }
   
   if (g_Input->WasKeyPressed(KEY_F1))
   {
/*      if( m_Resolutions[m_CurrentRes + 1] )
      {
         ++m_CurrentRes;
      }
      else
      {
         m_CurrentRes = 0;
      }
      
      g_Display->m_HRes = m_Resolutions[m_CurrentRes]->w;
      g_Display->GetHeight() = m_Resolutions[m_CurrentRes]->h;*/
      g_Display->SetIsFullscreen(!g_Display->GetIsFullscreen());
      
      g_Display->SetVideoMode(g_Display->GetWidth(), g_Display->GetHeight(), g_Display->GetIsFullscreen());
      g_ResourceManager->ReloadTextures();
   }
}



void MainState::Draw()
{
   g_Display->ClearScreen();

   //for (int k = xcoord; k < xcoord + 64; ++k)
   //{
   //    for (int l = ycoord; l < ycoord + 642; ++l)
   //    {
   //        //m_currentChunk = m_u7map[l][k];

   //        //for (int i = 0; i < 16; ++i)
   //        //{
   //        //    for (int j = 0; j < 16; ++j)
   //        //    {
   //                unsigned short data = g_World[k][l];
   //                unsigned short buffer = data << 8;
   //                unsigned char front = buffer >> 8;
   //                buffer = data >> 8;
   //                unsigned char h = buffer;
   //                unsigned short shapenum = front << 2;
   //                buffer = h << 6;
   //                buffer = buffer >> 6;
   //                shapenum = h;

   //                unsigned char framenum = front >> 2;

   //                g_Display->DrawImage(m_TerrainTexture, 8 * shapenum, 8 * framenum, 8, 8, (k - xcoord) * 16, (l - ycoord) * 16, 16, 16);
   //        //    }

   //        //}
	  // }
   //}






   g_Terrain->Draw();

//   g_Display->DrawMesh(g_Terrain->m_Highlight, glm::vec3(0, 0, 0));
   
   for(unordered_map<int, shared_ptr<U7Unit>>::iterator node = g_UnitList.begin(); node != g_UnitList.end(); ++node)
   {
      (*node).second->Draw();
   }
   
//   m_Particles.Draw();
   
   //int vpos = g_Display->GetHeight() - 160;
   //
   //stringstream converter;
   //converter << "X: " << g_Display->GetCameraLookAtPoint().x << " Z: " << g_Display->GetCameraLookAtPoint().z << " Angle: " << g_Display->GetCameraAngle();
   //g_SmallFont->DrawString(converter.str(), 0, vpos - 210);
   //
   //converter.str("");
   //
   //converter << "Number of cells drawn: " << g_Terrain->m_VisibleCells.size();//g_Terrain->m_CellsDrawnThisFrame;
   //g_SmallFont->DrawString(converter.str(), 0, vpos - 30);
   //
   //converter.str("");
   //
   //converter << "Terrain Hit: " << g_Terrain->m_HitX << ", " << g_Terrain->m_HitY <<  ", " << g_Terrain->GetHeight(g_Terrain->m_HitX, g_Terrain->m_HitY);
   //g_SmallFont->DrawString(converter.str(), 0, vpos - 60, Color(1, 0, 0, 1));

   //converter.str("");
   //
   //converter << "Number of units drawn: " << m_NumberOfVisibleUnits;
   //g_SmallFont->DrawString(converter.str(), 0, vpos - 90);
   //
   //converter.str("");
   //
   //converter << "Current update: " << g_CurrentUpdate;
   //g_SmallFont->DrawString(converter.str(), 0, vpos - 120);
   //
   //converter.str("");
   //
   //converter << "Duration of last visibility test: " << g_Terrain->m_DurationOfVisibleTest;
   //g_SmallFont->DrawString(converter.str(), 0, vpos - 150);
   //
   //converter.str("");
   //
   //if(g_CameraMoved)
   //   converter << "CAMERA MOVING";
   //g_SmallFont->DrawString(converter.str(), 0, vpos - 180);
   
   //if (m_DrawMarker)
   //{
   //   for (int i = 0; i < 36; ++i)
   //   {
   //      Color color = Color(float(i) / 40.0f, float((i + 12) % 40) / 40.0f, float((i + 23) % 40) / 40.0f, 1.0f);
   //      
   //      int offset = (g_Engine->Time() & 500) / 3;
   //      glm::vec3 sparklepos = glm::vec3(g_Terrain->m_FloatHitX, g_Terrain->GetHeight(g_Terrain->m_FloatHitX, g_Terrain->m_FloatHitY), g_Terrain->m_FloatHitY) + (GetRadialVector(200, (i * 5) + offset) * m_MarkerRadius);
   //      sparklepos.y = g_Terrain->GetHeight(sparklepos.x, sparklepos.z);

   //      g_Display->DrawMesh(g_AnimationFrames,
   //              0, 2, sparklepos,
   //              g_Sprites, color, glm::vec3(0, g_Display->GetCameraAngle() + 45, 0), glm::vec3(.5, .5, .5));
   //   }
   //}

   //m_Gui->Draw();
   //m_SpellsPanel->Draw();
   
   //m_OptionsGui->Draw();
   int ypos = -32;
   string welcome = "Welcome to Ultima VII: Revisited!";
   g_SmallFont->DrawString(welcome, 0, ypos += 32);

   welcome = "You can scroll anywhere on the map using WASD and rotate the map using Q and E.";
   g_SmallFont->DrawString(welcome, 0, ypos += 32);

   welcome = "Press ESC to exit.";
   g_SmallFont->DrawString(welcome, 0, ypos += 32);

   welcome = "";
   g_SmallFont->DrawString(welcome, 0, ypos += 32);

   string visibleCells = "Visible Cells: " + to_string(g_Terrain->m_VisibleCells.size());

   g_SmallFont->DrawString(visibleCells, 0, ypos += 32);

   string xcoordstring = "CamLookAt  X: " + to_string(g_Display->GetCameraLookAtPoint().x) + " Y: " + to_string(g_Display->GetCameraLookAtPoint().y) + " Z: " + to_string(g_Display->GetCameraLookAtPoint().z);
   g_SmallFont->DrawString(xcoordstring, 0, ypos += 32);

   xcoordstring = "CamPos      X: " + to_string(g_Display->GetCameraPosition().x) + " Y: " + to_string(g_Display->GetCameraPosition().y) + " Z: " + to_string(g_Display->GetCameraPosition().z);
   g_SmallFont->DrawString(xcoordstring, 0, ypos += 32);

   DrawConsole();
   

   g_Display->DrawPerfCounter(g_SmallFont);


   
   g_Display->DrawImage(g_Cursor, g_Input->m_MouseX, g_Input->m_MouseY);

}

void MainState::SetupGame()
{
    g_UnitList.clear();
    g_World.resize(3072);
    for (int i = 0; i < 3072; ++i)
    {
        g_World[i].resize(3072);
    }

    LoadChunks();
    LoadMap();

    LoadIFIX();


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
                    g_World[j * 16 + k][i * 16 + l] = m_Chunkmap[chunkid][l][k];
                }
            }
        }
    }

    m_TerrainTexture = g_ResourceManager->GetTexture("Images/Terrain/terrain_texture.png", false);



   //  Set up map
   int width = 3072;
   int height = 3072;
   //g_Display->SetCameraPosition(glm::vec3(216, 0, 195));
   g_Display->SetCameraPosition(glm::vec3(1068, 0, 2211));
   g_Terrain->Init(width, height);
   g_Terrain->InitializeMap(7777);   //  Check for a packet that tells us how to set up the game.

   //  Set the terrain types for each cell.
   g_Terrain->InitializeTerrainMesh();
   
   //  Since the terrain cannot be initialized until the game data has been sent
   //  but the main gui has already been created, we have to do a hacky bit of
   //  fixup to assign the minimap texture to the main gui.
   m_Gui->AddSprite(1001, 5, 5, make_shared<Sprite>(g_Terrain->m_Minimap, 0, 0, g_Terrain->m_Minimap->GetWidth(), g_Terrain->m_Minimap->GetHeight()));
   
   //for(int i = 0; i < 3; ++i)
   //{
   //   AddUnitActual(0, UNIT_WALKER, GetNextID(), 16, g_Terrain->GetHeight(16, 16), 16);
   //}
   //
   //for(int i = 0; i < 3; ++i)
   //{
   //   AddUnitActual(1, UNIT_WALKER, GetNextID(), 48, g_Terrain->GetHeight(48, 48), 48);
   //}

   m_ArePlayersSetUp = true;
   
   //for( int j = 15; j < 18; ++j )
   //{
   //   g_Terrain->SetTerrainType(j, 15, TT_FARMLAND);
   //   g_Terrain->SetTerrainType(j, 16, TT_FARMLAND);
   //   g_Terrain->SetTerrainType(j, 17, TT_FARMLAND);
   //   
   //   g_Terrain->SetTerrainType(j + 32, 47, TT_FARMLAND);
   //   g_Terrain->SetTerrainType(j + 32, 48, TT_FARMLAND);
   //   g_Terrain->SetTerrainType(j + 32, 49, TT_FARMLAND);
   //}
   //
   //
   //for( int j = 16; j < 17; ++j )
   //{
   //   g_Terrain->SetTerrainType(j, 16, TT_COBBLESTONE);
   //   //g_Terrain->SetTerrainType(j, 17, TT_COBBLESTONE);
   //   
   //   g_Terrain->SetTerrainType(j + 32, 48, TT_COBBLESTONE);
   //   //g_Terrain->SetTerrainType(j + 32, 49, TT_COBBLESTONE);
   //}
   
   

//   g_Terrain->UpdateMinimapTerrain();
   
   
   //  Otherwise, return.

   //  Create the world map and load its data from U7MAP and U7CHUNKS

}

void MainState::LoadChunks()
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
                thisvector.push_back(thisdata);
            }
            m_Chunkmap[i].push_back(thisvector);
        }
    }
    fclose(u7chunksfile);
}

void MainState::LoadMap()
{
    FILE* u7mapfile = fopen("Data/U7/STATIC/U7MAP", "rb");
    //  Untangle the map and chunk files into a single array.
    //  Create the map of chunk ids and chunk data
    for (int k = 0; k < 12; ++k)
    {
        for (int l = 0; l < 12; ++l)
        {
            for (int j = 0; j < 16; ++j)
            {
                for (int i = 0; i < 16; ++i)
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

void MainState::LoadShapes()
{
    //  Eventually we need to load the shapes from the U7SHAPES file instead of using pre-generated PNGs.
    //  For now, we'll just load the PNGs.


}

void MainState::LoadIFIX()
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

            //  This is followed two unsigned ints.  The first unsigned int is alwasy the same, so we can ignore it.
            //  The second is the number of entries in the file.
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
                            unsigned short shapeData = locationdata[w];
                            unsigned short thisLocationData = locationdata[w + 1];

                            int shape = shapeData & 0x3ff;
                            int frame = (shapeData >> 10) & 0x1f;

                            int y = thisLocationData & 0xf;
                            int x = (thisLocationData >> 4) & 0xf;
                            int z = (thisLocationData >> 8) & 0xf;

                            AddUnitActual(0, UNIT_WALKER, GetNextID(), (superchunkx * 256) + (chunkx * 16) + x, z, (superchunky * 256) + (chunky * 16) + y);

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


//void Game_map::get_ifix_objects(
//    int schunk          // Superchunk # (0-143).
//) {
//    char fname[128];        // Set up name.
//    if (!is_system_path_defined("<PATCH>") ||
//        // First check for patch.
//        !U7exists(get_schunk_file_name(PATCH_U7IFIX, schunk, fname))) {
//        get_schunk_file_name(U7IFIX, schunk, fname);
//    }
//    IFileDataSource ifix(fname);
//    if (!ifix.good()) {
//        if (!Game::is_editing())    // Ok if map-editing.
//            cerr << "Ifix file '" << fname << "' not found." << endl;
//        return;
//    }
//    FlexFile flex(fname);
//    int vers = static_cast<int>(flex.get_vers());
//    int scy = 16 * (schunk / 12); // Get abs. chunk coords.
//    int scx = 16 * (schunk % 12);
//    // Go through chunks.
//    for (int cy = 0; cy < 16; cy++) {
//        for (int cx = 0; cx < 16; cx++) {
//            // Get to index entry for chunk.
//            int chunk_num = cy * 16 + cx;
//            size_t len;
//            uint32 offset = flex.get_entry_info(chunk_num, len);
//            if (len)
//                get_ifix_chunk_objects(&ifix, vers, offset,
//                    len, scx + cx, scy + cy);
//        }
//    }
//}


void MainState::LoadIREG()
{

}
