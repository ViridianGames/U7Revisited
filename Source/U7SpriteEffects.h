#ifndef _U7SPRITEEFFECTS_H_
#define _U7SPRITEEFFECTS_H_

#include "raylib.h"
#include <vector>

// Short-lived 2D overlays from SPRITES.VGA (e.g. musical notes, spell puffs).
class U7SpriteEffectSystem
{
public:
	static constexpr float kFrameDuration = 0.1f;
	static constexpr int kInstrumentNotesSprite = 24;
	static constexpr int kInstrumentNoteFrames = 8;
	static constexpr float kInstrumentBaseYOffset = -1.0f;
	static constexpr float kInstrumentRisePerFrame = 0.2f;

	void Spawn(int spriteIndex, Vector3 worldPos);
	void SpawnOnObject(int objectId, int spriteIndex, float heightAboveTop = 1.0f);

	// Rising note sprite (24) loops until the instrument on this object stops.
	void StartInstrumentNotesOnObject(int objectId, float heightAboveTop = 1.0f);
	void StopInstrumentNotesOnObject(int objectId);

	void Update(float dt);
	void Draw(Camera camera);

private:
	struct ActiveSpriteEffect
	{
		int spriteIndex = 0;
		int frameIndex = 0;
		float frameTimer = 0.0f;
		Vector3 worldPos = { 0, 0, 0 };

// Musical notes sprite 24 specific properties
		bool risingNotes = false;  // True for musical notes that rise until the end of the sprite
		bool loopInstrumentNotes = false;  // True for musical notes that loop until instrument stops	
		int boundObjectId = -1;  // Object ID this effect is bound to (for instrument notes)
		float baseY = 0.0f;      // Base Y position for note animation
		float heightAboveTop = 1.0f;  // Height above object top
	};

	static float InstrumentNoteY(int frameIndex, float baseY);
	void RefreshInstrumentNoteAnchor(ActiveSpriteEffect& effect);

	std::vector<ActiveSpriteEffect> m_active;
};

#endif
