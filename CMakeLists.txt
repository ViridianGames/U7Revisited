cmake_minimum_required(VERSION 3.15)
project("Ultima 7 Revisited" VERSION 1.0.0 LANGUAGES C CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Default build type to Release
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Optimization and build settings
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)  # Enable LTO for Release builds only

# Compiler-specific flags
if(MSVC)
    # Suppress float-to-int warnings (C4244)
    add_compile_options(/wd4244)
    # Suppress truncation from 'double' to 'float' warnings (C4305)
    add_compile_options(/wd4305)
    # Suppress CRT security warnings for standard C functions
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
    # Declare C++17 for CPP source files
    add_compile_options(/std:c++17)
    # Warning level 3
    add_compile_options(/W3)
    # Release optimizations (using generator expressions for multi-config generators)
    add_compile_options($<$<CONFIG:Release>:/O2>)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    # For C4244 equivalent (float-to-int, general conversion issues)
    add_compile_options(-Wno-conversion)
    # Warning level
    add_compile_options(-Wall)
    # Release optimizations
    add_compile_options($<$<CONFIG:Release>:-O3>)
    add_link_options($<$<CONFIG:Release>:-s>)  # Strip symbols
endif()

# ============================================================================
# Raylib Dependency
# ============================================================================
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_LIBRARY_TYPE "OBJECT" CACHE STRING "" FORCE)
set(PLATFORM "Desktop" CACHE STRING "" FORCE)
if(WIN32)
    set(CMAKE_SYSTEM_VERSION "10.0.22621.0" CACHE STRING "" FORCE)
endif()

add_subdirectory(subprojects/raylib)
set(RAYLIB_EXTERNAL_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/subprojects/raylib/src/external)

# ============================================================================
# Lua Static Library
# ============================================================================
set(LUA_SOURCES
    ThirdParty/lua/src/lapi.c
    ThirdParty/lua/src/lcode.c
    ThirdParty/lua/src/lctype.c
    ThirdParty/lua/src/ldebug.c
    ThirdParty/lua/src/ldo.c
    ThirdParty/lua/src/ldump.c
    ThirdParty/lua/src/lfunc.c
    ThirdParty/lua/src/lgc.c
    ThirdParty/lua/src/llex.c
    ThirdParty/lua/src/lmem.c
    ThirdParty/lua/src/lobject.c
    ThirdParty/lua/src/lopcodes.c
    ThirdParty/lua/src/lparser.c
    ThirdParty/lua/src/lstate.c
    ThirdParty/lua/src/lstring.c
    ThirdParty/lua/src/ltable.c
    ThirdParty/lua/src/ltm.c
    ThirdParty/lua/src/lundump.c
    ThirdParty/lua/src/lvm.c
    ThirdParty/lua/src/lzio.c
    ThirdParty/lua/src/lauxlib.c
    ThirdParty/lua/src/lbaselib.c
    ThirdParty/lua/src/lcorolib.c
    ThirdParty/lua/src/ldblib.c
    ThirdParty/lua/src/liolib.c
    ThirdParty/lua/src/lmathlib.c
    ThirdParty/lua/src/loslib.c
    ThirdParty/lua/src/lstrlib.c
    ThirdParty/lua/src/ltablib.c
    ThirdParty/lua/src/linit.c
    ThirdParty/lua/src/loadlib.c
    ThirdParty/lua/src/lutf8lib.c
)

add_library(lua STATIC ${LUA_SOURCES})
target_include_directories(lua PUBLIC ThirdParty/lua/src)
target_compile_definitions(lua PRIVATE LUA_COMPAT_5_3)
if(WIN32)
    target_compile_definitions(lua PRIVATE LUA_BUILD_AS_DLL)
endif()

# ============================================================================
# Project Include Directories
# ============================================================================
include_directories(
    Source/Geist
    Source
)

# ============================================================================
# Source Files (Keep alphabetized)
# ============================================================================
set(SOURCES
    Source/Geist/BaseUnits.cpp
    Source/Geist/Config.cpp
    Source/Geist/Engine.cpp
    Source/Geist/Globals.cpp
    Source/Geist/Gui.cpp
    Source/Geist/GuiElements.cpp
    Source/Geist/GuiManager.cpp
    Source/Geist/IO.cpp
    Source/Geist/Logging.cpp
    Source/Geist/ParticleSystem.cpp
    Source/Geist/Primitives.cpp
    Source/Geist/RaylibModel.cpp
    Source/Geist/ResourceManager.cpp
    Source/Geist/RNG.cpp
    Source/Geist/ScriptingSystem.cpp
    Source/Geist/StateMachine.cpp
    Source/Geist/TooltipSystem.cpp

    Source/ConversationState.cpp
    Source/GumpManager.cpp
    Source/LoadingState.cpp
    Source/Main.cpp
    Source/MainState.cpp
    Source/OptionsState.cpp
    Source/Pathfinding.cpp
    Source/ShapeData.cpp
    Source/ShapeEditorState.cpp
    Source/Terrain.cpp
    Source/TitleState.cpp
    Source/U7GumpNumberBar.cpp
    Source/U7GumpBook.cpp
    Source/U7Globals.cpp
    Source/U7Gump.cpp
    Source/U7LuaFuncs.cpp
    Source/U7Object.cpp
    Source/U7Player.cpp
)

# ============================================================================
# Executable
# ============================================================================
add_executable(U7Revisited ${SOURCES})

# Link dependencies
target_link_libraries(U7Revisited PRIVATE
    raylib
    lua
)

# Additional include directories for dependencies
target_include_directories(U7Revisited PRIVATE
    ${RAYLIB_EXTERNAL_INCLUDE}
    ${CMAKE_CURRENT_SOURCE_DIR}/ThirdParty/raylib/external
)

# Windows-specific dependencies
if(WIN32)
    target_link_libraries(U7Revisited PRIVATE winmm)
endif()

# Set Visual Studio debugger working directory to Redist folder
set_target_properties(U7Revisited PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/Redist"
)

# Set as Visual Studio startup project
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT U7Revisited)

# ============================================================================
# Script Test Executable
# ============================================================================
# Use all main sources except Main.cpp (which has the game's main() function)
set(TEST_SOURCES ${SOURCES})
list(REMOVE_ITEM TEST_SOURCES Source/Main.cpp)

add_executable(ScriptTests
    Tests/ScriptTests.cpp
    Tests/ScriptTestMocks.cpp
    Tests/TestDataLoader.cpp
    ${TEST_SOURCES}
)

target_link_libraries(ScriptTests PRIVATE
    lua
    raylib
)

target_include_directories(ScriptTests PRIVATE
    Source
    Source/Geist
    ${RAYLIB_EXTERNAL_INCLUDE}
    ${CMAKE_CURRENT_SOURCE_DIR}/ThirdParty/raylib/external
)

# Windows-specific dependencies
if(WIN32)
    target_link_libraries(ScriptTests PRIVATE winmm)
endif()

# Set Visual Studio debugger working directory to Redist folder for testing
# and pass --execute flag by default
set_target_properties(ScriptTests PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/Redist"
    VS_DEBUGGER_COMMAND_ARGUMENTS "--execute"
)
