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

	/// Displace model to northwest quadrant from origin.
	RaylibModel& Decenter();

	void UpdateAnim(const std::string& animName);
	bool SetAnimationFrame(const std::string& animName, int frame);

private:
	Model m_Model = {{ 0 }};
	ModelAnimation* m_Anims = nullptr;
	int m_AnimCount = 0;

	unsigned int m_AnimFrame = 0;
	std::string m_CurrentAnim = "";
};

#endif
