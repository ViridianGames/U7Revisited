project('Ultima 7 Revisited', ['c', 'cpp'],
        version: '1.0.0',
        default_options: ['warning_level=3'])

# Suppress float-to-int warnings (C4244)
add_project_arguments('/wd4244', language: 'cpp')

# Suppress truncation from 'double' to 'float' warnings (C4305)
add_project_arguments('/wd4305', language: 'cpp')

# Declare C++17 for CPP source files
add_project_arguments('/std:c++17', language: 'cpp')

cmake = import('cmake')

dependencies = []

raylib_options = cmake.subproject_options()
raylib_options.add_cmake_defines({
     'BUILD_EXAMPLES': 'OFF',
     'GLFW_LIBRARY_TYPE': 'OBJECT',
     'CMAKE_POLICY_VERSION_MINIMUM': '3.5',
     'PLATFORM': 'Desktop',
})

# setup raylib dependency
raylib_subproject = cmake.subproject('raylib', options: raylib_options)
dependencies += raylib_subproject.dependency('raylib')

raylib_external_include = include_directories('ThirdParty/raylib/external')
dependencies += declare_dependency(include_directories: raylib_external_include)

# declare the lua dependency referencing the bundled version
lua_sources = files(
    'ThirdParty/lua/src/lapi.c',
    'ThirdParty/lua/src/lcode.c',
    'ThirdParty/lua/src/lctype.c',
    'ThirdParty/lua/src/ldebug.c',
    'ThirdParty/lua/src/ldo.c',
    'ThirdParty/lua/src/ldump.c',
    'ThirdParty/lua/src/lfunc.c',
    'ThirdParty/lua/src/lgc.c',
    'ThirdParty/lua/src/llex.c',
    'ThirdParty/lua/src/lmem.c',
    'ThirdParty/lua/src/lobject.c',
    'ThirdParty/lua/src/lopcodes.c',
    'ThirdParty/lua/src/lparser.c',
    'ThirdParty/lua/src/lstate.c',
    'ThirdParty/lua/src/lstring.c',
    'ThirdParty/lua/src/ltable.c',
    'ThirdParty/lua/src/ltm.c',
    'ThirdParty/lua/src/lundump.c',
    'ThirdParty/lua/src/lvm.c',
    'ThirdParty/lua/src/lzio.c',
    'ThirdParty/lua/src/lauxlib.c',
    'ThirdParty/lua/src/lbaselib.c',
    'ThirdParty/lua/src/lcorolib.c',
    'ThirdParty/lua/src/ldblib.c',
    'ThirdParty/lua/src/liolib.c',
    'ThirdParty/lua/src/lmathlib.c',
    'ThirdParty/lua/src/loslib.c',
    'ThirdParty/lua/src/lstrlib.c',
    'ThirdParty/lua/src/ltablib.c',
    'ThirdParty/lua/src/linit.c',
    'ThirdParty/lua/src/loadlib.c',
    'ThirdParty/lua/src/lutf8lib.c',
)
lua_include = include_directories('ThirdParty/lua/src')
lua_lib = static_library(
    'lua',
    lua_sources,
    include_directories: lua_include,
    c_args: ['-DLUA_COMPAT_5_3', '-DLUA_BUILD_AS_DLL']
)

dependencies += declare_dependency(
    include_directories: lua_include,
    link_with: lua_lib
)

# Windows build requires dependency of winmm
if host_machine.system() == 'windows'
  cc = meson.get_compiler('c')
  dependencies += [
    cc.find_library('winmm', required: false)
  ]
endif

include_directories = include_directories(
  'Source/Geist',
  'Source'
)

# Only cpp files needed here. Keep alphabetized.
sources = files(
           'Source/Geist/BaseUnits.cpp',
           'Source/Geist/Config.cpp',
           'Source/Geist/Engine.cpp',
           'Source/Geist/Globals.cpp',
           'Source/Geist/Gui.cpp',
           'Source/Geist/GuiElements.cpp',
           'Source/Geist/GuiManager.cpp',
           'Source/Geist/IO.cpp',
           'Source/Geist/Logging.cpp',
           'Source/Geist/ParticleSystem.cpp',
           'Source/Geist/Primitives.cpp',
           'Source/Geist/RaylibModel.cpp',
           'Source/Geist/ResourceManager.cpp',
           'Source/Geist/RNG.cpp',
           'Source/Geist/ScriptingSystem.cpp',
           'Source/Geist/StateMachine.cpp',
           'Source/Geist/TooltipSystem.cpp',

           'Source/ConversationState.cpp',
           'Source/LoadingState.cpp',
           'Source/Main.cpp',
           'Source/MainState.cpp',
           'Source/ObjectEditorState.cpp',
           'Source/OptionsState.cpp',
           'Source/ShapeData.cpp',
           'Source/ShapeEditorState.cpp',
           'Source/Terrain.cpp',
           'Source/TitleState.cpp',
           'Source/U7Globals.cpp',
           'Source/U7Gump.cpp',
           'Source/U7LuaFuncs.cpp',
           'Source/U7Object.cpp',
           'Source/U7Player.cpp',
           'Source/WorldEditorState.cpp',
)

executable('U7Revisited',
  sources,
  dependencies: dependencies,
  include_directories: include_directories,
  cpp_args: [],
)
