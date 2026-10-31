#include "Geist/Engine.h"
#include "Geist/Globals.h"
#include "Geist/ResourceManager.h"
#include "Geist/ScriptingSystem.h"
#include "Geist/SoundSystem.h"

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <vector>

// Test doubles keep these contract tests independent of a window, audio device,
// game assets, and game globals. SoundSystem and ScriptingSystem are real.
struct rAudioBuffer
{
    bool playing = false;
    bool released = false;
    float volume = 1.0f;
    float pan = 0.5f;
    int plays = 0;
};

std::unique_ptr<Engine> g_Engine;
std::unique_ptr<ResourceManager> g_ResourceManager;
std::unique_ptr<ScriptingSystem> g_ScriptingSystem;

static std::vector<std::unique_ptr<rAudioBuffer>> buffers;
static Sound lastPlayed{};
static float musicVolume = 1.0f;
static int failures = 0;

static void Expect(bool condition, const std::string& message)
{
    if (!condition)
    {
        std::cerr << "FAIL: " << message << '\n';
        ++failures;
    }
}

static bool Near(float actual, float expected)
{
    return std::abs(actual - expected) < 0.0001f;
}

static Sound NewSound()
{
    buffers.push_back(std::make_unique<rAudioBuffer>());
    Sound sound{};
    sound.frameCount = 100;
    sound.stream.buffer = buffers.back().get();
    return sound;
}

void Engine::Init(const std::string&) {}
void Engine::Shutdown() {}
void Engine::Update() {}
void Engine::Draw() {}
void ResourceManager::Init(const std::string&) {}
void ResourceManager::Shutdown() {}
void ResourceManager::Update() {}
RaylibModel::~RaylibModel() = default;
Sound* ResourceManager::GetSound(const std::string& path)
{
    auto it = m_SoundList.find(path);
    return it == m_SoundList.end() ? nullptr : it->second.get();
}
Music* ResourceManager::GetMusic(const std::string& path)
{
    auto it = m_MusicList.find(path);
    return it == m_MusicList.end() ? nullptr : it->second.get();
}
void Log(std::string, std::string, bool) {}
void DebugPrint(std::string) {}
double GetTime() { return 1.0; }
void InitAudioDevice() {}
Sound LoadSoundAlias(Sound) { return NewSound(); }
void UnloadSoundAlias(Sound sound)
{
    Expect(!sound.stream.buffer->released, "alias is released exactly once");
    sound.stream.buffer->released = true;
}
void PlaySound(Sound sound)
{
    Expect(!sound.stream.buffer->released, "released alias is never played");
    sound.stream.buffer->playing = true;
    ++sound.stream.buffer->plays;
    lastPlayed = sound;
}
bool IsSoundPlaying(Sound sound) { return sound.stream.buffer->playing; }
void StopSound(Sound sound) { sound.stream.buffer->playing = false; }
void SetSoundVolume(Sound sound, float volume) { sound.stream.buffer->volume = volume; }
void SetSoundPan(Sound sound, float pan) { sound.stream.buffer->pan = pan; }
void PlayMusicStream(Music) {}
void StopMusicStream(Music) {}
void UpdateMusicStream(Music) {}
void SetMusicVolume(Music, float volume) { musicVolume = volume; }

static SoundSystemHooks WorldHooks(Vector3& position, Camera& camera)
{
    SoundSystemHooks hooks;
    hooks.getListenerCamera = [&camera]() { return camera; };
    hooks.getObjectPosition = [&position](int, Vector3& out) { out = position; return true; };
    return hooks;
}

static void TestNoHooks()
{
    SoundSystem sound;
    sound.SetGlobalSoundVolume(60);
    sound.PlayLoopingSoundEffect(42, "sound", 8.0f, true);
    Sound loop = lastPlayed;
    sound.Update();
    Expect(!loop.stream.buffer->released, "loop survives updates without hooks");
    Expect(Near(loop.stream.buffer->volume, 0.6f) && Near(loop.stream.buffer->pan, 0.5f),
           "loop without hooks is centered at global volume");
    loop.stream.buffer->playing = false;
    sound.Update();
    Expect(loop.stream.buffer->plays == 2, "loop restarts without object hooks");
    sound.StopLoopingSoundEffect(42);
    Expect(loop.stream.buffer->released, "unpositioned loop can be explicitly stopped");
}

static void TestPartialHooks()
{
    SoundSystem sound;
    sound.SetGlobalSoundVolume(60);
    Vector3 position{1000.0f, 0.0f, 1000.0f};
    Camera camera{};
    auto hooks = WorldHooks(position, camera);
    hooks.getListenerCamera = {};
    sound.SetHooks(hooks);
    sound.PlaySoundAtObject("sound", 42, 8.0f);
    Expect(Near(lastPlayed.stream.buffer->volume, 0.6f) && Near(lastPlayed.stream.buffer->pan, 0.5f),
           "one-shot without listener uses unpositioned playback");
    Expect(sound.PlayInstrument(42, "sound", 8.0f), "instrument starts without listener");
    Sound instrument = lastPlayed;
    sound.Update();
    Expect(sound.IsInstrumentPlaying(42) && Near(instrument.stream.buffer->volume, 0.6f),
           "missing listener does not cause false instrument range stop");
    sound.PlayLoopingSoundEffect(43, "sound", 8.0f, true);
    Sound loop = lastPlayed;
    sound.Update();
    Expect(!loop.stream.buffer->released && Near(loop.stream.buffer->volume, 0.6f),
           "loop with position but no listener remains audible");

    hooks.getObjectPosition = {};
    hooks.getListenerCamera = [&camera]() { return camera; };
    sound.SetHooks(hooks);
    sound.Update();
    Expect(!loop.stream.buffer->released && Near(loop.stream.buffer->volume, 0.6f),
           "listener alone does not imply that the object was deleted");
}

static void TestWorldAudio()
{
    // Captured world state outlives SoundSystem, including its destructor.
    Vector3 position{1004.0f, 0.0f, 1000.0f};
    Camera camera{};
    camera.target = {1000.0f, 0.0f, 1000.0f};
    camera.position = {1000.0f, 10.0f, 990.0f};
    bool exists = true, dead = false, visible = false;
    SoundSystem sound;
    sound.SetGlobalSoundVolume(60);
    auto hooks = WorldHooks(position, camera);
    hooks.getObjectPosition = [&](int, Vector3& out) { out = position; return exists; };
    hooks.isObjectDead = [&](int) { return dead; };
    hooks.isObjectOnScreen = [&](int) { return visible; };
    sound.SetHooks(hooks);
    sound.PlaySoundAtObject("sound", 42, 8.0f);
    Expect(Near(lastPlayed.stream.buffer->volume, 0.15f) && Near(lastPlayed.stream.buffer->pan, 1.0f),
           "game hooks preserve quadratic attenuation and right pan");

    sound.PlayLoopingSoundEffect(42, "sound", 8.0f, true);
    Sound loop = lastPlayed;
    sound.Update();
    Expect(!loop.stream.buffer->released, "loop survives before first visible pass");
    visible = true;
    sound.Update();
    visible = false;
    sound.Update();
    Expect(loop.stream.buffer->released, "loop stops after leaving the screen");
    sound.PlayLoopingSoundEffect(42, "sound");
    loop = lastPlayed;
    dead = true;
    sound.Update();
    Expect(loop.stream.buffer->released, "dead object stops its loop");
    dead = false;
    sound.PlayLoopingSoundEffect(42, "sound");
    loop = lastPlayed;
    exists = false;
    sound.Update();
    Expect(loop.stream.buffer->released, "lookup failure stops deleted object's loop");

    exists = true;
    sound.PlayInstrument(42, "sound", 8.0f);
    Sound instrument = lastPlayed;
    auto noListener = hooks;
    noListener.getListenerCamera = {};
    sound.SetHooks(noListener);
    sound.Update();
    Expect(Near(instrument.stream.buffer->volume, 0.6f) && Near(instrument.stream.buffer->pan, 0.5f),
           "removing listener recenters a playing instrument");
    sound.SetHooks(hooks);
    position.x += 20.0f;
    sound.Update();
    Expect(!sound.IsInstrumentPlaying(42), "instrument beyond game listener range stops");
}

static void TestInstrumentNotifications()
{
    std::vector<int> events;
    SoundSystem sound;
    SoundSystemHooks hooks;
    hooks.onInstrumentStarted = [&](int id) { events.push_back(id); };
    hooks.onInstrumentStopped = [&](int id) { events.push_back(-id); };
    sound.SetHooks(hooks);
    sound.SetGlobalMusicVolume(80);
    sound.PlayMusic("music");
    sound.PlayInstrument(42, "sound");
    Expect(Near(musicVolume, 0.12f), "instrument ducks background music");
    lastPlayed.stream.buffer->playing = false;
    Expect(!sound.PlayInstrument(42, "missing"), "missing replacement clip fails");
    Expect(events == std::vector<int>({42, -42}), "failed replacement still balances instrument notifications");
    Expect(Near(musicVolume, 0.8f), "failed replacement restores background music volume");

    events.clear();
    sound.PlayInstrument(42, "sound");
    lastPlayed.stream.buffer->playing = false;
    sound.PlayInstrument(42, "sound");
    Expect(events == std::vector<int>({42, -42, 42}), "finished instrument stops before replacement starts");
    sound.Shutdown();
    sound.Shutdown();
    Expect(events == std::vector<int>({42, -42, 42, -42}), "repeated shutdown does not duplicate notifications");
}

static void AddYieldingScript(ScriptingSystem& scripts, const std::string& key)
{
    lua_State* co = lua_newthread(scripts.m_luaState);
    scripts.m_activeCoroutines[key] = luaL_ref(scripts.m_luaState, LUA_REGISTRYINDEX);
    const char* code = "local id = coroutine.yield(); resumed = (resumed or 0) + 1; resumed_id = id";
    Expect(luaL_loadstring(co, code) == LUA_OK, "test coroutine loads");
    int results = 0;
    Expect(lua_resume(co, scripts.m_luaState, 0, &results) == LUA_YIELD, "test coroutine yields");
    scripts.m_waitTimers[key] = 0.0f;
}

static int LuaNumber(ScriptingSystem& scripts, const char* name)
{
    lua_getglobal(scripts.m_luaState, name);
    int value = static_cast<int>(lua_tointeger(scripts.m_luaState, -1));
    lua_pop(scripts.m_luaState, 1);
    return value;
}

static void TestNpcResume()
{
    bool defer = true;
    int checkedId = -1;
    ScriptingSystem scripts;
    scripts.m_shouldDeferNpcResume = [&](int id) { checkedId = id; return defer; };
    AddYieldingScript(scripts, "activity_loiter_42");
    scripts.Update();
    Expect(checkedId == 42 && scripts.IsCoroutineYielded("activity_loiter_42"),
           "NPC hook receives ID and postpones yielded activity");
    Expect(scripts.m_waitTimers.count("activity_loiter_42") == 1 && scripts.m_scriptResumesThisFrame == 0,
           "deferred NPC is retried without consuming resume budget");
    defer = false;
    scripts.Update();
    Expect(LuaNumber(scripts, "resumed") == 1 && LuaNumber(scripts, "resumed_id") == 42,
           "allowed NPC resumes its full coroutine key with ID");
    Expect(!scripts.IsCoroutineActive("activity_loiter_42"), "completed NPC coroutine is cleaned up");

    scripts.m_shouldDeferNpcResume = {};
    AddYieldingScript(scripts, "activity_loiter_43");
    scripts.Update();
    Expect(LuaNumber(scripts, "resumed") == 2, "unset NPC hook permits resume");

    scripts.m_shouldDeferNpcResume = [](int) { return true; };
    AddYieldingScript(scripts, "conversation_42");
    scripts.Update();
    Expect(LuaNumber(scripts, "resumed") == 3, "NPC deferral does not block non-activity scripts");

    for (const std::string key : {"activity_test_", "activity_test_999999999999999999999"})
    {
        AddYieldingScript(scripts, key);
        scripts.Update();
        Expect(!scripts.IsCoroutineActive(key), "invalid NPC suffix resumes safely using full key: " + key);
    }

    scripts.m_shouldDeferNpcResume = {};
    scripts.m_maxScriptResumesPerFrame = 1;
    AddYieldingScript(scripts, "activity_loiter_44");
    AddYieldingScript(scripts, "activity_loiter_45");
    scripts.Update();
    Expect(LuaNumber(scripts, "resumed") == 6 && scripts.m_waitTimers.size() == 1,
           "NPC resume budget leaves the other NPC queued");
    scripts.Update();
    Expect(LuaNumber(scripts, "resumed") == 7 && scripts.m_waitTimers.empty(),
           "queued NPC resumes on the next frame with its own key");
}

int main()
{
    g_Engine = std::make_unique<Engine>();
    g_Engine->m_lastFrameInSecs = 0.1;
    g_ResourceManager = std::make_unique<ResourceManager>();
    g_ResourceManager->m_SoundList["sound"] = std::make_unique<Sound>(NewSound());
    g_ResourceManager->m_MusicList["music"] = std::make_unique<Music>();
    TestNoHooks();
    TestPartialHooks();
    TestWorldAudio();
    TestInstrumentNotifications();
    TestNpcResume();
    if (failures == 0)
        std::cout << "All engine hook contract tests passed.\n";
    return failures == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
