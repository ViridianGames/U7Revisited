#ifndef _TERRAIN_H_
#define _TERRAIN_H_

#include "Geist/Globals.h"
#include "Geist/Primitives.h"
#include <string>
#include <array>
#include <cstdint>

// Visible ground patch size in world tiles (centered on camera target).
constexpr int TILEWIDTH = 100;
constexpr int TILEHEIGHT = 100;

class Terrain : public Object
{
public:
	int m_width = 3072;
	int m_height = 3072;

	// Per-cell lighting for the current camera-centered patch (object draw samples this).
	Color m_cellLighting[TILEWIDTH][TILEHEIGHT];

	Model m_cellModel{};
	Mesh m_cellMesh{};

	Texture m_terrainTiles{};
	RenderTexture m_currentTerrain{};

	// Full terrain atlas kept on CPU so palette-cycling water pixels can be recolored.
	Image m_terrainColorImage = { 0 };
	Image m_terrainIndexImage = { 0 };
	bool m_terrainHasPaletteAnim = false;
	int m_lastTerrainPaletteStep = -1;

	Terrain();
	virtual ~Terrain();

	virtual void Init() override;
	virtual void Init(const std::string& data) override {}
	virtual void Shutdown();
	virtual void Update() override;
	virtual void Draw() override;

	// Force next Update() to rebuild lighting + ground RT (e.g. after atlas load).
	void MarkDirty();

	void CalculateLighting();
	void UpdateTerrainTexture(Image img);
	void SetTerrainIndexImage(Image indexImage);

	// Recolor water/fire pixels in the terrain atlas from the runtime palette LUT.
	// Marks the ground RT dirty when the atlas actually changes.
	void ApplyPaletteToTerrainAtlas();

	void UpdateTerrainTiles();

	void SetupChunkData();

	// Perf counters (reset by MainState telemetry each second).
	int m_rebuildsThisSecond = 0;
	int m_skipsThisSecond = 0;
	double m_rebuildMsThisSecond = 0.0;
	const char* m_lastDirtyReason = "none";

private:
	// Dirty-flag state: rebuild only when inputs that affect the ground RT change.
	bool m_forceDirty = true;
	int m_cachedCenterTileX = 0x7fffffff;
	int m_cachedCenterTileZ = 0x7fffffff;
	Color m_cachedDayNightColor = { 0, 0, 0, 0 };
	bool m_cachedIsDay = true;
	bool m_cachedDungeonView = false;
	int m_cachedPaletteStep = -1;
	uint64_t m_cachedLightHash = 0;

	// Hash of nearby light sources (tile-rounded positions) for night dirty detection.
	uint64_t ComputeLightHash() const;
	static bool ColorsEqual(Color a, Color b);
};

#endif
