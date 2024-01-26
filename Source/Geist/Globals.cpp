#include "Globals.h"

using namespace std;

unique_ptr<Engine>           g_Engine;
unique_ptr<ResourceManager>  g_ResourceManager;
unique_ptr<MemoryManager>    g_MemoryManager;
unique_ptr<Display>          g_Display;
unique_ptr<Input>            g_Input;
unique_ptr<Sound>            g_Sound;
unique_ptr<StateMachine>     g_StateMachine;
#ifdef REQUIRES_STEAM
unique_ptr<SteamManager>     g_SteamManager;
#endif

//glm::vec3 Normalize(glm::vec3 in)
//{
//	return glm::normalize(in);
//}
//
//float Dot(glm::vec3 a, glm::vec3 b)
//{
//	return glm::dot(a, b);
//}
//
//glm::vec3 Cross(glm::vec3 a, glm::vec3 b)
//{
//	return glm::cross(a, b);
//}
//
//glm::mat4 Translate(glm::mat4 mat, glm::vec3 pos)
//{
//	return glm::translate(mat, pos);
//}
//
//glm::mat4 Rotate(glm::mat4 mat, float angle, glm::vec3 up)
//{
//	return glm::rotate(mat, glm::radians(angle), up);
//}
//
//glm::mat4 Scale(glm::mat4 mat, glm::vec3 scaler)
//{
//	return glm::scale(mat, scaler);
//}

//  These functions assume that the ray and the triangle are in the same space.

#define EPSILON 0.000001
#define CROSS(dest,v1,v2) \
	dest[0]=v1[1]*v2[2]-v1[2]*v2[1]; \
	dest[1]=v1[2]*v2[0]-v1[0]*v2[2]; \
	dest[2]=v1[0]*v2[1]-v1[1]*v2[0];
#define DOT(v1,v2) (v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2])
#define SUB(dest,v1,v2) \
dest[0]=v1[0]-v2[0]; \
dest[1]=v1[1]-v2[1]; \
dest[2]=v1[2]-v2[2]; 

int intersect_triangle(double orig[3], double dir[3],
	double vert0[3], double vert1[3], double vert2[3],
	double* t, double* u, double* v)
{
	double edge1[3], edge2[3], tvec[3], pvec[3], qvec[3];
	double det, inv_det;

	/* find vectors for two edges sharing vert0 */
	SUB(edge1, vert1, vert0);
	SUB(edge2, vert2, vert0);

	/* begin calculating determinant - also used to calculate U parameter */
	CROSS(pvec, dir, edge2);

	/* if determinant is near zero, ray lies in plane of triangle */
	det = DOT(edge1, pvec);

	if (det > EPSILON)
	{
		/* calculate distance from vert0 to ray origin */
		SUB(tvec, orig, vert0);

		/* calculate U parameter and test bounds */
		*u = DOT(tvec, pvec);
		if (*u < 0.0 || *u > det)
			return 0;

		/* prepare to test V parameter */
		CROSS(qvec, tvec, edge1);

		/* calculate V parameter and test bounds */
		*v = DOT(dir, qvec);
		if (*v < 0.0 || *u + *v > det)
			return 0;

	}
	else if (det < -EPSILON)
	{
		/* calculate distance from vert0 to ray origin */
		SUB(tvec, orig, vert0);

		/* calculate U parameter and test bounds */
		*u = DOT(tvec, pvec);
		/*      printf("*u=%f\n",(float)*u); */
		/*      printf("det=%f\n",det); */
		if (*u > 0.0 || *u < det)
			return 0;

		/* prepare to test V parameter */
		CROSS(qvec, tvec, edge1);

		/* calculate V parameter and test bounds */
		*v = DOT(dir, qvec);
		if (*v > 0.0 || *u + *v < det)
			return 0;
	}
	else return 0;  /* ray is parallell to the plane of the triangle */


	inv_det = 1.0 / det;

	/* calculate t, ray intersects triangle */
	*t = DOT(edge2, qvec) * inv_det;
	(*u) *= inv_det;
	(*v) *= inv_det;

	return 1;
}

//  Fairly generic "ray-triangle" intersection function.  Takes the endpoint of
//  the ray (the start point is the location of the camera), the three vertices
//  of the triangle we're checking against, and the current transformation
//  matrix of the triangle we're checking against.
bool Pick(glm::vec3 _RayOrigin, glm::vec3 _RayDirection, glm::vec3 tri1, glm::vec3 tri2, glm::vec3 tri3, double& distance)
{
	double orig[3] = { _RayOrigin.x, _RayOrigin.y, _RayOrigin.z };
	double dir[3] = { _RayDirection.x, _RayDirection.y, _RayDirection.z };
	double vert0[3] = { tri1.x, tri1.y, tri1.z };
	double vert1[3] = { tri2.x, tri2.y, tri2.z };
	double vert2[3] = { tri3.x, tri3.y, tri3.z };

	double u, v;

	return intersect_triangle(orig, dir, vert0, vert1, vert2, &distance, &u, &v);
}

//  This version of Pick not only returns the distance, but also the UV
//  coordinates of the triangle.
bool PickWithUV(glm::vec3 _RayOrigin, glm::vec3 _RayDirection, glm::vec3 tri1, glm::vec3 tri2, glm::vec3 tri3, double& distance, double& u, double& v)
{
	double orig[3] = { _RayOrigin.x, _RayOrigin.y, _RayOrigin.z };
	double dir[3] = { _RayDirection.x, _RayDirection.y, _RayDirection.z };
	double vert0[3] = { tri1.x, tri1.y, tri1.z };
	double vert1[3] = { tri2.x, tri2.y, tri2.z };
	double vert2[3] = { tri3.x, tri3.y, tri3.z };

	return intersect_triangle(orig, dir, vert0, vert1, vert2, &distance, &u, &v);
}