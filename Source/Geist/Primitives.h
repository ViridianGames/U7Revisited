#ifndef _PRIMITIVES_H_
#define _PRIMITIVES_H_

#include <string>
#include <vector>
#include <math.h>
#include <memory>
#include <unordered_map>
#include "Object.h"

#include "GL/glew.h"
#ifdef _WINDOWS
#include <Windows.h>
#include <gl/gl.h>
#elif defined __APPLE__
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

//  Define some basic values and tools...
#define PI (3.141592654f)
#define Deg2Rad(a) ((a)*PI/180)
#define Rad2Deg(a) ((a)*180/PI)
#define Blend(_a, _b, _c) ( (_a)*(1-(_c)) + (_b)*(_c) )
#define ByteBlend(_a, _b, _c) ( (((_a)*(256-(_c)) + ((_b)*(_c))) >> 8) )

//  Yes, this is bad OOP, but accessors on such a simple class whose members
//  will be CONSTANTLY accessed is just stupid.  All it does is require you
//  to write more code.

class Point
{
public:
	Point(float x, float y) : X(x), Y(y) {};
	Point() : X(0), Y(0) {};

	float DistanceTo(Point dest) { return (sqrt((X - dest.X) * (X - dest.X) + (Y - dest.Y) * (Y - dest.Y))); }
	bool IsDistanceLessThan(Point dest, float dist) { return (dist * dist > ((X - dest.X) * (X - dest.X) + (Y - dest.Y) * (Y - dest.Y))); }
	float AngleBetween(Point dest);

	void Normalize();

	Point& operator=(const Point& rhs);
	Point& operator+=(const Point& rhs);
	Point operator+(const Point& rhs);
	Point& operator-=(const Point& rhs);
	Point operator-(const Point& rhs);
	Point operator*(const Point& rhs);
	Point operator*(const float mult);
	bool operator==(const Point& rhs) { return (X == rhs.X) && (Y == rhs.Y); }
	bool operator!=(const Point& rhs) { return !((X == rhs.X) && (Y == rhs.Y)); }

	float X;
	float Y;
};

class Rect : public Point
{
public:
	Rect(float x, float y, float width, float height) : W(width), H(height) { X = x; Y = y; };
	Rect() : W(0), H(0) { X = 0; Y = 0; };
	Rect& operator=(const Rect& rhs);

	Point GetCenter(void);
	bool Overlaps(Rect collider);
	bool Contains(Point collider);
	//  This version allows you to find out exactly how much the two rects interpenetrated.
	bool Overlaps(Rect collider, Rect& collisiondata);

	float W;
	float H;
};

class Color
{
public:
	Color() { r = 1.0f; g = 1.0f; b = 1.0f; a = 1.0f; }

	//Color(int rin, int gin, int bin, int ain)
	//{
	//   float frin = float(rin);
	//   float fgin = float(gin);
	//   float fbin = float(bin);
	//   float fain = float(ain);

	//   Color(frin, fgin, fbin, fain);
	//}

	Color(float rin, float gin, float bin, float ain)
	{
		//  We're using the 0-255 scale, rectify to 0-1
		if (rin > 1 || gin > 1 || bin > 1 || ain > 1)
		{
			rin = rin / 255.0f;
			gin = gin / 255.0f;
			bin = bin / 255.0f;
			ain = ain / 255.0f;
		}

		if (rin < 0.0f) rin = 0.0f;
		if (rin > 1.0f) rin = 1.0f;

		if (gin < 0.0f) gin = 0.0f;
		if (gin > 1.0f) gin = 1.0f;

		if (bin < 0.0f) bin = 0.0f;
		if (bin > 1.0f) bin = 1.0f;

		if (ain < 0.0f) ain = 0.0f;
		if (ain > 1.0f) ain = 1.0f;

		r = rin;
		g = gin;
		b = bin;
		a = ain;
	}

	bool operator == (const Color& inColor)
	{
		return (inColor.r == r && inColor.g == g &&
			inColor.b == b && inColor.a == a);
	}

	bool operator != (const Color& inColor)
	{
		return (inColor.r != r || inColor.g != g ||
			inColor.b != b || inColor.a != a);
	}

	void operator = (const unsigned int color)
	{
		//  HTML-style hex color
		if (color <= 0xFFFFFF)
		{
			a = 1.0f;
			b = (color & 0xFF) / 255.0f;
			g = ((color >> 8) & 0xFF) / 255.0f;
			r = ((color >> 16) & 0xFF) / 255.0f;
		}
		//  RGBA color.
		else
		{
			a = (color & 0xFF) / 255.0f;
			b = ((color >> 8) & 0xFF) / 255.0f;
			g = ((color >> 16) & 0xFF) / 255.0f;
			r = ((color >> 24) & 0xFF) / 255.0f;
		}
	}

	void operator = (const Color& inColor)
	{
		if (&inColor == this)
			return;

		r = inColor.r;
		g = inColor.g;
		b = inColor.b;
		a = inColor.a;
	}

	unsigned int GetHex();

	Color Interpolate(Color other, float percent)
	{
		return Color(
			this->r + (other.r - this->r) * percent,
			this->g + (other.g - this->g) * percent,
			this->b + (other.b - this->b) * percent,
			this->a + (other.a - this->a) * percent);
	};
	/*   Color ( float rin, float gin, float bin, float ain )
	{
	   r = max ( rin * 255, 255 );
	   g = max ( gin * 255, 255 );
	   b = max ( bin * 255, 255 );
	   a = max ( bin * 255, 255 );
	}*/


	float r;
	float g;
	float b;
	float a;
};

struct Vertex
{
	float x, y, z, r, g, b, a, u, v;
};

Vertex CreateVertex(float inx = 0, float iny = 0, float inz = 0,
	float inr = 1, float ing = 1, float inb = 1, float ina = 1,
	float inu = 0, float inv = 0);

Vertex CreateVertex(float inx = 0, float iny = 0, float inz = 0,
	Color color = Color(1, 1, 1, 1),
	float inu = 0, float inv = 0);

struct Vertex2D
{
	float x, y, r, g, b, a, u, v;
};

Vertex2D CreateVertex2D(float inx = 0, float iny = 0, float inr = 1,
	float ing = 1, float inb = 1, float ina = 1, float inu = 0,
	float inv = 0);

Vertex2D CreateVertex2D(float inx = 0, float iny = 0,
	Color color = Color(1, 1, 1, 1),
	float inu = 0, float inv = 0);

class ColoredString
{
public:
	ColoredString(std::string instring = "", Color color = Color(1, 1, 1, 1)) { m_String = instring; m_Color = color; }
	std::string m_String;
	Color m_Color;
};

/*class Vertex
{
public:
   Vertex(){};
   Vertex( glm::glm::vec3 thispos, glm::glm::vec3 thisnormal, Color thiscolor = Color(1.0f, 1.0f, 1.0f, 1.0f),
	  float theu = 0, float thev = 0, float theu2 = 0, float thev2 = 0 )
   { pos = thispos; normal = thisnormal; color = thiscolor; u = theu; v = thev; u2 = theu2; v2 = thev2; }

   glm::glm::vec3 pos;
   glm::glm::vec3 normal;
   Color color;
   float u, v;
   float u2, v2;
};*/

class Texture
{
private:
	int m_Width;
	int m_Height;
	std::string m_Filename;
	std::unique_ptr < std::vector<unsigned char> > m_PixelData;
	GLuint m_Texture;
	GLuint m_VBO;
	bool   m_AllowSmoothing;
	bool   m_Loaded;
	bool   m_IsMipMapped;

public:
	Texture();
	~Texture();
	void Load(const std::string& fileName, bool mipmaps = true);
	void Reload();
	void Create(int w, int h, bool mipmaps = true);
	void PutPixel(int x, int y, Color color);
	void PutPixel(int x, int y, unsigned int color);
	Color GetPixel(int x, int y);
	void UpdateData();
	void MakeVertexBuffer();
	int GetWidth() { return m_Width; }
	int GetHeight() { return m_Height; }
	bool WasLoaded() { return m_Loaded; }
	bool AllowSmoothing() { return m_AllowSmoothing; }
	bool IsMipMapped() { return m_IsMipMapped; }
	unsigned int GetTextureID() { return m_Texture; }
	unsigned char* GetPixelData() { return m_PixelData->data(); }
	std::string GetFileName() { return m_Filename; }
};

class Sprite
{
public:
	Texture* m_Texture;

	int m_PosX; //  Position within the texture, used to split sprites out of a single texture.
	int m_PosY;

	int m_Width;
	int m_Height;

	Sprite() { m_Texture = nullptr; }
	Sprite(Texture* texture, int posx, int posy, int width, int height) { m_Texture = texture; m_PosX = posx; m_PosY = posy; m_Width = width; m_Height = height; }
};

//  A "tween" is a point that moves between a start and destination point in a programmable way.
class Tween : public Object
{
public:
	Tween() {};
	void Init(const std::string& data) { throw("Tweens can't be initialized from data (yet)."); }
	void Init(Point start, Point dest, float speed, float acceleration)
	{
		m_Pos = m_Start = start;
		m_Dest = dest;
		m_Speed = speed;
		m_Acceleration = 1.0f;
		m_OvershootCount = 0;
	}

	virtual void Update();
	virtual void Draw() {};
	virtual void Shutdown() {};

	void Reverse();       // Swaps the pos and dest of an element, allowing it to move back and forth.
	void PopToStart() { m_Pos = m_Start; }
	void PopToDestination() { m_Pos = m_Dest; }
	bool Done() { return m_Done; }

	Point m_Start;        //  Need to know where the sprite started for certain movement types
	Point m_Pos;
	Point m_Dest;         //  Where the sprite wants to be.
	float m_Speed = 0;        //  How fast it's going to try to get there.
	float m_Acceleration = 0;
	float m_AccelerationPerSecond = 0;
	int   m_MoveType = MOVE_NORMAL;
	int   m_OvershootCount = 0;
	bool  m_Done = false;

	enum
	{
		MOVE_NORMAL = 0,  // Move to the target at specified speed.  Stop when we get there.
		MOVE_EASING, //  Move to the target at specified speed, slowing down to a stop as we arrive.
		MOVE_BOUNCE, //  Move to the target at specified speed and acceleration, halving acceleration and reversing direction when we reach the target until speed = 0;
		MOVE_PARABOLIC,
		MOVE_LASTMOVE
	};
};

class MobileSprite : public Tween
{
public:
	MobileSprite() {};
	void Init(Sprite sprite, Point start, Point dest, float speed, float acceleration);
	void Update();
	void Draw();
	void Shutdown() {};

	std::shared_ptr<Sprite> m_Sprite;
};

//  An animation is a group of sprites, along with the order in which they should be displayed and the frame rate they should be displayed.
class Animation
{
public:
	Animation() { }
	void AddFrames(Texture* texture, int posx, int posy, int width, int height, int numFrames);
	void AddFrame(std::shared_ptr<Sprite> sprite) { m_Frames.push_back(sprite); }
	void AddFrames(std::vector<std::shared_ptr<Sprite> > frames) { m_Frames = frames; }
	void AddFramesSpaced(Texture* texture, int posx, int posy, int width, int height, int numFrames, int xstep);
	void AddAnim(std::string name, std::initializer_list<int> frames, int frameRate, bool looping);
	void AddAnim(std::string name, std::vector<int> frames, int frameRate, bool looping);
	void Update();
	void Play(std::string animName, int starttime = 0, int elapsedtime = 0);
	std::string GetCurrentAnim() { return m_CurrentAnim; }
	bool GetDone() { return m_Done; }
	std::shared_ptr<Sprite> GetCurrentFrame();
	std::shared_ptr<Sprite> GetFrame(int frame);
	std::shared_ptr<Sprite> GetRawFrame(int frame);
	int GetElapsedTime() { return m_ElapsedTime; }
	int GetCurrentFrameNumber();
	void Save(std::ostream& stream);
	void Load(std::istream& stream);

private:

	//  An "anim" denotes the name, frame order and frame rate of an animation.
	//  An animation can have multiple anims, but only one anim can be played
	//  at a time.
	struct Anim
	{
		Anim() { m_Looping = false; }
		Anim(std::initializer_list<int> frameOrder, int frameRate, bool looping) { m_FrameOrder = frameOrder; m_FrameRate = frameRate; m_Looping = looping; m_MSPerFrame = int(m_FrameOrder.size()) / 1000; }
		Anim(std::vector<int> frameOrder, int frameRate, bool looping) { m_FrameOrder = frameOrder; m_FrameRate = frameRate; m_Looping = looping; m_MSPerFrame = int(m_FrameOrder.size()) / 1000; }
		std::vector<int> m_FrameOrder;
		int m_FrameRate = 0;
		bool m_Looping;
		int m_MSPerFrame;
	};

	std::vector<std::shared_ptr<Sprite> > m_Frames;
	std::unordered_map<std::string, Anim> m_Anims;
	std::string m_CurrentAnim = "";
	int m_StartTime = 0;
	int m_ElapsedTime = 0;
	int m_FrameCounter = 0;
	bool m_Done = false;
};

enum MeshTypes
{
	MT_STATIC = 0,
	MT_DYNAMIC,
	MT_STREAMING,

	MT_LASTMESHTYPE
};

class Mesh
{
private:
	int m_NumberOfVertices;
	std::vector<Vertex> m_Vertices;
	float* m_VertexPointer;

	int m_NumberOfIndices;
	std::vector<unsigned int> m_Indices;
	unsigned int* m_IndexPointer;

	int m_DrawMode; // Static, Dynamic or Streaming;

	GLuint m_VBO;     //  Vertex Buffer
	GLuint m_EBO;     //  Index buffer
	GLuint m_Shader;  //  Compiled vertex and fragment shader.

	bool m_Indexed;

public:

	Mesh();
	~Mesh();

	void Init(std::vector<Vertex> vertices, int meshtype = MT_STATIC);
	void Init(std::vector<Vertex> vertices, std::vector<unsigned int> indices, int meshtype = MT_STATIC);
	void Load(const std::string meshname);

	void UpdateVertices(int offset, std::vector<Vertex> vertices);
	void UpdateVertices(std::vector<Vertex> vertices) { UpdateVertices(0, vertices); }

	void UpdateIndices(std::vector<unsigned int> indices);

	Vertex GetVertex(int offset);
	void SetVertex(int offset, Vertex vertex) { m_Vertices[offset] = vertex; }

	bool IsIndexed();
	unsigned int GetVertexBufferID();
	unsigned int GetIndexBufferID();

	int GetNumberOfIndices();
	int GetNumberOfVertices();

	//  This function assumes that the ray is in the same space as the raw model data.
	bool SelectCheck(glm::vec3 position, float angle, glm::vec3 scaling);
	bool SelectCheck(int tristart, int numtris, glm::vec3 position, float angle, glm::vec3 scaling);
};

class SpriteSheet
{
public:

	Texture* m_Texture;
	Mesh* m_Mesh;
	int m_Columns;
	int m_Rows;
	int m_ColumnWidth;
	int m_RowHeight;

	SpriteSheet(Texture* texture, int columns, int rows);
	void DrawSprite(int spritex, int spritey, int posx, int posy);
};

#endif