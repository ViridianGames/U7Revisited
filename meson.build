project('Ultima 7 Revisited', ['c', 'cpp'],
        version: '1.0.0',
        default_options: [
          'warning_level=3', 
          'cpp_std=c++17',
          'buildtype=release',  # Default to release build
          'b_ndebug=if-release'  # Define NDEBUG in release mode
        ])

# Get compiler
cpp = meson.get_compiler('cpp')
host_system = host_machine.system()

# Check for 64-bit architecture
if host_machine.cpu_family() != 'x86_64'
  error('This project requires 64-bit build. Current architecture: ' + host_machine.cpu_family())
endif

# Platform-specific compiler flags
if host_system == 'windows'
  # Windows-specific compiler flags for MSVC
  add_project_arguments('/wd4244', language: 'cpp') # Suppress float-to-int warnings
  add_project_arguments('/wd4305', language: 'cpp') # Suppress truncation from 'double' to 'float' warnings
elif host_system == 'linux'
  # Linux-specific compiler flags
  add_project_arguments('-Wno-unused-result', language: 'cpp')
  add_project_arguments('-Wno-format-security', language: 'cpp')
endif

# Apply different flags for debug and release builds
if get_option('buildtype') == 'debug'
  message('Configuring debug build')
  # Add debug-specific flags here
  if host_system == 'windows'
    add_project_arguments('/Zi', language: 'cpp')  # Debug information
    add_project_arguments('/Od', language: 'cpp')  # Disable optimization
  else
    add_project_arguments('-g', language: 'cpp')   # Debug information
    add_project_arguments('-O0', language: 'cpp')  # Disable optimization
  endif
elif get_option('buildtype') == 'release'
  message('Configuring release build')
  # Add release-specific flags here
  if host_system == 'windows'
    add_project_arguments('/O2', language: 'cpp')  # Optimize for speed
  else
    add_project_arguments('-O2', language: 'cpp')  # Optimize for speed
  endif
endif

cmake = import('cmake')

dependencies = []

raylib_options = cmake.subproject_options()
raylib_options.add_cmake_defines({
     'BUILD_EXAMPLES': 'OFF',
     'GLFW_LIBRARY_TYPE': 'OBJECT',
     'CMAKE_POLICY_VERSION_MINIMUM': '3.5',
     'PLATFORM': 'Desktop',
     'CMAKE_SKIP_INSTALL_RULES': 'ON',  # Skip install rules for raylib
})

# setup raylib dependency
raylib_subproject = cmake.subproject('raylib', options: raylib_options)
dependencies += raylib_subproject.dependency('raylib')

raylib_external_include = include_directories('ThirdParty/raylib/external')
dependencies += declare_dependency(include_directories: raylib_external_include) # Uncommented: Required include path

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

# Set platform-specific Lua defines
lua_args = ['-DLUA_COMPAT_5_3']
if host_system == 'windows'
  lua_args += '-DLUA_BUILD_AS_DLL'
endif

lua_lib = static_library(
    'lua',
    lua_sources,
    include_directories: lua_include,
    c_args: lua_args
)

dependencies += declare_dependency(
    include_directories: lua_include,
    link_with: lua_lib
)

# Platform-specific dependencies
if host_system == 'windows'
  cc = meson.get_compiler('c')
  dependencies += [
    cc.find_library('winmm', required: true)
  ]
elif host_system == 'linux'
  # Linux-specific dependencies if needed
  cc = meson.get_compiler('c')
  dependencies += [
    cc.find_library('m', required: true),  # Math library
    cc.find_library('dl', required: true), # Dynamic linking library
    cc.find_library('pthread', required: true) # Threading library
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

# Build the executable with appropriate build type
output_suffix = ''
if get_option('buildtype') == 'debug'
  output_suffix = '_debug'
else
  output_suffix = '_release'
endif

u7_exe = executable('U7Revisited' + output_suffix,
  sources,
  dependencies: dependencies,
  include_directories: include_directories,
  install: true,  # Use Meson's built-in install
  install_dir: 'bin' # Install executable into 'bin' subdir
)

# Platform-specific installation targets for both debug and release builds
# REMOVED custom run_target commands previously here
# Installation should now be done via 'meson install -C builddir'
