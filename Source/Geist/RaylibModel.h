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

	/// Displace model to northwest quadrant from origin.
	RaylibModel& Decenter();
	RaylibModel& UpdateFlatUV(float uvXmin, float uvXmax, float uvYmin, float uvYmax);

	void UpdateAnim(const std::string& animName);
	bool SetAnimationFrame(const std::string& animName, int frame);

private:
	// True if every mesh has boneIds/boneWeights and model has a skeleton.
	static bool ModelMeshesAreFullySkinned(const Model& model);

	std::string m_Filename;
	Model m_Model = {{ 0 }};
	ModelAnimation* m_Anims = nullptr;
	int m_AnimCount = 0;
	bool m_CanApplySkeletalAnim = false;

	unsigned int m_AnimFrame = 0;
	std::string m_CurrentAnim = "";
};

#endif
