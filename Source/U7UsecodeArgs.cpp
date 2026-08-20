///////////////////////////////////////////////////////////////////////////
//
// Name:     U7UsecodeArgs.cpp
// Purpose:  Shared usecode/Lua argument contracts (see U7UsecodeArgs.h).
//
///////////////////////////////////////////////////////////////////////////

#include "U7UsecodeArgs.h"

extern "C"
{
#include <lua.h>
#include <lauxlib.h>
}

#include <cstdint>
#include <sstream>

int NormalizeUsecodeAny(int v)
{
	// Exult "any" sentinels: -359 / 359 / 0xFE99 (decompiler often emits unsigned 359)
	if (v == -359 || v == 359 || v == 0xFE99 || v == 65113)
		return kUsecodeAny;
	// Sign-extend 16-bit usecode constants (but keep 359 handled above)
	if (v > 359 && v >= 0x8000 && v <= 0xFFFF)
		return (int)(int16_t)(uint16_t)v;
	return v;
}

bool IsUsecodeAny(int v)
{
	const int n = NormalizeUsecodeAny(v);
	return n == -1 || n == kUsecodeAny;
}

int ClampShapeFrame(int frame)
{
	if (IsUsecodeAny(frame) || frame < 0 || frame >= 32)
		return 0;
	return frame;
}

bool MatchesShapeQualityFrame(int objShape, int objQuality, int objFrame,
                              int wantShape, int wantQuality, int wantFrame)
{
	if (!IsUsecodeAny(wantShape) && objShape != wantShape)
		return false;
	if (!IsUsecodeAny(wantQuality) && objQuality != wantQuality)
		return false;
	if (!IsUsecodeAny(wantFrame) && objFrame != wantFrame)
		return false;
	return true;
}

static bool LooksLikeFrameOrAny(int v)
{
	return (v >= 0 && v < 64) || IsUsecodeAny(v);
}

static bool LooksLikeShapeId(int v)
{
	// Shapes are 1..1023; exclude usecode "any" sentinels (359 etc.).
	if (IsUsecodeAny(v))
		return false;
	return v > 1 && v < 1024;
}

static bool LooksLikeObjectOrNpcId(int v)
{
	// World object ids are large; NPC refs are small (0–255) or negative usecode NPC ids.
	// 356/-356 = avatar, 357/-357 = party (Exult conventions used throughout BG scripts).
	const int absV = v < 0 ? -v : v;
	if (absV == 356 || absV == 357)
		return true;
	if (v < 0)
		return true; // e.g. -30 NPC
	if (v >= 0 && v <= 255)
		return true; // NPC id
	if (v > 1000)
		return true; // typical runtime object id
	return false;
}

PartyItemsArgs ParsePartyItemsArgs(lua_State* L)
{
	PartyItemsArgs out;
	const int n = lua_gettop(L);

	const bool arg1BoolOrFlag = lua_isboolean(L, 1) ||
		(lua_isnumber(L, 1) && lua_tointeger(L, 1) <= 1);
	const int arg2 = n >= 2 && lua_isnumber(L, 2) ? (int)lua_tointeger(L, 2) : -1;
	const int arg4 = n >= 4 && lua_isnumber(L, 4) ? (int)lua_tointeger(L, 4) : -1;
	const int arg5 = n >= 5 && lua_isnumber(L, 5) ? (int)lua_tointeger(L, 5) : -1;

	if (n >= 5 && arg1BoolOrFlag && LooksLikeFrameOrAny(arg2) &&
		arg5 > 0 && arg5 < 256 && LooksLikeShapeId(arg4))
	{
		// Reversed: (bool/flag, frame, quality, shape, count)
		out.reversed = true;
		out.frame = NormalizeUsecodeAny(arg2);
		out.quality = NormalizeUsecodeAny((int)lua_tointeger(L, 3));
		out.shape = NormalizeUsecodeAny(arg4);
		out.count = arg5;
	}
	else
	{
		// Exult: (count, shape, quality, frame [, bool])
		out.reversed = false;
		out.count = n >= 1 ? (int)lua_tointeger(L, 1) : 1;
		out.shape = n >= 2 ? NormalizeUsecodeAny((int)lua_tointeger(L, 2)) : kUsecodeAny;
		out.quality = n >= 3 ? NormalizeUsecodeAny((int)lua_tointeger(L, 3)) : kUsecodeAny;
		out.frame = n >= 4 ? NormalizeUsecodeAny((int)lua_tointeger(L, 4)) : kUsecodeAny;
	}

	if (out.count < 1)
		out.count = 1;
	return out;
}

ContItemsArgs ParseContItemsArgs(lua_State* L)
{
	ContItemsArgs out;
	const int n = lua_gettop(L);
	if (n < 1)
		return out;

	const int a1 = n >= 1 && lua_isnumber(L, 1) ? (int)lua_tointeger(L, 1) : 0;
	const int a2 = n >= 2 && lua_isnumber(L, 2) ? (int)lua_tointeger(L, 2) : kUsecodeAny;
	const int a3 = n >= 3 && lua_isnumber(L, 3) ? (int)lua_tointeger(L, 3) : kUsecodeAny;
	const int a4 = n >= 4 && lua_isnumber(L, 4) ? (int)lua_tointeger(L, 4) : -1;

	// 3-arg reversed shorthand seen in scripts: (frame, shape, container) quality=any
	if (n == 3 && LooksLikeFrameOrAny(a1) && !LooksLikeShapeId(a1) &&
		LooksLikeObjectOrNpcId(a3) && (LooksLikeShapeId(a2) || IsUsecodeAny(a2)))
	{
		out.reversed = true;
		out.frame = NormalizeUsecodeAny(a1);
		out.quality = kUsecodeAny;
		out.shape = NormalizeUsecodeAny(a2);
		out.containerId = a3;
		return out;
	}

	// Prefer reversed when arg1 is frame/any (not a shape id), arg3 is shape/any,
	// and arg4 looks like a container. Exult (smallContainer, shape, …) has a shape-like
	// arg1 only when the container id itself is in 2..1023 — those still lose to Exult
	// because LooksLikeShapeId(containerId) is true (see tests).
	const bool reversedLikely = n >= 4 &&
		LooksLikeFrameOrAny(a1) &&
		!LooksLikeShapeId(a1) &&
		(LooksLikeShapeId(a3) || IsUsecodeAny(a3)) &&
		LooksLikeObjectOrNpcId(a4);

	if (reversedLikely)
	{
		out.reversed = true;
		out.frame = NormalizeUsecodeAny(a1);
		out.quality = NormalizeUsecodeAny(a2);
		out.shape = NormalizeUsecodeAny(a3);
		out.containerId = a4;
	}
	else
	{
		// Exult: (container, shape, quality, frame)
		out.reversed = false;
		out.containerId = a1;
		out.shape = NormalizeUsecodeAny(a2);
		out.quality = NormalizeUsecodeAny(a3);
		out.frame = n >= 4 ? NormalizeUsecodeAny(a4) : kUsecodeAny;
	}
	return out;
}

ContItemsArgs ParseFindObjectArgs(lua_State* L)
{
	// Same layouts as cont-items; reuse the heuristic.
	return ParseContItemsArgs(L);
}

FindNearbyArgs ParseFindNearbyArgs(lua_State* L)
{
	FindNearbyArgs out;
	const int n = lua_gettop(L);
	if (n < 1)
		return out;

	const int a1 = n >= 1 && lua_isnumber(L, 1) ? (int)lua_tointeger(L, 1) : 0;
	const int a2 = n >= 2 && lua_isnumber(L, 2) ? (int)lua_tointeger(L, 2) : 0;
	const int a3 = n >= 3 && lua_isnumber(L, 3) ? (int)lua_tointeger(L, 3) : 0;
	const int a4 = n >= 4 && lua_isnumber(L, 4) ? (int)lua_tointeger(L, 4) : 0;

	const bool maskLike = (a1 >= 0 && a1 <= 255);
	const bool distLike = (a2 >= 0 && a2 <= 256);
	const bool shapeLike = LooksLikeShapeId(a3) || IsUsecodeAny(a3) || a3 == 0;
	const bool refLike = LooksLikeObjectOrNpcId(a4) && a4 != 0;

	// Majority of decompiler calls: find_nearby(0, dist, shape, objectref)
	const bool strongReverse = (a1 == 0 && distLike && shapeLike && refLike);

	// Also: (mask, dist, shape, ref) with a real shape in arg3 and mask≠0
	// (e.g. mask 176). Avoid Exult (npcId, bigShape, dist, mask) where arg2 is the shape.
	const bool maskedReverse = maskLike && a1 != 0 && distLike &&
		LooksLikeShapeId(a3) && a3 >= 100 && refLike &&
		!(LooksLikeShapeId(a2) && a2 >= 100);

	if (n >= 4 && (strongReverse || maskedReverse))
	{
		out.reversed = true;
		out.mask = a1;
		out.distance = a2;
		out.shape = NormalizeUsecodeAny(a3);
		out.objectRef = a4;
	}
	else
	{
		// Exult: (objectref, shape, distance, mask)
		out.reversed = false;
		out.objectRef = a1;
		out.shape = n >= 2 ? NormalizeUsecodeAny(a2) : 0;
		out.distance = n >= 3 ? a3 : 0;
		out.mask = n >= 4 ? a4 : 0;
	}

	out.anyShape = IsUsecodeAny(out.shape) || out.shape == 0;
	if (out.distance < 0)
		out.distance = 0;
	return out;
}

std::string PartyItemsArgsToString(const PartyItemsArgs& a)
{
	std::ostringstream ss;
	ss << "count=" << a.count
	   << " shape=" << a.shape
	   << " quality=" << a.quality
	   << " frame=" << a.frame
	   << (a.reversed ? " [reversed]" : " [exult]");
	return ss.str();
}

std::string ContItemsArgsToString(const ContItemsArgs& a)
{
	std::ostringstream ss;
	ss << "container=" << a.containerId
	   << " shape=" << a.shape
	   << " quality=" << a.quality
	   << " frame=" << a.frame
	   << (a.reversed ? " [reversed]" : " [exult]");
	return ss.str();
}

std::string FindNearbyArgsToString(const FindNearbyArgs& a)
{
	std::ostringstream ss;
	ss << "ref=" << a.objectRef
	   << " shape=" << a.shape
	   << " dist=" << a.distance
	   << " mask=" << a.mask
	   << (a.reversed ? " [reversed]" : " [exult]");
	return ss.str();
}
