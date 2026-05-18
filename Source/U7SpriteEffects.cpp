#include "U7SpriteEffects.h"

#include "Geist/Globals.h"
#include "SoundSystem.h"
#include "U7Globals.h"

#include <algorithm>

float U7SpriteEffectSystem::InstrumentNoteY(int frameIndex, float baseY)
{
	if (frameIndex < 0)
	{
		frameIndex = 0;
	}
	return baseY + kInstrumentBaseYOffset + static_cast<float>(frameIndex) * kInstrumentRisePerFrame;
}

void U7SpriteEffectSystem::RefreshInstrumentNoteAnchor(ActiveSpriteEffect& effect)
{
	U7Object* object = GetObjectFromID(effect.boundObjectId);
	if (!object)
	{
		return;
	}

	float topY = object->m_Pos.y;
	if (object->m_shapeData)
	{
		topY += object->m_shapeData->m_Dims.y;
	}

	effect.baseY = topY + effect.heightAboveTop;
	effect.worldPos.x = object->m_Pos.x;
	effect.worldPos.z = object->m_Pos.z;
	effect.worldPos.y = InstrumentNoteY(effect.frameIndex, effect.baseY);
}

void U7SpriteEffectSystem::Spawn(int spriteIndex, Vector3 worldPos)
{
	if (spriteIndex < 0 || spriteIndex >= static_cast<int>(g_spriteTable.size()))
	{
		return;
	}
	if (g_spriteTable[spriteIndex].empty())
	{
		return;
	}

	ActiveSpriteEffect effect;
	effect.spriteIndex = spriteIndex;
	effect.worldPos = worldPos;

	if (spriteIndex == kInstrumentNotesSprite)
	{
		effect.risingNotes = true;
		effect.baseY = worldPos.y;
		effect.frameIndex = 0;
		effect.worldPos.y = InstrumentNoteY(0, effect.baseY);
	}

	m_active.push_back(effect);
}

void U7SpriteEffectSystem::SpawnOnObject(int objectId, int spriteIndex, float heightAboveTop)
{
	U7Object* object = GetObjectFromID(objectId);
	if (!object)
	{
		return;
	}

	float topY = object->m_Pos.y;
	if (object->m_shapeData)
	{
		topY += object->m_shapeData->m_Dims.y;
	}

	Vector3 worldPos = {
		object->m_Pos.x,
		topY + heightAboveTop,
		object->m_Pos.z
	};
	Spawn(spriteIndex, worldPos);
}

void U7SpriteEffectSystem::StopInstrumentNotesOnObject(int objectId)
{
	m_active.erase(
		std::remove_if(
			m_active.begin(),
			m_active.end(),
			[objectId](const ActiveSpriteEffect& effect)
			{
				return effect.loopInstrumentNotes && effect.boundObjectId == objectId;
			}),
		m_active.end());
}

void U7SpriteEffectSystem::StartInstrumentNotesOnObject(int objectId, float heightAboveTop)
{
	if (objectId < 0)
	{
		return;
	}

	StopInstrumentNotesOnObject(objectId);

	U7Object* object = GetObjectFromID(objectId);
	if (!object)
	{
		return;
	}

	if (kInstrumentNotesSprite < 0 || kInstrumentNotesSprite >= static_cast<int>(g_spriteTable.size()))
	{
		return;
	}
	if (g_spriteTable[kInstrumentNotesSprite].empty())
	{
		return;
	}

	float topY = object->m_Pos.y;
	if (object->m_shapeData)
	{
		topY += object->m_shapeData->m_Dims.y;
	}

	ActiveSpriteEffect effect;
	effect.spriteIndex = kInstrumentNotesSprite;
	effect.risingNotes = true;
	effect.loopInstrumentNotes = true;
	effect.boundObjectId = objectId;
	effect.heightAboveTop = heightAboveTop;
	effect.baseY = topY + heightAboveTop;
	effect.frameIndex = 0;
	effect.frameTimer = 0.0f;
	effect.worldPos = { object->m_Pos.x, InstrumentNoteY(0, effect.baseY), object->m_Pos.z };

	m_active.push_back(effect);
}

void U7SpriteEffectSystem::Update(float dt)
{
	for (auto it = m_active.begin(); it != m_active.end();)
	{
		if (it->spriteIndex < 0 || it->spriteIndex >= static_cast<int>(g_spriteTable.size()))
		{
			it = m_active.erase(it);
			continue;
		}

		if (it->loopInstrumentNotes)
		{
			if (!g_SoundSystem || !g_SoundSystem->IsInstrumentPlaying(it->boundObjectId))
			{
				it = m_active.erase(it);
				continue;
			}
			RefreshInstrumentNoteAnchor(*it);
		}

		const auto& frames = g_spriteTable[it->spriteIndex];
		const int frameCount = static_cast<int>(frames.size());
		if (frameCount == 0)
		{
			it = m_active.erase(it);
			continue;
		}

		const int endFrame = it->risingNotes
			? std::min(kInstrumentNoteFrames, frameCount)
			: frameCount;

		it->frameTimer += dt;
		if (it->frameTimer < kFrameDuration)
		{
			++it;
			continue;
		}

		it->frameTimer -= kFrameDuration;
		it->frameIndex++;

		if (it->frameIndex < endFrame)
		{
			if (it->risingNotes)
			{
				it->worldPos.y = InstrumentNoteY(it->frameIndex, it->baseY);
			}
			++it;
		}
		else if (it->loopInstrumentNotes)
		{
			it->frameIndex = 0;
			it->worldPos.y = InstrumentNoteY(0, it->baseY);
			++it;
		}
		else
		{
			it = m_active.erase(it);
		}
	}
}

void U7SpriteEffectSystem::Draw(Camera camera)
{
	extern float g_DrawScale;

	for (const ActiveSpriteEffect& effect : m_active)
	{
		if (effect.spriteIndex < 0 || effect.spriteIndex >= static_cast<int>(g_spriteTable.size()))
		{
			continue;
		}

		const auto& frames = g_spriteTable[effect.spriteIndex];
		if (frames.empty() || effect.frameIndex < 0 || effect.frameIndex >= static_cast<int>(frames.size()))
		{
			continue;
		}

		const SpriteFrame& frame = frames[effect.frameIndex];
		if (frame.texture.id == 0)
		{
			continue;
		}

		Vector2 screenPos = GetWorldToScreen(effect.worldPos, camera);
		if (g_DrawScale > 0.0f)
		{
			screenPos.x /= g_DrawScale;
			screenPos.y /= g_DrawScale;
		}

		// U7 sprite offsets: anchor at bottom-center of the frame in world space.
		float drawX = screenPos.x - static_cast<float>(frame.xOffset);
		float drawY = screenPos.y - static_cast<float>(frame.yOffset) - static_cast<float>(frame.height);

		Rectangle source = { 0.0f, 0.0f, static_cast<float>(frame.width), static_cast<float>(frame.height) };
		Rectangle dest = { drawX, drawY, static_cast<float>(frame.width), static_cast<float>(frame.height) };
		DrawTexturePro(frame.texture, source, dest, { 0.0f, 0.0f }, 0.0f, WHITE);
	}
}
