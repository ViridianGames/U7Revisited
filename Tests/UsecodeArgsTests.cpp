///////////////////////////////////////////////////////////////////////////
//
// Name:     UsecodeArgsTests.cpp
// Purpose:  Lightweight unit tests for U7UsecodeArgs (no full game boot).
//
///////////////////////////////////////////////////////////////////////////

#include "U7UsecodeArgs.h"

#include <cstdlib>
#include <iostream>
#include <string>

extern "C"
{
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

static int g_failures = 0;

static void Expect(bool cond, const std::string& msg)
{
	if (!cond)
	{
		std::cerr << "FAIL: " << msg << "\n";
		++g_failures;
	}
	else
	{
		std::cout << "ok: " << msg << "\n";
	}
}

static lua_State* NewState()
{
	lua_State* L = luaL_newstate();
	luaL_openlibs(L);
	return L;
}

static void TestNormalize()
{
	Expect(NormalizeUsecodeAny(359) == kUsecodeAny, "Normalize 359");
	Expect(NormalizeUsecodeAny(-359) == kUsecodeAny, "Normalize -359");
	Expect(NormalizeUsecodeAny(0xFE99) == kUsecodeAny, "Normalize 0xFE99");
	Expect(NormalizeUsecodeAny(-1) == -1, "Normalize -1 leaves -1");
	Expect(IsUsecodeAny(-1), "IsUsecodeAny -1");
	Expect(IsUsecodeAny(359), "IsUsecodeAny 359");
	Expect(!IsUsecodeAny(641), "641 is not any");
	Expect(NormalizeUsecodeAny(641) == 641, "Normalize 641 unchanged");
}

static void TestClamp()
{
	Expect(ClampShapeFrame(359) == 0, "Clamp 359 → 0");
	Expect(ClampShapeFrame(-359) == 0, "Clamp -359 → 0");
	Expect(ClampShapeFrame(6) == 6, "Clamp 6 unchanged");
	Expect(ClampShapeFrame(32) == 0, "Clamp 32 → 0");
	Expect(ClampShapeFrame(-1) == 0, "Clamp -1 → 0");
}

static void TestMatch()
{
	Expect(MatchesShapeQualityFrame(641, 255, 0, kUsecodeAny, kUsecodeAny, kUsecodeAny),
		"any/any/any matches");
	Expect(MatchesShapeQualityFrame(641, 255, 0, 641, 255, 0), "exact match");
	Expect(!MatchesShapeQualityFrame(641, 255, 0, 641, 1, 0), "quality mismatch");
	Expect(MatchesShapeQualityFrame(641, 255, 0, 641, 359, 0), "quality 359 is any");
	Expect(!MatchesShapeQualityFrame(652, 0, 0, 641, kUsecodeAny, kUsecodeAny), "shape mismatch");
}

static void TestPartyItemsReversed()
{
	lua_State* L = NewState();
	lua_pushboolean(L, 1);
	lua_pushinteger(L, 359);
	lua_pushinteger(L, 255);
	lua_pushinteger(L, 641);
	lua_pushinteger(L, 1);
	PartyItemsArgs a = ParsePartyItemsArgs(L);
	Expect(a.reversed, "party reversed detected");
	Expect(a.shape == 641, "party reversed shape 641");
	Expect(a.quality == 255, "party reversed quality 255");
	Expect(IsUsecodeAny(a.frame), "party reversed frame any");
	Expect(a.count == 1, "party reversed count 1");
	lua_close(L);
}

static void TestPartyItemsExult()
{
	lua_State* L = NewState();
	lua_pushinteger(L, 1);
	lua_pushinteger(L, 641);
	lua_pushinteger(L, 255);
	lua_pushinteger(L, -359);
	lua_pushboolean(L, 1);
	PartyItemsArgs a = ParsePartyItemsArgs(L);
	Expect(!a.reversed, "party exult detected");
	Expect(a.shape == 641, "party exult shape 641");
	Expect(a.quality == 255, "party exult quality 255");
	Expect(IsUsecodeAny(a.frame), "party exult frame any");
	Expect(a.count == 1, "party exult count 1");
	lua_close(L);
}

static void TestContItemsReversed()
{
	lua_State* L = NewState();
	lua_pushinteger(L, 359);
	lua_pushinteger(L, 255);
	lua_pushinteger(L, 641);
	lua_pushinteger(L, 99);
	ContItemsArgs a = ParseContItemsArgs(L);
	Expect(a.reversed, "cont reversed detected");
	Expect(a.containerId == 99, "cont reversed container 99");
	Expect(a.shape == 641, "cont reversed shape 641");
	Expect(a.quality == 255, "cont reversed quality 255");
	Expect(IsUsecodeAny(a.frame), "cont reversed frame any");
	lua_close(L);
}

static void TestContItemsExult()
{
	lua_State* L = NewState();
	// container 50 looks like a frame range value but also like a shape id → Exult wins
	lua_pushinteger(L, 50);
	lua_pushinteger(L, 641);
	lua_pushinteger(L, 255);
	lua_pushinteger(L, 0);
	ContItemsArgs a = ParseContItemsArgs(L);
	Expect(!a.reversed, "cont exult detected for (50,641,255,0)");
	Expect(a.containerId == 50, "cont exult container 50");
	Expect(a.shape == 641, "cont exult shape 641");
	Expect(a.quality == 255, "cont exult quality 255");
	Expect(a.frame == 0, "cont exult frame 0");
	lua_close(L);
}

static void TestContItemsThreeArg()
{
	lua_State* L = NewState();
	lua_pushinteger(L, 359);
	lua_pushinteger(L, 839);
	lua_pushinteger(L, 357);
	ContItemsArgs a = ParseContItemsArgs(L);
	Expect(a.reversed, "cont 3-arg reversed");
	Expect(a.containerId == 357, "cont 3-arg container");
	Expect(a.shape == 839, "cont 3-arg shape");
	Expect(IsUsecodeAny(a.quality), "cont 3-arg quality any");
	Expect(IsUsecodeAny(a.frame), "cont 3-arg frame any");
	lua_close(L);
}

static void TestFindNearbyReversed()
{
	lua_State* L = NewState();
	// find_nearby(0, 20, 377, objectref) — classic decompiler form
	lua_pushinteger(L, 0);
	lua_pushinteger(L, 20);
	lua_pushinteger(L, 377);
	lua_pushinteger(L, 204118);
	FindNearbyArgs a = ParseFindNearbyArgs(L);
	Expect(a.reversed, "find_nearby reversed (0,dist,shape,ref)");
	Expect(a.objectRef == 204118, "find_nearby rev ref");
	Expect(a.shape == 377, "find_nearby rev shape");
	Expect(a.distance == 20, "find_nearby rev dist");
	Expect(a.mask == 0, "find_nearby rev mask");
	Expect(!a.anyShape, "find_nearby rev not any-shape");
	lua_close(L);
}

static void TestFindNearbyReversedLongDist()
{
	// Old Lua wrapper rejected dist > 64; C++ must accept 80.
	lua_State* L = NewState();
	lua_pushinteger(L, 0);
	lua_pushinteger(L, 80);
	lua_pushinteger(L, 403);
	lua_pushinteger(L, -356);
	FindNearbyArgs a = ParseFindNearbyArgs(L);
	Expect(a.reversed, "find_nearby reversed dist=80");
	Expect(a.distance == 80, "find_nearby dist 80");
	Expect(a.shape == 403, "find_nearby shape 403");
	Expect(a.objectRef == -356, "find_nearby avatar ref");
	lua_close(L);
}

static void TestFindNearbyExult()
{
	lua_State* L = NewState();
	// Exult: (npcRef, shape, dist, mask) — shape in arg2 is large
	lua_pushinteger(L, 21);
	lua_pushinteger(L, 650);
	lua_pushinteger(L, 20);
	lua_pushinteger(L, 0);
	FindNearbyArgs a = ParseFindNearbyArgs(L);
	Expect(!a.reversed, "find_nearby exult (npc,shape,dist,mask)");
	Expect(a.objectRef == 21, "find_nearby exult ref");
	Expect(a.shape == 650, "find_nearby exult shape");
	Expect(a.distance == 20, "find_nearby exult dist");
	lua_close(L);
}

static void TestFindNearbyMaskedReverse()
{
	lua_State* L = NewState();
	// mask 176, dist 5, shape 820, ref
	lua_pushinteger(L, 176);
	lua_pushinteger(L, 5);
	lua_pushinteger(L, 820);
	lua_pushinteger(L, 5000);
	FindNearbyArgs a = ParseFindNearbyArgs(L);
	Expect(a.reversed, "find_nearby masked reverse");
	Expect(a.mask == 176, "find_nearby mask 176");
	Expect(a.shape == 820, "find_nearby shape 820");
	Expect(a.objectRef == 5000, "find_nearby ref 5000");
	lua_close(L);
}

int main()
{
	TestNormalize();
	TestClamp();
	TestMatch();
	TestPartyItemsReversed();
	TestPartyItemsExult();
	TestContItemsReversed();
	TestContItemsExult();
	TestContItemsThreeArg();
	TestFindNearbyReversed();
	TestFindNearbyReversedLongDist();
	TestFindNearbyExult();
	TestFindNearbyMaskedReverse();

	if (g_failures)
	{
		std::cerr << g_failures << " failure(s)\n";
		return 1;
	}
	std::cout << "All UsecodeArgsTests passed\n";
	return 0;
}
