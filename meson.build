project('Ultima 7 Revisited', 'cpp',
        version: '1.0.0',
        default_options: ['warning_level=3'])


dependencies = []
cpp_args = []

cmake = import('cmake')

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

# setup lua dependency
dependencies += dependency('lua')

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
           'Source/U7Object.cpp',
           'Source/WorldEditorState.cpp',
)

executable('U7Revisited',
  sources,
  cpp_args: cpp_args,
  dependencies: dependencies,
  include_directories: include_directories,
)
