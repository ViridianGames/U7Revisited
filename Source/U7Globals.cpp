#include "U7Globals.h"
#include "U7SpriteEffects.h"
#include "U7Object.h"
#include "Geist/Engine.h"
#include "Geist/Logging.h"
#include "Geist/ResourceManager.h"
#include "Geist/ScriptingSystem.h"
#include "ConversationState.h"
#include "PathfindingSystem.h"
#include "lua.hpp"
#include "../ThirdParty/raylib/include/rlgl.h"
#include "../ThirdParty/nlohmann/json.hpp"
#include <algorithm>
#include <fstream>
#include <sstream>
#include <iterator>
#include <utility>
#include <iomanip>
#include <iostream>
#include <cassert>
#include <mutex>
#include <vector>
#include <memory>
#include <unordered_map>
#include <cmath>
#include <cstring>

#include "InputSystem.h"
#include "raylib.h"
#include "rlgl.h"
#include "glad.h"
#include <cstdio>
using namespace std;

std::string BuildU7SfxPath(int soundId)
{
	string bank = "mt32";
	if (g_Engine)
	{
		const string configured = g_Engine->m_EngineConfig.GetString("sfx_bank");
		if (!configured.empty())
		{
			bank = configured;
		}
	}

	char path[128];
	snprintf(path, sizeof(path), "Audio/SFX/%s/U7BG_SFX_%s_%03d.wav", bank.c_str(), bank.c_str(), soundId);
	return path;
}

std::string BuildU7VoicePath(int voiceId)
{
	char path[128];
	snprintf(path, sizeof(path), "Audio/Voice/U7BG_voice_%03d.wav", voiceId);
	return path;
}

std::string BuildU7MusicPath(int trackId)
{
	char path[128];
	snprintf(path, sizeof(path), "Audio/Music/%02dbg.ogg", trackId);
	return path;
}

std::string g_version;

std::unordered_map<int, std::unique_ptr<U7Object>> g_objectList;

extern Texture* g_Cursor; // Defined in StateMachine.cpp
Texture* g_objectSelectCursor;
Texture* g_EmptyTexture;
Texture* g_Minimap;

std::shared_ptr<Font> g_Font;
std::shared_ptr<Font> g_SmallFont;
std::shared_ptr<Font> g_ConversationFont;
std::shared_ptr<Font> g_ConversationSmallFont;
std::shared_ptr<Font> g_guiFont;
std::shared_mutex g_chunkMapMutex;

//float g_smallFontSize = 8;
float g_fontSize = 16;
float g_guiFontSize = 8;

std::unique_ptr<RNG> g_VitalRNG;
std::unique_ptr<RNG> g_NonVitalRNG;

std::unique_ptr<Terrain> g_Terrain;

std::array<std::array<ShapeData, 32>, 1024> g_shapeTable;
std::array<ObjectData, 1024> g_objectDataTable;


// Weather/effect sprite data
std::array<std::vector<SpriteFrame>, 32> g_spriteTable;
std::unique_ptr<U7SpriteEffectSystem> g_SpriteEffectSystem = std::make_unique<U7SpriteEffectSystem>();

// Misc names from TEXT.FLX for frame-specific item names
std::vector<std::string> g_miscNames;

std::unordered_map<int, unique_ptr<NPCData>> g_NPCData;
std::vector<MonsterData> g_monsterData;   // Loaded from STATIC/MONSTERS.DAT (65 entries, 25 bytes each) - see wiki for format

// Spell system data
std::vector<ReagentData> g_reagentData;
std::vector<SpellCircle> g_spellCircles;
std::unordered_map<int, SpellData*> g_spellMap;

std::unique_ptr<PathfindingSystem> g_pathfindingSystem;

ConversationState* g_ConversationState;
CombatState* g_CombatState;
MainState* g_mainState;

bool g_CameraMoved;

unsigned int g_CurrentUpdate;

unsigned int g_minimapSize;

std::vector< std::vector<unsigned short> > g_World;

Vector3 g_Gravity = Vector3{ 0, .1f, 0 };
// Default first-person settings
constexpr float DEFAULT_FIRSTPERSON_HEIGHT = 5.5f;
constexpr float DEFAULT_FIRSTPERSON_PITCH = 0.0f;

float g_CameraRotateSpeed = 0;

Vector3 g_CameraMovementSpeed = Vector3{ 0, 0, 0 };

std::string g_gameStateStrings[] = { "LoadingState", "TitleState", "MainState", "OptionsState", "ObjectEditorState", "WorldEditorState" };

std::string g_objectDrawTypeStrings[] = { "Billboard", "Cuboid", "Flat", "Custom Mesh" };

std::string g_objectTypeStrings[] = { "Static", "Creature", "Weapon", "Armor", "Container", "Quest Item", "Key", "Item" };

int g_selectedShape = 150;
int g_selectedFrame = 0;

std::unordered_map<int, int[16][16]> g_ChunkTypeList;  // The 16x16 tiles for each chunk type
int g_chunkTypeMap[192][192]; // The type of each chunk in the map

std::vector<U7Object*> g_chunkObjectMap[192][192]; // The objects in each chunk

std::vector<U7Object*> g_sortedVisibleObjects;

// Interest spheres (see U7Globals.h)
float g_interestRadiusTiles = 96.0f; // ~6 chunks; multiplayer: per-player sphere size
int g_interestCenterCount = 0;
int g_interestChunkCount = 0;
int g_interestObjectsUpdated = 0;
std::vector<int> g_interestChunkList;

namespace
{
	std::vector<Vector3> g_interestCenters;
	// Generation stamp so overlapping spheres don't double-process chunks.
	uint32_t g_interestChunkStamp[192][192] = {};
	uint32_t g_interestGeneration = 1;
}

void ClearInterestCenters()
{
	g_interestCenters.clear();
	g_interestCenterCount = 0;
}

void AddInterestCenter(Vector3 worldPos)
{
	g_interestCenters.push_back(worldPos);
	g_interestCenterCount = static_cast<int>(g_interestCenters.size());
}

void RebuildInterestCentersFromLocalPlayers()
{
	ClearInterestCenters();

	if (g_Player)
	{
		if (U7Object* avatar = g_Player->GetAvatarObject())
		{
			AddInterestCenter(avatar->GetPos());
		}
		// Party members each get a sphere (multiplayer-ready: remote players use AddInterestCenter).
		for (int npcId : g_Player->GetPartyMemberIds())
		{
			if (npcId == 0)
			{
				continue; // avatar already added
			}
			auto npcIt = g_NPCData.find(npcId);
			if (npcIt == g_NPCData.end() || !npcIt->second)
			{
				continue;
			}
			U7Object* member = GetObjectFromID(npcIt->second->m_objectID);
			if (member)
			{
				AddInterestCenter(member->GetPos());
			}
		}
	}

	// Freecam / follow-cam: always sim what the local view is pointed at.
	AddInterestCenter(g_camera.target);
}

void RebuildInterestChunkSet()
{
	++g_interestGeneration;
	if (g_interestGeneration == 0)
	{
		// Wrap: clear stamps (rare).
		std::memset(g_interestChunkStamp, 0, sizeof(g_interestChunkStamp));
		g_interestGeneration = 1;
	}

	g_interestChunkCount = 0;
	g_interestChunkList.clear();
	g_interestChunkList.reserve(256);
	const float radius = std::max(16.0f, g_interestRadiusTiles);
	const int radiusChunks = static_cast<int>(std::ceil(radius / 16.0f)) + 1;

	auto stampChunk = [](int cx, int cz) {
		if (cx < 0 || cx >= 192 || cz < 0 || cz >= 192)
		{
			return;
		}
		if (g_interestChunkStamp[cx][cz] != g_interestGeneration)
		{
			g_interestChunkStamp[cx][cz] = g_interestGeneration;
			++g_interestChunkCount;
			g_interestChunkList.push_back(cx | (cz << 16));
		}
	};

	for (const Vector3& c : g_interestCenters)
	{
		const int ccx = static_cast<int>(std::floor(c.x / 16.0f));
		const int ccz = static_cast<int>(std::floor(c.z / 16.0f));
		for (int dz = -radiusChunks; dz <= radiusChunks; ++dz)
		{
			for (int dx = -radiusChunks; dx <= radiusChunks; ++dx)
			{
				// Circle test in chunk space (approx).
				if (dx * dx + dz * dz > radiusChunks * radiusChunks)
				{
					continue;
				}
				stampChunk(ccx + dx, ccz + dz);
			}
		}
	}

	// Union camera frustum so zoomed-out views still tick everything on screen.
	int minCX = 0, maxCX = 0, minCZ = 0, maxCZ = 0;
	GetCameraVisibleChunkRange(minCX, maxCX, minCZ, maxCZ);
	for (int cz = minCZ; cz <= maxCZ; ++cz)
	{
		for (int cx = minCX; cx <= maxCX; ++cx)
		{
			stampChunk(cx, cz);
		}
	}
}

bool IsChunkInInterest(int chunkX, int chunkZ)
{
	if (chunkX < 0 || chunkX >= 192 || chunkZ < 0 || chunkZ >= 192)
	{
		return false;
	}
	return g_interestChunkStamp[chunkX][chunkZ] == g_interestGeneration;
}

void ApplyObjectDrawVisibility(U7Object* object, float heightCutoff)
{
	if (!object)
	{
		return;
	}

	if (object->m_Pos.y > heightCutoff)
	{
		object->m_Visible = false;
		return;
	}

	if (!object->GetIsDead())
	{
		object->m_Visible = true;
	}
	if (object->m_drawType == ShapeDrawType::OBJECT_DRAW_DONT_DRAW)
	{
		object->m_Visible = false;
	}

	// Dungeon: hide mountain tops and exterior (Exult skip_lift + blackness).
	if (g_dungeonViewActive && object->m_Visible && g_pathfindingSystem)
	{
		if (PathfindingSystem::IsMountainTopShape(object->m_ObjectType))
		{
			object->m_Visible = false;
		}
		else
		{
			const int ox = static_cast<int>(std::floor(object->m_Pos.x));
			const int oz = static_cast<int>(std::floor(object->m_Pos.z));
			if (!g_pathfindingSystem->IsDungeonTile(ox, oz))
			{
				object->m_Visible = false;
			}
		}
	}
}

float g_cameraDistance; // distance from target
float g_cameraRotation = 0; // angle around target
float g_cameraRotationTarget = 0;
Vector3 g_cameraDestination = g_camera.target;
float g_cameraSpeed = 25.0f;
bool g_shouldCameraMoveToDestination = false;

Shader g_alphaDiscard;
Shader g_cuboidShader;
int g_cuboidTexCoordsLoc;

Shader g_meshIdShader{};
Shader g_meshOutlineShader{};
int g_meshOutlineIdSamplerLoc = -1;
int g_meshOutlineResolutionLoc = -1;
int g_meshOutlineThicknessLoc = -1;
float g_meshOutlineThickness = 0.75f;
RenderTexture2D g_meshIdTarget{};
bool g_meshOutlineSystemReady = false;

std::array<Color, 256> g_basePalette{};
std::array<Color, 256> g_runtimePalette{};
Texture2D g_paletteTexture{};
Shader g_paletteShader{};
int g_paletteSamplerLoc = -1;
bool g_paletteSystemReady = false;

namespace
{
	void RotatePaletteBand(int start, int count, int step)
	{
		if (count <= 0)
		{
			return;
		}
		step %= count;
		if (step < 0)
		{
			step += count;
		}
		// Pixel at offset k shows color from (k - step) mod count (U7 band rotation)
		for (int i = 0; i < count; ++i)
		{
			int src = start + ((i - step) % count + count) % count;
			g_runtimePalette[start + i] = g_basePalette[src];
		}
	}

	// Baked RGBA for translucent (TFA) shapes only — not used in the runtime LUT.
	const Color kU7XformBakeColors[11] = {
		Color{ 144, 40, 192, 128 }, // 244
		Color{ 96, 40, 16, 128 },   // 245
		Color{ 100, 108, 116, 192 },// 246
		Color{ 68, 132, 28, 128 },  // 247
		Color{ 255, 208, 48, 64 },  // 248
		Color{ 28, 52, 255, 128 },  // 249
		Color{ 8, 68, 0, 128 },     // 250
		Color{ 255, 8, 8, 118 },    // 251
		Color{ 255, 244, 248, 128 },// 252
		Color{ 56, 40, 32, 128 },   // 253
		Color{ 228, 224, 214, 82 }, // 254
	};
}

Color GetU7XformBakeColor(int paletteIndex)
{
	if (paletteIndex < kU7PaletteXformMin || paletteIndex > kU7PaletteXformMaxInclusive)
	{
		return Color{ 0, 0, 0, 0 };
	}
	return kU7XformBakeColors[paletteIndex - kU7PaletteXformMin];
}

Color GetU7ShapePixelColor(const std::array<Color, 256>& palette, int paletteIndex, bool shapeIsTranslucent)
{
	if (paletteIndex < 0 || paletteIndex > 255)
	{
		return Color{ 0, 0, 0, 0 };
	}
	if (paletteIndex == 255)
	{
		return Color{ 0, 0, 0, 0 };
	}
	// Translucent shapes use fixed xform bake colors for 244-254 (blood/glass).
	// Opaque shapes (gems, etc.) keep original palette RGB so glisten looks correct.
	if (shapeIsTranslucent && paletteIndex >= kU7PaletteXformMin && paletteIndex <= kU7PaletteXformMaxInclusive)
	{
		return GetU7XformBakeColor(paletteIndex);
	}
	return palette[paletteIndex];
}

void InitRuntimePalette(const std::array<Color, 256>& basePalette)
{
	g_basePalette = basePalette;
	g_runtimePalette = basePalette;

	Image paletteImage = GenImageColor(256, 1, BLACK);
	for (int i = 0; i < 256; ++i)
	{
		ImageDrawPixel(&paletteImage, i, 0, g_runtimePalette[i]);
	}

	if (g_paletteTexture.id > 0)
	{
		UnloadTexture(g_paletteTexture);
	}
	g_paletteTexture = LoadTextureFromImage(paletteImage);
	SetTextureFilter(g_paletteTexture, TEXTURE_FILTER_POINT);
	SetTextureWrap(g_paletteTexture, TEXTURE_WRAP_CLAMP);
	UnloadImage(paletteImage);

	g_paletteSystemReady = (g_paletteShader.id > 0 && g_paletteTexture.id > 0);
}

void UpdateRuntimePalette()
{
	if (!g_paletteSystemReady)
	{
		return;
	}

	// Glisten bands cycle at 8 steps/sec; shorter bands share the same clock.
	// Includes 244-254 so opaque gems (shape 760 frames 7-11) sparkle with original colors.
	// Translucent shapes never sample this LUT for 244-254 — they use static xform bake colors.
	const int step = static_cast<int>(GetTime() * 8.0) % 8;

	g_runtimePalette = g_basePalette;
	RotatePaletteBand(224, 8, step); // 224-231
	RotatePaletteBand(232, 8, step); // 232-239
	RotatePaletteBand(240, 4, step); // 240-243
	RotatePaletteBand(244, 4, step); // 244-247 (opaque gem glisten; translucent shapes use bake path)
	RotatePaletteBand(248, 4, step); // 248-251
	RotatePaletteBand(252, 3, step); // 252-254

	UpdateTexture(g_paletteTexture, g_runtimePalette.data());

	if (g_Terrain)
	{
		g_Terrain->ApplyPaletteToTerrainAtlas();
	}

	// Cuboids still sample RGB face atlases; recolor cycling pixels from the LUT.
	// Only touch shape/frames that are actually on-screen — full 150–1023×32 scans
	// plus UpdateTextures() (full face-atlas rebuild) were a major hitch at 8 Hz.
	static int lastCuboidPaletteStep = -1;
	if (step != lastCuboidPaletteStep)
	{
		lastCuboidPaletteStep = step;

		// Collect unique (shape, frame) pairs for visible cuboids with glisten pixels.
		// Key: shape * 32 + frame (shape < 1024, frame < 32).
		static thread_local std::vector<int> visibleCuboidKeys;
		visibleCuboidKeys.clear();
		for (U7Object* obj : g_sortedVisibleObjects)
		{
			if (!obj || !obj->m_shapeData)
			{
				continue;
			}
			ShapeData* sd = obj->m_shapeData;
			if (sd->GetDrawType() != ShapeDrawType::OBJECT_DRAW_CUBOID || sd->m_palettePixels.empty())
			{
				continue;
			}
			const int key = sd->GetShape() * 32 + sd->GetFrame();
			visibleCuboidKeys.push_back(key);
		}
		std::sort(visibleCuboidKeys.begin(), visibleCuboidKeys.end());
		visibleCuboidKeys.erase(std::unique(visibleCuboidKeys.begin(), visibleCuboidKeys.end()), visibleCuboidKeys.end());

		for (int key : visibleCuboidKeys)
		{
			const int shape = key / 32;
			const int frame = key % 32;
			if (shape < 150 || shape >= 1024 || frame < 0 || frame >= 32)
			{
				continue;
			}
			ShapeData& shapeData = g_shapeTable[shape][frame];
			if (!shapeData.IsValid() || shapeData.m_palettePixels.empty())
			{
				continue;
			}
			if (shapeData.m_texture == nullptr || shapeData.m_texture->m_Image.data == nullptr)
			{
				continue;
			}

			for (const auto& pixel : shapeData.m_palettePixels)
			{
				const int pX = std::get<0>(pixel);
				const int pY = std::get<1>(pixel);
				const int pRef = std::get<2>(pixel);
				if (pRef < 0 || pRef > 255)
				{
					continue;
				}
				if (pX < 0 || pY < 0 || pX >= shapeData.m_texture->width || pY >= shapeData.m_texture->height)
				{
					continue;
				}
				ImageDrawPixel(&shapeData.m_texture->m_Image, pX, pY, g_runtimePalette[pRef]);
			}
			// In-place GPU update (avoids leaking a new texture each tick)
			::UpdateTexture(shapeData.m_texture->m_Texture, shapeData.m_texture->m_Image.data);
			// Rebuild cuboid face atlas so world draws see the new colors.
			shapeData.UpdateTextures();
		}
	}
}

void BindPaletteShader()
{
	if (!g_paletteSystemReady)
	{
		return;
	}
	// Bind palette LUT to texture1 for BeginShaderMode paths (billboards).
	// Model draws also set MATERIAL_MAP_SPECULAR so DrawMesh rebinds it.
	if (g_paletteSamplerLoc >= 0)
	{
		SetShaderValueTexture(g_paletteShader, g_paletteSamplerLoc, g_paletteTexture);
	}
}

void BindPaletteMaterial(Material* material, Texture2D indexTexture)
{
	if (!g_paletteSystemReady || material == nullptr)
	{
		return;
	}
	material->shader = g_paletteShader;
	SetMaterialTexture(material, MATERIAL_MAP_DIFFUSE, indexTexture);
	SetMaterialTexture(material, MATERIAL_MAP_SPECULAR, g_paletteTexture);
}

int FindNearestU7PaletteIndex(unsigned char r, unsigned char g, unsigned char b)
{
	int best = 0;
	int bestDist = 0x7fffffff;
	for (int i = 0; i < 255; ++i)
	{
		const int dr = int(r) - int(g_basePalette[i].r);
		const int dg = int(g) - int(g_basePalette[i].g);
		const int db = int(b) - int(g_basePalette[i].b);
		const int dist = dr * dr + dg * dg + db * db;
		if (dist < bestDist)
		{
			bestDist = dist;
			best = i;
			if (dist == 0)
				break;
		}
	}
	return best;
}

bool g_pixelated = false;
// Default: screen-space outlines (F6 falls back to stencil inflate).
bool g_useScreenSpaceMeshOutline = true;
RenderTexture2D g_renderTarget;
RenderTexture2D g_pixelRenderTarget;
RenderTexture2D g_guiRenderTarget;

RenderTexture2D& GetWorldRenderTarget()
{
	return g_pixelated ? g_pixelRenderTarget : g_renderTarget;
}

std::unique_ptr<U7Player> g_Player;

bool g_LuaDebug = false;  // Toggle with F8 key
bool g_showScriptedObjects = false;  // Toggle with F11 key - highlights objects with scripts
bool g_showEggs = false;  // Toggle with Ctrl+G

std::unique_ptr<Model> g_CuboidModel;

std::vector< std::vector<Texture> > g_walkFrames;


Color g_dayNightColor = WHITE;
bool g_isDay = true;

float g_lastTime;
unsigned int g_hour;
unsigned int g_minute;
unsigned int g_scheduleTime;
float g_secsPerMinute = 5;
bool g_autoRotate = false;

int g_lastScheduleTimeCheck = -1;

#ifdef DEBUG_NPC_PATHFINDING
std::unordered_map<int, NPCPathStats> g_npcMaxPathStats;
#endif

Vector3 g_terrainUnderMousePointer = Vector3{ 0, 0, 0 };

U7Object* g_mouseOverObject = nullptr;

std::unique_ptr<GumpManager> g_gumpManager;

U7Object* g_objectUnderMousePointer;
bool g_mouseOverUI = false;

U7Object* g_doubleClickedObject;

bool g_allowInput = true;
bool g_dungeonViewActive = false;

int g_cameraLockObjectId = -1;

namespace
{
	// Stable storage so returned Image* stays valid across calls (unique_ptr, not map-by-value).
	std::unordered_map<std::string, std::unique_ptr<Image>> g_guiImageCache;
}

const Image* GetCachedGuiImage(const std::string& resourcePath)
{
	auto it = g_guiImageCache.find(resourcePath);
	if (it != g_guiImageCache.end() && it->second && it->second->data != nullptr)
	{
		return it->second.get();
	}

	if (!g_ResourceManager)
	{
		return nullptr;
	}

	Texture* tex = g_ResourceManager->GetTexture(resourcePath, false);
	if (tex == nullptr || tex->id == 0)
	{
		return nullptr;
	}

	// One GPU→CPU read per texture for the lifetime of the process.
	Image img = LoadImageFromTexture(*tex);
	if (img.data == nullptr)
	{
		return nullptr;
	}

	auto stored = std::make_unique<Image>(img);
	Image* raw = stored.get();
	g_guiImageCache[resourcePath] = std::move(stored);
	return raw;
}

bool IsCameraLocked()
{
	return g_cameraLockObjectId >= 0;
}

bool IsCameraLockedToAvatar()
{
	if (!IsCameraLocked() || !g_Player)
		return false;

	U7Object* avatar = g_Player->GetAvatarObject();
	return avatar && g_cameraLockObjectId == avatar->m_ID;
}

void LockCameraToObject(int objectId)
{
	auto it = g_objectList.find(objectId);
	if (it == g_objectList.end() || !it->second || it->second->GetIsDead())
	{
		AddConsoleString("Cannot lock camera to that unit.", RED);
		return;
	}

	g_cameraLockObjectId = objectId;
	U7Object* obj = it->second.get();
	AddConsoleString("Camera locked to " + obj->m_name + ".", SKYBLUE);
}

void LockCameraToAvatar()
{
	if (!g_Player)
		return;

	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
		return;

	g_cameraLockObjectId = avatar->m_ID;
}

void UnlockCamera()
{
	if (!IsCameraLocked())
		return;

	g_cameraLockObjectId = -1;
	AddConsoleString("Camera unlocked.", SKYBLUE);
}

void LockCamera()
{
	LockCameraToAvatar();
}

Vector3 GetStandoffPosition(const Vector3& attackerPos, const Vector3& targetPos, float standOffRange)
{
	Vector3 delta = Vector3Subtract(attackerPos, targetPos);
	delta.y = 0.0f;

	float dist = Vector3Length(delta);
	if (dist < 0.001f)
		return attackerPos;

	Vector3 dir = Vector3Scale(delta, 1.0f / dist);
	return Vector3{
		targetPos.x + dir.x * standOffRange,
		attackerPos.y,
		targetPos.z + dir.z * standOffRange
	};
}

Vector3 GetScreenCenterWorldPoint()
{
	Ray ray = GetMouseRay({ (float)GetScreenWidth() / 2.0f, (float)GetScreenHeight() / 2.0f }, g_camera);

	float t = 0.0f;
	bool hit = false;


	U7Object* avatar = g_Player ? g_Player->GetAvatarObject() : nullptr;
	float avatarY = avatar ? avatar->m_centerPoint.y : 0.0f;


	if (ray.direction.y != 0.0f)
	{
		t = (avatarY - ray.position.y) / ray.direction.y;
		if (t > 0.0f)
			hit = true;
	}

	if (!hit || t < 0.5f)
	{
		if (ray.direction.y != 0.0f)
		{
			t = (0.0f - ray.position.y) / ray.direction.y;
			if (t > 0.0f)
				hit = true;
		}
	}

	if (hit)
		return Vector3Add(ray.position, Vector3Scale(ray.direction, t));

	return g_camera.target; // ultimate fallback
}

void CameraInput()
{
	g_CameraMoved = false;

	// Toggle first-person: Left Ctrl + P
	if (g_allowInput)
	{
		if (IsKeyDown(KEY_LEFT_CONTROL) && IsKeyPressed(KEY_P))
		{
			g_firstPersonEnabled = !g_firstPersonEnabled;

			// Reset first-person height and pitch to defaults whenever we toggle first-person mode
			g_firstPersonHeight = DEFAULT_FIRSTPERSON_HEIGHT;
			g_firstPersonPitch = DEFAULT_FIRSTPERSON_PITCH;

			// Initialize yaw depending on whether camera is locked to avatar or free
			if (g_firstPersonEnabled && g_Player)
			{
				U7Object* avatar = g_Player->GetAvatarObject();

				// If camera is locked to the avatar, derive yaw from player/avatar direction as before
				if (IsCameraLockedToAvatar())
				{
					Vector3 dir = g_Player->GetAvatarObject()->GetPos();
					if (Vector3Length(dir) < 0.001f && avatar)
						dir = avatar->m_Direction;
					if (Vector3Length(dir) >= 0.001f)
						g_firstPersonYaw = atan2f(dir.z, dir.x);
				}
				else
				{
					Vector3 centerPoint = GetScreenCenterWorldPoint();
					Vector3 camForward = Vector3Subtract(centerPoint, g_camera.position);
					camForward.y = 0.0f;


					const float EPS = 0.0005f;
					if (Vector3Length(camForward) >= EPS)
					{
						Vector3 normalizedForward = Vector3Normalize(camForward);
						g_firstPersonYaw = atan2f(normalizedForward.z, normalizedForward.x);

						float backupDistance = 16.0F;

						g_camera.position.x = centerPoint.x - (normalizedForward.x * backupDistance);
						g_camera.position.z = centerPoint.z - (normalizedForward.z * backupDistance);
					}
					// else: keep existing yaw to avoid jumps
				}
			}

			// Hide/show avatar mesh when toggling first-person
			if (g_Player)
			{
				U7Object* avatar = g_Player->GetAvatarObject();
				if (avatar)
				{
					if (IsCameraLockedToAvatar())
						avatar->m_ShouldDraw = !g_firstPersonEnabled;
				}
			}

			AddConsoleString(std::string("First-person view ") + (g_firstPersonEnabled ? "enabled" : "disabled"), WHITE);

			// Update camera once so position/target reflect the new first-person yaw/height without changing X/Z
			CameraUpdate(true);

			// Debug: camera state after toggle
			Vector3 afterPos = g_camera.position;
			Vector3 afterTarget = g_camera.target;
			std::ostringstream ossAfter;
			ossAfter << "CAM_TOGGLE AFTER  pos=(" << afterPos.x << "," << afterPos.y << "," << afterPos.z << ") tgt=("
				<< afterTarget.x << "," << afterTarget.y << "," << afterTarget.z << ")";
			AddConsoleString(ossAfter.str(), WHITE);
		}
	}

	// If first-person enabled, compute camera-relative forward/right once and use them both for locked and free movement
	if (g_firstPersonEnabled && g_Player && g_allowInput)
	{
		U7Object* avatar = g_Player->GetAvatarObject();
		if (!avatar) return;

		float dt = g_Engine->LastFrameInSeconds();

		// Rotation (Q/E) - Q = left, E = right
		if (!IsKeyDown(KEY_LEFT_CONTROL) && IsKeyDown(KEY_Q))
		{
			g_firstPersonYaw -= dt * 3.5f; // rotate left
		}
		if (!IsKeyDown(KEY_LEFT_CONTROL) && IsKeyDown(KEY_E))
		{
			g_firstPersonYaw += dt * 3.5f; // rotate right
		}

		// Z / C behavior:
		// - When NOT locked to avatar: Z lowers the camera (decrease eye height), C raises it (increase eye height).
		// - When locked to avatar: Z looks down (decrease pitch), C looks up (increase pitch) while keeping eye height at avatar head.
		const float heightSpeed = 2.5f;    // units per second for raising/lowering
		const float pitchSpeed = 1.5f;     // radians per second for looking up/down
		const float minHeight = 1.0f;
		const float maxHeight = 20.0f;
		const float maxPitch = PI * 0.45f; // ~81 deg limit
		const float minPitch = -PI * 0.45f;

		if (!IsCameraLocked())
		{
			// Free first-person: change eye height
			if (IsKeyDown(KEY_LEFT_CONTROL) && IsKeyDown(KEY_Q))
			{
				g_firstPersonHeight -= heightSpeed * dt;
				if (g_firstPersonHeight < minHeight) g_firstPersonHeight = minHeight;
			}
			if (IsKeyDown(KEY_LEFT_CONTROL) && IsKeyDown(KEY_E))
			{
				g_firstPersonHeight += heightSpeed * dt;
				if (g_firstPersonHeight > maxHeight) g_firstPersonHeight = maxHeight;
			}

			// When free, keep pitch neutral to avoid accidental tilt
			g_firstPersonPitch = 0.0f;
		}
		else
		{
			// Locked-first-person: change pitch (look up/down) but keep eye height anchored to avatar
			if (IsKeyDown(KEY_LEFT_CONTROL) && IsKeyDown(KEY_Q))
			{
				g_firstPersonPitch -= pitchSpeed * dt; // look down
				if (g_firstPersonPitch < minPitch) g_firstPersonPitch = minPitch;
			}
			if (IsKeyDown(KEY_LEFT_CONTROL) && IsKeyDown(KEY_E))
			{
				g_firstPersonPitch += pitchSpeed * dt; // look up
				if (g_firstPersonPitch > maxPitch) g_firstPersonPitch = maxPitch;
			}
		}

		// normalize yaw
		while (g_firstPersonYaw < 0.0f) g_firstPersonYaw += 2 * PI;
		while (g_firstPersonYaw >= 2 * PI) g_firstPersonYaw -= 2 * PI;

		// Ensure camera uses latest yaw/pitch/height
		CameraUpdate(true);

		// Derive a horizontal forward vector from the camera look direction (flat on XZ)
		Vector3 camForward = Vector3Subtract(g_camera.target, g_camera.position);
		Vector3 flatForward = camForward;
		flatForward.y = 0.0f;
		if (Vector3Length(flatForward) < 0.0001f)
		{
			flatForward = Vector3{ cosf(g_firstPersonYaw), 0.0f, sinf(g_firstPersonYaw) };
		}
		flatForward = Vector3Normalize(flatForward);

		// Right vector on XZ plane (camera-right)
		Vector3 right = Vector3{ flatForward.z, 0.0f, -flatForward.x };
		right = Vector3Normalize(right);

		// Movement relative to camera (horizontal only)
		Vector3 move = { 0.0f, 0.0f, 0.0f };
		if (IsKeyDown(KEY_W)) move = Vector3Add(move, Vector3Scale(flatForward, g_firstPersonMoveSpeed * dt));
		if (IsKeyDown(KEY_S)) move = Vector3Add(move, Vector3Scale(flatForward, -g_firstPersonMoveSpeed * dt));
		if (IsKeyDown(KEY_D)) move = Vector3Add(move, Vector3Scale(right, -g_firstPersonMoveSpeed * dt));
		if (IsKeyDown(KEY_A)) move = Vector3Add(move, Vector3Scale(right, g_firstPersonMoveSpeed * dt));

		if (move.x != 0.0f || move.z != 0.0f)
		{
			if (!IsCameraLocked())
			{
				// Free camera: move both camera position and target by the same vector
				Vector3 newCamPos = Vector3Add(g_camera.position, move);
				Vector3 newCamTarget = Vector3Add(g_camera.target, move);

				// Keep camera within world bounds in X/Z
				if (newCamPos.x < 0.0f) newCamPos.x = 0.0f;
				if (newCamPos.x > 3072.0f) newCamPos.x = 3072.0f;
				if (newCamPos.z < 0.0f) newCamPos.z = 0.0f;
				if (newCamPos.z > 3072.0f) newCamPos.z = 3072.0f;

				g_camera.position = newCamPos;
				g_camera.target = newCamTarget;
				g_hasCameraChanged = true;
				g_CameraMoved = true;
			}
			// else: locked camera shouldn't move the avatar here
		}
		else
		{
			// no movement, but allow rotation-only to update camera
			g_CameraMoved = true;
		}

		// Done handling first-person input — don't fall through to third-person controls
		return;
	}

	// --- existing third-person controls (unchanged) ---
	Vector3 direction = { 0, 0, 0 };
	float deltaRotation = 0;

	float frameTimeModifier = 30;

	if (!IsCameraLocked() && g_allowInput)
	{
		if (IsKeyDown(KEY_A))
		{
			direction = Vector3Add(direction, { float(-g_Engine->LastFrameInSeconds()) * frameTimeModifier, 0, float(g_Engine->LastFrameInSeconds()) * frameTimeModifier});
			g_CameraMoved = true;
		}

		if (IsKeyDown(KEY_D))
		{
			direction = Vector3Add(direction, { float(g_Engine->LastFrameInSeconds()) * frameTimeModifier, 0, float(-g_Engine->LastFrameInSeconds()) * frameTimeModifier });
			g_CameraMoved = true;
		}

		if (IsKeyDown(KEY_W))
		{
			direction = Vector3Add(direction, { float(-g_Engine->LastFrameInSeconds()) * frameTimeModifier, 0, float(-g_Engine->LastFrameInSeconds()) * frameTimeModifier });
			g_CameraMoved = true;
		}

		if (IsKeyDown(KEY_S))
		{
			direction = Vector3Add(direction, { float(g_Engine->LastFrameInSeconds()) * frameTimeModifier, 0, float(g_Engine->LastFrameInSeconds()) * frameTimeModifier });
			g_CameraMoved = true;
		}
	}
	// else
	// {
	// 	Vector3 cameraPosition = g_camera.target;
	// 	Vector3 playerPosition = g_objectList[g_NPCData[0]->m_objectID]->m_Pos;
	//
	// 	if (cameraPosition.x != playerPosition.x || cameraPosition.y != playerPosition.y || cameraPosition.z != playerPosition.z)
	// 	{
	// 		g_camera.target = playerPosition;
	// 		g_CameraMoved = true;
	// 	}
	// }

	if (g_CameraMoved)
	{
		g_CameraMovementSpeed = direction;
	}

	bool cameraRotated = false;

	if (g_allowInput)
	{
		if (IsKeyDown(KEY_Q))
		{
			g_CameraRotateSpeed = g_Engine->LastFrameInSeconds() * 5;
			g_CameraMoved = true;
			cameraRotated = true;
		}

		if (IsKeyDown(KEY_E))
		{
			g_CameraRotateSpeed = -g_Engine->LastFrameInSeconds() * 5;
			g_CameraMoved = true;
			cameraRotated = true;
		}
	}

	float newDistance = g_cameraDistance;
	bool mouseWheel = false;
	float mouseDelta = 1;

	if (g_allowInput)
	{
		if (GetMouseWheelMove() < 0)
		{
			newDistance = g_cameraDistance + mouseDelta;
			mouseWheel = true;
		}

		if (GetMouseWheelMove() > 0)
		{
			newDistance = g_cameraDistance - mouseDelta;
			mouseWheel = true;
		}
	}

	if (mouseWheel)
	{
		if (newDistance > g_Engine->m_EngineConfig.GetNumber("camera_far_limit"))
		{
			newDistance = g_Engine->m_EngineConfig.GetNumber("camera_far_limit");
		}

		if (newDistance < g_Engine->m_EngineConfig.GetNumber("camera_close_limit"))
		{
			newDistance = g_Engine->m_EngineConfig.GetNumber("camera_close_limit");
		}

		g_cameraDistance = newDistance;

		g_CameraMoved = true;
	}

	if (g_allowInput)
	{
		if (g_InputSystem->IsLButtonDownInRegion(g_Engine->m_ScreenWidth - (g_minimapSize * g_DrawScale), 0, g_Engine->m_ScreenWidth, g_minimapSize * g_DrawScale)
			&& !g_gumpManager->IsAnyGumpBeingDragged())
		{
			float minimapx = float(GetMouseX() - (g_Engine->m_ScreenWidth - (g_minimapSize * g_DrawScale))) / float(g_minimapSize * g_DrawScale) * 3072;
			float minimapy = float(GetMouseY()) / float(g_minimapSize * g_DrawScale) * 3072;

			g_camera.target = Vector3{ minimapx, 0, minimapy };
			g_CameraMoved = true;
		}
	}
}

void CameraSetDestination(Vector3 destination)
{
	g_shouldCameraMoveToDestination = true;
	g_cameraDestination = destination;
}

// --- Replace CameraUpdate() to honor first-person yaw when enabled ---
void CameraUpdate(bool forcemove)
{
	bool moveDecay = false;
	bool rotateDecay = false;

	// First-person: position camera at avatar eye when locked, or keep X/Z and apply first-person angle/height when not locked
	if (g_firstPersonEnabled && g_Player)
	{
		U7Object* avatar = g_Player->GetAvatarObject();
		if (avatar)
		{
			// If camera is locked to avatar, use avatar center as base (previous behavior)
			if (IsCameraLocked())
			{
				U7Object* lockObj = GetObjectFromID(g_cameraLockObjectId);
				Vector3 basePos = lockObj ? lockObj->m_Pos : avatar->m_Pos;
				Vector3 eyePos = Vector3Add(basePos, Vector3{ 0.0f, g_firstPersonHeight - 2.0f, 0.0f });

				// forward now respects pitch
				float cp = cosf(g_firstPersonPitch);
				Vector3 forward = { cosf(g_firstPersonYaw) * cp, sinf(g_firstPersonPitch), sinf(g_firstPersonYaw) * cp };
				Vector3 target = Vector3Add(eyePos, Vector3Scale(forward, 10.0f)); // look 10 units ahead

				g_camera.position = eyePos;
				g_camera.target = target;
				g_camera.up = Vector3{ 0.0f, 1.0f, 0.0f };
				g_camera.projection = CAMERA_PERSPECTIVE;
				g_camera.fovy = g_firstPersonFOV;
				g_hasCameraChanged = true;
			}
			else
			{
				// Camera not locked to avatar: preserve current X/Z, set Y to avatar height + eye offset,
				// then orient by first-person yaw (no center-of-screen focus logic).
				Vector3 prevPos = g_camera.position; // preserve X/Z
				Vector3 eyePos = prevPos;
				eyePos.y = avatar->m_centerPoint.y + g_firstPersonHeight;

				// For free camera we keep horizontal forward (no pitch) so the view remains level.
				Vector3 forward = { cosf(g_firstPersonYaw), 0.0f, sinf(g_firstPersonYaw) };
				Vector3 target = Vector3Add(eyePos, Vector3Scale(forward, 10.0f));

				g_camera.position = eyePos;
				g_camera.target = target;
				g_camera.up = Vector3{ 0.0f, 1.0f, 0.0f };
				g_camera.projection = CAMERA_PERSPECTIVE;
				g_camera.fovy = g_firstPersonFOV;
				g_hasCameraChanged = true;
			}
		}
		return; // skip third-person updates
	}

	if (IsCameraLocked())
	{
		U7Object* lockObj = GetObjectFromID(g_cameraLockObjectId);
		if (lockObj && !lockObj->GetIsDead())
		{
			const Vector3 lockPosition = lockObj->m_Pos;

			// Follow XZ tightly so pan still feels locked to the unit.
			g_camera.target.x = lockPosition.x;
			g_camera.target.z = lockPosition.z;

			// Smooth vertical follow so stepping onto crates/stairs does not pop the ortho camera.
			// forcemove snaps (teleport / mode toggles / scripted camera).
			if (forcemove)
			{
				g_camera.target.y = lockPosition.y;
			}
			else
			{
				float dt = g_Engine->LastFrameInSeconds();
				if (dt < 1e-4f)
				{
					dt = 1e-4f;
				}
				// Higher = snappier. ~5-8 feels like existing rotate/pan decay.
				constexpr float kCameraYSmoothSpeed = 6.0f;
				const float dy = lockPosition.y - g_camera.target.y;
				if (fabsf(dy) < 0.005f)
				{
					g_camera.target.y = lockPosition.y;
				}
				else
				{
					const float t = 1.0f - expf(-kCameraYSmoothSpeed * dt);
					g_camera.target.y += dy * t;
				}
			}

			// Always refresh camera pose while locked (Y may still be lerping).
			g_CameraMoved = true;
		}
		else
		{
			UnlockCamera();
		}
	}



		// --- existing third-person CameraUpdate logic below (unchanged) ---

		if (!g_CameraMoved && (g_CameraMovementSpeed.x != 0 || g_CameraMovementSpeed.z != 0))
		{
			g_CameraMovementSpeed = Vector3{ g_CameraMovementSpeed.x * .75f, g_CameraMovementSpeed.y, g_CameraMovementSpeed.z * .75f };

			if (abs(g_CameraMovementSpeed.x) < .01f)
			{
				g_CameraMovementSpeed.x = 0;
			}

			if (abs(g_CameraMovementSpeed.z) < .01f)
			{
				g_CameraMovementSpeed.z = 0;
			}

			moveDecay = true;
		}

		//  Make sure we eventually stop moving no matter what.
		if (g_CameraRotateSpeed != 0)
		{
			g_CameraRotateSpeed = g_CameraRotateSpeed * .75f;
			if (abs(g_CameraRotateSpeed) < .01f)
			{
				g_CameraRotateSpeed = 0;
			}

			rotateDecay = true;
		}

	// The camera was manually moved.
	if (g_CameraMoved || forcemove || g_autoRotate || rotateDecay || moveDecay)
	{
		g_cameraRotation += g_CameraRotateSpeed;

		while (g_cameraRotation < 0)
		{
			g_cameraRotation += 2 * PI;
		}

		while (g_cameraRotation > 2 * PI)
		{
			g_cameraRotation -= 2 * PI;
		}
	}

	// A rotation and/or destination was set, probably by a script.
	if (g_autoRotate == true)
	{
		float delta = g_cameraRotationTarget - g_cameraRotation;
		if (abs(delta) > 0.05 && g_autoRotate)
		{
			if (delta > PI)
			{
				delta -= 2 * PI;
			}
			else if (delta < -PI)
			{
				delta += 2 * PI;
			}
			g_CameraRotateSpeed = (delta > 0.0f) ? g_Engine->LastFrameInSeconds() * 1 : g_Engine->LastFrameInSeconds() * -1;
		}
		else
		{
			g_autoRotate = false;
			g_cameraRotation = g_cameraRotationTarget;
		}
	}


	Vector3 current = g_camera.target;

	Vector3 finalmovement = Vector3RotateByAxisAngle(g_CameraMovementSpeed, Vector3{ 0, 1, 0 }, g_cameraRotation);

	current = Vector3Add(current, finalmovement);

	if (current.x < 0) current.x = 0;
	if (current.x > 3072) current.x = 3072;
	if (current.z < 0) current.z = 0;
	if (current.z > 3072) current.z = 3072;

	Vector3 camPos = { g_cameraDistance, g_cameraDistance, g_cameraDistance };
	camPos = Vector3RotateByAxisAngle(camPos, Vector3{ 0, 1, 0 }, g_cameraRotation);

	g_camera.target = current;
	g_camera.position = Vector3Add(current, camPos);
	g_camera.fovy = g_cameraDistance;
	g_camera.projection = CAMERA_ORTHOGRAPHIC;
}

U7Object* GetObjectFromID(int unitID)
{
	auto it = g_objectList.find(unitID);
	if (it != g_objectList.end())
	{
		return it->second.get(); // Returns raw pointer to U7Object
	}
	return nullptr;
}

U7Object* GetRootNPCFromContainer(U7Object* container)
{
	if (container == nullptr)
		return nullptr;

	// If this container is already an NPC, return it
	if (container->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
		return container;

	// Follow the parent chain up to find an NPC
	int currentId = container->m_containingObjectId;
	while (currentId != -1)
	{
		U7Object* parent = GetObjectFromID(currentId);
		if (parent == nullptr)
			break;

		if (parent->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
			return parent;

		currentId = parent->m_containingObjectId;
	}

	return nullptr;
}

float GetMaxWeightFromStrength(int strength)
{
	return 2.0f * strength;
}

// Intersect a ray with a horizontal plane at planeY. Returns false if ray is parallel.
static bool RayHitPlaneY(const Ray& ray, float planeY, Vector3& outHit)
{
	if (fabsf(ray.direction.y) < 1e-8f)
		return false;
	const float t = (planeY - ray.position.y) / ray.direction.y;
	outHit = Vector3Add(ray.position, Vector3Scale(ray.direction, t));
	return true;
}

void GetCameraVisibleChunkRange(int& outMinCX, int& outMaxCX, int& outMinCZ, int& outMaxCZ)
{
	// Unproject the four screen corners onto horizontal planes through the world.
	// Using ground (y=0) plus a tall-object plane expands the range so rooftops and
	// multi-story walls near the frustum edge still pull in their home chunks.
	// This tracks zoom, aspect ratio, and camera rotation — unlike a fixed ±N radius
	// around the look-at point, which drops objects when zoomed out.

	const float screenW = static_cast<float>(GetScreenWidth());
	const float screenH = static_cast<float>(GetScreenHeight());
	const Vector2 corners[4] = {
		{ 0.0f, 0.0f },
		{ screenW, 0.0f },
		{ screenW, screenH },
		{ 0.0f, screenH }
	};

	// m_heightCutoff for "inside" drawing is 16; sample a bit above for safety.
	const float planes[] = { 0.0f, 8.0f, 16.0f };

	float minX = 1e9f, maxX = -1e9f, minZ = 1e9f, maxZ = -1e9f;
	int hitCount = 0;

	for (float planeY : planes)
	{
		for (const Vector2& c : corners)
		{
			const Ray ray = GetMouseRay(c, g_camera);
			Vector3 hit{};
			if (!RayHitPlaneY(ray, planeY, hit))
				continue;

			// Discard absurd hits (e.g. looking nearly parallel to the ground).
			if (hit.x < -512.0f || hit.x > 3072.0f + 512.0f ||
			    hit.z < -512.0f || hit.z > 3072.0f + 512.0f)
				continue;

			minX = std::min(minX, hit.x);
			maxX = std::max(maxX, hit.x);
			minZ = std::min(minZ, hit.z);
			maxZ = std::max(maxZ, hit.z);
			++hitCount;
		}
	}

	// Pad for multi-tile objects whose m_Pos chunk is outside the pure ground AABB
	// but whose art still reaches into the frustum (SE-origin footprints, billboards).
	const float padTiles = 12.0f;

	if (hitCount < 4)
	{
		// Fallback: distance-based radius (ortho fovy ≈ world height in tiles).
		const float halfExtent = std::max(g_cameraDistance, 18.0f) * 1.25f + padTiles;
		minX = g_camera.target.x - halfExtent;
		maxX = g_camera.target.x + halfExtent;
		minZ = g_camera.target.z - halfExtent;
		maxZ = g_camera.target.z + halfExtent;
	}
	else
	{
		minX -= padTiles;
		maxX += padTiles;
		minZ -= padTiles;
		maxZ += padTiles;
	}

	auto toChunk = [](float world) -> int {
		return static_cast<int>(std::floor(world / 16.0f));
	};

	outMinCX = std::max(0, toChunk(minX));
	outMaxCX = std::min(191, toChunk(maxX));
	outMinCZ = std::max(0, toChunk(minZ));
	outMaxCZ = std::min(191, toChunk(maxZ));

	// Safety: never return an inverted range.
	if (outMinCX > outMaxCX) std::swap(outMinCX, outMaxCX);
	if (outMinCZ > outMaxCZ) std::swap(outMinCZ, outMaxCZ);
}

void UpdateSortedVisibleObjects()
{
	int minCX = 0, maxCX = 0, minCZ = 0, maxCZ = 0;
	GetCameraVisibleChunkRange(minCX, maxCX, minCZ, maxCZ);

	g_sortedVisibleObjects.clear();

	for (int x = minCX; x <= maxCX; x++)
	{
		for (int y = minCZ; y <= maxCZ; y++)
		{
			for (auto object : g_chunkObjectMap[x][y])
			{
				// Skip null, dead, or contained objects
				if (!object || object->GetIsDead() || object->m_isContained || !object->m_Visible)
				{
					continue;
				}

				object->m_distanceFromCamera = Vector3DistanceSqr(object->m_centerPoint, g_camera.position);
				g_sortedVisibleObjects.push_back(object);
				// Multi-frame FX use TFA isAnimated + native SetFrame cycling in InteractiveDraw.
			}
		}
	}

	std::sort(g_sortedVisibleObjects.begin(), g_sortedVisibleObjects.end(), [](U7Object* a, U7Object* b) { return a->m_distanceFromCamera > b->m_distanceFromCamera; });

	g_objectUnderMousePointer = nullptr;

	// Don't pick objects if mouse is over UI elements
	if (g_mouseOverUI)
	{
		return;
	}

	//  Is a gump open?  Are we over it?  See if there's an object under our mouse.
	if (!g_gumpManager->m_GumpList.empty() && g_gumpManager->IsMouseOverGump() && g_gumpManager->m_gumpUnderMouse != nullptr)
	{
		g_objectUnderMousePointer = g_gumpManager->m_gumpUnderMouse->GetObjectUnderMousePointer();
	}
	else
	{
		for (auto node = g_sortedVisibleObjects.rbegin(); node != g_sortedVisibleObjects.rend(); ++node)
		{
			if (*node == nullptr || !(*node)->m_Visible)
			{
				continue;
			}

			Vector3 pos = { 0, 0, 0 };
			float picked = (*node)->PickXYZ(pos);

			if (picked != -1)
			{
				g_objectUnderMousePointer = *node;
				break;
			}
		}
	}

	// Pick cell under mouse pointer
	Ray ray = GetMouseRay(GetMousePosition(), g_camera);
	float pickx = 0;
	float picky = 0;

	Vector3 planeNormal = { 0.0f, 1.0f, 0.0f };
	Vector3 planePoint = { 0.0f, 0.0f, 0.0f };
	float denominator = Vector3DotProduct(ray.direction, planeNormal);

	if (fabs(denominator) > 0.0001f)
	{
		Vector3 pointToPlane = Vector3Subtract(planePoint, ray.position);
		float t = Vector3DotProduct(pointToPlane, planeNormal) / denominator;
		if (t >= 0.0f) {
			Vector3 hitPoint = Vector3Add(ray.position, Vector3Scale(ray.direction, t));
			int x = static_cast<int>(floor(hitPoint.x));
			int y = static_cast<int>(floor(hitPoint.z));
			if (x >= 0 && x < 3072 && y >= 0 && y < 3072)
			{
				pickx = x;
				picky = y;
			}
		}
	}

	g_terrainUnderMousePointer = { pickx, 0, picky };

	g_terrainUnderMousePointer.x = roundf(g_terrainUnderMousePointer.x);
	g_terrainUnderMousePointer.y = roundf(g_terrainUnderMousePointer.y);
	g_terrainUnderMousePointer.z = roundf(g_terrainUnderMousePointer.z);
}

void DrawGameWorld(bool drawObjects)
{
	if (g_Terrain)
		g_Terrain->Draw();

	if (!drawObjects)
		return;

	// Flats are coplanar: camera-distance sort makes draw order flip when you rotate
	// (z-fight flicker). Use fixed world keys for a stable order at any angle.
	// Rugs (object name "rug") must sit under everything else, so they draw first
	// after terrain; other flats still draw after non-flats.
	auto stableFlatLess = [](const U7Object* a, const U7Object* b) {
		if (a->m_Pos.y != b->m_Pos.y)
			return a->m_Pos.y < b->m_Pos.y;
		if (a->m_Pos.z != b->m_Pos.z)
			return a->m_Pos.z < b->m_Pos.z;
		if (a->m_Pos.x != b->m_Pos.x)
			return a->m_Pos.x < b->m_Pos.x;
		return a->m_ID < b->m_ID;
	};

	auto isRugFlat = [](const U7Object* object) {
		if (!object || !object->m_objectData)
			return false;
		// TEXT.FLX labels these "rug" (shapes 188, 483, …).
		const std::string& name = object->m_objectData->m_name;
		return name.size() == 3 &&
			(name[0] == 'r' || name[0] == 'R') &&
			(name[1] == 'u' || name[1] == 'U') &&
			(name[2] == 'g' || name[2] == 'G');
	};

	std::vector<U7Object*> rugs;
	std::vector<U7Object*> flats;
	std::vector<U7Object*> meshes;
	rugs.reserve(16);
	flats.reserve(64);
	meshes.reserve(16);

	for (U7Object* object : g_sortedVisibleObjects)
	{
		if (!object)
			continue;
		if (object->m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
		{
			if (isRugFlat(object))
				rugs.push_back(object);
			else
				flats.push_back(object);
		}
		else if (object->m_drawType == ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH_DEFER)
			meshes.push_back(object);
	}

	std::sort(rugs.begin(), rugs.end(), stableFlatLess);
	std::sort(flats.begin(), flats.end(), stableFlatLess);

	// Rugs first (under furniture, other flats, etc.). Write depth so later
	// geometry occludes them correctly. Polygon offset is for flats only —
	// leaving it on for cuboids/meshes opened seam cracks in-game that the
	// Shape Editor never showed (it does not use DrawGameWorld).
	glEnable(GL_POLYGON_OFFSET_FILL);
	glPolygonOffset(-1.0f, -1.0f);
	for (U7Object* object : rugs)
		object->Draw();
	glDisable(GL_POLYGON_OFFSET_FILL);

	// Non-flats (write depth) — no polygon offset.
	for (U7Object* object : g_sortedVisibleObjects)
	{
		if (!object)
			continue;
		if (object->m_drawType == ShapeDrawType::OBJECT_DRAW_FLAT)
			continue;
		if (object->m_drawType == ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH_DEFER)
			continue;
		object->Draw();
	}

	// Other flats: depth-write off so coplanar roofs/floors do not fight each other.
	glEnable(GL_POLYGON_OFFSET_FILL);
	glPolygonOffset(-1.0f, -1.0f);
	rlDisableDepthMask();
	for (U7Object* object : flats)
		object->Draw();
	rlEnableDepthMask();
	glDisable(GL_POLYGON_OFFSET_FILL);

	if (!meshes.empty())
	{
		BeginShaderMode(g_alphaDiscard);
		for (U7Object* object : meshes)
			object->Draw();
		EndShaderMode();
	}

}
Color MakeMeshOutlineIdColor(int objectId)
{
	// Reserve RGB(0,0,0) as "no mesh" in the ID buffer.
	unsigned id = static_cast<unsigned>(objectId) + 1u;
	if (id == 0 || id > 0x00FFFFFFu)
		id = (id % 0x00FFFFFFu) + 1u;
	return Color{
		static_cast<unsigned char>(id & 0xFFu),
		static_cast<unsigned char>((id >> 8) & 0xFFu),
		static_cast<unsigned char>((id >> 16) & 0xFFu),
		255
	};
}

bool ObjectWantsScreenSpaceOutline(U7Object* object)
{
	if (!object || !object->m_shapeData || g_pixelated || !g_meshOutlineSystemReady)
		return false;
	if (!g_useScreenSpaceMeshOutline)
		return false;
	if (!object->m_shapeData->m_meshOutline)
		return false;
	const ShapeDrawType dt = object->m_drawType;
	return dt == ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH ||
		dt == ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH_DEFER;
}

void DrawMeshOutlineIdPass(bool drawObjects)
{
	if (!g_meshOutlineSystemReady || g_pixelated || !g_useScreenSpaceMeshOutline || !drawObjects)
		return;

	BeginTextureMode(g_meshIdTarget);
	ClearBackground(BLANK); // ID 0
	BeginMode3D(g_camera);

	// Depth occluders so outlines don't bleed through nearer non-outlined geometry.
	glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
	if (g_Terrain)
		g_Terrain->Draw();
	for (U7Object* object : g_sortedVisibleObjects)
	{
		if (!object || ObjectWantsScreenSpaceOutline(object))
			continue;
		object->Draw();
	}
	glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);

	for (U7Object* object : g_sortedVisibleObjects)
	{
		if (!object || !ObjectWantsScreenSpaceOutline(object))
			continue;
		object->DrawMeshId();
	}

	EndMode3D();
	EndTextureMode();
}

void BlitWorldWithMeshOutline()
{
	RenderTexture2D& worldRT = GetWorldRenderTarget();
	const Rectangle src{
		0, 0,
		float(worldRT.texture.width),
		float(worldRT.texture.height)
	};
	const Rectangle dest{
		0, float(g_Engine->m_ScreenHeight),
		float(g_Engine->m_ScreenWidth),
		-float(g_Engine->m_ScreenHeight)
	};

	const bool doScreenSpace = g_meshOutlineSystemReady && g_useScreenSpaceMeshOutline && !g_pixelated;
	if (!doScreenSpace)
	{
		DrawTexturePro(worldRT.texture, src, dest, { 0, 0 }, 0, WHITE);
		return;
	}

	const float res[2] = {
		float(worldRT.texture.width),
		float(worldRT.texture.height)
	};
	// Thickness = base × drawScale at closest zoom; shrinks as camera zooms out
	// so borders don't look heavier in screen space when the world shrinks.
	float closeLimit = 18.0f;
	if (g_Engine)
	{
		const float cfgClose = g_Engine->m_EngineConfig.GetNumber("camera_close_limit");
		if (cfgClose > 0.0f)
			closeLimit = cfgClose;
	}
	const float zoomFactor = closeLimit / std::max(g_cameraDistance, closeLimit);
	const float scaledThickness = g_meshOutlineThickness * g_DrawScale * zoomFactor;
	SetShaderValue(g_meshOutlineShader, g_meshOutlineResolutionLoc, res, SHADER_UNIFORM_VEC2);
	SetShaderValue(g_meshOutlineShader, g_meshOutlineThicknessLoc, &scaledThickness, SHADER_UNIFORM_FLOAT);

	BeginShaderMode(g_meshOutlineShader);
	if (g_meshOutlineIdSamplerLoc >= 0)
		SetShaderValueTexture(g_meshOutlineShader, g_meshOutlineIdSamplerLoc, g_meshIdTarget.texture);
	DrawTexturePro(worldRT.texture, src, dest, { 0, 0 }, 0, WHITE);
	EndShaderMode();
}

void DrawGameWorldFrame(bool drawObjects)
{
	const bool worldToRT = g_useScreenSpaceMeshOutline || g_pixelated;
	if (worldToRT)
		BeginTextureMode(GetWorldRenderTarget());

	ClearBackground(Color{ 0, 0, 0, 255 });
	BeginMode3D(g_camera);
	DrawGameWorld(drawObjects);
	EndMode3D();

	if (worldToRT)
	{
		EndTextureMode();
		DrawMeshOutlineIdPass(drawObjects);
		BlitWorldWithMeshOutline();
	}
}

Vector3 GetRadialVector(float partitions, float thispartition)
{
	float finalpartition = ((PI * 2) / partitions) * thispartition;

	return Vector3{ cos(finalpartition), 0, sin(finalpartition) };
}

unsigned int g_CurrentUnitID = 0;

unsigned int GetNextID() { return g_CurrentUnitID++; }

U7Object* AddObject(int shapenum, int framenum, int id, float x, float y, float z)
{
	if (shapenum == 739 && x == 968 && z == 2292)
	{
		Log("Stop here.");
	}

	g_objectList.emplace(id, make_unique<U7Object>());

	U7Object* temp = g_objectList[id].get();
	temp->Init("Data/Units/Walker.cfg", shapenum, framenum);
	temp->m_ID = id;
	temp->SetInitialPos(Vector3{ x, y, z });
	AssignObjectChunk(temp);
	//UpdateModelAnimation(temp->m_shapeData->m_customMesh->GetModel(), temp->m_shapeData->m_customMesh->GetModel()-> ->   0);

	// Notify pathfinding grid if this is a non-walkable object
	if (temp->m_objectData && temp->m_objectData->m_isNotWalkable)
	{
		NotifyPathfindingGridUpdate((int)x, (int)z);
	}

	return g_objectList[id].get();
}

void HideObject(int shapenum, int framenum, float x, float y, float z)
{
	int hideCount = 0;

	bool matched = false;
	int xInt = int(x);
	int yInt = int(z);
	int xPos = 0;
	int yPos = 0;
	int xMax = 192;
	int yMax = 192;
	xPos = (xInt - (xInt % 16)) / 16;
	yPos = (yInt - (yInt % 16)) / 16;
	if (xPos >= 0 && xPos < xMax && yPos >= 0 && yPos < yMax)
	{
		for (auto object : g_chunkObjectMap[int(xPos)][int(yPos)])
		{
			if (object->m_Pos.x == x && object->m_Pos.y == y && object->m_Pos.z == z)
			{
				object->Hide();
				hideCount++;
				matched = true;
				break;
			}
		}
	}
}

void MorphObject(int shapenum, int framenum, float x, float y, float z, float nux, float nuy, float nuz, const std::string& modelName, const std::string& imageName, ShapeDrawType drawType)
{
	int hideCount = 0;

	bool matched = false;
	int xInt = int(x);
	int yInt = int(z);
	int xPos = 0;
	int yPos = 0;
	int xMax = 192;
	int yMax = 192;
	xPos = (xInt - (xInt % 16)) / 16;
	yPos = (yInt - (yInt % 16)) / 16;
	if (xPos >= 0 && xPos < xMax && yPos >= 0 && yPos < yMax)
	{
		for (auto object : g_chunkObjectMap[int(xPos)][int(yPos)])
		{
			if (object->m_Pos.x == x && object->m_Pos.y == y && object->m_Pos.z == z)
			{
				object->m_customMeshName = modelName;
				// draw pos of roof object is offset from the top left sooo I should fix that or something
				object->m_anchorPos = Vector3{ -4.125f + nux, 0.0f + nuy, -4.125f - nuz };
				object->Morph(ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH_DEFER);
				hideCount++;
				matched = true;
				break;
			}
		}
	}
	//AddConsoleString("Morphed " + std::to_string(hideCount) + " objects in the Trinsic area.", GREEN);
}

void MorphAnimFlat(int shapeNum, int frameNum, int numFrames) {
	// Legacy entry point from roofimages.csv morphanim rows.
	// Animation is native SetFrame cycling for TFA isAnimated shapes — no shapesprite strips.
	(void)frameNum;
	if (shapeNum < 0 || shapeNum >= 1024 || numFrames < 2)
	{
		return;
	}
	// Ensure frame count is available if load-time count was missing.
	if (g_shapeTable[shapeNum][0].m_numFrames < numFrames)
	{
		const int count = std::min(numFrames, 32);
		for (int f = 0; f < count; ++f)
		{
			if (g_shapeTable[shapeNum][f].m_texture != nullptr)
			{
				g_shapeTable[shapeNum][f].m_numFrames = count;
			}
		}
	}
}

void MorphRoof(int roofId, int shapeNum, int frameNum, float x, float y, float z, float nux, float nuy, float nuz)
{
	int hideCount = 0;
	bool matched = false;
	int xInt = int(x);
	int yInt = int(z);
	int xPos = 0;
	int yPos = 0;
	int xMax = 192;
	int yMax = 192;
	xPos = (xInt - (xInt % 16)) / 16;
	yPos = (yInt - (yInt % 16)) / 16;
	if (xPos >= 0 && xPos < xMax && yPos >= 0 && yPos < yMax)
	{
		for (auto object : g_chunkObjectMap[int(xPos)][int(yPos)])
		{
			if (object->m_Pos.x == x && object->m_Pos.y == y && object->m_Pos.z == z)
			{
				object->m_customMeshName = "Models/3dmodels/roof_" + std::to_string(roofId) + ".glb";
				std::string imagePath = "Images/roof/roof_" + std::to_string(roofId) + ".png";
				// draw pos of roof object is offset from the top left sooo I should fix that or something
				object->m_anchorPos = Vector3{ -4.125f + nux, 0.0f + nuy, -4.125f - nuz };
				object->Morph(imagePath.c_str(), ShapeDrawType::OBJECT_DRAW_CUSTOM_MESH_DEFER);
				//AddConsoleString("It's morphing time! " + object->m_customMeshName, GREEN);
				hideCount++;
				matched = true;
				break;
			}
		}
	}
	//AddConsoleString("Morphed " + std::to_string(hideCount) + " roof objects in the area.", GREEN);
}

void BakeImageShapeFrames(int shapeNum, int startFrame, int maxFrames, int tileSizeX, int tileSizeY) {
	//AddConsoleString("Baking sprite images... ", GREEN);
	std::string objType = "shapesprite";
	std::string s_objId = std::to_string(shapeNum);
	std::string s_objFrame = std::to_string(startFrame);
	std::string objFolder = "Images/" + objType;
	std::filesystem::create_directories(objFolder.c_str());
	std::string imagePath = "Images/" + objType + "/" + objType + "_" + s_objId + "_" + s_objFrame + ".png";
	int borderSize = 0;
	int tileCountX = maxFrames - startFrame;
	int tileCountY = 1;
	if (FileExists(imagePath.c_str())) {
		Log("sprite image " + imagePath + " already exists, skipping generation.");
	}
	else {
		Log("sprite image " + imagePath + " does not exist, generating.");
		int imgSzeX = (tileSizeX * tileCountX);
		int imgSzeY = (tileSizeY * tileCountY);
		Image frameImage = GenImageColor(imgSzeX, imgSzeY, Color{ 0, 0, 0, 0 });
		float x = 0.0f;
		float z = 0.0f;
		float thisx = x;
		float thisz = z;
		int xInt = int(x);
		int yInt = int(z);
		int xPx = 0;
		int yPx = 0;
		int j = 0;
		int i = startFrame;
		thisz = z + (j * tileSizeY);
		i = 0;
		while (i < maxFrames) {
			thisx = x + ((i-startFrame) * tileSizeX);
			xInt = int(thisx);
			yInt = int(thisz);
			int framenum = i;
			ShapeData& m_shapeData = g_shapeTable[shapeNum][framenum];
			//xPx = (i * tileSizeX * borderSize) + borderSize * (tileSizeX + 1);
			//yPx = (j * tileSizeY * borderSize) + borderSize * (tileSizeY + 1);
			xPx = (i * tileSizeX) + (tileSizeX);
			yPx = (j * tileSizeY) + (tileSizeY);
			//float dstPosX = float(xPx - m_shapeData.m_pixelOffsetX);
			//float dstPosY = float(yPx - m_shapeData.m_pixelOffsetY);
			float dstPosX = float(xPx - m_shapeData.m_pixelOffsetX);
			float dstPosY = float(yPx - m_shapeData.m_pixelOffsetY);
			//Log("Loading shape palette " + std::to_string(xPx) + ", " + std::to_string(yPx) + " | " + std::to_string(dstPosX) + ", " + std::to_string(dstPosY) + " to sprite image!" + std::to_string(m_shapeData.m_pixelOffsetX) + ", " + std::to_string(m_shapeData.m_pixelOffsetY) + " shapeFrame[" + std::to_string(shapeNum) + ":" + std::to_string(framenum) + "]", "anims.log");
			ImageDraw(&frameImage,
				m_shapeData.m_texture->m_OriginalImage,
				Rectangle{ 0, 0, float(m_shapeData.m_texture->width), float(m_shapeData.m_texture->height) },
				Rectangle{
					dstPosX,
					dstPosY,
					float(m_shapeData.m_texture->width),
					float(m_shapeData.m_texture->height) },
					WHITE);
			i++;
		}
		//Log("Exporting sprite image to " + imagePath, "anims.log");
		ExportImage(frameImage, imagePath.c_str());
	}
}

void BakeImageRoof(int objId, int xOfs, float y, int tileSizeX, int tileSizeY, int borderSize, int tileCountX, int tileCountY) {
	//AddConsoleString("Baking roof images... ", GREEN);
	std::string objType = "roof";
	std::string s_objId = std::to_string(objId);
	int posStart = objId + xOfs;
	std::string objFolder = "Images/" + objType;
	std::filesystem::create_directories(objFolder.c_str());
	std::string imagePath = "Images/" + objType + "/" + objType + "_" + s_objId + ".png";
	if (FileExists(imagePath.c_str())) {
		Log("Roof image " + imagePath + " already exists, skipping generation.");
	}
	else {
		Log("Roof image " + imagePath + " does not exist, generating.");
		int imgSzeX = (tileSizeX * borderSize * tileCountX) + (borderSize * 2);
		int imgSzeY = (tileSizeY * borderSize * tileCountY) + (borderSize * 2);
		Image frameImage = GenImageColor(imgSzeX, imgSzeY, Color{ 0, 0, 0, 0 });

		float x = float(posStart % 3072);
		float z = float(posStart - int(x)) / 3072;
		float thisx = x;
		float thisz = z;

		int hideCount = 0;

		bool matched = false;
		int xInt = int(x);
		int yInt = int(z);
		int xPos = 0;
		int yPos = 0;
		int xPx = 0;
		int yPx = 0;
		int xMax = 192;
		int yMax = 192;
		int j = 0;
		int i = 0;
		while (j < tileCountY) {
			thisz = z + (j * tileSizeY);
			i = 0;
			while (i < tileCountX) {
				thisx = x + (i * tileSizeX);
				xInt = int(thisx);
				yInt = int(thisz);
				xPos = (xInt - (xInt % 16)) / 16;
				yPos = (yInt - (yInt % 16)) / 16;
				if (xPos >= 0 && xPos < xMax && yPos >= 0 && yPos < yMax)
				{
					for (auto object : g_chunkObjectMap[int(xPos)][int(yPos)])
					{
						if (object->m_Pos.x == thisx && object->m_Pos.y == y && object->m_Pos.z == thisz)
						{
							int shapenum = object->m_ObjectType;
							int framenum = object->m_Frame;
							ShapeData& m_shapeData = g_shapeTable[shapenum][framenum];
							xPx = (i * tileSizeX * borderSize) + borderSize * (tileSizeX + 1);
							yPx = (j * tileSizeY * borderSize) + borderSize * (tileSizeY + 1);
							float dstPosX = float(xPx - m_shapeData.m_pixelOffsetX);
							float dstPosY = float(yPx - m_shapeData.m_pixelOffsetY);
							//Log("Loading shape frame " + std::to_string(xPx) + ", " + std::to_string(yPx) + " | " + std::to_string(dstPosX) + ", " + std::to_string(dstPosY) + " to roof image!" + std::to_string(m_shapeData.m_pixelOffsetX) + ", " + std::to_string(m_shapeData.m_pixelOffsetY) + " shapeFrame[" + std::to_string(shapenum) + ":" + std::to_string(framenum) + "]");
							ImageDraw(&frameImage,
								m_shapeData.m_texture->m_OriginalImage,
								Rectangle{ 0, 0, float(m_shapeData.m_texture->width), float(m_shapeData.m_texture->height) },
								Rectangle{
									dstPosX,
									dstPosY,
									float(m_shapeData.m_texture->width),
									float(m_shapeData.m_texture->height) },
									WHITE);
							//AddConsoleString("WARNING: Shape: " + std::to_string(shapenum) + ", Frame: " + std::to_string(framenum) + ", File: " + filename, YELLOW);
							matched = true;
						}
					}
				}
				i++;
			}
			j++;
		}
		ExportImage(frameImage, imagePath.c_str());
	}
}

void UpdateObjectChunk(U7Object* object, Vector3 fromPos)
{
	if (object == nullptr)
		return;

	Vector2 fromChunkPos = Vector2{ floor(fromPos.x / 16), floor(fromPos.z / 16) };
	Vector2 toChunkPos = object->GetChunkPos();

	const int fromX = static_cast<int>(fromChunkPos.x);
	const int fromY = static_cast<int>(fromChunkPos.y);
	const int toX = static_cast<int>(toChunkPos.x);
	const int toY = static_cast<int>(toChunkPos.y);

	auto inBounds = [](int x, int y) { return x >= 0 && x < 192 && y >= 0 && y < 192; };

	if (toX == fromX && toY == fromY)
	{
		// Same chunk: still ensure we are registered (e.g. after a full map clear + SetPos).
		if (inBounds(toX, toY))
		{
			auto& chunk = g_chunkObjectMap[toX][toY];
			if (std::find(chunk.begin(), chunk.end(), object) == chunk.end())
				chunk.push_back(object);
		}
		return;
	}

	if (inBounds(fromX, fromY))
	{
		auto& fromChunk = g_chunkObjectMap[fromX][fromY];
		auto fromChunknode = std::find(fromChunk.begin(), fromChunk.end(), object);
		if (fromChunknode != fromChunk.end())
			fromChunk.erase(fromChunknode);
	}

	if (inBounds(toX, toY))
	{
		auto& toChunk = g_chunkObjectMap[toX][toY];
		toChunk.push_back(object);
	}
}

void AssignObjectChunk(U7Object* object)
{
	if (object == nullptr)
		return;

	int i = static_cast<int>(object->m_Pos.x / 16);
	int j = static_cast<int>(object->m_Pos.z / 16);
	if (i < 0 || i >= 192 || j < 0 || j >= 192)
		return;

	g_chunkObjectMap[i][j].push_back(object);
}

void UnassignObjectChunk(U7Object* object)
{
	if (object == nullptr)
		return;

	int i = static_cast<int>(object->m_Pos.x / 16);
	int j = static_cast<int>(object->m_Pos.z / 16);
	if (i < 0 || i >= 192 || j < 0 || j >= 192)
		return;

	auto fromChunkPos = std::find(g_chunkObjectMap[i][j].begin(), g_chunkObjectMap[i][j].end(), object);
	if (fromChunkPos != g_chunkObjectMap[i][j].end())
	{
		g_chunkObjectMap[i][j].erase(fromChunkPos);
	}
}

void AddObjectToInventory(int objectId, int containerId)
{
	U7Object* object = GetObjectFromID(objectId);
	U7Object* container = GetObjectFromID(containerId);

	if (object == nullptr || container == nullptr)
	{
		return;
	}

	container->AddObjectToInventory(objectId);
}

//////////////////////////////////////////////////////////////////////////////
//  CSV PARSING
//////////////////////////////////////////////////////////////////////////////
std::vector<size_t> findUnquotedCommas(const std::string& line) {
	std::vector<size_t> positions;
	bool inQuotes = false;

	for (size_t i = 0; i < line.size(); ++i) {
		char c = line[i];
		if (c == '"') {
			// Handle escaped quotes ("") inside a quoted field
			if (inQuotes && i + 1 < line.size() && line[i + 1] == '"') {
				++i; // skip the second quote of the pair
			}
			else {
				inQuotes = !inQuotes;
			}
		}
		else if (c == ',' && !inQuotes) {
			positions.push_back(i);
		}
	}
	return positions;
}

//////////////////////////////////////////////////////////////////////////////
//  CONSOLE
//////////////////////////////////////////////////////////////////////////////

std::vector<ConsoleString> g_ConsoleStrings;

void ClearConsole()
{
	g_ConsoleStrings.clear();
}

void AddConsoleString(std::string string, Color color, float starttime)
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
	temp.m_StartTime = GetTime();

	g_ConsoleStrings.push_back(temp);
	cout << string << endl;
}

void SaveShapeTable()
{
	std::ofstream file("Data/shapetable.dat", std::ios::trunc);
	if (file.is_open())
	{
		for (int i = 150; i < 1024; ++i)
		{
			for (int j = 0; j < 32; ++j)
			{
				g_shapeTable[i][j].Serialize(file);
			}
		}
		file.close();
	}
	AddConsoleString("Saved shapetable.dat successfully!", GREEN);
}

void AnalyzeGlobalObjectList()
{
	int staticObjects = 0;
	int npcObjects = 0;
	int nonStaticObjects = 0;
	int eggsAndTriggers = 0;
	for (auto& object : g_objectList)
	{
		if (object.second->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_STATIC)
			++staticObjects;
		else if (object.second->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC)
			++npcObjects;
		else if (object.second->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_OBJECT)
		{
			++nonStaticObjects;
			DebugPrint("Non-static object in IFIX: " + std::to_string(object.second->m_ObjectType));
		}
		else if (object.second->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_EGG)
			++eggsAndTriggers;
	}
	AddConsoleString("Total objects: " + std::to_string(g_objectList.size()), GREEN);
	AddConsoleString("Static objects: " + std::to_string(staticObjects), GREEN);
	AddConsoleString("NPC objects: " + std::to_string(npcObjects), GREEN);
	AddConsoleString("Non-static objects: " + std::to_string(nonStaticObjects), GREEN);
	AddConsoleString("Eggs and triggers: " + std::to_string(eggsAndTriggers), GREEN);

	DebugPrint("Total objects: " + std::to_string(g_objectList.size()));
	DebugPrint("Static objects: " + std::to_string(staticObjects));
	DebugPrint("NPC objects: " + std::to_string(npcObjects));
	DebugPrint("Non-static objects: " + std::to_string(nonStaticObjects));
	DebugPrint("Eggs and triggers: " + std::to_string(eggsAndTriggers));
}

void AnalyzeTrinsicObjectList()
{
	std::vector<U7Object*> statics;
	std::vector<U7Object*> npcs;
	std::vector<U7Object*> objects;
	std::vector<U7Object*> eggs;

	for (auto& unit : g_objectList)
	{
		if ( unit.second->m_Pos.x >= 944 && unit.second->m_Pos.x <= 1104 && unit.second->m_Pos.z >= 2096 && unit.second->m_Pos.z <= 2336 )
		{
			switch (unit.second->m_UnitType)
			{
				case U7Object::UnitTypes::UNIT_TYPE_STATIC:
				{
					// If we don't already have a static with this shape/frame in the list, add it to the list
					bool dupe = false;
					for (auto& staticObject : statics)
					{
						if ((staticObject->m_shapeData->m_shape == unit.second->m_shapeData->m_shape) && (staticObject->m_shapeData->m_frame == unit.second->m_shapeData->m_frame))
						{
							dupe = true;
						}
					}
					if (!dupe)
					{
						statics.push_back(unit.second.get());
					}
				}
					break;

				case U7Object::UnitTypes::UNIT_TYPE_NPC:
					npcs.push_back(unit.second.get());
					break;

				case U7Object::UnitTypes::UNIT_TYPE_OBJECT:
					for (auto& object : objects)
					{
						if (object->m_ObjectType == unit.second->m_ObjectType)
						{
							continue; // we already have one of these in the list.
						}
					}
					objects.push_back(unit.second.get());
					break;

				case U7Object::UnitTypes::UNIT_TYPE_EGG:
					eggs.push_back(unit.second.get());
					break;
			}
		}
	}

	std::sort(statics.begin(), statics.end(),
	[](const U7Object* a, const U7Object* b)
	{
		return (a->m_shapeData->m_shape != b->m_shapeData->m_shape)
			? (a->m_shapeData->m_shape < b->m_shapeData->m_shape)
			: (a->m_shapeData->m_frame < b->m_shapeData->m_frame);
	});

	DebugPrint("Total objects: " + to_string(g_objectList.size()));

	for (auto& staticObject : statics)
	{
		DebugPrint("Static: " + g_objectDataTable[staticObject->m_shapeData->m_shape].m_name + " " + to_string(staticObject->m_shapeData->m_shape) + " " + to_string(staticObject->m_shapeData->m_frame));
	}

	DebugPrint("NPCs: " + to_string(npcs.size()));

	for (auto& npc : npcs)
	{
		DebugPrint("NPC: " + std::string(g_NPCData[npc->m_NPCID]->name));
	}

	DebugPrint("Objects: " + to_string(objects.size()));

	std::sort(objects.begin(), objects.end(),
	[](const U7Object* a, const U7Object* b)
	{
		return (a->m_shapeData->m_shape != b->m_shapeData->m_shape)
			? (a->m_shapeData->m_shape < b->m_shapeData->m_shape)
			: (a->m_shapeData->m_frame < b->m_shapeData->m_frame);
	});

	for (auto& object : objects)
	{
		DebugPrint("Object: " + g_objectDataTable[object->m_ObjectType].m_name  + " " + to_string(object->m_shapeData->m_shape) + " " + to_string(object->m_shapeData->m_frame));
	}

	DebugPrint("Eggs: " + to_string(eggs.size()));

}
void DrawWorld()
{
	// Legacy entry point — same path as MainState / overlays.
	BeginMode3D(g_camera);
	DrawGameWorld(true);
	EndMode3D();
}
void DrawConsole()
{
	int counter = 0;
	vector<ConsoleString>::iterator node = g_ConsoleStrings.begin();
	float shadowOffset = 1;
	if (shadowOffset < 1)
	{
		shadowOffset = 1;
	}
	for (node; node != g_ConsoleStrings.end(); ++node)
	{
		float elapsed = GetTime() - (*node).m_StartTime;
		if (elapsed > 9)
		{
			float alpha = float(9 - elapsed);
			if (alpha == 1.0f)
			{
				alpha = 0;
			}
			(*node).m_Color.a = alpha * 255;
		}

		if (elapsed < 10)
		{
			DrawOutlinedText(g_SmallFont, (*node).m_String.c_str(), Vector2{ 0, float(counter * (g_SmallFont->baseSize + 2)) }, g_SmallFont->baseSize, 1, (*node).m_Color);

		}
		++counter;
	}

	node = g_ConsoleStrings.begin();
	for (node; node != g_ConsoleStrings.end();)
	{
		if (GetTime() - (*node).m_StartTime > 10)
		{
			node = g_ConsoleStrings.erase(node);
		}
		else
		{
			++node;
		}
	}
}

void DrawOutlinedText(std::shared_ptr<Font> font, const std::string& text, Vector2 position, float fontSize, int spacing, Color color)
{
	DrawTextEx(*font, text.c_str(), Vector2{ position.x + 1, position.y + 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x, position.y + 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x - 1, position.y - 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x, position.y - 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x + 1, position.y - 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x + 1, position.y }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x - 1, position.y + 1 }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), Vector2{ position.x - 1, position.y }, fontSize, spacing, Color{ 0, 0, 0, color.a });
	DrawTextEx(*font, text.c_str(), position, fontSize, spacing, color);
}

void DrawParagraph(std::shared_ptr<Font> font, const std::string& text, Vector2 position, float maxwidth, float fontSize, int spacing, Color color, bool outlined)
{
	std::istringstream iss(text);
	std::string word;
	std::vector<std::string> lines;
	float lineWidth = 0;

	string rawline;
	string line;
	while (getline(iss, rawline))
	{
		std::stringstream lineStream(rawline);
		while (lineStream >> word)
		{
			int currentLineWidth = MeasureTextEx(*font, (line + word).c_str(), fontSize, spacing).x;
			if (currentLineWidth > maxwidth)
			{
				lines.push_back(line);
				line.clear();
				line += word + " ";
			}
			else
			{
				line += word + " ";
			}
		}

		lines.push_back(line);

		line.clear();
	}

	auto it = lines.begin();
	float y = position.y;
	while (it != lines.end())
	{
		if (outlined)
		{
			DrawOutlinedText(font, (*it).c_str(), Vector2{ position.x, y }, fontSize, spacing, color);
		}
		else
		{
			DrawTextEx(*font, (*it).c_str(), Vector2{ position.x, y }, fontSize, spacing, color);
		}
		y += fontSize * 1.2f;
		++it;
	}
}


void AddObjectToContainer(int objectID, int containerID)
{
	U7Object* object = GetObjectFromID(objectID);
	U7Object* container = GetObjectFromID(containerID);

	if (object == nullptr || container == nullptr)
	{
		Log("AddObjectToContainer ERROR: object=" + std::to_string(objectID) + " is " + (object ? "valid" : "NULL") +
			", container=" + std::to_string(containerID) + " is " + (container ? "valid" : "NULL"));
		return;
	}

	bool success = container->AddObjectToInventory(objectID);

	// Debug: Log inventory addition
	static int addCount = 0;
	if (addCount < 30)
	{
		Log("AddObjectToContainer: Added object " + std::to_string(objectID) + " to container " + std::to_string(containerID) +
			" (success=" + std::string(success ? "true" : "false") + ", inventory size now=" + std::to_string(container->m_inventory.size()) + ")");
		addCount++;
	}

	// Objects in containers are not in world chunks
	UnassignObjectChunk(object);
}

extern float g_DrawScale; // Defined in StateMachine.cpp

std::shared_ptr<Sprite> g_BoxTL;
std::shared_ptr<Sprite> g_BoxT;
std::shared_ptr<Sprite> g_BoxTR;
std::shared_ptr<Sprite> g_BoxL;
std::shared_ptr<Sprite> g_BoxC;
std::shared_ptr<Sprite> g_BoxR;
std::shared_ptr<Sprite> g_BoxBL;
std::shared_ptr<Sprite> g_BoxB;
std::shared_ptr<Sprite> g_BoxBR;

std::vector<std::shared_ptr<Sprite> > g_Borders;
std::vector<std::shared_ptr<Sprite> > g_ConversationBorders;

shared_ptr<Sprite> g_InactiveButtonL;
shared_ptr<Sprite> g_InactiveButtonM;
shared_ptr<Sprite> g_InactiveButtonR;
shared_ptr<Sprite> g_ActiveButtonL;
shared_ptr<Sprite> g_ActiveButtonM;
shared_ptr<Sprite> g_ActiveButtonR;

shared_ptr<Sprite> g_ShapeButtonL;
shared_ptr<Sprite> g_ShapeButtonM;
shared_ptr<Sprite> g_ShapeButtonR;

shared_ptr<Sprite> g_LeftArrow;
shared_ptr<Sprite> g_RightArrow;

shared_ptr<Sprite> g_gumpBackground;
shared_ptr<Sprite> g_gumpCheckmarkUp;
shared_ptr<Sprite> g_gumpCheckmarkDown;

shared_ptr<Sprite> g_GitHubButton;
shared_ptr<Sprite> g_XButton;
shared_ptr<Sprite> g_YouTubeButton;
shared_ptr<Sprite> g_PatreonButton;
shared_ptr<Sprite> g_KoFiButton;

shared_ptr<Sprite> g_gumpNumberBarBackground;
shared_ptr<Sprite> g_gumpNumberBarMarker;
shared_ptr<Sprite> g_gumpNumberBarRightArrow;
shared_ptr<Sprite> g_gumpNumberBarLeftArrow;


shared_ptr<Texture2D> g_statsBackground;

Camera g_camera = { 0 };

bool g_hasCameraChanged = true;

EngineModes g_engineMode = EngineModes::ENGINE_MODE_BLACK_GATE;

std::string g_engineModeStrings[] = { "blackgate", "serpentisle", "NONE" };

void OpenURL(const std::string& url)
{
#ifdef __linux__
	std::string command = "xdg-open " + url;
#elif _WIN32
	std::string command = "start " + url;
#elif __APPLE__
	std::string command = "open " + url;
#else
	return; // Unsupported platform
#endif
	std::system(command.c_str());
}

// Pathfinding grid update notification
void NotifyPathfindingGridUpdate(int worldX, int worldZ, int radius)
{
	// No longer needed - tile-based pathfinding checks walkability dynamically during A* search
	// Keeping this function as a no-op to avoid breaking existing code
}

#ifdef DEBUG_NPC_PATHFINDING
void PrintNPCPathStats()
{
	if (g_npcMaxPathStats.empty())
	{
		AddConsoleString("No NPC pathfinding stats collected yet.", YELLOW);
		return;
	}

	// Convert to vector for sorting
	std::vector<NPCPathStats> stats;
	stats.reserve(g_npcMaxPathStats.size());
	for (const auto& pair : g_npcMaxPathStats)
	{
		stats.push_back(pair.second);
	}

	// Sort by distance (longest first)
	std::sort(stats.begin(), stats.end(), [](const NPCPathStats& a, const NPCPathStats& b) {
		return a.distance > b.distance;
	});

	// Print header
	AddConsoleString("=== NPC Longest Pathfinding Routes (sorted by distance) ===", SKYBLUE);
	AddConsoleString("Total NPCs tracked: " + std::to_string(stats.size()), SKYBLUE);

	// Print each NPC's longest path
	for (const auto& stat : stats)
	{
		std::string msg = "NPC " + std::to_string(stat.npcID) +
			": Distance=" + std::to_string((int)stat.distance) + " tiles" +
			", Waypoints=" + std::to_string(stat.waypointCount) +
			", From=(" + std::to_string((int)stat.startPos.x) + "," + std::to_string((int)stat.startPos.z) + ")" +
			" To=(" + std::to_string((int)stat.endPos.x) + "," + std::to_string((int)stat.endPos.z) + ")";
		AddConsoleString(msg, WHITE);
	}

	AddConsoleString("=== End of NPC Path Stats ===", SKYBLUE);
}
#endif


// int l_add_dialogue(lua_State* L)
// {
// 	const char* message = luaL_checkstring(L, 1);
// 	printf("Lua says: %s\n", message);
// 	return 0;
// }

// Helper function to parse U7 text format: "a/<singular>//<plural>/s"
// Returns singular or plural with quantity
std::string ParseU7TextFormat(const std::string& rawText, int quantity)
{
	// Format can be:
	// "bread" - no slashes, just a name
	// "a/garlic//s" - article/singular_name/middle_part/plural_suffix
	// "/kni/fe/ves" - /prefix/suffix/plural_ending (for knife/knives)

	size_t firstSlash = rawText.find('/');
	if (firstSlash == std::string::npos)
	{
		// No slashes means no U7 text format, just return the name as-is without quantity
		return rawText;
	}

	// Find the second slash
	size_t secondSlash = rawText.find('/', firstSlash + 1);
	if (secondSlash == std::string::npos)
	{
		// Malformed, return as-is
		return rawText;
	}

	// Get the article (before first slash)
	std::string article = rawText.substr(0, firstSlash);

	// Get the first part (between 1st and 2nd slash)
	std::string firstPart = rawText.substr(firstSlash + 1, secondSlash - firstSlash - 1);

	// Find the third slash
	size_t thirdSlash = rawText.find('/', secondSlash + 1);

	// Check if there's content between 2nd and 3rd slash (middle part exists)
	bool hasMiddlePart = (thirdSlash != std::string::npos) && (thirdSlash > secondSlash + 1);

	std::string singularName;
	std::string pluralName;

	if (hasMiddlePart)
	{
		// Format: article/prefix/suffix/plural_ending (e.g., "/kni/fe/ves")
		std::string prefix = firstPart;
		std::string suffix = rawText.substr(secondSlash + 1, thirdSlash - secondSlash - 1);
		std::string pluralEnding = rawText.substr(thirdSlash + 1);

		singularName = prefix + suffix;  // "kni" + "fe" = "knife"
		pluralName = prefix + pluralEnding;  // "kni" + "ves" = "knives"
	}
	else
	{
		// Format: article/singular_name//plural_suffix (e.g., "a/garlic//s")
		singularName = firstPart;
		std::string pluralSuffix = "";
		if (thirdSlash != std::string::npos && thirdSlash + 1 < rawText.length())
		{
			pluralSuffix = rawText.substr(thirdSlash + 1);
		}
		pluralName = singularName + pluralSuffix;  // "garlic" + "s" = "garlics"
	}

	if (quantity == 1)
	{
		// Only add article if it's not empty and not just whitespace
		if (!article.empty() && article.find_first_not_of(" \t") != std::string::npos)
			return article + " " + singularName;
		else
			return singularName;
	}
	else
	{
		// Plural: quantity + plural name
		if (quantity > 0)
			return std::to_string(quantity) + " " + pluralName;
		else
			return singularName; // quantity 0 or invalid, just show the name
	}
}

std::string GetShapeFrameName(int shape, int frame, int quantity)
{
	// Check if misc_names are loaded yet
	if (!g_miscNames.empty())
	{
		// Shape 842: Reagents (8 frames)
		if (shape == 842 && frame >= 0 && frame < 8)
		{
			// Reagents: frames 0-7 map to misc_names 256-263
			// (black pearl, blood moss, nightshade, mandrake, garlic, ginseng, spider silk, sulfurous ash)
			int miscIndex = 256 + frame;
			if (miscIndex < g_miscNames.size())
			{
				return ParseU7TextFormat(g_miscNames[miscIndex], quantity);
			}
		}

		// Shape 377: Food items (32 frames)
		if (shape == 377 && frame >= 0 && frame < 32)
		{
			// Food items: frames 0-31 map to misc_names 267-298
			// (bread, bread, rolls, fruitcake, cake, pie, pastry, sausage, mutton, beef, fowl, etc.)
			int miscIndex = 267 + frame;
			if (miscIndex < g_miscNames.size())
			{
				return ParseU7TextFormat(g_miscNames[miscIndex], quantity);
			}
		}

		// Shape 675: Desk items (21 frames)
		if (shape == 675 && frame >= 0 && frame < 21)
		{
			// Desk items: frames 0-20 map to misc_names 301-321
			int miscIndex = 301 + frame;
			if (miscIndex < g_miscNames.size())
			{
				return ParseU7TextFormat(g_miscNames[miscIndex], quantity);
			}
		}

		// TODO: Shape 863: Kitchen items - need to find correct misc_names mapping from Exult
	}

	// Fall back to shape name if no frame-specific name found
	// Still parse it to handle the "a/name//s" format
	if (shape >= 0 && shape < 1024)
	{
		std::string shapeName = g_objectDataTable[shape].m_name;
		if (!shapeName.empty())
		{
			return ParseU7TextFormat(shapeName, quantity);
		}
	}

	return "unknown";
}

std::string GetObjectDisplayName(U7Object* object)
{
	if (!object || !object->m_shapeData)
		return "Unknown";

	int shape = object->m_shapeData->GetShape();
	
	// Calculate quantity correctly for stackable items
	// For stackable items (shape type 3), quality field lower 7 bits = quantity
	// High bit (0x80) is used for other flags and must be masked off
	int quantity = 1;
	char shapeType = (shape >= 0 && shape < 1024) ? g_objectDataTable[shape].m_shapeType : 0;
	
	// Check shape type from global table
	if (shapeType == 3)
	{
		quantity = object->m_Quality & 0x7f;
		if (quantity == 0) quantity = 1;
	}

	return GetShapeFrameName(shape, object->m_shapeData->GetFrame(), quantity);
}

std::string FindNPCScriptByID(int npcID)
{
	// Format NPC ID as 4-digit hex suffix: _XXXX
	stringstream ss;
	ss << std::setfill('0') << std::setw(4) << npcID;
	string suffix = "_" + ss.str();

	// Search for script ending with this suffix that starts with "npc_"
	for (int i = 0; i < g_ScriptingSystem->m_scriptFiles.size(); ++i)
	{
		const string& name = g_ScriptingSystem->m_scriptFiles[i].first;

		// Check if name starts with "npc_" and ends with the suffix
		if (name.length() >= 4 + suffix.length() &&
			name.substr(0, 4) == "npc_" &&
			name.compare(name.length() - suffix.length(), suffix.length(), suffix) == 0)
		{
			return name;
		}
	}

	return "";  // No matching NPC script found
}

std::string GetObjectScriptName(U7Object* object)
{
	if (!object)
		return "";

	// NPCs with conversation trees use NPC ID-based scripts
	if (object->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC && object->m_hasConversationTree)
	{
		return FindNPCScriptByID(object->m_NPCID);
	}
	// Regular objects use shape table scripts
	else
	{
		int shape = object->m_shapeData->GetShape();
		int frame = object->m_shapeData->GetFrame();
		if (shape < g_shapeTable.size() && frame < g_shapeTable[shape].size())
		{
			const std::string& scriptName = g_shapeTable[shape][frame].m_luaScript;
			if (!scriptName.empty() && scriptName != "default")
			{
				return scriptName;
			}
		}
	}

	return "";  // No script or using default
}

// Equipment slot configuration loaded from slots.json
static std::map<int, std::vector<EquipmentSlot>> g_equipmentSlotMap;      // Valid slots item can be placed in
static std::map<int, std::vector<EquipmentSlot>> g_equipmentSlotFillsMap; // All slots item occupies when equipped

// String to EquipmentSlot enum conversion
static EquipmentSlot StringToEquipmentSlot(const std::string& slotName)
{
	if (slotName == "SLOT_HEAD") return EquipmentSlot::SLOT_HEAD;
	if (slotName == "SLOT_NECK") return EquipmentSlot::SLOT_NECK;
	if (slotName == "SLOT_TORSO") return EquipmentSlot::SLOT_TORSO;
	if (slotName == "SLOT_LEGS") return EquipmentSlot::SLOT_LEGS;
	if (slotName == "SLOT_HANDS") return EquipmentSlot::SLOT_HANDS;
	if (slotName == "SLOT_FEET") return EquipmentSlot::SLOT_FEET;
	if (slotName == "SLOT_LEFT_HAND") return EquipmentSlot::SLOT_LEFT_HAND;
	if (slotName == "SLOT_RIGHT_HAND") return EquipmentSlot::SLOT_RIGHT_HAND;
	if (slotName == "SLOT_AMMO") return EquipmentSlot::SLOT_AMMO;
	if (slotName == "SLOT_LEFT_RING") return EquipmentSlot::SLOT_LEFT_RING;
	if (slotName == "SLOT_RIGHT_RING") return EquipmentSlot::SLOT_RIGHT_RING;
	if (slotName == "SLOT_BELT") return EquipmentSlot::SLOT_BELT;
	if (slotName == "SLOT_BACKPACK") return EquipmentSlot::SLOT_BACKPACK;
	return EquipmentSlot::SLOT_COUNT;
}

// Load equipment slot configuration from Data/equip_slots.json
void LoadEquipmentSlotsConfig()
{
	g_equipmentSlotMap.clear();
	g_equipmentSlotFillsMap.clear();

	std::string configPath = "Data/equip_slots.json";

	std::ifstream file(configPath);
	if (!file.is_open())
	{
		Log("ERROR: Could not open " + configPath);
		return;
	}

	try
	{
		nlohmann::json config;
		file >> config;

		// New format: root object is a map of shape_id (as string) to item data
		if (config.is_object())
		{
			for (auto& [shapeIdStr, item] : config.items())
			{
				// Convert string key to int
				int shapeId = std::stoi(shapeIdStr);

				if (item.contains("slots") && item["slots"].is_array())
				{
					std::vector<EquipmentSlot> validSlots;

					// Load valid slots (where item can be placed)
					for (const auto& slotName : item["slots"])
					{
						EquipmentSlot slot = StringToEquipmentSlot(slotName.get<std::string>());
						if (slot != EquipmentSlot::SLOT_COUNT)
						{
							validSlots.push_back(slot);
						}
					}

					if (!validSlots.empty())
					{
						g_equipmentSlotMap[shapeId] = validSlots;
					}

					// Load fills (all slots occupied when equipped)
					if (item.contains("fills") && item["fills"].is_array())
					{
						std::vector<EquipmentSlot> fillSlots;
						for (const auto& slotName : item["fills"])
						{
							EquipmentSlot slot = StringToEquipmentSlot(slotName.get<std::string>());
							if (slot != EquipmentSlot::SLOT_COUNT)
							{
								fillSlots.push_back(slot);
							}
						}
						if (!fillSlots.empty())
						{
							g_equipmentSlotFillsMap[shapeId] = fillSlots;
						}
					}
				}
			}
		}

		Log("Loaded equipment slot configuration for " + std::to_string(g_equipmentSlotMap.size()) + " item types");
	}
	catch (const std::exception& e)
	{
		Log("ERROR: Failed to parse " + configPath + ": " + e.what());
	}
}

// Returns all valid equipment slots for an item shape ID
std::vector<EquipmentSlot> GetEquipmentSlotsForShape(int shapeId)
{
	auto it = g_equipmentSlotMap.find(shapeId);
	if (it != g_equipmentSlotMap.end())
	{
		return it->second;
	}
	return {}; // Empty vector if not equippable
}

// Returns all slots this item occupies when equipped (may be multiple)
std::vector<EquipmentSlot> GetEquipmentSlotsFilled(int shapeId)
{
	auto it = g_equipmentSlotFillsMap.find(shapeId);
	if (it != g_equipmentSlotFillsMap.end())
	{
		return it->second;
	}
	return {}; // Empty vector if not equippable
}

// Deprecated: Returns only the first valid equipment slot for an item
// Use GetEquipmentSlotsForShape() for items that can go in multiple slots
EquipmentSlot GetEquipmentSlotForShape(int shapeId)
{
	auto slots = GetEquipmentSlotsForShape(shapeId);
	if (!slots.empty())
	{
		return slots[0];
	}
	return EquipmentSlot::SLOT_COUNT;
}

// NPCData equipment management implementations
void NPCData::SetEquippedItem(EquipmentSlot slot, int objectId)
{
	m_equipment[slot] = objectId;

	// Add to NPC's inventory if not already there, or invalidate cache if it is
	U7Object* npcObject = g_objectList[m_objectID].get();
	if (npcObject)
	{
		if (!npcObject->IsInInventoryById(objectId))
		{
			npcObject->AddObjectToInventory(objectId);
		}
		else
		{
			// Item already in inventory, just invalidate weight cache
			npcObject->InvalidateWeightCache();
		}
	}
}

void NPCData::UnequipItem(EquipmentSlot slot)
{
	int objectId = GetEquippedItem(slot);
	m_equipment[slot] = -1;

	// Remove from NPC's inventory
	if (objectId != -1)
	{
		U7Object* npcObject = g_objectList[m_objectID].get();
		if (npcObject)
		{
			npcObject->RemoveObjectFromInventory(objectId);
		}
	}
}

//////////////////////////////////////////////////////////////////////////////
//  SPELL SYSTEM
//////////////////////////////////////////////////////////////////////////////

void LoadSpellData()
{
	static bool s_spellDataLoaded = false;

	if (s_spellDataLoaded)
	{
		Log("LoadSpellData: Spell data already loaded, skipping reload.");
		return;
	}

	Log("Loading spell data from spells.json...");

	// Clear existing data
	g_reagentData.clear();
	g_spellCircles.clear();
	g_spellMap.clear();

	// Open spells.json
	std::string spellDataPath = "Data/spells.json";
	std::ifstream file(spellDataPath);

	if (!file.is_open())
	{
		Log("ERROR: Could not open " + spellDataPath);
		AddConsoleString("ERROR: Could not open " + spellDataPath, RED);
		return;
	}

	try
	{
		nlohmann::json spellJson;
		file >> spellJson;

		// Load reagents
		if (spellJson.contains("reagents") && spellJson["reagents"].is_array())
		{
			for (const auto& reagentJson : spellJson["reagents"])
			{
				ReagentData reagent;
				reagent.name = reagentJson["name"].get<std::string>();
				reagent.frame = reagentJson["frame"].get<int>();
				g_reagentData.push_back(reagent);
			}
			Log("Loaded " + std::to_string(g_reagentData.size()) + " reagents");
		}

		// Load spell circles
		if (spellJson.contains("circles") && spellJson["circles"].is_array())
		{
			for (const auto& circleJson : spellJson["circles"])
			{
				SpellCircle circle;
				circle.circle = circleJson["circle"].get<int>();
				circle.name = circleJson["name"].get<std::string>();

				// Load spells in this circle
				if (circleJson.contains("spells") && circleJson["spells"].is_array())
				{
					for (const auto& spellJson : circleJson["spells"])
					{
						SpellData spell;
						spell.id = spellJson["id"].get<int>();
						spell.name = spellJson["name"].get<std::string>();
						spell.x = spellJson["x"].get<int>();
						spell.y = spellJson["y"].get<int>();
						spell.words = spellJson["words"].get<std::string>();
						spell.scriptId = spellJson["scriptId"].get<int>();
						spell.circle = circle.circle;

						// Load reagents
						if (spellJson.contains("reagents") && spellJson["reagents"].is_array())
						{
							for (const auto& reagentName : spellJson["reagents"])
							{
								spell.reagents.push_back(reagentName.get<std::string>());
							}
						}

						// Load description
						if (spellJson.contains("desc"))
						{
							spell.desc = spellJson["desc"].get<std::string>();
						}

						circle.spells.push_back(spell);
					}
				}

				g_spellCircles.push_back(circle);
			}
			Log("Loaded " + std::to_string(g_spellCircles.size()) + " spell circles");
		}

		// Build spell lookup map
		for (auto& circle : g_spellCircles)
		{
			for (auto& spell : circle.spells)
			{
				g_spellMap[spell.id] = &spell;
			}
		}
		Log("Built spell lookup map with " + std::to_string(g_spellMap.size()) + " spells");
		AddConsoleString("Loaded " + std::to_string(g_spellMap.size()) + " spells from spells.json", GREEN);

		s_spellDataLoaded = true;
	}
	catch (const std::exception& e)
	{
		Log("ERROR: Exception while loading spell data: " + std::string(e.what()));
		AddConsoleString("ERROR: Exception while loading spell data", RED);
	}

	file.close();
}

bool IsDistanceLessThan(float startX, float startZ, float endX, float endZ, float range);

SpellData* GetSpellData(int spellId)
{
	auto it = g_spellMap.find(spellId);
	if (it != g_spellMap.end())
	{
		return it->second;
	}
	return nullptr;
}

std::array<int, 1024> g_isObjectMoveable =
	{
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 0-15
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 16-31
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 32-47
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 48-63
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 64-79
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 80-95
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 96-111
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 112-127
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 128-143
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1, // 144-159
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 160-175
	0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0, // 176-191
	0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0, // 192-207
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 208-223
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 224-239
	0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0, // 240-255
	0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0, // 256-271
	0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0, // 272-287
	0,0,0,0,0,0,0,1,1,1,1,0,1,1,1,0, // 288-303
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 304-319
	0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0, // 320-335
	1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0, // 336-351
	0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 352-367
	0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1, // 368-383
	0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0, // 384-399
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1, // 400-415
	0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 416-431
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 432-447
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, //	448-463
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 464-479
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 480-495
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 496-511
	0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0, // 512-527
	0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,1, // 528-543
	0,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1, // 544-559
	1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1, // 560-575
	1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1, // 576-591
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0, // 592-607
	1,1,0,0,0,0,1,1,1,1,0,0,0,1,1,1, // 608-623
	1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,0, // 624-639
	1,1,1,0,1,1,1,1,1,1,1,0,0,0,1,0, // 640-655
	0,0,1,1,0,0,1,1,0,0,1,0,1,0,0,0, // 656-671
	0,0,0,1,0,1,0,0,0,1,1,0,0,0,1,0, // 672-687
	0,0,0,1,1,1,0,0,0,0,1,0,0,0,0,1, // 688-703
	1,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0, // 704-719
	0,0,1,1,0,0,1,0,1,1,1,0,0,0,0,0, // 720-735
	0,0,1,0,0,0,1,0,0,0,1,1,0,1,0,0, // 736-751
	1,0,1,0,1,0,0,1,1,1,0,0,0,0,0,1, // 752-767
	0,1,1,1,1,0,0,0,0,0,0,0,0,0,1,0, // 768-783
	0,1,1,0,0,0,1,0,1,0,0,0,0,1,1,1, // 784-799
	1,1,1,1,1,0,0,0,0,0,1,0,0,0,0,1, // 800-815
	0,0,0,0,0,0,1,1,1,0,0,1,0,0,0,0, // 816-831
	0,0,0,1,1,0,1,1,0,0,1,1,0,0,0,0, // 832-847
	0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1, // 848-863
	1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0, // 864-879
	0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0, // 880-895
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 896-911
	0,0,1,1,1,0,0,0,0,1,0,0,0,0,0,0, // 912-927
	0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0, // 928-943
	1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0, // 944-959
	0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0, // 960-975
	0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1, // 976-991
	0,0,1,0,0,1,1,0,0,0,0,0,1,0,0,0, // 992-1007
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  // 1008-1023
};


bool g_firstPersonEnabled = false;
float g_firstPersonHeight = DEFAULT_FIRSTPERSON_HEIGHT;   // eye height above avatar center (tweak)
float g_firstPersonFOV = 60.0f;
float g_firstPersonYaw = 0.0f;
float g_firstPersonPitch = DEFAULT_FIRSTPERSON_PITCH;
float g_firstPersonMoveSpeed = 5.0f; // units per second
bool g_firstPersonPreserveCenter = false;
Vector3 g_firstPersonFocus = { 0.0f, 0.0f, 0.0f };

// -----------------------------------------------------------------------------
// Serialize m_flags to a JSON object
// -----------------------------------------------------------------------------
nlohmann::json SaveGameFlagsToJson(const std::unordered_map<int, bool>& flags)
{
	nlohmann::json j = nlohmann::json::object();

	for (const auto& [key, value] : flags)
	{
		j[std::to_string(key)] = value;
	}

	return j;
}

// -----------------------------------------------------------------------------
// Load m_flags from a JSON object
// -----------------------------------------------------------------------------
void LoadGameFlagsFromJson(std::unordered_map<int, bool>& flags, const nlohmann::json& j)
{
	// Clear existing flags to avoid leftovers
	flags.clear();

	if (!j.is_object())
	{
		// Optional: log error or throw
		return;
	}

	for (auto& [keyStr, val] : j.items())
	{
		try
		{
			int key = std::stoi(keyStr);
			bool value = val.get<bool>();
			flags[key] = value;
		}
		catch (const std::exception&)
		{
			// Skip invalid entries (malformed key or non-bool value)
			// Optional: log warning
		}
	}
}

void DrawPerfCounter(Font* font, int loc)
{
	int vpos = 0;
	int hpos = 0;
	int width = g_Engine->m_RenderWidth * .20f;
	int height = g_Engine->m_RenderHeight * .20f;
	switch (loc)
	{
		case 0: // Bottom-left
			hpos = 0;
			vpos = g_Engine->m_RenderHeight - height;
			break;
		case 1: // Top-left
			hpos = 0;
			vpos = 0;
			break;
		case 2: // Bottom-right
			hpos = g_Engine->m_RenderWidth - width;
			vpos = g_Engine->m_RenderHeight - height;
			break;
		case 3: // Top-right
			hpos = g_Engine->m_RenderWidth - width;
			vpos = 0;
			break;
	}
	DrawRectangle(hpos, vpos, width, height, BLACK);
	DrawRectangleLines(hpos, vpos, width, height, BLUE);

	string perf_temp = to_string(int(1.0f / g_Engine->LastFrameInSeconds())) + " fps (" + to_string(int(g_Engine->LastFrameInSeconds() * 1000.0f)) + " mspf)";
	DrawTextEx(*font, perf_temp.c_str(), {hpos + (width * .05f), vpos + height - (font->baseSize * 1.01f)}, font->baseSize, 1, WHITE);
	// if (font)
	// {
	// 	DrawTextEx(*font, perf_temp.c_str(), {hpos + (width * .05f), vpos + height - (font->baseSize * 1.01f)}, font->baseSize, 1, WHITE);
	// }
	DrawTextEx(*font, "Draw", {hpos + (width * .05f), g_Engine->m_RenderHeight * .95f}, font->baseSize, 1, GREEN);
	DrawTextEx(*font, "Update", {hpos + (width * .3f), g_Engine->m_RenderHeight * .95f}, font->baseSize, 1,  YELLOW);
	DrawTextEx(*font, "Network", {hpos + (width * .65f), g_Engine->m_RenderHeight * .95f}, font->baseSize, 1, BLUE);
	int perf_i;
	for (perf_i = 0; perf_i < 50 - 1; perf_i++)
	{
		int h = std::max(1, int(g_Engine->m_UpdateFrames[perf_i]));
		int h2 = std::max(1, int(g_Engine->m_DrawFrames[perf_i]));
		DrawRectangle(hpos + 4 + (perf_i * 2), int(g_Engine->m_RenderHeight * .94f) - h, 2, h, YELLOW);
		DrawRectangle(hpos + 4 + (perf_i * 2), int(g_Engine->m_RenderHeight * .94f) - (h + h2), 2, h2, GREEN);
	}
}
