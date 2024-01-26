#include "Globals.h"
#include "Display.h"
#include "RNG.h"
#include <fstream>
#include <sstream>
#include <algorithm>
#include "SDL.h"
#include "Logging.h"

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

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

using namespace std;

void Display::Init(const string& configfile)
{
	Log("Starting Display::Init()");

	//  We have to set the application icon before we set the video mode.
	SDL_Surface* icon = SDL_LoadBMP(g_Engine->m_EngineConfig.GetString("icon").c_str());
	if (icon)
	{
		//      SDL_SetColorKey(icon, SDL_SRCCOLORKEY, SDL_MapRGB(icon->format, 255, 0, 255));
		//      SDL_WM_SetIcon(icon, NULL);
	}

	m_FullScreen = g_Engine->m_EngineConfig.GetNumber("full_screen");
	m_HRes = (int)g_Engine->m_EngineConfig.GetNumber("h_res");
	m_VRes = (int)g_Engine->m_EngineConfig.GetNumber("v_res");

	InitializeVideoMode(m_HRes, m_VRes, m_FullScreen);

	glGenBuffers(1, &m_2DVBO);

	m_CameraChanged = false;

	m_LastMesh = NULL;
	m_VertexList = make_unique<vector<Vertex2D>>();
	m_Debugging = false;

	Log("Done With Display::Init()");

}

void Display::InitializeVideoMode(int w, int h, bool fullscreen)
{
	SetVideoMode(w, h, fullscreen);

	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);

	glEnable(GL_ALPHA_TEST);

	glClearColor(0, 0, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	SDL_GL_SwapWindow(m_Screen);
	if (SDL_GL_SetSwapInterval(-1) == -1) // Try adaptive refresh
		SDL_GL_SetSwapInterval(1); //  Okay, just do vsync then.

	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

	// Initialize GLEW
	Log("Initializing GLEW.");
	glewExperimental = GL_TRUE;

	GLenum err = glewInit();
	if (GLEW_OK != err)
	{
		Log((char*)glewGetErrorString(err));
	}

	glViewport(0, 0, w, h);

	glMatrixMode(GL_PROJECTION);
	m_fieldOfView = g_Engine->m_EngineConfig.GetNumber("field_of_view");
	if (m_fieldOfView == 0)
	{
		m_fieldOfView = 90;
	}
	m_3DProj = glm::perspective(glm::radians(m_fieldOfView), ((float)m_HRes / (float)m_VRes), 1.0f, 1000.0f);

	glMultMatrixf(glm::value_ptr(m_3DProj));


	glMatrixMode(GL_MODELVIEW);
	m_CamLookAt = glm::vec3(51, 13, 51);
	m_CamPos = glm::vec3(1, 0, 1);
	m_CamUp = glm::vec3(0, 1, 0);
	m_CamRotation = glm::mat4(1.0f);

	m_3DModelView = glm::lookAt(m_CamPos, m_CamLookAt, m_CamUp);
	glMultMatrixf(glm::value_ptr(m_3DModelView));

	m_DrawMode = DM_3D;

	m_CamAngle = 0;

	float cameraCloseLimit = g_Engine->m_EngineConfig.GetNumber("camera_close_limit");
	if (cameraCloseLimit == 0)
	{
		cameraCloseLimit = 13;
	}

	m_CamDistance = cameraCloseLimit;

	m_UnitDiagonal = glm::vec3(1, 1, 1);
	glm::normalize(m_UnitDiagonal);

	m_CurrentBoundTexture = 727;

	Log("Updating camera.");
	UpdateCamera();

	Log("Leaving Display::InitializeVideoMode()");
}

void Display::SetVideoMode(int width, int height, bool fullscreen)
{
	bool needResave = false;
	if (width == 0 && height == 0)
	{
		//  Try to set a mode as close to the current resolution of the operating system as possible.
		SDL_DisplayMode dm;
		if (SDL_GetDesktopDisplayMode(0, &dm) != 0)
		{
			//  We couldn't get the current display mode.  Play it safe and default to 1280x720.
			m_HRes = 1280;
			m_VRes = 720;

			width = m_HRes;
			height = m_VRes;
		}
		else
		{
			//  See if the display resolution is in our supported list.  If so, use it.  If not, use the one
			//  just smaller than it.

			Log("Attempting to set highest possible resolution.");
			vector<Point> res = GetSupportedResolutions();
			//  Cull out resolutions that aren't 16x9 or 16x10
			for (auto node : res)
			{
				if (node.X / node.Y < 1.777 || node.X / node.Y > 1.780)
					continue;

				if (node.X <= dm.w && node.Y <= dm.h)
				{
					m_VRes = node.Y;
					m_HRes = node.X;

					width = m_HRes;
					height = m_VRes;
				}
			}

			needResave = true;
		}

		//  If width and height are STILL 0, meaning we tried to find a resolution but couldn't,
		//  use safe and sane defaults.
		if (width == 0 && height == 0)
		{
			m_HRes = 1280;
			m_VRes = 720;

			width = m_HRes;
			height = m_VRes;

			needResave = true;
		}

		g_Engine->m_EngineConfig.SetNumber("h_res", m_HRes);
		g_Engine->m_EngineConfig.SetNumber("v_res", m_VRes);
	}

	Log("Starting Display::SetVideoMode(), setting " + to_string(width) + "x" + to_string(height));

	//  Start SDL
	m_Screen = SDL_CreateWindow(g_Engine->m_EngineConfig.GetString("name").c_str(),
		SDL_WINDOWPOS_UNDEFINED,
		SDL_WINDOWPOS_UNDEFINED,
		width, height,
		SDL_WINDOW_OPENGL);

	if (m_Screen == NULL)
	{
		throw("Could not set desired windowed resolution.");
	}

	if (fullscreen)
	{
		int result = SDL_SetWindowFullscreen(m_Screen, SDL_WINDOW_FULLSCREEN);
		if (result == -1)
		{
			throw("Could not set desired fullscreen resolution.");
		}
	}

	//  Start OpenGL

	SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_COMPATIBILITY);
	//   SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
	//   SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
	//   SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
	//   SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
	//   SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
	//   SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

	m_GLContext = SDL_GL_CreateContext(m_Screen);

	if (m_GLContext == NULL)
	{
		throw("Could not initialize OpenGL.");
	}

	g_ResourceManager->ReloadTextures();

	//  We have successfully set our resolution, write out known good numbers.
	//  If we crashed while setting our resolution, the crash handler will write
	//  out a safe engine.cfg (lowest res, windowed).
	if (needResave)
		g_Engine->m_EngineConfig.Save();

}

void Display::SetWindowIcon(std::string iconName)
{
	//SDL_Surface* surface; // This surface will tell us the details of the image



	//if ((surface = IMG_Load(iconName.c_str())))
	//{
	//	SDL_SetWindowIcon(m_Screen, surface);
	//	SDL_FreeSurface(surface);
	//}
}

std::vector<Point> Display::GetSupportedResolutions()
{
	Log("Attempting to enumerate resolutions.");
	int display_count = 0, display_index = 0, mode_index = 0;

	//  Get the current display mode so that we know what refresh rate to look for.
	SDL_DisplayMode mode = { SDL_PIXELFORMAT_UNKNOWN, 0, 0, 0, 0 };
	SDL_GetCurrentDisplayMode(0, &mode);
	int desiredRefresh = mode.refresh_rate;

	std::vector<Point> displayModes;
	displayModes.clear();
	int modeCount = SDL_GetNumDisplayModes(0);
	Log("Found " + to_string(modeCount) + " resolutions.");
	if (modeCount == 0)
	{
		throw("No resolutions found!");
	}
	else if (modeCount < 0)
	{
		throw("Could not enumerate resolutions!  Error: " + string(SDL_GetError()));
	}

	for (int i = 0; i < modeCount; ++i)
	{
		SDL_GetDisplayMode(display_index, i, &mode);
		if (mode.refresh_rate == desiredRefresh)
		{
			Log("Found resolution: " + to_string(mode.w) + "x" + to_string(mode.h));
			displayModes.push_back(Point(mode.w, mode.h));
		}
	}

	std::reverse(displayModes.begin(), displayModes.end());
	return displayModes;
}

void Display::ClearScreen(Color color)
{
	glClearColor(color.r, color.g, color.b, color.a);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

float Display::GetCameraAngle()
{
	return m_CamAngle;
}

glm::vec3 Display::GetCameraPosition()
{
	return m_CamPos;
}

glm::vec3 Display::GetCameraLookAtPoint()
{
	return m_CamLookAt;
}

glm::mat4 Display::GetCameraRotationMatrix()
{
	return m_CamRotation;
}

bool Display::GetHasCameraChanged()
{
	return m_CameraChanged;
}

void Display::SetHasCameraChanged(bool changed)
{
	m_CameraChanged = changed;
}

float Display::GetCameraDistance()
{
	return m_CamDistance;
}

void Display::SetCameraDistance(float distance)
{
	m_CamDistance = distance;
}

void Display::Go2D()
{
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glm::ortho(0, m_HRes, m_VRes, 0);
	glMultMatrixf(glm::value_ptr(glm::ortho<float>(0, m_HRes, m_VRes, 0)));
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_ALPHA_TEST);
	m_DrawMode = DM_2D;
}

void Display::Go3D()
{
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_ALPHA_TEST);
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
	m_DrawMode = DM_3D;
}

void Display::Go3DOrtho()
{
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(0, m_HRes, m_VRes, 0, 1.0f, 10000.0f);
	m_3DProj = glm::ortho(0.0f, (float)m_HRes, (float)m_VRes, 0.0f, 1.0f, 10000.0f);
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	m_DrawMode = DM_3DORTHO;
}

int Display::GetDrawMode()
{
	return m_DrawMode;
}

void Display::SetCameraAngle(float newangle)
{
	m_CamAngle = newangle;

	if (m_CamAngle < 0) m_CamAngle += 360;

	if (m_CamAngle > 359) m_CamAngle -= 360;


	m_CameraChanged = true;
	UpdateCamera();
}

void Display::SetCameraPosition(glm::vec3 newpos)
{
	m_CamLookAt = newpos;
	m_CameraChanged = true;
	UpdateCamera();
}

glm::vec3 Display::GetCameraDirection()
{
	return m_CamDirection;
}

bool Display::GetIsFullscreen()
{
	return m_FullScreen;
}

void Display::SetIsFullscreen(bool isFS)
{
	m_FullScreen = isFS;
}

void Display::UpdateCamera()
{
	glm::vec3 newpos = m_UnitDiagonal;

	newpos *= m_CamDistance;
	glm::mat4 camrot = glm::mat4(1.0f);
	camrot = glm::rotate(camrot, glm::radians(m_CamAngle), m_CamUp);
	glm::vec4 camfinal = camrot * glm::vec4(newpos, 1);
	camfinal += glm::vec4(m_CamLookAt, 1);

	m_CamPos = glm::vec3(camfinal.x, camfinal.y, camfinal.z);

	m_3DModelView = glm::mat4(1.0f);
	m_3DModelView = glm::lookAt(m_CamPos, m_CamLookAt, m_CamUp);

	m_CamDirection = glm::normalize(glm::vec3(m_CamPos.x, 0, m_CamPos.z) - glm::vec3(m_CamLookAt.x, 0, m_CamLookAt.z));
	m_CamRotation = glm::mat4(1.0f);
	m_CamRotation = glm::rotate(m_CamRotation, glm::radians(m_CamAngle), m_CamUp);
	m_CameraChanged = false;
}

void Display::DrawSprite(shared_ptr<Sprite> sprite, const float destx, const float desty, const Color& color, bool flipped, float angle, unsigned int blendmode)
{
	DrawImage(sprite->m_Texture, sprite->m_PosX, sprite->m_PosY, sprite->m_Width, sprite->m_Height, destx, desty, sprite->m_Width, sprite->m_Height, color, flipped, angle, blendmode);
}

void Display::DrawSpriteScaled(shared_ptr<Sprite> sprite, const float destx, const float desty, const float xScale, const float yScale, const Color& color, bool flipped, float angle, unsigned int blendmode)
{
	DrawImage(sprite->m_Texture, sprite->m_PosX, sprite->m_PosY, sprite->m_Width, sprite->m_Height, destx, desty, sprite->m_Width * xScale, sprite->m_Height * yScale, color, flipped, angle, blendmode);
}

void Display::DrawImage(Texture* texture, const float destx, const float desty, const Color& color, bool flipped, float angle, unsigned int blendmode)
{
	if (angle == 0 && (destx > GetWidth() || desty > GetHeight() || (destx + texture->GetWidth() < 0 && desty + texture->GetHeight() < 0)))
		return;

	Drawable temp;
	temp.m_X1 = 0;
	temp.m_Y1 = 0;
	temp.m_W1 = texture->GetWidth();
	temp.m_H1 = texture->GetHeight();
	temp.m_X2 = destx;
	temp.m_Y2 = desty;
	temp.m_W2 = texture->GetWidth();
	temp.m_H2 = texture->GetHeight();
	temp.m_Color = color;
	temp.m_Image = texture;
	temp.m_Type = DTYPE_IMAGE;
	temp.m_Rotation = glm::vec3(0, 0, angle);
	temp.m_Flag = flipped;
	temp.m_BlendMode = blendmode;

	m_SceneGraph.push_back(temp);
}

void Display::DrawImage(Texture* texture, const float destx, const float desty, const float destw, const float desth, const Color& color, bool flipped, float angle, unsigned int blendmode)
{
	if (angle == 0 && (destx > GetWidth() || desty > GetHeight() || (destx + destw < 0 && desty + desth < 0)))
		return;

	Drawable temp;
	temp.m_X1 = 0;
	temp.m_Y1 = 0;
	temp.m_W1 = texture->GetWidth();
	temp.m_H1 = texture->GetHeight();
	temp.m_X2 = destx;
	temp.m_Y2 = desty;
	temp.m_W2 = destw;
	temp.m_H2 = desth;
	temp.m_Color = color;
	temp.m_Image = texture;
	temp.m_Type = DTYPE_IMAGE;
	temp.m_Rotation = glm::vec3(0, 0, angle);
	temp.m_Flag = flipped;
	temp.m_BlendMode = blendmode;

	m_SceneGraph.push_back(temp);
}

void Display::DrawImage(Texture* texture, const float srcx, const float srcy, const float srcw, const float srch, const float destx, const float desty, const Color& color, bool flipped, float angle, unsigned int blendmode)
{
	if (angle == 0 && (destx > GetWidth() || desty > GetHeight() || (destx + srcw < 0 && desty + srch < 0)))
		return;

	Drawable temp;
	temp.m_X1 = srcx;
	temp.m_Y1 = srcy;
	temp.m_W1 = texture->GetWidth();
	temp.m_H1 = texture->GetHeight();
	temp.m_X2 = destx;
	temp.m_Y2 = desty;
	temp.m_W2 = srcw;
	temp.m_H2 = srch;
	temp.m_Color = color;
	temp.m_Image = texture;
	temp.m_Type = DTYPE_IMAGE;
	temp.m_Rotation = glm::vec3(0, 0, angle);
	temp.m_Flag = flipped;
	temp.m_BlendMode = blendmode;

	m_SceneGraph.push_back(temp);
}

void Display::DrawImage(Texture* texture, const float srcx, const float srcy, const float srcw, const float srch, const float destx, const float desty, const float destw, const float desth, const Color& color, bool flipped, float angle, unsigned int blendmode)
{
	if (angle == 0 && (destx > GetWidth() || desty > GetHeight() || (destx + destw < 0 && desty + desth < 0)))
		return;

	Drawable temp;
	temp.m_X1 = srcx;
	temp.m_Y1 = srcy;
	temp.m_W1 = srcw;
	temp.m_H1 = srch;
	temp.m_X2 = destx;
	temp.m_Y2 = desty;
	temp.m_W2 = destw;
	temp.m_H2 = desth;
	temp.m_Color = color;
	temp.m_Image = texture;
	temp.m_Type = DTYPE_IMAGE;
	temp.m_Rotation = glm::vec3(0, 0, angle);
	temp.m_Flag = flipped;
	temp.m_BlendMode = blendmode;

	m_SceneGraph.push_back(temp);

}

void Display::DrawFontText(Texture* texture, const float srcx, const float srcy, const float srcw, const float srch, const float destx, const float desty, const float destw, const float desth, const Color& color, bool flipped, float angle, unsigned int blendmode)
{
	if (angle == 0 && (destx > GetWidth() || desty > GetHeight() || (destx + destw < 0 && desty + desth < 0)))
		return;

	Drawable temp;
	temp.m_X1 = srcx;
	temp.m_Y1 = srcy;
	temp.m_W1 = srcw;
	temp.m_H1 = srch;
	temp.m_X2 = destx;
	temp.m_Y2 = desty;
	temp.m_W2 = destw;
	temp.m_H2 = desth;
	temp.m_Color = color;
	temp.m_Image = texture;
	temp.m_Type = DTYPE_TEXT;
	temp.m_Rotation = glm::vec3(0, 0, angle);
	temp.m_Flag = flipped;
	temp.m_BlendMode = blendmode;

	m_SceneGraph.push_back(temp);

}

void Display::DrawBox(const int posx, const int posy, const int width, const int height, const Color& color, const bool filled)
{
	Drawable temp;
	temp.m_X1 = posx;
	temp.m_Y1 = posy;
	temp.m_W1 = width;
	temp.m_H1 = height;
	temp.m_Color = color;
	temp.m_Flag = filled;
	temp.m_Type = DTYPE_BOX;

	m_SceneGraph.push_back(temp);
}

void Display::DrawLine(const int posx, const int posy, const int endx, const int endy, float width, const Color& color)
{
	Drawable temp;
	temp.m_X1 = posx;
	temp.m_Y1 = posy;
	temp.m_X2 = endx;
	temp.m_Y2 = endy;
	temp.m_Color = color;
	temp.m_Width = width;
	temp.m_Type = DTYPE_LINE;

	m_SceneGraph.push_back(temp);

}

void Display::DrawMesh(Mesh* mesh, bool is3d, glm::vec3 pos, Texture* tex, const Color& color, glm::vec3 angle, glm::vec3 scale)
{
	Drawable temp;
	temp.m_Mesh = mesh;
	temp.m_Position = pos;
	temp.m_Tex1 = tex;
	temp.m_Color = color;
	temp.m_Rotation = angle;
	temp.m_Scaling = scale;
	temp.m_Type = DTYPE_MESH;

	//  Start
	temp.m_X1 = 0;

	//  Numtris
	if (mesh->IsIndexed())
	{
		temp.m_Y1 = mesh->GetNumberOfIndices() / 3;
	}
	else
	{
		temp.m_Y1 = mesh->GetNumberOfVertices() / 3;
	}
	temp.m_Flag = is3d;

	m_SceneGraph.push_back(temp);
}

void Display::DrawMesh(Mesh* mesh, glm::vec3 pos, Texture* tex, const Color& color, glm::vec3 angle, glm::vec3 scale)
{
	DrawMesh(mesh, true, pos, tex, color, angle, scale);
}

void Display::DrawMesh(Mesh* mesh, bool is3d, int tristart, int numtris, glm::vec3 pos, Texture* tex, const Color& color, glm::vec3 angle, glm::vec3 scale)
{
	Drawable temp;
	temp.m_Mesh = mesh;
	temp.m_Position = pos;
	temp.m_Tex1 = tex;
	temp.m_Color = color;
	temp.m_Rotation = angle;
	temp.m_Scaling = scale;
	temp.m_Type = DTYPE_MESH;
	temp.m_X1 = tristart;
	temp.m_Y1 = numtris;
	temp.m_Flag = is3d;

	m_SceneGraph.push_back(temp);
}

void Display::DrawMesh(Mesh* mesh, int tristart, int numtris, glm::vec3 pos, Texture* tex, const Color& color, glm::vec3 angle, glm::vec3 scale)
{
	DrawMesh(mesh, true, tristart, numtris, pos, tex, color, angle, scale);
}

void Display::DrawPolygon(Texture* texture, const float srcX, const float srcY, const float srcWid, const float srcHei, const float x1, const float topY1, const float x2, const float topY2, const float bottomY, const Color& color, unsigned int blendmode)
{
	Drawable temp;
	temp.m_Tex1 = texture;
	temp.m_Position.x = srcX;
	temp.m_Position.y = srcY;
	temp.m_Position.z = srcWid;
	temp.m_H2 = srcHei;
	temp.m_X1 = x1;
	temp.m_X2 = x2;
	temp.m_Y1 = topY1;
	temp.m_Y2 = topY2;
	temp.m_H1 = bottomY;
	temp.m_Color = color;
	temp.m_Type = DTYPE_POLYGON;
	m_SceneGraph.push_back(temp);
}

//  BEGIN ACTUALS

void Display::DrawImageActual(Texture* texture, const float srcx, const float srcy, const float srcw, const float srch, const float destx, const float desty, const float destw, const float desth, const Color color, const bool flipped, const float angle, unsigned int blendmode)
{
	//  If no texture, problem, abort
	if (!texture)
		return;

	//  Create vertices
	m_VertexList->clear();
	int x = round(destx);
	int y = round(desty);
	int x1 = round(destx + destw);
	int y1 = round(desty + desth);
	float u = srcx / float(texture->GetWidth());
	float v = srcy / float(texture->GetHeight());
	float u1 = (srcx + srcw) / float(texture->GetWidth());
	float v1 = (srcy + srch) / float(texture->GetHeight());

	if (angle == 0 && flipped == false) //  No special actions means we can bake the final coordinates into the vertices.
	{
		m_VertexList->emplace_back(CreateVertex2D(x, y, color.r * color.a, color.g * color.a, color.b * color.a, color.a, u, v)); // Top-left
		m_VertexList->emplace_back(CreateVertex2D(x1, y, color.r * color.a, color.g * color.a, color.b * color.a, color.a, u1, v)); // Top-right
		m_VertexList->emplace_back(CreateVertex2D(x1, y1, color.r * color.a, color.g * color.a, color.b * color.a, color.a, u1, v1)); // Bottom-right
		m_VertexList->emplace_back(CreateVertex2D(x1, y1, color.r * color.a, color.g * color.a, color.b * color.a, color.a, u1, v1)); // Bottom-right
		m_VertexList->emplace_back(CreateVertex2D(x, y1, color.r * color.a, color.g * color.a, color.b * color.a, color.a, u, v1)); // Bottom-left
		m_VertexList->emplace_back(CreateVertex2D(x, y, color.r * color.a, color.g * color.a, color.b * color.a, color.a, u, v)); // Top-left
	}
	else
	{
		m_VertexList->emplace_back(CreateVertex2D(0, 0, color.r * color.a, color.g * color.a, color.b * color.a, color.a, srcx / float(texture->GetWidth()), srcy / float(texture->GetHeight()))); // Top-left
		m_VertexList->emplace_back(CreateVertex2D(destw, 0, color.r * color.a, color.g * color.a, color.b * color.a, color.a, (srcx + srcw) / float(texture->GetWidth()), srcy / float(texture->GetHeight()))); // Top-right
		m_VertexList->emplace_back(CreateVertex2D(destw, desth, color.r * color.a, color.g * color.a, color.b * color.a, color.a, (srcx + srcw) / float(texture->GetWidth()), (srcy + srch) / float(texture->GetHeight()))); // Bottom-right
		m_VertexList->emplace_back(CreateVertex2D(destw, desth, color.r * color.a, color.g * color.a, color.b * color.a, color.a, (srcx + srcw) / float(texture->GetWidth()), (srcy + srch) / float(texture->GetHeight()))); // Bottom-right
		m_VertexList->emplace_back(CreateVertex2D(0, desth, color.r * color.a, color.g * color.a, color.b * color.a, color.a, srcx / float(texture->GetWidth()), (srcy + srch) / float(texture->GetHeight()))); // Bottom-left
		m_VertexList->emplace_back(CreateVertex2D(0, 0, color.r * color.a, color.g * color.a, color.b * color.a, color.a, srcx / float(texture->GetWidth()), srcy / float(texture->GetHeight()))); // Top-left
	}

	if (m_DrawMode != DM_2D)
		Go2D();

	switch (blendmode)
	{
	case BLEND_ADDITIVE:
		glBlendFunc(GL_ONE, GL_ONE);
		break;
	case BLEND_NORMAL:
	default:
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		break;
	}

	glEnable(GL_TEXTURE_2D);

	//  Bind Texture
	glBindTexture(GL_TEXTURE_2D, texture->GetTextureID());

	//  If we don't have mipmaps, we want chunky pixels.
	if (texture->AllowSmoothing())
	{
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}
	else
	{
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	}

	//  Bind Vertex Buffer Object
	glBindBuffer(GL_ARRAY_BUFFER, m_2DVBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex2D) * m_VertexList->size(), m_VertexList->data(), GL_STREAM_DRAW);

	//  Loy out the data
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	glVertexPointer(2, GL_FLOAT, sizeof(GLfloat) * 8, NULL);
	glColorPointer(4, GL_FLOAT, sizeof(GLfloat) * 8, (float*)(sizeof(GLfloat) * 2));
	glTexCoordPointer(2, GL_FLOAT, sizeof(GLfloat) * 8, (float*)(sizeof(GLfloat) * 6));

	//  Draw
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();

	//  Okay, the destx and desty come in as floats, for greater precision, but in the end they have to be converted to ints.
	//  But how to convert them?  I was just casting, but that chops off the fractional part when the fractional part is actually very important.

	if (angle != 0)
	{
		if (flipped)
		{
			glTranslatef(round(destx + float(destw) / 2.0f), round(desty + float(desth) / 2.0f), 0);
			glRotatef(angle, 0.0f, 0.0f, 1.0f);
			glTranslatef(round(float(destw) / 2.0f), -round(float(desth) / 2.0f), 0);
			glScalef(-1, 1, 1);
		}
		else
		{
			glTranslatef(x + round(float(destw) / 2.0f), y + round(float(desth) / 2.0f), 0);
			glRotatef(angle, 0.0f, 0.0f, 1.0f);
			glTranslatef(-round(float(destw) / 2.0f), -round(float(desth) / 2.0f), 0);
			glScalef(1, 1, 1);
		}
	}
	else
	{
		if (flipped)
		{
			glTranslatef(x1, y, 0);
			glScalef(-1, 1, 1);
		}
	}

	glDrawArrays(GL_TRIANGLES, 0, 6);

	glPopMatrix();

	//  Clean up
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);

	glDisable(GL_TEXTURE_2D);

	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

	m_LastMesh = NULL;
}

void Display::DrawPolygonActual(Texture* texture, const float srcX, const float srcY, const float srcWid, const float srcHei, const float x1, const float topY1, const float x2, const float topY2, const float bottomY, const Color& color)
{
	if (m_DrawMode != DM_2D)
		Go2D();

	//  If no texture, problem, abort
	if (!texture)
		return;

	glEnable(GL_TEXTURE_2D);

	//  Bind Texture
	glBindTexture(GL_TEXTURE_2D, texture->GetTextureID());

	//  If we don't have mipmaps, we want chunky pixels.
	if (texture->AllowSmoothing())
	{
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}
	else
	{
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	}

	//  Create vertices
	m_VertexList->clear();
	m_VertexList->emplace_back(CreateVertex2D(x1, topY1, color.r * color.a, color.g * color.a, color.b * color.a, color.a, srcX / float(texture->GetWidth()), srcY / float(texture->GetHeight())));
	m_VertexList->emplace_back(CreateVertex2D(x2, topY2, color.r * color.a, color.g * color.a, color.b * color.a, color.a, (srcX + srcWid) / float(texture->GetWidth()), srcY / float(texture->GetHeight()))); // Top-right
	m_VertexList->emplace_back(CreateVertex2D(x2, bottomY, color.r * color.a, color.g * color.a, color.b * color.a, color.a, (srcX + srcWid) / float(texture->GetWidth()), (srcY + srcHei) / float(texture->GetHeight()))); // Bottom-right
	m_VertexList->emplace_back(CreateVertex2D(x2, bottomY, color.r * color.a, color.g * color.a, color.b * color.a, color.a, (srcX + srcWid) / float(texture->GetWidth()), (srcY + srcHei) / float(texture->GetHeight()))); // Bottom-right
	m_VertexList->emplace_back(CreateVertex2D(x1, bottomY, color.r * color.a, color.g * color.a, color.b * color.a, color.a, srcX / float(texture->GetWidth()), (srcY + srcHei) / float(texture->GetHeight()))); // Bottom-left
	m_VertexList->emplace_back(CreateVertex2D(x1, topY1, color.r * color.a, color.g * color.a, color.b * color.a, color.a, srcX / float(texture->GetWidth()), srcY / float(texture->GetHeight()))); // Top-left

	//  Bind Vertex Buffer Object
	glBindBuffer(GL_ARRAY_BUFFER, m_2DVBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex2D) * m_VertexList->size(), m_VertexList->data(), GL_STREAM_DRAW);

	//  Loy out the data
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	glVertexPointer(2, GL_FLOAT, sizeof(GLfloat) * 8, NULL);
	glColorPointer(4, GL_FLOAT, sizeof(GLfloat) * 8, (float*)(sizeof(GLfloat) * 2));
	glTexCoordPointer(2, GL_FLOAT, sizeof(GLfloat) * 8, (float*)(sizeof(GLfloat) * 6));

	//  Draw
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();

	glScalef(1, 1, 1);

	glDrawArrays(GL_TRIANGLES, 0, 6);

	glPopMatrix();

	//  Clean up
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);

	glDisable(GL_TEXTURE_2D);

	m_LastMesh = NULL;
}

void Display::DrawMeshActual(Mesh* mesh, bool is3D, int tristart, int numtris, glm::vec3 pos, Texture* tex, Color color, glm::vec3 angle, glm::vec3 scale)
{
	if (m_DrawMode != DM_3D)
		Go3D();

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_ALPHA_TEST);

	if (tex)
	{
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, tex->GetTextureID());
	}

	//  Don't need to bind VAO or VBO if we're drawing the same mesh again in a different location.
	if (m_LastMesh != mesh)
	{
		//  Bind Vertex Buffer Object
		glBindBuffer(GL_ARRAY_BUFFER, mesh->GetVertexBufferID());

		//  If indexed, bind index buffer.
		if (mesh->IsIndexed())
		{
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh->GetIndexBufferID());
		}
		m_LastMesh = mesh;
	}

	if (color != Color(1, 1, 1, 1))
	{
		glBlendFunc(GL_CONSTANT_COLOR, GL_ONE_MINUS_SRC_COLOR);
		glBlendColor(color.r, color.g, color.b, color.a);
		glAlphaFunc(GL_GEQUAL, 1);
	}

	//  Loy out the data
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	glVertexPointer(3, GL_FLOAT, sizeof(GLfloat) * 9, NULL);
	glColorPointer(4, GL_FLOAT, sizeof(GLfloat) * 9, (float*)(sizeof(GLfloat) * 3));
	glTexCoordPointer(2, GL_FLOAT, sizeof(GLfloat) * 9, (float*)(sizeof(GLfloat) * 7));

	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	m_3DModelView = glm::lookAt(m_CamPos, m_CamLookAt, m_CamUp);
	glMultMatrixf(glm::value_ptr(m_3DModelView));
	glTranslatef(pos.x, pos.y, pos.z);
	glRotatef(angle.x, 1, 0, 0);
	glRotatef(angle.y, 0, 1, 0);
	glRotatef(angle.z, 0, 0, 1);
	glScalef(scale.x, scale.y, scale.z);

	if (mesh->IsIndexed())
	{
		if (m_Debugging)
			glDrawElements(GL_LINES, numtris * 3, GL_UNSIGNED_INT, (GLvoid*)(tristart * 3 * sizeof(unsigned int)));
		else
			glDrawElements(GL_TRIANGLES, numtris * 3, GL_UNSIGNED_INT, (GLvoid*)(tristart * 3 * sizeof(unsigned int)));
	}
	else
	{
		if (m_Debugging)
			glDrawArrays(GL_LINES, tristart * 3, numtris * 3);
		else
			glDrawArrays(GL_TRIANGLES, tristart * 3, numtris * 3);

	}
	glPopMatrix();

	//  Clean up
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);

	glDisable(GL_DEPTH_TEST);
	glDisable(GL_ALPHA_TEST);

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glAlphaFunc(GL_ALWAYS, 0);
	glDisable(GL_TEXTURE_2D);
}

void Display::DrawBoxActual(const int posx, const int posy, const int width, const int height, const Color color, const bool filled)
{
	if (m_DrawMode != DM_2D)
		Go2D();

	glDisable(GL_DEPTH_TEST);
	glDisable(GL_TEXTURE_2D);

	//  Build the box - position and color
	if (filled)
	{
		float vertices[] = {
		   (float)posx + .5f, (float)posy + .5f, color.r, color.g, color.b, color.a, // Top-left
		   (float)posx + (float)width + .5f, (float)posy + .5f, color.r, color.g, color.b, color.a, // Top-right
		   (float)posx + .5f, (float)posy + (float)height + .5f, color.r, color.g, color.b, color.a, // Bottom-left
		   (float)posx + (float)width + .5f, (float)posy + (float)height + .5f, color.r, color.g, color.b, color.a, // Bottom-right
		   (float)posx + .5f, (float)posy + (float)height + .5f, color.r, color.g, color.b, color.a, // Bottom-left
		   (float)posx + (float)width + .5f, (float)posy + .5f, color.r, color.g, color.b, color.a // Top-right
		};

		glBindBuffer(GL_ARRAY_BUFFER, m_2DVBO);
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STREAM_DRAW);
	}
	else
	{
		float vertices[] = {
		   posx + .5f, posy + .5f, color.r, color.g, color.b, color.a, // Top-left
		   posx + width + .5f, posy + .5f, color.r, color.g, color.b, color.a, // Top-right
		   posx + width + .5f, posy + height + .5f, color.r, color.g, color.b, color.a, // Bottom-right
		   posx + .5f, posy + height + .5f, color.r, color.g, color.b, color.a // Bottom-left
		};

		glBindBuffer(GL_ARRAY_BUFFER, m_2DVBO);
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STREAM_DRAW);
	}

	//  Loy out the data
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);

	glVertexPointer(2, GL_FLOAT, sizeof(GLfloat) * 6, NULL);
	glColorPointer(4, GL_FLOAT, sizeof(GLfloat) * 6, (float*)(sizeof(GLfloat) * 2));

	//  Draw
	if (filled)
	{
		glDrawArrays(GL_TRIANGLES, 0, 6);
	}
	else
	{
		glDrawArrays(GL_LINE_LOOP, 0, 4);
	}

	//  Clean up
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);

	m_LastMesh = NULL;
}

void Display::DrawLineActual(const int posx, const int posy, const int endx, const int endy, const float width, const Color color)
{
	if (m_DrawMode != DM_2D)
		Go2D();

	glDisable(GL_DEPTH_TEST);
	glLineWidth(width);
	//  Build the line - position and color
	float vertices[] = {
		//  Position   Color
		(float)posx, (float)posy, color.r, color.g, color.b, color.a,
		(float)endx, (float)endy, color.r, color.g, color.b, color.a
	};
	glBindBuffer(GL_ARRAY_BUFFER, m_2DVBO);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STREAM_DRAW);

	//  Loy out the data
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);

	glVertexPointer(2, GL_FLOAT, sizeof(GLfloat) * 6, NULL);
	glColorPointer(4, GL_FLOAT, sizeof(GLfloat) * 6, (float*)(sizeof(GLfloat) * 2));

	// Draw a line
	glDrawArrays(GL_LINES, 0, 2);

	//  Clean up
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	glLineWidth(1);
	m_LastMesh = NULL;
}

void Display::DrawPerfCounter(std::shared_ptr<Font>& m_Font, int loc)
{
	int vpos = 0;
	int hpos = 0;
	int width = m_HRes * .20f;
	int height = m_VRes * .14f;

	switch (loc)
	{
	case 0: // Bottom-left
		hpos = 0;
		vpos = m_VRes - height;
		break;

	case 1: // Top-left
		hpos = 0;
		vpos = 0;
		break;

	case 2: // Bottom-right
		hpos = m_HRes - width;
		vpos = m_VRes - height;
		break;

	case 3: // Top-right
		hpos = m_HRes - width;
		vpos = 0;
		break;
	}

	DrawBox(hpos, vpos, width, height, Color(0, 0, 0, 1), true);
	DrawBox(hpos, vpos, width, height, Color(0, 0, .75, 1), false);

	stringstream perf_temp;
	perf_temp.str(string());
	perf_temp << (int)g_Engine->m_FrameRate << " fps (" << g_Engine->m_MillisecondsThisFrame << " mspf)";
	if (m_Font)
	{
		m_Font->DrawString(perf_temp.str(), hpos + (width * .05f), vpos + height - (m_Font->GetHeight() * 1.01f));
	}

	m_Font->DrawString("Draw", hpos + (width * .05f), vpos, Color(0, 1, 0, 1));
	m_Font->DrawString("Update", hpos + (width * .3f), vpos, Color(1, 1, 0, 1));
	m_Font->DrawString("Network", hpos + (width * .65f), vpos, Color(.5, .5, 1, 1));

	int perf_i;
	/*   for (perf_i = 0; perf_i < 50 - 1; perf_i++)
	{
	float h = (g_Engine->m_Frames[(g_Engine->m_CurrentFrame + perf_i + 1) % 50] - g_Engine->m_Frames[(g_Engine->m_CurrentFrame + perf_i) % 50]);
	DrawBox(perf_i * 4 + 8, vpos - h - 40, 3, h, Color(1, 0, 0, 1), true);
	}*/

	for (perf_i = 0; perf_i < 50 - 1; perf_i++)
	{
		int h = g_Engine->m_DrawFrames[perf_i];
		DrawBox(hpos + (perf_i * (width * .019f)) + (width * .05f), vpos + (height * .95f) - h - 12, 3, h, Color(0, 1, 0, 1), true);
	}

	for (perf_i = 0; perf_i < 50 - 1; perf_i++)
	{
		int h = (g_Engine->m_UpdateFrames[perf_i]);
		int h2 = (g_Engine->m_DrawFrames[perf_i]);
		DrawBox(hpos + (perf_i * (width * .019f)) + (width * .05f), vpos + (height * .95f) - h - h2 - 12, 3, h, Color(1, 1, 0, 1), true);
	}
	//    (float)(perf_data[perf_idx] - perf_data[(perf_idx+1) % PERF_FRAMES]) / PERF_FRAMES
}

void Display::Update()
{
	if (m_CameraChanged)
	{
		UpdateCamera();
	}
}

void Display::Draw()
{
	glViewport(0, 0, m_HRes, m_VRes);
	for (auto& node : m_SceneGraph)
	{
		switch (node.m_Type)
		{
		default:
		case DTYPE_NONE:
		{
			throw ("Bad entry in scene graph!");
		}

		case DTYPE_BOX:
		{
			DrawBoxActual(node.m_X1, node.m_Y1, node.m_W1, node.m_H1, node.m_Color, node.m_Flag);
			break;
		}

		case DTYPE_LINE:
		{
			DrawLineActual(node.m_X1, node.m_Y1, node.m_X2, node.m_Y2, node.m_Width, node.m_Color);
			break;
		}

		case DTYPE_IMAGE:
		{
			DrawImageActual(node.m_Image, node.m_X1, node.m_Y1, node.m_W1, node.m_H1, node.m_X2, node.m_Y2, node.m_W2, node.m_H2, node.m_Color, node.m_Flag, node.m_Rotation.z, node.m_BlendMode);
			break;
		}

		case DTYPE_POLYGON:
		{
			DrawPolygonActual(node.m_Tex1, node.m_Position.x, node.m_Position.y, node.m_Position.z, node.m_H2,
				node.m_X1, node.m_Y1, node.m_X2, node.m_Y2, node.m_H1, node.m_Color);
			break;
		}
		case DTYPE_MESH:
		{
			DrawMeshActual(node.m_Mesh, node.m_Flag, node.m_X1, node.m_Y1, node.m_Position, node.m_Tex1, node.m_Color, node.m_Rotation, node.m_Scaling);
			break;
		}

		case DTYPE_TEXT:
		{
			DrawImageActual(node.m_Image, node.m_X1, node.m_Y1, node.m_W1, node.m_H1, node.m_X2, node.m_Y2, node.m_W2, node.m_H2, node.m_Color, node.m_Flag, node.m_Rotation.z, node.m_BlendMode);
			break;
		}
		}
	}

	m_SceneGraph.clear();
	SDL_GL_SwapWindow(m_Screen);
}

void Display::Shutdown()
{
	SDL_DestroyWindow(m_Screen);
	SDL_Quit();
}

void Display::ChangeToFullscreen()
{
	g_Engine->m_EngineConfig.SetNumber("full_screen", 1);
	g_Engine->m_EngineConfig.Save();
}

void Display::ChangeToWindowed()
{
	g_Engine->m_EngineConfig.SetNumber("full_screen", 0);
	g_Engine->m_EngineConfig.Save();
}

glm::mat4 Display::GetProjectionMatrix()
{
	return m_3DProj;
}

glm::mat4 Display::GetModelViewMatrix()
{
	return m_3DModelView;
}




