///////////////////////////////////////////////////////////////////////////
//
// Name:     U7UsecodeArgs.h
// Purpose:  Shared usecode/Lua argument contracts for Exult intrinsics.
//
// Decompiled BG Lua often reverses Exult intrinsic argument order and emits
// unsigned 359 for the classic "any" sentinel (-359 / 0xFE99). Every inventory
// / find / create binding should go through these helpers so wildcards and
// order heuristics stay consistent (no more shape-table OOB "cart piece" bugs).
//
// Common layouts:
//   Exult party items:     (count, shape, quality, frame [, temporary])
//   Reversed party items:  (bool/0/1, frame, quality, shape, count)
//   Exult cont items:      (container, shape, quality, frame)
//   Reversed cont items:   (frame, quality, shape, container)
//   Exult find_nearby:     (objectref, shape, distance, mask)
//   Reversed find_nearby:  (mask, distance, shape, objectref)
//
///////////////////////////////////////////////////////////////////////////

#ifndef _U7UsecodeArgs_h_
#define _U7UsecodeArgs_h_

#include <string>

struct lua_State;

// Canonical "any" after NormalizeUsecodeAny (also treats -1 as any in IsUsecodeAny).
constexpr int kUsecodeAny = -359;

int  NormalizeUsecodeAny(int v);
bool IsUsecodeAny(int v);

// g_shapeTable is [1024][32] — never pass usecode "any" through as a frame index.
int ClampShapeFrame(int frame);

// Match live object fields against filters (any = accept).
bool MatchesShapeQualityFrame(int objShape, int objQuality, int objFrame,
                              int wantShape, int wantQuality, int wantFrame);

struct PartyItemsArgs
{
	int count = 1;
	int shape = kUsecodeAny;
	int quality = kUsecodeAny;
	int frame = kUsecodeAny;
	bool reversed = false;
};

// Exult: (count, shape, quality, frame [, bool])
// Reversed: (bool/0/1, frame, quality, shape, count)
PartyItemsArgs ParsePartyItemsArgs(lua_State* L);

struct ContItemsArgs
{
	int containerId = -1;
	int shape = kUsecodeAny;
	int quality = kUsecodeAny;
	int frame = kUsecodeAny;
	bool reversed = false;
};

// Exult: (container, shape, quality, frame)
// Reversed (decompiler / all current Lua call sites): (frame, quality, shape, container)
ContItemsArgs ParseContItemsArgs(lua_State* L);

// Find-object uses the same shapes as cont-items but often Exult order.
// Heuristic: if arg1 looks like a container/NPC id and arg2 like a shape, Exult;
// if arg1 looks like frame/any and arg4 like container, reversed.
ContItemsArgs ParseFindObjectArgs(lua_State* L);

struct FindNearbyArgs
{
	int objectRef = -1;
	int shape = 0;       // 0 / any = match all shapes
	int distance = 0;
	int mask = 0;        // currently unused by engine search
	bool reversed = false;
	bool anyShape = true;
};

// Exult: (objectref, shape, distance, mask)
// Reversed (most BG Lua): (mask, distance, shape, objectref)
FindNearbyArgs ParseFindNearbyArgs(lua_State* L);

std::string PartyItemsArgsToString(const PartyItemsArgs& a);
std::string ContItemsArgsToString(const ContItemsArgs& a);
std::string FindNearbyArgsToString(const FindNearbyArgs& a);

#endif
