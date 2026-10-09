#include "NpcAnimation.h"
#include "U7Globals.h"
#include "Geist/ResourceManager.h"

#include <string>

using namespace std;

namespace
{
	// Exult Actor::visible_frames — substitute when a pose frame is empty.
	constexpr int kVisibleFrames[16] = {
		0,  // standing
		0,  // step_right → standing
		0,  // step_left → standing
		0,  // ready → standing
		6,  // raise1 → strike1
		6,  // reach1 → strike1
		9,  // strike1 → strike2
		9,  // raise2 → strike2
		9,  // reach2 → strike2
		6,  // strike2 → strike1
		0,  // sit → standing
		0,  // bow → standing
		0,  // kneel → standing
		0,  // sleep → standing
		0,  // up → standing
		0,  // out → standing
	};

	bool HasShapeTexture(int shapenum, int frame)
	{
		// g_shapeTable is [1024][32] — only N (0–15) and S (16–31) blocks are loaded today.
		if (shapenum < 0 || shapenum >= 1024 || frame < 0 || frame >= 32)
			return false;
		return g_shapeTable[shapenum][frame].m_texture != nullptr;
	}

	Texture* ResolveShapeTexture(int shapenum, int facingBase, int poseNibble)
	{
		poseNibble &= 15;
		int frame = facingBase + poseNibble;
		if (HasShapeTexture(shapenum, frame))
			return &g_shapeTable[shapenum][frame].m_texture->m_Texture;

		const int altPose = NpcVisiblePoseFrame(poseNibble);
		frame = facingBase + altPose;
		if (HasShapeTexture(shapenum, frame))
			return &g_shapeTable[shapenum][frame].m_texture->m_Texture;

		// Last resort: standing in this facing, then standing north.
		if (HasShapeTexture(shapenum, facingBase + 0))
			return &g_shapeTable[shapenum][facingBase + 0].m_texture->m_Texture;
		if (HasShapeTexture(shapenum, 0))
			return &g_shapeTable[shapenum][0].m_texture->m_Texture;
		return nullptr;
	}

	Texture* GetFlippedTexture(int shapenum, int sourceFrame, const string& cacheName)
	{
		if (!HasShapeTexture(shapenum, sourceFrame))
			return nullptr;
		if (g_ResourceManager->DoesTextureExist(cacheName))
			return g_ResourceManager->GetTexture(cacheName);

		Image image = ImageCopy(g_shapeTable[shapenum][sourceFrame].m_texture->m_Image);
		ImageFlipHorizontal(&image);
		g_ResourceManager->AddTexture(image, cacheName);
		return g_ResourceManager->GetTexture(cacheName);
	}

	void AssignDirFromPoses(NpcActionTextures& out, NpcAnimAction action, int dir,
	                        int shapenum, int facingBase, const vector<int>& poses)
	{
		auto& clip = out.textures[static_cast<size_t>(action)][dir];
		clip.clear();
		clip.reserve(poses.size());
		for (int pose : poses)
		{
			Texture* tex = ResolveShapeTexture(shapenum, facingBase, pose);
			if (tex)
				clip.push_back(tex);
		}
	}

	void AssignDirFlipped(NpcActionTextures& out, NpcAnimAction action, int dir,
	                      int shapenum, int sourceFacingBase, const vector<int>& poses,
	                      const char* label)
	{
		auto& clip = out.textures[static_cast<size_t>(action)][dir];
		clip.clear();
		clip.reserve(poses.size());
		for (size_t i = 0; i < poses.size(); ++i)
		{
			const int pose = poses[i] & 15;
			int srcFrame = sourceFacingBase + pose;
			if (!HasShapeTexture(shapenum, srcFrame))
				srcFrame = sourceFacingBase + NpcVisiblePoseFrame(pose);
			const string key = to_string(shapenum) + "_act_" + label + "_" +
				to_string(static_cast<int>(action)) + "_" + to_string(i);
			Texture* tex = GetFlippedTexture(shapenum, srcFrame, key);
			if (!tex)
				tex = ResolveShapeTexture(shapenum, sourceFacingBase, pose);
			if (tex)
				clip.push_back(tex);
		}
	}

	void FillActionAllDirs(NpcActionTextures& out, NpcAnimAction action, int shapenum,
	                       const vector<int>& poses)
	{
		// NE ← North block; SW ← South block (matches current FillWalkTextures).
		// E/W blocks (32/48) are not in g_shapeTable[32] yet — mirror diagonals.
		AssignDirFromPoses(out, action, 4, shapenum, 0, poses);   // NE
		AssignDirFromPoses(out, action, 0, shapenum, 16, poses);  // SW

		AssignDirFlipped(out, action, 6, shapenum, 16, poses, "SE");
		AssignDirFlipped(out, action, 2, shapenum, 0, poses, "NW");

		out.textures[static_cast<size_t>(action)][1] =
			out.textures[static_cast<size_t>(action)][0]; // W ← SW
		out.textures[static_cast<size_t>(action)][5] =
			out.textures[static_cast<size_t>(action)][4]; // E ← NE
		out.textures[static_cast<size_t>(action)][3] =
			out.textures[static_cast<size_t>(action)][2]; // N ← NW
		out.textures[static_cast<size_t>(action)][7] =
			out.textures[static_cast<size_t>(action)][6]; // S ← SE
	}
}

int NpcVisiblePoseFrame(int poseNibble)
{
	poseNibble &= 15;
	return kVisibleFrames[poseNibble];
}

bool FillNpcActionTextures(NpcActionTextures& out, int shapenum)
{
	out = NpcActionTextures{};
	if (shapenum < 0 || shapenum >= 1024)
		return false;

	// Need at least north/south standing frames (same gate as FillWalkTextures).
	if (!HasShapeTexture(shapenum, 0) || !HasShapeTexture(shapenum, 16))
		return false;

	// Walk: Exult NPC cycle with stand between steps.
	FillActionAllDirs(out, NpcAnimAction::Walk, shapenum, { 0, 1, 0, 2, 0 });
	FillActionAllDirs(out, NpcAnimAction::Stand, shapenum, { 0 });
	FillActionAllDirs(out, NpcAnimAction::Ready, shapenum, { 3 });
	FillActionAllDirs(out, NpcAnimAction::Attack1H, shapenum, { 3, 4, 5, 6 });
	FillActionAllDirs(out, NpcAnimAction::Attack2H, shapenum, { 3, 7, 8, 9 });
	FillActionAllDirs(out, NpcAnimAction::Shoot, shapenum, { 3, 11 });
	FillActionAllDirs(out, NpcAnimAction::Cast, shapenum, { 11 });
	FillActionAllDirs(out, NpcAnimAction::Kneel, shapenum, { 12 });
	FillActionAllDirs(out, NpcAnimAction::Sit, shapenum, { 10 });
	FillActionAllDirs(out, NpcAnimAction::Sleep, shapenum, { 13 });
	FillActionAllDirs(out, NpcAnimAction::Up, shapenum, { 14 });
	FillActionAllDirs(out, NpcAnimAction::Out, shapenum, { 15 });

	// Require walk NE/SW to have something drawable.
	if (out.textures[static_cast<size_t>(NpcAnimAction::Walk)][4].empty() ||
	    out.textures[static_cast<size_t>(NpcAnimAction::Walk)][0].empty())
		return false;

	out.valid = true;
	return true;
}

void CopyWalkTexturesFromActions(const NpcActionTextures& actions,
                                 std::vector<std::vector<Texture*>>& outWalk)
{
	outWalk.resize(8);
	const auto& walk = actions.textures[static_cast<size_t>(NpcAnimAction::Walk)];
	for (int d = 0; d < 8; ++d)
		outWalk[d] = walk[d];
}

Texture* GetNpcActionTexture(const NpcActionTextures& actions,
                               NpcAnimAction action, int dir8, int phase)
{
	if (!actions.valid)
		return nullptr;
	const size_t a = static_cast<size_t>(action);
	if (a >= static_cast<size_t>(NpcAnimAction::COUNT))
		return nullptr;
	dir8 = ((dir8 % 8) + 8) % 8;
	const auto& clip = actions.textures[a][dir8];
	if (clip.empty())
		return nullptr;
	if (phase < 0)
		phase = 0;
	return clip[static_cast<size_t>(phase) % clip.size()];
}

int GetNpcActionPhaseCount(const NpcActionTextures& actions, NpcAnimAction action, int dir8)
{
	if (!actions.valid)
		return 0;
	const size_t a = static_cast<size_t>(action);
	if (a >= static_cast<size_t>(NpcAnimAction::COUNT))
		return 0;
	dir8 = ((dir8 % 8) + 8) % 8;
	return static_cast<int>(actions.textures[a][dir8].size());
}

const char* NpcAnimActionName(NpcAnimAction action)
{
	switch (action)
	{
	case NpcAnimAction::Stand: return "Stand";
	case NpcAnimAction::Walk: return "Walk";
	case NpcAnimAction::Ready: return "Ready";
	case NpcAnimAction::Attack1H: return "Attack1H";
	case NpcAnimAction::Attack2H: return "Attack2H";
	case NpcAnimAction::Shoot: return "Shoot";
	case NpcAnimAction::Cast: return "Cast";
	case NpcAnimAction::Kneel: return "Kneel";
	case NpcAnimAction::Sit: return "Sit";
	case NpcAnimAction::Sleep: return "Sleep";
	case NpcAnimAction::Up: return "Up";
	case NpcAnimAction::Out: return "Out";
	default: return "Unknown";
	}
}
