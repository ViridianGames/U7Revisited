//  Ultima VII's map consistes of 12x12 "superchunks", each of which is 16x16
//  "chunks".
//
//  A chunk consists of 16x16 cells.
//
//  So the world consists of a 192x192 map of chunks, each of which has 16x16
//  tiles.
//
//  Which means that there are 36,864 chunks in the map.  But there are only
//  3072 unique chunks, which means some are repeated as necessary.
//
//  So the first thing we need to do is create a mesh for each of the 3072
//  chunks.

#include <fstream>

#include "Geist/Config.h"
#include "Geist/Globals.h"
#include "Geist/RNG.h"
#include "Terrain.h"
#include "U7Globals.h"

using namespace std;

Terrain::Terrain() {
    m_height = 3072;
    m_width = 3072;
    m_terrainTexture = GenImageColor(2048, 256, Color{0, 0, 0, 0});
}

Terrain::~Terrain() { Shutdown(); }

void Terrain::Init() {
    // Create the chunk database

    //  Create a mesh for each chunk
    Mesh mesh = GenMeshPlane(16, 16, 1, 1);

    //  Move the mesh from the center to the corner
    for (int i = 0; i < mesh.vertexCount; ++i) {
        mesh.vertices[i * 3] += 8.0f;
        mesh.vertices[i * 3 + 2] += 8.0f;
    }

    UpdateMeshBuffer(mesh, 0, mesh.vertices,
                     sizeof(float) * mesh.vertexCount * 3, 0);

    unsigned short prevShape = 0;
    unsigned short prevFrame = 0;
    for (unsigned int i = 0; i < 3072; ++i) {
        m_chunkModels[i] = make_unique<Model>(LoadModelFromMesh(mesh));

        Image img = GenImageColor(128, 128, BLACK);
        for (int j = 0; j < 16; ++j) {
            for (int k = 0; k < 16; ++k) {
                unsigned short thisdata = g_ChunkTypeList[i][j][k];
                unsigned short shapenum = thisdata & 0x3ff;
                unsigned short framenum = (thisdata >> 10) & 0x1f;

                if (shapenum <= 150 && framenum < 32) {
                    ImageDraw(&img, m_terrainTexture,
                              Rectangle{shapenum * 8.0f, framenum * 8.0f, 8, 8},
                              Rectangle{k * 8.0f, j * 8.0f, 8, 8}, WHITE);
                    prevShape = shapenum;
                    prevFrame = framenum;
                } else {
                    ImageDraw(
                        &img, m_terrainTexture,
                        Rectangle{prevShape * 8.0f, prevFrame * 8.0f, 8, 8},
                        Rectangle{k * 8.0f, j * 8.0f, 8, 8}, WHITE);
                }
            }
        }

        Texture thisTexture = LoadTextureFromImage(img);
        SetTextureFilter(thisTexture, TEXTURE_FILTER_POINT);

        SetMaterialTexture(&m_chunkModels[i]->materials[0],
                           MATERIAL_MAP_DIFFUSE, thisTexture);

        UnloadImage(img);
    }
}

void Terrain::UpdateTerrainTexture(Image img) { m_terrainTexture = img; }

void Terrain::Draw() {
    int range = g_camera.fovy / 16 + 1;

    int chunkx = g_camera.target.x / 16;
    int chunky = g_camera.target.z / 16;

    for (int i = chunkx - range; i <= chunkx + range + 1; ++i) {
        for (int j = chunky - range; j <= chunky + range + 1; ++j) {
            if (i < 0 || i >= 192 || j < 0 || j >= 192) {
                continue;
            }

            DrawModel(*m_chunkModels[g_chunkTypeMap[i][j]],
                      {i * 16.0f, 0, j * 16.0f}, 1.0f, WHITE);
        }
    }
}

void Terrain::Shutdown() {}

bool Terrain::IsChunkVisible(int x, int y) { return false; }

void Terrain::Update() {
    if (g_CameraMoved) {
        FindVisibleChunks();
    }
}

void Terrain::FindVisibleChunks() { m_visibleChunks.clear(); }
