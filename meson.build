project('Ultima 7 Revisited', 'cpp')

cmake = import('cmake')

deps = []

opt = cmake.subproject_options()
opt.add_cmake_defines({'GLFW_LIBRARY_TYPE': 'OBJECT'})
raylib = cmake.subproject('raylib', options: opt)
deps += raylib.get_variable('raylib_dep')

# Windows build seems to require dependency to this.
if host_machine.system() == 'windows'
  c_compiler = meson.get_compiler('c')
  winmm_lib = c_compiler.find_library('winmm', required: false)
  deps += winmm_lib
endif

# Only cpp files needed here. Keep alphabetized.
executable('U7Revisited',
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
  'Source/Geist/RNG.cpp',
  'Source/Geist/ResourceManager.cpp',
  'Source/Geist/StateMachine.cpp',
  'Source/Geist/TooltipSystem.cpp',

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

  dependencies: deps,
)
