#include <Geist/RaylibModel.h>
#include <cassert>
#include <raymath.h>

using namespace std;

void Log(std::string text, std::string filename = "", bool suppressdatetime = false);

RaylibModel::RaylibModel(const std::string& filename)
{
	bool is_glb = IsFileExtension(filename.c_str(), ".glb");
	if (is_glb) {
		Log("Loading GLB model " + filename, "anims.log");
	}
	else {
		Log("Loading model " + filename, "anims.log");
	}
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
		if (is_glb) {
			Log("Loading animations for GLB " + filename, "anims.log");
			//Log("Loading animations for " + filename, "anims.log");
			m_Anims = LoadModelAnimations(filename.c_str(), &m_AnimCount);
			Log("Loaded " + std::to_string(m_AnimCount) + " animations for GLB " + filename, "anims.log");
		}
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
		other.m_TexAnimated = false;
	}

	return *this;
}

void RaylibModel::SetTexAnimated(bool animated)
{
	m_TexAnimated = animated;
}

bool RaylibModel::IsTexAnimated()
{
	return m_TexAnimated;
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
	double timePerFrame = 1.0 / 24.0;

	// Look for the named animation in this model.
	for (int i = 0; i < m_AnimCount; ++i) {
		Log("  UpdateAnim " + animName + " i = " + std::to_string(i) + "  of " + std::to_string(m_AnimCount), "anims.log");
		if (m_Anims[i].frameCount == 0) {
			continue;
		}

		if (animName == m_Anims[i].name) {
			animIdx = i;
			// Standard movie animation, 24 frames per second.
			currentFrame = static_cast<unsigned int>(GetTime() / timePerFrame) % m_Anims[i].frameCount;
			//currentFrame = static_cast<unsigned int>(GetTime() * 24.0f) % m_Anims[i].frameCount;
			//currentFrame = (m_AnimFrame + 1) % m_Anims[i].frameCount;
			Log("    Frame " + std::to_string(currentFrame) + "  of " + std::to_string(m_Anims[i].frameCount), "anims.log");
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

bool RaylibModel::SetAnimationFrame(const std::string& animName, int frame)
{
	// Look for the named animation in this model.
	bool animValid = false;
	int i = 0;
	if (m_AnimCount > 0) {
		Log("  UpdateAnim " + animName + " m_AnimCount = " + std::to_string(m_AnimCount), "anims.log");
	}
	for (; i < m_AnimCount; ++i)
	{
		if (animName == m_Anims[i].name)
		{
			// Make sure it has the frame we want.
			if (m_Anims[i].frameCount > frame)
			{
				animValid = true;
			}
			break;
		}
	}

	// It doesn't have it, return.
	if (!animValid)
	{
		return false;
	}

	UpdateModelAnimation(m_Model, m_Anims[i], frame);
	UpdateAnim(animName);
	return true;
}