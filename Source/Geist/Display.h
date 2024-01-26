///////////////////////////////////////////////////////////////////////////
//
// Name:     DISPLAY.H
// Author:   Anthony Salter
// Date:     2/03/05
// Purpose:  The display subsystem, which creates the owner window,
//           initializes our rendering system, handles drawing of all
//           objects (by invoking their own ->Draw() commands), and handles
//           the proper restoration of lost surfaces.
//
///////////////////////////////////////////////////////////////////////////

#ifndef _DISPLAY_H_
#define _DISPLAY_H_

#include <map>
#include <string>
#include <vector>
#include <memory>
#include <list>

#include "GL/glew.h"
#ifdef _WINDOWS
#include <Windows.h>
#include <gl/gl.h>
#else
#include <GL/gl.h>
#endif

#include "Object.h"
#include "Config.h"
#include "Font.h"


enum DrawTypes
{
	DTYPE_NONE = 0,
	DTYPE_POINT,
	DTYPE_LINE,
	DTYPE_BOX,
	DTYPE_IMAGE,
	DTYPE_MESH,
	DTYPE_POLYGON,
	DTYPE_TEXT,
	DTYPE_LASTDTYPE
};

enum DrawModes
{
	DM_2D = 0,
	DM_3D,
	DM_3DORTHO
};

enum BlendModes
{
	BLEND_NORMAL = 0,
	BLEND_ADDITIVE
};

class Drawable
{
public:

	// Constructor for point
	Drawable()
	{
		m_X1 = 0;
		m_Y1 = 0;
		m_X2 = 0;
		m_Y2 = 0;
		m_W1 = 0;
		m_H1 = 0;
		m_W2 = 0;
		m_H2 = 0;
		m_Mesh = NULL;
		m_Image = NULL;
		m_Tex1 = NULL;
		m_Tex2 = NULL;
		m_Matrix = glm::mat4();
		m_Color = Color(1, 1, 1, 1);
		m_Position = glm::vec3(0, 0, 0);
		m_Scaling = glm::vec3(1, 1, 1);
		m_Rotation = glm::vec3(0, 0, 0);
		m_Style = 0;
		m_Width = 0;
		m_Flag = false;
		m_BlendMode = BLEND_NORMAL;
		m_Type = DTYPE_NONE;
	}

	float m_X1, m_Y1, m_X2, m_Y2, m_W1, m_H1, m_W2, m_H2;
	int m_Style;
	float m_Width;
	unsigned int m_BlendMode;
	bool m_Flag;
	Mesh* m_Mesh;
	glm::mat4 m_Matrix;
	Texture* m_Image;
	Texture* m_Tex1;
	Texture* m_Tex2;
	Color m_Color;

	glm::vec3 m_Position;
	glm::vec3 m_Rotation;
	glm::vec3 m_Scaling;

	int m_Type;

};

class Display : public Object
{
private:
	int m_HRes, m_VRes, m_BPP;
	bool m_FullScreen, m_UseOpenGL, m_IsWindowActive, m_HasDisplayChanged, m_FastTerrain;

	SDL_Window* m_Screen;
	SDL_GLContext m_GLContext;

	GLuint m_CurrentBoundTexture;

	std::list<Drawable> m_SceneGraph; //  Some day you'll grow up to be a real scene graph!
	std::unique_ptr<std::vector<Vertex2D>> m_VertexList;

	int m_DrawMode;

	GLuint m_2DVBO;
	//   GLuint m_2DEBO;

	GLuint m_Framebuffer;

	//   glm::mat4 m_2DMatrix;
	//   glm::mat4 m_3DMatrix;

	glm::vec3 m_CamPos;
	glm::vec3 m_CamLookAt;
	glm::vec3 m_CamUp;
	glm::vec3 m_CamDirection;

	glm::vec3 m_UnitDiagonal;
	float m_CamAngle;
	float m_CamDistance;
	glm::mat4 m_CamRotation = glm::mat4(1.0f);
	float m_fieldOfView;

	glm::mat4 m_3DProj = glm::mat4(1.0f); //  3D projection matrix, stored to make picking easier.
	glm::mat4 m_3DModelView = glm::mat4(1.0f); //  3D modelview matrix, stored to make picking easier.

	bool m_CameraChanged;

	Mesh* m_LastMesh;

	bool m_Debugging;

public:
	Display() {};

	virtual void Init() { Init(std::string("")); }
	virtual void Init(const std::string& data);
	virtual void Shutdown();
	virtual void Update();
	virtual void Draw();

	void InitializeVideoMode(int w, int h, bool fullscreen);

	void SetVideoMode(int width, int height, bool fullscreen);

	void SetWindowIcon(std::string iconName);

	void Go2D();
	void Go3D();
	void Go3DOrtho();

	int  GetDrawMode();

	int GetWidth() { return m_HRes; }
	int GetHeight() { return m_VRes; }

	void ClearScreen(Color color = Color(0, 0, 0, 1));

	//  These functions are called from outside the class.  They do not actually draw anything;
	//  they create entries in the scene graph that will later be drawn in Display::Draw().
	void DrawBox(const int posx, const int posy, const int width, const int height, const Color& color = Color(1.0f, 1.0f, 1.0f, 1.0f), const bool filled = false);
	void DrawLine(const int posx, const int posy, const int endx, const int endy, const float width = 1, const Color& color = Color(1.0f, 1.0f, 1.0f, 1.0f));

	void DrawMesh(Mesh* mesh, glm::vec3 pos = glm::vec3(0, 0, 0), Texture* tex = NULL, const Color& color = Color(1, 1, 1, 1), glm::vec3 angle = glm::vec3(0, 0, 0), glm::vec3 scale = glm::vec3(1, 1, 1));
	void DrawMesh(Mesh* mesh, bool is3d, glm::vec3 pos = glm::vec3(0, 0, 0), Texture* tex = NULL, const Color& color = Color(1, 1, 1, 1), glm::vec3 angle = glm::vec3(0, 0, 0), glm::vec3 scale = glm::vec3(1, 1, 1));
	void DrawMesh(Mesh* mesh, int tristart, int numtris, glm::vec3 pos = glm::vec3(0, 0, 0), Texture* tex = NULL, const Color& color = Color(1, 1, 1, 1), glm::vec3 angle = glm::vec3(0, 0, 0), glm::vec3 scale = glm::vec3(1, 1, 1));
	void DrawMesh(Mesh* mesh, bool is3d, int tristart, int numtris, glm::vec3 pos = glm::vec3(0, 0, 0), Texture* tex = NULL, const Color& color = Color(1, 1, 1, 1), glm::vec3 angle = glm::vec3(0, 0, 0), glm::vec3 scale = glm::vec3(1, 1, 1));

	//  The order here is texture, source coordinates, source width/height(clipping), destination coordinates, destination width/height(scaling), color.
	//  All units are in pixels so all coordinate variables are ints.
	//  Color is the only element to have a default value - white.
	//  You can flip an image up/down, left/right or both by specifying the source coordinate at the END of the image and using a negative width or height.

	// this is for a pretty specific polygon... a rectangle, but the top 2 vertices can be adjusted up or down any amount.
	void DrawPolygon(Texture* texture, const float srcX, const float srcY, const float srcWid, const float srcHei, const float x1, const float topY1, const float x2, const float topY2, const float bottomY, const Color& color = Color(1, 1, 1, 1), const unsigned int blendmode = BLEND_NORMAL);

	//  Sprites already have texture and UV data within them, so drawing them requires less effort.
	void DrawSprite(std::shared_ptr<Sprite> sprite, const float destx, const float desty, const Color& color = Color(1.0f, 1.0f, 1.0f, 1.0f), bool flipped = false, float angle = 0, const unsigned int blendmode = BLEND_NORMAL);

	void DrawSpriteScaled(std::shared_ptr<Sprite> sprite, const float destx, const float desty, const float xScale, const float yScale, const Color& color = Color(1.0f, 1.0f, 1.0f, 1.0f), bool flipped = false, float angle = 0, const unsigned int blendmode = BLEND_NORMAL);

	//  Draw the whole image at the specified coordinates.
	void DrawImage(Texture* texture, const float destx, const float desty, const Color& color = Color(1.0f, 1.0f, 1.0f, 1.0f), bool flipped = false, float angle = 0, const unsigned int blendmode = BLEND_NORMAL);

	//  Draw the whole image resized to width/height at the specified coordinates.
	void DrawImage(Texture* texture, const float destx, const float desty, const float destw, const float desth, const Color& color = Color(1.0f, 1.0f, 1.0f, 1.0f), bool flipped = false, float angle = 0, const unsigned int blendmode = BLEND_NORMAL);

	//  Draw part of the image at the specified coordinates.
	void DrawImage(Texture* texture, const float srcx, const float srcy, const float srcw, const float srch, const float destx, const float desty, const Color& color = Color(1.0f, 1.0f, 1.0f, 1.0f), bool flipped = false, float angle = 0, const unsigned int blendmode = BLEND_NORMAL);

	//  Draw part of the image, resized, at the specified coordinates.
	void DrawImage(Texture* texture, const float srcx, const float srcy, const float srcw, const float srch, const float destx, const float desty, const float destw, const float desth, const Color& color = Color(1.0f, 1.0f, 1.0f, 1.0f), bool flipped = false, float angle = 0, const unsigned int blendmode = BLEND_NORMAL);

	//  Draw text.
	void DrawFontText(Texture* texture, const float srcx, const float srcy, const float srcw, const float srch, const float destx, const float desty, const float destw, const float desth, const Color& color = Color(1.0f, 1.0f, 1.0f, 1.0f), bool flipped = false, float angle = 0, const unsigned int blendmode = BLEND_NORMAL);


	//  These functions actually do the drawing and are called from the display list.
	void DrawImageActual(Texture* texture, const float srcx, const float srcy, const float srcw, const float srch, const float destx, const float desty, const float destw, const float desth, const Color color, const bool flipped, const float angle, const unsigned int blendmode);
	void DrawBoxActual(const int posx, const int posy, const int width, const int height, const Color color = Color(1.0f, 1.0f, 1.0f, 1.0f), const bool filled = false);
	void DrawLineActual(const int posx, const int posy, const int endx, const int endy, const float width, const Color color = Color(1.0f, 1.0f, 1.0f, 1.0f));
	void DrawMeshActual(Mesh* mesh, bool is3D, int tristart, int numtris, glm::vec3 pos, Texture* tex, Color color, glm::vec3 angle, glm::vec3 scale);
	void DrawPolygonActual(Texture* texture, const float srcX, const float srcY, const float srcWid, const float srcHei, const float x1, const float topY1, const float x2, const float topY2, const float bottomY, const Color& color = Color(1, 1, 1, 1));
	void DrawPerfCounter(std::shared_ptr<Font>& m_Font, int loc = 0);

	void ChangeToFullscreen();
	void ChangeToWindowed();

	float GetCameraAngle();
	void SetCameraAngle(float newangle);

	glm::vec3 GetCameraPosition();
	void SetCameraPosition(glm::vec3 newpos);

	glm::mat4 GetProjectionMatrix();
	glm::mat4 GetModelViewMatrix();

	glm::mat4 GetCameraRotationMatrix();

	glm::vec3 GetCameraDirection();
	glm::vec3 GetCameraLookAtPoint();

	float GetFieldOfView() { return m_fieldOfView; }

	bool GetIsFullscreen();
	void SetIsFullscreen(bool isFS);

	void UpdateCamera();

	float GetCameraDistance();
	void  SetCameraDistance(float distance);

	bool GetHasCameraChanged();
	void SetHasCameraChanged(bool changed);

	int IntersectTriangle(double orig[3], double dir[3], double vert0[3], double vert1[3], double vert2[3], double* t, double* u, double* v);

	std::vector<Point> GetSupportedResolutions();
};

#endif