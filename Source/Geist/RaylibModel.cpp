#include "RaylibModel.h"
#include <cassert>
#include "raymath.h"

using namespace std;

RaylibModel::RaylibModel(const std::string& filename)
{
	m_Model = LoadModel(filename.c_str());
	if (!m_Model.meshCount) {
		throw("Failed to load model " + filename);
	}

	bool is_obj = IsFileExtension(filename.c_str(), ".obj");

	if (is_obj) {
		string mtlPath = filename;
		mtlPath.replace(mtlPath.find(".obj"), 4, ".mtl");

		int materialCount = 0;
		// Load material
		Material* material = LoadMaterials(mtlPath.c_str(), &materialCount);
		// Set map diffuse texture.
		if (material && materialCount > 0) {
			m_Model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = material[0].maps[0].texture;
		}
	}

	// Try loading animations. Don't bother with OBJ files that don't have
	// any.
	if (!is_obj) {
		m_Anims = LoadModelAnimations(filename.c_str(), &m_AnimCount);
	}
}

RaylibModel::~RaylibModel()
{
	if (!m_Model.meshCount) {
		assert(!m_Anims && !m_AnimCount);
		return;
	}

	UnloadModel(m_Model);
	if (m_Anims) {
		UnloadModelAnimations(m_Anims, m_AnimCount);
	}
}

RaylibModel::RaylibModel(RaylibModel&& other)
{
	*this = std::move(other);
}

RaylibModel& RaylibModel::operator=(RaylibModel&& other)
{
	if (this != &other)
	{
		m_Model = other.m_Model;
		m_Anims = other.m_Anims;
		m_AnimCount = other.m_AnimCount;

		other.m_Model = {{ 0 }};
		other.m_Anims = nullptr;
		other.m_AnimCount = 0;
	}

	return *this;
}

RaylibModel& RaylibModel::Decenter()
{
	BoundingBox bounds = GetModelBoundingBox(m_Model);
	Vector3 center = Vector3 {
		(bounds.min.x + bounds.max.x) / 2.0f,
			(bounds.min.y + bounds.max.y) / 2.0f,
			(bounds.min.z + bounds.max.z) / 2.0f
	};

	Matrix translation = MatrixTranslate(-center.x, 0, -center.z);
	m_Model.transform = MatrixMultiply(m_Model.transform, translation);

	return *this;
}

void RaylibModel::UpdateAnim(const std::string& animName) {
	int animIdx = -1;
	unsigned int currentFrame = 0;

	// Look for the named animation in this model.
	for (int i = 0; i < m_AnimCount; ++i) {
		if (m_Anims[i].frameCount == 0) {
			continue;
		}

		if (animName == m_Anims[i].name) {
			animIdx = i;
			// Standard movie animation, 24 frames per second.
			currentFrame = static_cast<unsigned int>(GetTime() * 24.0f) % m_Anims[i].frameCount;
			break;
		}
	}

	// It doesn't have it, return.
	if (animIdx < 0) {
		return;
	}

	// Animation exists and we should show a different frame than we currently
	// are, update the model.
	if (animName != m_CurrentAnim || currentFrame != m_AnimFrame) {
		m_CurrentAnim = animName;
		m_AnimFrame = currentFrame;
		UpdateModelAnimation(m_Model, m_Anims[animIdx], m_AnimFrame);
	}
}
