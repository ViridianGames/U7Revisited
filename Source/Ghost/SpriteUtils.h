#ifndef _SPRITEUTILS_H_
#define _SPRITEUTILS_H_

#include <string>
#include "../Geist/ResourceManager.h"
#include "../Geist/Logging.h"
#include "raylib.h"

// Sprite validation and fallback utility
// This validates sprite parameters and applies fallback values if they're invalid
class SpriteUtils
{
public:
	// Validates sprite parameters and applies fallbacks if needed
	// Returns true if the original values were valid, false if fallbacks were applied
	static bool ValidateAndApplyFallbacks(
		std::string& filename,
		int& x,
		int& y,
		int& width,
		int& height,
		const std::string& spritePath,
		ResourceManager* resourceManager)
	{
		// Check if width or height are invalid
		if (width <= 0 || height <= 0)
		{
			Log("SpriteUtils: Invalid width/height, applying fallbacks");
			ApplyFallbacks(filename, x, y, width, height);
			return false;
		}

		// If filename is empty, apply fallbacks
		if (filename.empty())
		{
			Log("SpriteUtils: Empty filename, applying fallbacks");
			ApplyFallbacks(filename, x, y, width, height);
			return false;
		}

		// Attempt to load the sprite to verify it's valid
		std::string fullSpritePath = spritePath + filename;
		Texture* texture = resourceManager->GetTexture(fullSpritePath);

		// Check if texture loaded successfully
		if (!texture || texture->id == 0 || texture->width == 0 || texture->height == 0)
		{
			Log("SpriteUtils: Failed to load sprite '" + fullSpritePath + "', applying fallbacks");
			ApplyFallbacks(filename, x, y, width, height);
			return false;
		}

		// Check if the sprite coordinates are within the texture bounds
		if (x < 0 || y < 0 ||
			x + width > texture->width ||
			y + height > texture->height)
		{
			Log("SpriteUtils: Sprite coordinates out of bounds (texture: " +
				std::to_string(texture->width) + "x" + std::to_string(texture->height) +
				", sprite: " + std::to_string(x) + "," + std::to_string(y) +
				" " + std::to_string(width) + "x" + std::to_string(height) + "), applying fallbacks");
			ApplyFallbacks(filename, x, y, width, height);
			return false;
		}

		// All validations passed
		return true;
	}

	// Apply default fallback sprite values
	static void ApplyFallbacks(
		std::string& filename,
		int& x,
		int& y,
		int& width,
		int& height)
	{
		filename = "image.png";
		x = 0;
		y = 0;
		width = 16;
		height = 48;
	}

	// Get fallback sprite definition for a specific sprite type
	// spriteType: "left", "center", "right", or "sprite"
	static void GetFallbackForType(
		const std::string& spriteType,
		std::string& filename,
		int& x,
		int& y,
		int& width,
		int& height)
	{
		filename = "image.png";

		if (spriteType == "left")
		{
			x = 0;
			y = 0;
			width = 16;
			height = 48;
		}
		else if (spriteType == "center")
		{
			x = 16;
			y = 0;
			width = 16;
			height = 48;
		}
		else if (spriteType == "right")
		{
			x = 32;
			y = 0;
			width = 16;
			height = 48;
		}
		else if (spriteType == "sprite")
		{
			// 48x48 square for regular sprites
			x = 0;
			y = 0;
			width = 48;
			height = 48;
		}
		else
		{
			// Default to left
			x = 0;
			y = 0;
			width = 16;
			height = 48;
		}
	}
};

#endif
