#include <fstream>
#include <cstring>

#include "Primitives.h"
#include "Globals.h"
#include "SDL.h"
#include "Logging.h"

#define STB_IMAGE_IMPLEMENTATION

#include "stb_image.h"

using namespace std;
using namespace glm;

Point& Point::operator=(const Point& rhs)
{
	if (this == &rhs)
		return *this; // No assignment to self

	X = rhs.X;
	Y = rhs.Y;
	return *this;
}

Point& Point::operator+=(const Point& rhs)
{
	X += rhs.X;
	Y += rhs.Y;

	return *this;
}

Point Point::operator+(const Point& rhs)
{
	Point final;
	final.X = X + rhs.X;
	final.Y = Y + rhs.Y;
	return final;
}

Point& Point::operator-=(const Point& rhs)
{
	X -= rhs.X;
	Y -= rhs.Y;

	return *this;
}

Point Point::operator-(const Point& rhs)
{
	Point final;
	final.X = X - rhs.X;
	final.Y = Y - rhs.Y;
	return final;
}

Point Point::operator*(const Point& rhs)
{
	Point final;
	final.X *= rhs.X;
	final.Y *= rhs.Y;

	return final;
}

Point Point::operator*(float mult)
{
	Point final;
	final.X *= mult;
	final.Y *= mult;

	return final;
}

void Point::Normalize()
{
	float dist = Point(0, 0).DistanceTo(*this);
	X /= dist;
	Y /= dist;
}

float Point::AngleBetween(Point dest)
{
	Point dir = dest - *this;
	dir.Normalize();
	return Rad2Deg(atan2f(dir.Y, dir.X));
}

Rect& Rect::operator=(const Rect& rhs)
{
	if (this == &rhs)
		return *this; // No assignment to self

	X = rhs.X;
	Y = rhs.Y;
	W = rhs.W;
	H = rhs.H;
	return *this;
}

bool Rect::Overlaps(Rect collider)
{
	float left, right, top, bottom; //  This rect's dimensions
	float leftcol, rightcol, topcol, bottomcol;  //  Dimensions of the collider

	left = X;
	right = X + W;
	top = Y;
	bottom = Y + H;

	leftcol = collider.X;
	rightcol = collider.X + collider.W;
	topcol = collider.Y;
	bottomcol = collider.Y + collider.H;

	//  If the bottom of our rect is above the top of the colliding rect, we cannot possibly be colliding.
	if (bottom < topcol)
	{
		return false;
	}

	//  If the top of our rect is below the bottom of the colliding rect, we cannot possibly be colliding.
	if (top > bottomcol)
	{
		return false;
	}

	//  If the right side of our rect is to the left of the leftmost side of the colliding rect, we cannot possibly be colliding.
	if (right < leftcol)
	{
		return false;
	}

	//  If the left side of our rect is to the right of the rightmost side of the colliding rect, we cannot possibly be colliding.
	if (left > rightcol)
	{
		return false;
	}

	//  What do you know, we're colliding.
	return true;
}

bool Rect::Contains(Point collider)
{
	return(collider.X >= X && collider.Y >= Y && collider.X < X + W && collider.Y < Y + H);
}

Point Rect::GetCenter(void)
{
	return Point(X + W / 2.0f, Y + H / 2.0f);
}

//  This function not only returns whether or not they are colliding, it returns the actual location, width and height of the collision.
bool Rect::Overlaps(Rect collider, Rect& collisiondata)
{
	float left, right, top, bottom; //  This rect's dimensions
	float leftcol, rightcol, topcol, bottomcol;  //  Dimensions of the collider
	float roundingError = 0.0000001f;

	left = X;
	right = X + W;
	top = Y;
	bottom = Y + H;

	leftcol = collider.X;
	rightcol = collider.X + collider.W;
	topcol = collider.Y;
	bottomcol = collider.Y + collider.H;

	//  If the bottom of our rect is above the top of the colliding rect, we cannot possibly be colliding.
	if (bottom < topcol + roundingError)
	{
		return false;
	}

	//  If the top of our rect is below the bottom of the colliding rect, we cannot possibly be colliding.
	if (top + roundingError > bottomcol)
	{
		return false;
	}

	//  If the right side of our rect is to the left of the leftmost side of the colliding rect, we cannot possibly be colliding.
	if (right < leftcol + roundingError)
	{
		return false;
	}

	//  If the left side of our rect is to the right of the rightmost side of the colliding rect, we cannot possibly be colliding.
	if (left + roundingError > rightcol)
	{
		return false;
	}

	//  What do you know, we're colliding.
	//  X Collision - Starter is right of collider
	if (leftcol < left && left < rightcol)
	{
		collisiondata.X = left;
		collisiondata.W = (rightcol - left);
	}

	//  X Collision - Starter is left of collider
	if (leftcol < right && right < rightcol)
	{
		collisiondata.X = leftcol;
		collisiondata.W = (rightcol - right);
	}

	//  Y - Starter is below Collider
	if (top > topcol && top < bottomcol)
	{
		collisiondata.Y = top;
		collisiondata.H = (bottomcol - top);
	}

	//  Y - Starter is above Collider
	if (top < topcol && topcol < bottom)
	{
		collisiondata.Y = topcol;
		collisiondata.H = (bottom - topcol);
	}

	return true;
}

void Tween::Update()
{
	//  Already at target
	if (m_Pos.X == m_Dest.X && m_Pos.Y == m_Dest.Y)
	{
		m_Done = true;
		return;
	}

	m_Done = false;
	switch (m_MoveType)
	{
	case MOVE_NORMAL:
	{
		Point dir = m_Dest - Point(m_Pos.X, m_Pos.Y);
		dir.Normalize();

		dir.X *= (m_Speed * g_Engine->LastUpdateInSeconds());
		dir.Y *= (m_Speed * g_Engine->LastUpdateInSeconds());

		Point newPos(m_Pos.X + dir.X, m_Pos.Y + dir.Y);
		Point newDir = m_Dest - newPos;

		//  See if we've overshot; if a sign has changed we've overshot on that dimension. Just pop to the destination.
		if (newDir.X * dir.X < 0)
		{
			m_Pos.X = m_Dest.X;
		}
		else // Otherwise, move to new position
		{
			m_Pos.X = newPos.X;
		}

		if (newDir.Y * dir.Y < 0)
		{
			m_Pos.Y = m_Dest.Y;
		}
		else
		{
			m_Pos.Y = newPos.Y;
		}
	}
	break;

	case MOVE_BOUNCE:
	{
		m_Acceleration += m_AccelerationPerSecond * g_Engine->LastUpdateInSeconds();
		m_Speed += m_Acceleration * g_Engine->LastUpdateInSeconds();

		Point dir = m_Dest - Point(m_Pos.X, m_Pos.Y);
		dir.Normalize();

		dir.X *= (m_Speed * g_Engine->LastUpdateInSeconds());
		dir.Y *= (m_Speed * g_Engine->LastUpdateInSeconds());

		Point newPos(m_Pos.X + dir.X, m_Pos.Y + dir.Y);

		//  See if we've overshot on either x or y.
		if (m_Pos.X < m_Dest.X && newPos.X > m_Dest.X || //  Overshot going right
			m_Pos.X > m_Dest.X && newPos.X < m_Dest.X ||  //  Overshot going left
			m_Pos.Y < m_Dest.Y && newPos.Y > m_Dest.Y ||  //  Overshot going down
			m_Pos.Y > m_Dest.Y && newPos.Y < m_Dest.Y)    //  Overshot going up
		{
			//  Half the speed and reverse it.
			m_Speed = -0.1f * m_Speed;
			m_Acceleration = m_AccelerationPerSecond;
			++m_OvershootCount;
		}
		else // Otherwise, move to new position
		{
			m_Pos.X = newPos.X;
			m_Pos.Y = newPos.Y;
		}
	}
	break;

	case MOVE_PARABOLIC:
	{
		m_Acceleration += m_AccelerationPerSecond * g_Engine->LastUpdateInSeconds();
		m_Speed += m_Acceleration * g_Engine->LastUpdateInSeconds();

		Point dir = m_Dest - Point(m_Pos.X, m_Pos.Y);
		dir.Normalize();

		dir.X *= (m_Speed * g_Engine->LastUpdateInSeconds());
		dir.Y *= (m_Speed * g_Engine->LastUpdateInSeconds());

		Point newPos(m_Pos.X + dir.X, m_Pos.Y + dir.Y);

		//  See if we've overshot on either x or y.
		if (m_Pos.X < m_Dest.X && newPos.X > m_Dest.X || //  Overshot going right
			m_Pos.X > m_Dest.X && newPos.X < m_Dest.X ||  //  Overshot going left
			m_Pos.Y < m_Dest.Y && newPos.Y > m_Dest.Y ||  //  Overshot going down
			m_Pos.Y > m_Dest.Y && newPos.Y < m_Dest.Y)    //  Overshot going up
		{
			if (m_OvershootCount == 0)
			{
				m_Pos = newPos;
				//  Greatly increase the acceleration to pull the item back where it needs to be.
				m_Acceleration = 0;
				m_AccelerationPerSecond *= 12;
				m_Speed = -m_Speed * 0.5f;
			}
			else // Otherwise, move to new position
			{
				m_Pos.X = m_Dest.X;
				m_Pos.Y = m_Dest.Y;
			}
			++m_OvershootCount;
		}
		else
			m_Pos = newPos;
	}
	break;

	case MOVE_EASING:
	{
		Point dir = m_Dest - Point(m_Pos.X, m_Pos.Y);
		dir.Normalize();

		//  Get distance ratio to target
		float start = m_Start.DistanceTo(m_Dest);
		float current = m_Pos.DistanceTo(m_Dest);

		float t = sin(current / start) * 1.5;
		if (t > 1) t = 1;
		float speedRatio = t;

		dir.X *= (m_Speed * speedRatio * g_Engine->LastUpdateInSeconds());
		dir.Y *= (m_Speed * speedRatio * g_Engine->LastUpdateInSeconds());

		Point newPos(m_Pos.X + dir.X, m_Pos.Y + dir.Y);
		Point newDir = m_Dest - newPos;

		//  See if we've overshot; if a sign has changed we've overshot on that dimension. Just pop to the destination.
		if (newDir.X * dir.X < 0)
		{
			m_Pos.X = m_Dest.X;
		}
		else // Otherwise, move to new position
		{
			m_Pos.X = newPos.X;
		}

		if (newDir.Y * dir.Y < 0)
		{
			m_Pos.Y = m_Dest.Y;
		}
		else
		{
			m_Pos.Y = newPos.Y;
		}
	}
	break;
	}
}

void Tween::Reverse()
{
	Point start = m_Start;
	m_Start = m_Dest;
	m_Dest = start;
}

void MobileSprite::Init(Sprite sprite, Point start, Point dest, float speed, float acceleration)
{
	Tween::Init(start, dest, speed, acceleration);
	m_Sprite = make_shared<Sprite>(sprite);
}

void MobileSprite::Update()
{
	Tween::Update();
}

void MobileSprite::Draw()
{
	g_Display->DrawSprite(m_Sprite, int(m_Pos.X), int(m_Pos.Y));
}

void Animation::Update()
{
	m_ElapsedTime += g_Engine->LastUpdateInMS();
}

void Animation::Play(std::string anim, int starttime, int elapsedtime)
{
	if (anim == m_CurrentAnim && m_Anims[m_CurrentAnim].m_Looping == true && elapsedtime == 0)
	{
		return; //  Don't restart an already playing looping anim.
	}

	if (m_Anims.find(anim) != m_Anims.end())
		m_CurrentAnim = anim;
	else
		return; //  Fail safe if no requested anim.
	if (starttime == 0)
		m_StartTime = g_Engine->GameTimeInMS() + elapsedtime;
	else
		m_StartTime = starttime;

	m_ElapsedTime = elapsedtime;

	m_Done = false;
}

//  For this version to work, all the frames must be on the same horizontal line in the texture.
void Animation::AddFrames(Texture* texture, int posx, int posy, int width, int height, int numFrames)
{
	for (int i = 0; i < numFrames; ++i)
	{
		m_Frames.push_back(make_shared<Sprite>(texture, posx + i * width, posy, width, height));
	}
}

void Animation::AddFramesSpaced(Texture* texture, int posx, int posy, int width, int height, int numFrames, int xstep)
{
	for (int i = 0; i < numFrames; ++i)
	{
		m_Frames.push_back(make_shared<Sprite>(texture, posx + i * xstep, posy, width, height));
	}
}

void Animation::AddAnim(std::string name, std::initializer_list<int> frames, int frameRate, bool looping)
{
	Anim temp(frames, frameRate, looping);
	temp.m_MSPerFrame = 1000 / frameRate;
	m_Anims[name] = temp;
}

void Animation::AddAnim(std::string name, std::vector<int> frames, int frameRate, bool looping)
{
	Anim temp(frames, frameRate, looping);
	temp.m_MSPerFrame = 1000 / frameRate;
	m_Anims[name] = temp;
}

shared_ptr<Sprite> Animation::GetCurrentFrame()
{
	int thisFrame = GetCurrentFrameNumber();
	return m_Frames[thisFrame];
}

shared_ptr<Sprite> Animation::GetFrame(int frame)
{
	return m_Frames[m_Anims[m_CurrentAnim].m_FrameOrder[frame]];
}

shared_ptr<Sprite> Animation::GetRawFrame(int frame)
{
	return m_Frames[frame];
}

int Animation::GetCurrentFrameNumber()
{
	Anim& thisAnim = m_Anims[m_CurrentAnim];

	int thisFrame = m_ElapsedTime / thisAnim.m_MSPerFrame;
	if (thisAnim.m_Looping == false)
	{
		if (thisFrame > (int)m_Anims[m_CurrentAnim].m_FrameOrder.size() - 1)
		{
			thisFrame = (int)m_Anims[m_CurrentAnim].m_FrameOrder.size() - 1; // Hold on last frame if we're not looping.
			m_Done = true;
		}
	}
	else
	{
		thisFrame = thisFrame % m_Anims[m_CurrentAnim].m_FrameOrder.size();
	}

	return m_Anims[m_CurrentAnim].m_FrameOrder[thisFrame];
}

void Animation::Save(ostream& stream)
{
	IO::Serialize(stream, m_CurrentAnim);
	IO::Serialize(stream, m_ElapsedTime);
}

void Animation::Load(istream& stream)
{
	std::string currentAnim;
	int elapsedTime;
	IO::Serialize(stream, currentAnim);
	IO::Serialize(stream, elapsedTime);
	Play(currentAnim, g_Engine->GameTimeInMS(), elapsedTime);
}

unsigned int Color::GetHex()
{
	unsigned int color = int(a * 255);
	color = color << 8;
	color = color | int(b * 255);
	color = color << 8;
	color = color | int(g * 255);
	color = color << 8;
	color = color | int(r * 255);

	return color;
}

Texture::Texture()
{
	m_Width = 0;
	m_Height = 0;
	m_Texture = 0;
	m_Filename = "";
	glGenBuffers(1, &m_VBO);
	m_AllowSmoothing = true;
	m_PixelData = make_unique < std::vector<Uint8> >();
	m_Loaded = false;
	m_IsMipMapped = false;
}

Texture::~Texture()
{
	glDeleteTextures(1, &m_Texture);
	glDeleteBuffers(1, &m_VBO);
}

void Texture::Create(int w, int h, bool mipmaps)
{
	m_Loaded = false;
	m_IsMipMapped = mipmaps;
	m_PixelData->resize(w * h * 4, 0);

	m_Filename = "";
	GLuint texture;

	glGenTextures(1, &texture);

	// Bind the texture object
	glBindTexture(GL_TEXTURE_2D, texture);

	// Set the texture's stretching properties
	if (mipmaps)
	{
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		m_AllowSmoothing = true;
	}
	else
	{
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		m_AllowSmoothing = false;
	}

	// Edit the texture object's image data using the information SDL_Surface gives us
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0,
		GL_RGBA, GL_UNSIGNED_BYTE, (void*)m_PixelData->data());
	glGenerateMipmap(texture);

	m_Texture = texture;

	m_Width = w;
	m_Height = h;

	MakeVertexBuffer();
}

void Texture::UpdateData()
{
	if (m_PixelData)
	{
		glBindTexture(GL_TEXTURE_2D, m_Texture);
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, m_Width, m_Height, GL_RGBA, GL_UNSIGNED_BYTE, (void*)m_PixelData->data());
	}
}

void Texture::PutPixel(int x, int y, Color color)
{
	if (m_PixelData == nullptr)
		return;

	if (x >= m_Width || y >= m_Height)
	{
		return;
	}

	if (4 * (y * m_Width + x) + 3 >= (int)m_PixelData->size())
		return;

	PutPixel(x, y, color.GetHex());
}

Color Texture::GetPixel(int x, int y)
{
	if (x < 0 || x >= m_Width || y < 0 || y >= m_Height)
	{
		return Color(0, 0, 0, 0);
	}

	Color final;
	final.r = (unsigned char)m_PixelData->data()[4 * (y * m_Width + x)] / 255.f;
	final.g = (unsigned char)m_PixelData->data()[4 * (y * m_Width + x) + 1] / 255.f;
	final.b = (unsigned char)m_PixelData->data()[4 * (y * m_Width + x) + 2] / 255.f;
	final.a = (unsigned char)m_PixelData->data()[4 * (y * m_Width + x) + 3] / 255.f;

	return final;
}

void Texture::PutPixel(int x, int y, unsigned int color)
{
	if (m_PixelData == nullptr)
		return;

	if(x < 0 || y < 0 || x >= m_Width || y >= m_Height)
		return;

	if (4 * (y * m_Width + x) + 3 >= (int)m_PixelData->size())
		return;

	memcpy(m_PixelData->data() + (4 * (y * m_Width + x)), &color, sizeof(unsigned int));
}

void Texture::MakeVertexBuffer()
{
	float vertices[] = {
		//  Position   Color             Texcoords
		0,                               0, 0, 1, 1, 1, 1, 0, 0, // Top-left
		(float)m_Width,                  0, 0, 1, 1, 1, 1, 1, 0, // Top-right
		(float)m_Width, (float)m_Height, 0, 1, 1, 1, 1, 1, 1, // Bottom-right
		(float)m_Width, (float)m_Height, 0, 1, 1, 1, 1, 1, 1, // Bottom-right
		0,              (float)m_Height, 0, 1, 1, 1, 1, 0, 1,  // Bottom-left
		0,                               0, 0, 1, 1, 1, 1, 0, 0// Top-left
	};

	//  Create vertex buffer

	glBindBuffer(GL_ARRAY_BUFFER, m_VBO);

	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

void Texture::Load(const std::string& fileName, bool mipmaps)
{
	m_Filename = fileName;
	m_IsMipMapped = mipmaps;
	m_Loaded = true;
	if (m_PixelData->size() != 0)
	{
		m_PixelData->clear();
	}

	if (m_Texture == 0)
	{
		glGenTextures(1, &m_Texture);
	}

	// Bind the texture object
	glBindTexture(GL_TEXTURE_2D, m_Texture);

	GLint bpp;
	int width = 0;
	int height = 0;
	stbi_uc* data = stbi_load(fileName.c_str(), &width, &height, &bpp, 0);

	if (data != nullptr)
	{
		// Check that the image's width is a power of 2
		if ((width & (width - 1)) != 0)
		{
			Log(fileName + " width is not a power of 2.");
		}

		// Also check if the height is a power of 2
		if ((height & (height - 1)) != 0)
		{
			Log(fileName + " height is not a power of 2.");
		}

		if (mipmaps)
		{
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			m_AllowSmoothing = true;
		}
		else
		{
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			m_AllowSmoothing = false;
		}

		// Edit the texture object's image data using the information SDL_Surface gives us

		m_Width = width;
		m_Height = height;

		m_PixelData->resize(m_Width * m_Height * sizeof(unsigned char) * bpp, 255);
		memcpy(m_PixelData->data(), data, m_Width * m_Height * sizeof(unsigned char) * bpp);

		if (bpp == 4)
		{
			unsigned char* pixData = m_PixelData->data();
			for (int i = 0; i < m_Width * m_Height * 4; i += 4)
			{
				unsigned char r, g, b, a;
				r = pixData[i];
				g = pixData[i + 1];
				b = pixData[i + 2];
				a = pixData[i + 3];
				r = r * a / 255;
				g = g * a / 255;
				b = b * a / 255;

				pixData[i] = r;
				pixData[i + 1] = g;
				pixData[i + 2] = b;
				pixData[i + 3] = a;
			}
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, m_Width, m_Height, 0,
				GL_RGBA, GL_UNSIGNED_BYTE, (void*)m_PixelData->data());
			glGenerateMipmap(m_Texture);
		}

		stbi_image_free(data);
	}
	else
	{
		throw("stb_image failed to load " + fileName);
	}

	MakeVertexBuffer();
}

//  Call this function to reload a texture that has changed on disk.
void Texture::Reload()
{
	m_Loaded = true;

	if (m_PixelData->size() != 0)
	{
		m_PixelData->clear();
	}

	Load(m_Filename, m_IsMipMapped);
}


Mesh::Mesh()
{
	m_Vertices.clear();
	m_NumberOfVertices = 0;
	m_Indexed = false;
	m_VertexPointer = NULL;
	m_IndexPointer = NULL;

	glGenBuffers(1, &m_VBO);
	glGenBuffers(1, &m_EBO);
}


Mesh::~Mesh()
{
	glDeleteBuffers(1, &m_VBO);
	glDeleteBuffers(1, &m_EBO);
}

void Mesh::Init(vector<Vertex> vertices, vector<unsigned int> indices, int type)
{
	if (vertices.size() == 0 || indices.size() == 0)
		return;

	m_Indexed = true;
	m_DrawMode = type;

	//  Set up vertices
	m_Vertices.clear();
	m_Vertices = vertices;
	m_NumberOfVertices = int(m_Vertices.size());

	if (m_NumberOfVertices == 0)
		return;

	glBindBuffer(GL_ARRAY_BUFFER, m_VBO);

	m_VertexPointer = (float*)&(m_Vertices[0]);

	switch (m_DrawMode)
	{
	case MT_STATIC:
	default:
		glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * m_NumberOfVertices, m_VertexPointer, GL_STATIC_DRAW);
		break;

	case MT_DYNAMIC:
		glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * m_NumberOfVertices, m_VertexPointer, GL_DYNAMIC_DRAW);
		break;

	case MT_STREAMING:
		glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * m_NumberOfVertices, m_VertexPointer, GL_STREAM_DRAW);
		break;
	}

	//  Set up indices
	m_Indices.clear();
	m_Indices = indices;
	m_NumberOfIndices = int(m_Indices.size());

	if (m_NumberOfIndices == 0)
		return;

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_EBO);

	m_IndexPointer = (unsigned int*)&(m_Indices[0]);

	switch (m_DrawMode)
	{
	case MT_STATIC:
	default:
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * indices.size(), m_IndexPointer, GL_STATIC_DRAW);
		break;

	case MT_DYNAMIC:
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * indices.size(), m_IndexPointer, GL_STATIC_DRAW);
		break;

	case MT_STREAMING:
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * indices.size(), m_IndexPointer, GL_STATIC_DRAW);
		break;
	}
}

void Mesh::Init(vector<Vertex> vertices, int type)
{
	if (vertices.size() == 0)
		return;

	m_Indexed = false;
	m_DrawMode = type;

	//  Set up vertices
	m_Vertices = vertices;
	m_NumberOfVertices = int(m_Vertices.size());

	if (m_NumberOfVertices == 0)
		return;

	glBindBuffer(GL_ARRAY_BUFFER, m_VBO);

	m_VertexPointer = (float*)&(m_Vertices[0]);

	switch (m_DrawMode)
	{
	case MT_STATIC:
	default:
		glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * m_NumberOfVertices, m_VertexPointer, GL_STATIC_DRAW);
		break;

	case MT_DYNAMIC:
		glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * m_NumberOfVertices, m_VertexPointer, GL_DYNAMIC_DRAW);
		break;

	case MT_STREAMING:
		glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * m_NumberOfVertices, m_VertexPointer, GL_STREAM_DRAW);
		break;
	}
}

unsigned int Mesh::GetVertexBufferID()
{
	return m_VBO;
}

unsigned int Mesh::GetIndexBufferID()
{
	return m_EBO;
}

int Mesh::GetNumberOfIndices()
{
	return m_NumberOfIndices;
}

int Mesh::GetNumberOfVertices()
{
	return m_NumberOfVertices;
}

bool Mesh::IsIndexed()
{
	return m_Indexed;
}

void Mesh::UpdateIndices(vector<unsigned int> indices)
{
	if(indices.size() == 0)
		return;

	if (!m_Indexed)
	{
		m_Indexed = true;
	}

	m_Indices.clear();
	m_Indices = indices;

	m_NumberOfIndices = int(m_Indices.size());

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_EBO);

	m_IndexPointer = (unsigned int*)&(m_Indices[0]);

	switch (m_DrawMode)
	{
	case MT_STATIC:
	default:
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * m_Indices.size(), m_IndexPointer, GL_STATIC_DRAW);
		break;

	case MT_DYNAMIC:
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * m_Indices.size(), m_IndexPointer, GL_STATIC_DRAW);
		break;

	case MT_STREAMING:
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int) * m_Indices.size(), m_IndexPointer, GL_STATIC_DRAW);
		break;
	}
}

//  It's vital that the VBO and the stored vertices stay in sync even though
//  we may not be updating the entire dataset.
void Mesh::UpdateVertices(int offset, vector<Vertex> vertices)
{
	//  Update vertices
	if (offset == 0)
	{
		m_Vertices.clear();
		m_Vertices.resize(vertices.size());
		m_NumberOfVertices = int(vertices.size());
	}

	for (std::size_t i = 0; i < vertices.size(); ++i)
	{
		m_Vertices[offset + i] = vertices[i];
	}

	//  Update VBO
	glBindBuffer(GL_ARRAY_BUFFER, m_VBO);
	glBufferSubData(GL_ARRAY_BUFFER, sizeof(Vertex) * offset,
		sizeof(Vertex) * vertices.size(), vertices.data());
}

Vertex Mesh::GetVertex(int offset)
{
	return m_Vertices[offset];
}

void Mesh::Load(const std::string meshname)
{
	m_Indexed = false;
	m_DrawMode = MT_STATIC;

	m_Vertices.clear();

	vector<Vertex> tempvector;
	//   Vertex temp;

	//  It's not in the list, add it.
	ifstream instream;
	instream.open(meshname.c_str());
	if (!instream.fail())
	{
		while (!instream.eof())
		{
			Vertex temp;
			instream >> temp.x;
			instream >> temp.y;
			instream >> temp.z;
			instream >> temp.r;
			instream >> temp.g;
			instream >> temp.b;
			instream >> temp.a;
			instream >> temp.u;
			instream >> temp.v;

			tempvector.push_back(CreateVertex(temp.x, temp.y, temp.z, temp.r, temp.g, temp.b, temp.a, temp.u, temp.v));
		}
	}
	else
	{
		Log("Error loading mesh: " + meshname);
	}

	if (tempvector.size() > 0)
	{
		Init(tempvector);
	}
	else
	{
		Log("Vertex count of zero in mesh: " + meshname);
	}
}

bool Mesh::SelectCheck(glm::vec3 position, float angle, glm::vec3 scaling)
{
	glm::vec3 ori, pos;
	g_Input->GetMouseRay(ori, pos);

	glm::vec4 rayOrigin = glm::vec4(ori, 1);
	glm::vec4 rayDirection = glm::vec4(pos, 0);

	glm::mat4 translation = glm::translate(glm::mat4(), position);
	glm::mat4 rotation = glm::rotate(translation, angle, glm::vec3(0, 1, 0));
	glm::mat4 model = glm::scale(rotation, scaling);

	if (m_Indexed)
	{
		for (int i = 0; i < m_NumberOfIndices; i += 3)
		{
			glm::vec3 tri1 = glm::vec3(m_Vertices[m_Indices[i]].x, m_Vertices[m_Indices[i]].y, m_Vertices[m_Indices[i]].z);
			glm::vec3 tri2 = glm::vec3(m_Vertices[m_Indices[i + 1]].x, m_Vertices[m_Indices[i + 1]].y, m_Vertices[m_Indices[i + 1]].z);
			glm::vec3 tri3 = glm::vec3(m_Vertices[m_Indices[i + 2]].x, m_Vertices[m_Indices[i + 2]].y, m_Vertices[m_Indices[i + 2]].z);

			tri1 = glm::vec3(model * glm::vec4(tri1, 1));
			tri2 = glm::vec3(model * glm::vec4(tri2, 1));
			tri3 = glm::vec3(model * glm::vec4(tri3, 1));

			double distance;
			if (Pick(glm::vec3(rayOrigin), glm::vec3(rayDirection), tri1, tri2, tri3, distance))
				return true;
		}

	}
	else
	{
		for (int i = 0; i < m_NumberOfVertices; i += 3)
		{
			glm::vec3 tri1 = glm::vec3(m_Vertices[i].x, m_Vertices[i].y, m_Vertices[i].z);
			glm::vec3 tri2 = glm::vec3(m_Vertices[i + 1].x, m_Vertices[i + 1].y, m_Vertices[i + 1].z);
			glm::vec3 tri3 = glm::vec3(m_Vertices[i + 2].x, m_Vertices[i + 2].y, m_Vertices[i + 2].z);

			tri1 = glm::vec3(model * glm::vec4(tri1, 1));
			tri2 = glm::vec3(model * glm::vec4(tri2, 1));
			tri3 = glm::vec3(model * glm::vec4(tri3, 1));

			double distance;
			if (Pick(glm::vec3(rayOrigin), glm::vec3(rayDirection), tri1, tri2, tri3, distance))
				return true;
		}
	}

	return false;

}

bool Mesh::SelectCheck(int tristart, int numtris, glm::vec3 position, float angle, glm::vec3 scaling)
{
	glm::vec3 ori, pos;
	g_Input->GetMouseRay(ori, pos);

	glm::vec4 rayOrigin = glm::vec4(ori, 1);
	glm::vec4 rayDirection = glm::vec4(pos, 0);

	glm::mat4 translation = glm::translate(glm::mat4(), position);
	glm::mat4 rotation = glm::rotate(translation, angle, glm::vec3(0, 1, 0));
	glm::mat4 model = glm::scale(rotation, scaling);

	if (m_Indexed)
	{
		for (int i = tristart * 3; i < tristart * 3 + numtris * 3; i += 3)
		{
			glm::vec3 tri1 = glm::vec3(m_Vertices[m_Indices[i]].x, m_Vertices[m_Indices[i]].y, m_Vertices[m_Indices[i]].z);
			glm::vec3 tri2 = glm::vec3(m_Vertices[m_Indices[i + 1]].x, m_Vertices[m_Indices[i + 1]].y, m_Vertices[m_Indices[i + 1]].z);
			glm::vec3 tri3 = glm::vec3(m_Vertices[m_Indices[i + 2]].x, m_Vertices[m_Indices[i + 2]].y, m_Vertices[m_Indices[i + 2]].z);

			tri1 = glm::vec3(model * glm::vec4(tri1, 1));
			tri2 = glm::vec3(model * glm::vec4(tri2, 1));
			tri3 = glm::vec3(model * glm::vec4(tri3, 1));

			double distance;
			if (Pick(glm::vec3(rayOrigin), glm::vec3(rayDirection), tri1, tri2, tri3, distance))
				return true;
		}

	}
	else
	{
		for (int i = tristart * 3; i < tristart * 3 + numtris * 3; i += 3)
		{
			glm::vec3 tri1 = glm::vec3(m_Vertices[i].x, m_Vertices[i].y, m_Vertices[i].z);
			glm::vec3 tri2 = glm::vec3(m_Vertices[i + 1].x, m_Vertices[i + 1].y, m_Vertices[i + 1].z);
			glm::vec3 tri3 = glm::vec3(m_Vertices[i + 2].x, m_Vertices[i + 2].y, m_Vertices[i + 2].z);

			tri1 = glm::vec3(model * glm::vec4(tri1, 1));
			tri2 = glm::vec3(model * glm::vec4(tri2, 1));
			tri3 = glm::vec3(model * glm::vec4(tri3, 1));

			double distance;
			if (Pick(glm::vec3(rayOrigin), glm::vec3(rayDirection), tri1, tri2, tri3, distance))
				return true;
		}
	}
	return false;
}


Vertex CreateVertex(float inx, float iny, float inz,
	float inr, float ing, float inb, float ina,
	float inu, float inv)
{
	Vertex out;
	out.x = inx;
	out.y = iny;
	out.z = inz;
	out.r = inr;
	out.g = ing;
	out.b = inb;
	out.a = ina;
	out.u = inu;
	out.v = inv;

	return out;
}

Vertex CreateVertex(float inx, float iny, float inz,
	Color color,
	float inu, float inv)
{
	Vertex out;
	out.x = inx;
	out.y = iny;
	out.z = inz;
	out.r = color.r;
	out.g = color.g;
	out.b = color.b;
	out.a = color.a;
	out.u = inu;
	out.v = inv;

	return out;
}

Vertex2D CreateVertex2D(float inx, float iny, float inr,
	float ing, float inb, float ina, float inu,
	float inv)
{
	Vertex2D out;
	out.x = inx;
	out.y = iny;
	out.r = inr;
	out.g = ing;
	out.b = inb;
	out.a = ina;
	out.u = inu;
	out.v = inv;
	return out;
}

Vertex2D CreateVertex2D(float inx, float iny, Color color, float inu, float inv)
{
	Vertex2D out;
	out.x = inx;
	out.y = iny;
	out.r = color.r;
	out.g = color.g;
	out.b = color.b;
	out.a = color.a;
	out.u = inu;
	out.v = inv;

	return out;
}



SpriteSheet::SpriteSheet(Texture* texture, int columns, int rows)
{
	//  Create a mesh that splits the given texture up into equal columns and rows
	m_Mesh = new Mesh();
	m_Texture = texture;

	vector<Vertex> vertices;
	vector<unsigned int> indices;

	m_Columns = columns;
	m_Rows = rows;
	m_ColumnWidth = m_Texture->GetWidth() / columns;
	m_RowHeight = m_Texture->GetHeight() / rows;
	float spriteu = 1.0f / float(columns);
	float spritev = 1.0f / float(rows);

	for (int i = 0; i < columns; ++i)
	{
		for (int j = 0; j < rows; ++j)
		{

			float startx = float(i * spriteu);
			float endx = float((i + 1) * spriteu);
			float starty = float(j * spritev);
			float endy = float((j + 1) * spritev);

			vertices.push_back(CreateVertex(0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, startx, starty));
			vertices.push_back(CreateVertex(float(m_ColumnWidth), 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, endx, starty));
			vertices.push_back(CreateVertex(0.0f, float(m_RowHeight), 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, startx, endy));
			vertices.push_back(CreateVertex(float(m_ColumnWidth), float(m_RowHeight), 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, endx, endy));
		}
	}

	for (int i = 0; i < columns * rows * 4; ++i)
	{
		indices.push_back(i);
		indices.push_back(i + 1);
		indices.push_back(i + 2);
		indices.push_back(i + 3);
		indices.push_back(i + 2);
		indices.push_back(i + 1);

		i += 4;
	}

	m_Mesh->Init(vertices, indices);

}

void SpriteSheet::DrawSprite(int spritex, int spritey, int posx, int posy)
{
	g_Display->DrawImage(m_Texture, spritex * m_ColumnWidth, spritey * m_RowHeight,
		m_ColumnWidth, m_RowHeight, posx, posy);
}