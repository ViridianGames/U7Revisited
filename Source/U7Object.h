#pragma warning(disable:4786)

#ifndef _U7OBJECT_H_
#define _U7OBJECT_H_

#include "Globals.h"
#include "BaseUnits.h"
//#include "U7Globals.h"
#include <string>
#include <list>

struct ObjectData;

class U7Object : public Unit3D
{

public:

	U7Object() {};
	virtual ~U7Object();

	virtual void Init(const std::string& configfile);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	void SetObjectData(int objectType);

	virtual bool SelectCheck();

	virtual glm::vec3 GetPos() { return m_Pos; }
	virtual void SetPos(glm::vec3 pos) { m_Pos = pos; }

	void SetShapeAndFrame(unsigned int shape, unsigned int frame);

	ObjectData* m_objectData;

	bool m_isVisible;

	glm::vec3 m_Pos;
	glm::vec3 m_Scaling;
	float m_Angle;

	unsigned int m_UnitType;

	Mesh* m_Mesh;
	Texture* m_Texture;
	Config* m_UnitConfig;
};

#endif