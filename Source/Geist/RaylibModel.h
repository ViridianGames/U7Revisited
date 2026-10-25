#ifndef _RAYLIB_MODEL_H_
#define _RAYLIB_MODEL_H_

#include <string>
#include "raylib.h"

/// Resource-managing wrapper for raylib models that may be animated.
class RaylibModel
{
public:
	RaylibModel(const std::string& filename);
	~RaylibModel();
	RaylibModel(RaylibModel&& other);
	RaylibModel& operator=(RaylibModel&& other);
	RaylibModel(const RaylibModel&) = delete;
	RaylibModel& operator=(const RaylibModel&) = delete;

	Model& GetModel() { return m_Model; }
	const std::string& GetFilename() const { return m_Filename; }

	/// True if this model has animations and every mesh has bone ids/weights
	/// so UpdateModelAnimation will not emit raylib skinning warnings.
	bool CanApplySkeletalAnimation() const { return m_CanApplySkeletalAnim; }

	/// Displace model so AABB XZ center sits on local origin (LoadModels).
	RaylibModel& Decenter();
	/// XZ subtracted by Decenter(); zero if Decenter was never called.
	Vector3 GetDecenterOffset() const { return m_DecenterOffset; }
	RaylibModel& UpdateFlatUV(float uvXmin, float uvXmax, float uvYmin, float uvYmax);

	/// speedMul scales playback (1 = 24 fps). <= 0 freezes on frame 0.
	void UpdateAnim(const std::string& animName, float speedMul = 1.0f);
	bool SetAnimationFrame(const std::string& animName, int frame);

private:
	// True if every mesh has boneIds/boneWeights and model has a skeleton.
	static bool ModelMeshesAreFullySkinned(const Model& model);

	std::string m_Filename;
	Model m_Model = {{ 0 }};
	ModelAnimation* m_Anims = nullptr;
	int m_AnimCount = 0;
	bool m_CanApplySkeletalAnim = false;
	Vector3 m_DecenterOffset = { 0, 0, 0 };

	unsigned int m_AnimFrame = 0;
	std::string m_CurrentAnim = "";
};

#endif
