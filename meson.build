project('Ultima 7 Revisited', 'cpp')

cmake = import('cmake')

deps = []

# Configure GLFW to not try to build Wayland, couldn't get the dependencies
# right for it to work...
opt = cmake.subproject_options()
opt.add_cmake_defines({'GLFW_BUILD_WAYLAND': false})
glfw = cmake.subproject('glfw', options: opt)
deps += glfw.get_variable('glfw_dep')

raylib = subproject('raylib')
deps += raylib.get_variable('raylib_dep')

# Windows build seems to require dependency to this.
if host_machine.system() == 'windows'
  c_compiler = meson.get_compiler('c')
  winmm_lib = c_compiler.find_library('winmm', required: false)
  deps += winmm_lib
endif

# Only cpp files needed here. Keep alphabetized.
executable('u7revisited',
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
  'Source/Geist/RNG.cpp',
  'Source/Geist/ResourceManager.cpp',
  'Source/Geist/StateMachine.cpp',
  'Source/Geist/TooltipSystem.cpp',

  #'Source/GUMP.cpp',  # FIXME won't compile with this included
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
  'Source/U7Object.cpp',
  'Source/WorldEditorState.cpp',

  dependencies: deps,
)
