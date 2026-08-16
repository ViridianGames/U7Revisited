#include <Geist/RaylibModel.h>
#include <Geist/Logging.h>
#include <cassert>
#include <raymath.h>
#include <string>

using namespace std;

bool RaylibModel::ModelMeshesAreFullySkinned(const Model& model)
{
	if (model.meshCount <= 0 || model.boneCount <= 0 || model.bones == nullptr)
	{
		return false;
	}

	// raylib's UpdateModelAnimation logs
	//   "Mesh N has no connection to bones"
	// for every mesh with null boneIds. Only apply anims when every mesh is skinned.
	for (int i = 0; i < model.meshCount; ++i)
	{
		if (model.meshes[i].boneIds == nullptr || model.meshes[i].boneWeights == nullptr)
		{
			return false;
		}
	}
	return true;
}

RaylibModel::RaylibModel(const std::string& filename)
	: m_Filename(filename)
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

	m_CanApplySkeletalAnim = (m_Anims != nullptr && m_AnimCount > 0
		&& ModelMeshesAreFullySkinned(m_Model));

	// Anim clips without per-vertex bone data: raylib would spam warnings every
	// frame when ShapeData calls UpdateAnim("idle"). Log once and drop the clips.
	if (m_Anims != nullptr && m_AnimCount > 0 && !m_CanApplySkeletalAnim)
	{
		int meshesMissingBones = 0;
		for (int i = 0; i < m_Model.meshCount; ++i)
		{
			if (m_Model.meshes[i].boneIds == nullptr || m_Model.meshes[i].boneWeights == nullptr)
			{
				++meshesMissingBones;
			}
		}

		Log("MODEL ANIM SKIP (no bone skinning on mesh): " + filename
			+ " | anims=" + std::to_string(m_AnimCount)
			+ " | modelBones=" + std::to_string(m_Model.boneCount)
			+ " | meshes=" + std::to_string(m_Model.meshCount)
			+ " | meshesWithoutBoneIds=" + std::to_string(meshesMissingBones)
			+ " | firstAnim=\"" + std::string(m_Anims[0].name ? m_Anims[0].name : "") + "\"");

		UnloadModelAnimations(m_Anims, m_AnimCount);
		m_Anims = nullptr;
		m_AnimCount = 0;
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
		m_Filename = std::move(other.m_Filename);
		m_Model = other.m_Model;
		m_Anims = other.m_Anims;
		m_AnimCount = other.m_AnimCount;
		m_CanApplySkeletalAnim = other.m_CanApplySkeletalAnim;
		m_AnimFrame = other.m_AnimFrame;
		m_CurrentAnim = std::move(other.m_CurrentAnim);

		other.m_Model = {{ 0 }};
		other.m_Anims = nullptr;
		other.m_AnimCount = 0;
		other.m_CanApplySkeletalAnim = false;
		other.m_AnimFrame = 0;
		other.m_CurrentAnim.clear();
		other.m_Filename.clear();
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

RaylibModel& RaylibModel::UpdateFlatUV(float uvXmin, float uvXmax, float uvYmin, float uvYmax)
{
	Mesh mesh = m_Model.meshes[0];
	
	// here is the dirty secret to how I can do UV updates, I had to get the vertex order and print it out so that I'd know.
	//   if flat.obj changes, we'd need to re-run this to get the new vertex order.  Potentially could be done programattically, but this works.
	/*
	int vertNum = 0;
	int vertMax = mesh.vertexCount;
	for (int i = 0; i < vertMax; ++i) {
		// Update UV coordinates here
		//mesh.texcoords[i * 2]     = 0.5f;
		//mesh.texcoords[i * 2 + 1] = 1.0f;
		//Log("Vertex " + std::to_string(i) + " UV " + std::to_string(mesh.texcoords[i * 2]) + ", " + std::to_string(mesh.texcoords[i * 2 + 1]) + ".", "anims.log");
	}
	*/
	int i = 0;
	mesh.texcoords[i * 2] = uvXmin;
	mesh.texcoords[i * 2 + 1] = uvYmin;
	i = 3;
	mesh.texcoords[i * 2] = uvXmin;
	mesh.texcoords[i * 2 + 1] = uvYmin;
	i = 2;
	mesh.texcoords[i * 2] = uvXmax;
	mesh.texcoords[i * 2 + 1] = uvYmax;
	i = 4;
	mesh.texcoords[i * 2] = uvXmax;
	mesh.texcoords[i * 2 + 1] = uvYmax;
	i = 1;
	mesh.texcoords[i * 2] = uvXmax;
	mesh.texcoords[i * 2 + 1] = uvYmin;
	i = 5;
	mesh.texcoords[i * 2] = uvXmin;
	mesh.texcoords[i * 2 + 1] = uvYmax;

	int bufferId = 1;
	UpdateMeshBuffer(mesh, bufferId, mesh.texcoords, mesh.vertexCount * 2 * sizeof(float), 0);
	return *this;
}

void RaylibModel::UpdateAnim(const std::string& animName) {
	// Unskinned models (or models whose anims were dropped at load) are a no-op.
	if (!m_CanApplySkeletalAnim || !m_Anims || m_AnimCount <= 0) {
		return;
	}

	int animIdx = -1;
	unsigned int currentFrame = 0;
	double timePerFrame = 1.0 / 24.0;

	// Look for the named animation in this model.
	for (int i = 0; i < m_AnimCount; ++i) {
		if (m_Anims[i].frameCount == 0) {
			continue;
		}

		if (animName == m_Anims[i].name) {
			animIdx = i;
			// Standard movie animation, 24 frames per second.
			currentFrame = static_cast<unsigned int>(GetTime() / timePerFrame) % m_Anims[i].frameCount;
			//currentFrame = static_cast<unsigned int>(GetTime() * 24.0f) % m_Anims[i].frameCount;
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
	if (!m_CanApplySkeletalAnim || !m_Anims || m_AnimCount <= 0)
	{
		return false;
	}

	// Look for the named animation in this model.
	bool animValid = false;
	int i = 0;
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