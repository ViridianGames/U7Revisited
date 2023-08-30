#include "U7Globals.h"
#include "U7Unit.h"
#include <algorithm>
#include <fstream>
#include <sstream>
#include <iterator>
#include <utility>

using namespace std;

unordered_map<int, std::shared_ptr<U7Unit> > g_UnitList;

Mesh* g_AnimationFrames;

Texture* g_WalkerTexture;
Texture* g_WalkerMask;
Texture* g_Cursor;
Texture* g_Sprites;

std::shared_ptr<Font> g_Font;
std::shared_ptr<Font> g_SmallFont;

std::unique_ptr<RNG> g_VitalRNG;
std::unique_ptr<RNG> g_NonVitalRNG;

std::unique_ptr<Terrain> g_Terrain;

Mesh* g_TestMesh;

bool g_IsSinglePlayer;  //  not single payer
bool g_IsServer;

bool g_CameraMoved;

unsigned int g_CurrentUpdate;

string GameEventStrings[LASTGAMEEVENT + 1] = 
{
   //  Camera Events
   "Add Player",
   "Set Game Type",
   "Server: Sent Eventss",
   "Client: Acknowledge Events",
   "Server: Advance Turn",
   "Chat",
   "Pause",

   "Add Unit",
   "Do God Power",
   "Set Unit Target",
   "Set Unit Physics Force",
   "Bounce Unit",
   "Turn Unit",
   "Link Unit To Master"
   "Damage Unit",
   "Heal Unit",

   "User Input On",
   "User Input Off",

   "LastGameString"
};

string UnitTypeStrings[UNIT_LASTUNITTYPE + 1] = 
{
   "Unit", //  Default unit type; no specialized behavior.
   "Archer",
   "Arrow",
   "Barbarian",
   "General",
   "Village",
   "Walker",
   "Warrior",
   "Bird",
   "Rock",
   "Sheep",
   "Tree",
   "Earthquake",
   "Flamestrike",
   "Flamering",
   "HealingLight",
   "Knight",
   "Lightning",
   "Meteor",
   "Tornado",
   "Volcano",

   "LastUnitType"
};

list<GameEvent> g_EventStack;
list<GameEvent> g_ProcessedStack;
list<GameEvent> g_ReplayStack;

list<GameEvent> g_ClientTurnStack;
list<GameEvent> g_ServerTurnStack;

std::vector< std::vector<unsigned short> > g_World;

const float g_ManaCosts[18] =
{
   .1f, // Flatten
   .1f, // Raise
   .1f, // Lower
   5,  // Earthquake
   25, // Golem
   5,  // StoneRain
   25, // Flamestrike
   75, // Volcano
   5,  // Lightning
   25, // Lightning Storm
   75, // Meteor
   5,  // Bless
   75,  // Swamp
   25, // Healing Rain
   100, // Armageddon
   0,   // Create Archer
   0,   // Create Barbarian
   0   // Create Warrior
};

glm::vec3 g_Gravity = glm::vec3(0, .1f, 0);

//  Slow.  Use only when you actually need to know the distance.
float GetDistance(float startX, float startZ, float endX, float endZ)
{
   float dx = startX - endX;
   float dz = startZ - endZ;
   return sqrt( (dx * dx) + (dz * dz) );
}

//  Use when you just need to know if the distance is less than a certain range
//  (which is 90% of the time).  Much faster because it does not require a square root call.
//  Yes, technically it's "Is less than or equals to".
bool IsDistanceLessThan(float startX, float startZ, float endX, float endZ, float range)
{
   float dx = startX - endX;
   float dz = startZ - endZ;
   return ( (dx * dx) + (dz * dz) ) <= (range * range);
}

float Lerp(float a, float b, float t)
{
   return a - (a*t) + (b*t);
}

//  This makes an animation 
void MakeAnimationFrameMeshes()
{
   g_AnimationFrames = new Mesh();
   vector<Vertex> vertices;
   vector<unsigned int> indices;
   for( int i = 0; i < 8; ++i)
   {
      for( int j = 0; j < 8; ++j )
      {
         vertices.push_back(CreateVertex(-.5, 0, 0, 1, 1, 1, 1, (i + 1) * 0.1250, (j + 1) * 0.1250 ));
         vertices.push_back(CreateVertex( .5, 0, 0, 1, 1, 1, 1,       i * 0.1250, (j + 1) * 0.1250 ));
         vertices.push_back(CreateVertex(-.5, 1, 0, 1, 1, 1, 1, (i + 1) * 0.1250,       j * 0.1250 ));
         vertices.push_back(CreateVertex( .5, 1, 0, 1, 1, 1, 1,       i * 0.1250,       j * 0.1250 ));
      }
   }

   for(int i = 0; i < 256; )
   {
         indices.push_back(i);
         indices.push_back(i + 1);
         indices.push_back(i + 2);
         indices.push_back(i + 3);
         indices.push_back(i + 2);
         indices.push_back(i + 1);

         i += 4;
   }

   g_AnimationFrames->Init(vertices, indices);
}

void DoCameraMovement()
{
   g_CameraMoved = false;

   if (g_Input->WasAnyKeyPressed())
   {
	   int stopper = 0;
   }
      if( g_Input->IsKeyDown(KEY_q))
   {
      g_Display->SetCameraAngle(g_Display->GetCameraAngle() + g_Engine->LastUpdateInMS() / 2);
      g_CameraMoved = true;
   }
   
   if( g_Input->IsKeyDown(KEY_e))
   {
      g_Display->SetCameraAngle(g_Display->GetCameraAngle() - g_Engine->LastUpdateInMS() / 2);
      g_CameraMoved = true;
   }
   
   if( g_Input->IsKeyDown(KEY_a))
   {
      glm::vec3 current = g_Display->GetCameraLookAtPoint();
      glm::vec3 direction = glm::vec3(-1, 0, 1);
      
      direction = direction * ((float)g_Engine->LastUpdateInMS() / 100.0f);
      
      glm::vec4 final = g_Display->GetCameraRotationMatrix() * glm::vec4(direction, 1);
      
      current = current + glm::vec3(final);
      
      if( current.x < 0 ) current.x = 0;
      if( current.x > g_Terrain->m_CellWidth ) current.x = g_Terrain->m_CellWidth;
      if( current.z < 0 ) current.z = 0;
      if( current.z > g_Terrain->m_CellHeight ) current.z = g_Terrain->m_CellHeight;
      
      g_Display->SetCameraPosition(current);
      g_CameraMoved = true;
   }
   
   if( g_Input->IsKeyDown(KEY_d))
   {
      glm::vec3 current = g_Display->GetCameraLookAtPoint();
      glm::vec3 direction = glm::vec3(1, 0, -1);
      
      direction = direction * ((float)g_Engine->LastUpdateInMS() / 100.0f);
      
      glm::vec4 final = g_Display->GetCameraRotationMatrix() * glm::vec4(direction, 1);
      
      current = current + glm::vec3(final);
      
      if( current.x < 0 ) current.x = 0;
      if( current.x > g_Terrain->m_CellWidth ) current.x = g_Terrain->m_CellWidth;
      if( current.z < 0 ) current.z = 0;
      if( current.z > g_Terrain->m_CellHeight ) current.z = g_Terrain->m_CellHeight;
      
      g_Display->SetCameraPosition(current);
      
      g_CameraMoved = true;
   }
   
   if( g_Input->IsKeyDown(KEY_w))
   {
      glm::vec3 current = g_Display->GetCameraLookAtPoint();
      glm::vec3 direction = glm::vec3(-1, 0, -1);
      
      direction = direction * ((float)g_Engine->LastUpdateInMS() / 100.0f);
      
      glm::vec4 final = g_Display->GetCameraRotationMatrix() * glm::vec4(direction, 1);
      
      current = current + glm::vec3(final);
      
      if( current.x < 0 ) current.x = 0;
      if( current.x > g_Terrain->m_CellWidth ) current.x = g_Terrain->m_CellWidth;
      if( current.z < 0 ) current.z = 0;
      if( current.z > g_Terrain->m_CellHeight ) current.z = g_Terrain->m_CellHeight;
      
      g_Display->SetCameraPosition(current);
      g_CameraMoved = true;
   }
   
   if( g_Input->IsKeyDown(KEY_s))
   {
      glm::vec3 current = g_Display->GetCameraLookAtPoint();
      glm::vec3 direction = glm::vec3(1, 0, 1);
      
      direction = direction * ((float)g_Engine->LastUpdateInMS() / 100.0f);
      
      glm::vec4 final = g_Display->GetCameraRotationMatrix() * glm::vec4(direction, 1);
      
      current = current + glm::vec3(final);
      
      if( current.x < 0 ) current.x = 0;
      if( current.x > g_Terrain->m_CellWidth ) current.x = g_Terrain->m_CellWidth;
      if( current.z < 0 ) current.z = 0;
      if( current.z > g_Terrain->m_CellHeight ) current.z = g_Terrain->m_CellHeight;
      
      g_Display->SetCameraPosition(current);
      
      g_CameraMoved = true;
   }
   
   if( g_Input->MouseWheelUp() )
   {
      g_Display->SetCameraDistance(g_Display->GetCameraDistance() + .3);
      g_Display->SetHasCameraChanged(true);
      g_Display->UpdateCamera();
      g_CameraMoved = true;
   }
   
   if( g_Input->MouseWheelDown() )
   {
      g_Display->SetCameraDistance(g_Display->GetCameraDistance() - .3);
      g_Display->SetHasCameraChanged(true);
      g_Display->UpdateCamera();
      g_CameraMoved = true;
   }

}

shared_ptr<U7Unit> GetPointerFromID(int unitID)
{
   unordered_map<int, shared_ptr<U7Unit> >::iterator finder = g_UnitList.find(unitID);

   if( finder == g_UnitList.end() )
      return nullptr;
   else
      return (*finder).second;
}

shared_ptr<U7Unit> U7UnitClassFactory(int type)
{
   switch (type)
   {
      case UNIT_WALKER:
      {
         shared_ptr<U7Unit> temp = make_shared<U7Unit>();
         temp->m_UnitType = UNIT_WALKER;
         return temp;
      }
      break;

      default:
         throw("Bad identifier in unit factory!");
         break;
   }
}

vector<shared_ptr<U7Unit> > GetAllUnitsWithinRange(float x, float y, int range)
{
   vector<shared_ptr<U7Unit> > _Targets;
   for(auto& unit : g_UnitList)
   {
      if(IsDistanceLessThan(x, y, unit.second->m_Pos.x, unit.second->m_Pos.z, range))
      {
         _Targets.emplace_back(unit.second);
      }
   }
   
   return _Targets;
}

glm::vec3 GetRadialVector(float partitions, float thispartition)
{
	float finalpartition = ((PI * 2) / partitions) * thispartition;

	return glm::vec3(cos(finalpartition), 0, sin(finalpartition));
}

unsigned int g_CurrentUnitID = 0;

unsigned int GetNextID(){ return g_CurrentUnitID++; }

//  This function creates a game event to add the unit and puts it on the event
//  stack.

//  Sends the event through the networking system
void SendEvent(GameEvent event)
{
   //g_ClientTurnStack.push_back(event);
   g_EventStack.push_back(event);
}

void ClearEvent(GameEvent& event)
{
   memset(&event, 0, sizeof(GameEvent));
}

//  Sends a unit creation event through the networking code
void SendUnit(int player, int unittype, int id, float x, float y, float z)
{
   GameEvent temp;
   ClearEvent(temp);
   temp.m_Event = GE_ADDUNIT;
   temp.m_Type = unittype;
   temp.m_Team = player;
   temp.m_PosX = x;
   temp.m_PosY = y;
   temp.m_PosZ = z;
   temp.m_UpdateIndex = g_CurrentUpdate + 1;
   temp.m_Handled = false;
   
   SendEvent(temp);
}

void AddUnit(int player, int unittype, int id, float x, float y, float z)
{
   GameEvent temp;
   ClearEvent(temp);
   temp.m_Event = GE_ADDUNIT;
   temp.m_Type = unittype;
   temp.m_Team = player;
   temp.m_PosX = x;
   temp.m_PosY = y;
   temp.m_PosZ = z;
   temp.m_UpdateIndex = g_CurrentUpdate;
   temp.m_Handled = false;
   
   g_EventStack.push_back(temp);
}


//  Puts a god power activation event on the local event stack

//  Puts a unit creation event on the local event stack

//  This function actually creates a unit.  It should ONLY be called by the event stack.
void AddUnitActual(int player, int unittype, int id, float x, float y, float z )
{
   shared_ptr<U7Unit> temp = U7UnitClassFactory(unittype);
   temp->Init("Data/Units/Walker.cfg");
   temp->SetInitialPos(glm::vec3(x, y, z));
   temp->m_BaseTeam = player;
   temp->m_Team = player;
   g_UnitList[id] = temp;
}


//////////////////////////////////////////////////////////////////////////////
//  CONSOLE
//////////////////////////////////////////////////////////////////////////////

std::vector<ConsoleString> g_ConsoleStrings;

void AddConsoleString(std::string string, Color color, unsigned int starttime)
{
   ConsoleString temp;
   temp.m_String = string;
   temp.m_Color = color;
   temp.m_StartTime = starttime;
   
   g_ConsoleStrings.push_back(temp);
}

void AddConsoleString(std::string string, Color color)
{
   ConsoleString temp;
   temp.m_String = string;
   temp.m_Color = color;
   temp.m_StartTime = g_Engine->Time();
   
   g_ConsoleStrings.push_back(temp);
}

void DrawConsole()
{
   int counter = 0;
   vector<ConsoleString>::iterator node = g_ConsoleStrings.begin();
   for( node; node != g_ConsoleStrings.end(); ++node)
   {
      unsigned int elapsed = g_Engine->Time() - (*node).m_StartTime;
      if(elapsed > 9000)
         (*node).m_Color.a = float( 10000 - elapsed) / 1000.0f;
      g_SmallFont->DrawString((*node).m_String, 1, counter * (g_SmallFont->GetHeight() + 2) + 1, Color(0, 0, 0, (*node).m_Color.a));
      g_SmallFont->DrawString((*node).m_String, 0, counter * (g_SmallFont->GetHeight() + 2), (*node).m_Color);
      ++counter;
   }
   
   node = g_ConsoleStrings.begin();
   for(node; node != g_ConsoleStrings.end();)
   {
      if( g_Engine->Time() - (*node).m_StartTime > 10000)
      {
         node = g_ConsoleStrings.erase(node);
      }
      else
      {
         ++node;
      }
   }
}

void SaveReplay()
{
   stringstream filename;
   filename << g_NonVitalRNG->Random(256);
   filename << "replay.txt"; 
   ofstream outstream;
   
   outstream.open(filename.str().c_str());
   
   //  Header for game
   if( g_IsSinglePlayer)
   {
      outstream << "Single Player Game." << endl;
   }
   else if( g_IsServer )
   {
      outstream << "Multiplayer Game Server." << endl;
   }
   else
   {
      outstream << "Multiplayer Game Client." << endl;
   }
   
   
   
   outstream << " Random Seed: " << g_VitalRNG->GetOriginalSeed() << endl;
   
   list<GameEvent>::iterator node = g_ReplayStack.begin();
   for (node; node != g_ReplayStack.end(); ++node)
   {
      if((*node).m_Event == GE_ADDUNIT )
      {
         outstream << 
         "Update: " <<   (*node).m_UpdateIndex << "  " <<
         "Team: " << (*node).m_Team << "  " <<
         "Event: "  <<    GameEventStrings[(*node).m_Event] << "  " <<
         "Unit Type: " << UnitTypeStrings[(*node).m_Type] << "  " <<
         "Unit Location: " << (*node).m_PosX << ", " << (*node).m_PosY << ", " << (*node).m_PosZ << "  " <<
         "Unit ID: " << (*node).m_UnitID << "  " <<
         "Integer Flags: " <<  (*node).m_Int1 << "  " << (*node).m_Int2 << "  " << (*node).m_Int3 << "  " <<	(*node).m_Int4 << "  " <<
         "Float Flags: " << (*node).m_Float1 << "  " <<	(*node).m_Float2 << "  " <<	(*node).m_Float3 << "  " <<	(*node).m_Float4 << "  " << endl;
      }
      else
      {
         outstream << 
         "Update: " <<   (*node).m_UpdateIndex << "  " <<
         "Event: "  <<    GameEventStrings[(*node).m_Event] << "  " <<
         "Unit: " << (*node).m_UnitID << "  " <<
         "Team: " << (*node).m_Team << "  " <<
         "Unit Type: " << UnitTypeStrings[(*node).m_Type] << "  " <<
         "Unit Location: " << (*node).m_PosX << ", " << (*node).m_PosY << ", " << (*node).m_PosZ << "  " <<
         "Integer Flags: " <<  (*node).m_Int1 << "  " << (*node).m_Int2 << "  " << (*node).m_Int3 << "  " <<	(*node).m_Int4 << "  " <<
         "Float Flags: " << (*node).m_Float1 << "  " <<	(*node).m_Float2 << "  " <<	(*node).m_Float3 << "  " <<	(*node).m_Float4 << "  " << endl;
      }
   }
}

float g_DrawScale;