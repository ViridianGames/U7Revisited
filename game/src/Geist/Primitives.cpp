#include <fstream>
#include <cstring>

#include "raylib.h"
#include "raymath.h"
#include "Primitives.h"
#include "IO.h"
#include "Globals.h"

using namespace std;


//--------------------------------------------------------------------------------------------

void Sprite::Draw(float x, float y, Color tint)
{
	DrawTextureRec(*m_texture, m_sourceRect, Vector2{ float(x), float(y) }, tint);
}

void Sprite::Draw(Vector2 pos, Color tint)
{
	DrawTextureRec(*m_texture, m_sourceRect, pos, tint);
}

void Sprite::DrawScaled(Rectangle dest, Vector2 origin, float rotation, Color tint)
{
	DrawTexturePro(*m_texture, m_sourceRect, dest, origin, rotation, tint);
}

//--------------------------------------------------------------------------------------------

void Tween::Update()
{
	//  Already at target
	if (m_Pos.x == m_Dest.x && m_Pos.y == m_Dest.y)
	{
		m_Done = true;
		return;
	}

	m_Done = false;
	switch (m_MoveType)
	{
	case MOVE_NORMAL:
	{
		Vector2 dir = Vector2Subtract(m_Dest, Vector2{ m_Pos.x, m_Pos.y });
		dir = Vector2Normalize(dir);

		dir.x *= (m_Speed * GetFrameTime());
		dir.y *= (m_Speed * GetFrameTime());

		Vector2 newPos = Vector2Add(m_Pos, dir);
		Vector2 newDir = Vector2Subtract(m_Dest, newPos);

		//  See if we've overshot; if a sign has changed we've overshot on that dimension. Just pop to the destination.
		if (newDir.x * dir.x < 0)
		{
			m_Pos.x = m_Dest.x;
		}
		else // Otherwise, move to new position
		{
			m_Pos.x = newPos.x;
		}

		if (newDir.y * dir.y < 0)
		{
			m_Pos.y = m_Dest.y;
		}
		else
		{
			m_Pos.y = newPos.y;
		}
	}
	break;

	case MOVE_BOUNCE:
	{
		m_Acceleration += m_AccelerationPerSecond * GetFrameTime();
		m_Speed += m_Acceleration * GetFrameTime();

		Vector2 dir = Vector2Subtract(m_Dest, Vector2{ m_Pos.x, m_Pos.y });
		dir = Vector2Normalize(dir);

		dir.x *= (m_Speed * GetFrameTime());
		dir.y *= (m_Speed * GetFrameTime());

		Vector2 newPos = Vector2Add(m_Pos, dir);

		//  See if we've overshot on either x or y.
		if (m_Pos.x < m_Dest.x && newPos.x > m_Dest.x || //  Overshot going right
			m_Pos.x > m_Dest.x && newPos.x < m_Dest.x ||  //  Overshot going left
			m_Pos.y < m_Dest.y && newPos.y > m_Dest.y ||  //  Overshot going down
			m_Pos.y > m_Dest.y && newPos.y < m_Dest.y)    //  Overshot going up
		{
			//  Half the speed and reverse it.
			m_Speed = -0.1f * m_Speed;
			m_Acceleration = m_AccelerationPerSecond;
			++m_OvershootCount;
		}
		else // Otherwise, move to new position
		{
			m_Pos.x = newPos.x;
			m_Pos.y = newPos.y;
		}
	}
	break;

	case MOVE_PARABOLIC:
	{
		m_Acceleration += m_AccelerationPerSecond * GetFrameTime();
		m_Speed += m_Acceleration * GetFrameTime();

		Vector2 dir = Vector2Subtract(m_Dest, Vector2{ m_Pos.x, m_Pos.y });
		dir = Vector2Normalize(dir);

		dir.x *= (m_Speed * GetFrameTime());
		dir.y *= (m_Speed * GetFrameTime());

		Vector2 newPos = Vector2Add(m_Pos, dir);

		//  See if we've overshot on either x or y.
		if (m_Pos.x < m_Dest.x && newPos.x > m_Dest.x || //  Overshot going right
			m_Pos.x > m_Dest.x && newPos.x < m_Dest.x ||  //  Overshot going left
			m_Pos.y < m_Dest.y && newPos.y > m_Dest.y ||  //  Overshot going down
			m_Pos.y > m_Dest.y && newPos.y < m_Dest.y)    //  Overshot going up
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
				m_Pos.x = m_Dest.x;
				m_Pos.y = m_Dest.y;
			}
			++m_OvershootCount;
		}
		else
			m_Pos = newPos;
	}
	break;

	case MOVE_EASING:
	{
		Vector2 dir = Vector2Subtract(m_Dest, Vector2{ m_Pos.x, m_Pos.y });
		dir = Vector2Normalize(dir);

		//  Get distance ratio to target
		float start = Vector2Distance(m_Start, m_Dest);
		float current = Vector2Distance(m_Pos, m_Dest);

		float t = sin(current / start) * 1.5f;
		if (t > 1) t = 1;
		float speedRatio = t;

		dir.x *= (m_Speed * speedRatio * GetFrameTime());
		dir.y *= (m_Speed * speedRatio * GetFrameTime());

		Vector2 newPos = Vector2Add(m_Pos, dir);
		Vector2 newDir = Vector2Subtract(m_Dest, newPos);

		//  See if we've overshot; if a sign has changed we've overshot on that dimension. Just pop to the destination.
		if (newDir.x * dir.x < 0)
		{
			m_Pos.x = m_Dest.x;
		}
		else // Otherwise, move to new position
		{
			m_Pos.x = newPos.x;
		}

		if (newDir.y * dir.y < 0)
		{
			m_Pos.y = m_Dest.y;
		}
		else
		{
			m_Pos.y = newPos.y;
		}
	}
	break;
	}
}

void Tween::Reverse()
{
	Vector2 start = m_Start;
	m_Start = m_Dest;
	m_Dest = start;
}

//--------------------------------------------------------------------------------------------

void MobileSprite::Init(Sprite sprite, Vector2 start, Vector2 dest, float speed, float acceleration)
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
	m_Sprite->Draw(m_Pos.x, m_Pos.y);
}

void Animation::Update()
{
	m_ElapsedTime += static_cast<int>(GetFrameTime() * 1000);
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
		m_StartTime = int(GetTime() * 1000) + elapsedtime;
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
	Play(currentAnim, int(GetTime() * 1000), elapsedTime);
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
	m_Texture = texture;

	vector<Vertex> vertices;
	vector<unsigned int> indices;

	m_Columns = columns;
	m_Rows = rows;
	m_ColumnWidth = m_Texture->width / columns;
	m_RowHeight = m_Texture->height / rows;
	float spriteu = 1.0f / float(columns);
	float spritev = 1.0f / float(rows);
}

void SpriteSheet::DrawSprite(int spritex, int spritey, int posx, int posy)
{
	Sprite temp(m_Texture, spritex * m_ColumnWidth, spritey * m_RowHeight, m_ColumnWidth, m_RowHeight);
	temp.Draw(float(posx), float(posy));
}

void ModTexture::MoveImageRowLeft(int row)
{
	for (int x = 0; x < m_Image.width - 1; ++x)
	{
		Color newPixel = GetImageColor(m_Image, x + 1, row);
		ImageDrawPixel(&m_Image, x, row, newPixel);
	}
}

void ModTexture::MoveImageRowRight(int row)
{
	for (int x = m_Image.width - 1; x > 0; --x)
	{
		Color newPixel = GetImageColor(m_Image, x - 1, row);
		ImageDrawPixel(&m_Image, x, row, newPixel);
	}
}

void ModTexture::MoveImageColumnUp(int column)
{
	for (int y = 0; y < m_Image.height - 1; ++y)
	{
		Color newPixel = GetImageColor(m_Image, column, y + 1);
		ImageDrawPixel(&m_Image, column, y, newPixel);
	}
}

void ModTexture::MoveImageColumnDown(int column)
{
	for (int y = m_Image.height - 1; y > 0; --y)
	{
		Color newPixel = GetImageColor(m_Image, column, y - 1);
		ImageDrawPixel(&m_Image, column, y, newPixel);
	}
}

void ModTexture::UpdateTexture()
{
	m_Texture = LoadTextureFromImage(m_Image);
}

void ModTexture::AssignImage(char* image)
{
	m_Image = LoadImage(image);
	m_OriginalImage = m_Image;
	m_Texture = LoadTextureFromImage(m_Image);
	width = m_Image.width;
	height = m_Image.height;
	SetTextureFilter(m_Texture, TEXTURE_FILTER_POINT);
}

void ModTexture::AssignImage(Image img)
{
	m_Image = img;
	m_OriginalImage = m_Image;
	m_Texture = LoadTextureFromImage(m_Image);
	width = m_Image.width;
	height = m_Image.height;
	SetTextureFilter(m_Texture, TEXTURE_FILTER_POINT);
}

void ModTexture::ResizeImage(float newWidth, float newHeight)
{
	if (newWidth < 1 || newHeight < 1 || newWidth > width || newHeight > height)
	{
		return;
	}

	m_Image = ImageFromImage(m_Image, Rectangle{ 0, 0, newWidth, newHeight });
}

void ModTexture::Reset()
{
	m_Image = m_OriginalImage;
	m_Texture = LoadTextureFromImage(m_Image);
	width = m_Image.width;
	height = m_Image.height;
}