#ifndef _PRIMITIVES_H_
#define _PRIMITIVES_H_

#include <string>
#include <vector>
#include <math.h>
#include <memory>
#include <unordered_map>
#include "Object.h"
#include "raylib.h"

struct Color;

struct Vertex
{
	float x, y, z, r, g, b, a, u, v;
};

Vertex CreateVertex(float inx = 0, float iny = 0, float inz = 0,
	float inr = 1, float ing = 1, float inb = 1, float ina = 1,
	float inu = 0, float inv = 0);

Vertex CreateVertex(float inx = 0, float iny = 0, float inz = 0,
	Color color = ColorFromNormalized(Vector4{ 1, 1, 1, 1 }),
	float inu = 0, float inv = 0);

struct Vertex2D
{
	float x, y, r, g, b, a, u, v;
};

Vertex2D CreateVertex2D(float inx = 0, float iny = 0, float inr = 1,
	float ing = 1, float inb = 1, float ina = 1, float inu = 0,
	float inv = 0);

Vertex2D CreateVertex2D(float inx = 0, float iny = 0,
	Color color = ColorFromNormalized(Vector4{ 1, 1, 1, 1 }),
	float inu = 0, float inv = 0);

class ColoredString
{
public:
	ColoredString(std::string instring = "", Color color = ColorFromNormalized(Vector4{ 1.0f, 1.0f, 1.0f, 1.0f })) { m_String = instring; m_Color = color; }
	std::string m_String;
	Color m_Color;
};

class Sprite
{
public:
	Texture* m_texture;

	Rectangle m_sourceRect;

	Sprite() { m_texture = nullptr; m_sourceRect.x = 0; m_sourceRect.y = 0; m_sourceRect.width = 0; m_sourceRect.height = 0; }
	Sprite(Texture* texture, float posx, float posy, float width, float height) { m_texture = texture; m_sourceRect.x = posx; m_sourceRect.y = posy; m_sourceRect.width = width; m_sourceRect.height = height; }
	Sprite(Texture* texture, int posx, int posy, int width, int height) { m_texture = texture; m_sourceRect.x = float(posx); m_sourceRect.y = float(posy); m_sourceRect.width = float(width); m_sourceRect.height = float(height);	}

	void Draw(float x, float y, Color tint = WHITE);
	void Draw(Vector2 pos, Color tint = WHITE);
	void DrawScaled(Rectangle dest, Vector2 origin = Vector2{ 0, 0 }, float rotation = 0, Color tint = WHITE);
};

//  A "tween" is a point that moves between a start and destination point in a programmable way.
class Tween : public Object
{
public:
	Tween()
		: m_Start({ 0.0f, 0.0f })
		, m_Pos({ 0.0f, 0.0f })
		, m_Dest({ 0.0f, 0.0f })
	{}
	void Init(const std::string& data) { throw("Tweens can't be initialized from data (yet)."); }
	void Init(Vector2 start, Vector2 dest, float speed, float acceleration)
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

	Vector2 m_Start;        //  Need to know where the sprite started for certain movement types
	Vector2 m_Pos;
	Vector2 m_Dest;         //  Where the sprite wants to be.
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
	void Init(Sprite sprite, Vector2 start, Vector2 dest, float speed, float acceleration);
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
		Anim() : m_MSPerFrame(0), m_Looping(false) { }
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

class ModTexture // A texture with an associated image that can be modified after creation.
{
public:
	ModTexture()
		: m_Image({ 0 })
		, m_OriginalImage({ 0 })
		, m_Texture({ 0 })
		, width(0)
		, height(0)
	{ }
	ModTexture(char* image) { AssignImage(image); }
	ModTexture(Image img) { AssignImage(img); }
	void AssignImage(char* image);
	void AssignImage(Image img);

	Image m_Image;
	Image m_OriginalImage;
	Texture m_Texture;

	int width;
	int height;

	void MoveImageRowLeft(int row);
	void MoveImageRowRight(int row);
	void MoveImageColumnUp(int column);
	void MoveImageColumnDown(int column);

	void ResizeImage(float newWidth, float newHeight);

	void Reset();

	void UpdateTexture();
};

#endif