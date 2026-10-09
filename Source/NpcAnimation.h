#ifndef _NpcAnimation_H_
#define _NpcAnimation_H_

#include "raylib.h"
#include <array>
#include <vector>

// Ultima VII / Exult actor frame layout for default SHAPES.VGA NPCs and monsters.
// Within each facing block of 16 frames (low nibble = pose):
enum class NpcFramePose : int
{
	Standing = 0,
	StepRight = 1,
	StepLeft = 2,
	Ready = 3,
	Raise1 = 4,
	Reach1 = 5,
	Strike1 = 6,
	Raise2 = 7,
	Reach2 = 8,
	Strike2 = 9,
	Sit = 10,
	Bow = 11,
	Kneel = 12,
	Sleep = 13,
	Up = 14,
	Out = 15,
};

// Facing block bases added to NpcFramePose.
enum class NpcFrameFacing : int
{
	North = 0,   // frames 0–15
	South = 16,  // frames 16–31
	West = 32,   // frames 32–47
	East = 48,   // frames 48–63
};

enum class NpcAnimAction : int
{
	Stand = 0,
	Walk,
	Ready,
	Attack1H,
	Attack2H,
	Shoot,
	Cast,
	Kneel,
	Sit,
	Sleep,
	Up,
	Out,
	COUNT
};

// Pre-baked [action][dir8][phase] textures. Dir layout matches walk:
// 0=SW, 1=W, 2=NW, 3=N, 4=NE, 5=E, 6=SE, 7=S.
struct NpcActionTextures
{
	std::array<std::array<std::vector<Texture*>, 8>, static_cast<size_t>(NpcAnimAction::COUNT)> textures{};
	bool valid = false;
};

inline int NpcFrameIndex(NpcFrameFacing facing, NpcFramePose pose)
{
	return static_cast<int>(facing) + static_cast<int>(pose);
}

// Exult empty-frame substitutes within a 16-frame block (pose nibble).
int NpcVisiblePoseFrame(int poseNibble);

// Bake all action clips from SHAPES.VGA for shapenum.
bool FillNpcActionTextures(NpcActionTextures& out, int shapenum);

// Copy Walk action into the legacy [dir][phase] walk table (WalkSheet / old call sites).
void CopyWalkTexturesFromActions(const NpcActionTextures& actions,
                                 std::vector<std::vector<Texture*>>& outWalk);

Texture* GetNpcActionTexture(const NpcActionTextures& actions,
                               NpcAnimAction action, int dir8, int phase);

int GetNpcActionPhaseCount(const NpcActionTextures& actions, NpcAnimAction action, int dir8);

const char* NpcAnimActionName(NpcAnimAction action);

#endif
