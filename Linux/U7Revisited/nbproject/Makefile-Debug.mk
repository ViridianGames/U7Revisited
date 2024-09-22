#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Environment
MKDIR=mkdir
CP=cp
GREP=grep
NM=nm
CCADMIN=CCadmin
RANLIB=ranlib
CC=gcc
CCC=g++
CXX=g++
FC=gfortran
AS=as

# Macros
CND_PLATFORM=GNU-Linux
CND_DLIB_EXT=so
CND_CONF=Debug
CND_DISTDIR=dist
CND_BUILDDIR=build

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=${CND_BUILDDIR}/${CND_CONF}/${CND_PLATFORM}

# Object Files
OBJECTFILES= \
	${OBJECTDIR}/_ext/d8db8d98/BaseUnits.o \
	${OBJECTDIR}/_ext/d8db8d98/Config.o \
	${OBJECTDIR}/_ext/d8db8d98/Display.o \
	${OBJECTDIR}/_ext/d8db8d98/Engine.o \
	${OBJECTDIR}/_ext/d8db8d98/Font.o \
	${OBJECTDIR}/_ext/d8db8d98/GUIElements.o \
	${OBJECTDIR}/_ext/d8db8d98/Globals.o \
	${OBJECTDIR}/_ext/d8db8d98/Gui.o \
	${OBJECTDIR}/_ext/d8db8d98/IO.o \
	${OBJECTDIR}/_ext/d8db8d98/Input.o \
	${OBJECTDIR}/_ext/d8db8d98/Logging.o \
	${OBJECTDIR}/_ext/d8db8d98/MemoryManager.o \
	${OBJECTDIR}/_ext/d8db8d98/ParticleSystem.o \
	${OBJECTDIR}/_ext/d8db8d98/Primitives.o \
	${OBJECTDIR}/_ext/d8db8d98/RNG.o \
	${OBJECTDIR}/_ext/d8db8d98/ResourceManager.o \
	${OBJECTDIR}/_ext/d8db8d98/Sound.o \
	${OBJECTDIR}/_ext/d8db8d98/StateMachine.o \
	${OBJECTDIR}/_ext/d8db8d98/TooltipSystem.o \
	${OBJECTDIR}/_ext/957bd1db/LoadingState.o \
	${OBJECTDIR}/_ext/957bd1db/Main.o \
	${OBJECTDIR}/_ext/957bd1db/MainState.o \
	${OBJECTDIR}/_ext/957bd1db/ObjectEditorState.o \
	${OBJECTDIR}/_ext/957bd1db/OptionsState.o \
	${OBJECTDIR}/_ext/957bd1db/ShapeData.o \
	${OBJECTDIR}/_ext/957bd1db/Terrain.o \
	${OBJECTDIR}/_ext/957bd1db/TitleState.o \
	${OBJECTDIR}/_ext/957bd1db/U7Globals.o \
	${OBJECTDIR}/_ext/957bd1db/U7Object.o \
	${OBJECTDIR}/_ext/957bd1db/WorldEditorState.o \
	${OBJECTDIR}/_ext/ffca3baf/soloud_monotone.o \
	${OBJECTDIR}/_ext/16f4a480/soloud_noise.o \
	${OBJECTDIR}/_ext/62be208d/soloud_openmpt.o \
	${OBJECTDIR}/_ext/62be208d/soloud_openmpt_dll.o \
	${OBJECTDIR}/_ext/ae2b1267/soloud_sfxr.o \
	${OBJECTDIR}/_ext/d034383c/darray.o \
	${OBJECTDIR}/_ext/d034383c/klatt.o \
	${OBJECTDIR}/_ext/d034383c/resonator.o \
	${OBJECTDIR}/_ext/d034383c/soloud_speech.o \
	${OBJECTDIR}/_ext/d034383c/tts.o \
	${OBJECTDIR}/_ext/d14dcf35/sid.o \
	${OBJECTDIR}/_ext/d14dcf35/soloud_tedsid.o \
	${OBJECTDIR}/_ext/d14dcf35/ted.o \
	${OBJECTDIR}/_ext/de066f6/soloud_vic.o \
	${OBJECTDIR}/_ext/1762e628/soloud_vizsn.o \
	${OBJECTDIR}/_ext/de069d2/dr_impl.o \
	${OBJECTDIR}/_ext/de069d2/soloud_wav.o \
	${OBJECTDIR}/_ext/de069d2/soloud_wavstream.o \
	${OBJECTDIR}/_ext/de069d2/stb_vorbis.o \
	${OBJECTDIR}/_ext/7dc31a50/soloud_alsa.o \
	${OBJECTDIR}/_ext/c247ff60/soloud_coreaudio.o \
	${OBJECTDIR}/_ext/7dc70676/soloud_jack.o \
	${OBJECTDIR}/_ext/50e7bda8/soloud_miniaudio.o \
	${OBJECTDIR}/_ext/c82ab1f7/soloud_nosound.o \
	${OBJECTDIR}/_ext/7dc9241e/soloud_null.o \
	${OBJECTDIR}/_ext/317bdccc/soloud_openal.o \
	${OBJECTDIR}/_ext/317bdccc/soloud_openal_dll.o \
	${OBJECTDIR}/_ext/c2001528/soloud_opensles.o \
	${OBJECTDIR}/_ext/f38aa198/soloud_oss.o \
	${OBJECTDIR}/_ext/635a53be/soloud_portaudio.o \
	${OBJECTDIR}/_ext/635a53be/soloud_portaudio_dll.o \
	${OBJECTDIR}/_ext/f38aaec4/soloud_sdl1.o \
	${OBJECTDIR}/_ext/f38aaec4/soloud_sdl1_dll.o \
	${OBJECTDIR}/_ext/f38aaec4/soloud_sdl2.o \
	${OBJECTDIR}/_ext/f38aaec4/soloud_sdl2_dll.o \
	${OBJECTDIR}/_ext/879a39df/soloud_sdl2_static.o \
	${OBJECTDIR}/_ext/de59b849/soloud_sdl_static.o \
	${OBJECTDIR}/_ext/3e556f68/soloud_wasapi.o \
	${OBJECTDIR}/_ext/3bd4c6c5/soloud_winmm.o \
	${OBJECTDIR}/_ext/c15c2b9d/soloud_xaudio2.o \
	${OBJECTDIR}/_ext/b5c86bc2/soloud_c.o \
	${OBJECTDIR}/_ext/9240839b/soloud.o \
	${OBJECTDIR}/_ext/9240839b/soloud_audiosource.o \
	${OBJECTDIR}/_ext/9240839b/soloud_bus.o \
	${OBJECTDIR}/_ext/9240839b/soloud_core_3d.o \
	${OBJECTDIR}/_ext/9240839b/soloud_core_basicops.o \
	${OBJECTDIR}/_ext/9240839b/soloud_core_faderops.o \
	${OBJECTDIR}/_ext/9240839b/soloud_core_filterops.o \
	${OBJECTDIR}/_ext/9240839b/soloud_core_getters.o \
	${OBJECTDIR}/_ext/9240839b/soloud_core_setters.o \
	${OBJECTDIR}/_ext/9240839b/soloud_core_voicegroup.o \
	${OBJECTDIR}/_ext/9240839b/soloud_core_voiceops.o \
	${OBJECTDIR}/_ext/9240839b/soloud_fader.o \
	${OBJECTDIR}/_ext/9240839b/soloud_fft.o \
	${OBJECTDIR}/_ext/9240839b/soloud_fft_lut.o \
	${OBJECTDIR}/_ext/9240839b/soloud_file.o \
	${OBJECTDIR}/_ext/9240839b/soloud_filter.o \
	${OBJECTDIR}/_ext/9240839b/soloud_misc.o \
	${OBJECTDIR}/_ext/9240839b/soloud_queue.o \
	${OBJECTDIR}/_ext/9240839b/soloud_thread.o \
	${OBJECTDIR}/_ext/8f59074/soloud_bassboostfilter.o \
	${OBJECTDIR}/_ext/8f59074/soloud_biquadresonantfilter.o \
	${OBJECTDIR}/_ext/8f59074/soloud_dcremovalfilter.o \
	${OBJECTDIR}/_ext/8f59074/soloud_echofilter.o \
	${OBJECTDIR}/_ext/8f59074/soloud_fftfilter.o \
	${OBJECTDIR}/_ext/8f59074/soloud_flangerfilter.o \
	${OBJECTDIR}/_ext/8f59074/soloud_freeverbfilter.o \
	${OBJECTDIR}/_ext/8f59074/soloud_lofifilter.o \
	${OBJECTDIR}/_ext/8f59074/soloud_robotizefilter.o \
	${OBJECTDIR}/_ext/8f59074/soloud_waveshaperfilter.o


# C Compiler Flags
CFLAGS=

# CC Compiler Flags
CCFLAGS=-m64
CXXFLAGS=-m64

# Fortran Compiler Flags
FFLAGS=

# Assembler Flags
ASFLAGS=

# Link Libraries and Options
LDLIBSOPTIONS=

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-${CND_CONF}.mk ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited

${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited: ${OBJECTFILES}
	${MKDIR} -p ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}
	${LINK.cc} -o ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited ${OBJECTFILES} ${LDLIBSOPTIONS} -lX11 -lGL -lGLU -lSDL2 -lGLEW -ltinyxml2

${OBJECTDIR}/_ext/d8db8d98/BaseUnits.o: ../../Source/Geist/BaseUnits.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/BaseUnits.o ../../Source/Geist/BaseUnits.cpp

${OBJECTDIR}/_ext/d8db8d98/Config.o: ../../Source/Geist/Config.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Config.o ../../Source/Geist/Config.cpp

${OBJECTDIR}/_ext/d8db8d98/Display.o: ../../Source/Geist/Display.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Display.o ../../Source/Geist/Display.cpp

${OBJECTDIR}/_ext/d8db8d98/Engine.o: ../../Source/Geist/Engine.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Engine.o ../../Source/Geist/Engine.cpp

${OBJECTDIR}/_ext/d8db8d98/Font.o: ../../Source/Geist/Font.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Font.o ../../Source/Geist/Font.cpp

${OBJECTDIR}/_ext/d8db8d98/GUIElements.o: ../../Source/Geist/GUIElements.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/GUIElements.o ../../Source/Geist/GUIElements.cpp

${OBJECTDIR}/_ext/d8db8d98/Globals.o: ../../Source/Geist/Globals.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Globals.o ../../Source/Geist/Globals.cpp

${OBJECTDIR}/_ext/d8db8d98/Gui.o: ../../Source/Geist/Gui.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Gui.o ../../Source/Geist/Gui.cpp

${OBJECTDIR}/_ext/d8db8d98/IO.o: ../../Source/Geist/IO.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/IO.o ../../Source/Geist/IO.cpp

${OBJECTDIR}/_ext/d8db8d98/Input.o: ../../Source/Geist/Input.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Input.o ../../Source/Geist/Input.cpp

${OBJECTDIR}/_ext/d8db8d98/Logging.o: ../../Source/Geist/Logging.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Logging.o ../../Source/Geist/Logging.cpp

${OBJECTDIR}/_ext/d8db8d98/MemoryManager.o: ../../Source/Geist/MemoryManager.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/MemoryManager.o ../../Source/Geist/MemoryManager.cpp

${OBJECTDIR}/_ext/d8db8d98/ParticleSystem.o: ../../Source/Geist/ParticleSystem.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/ParticleSystem.o ../../Source/Geist/ParticleSystem.cpp

${OBJECTDIR}/_ext/d8db8d98/Primitives.o: ../../Source/Geist/Primitives.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Primitives.o ../../Source/Geist/Primitives.cpp

${OBJECTDIR}/_ext/d8db8d98/RNG.o: ../../Source/Geist/RNG.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/RNG.o ../../Source/Geist/RNG.cpp

${OBJECTDIR}/_ext/d8db8d98/ResourceManager.o: ../../Source/Geist/ResourceManager.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/ResourceManager.o ../../Source/Geist/ResourceManager.cpp

${OBJECTDIR}/_ext/d8db8d98/Sound.o: ../../Source/Geist/Sound.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Sound.o ../../Source/Geist/Sound.cpp

${OBJECTDIR}/_ext/d8db8d98/StateMachine.o: ../../Source/Geist/StateMachine.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/StateMachine.o ../../Source/Geist/StateMachine.cpp

${OBJECTDIR}/_ext/d8db8d98/TooltipSystem.o: ../../Source/Geist/TooltipSystem.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/TooltipSystem.o ../../Source/Geist/TooltipSystem.cpp

${OBJECTDIR}/_ext/957bd1db/LoadingState.o: ../../Source/LoadingState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/LoadingState.o ../../Source/LoadingState.cpp

${OBJECTDIR}/_ext/957bd1db/Main.o: ../../Source/Main.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Main.o ../../Source/Main.cpp

${OBJECTDIR}/_ext/957bd1db/MainState.o: ../../Source/MainState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/MainState.o ../../Source/MainState.cpp

${OBJECTDIR}/_ext/957bd1db/ObjectEditorState.o: ../../Source/ObjectEditorState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/ObjectEditorState.o ../../Source/ObjectEditorState.cpp

${OBJECTDIR}/_ext/957bd1db/OptionsState.o: ../../Source/OptionsState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/OptionsState.o ../../Source/OptionsState.cpp

${OBJECTDIR}/_ext/957bd1db/ShapeData.o: ../../Source/ShapeData.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/ShapeData.o ../../Source/ShapeData.cpp

${OBJECTDIR}/_ext/957bd1db/Terrain.o: ../../Source/Terrain.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Terrain.o ../../Source/Terrain.cpp

${OBJECTDIR}/_ext/957bd1db/TitleState.o: ../../Source/TitleState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/TitleState.o ../../Source/TitleState.cpp

${OBJECTDIR}/_ext/957bd1db/U7Globals.o: ../../Source/U7Globals.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/U7Globals.o ../../Source/U7Globals.cpp

${OBJECTDIR}/_ext/957bd1db/U7Object.o: ../../Source/U7Object.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/U7Object.o ../../Source/U7Object.cpp

${OBJECTDIR}/_ext/957bd1db/WorldEditorState.o: ../../Source/WorldEditorState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/WorldEditorState.o ../../Source/WorldEditorState.cpp

${OBJECTDIR}/_ext/ffca3baf/soloud_monotone.o: ../../ThirdParty/soloud/src/audiosource/monotone/soloud_monotone.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/ffca3baf
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/ffca3baf/soloud_monotone.o ../../ThirdParty/soloud/src/audiosource/monotone/soloud_monotone.cpp

${OBJECTDIR}/_ext/16f4a480/soloud_noise.o: ../../ThirdParty/soloud/src/audiosource/noise/soloud_noise.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/16f4a480
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/16f4a480/soloud_noise.o ../../ThirdParty/soloud/src/audiosource/noise/soloud_noise.cpp

${OBJECTDIR}/_ext/62be208d/soloud_openmpt.o: ../../ThirdParty/soloud/src/audiosource/openmpt/soloud_openmpt.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/62be208d
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/62be208d/soloud_openmpt.o ../../ThirdParty/soloud/src/audiosource/openmpt/soloud_openmpt.cpp

${OBJECTDIR}/_ext/62be208d/soloud_openmpt_dll.o: ../../ThirdParty/soloud/src/audiosource/openmpt/soloud_openmpt_dll.c
	${MKDIR} -p ${OBJECTDIR}/_ext/62be208d
	${RM} "$@.d"
	$(COMPILE.c) -g -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/62be208d/soloud_openmpt_dll.o ../../ThirdParty/soloud/src/audiosource/openmpt/soloud_openmpt_dll.c

${OBJECTDIR}/_ext/ae2b1267/soloud_sfxr.o: ../../ThirdParty/soloud/src/audiosource/sfxr/soloud_sfxr.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/ae2b1267
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/ae2b1267/soloud_sfxr.o ../../ThirdParty/soloud/src/audiosource/sfxr/soloud_sfxr.cpp

${OBJECTDIR}/_ext/d034383c/darray.o: ../../ThirdParty/soloud/src/audiosource/speech/darray.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d034383c
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d034383c/darray.o ../../ThirdParty/soloud/src/audiosource/speech/darray.cpp

${OBJECTDIR}/_ext/d034383c/klatt.o: ../../ThirdParty/soloud/src/audiosource/speech/klatt.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d034383c
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d034383c/klatt.o ../../ThirdParty/soloud/src/audiosource/speech/klatt.cpp

${OBJECTDIR}/_ext/d034383c/resonator.o: ../../ThirdParty/soloud/src/audiosource/speech/resonator.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d034383c
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d034383c/resonator.o ../../ThirdParty/soloud/src/audiosource/speech/resonator.cpp

${OBJECTDIR}/_ext/d034383c/soloud_speech.o: ../../ThirdParty/soloud/src/audiosource/speech/soloud_speech.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d034383c
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d034383c/soloud_speech.o ../../ThirdParty/soloud/src/audiosource/speech/soloud_speech.cpp

${OBJECTDIR}/_ext/d034383c/tts.o: ../../ThirdParty/soloud/src/audiosource/speech/tts.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d034383c
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d034383c/tts.o ../../ThirdParty/soloud/src/audiosource/speech/tts.cpp

${OBJECTDIR}/_ext/d14dcf35/sid.o: ../../ThirdParty/soloud/src/audiosource/tedsid/sid.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d14dcf35
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d14dcf35/sid.o ../../ThirdParty/soloud/src/audiosource/tedsid/sid.cpp

${OBJECTDIR}/_ext/d14dcf35/soloud_tedsid.o: ../../ThirdParty/soloud/src/audiosource/tedsid/soloud_tedsid.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d14dcf35
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d14dcf35/soloud_tedsid.o ../../ThirdParty/soloud/src/audiosource/tedsid/soloud_tedsid.cpp

${OBJECTDIR}/_ext/d14dcf35/ted.o: ../../ThirdParty/soloud/src/audiosource/tedsid/ted.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d14dcf35
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d14dcf35/ted.o ../../ThirdParty/soloud/src/audiosource/tedsid/ted.cpp

${OBJECTDIR}/_ext/de066f6/soloud_vic.o: ../../ThirdParty/soloud/src/audiosource/vic/soloud_vic.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/de066f6
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/de066f6/soloud_vic.o ../../ThirdParty/soloud/src/audiosource/vic/soloud_vic.cpp

${OBJECTDIR}/_ext/1762e628/soloud_vizsn.o: ../../ThirdParty/soloud/src/audiosource/vizsn/soloud_vizsn.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/1762e628
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/1762e628/soloud_vizsn.o ../../ThirdParty/soloud/src/audiosource/vizsn/soloud_vizsn.cpp

${OBJECTDIR}/_ext/de069d2/dr_impl.o: ../../ThirdParty/soloud/src/audiosource/wav/dr_impl.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/de069d2
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/de069d2/dr_impl.o ../../ThirdParty/soloud/src/audiosource/wav/dr_impl.cpp

${OBJECTDIR}/_ext/de069d2/soloud_wav.o: ../../ThirdParty/soloud/src/audiosource/wav/soloud_wav.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/de069d2
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/de069d2/soloud_wav.o ../../ThirdParty/soloud/src/audiosource/wav/soloud_wav.cpp

${OBJECTDIR}/_ext/de069d2/soloud_wavstream.o: ../../ThirdParty/soloud/src/audiosource/wav/soloud_wavstream.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/de069d2
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/de069d2/soloud_wavstream.o ../../ThirdParty/soloud/src/audiosource/wav/soloud_wavstream.cpp

${OBJECTDIR}/_ext/de069d2/stb_vorbis.o: ../../ThirdParty/soloud/src/audiosource/wav/stb_vorbis.c
	${MKDIR} -p ${OBJECTDIR}/_ext/de069d2
	${RM} "$@.d"
	$(COMPILE.c) -g -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/de069d2/stb_vorbis.o ../../ThirdParty/soloud/src/audiosource/wav/stb_vorbis.c

${OBJECTDIR}/_ext/7dc31a50/soloud_alsa.o: ../../ThirdParty/soloud/src/backend/alsa/soloud_alsa.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/7dc31a50
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/7dc31a50/soloud_alsa.o ../../ThirdParty/soloud/src/backend/alsa/soloud_alsa.cpp

${OBJECTDIR}/_ext/c247ff60/soloud_coreaudio.o: ../../ThirdParty/soloud/src/backend/coreaudio/soloud_coreaudio.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/c247ff60
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/c247ff60/soloud_coreaudio.o ../../ThirdParty/soloud/src/backend/coreaudio/soloud_coreaudio.cpp

${OBJECTDIR}/_ext/7dc70676/soloud_jack.o: ../../ThirdParty/soloud/src/backend/jack/soloud_jack.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/7dc70676
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/7dc70676/soloud_jack.o ../../ThirdParty/soloud/src/backend/jack/soloud_jack.cpp

${OBJECTDIR}/_ext/50e7bda8/soloud_miniaudio.o: ../../ThirdParty/soloud/src/backend/miniaudio/soloud_miniaudio.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/50e7bda8
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/50e7bda8/soloud_miniaudio.o ../../ThirdParty/soloud/src/backend/miniaudio/soloud_miniaudio.cpp

${OBJECTDIR}/_ext/c82ab1f7/soloud_nosound.o: ../../ThirdParty/soloud/src/backend/nosound/soloud_nosound.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/c82ab1f7
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/c82ab1f7/soloud_nosound.o ../../ThirdParty/soloud/src/backend/nosound/soloud_nosound.cpp

${OBJECTDIR}/_ext/7dc9241e/soloud_null.o: ../../ThirdParty/soloud/src/backend/null/soloud_null.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/7dc9241e
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/7dc9241e/soloud_null.o ../../ThirdParty/soloud/src/backend/null/soloud_null.cpp

${OBJECTDIR}/_ext/317bdccc/soloud_openal.o: ../../ThirdParty/soloud/src/backend/openal/soloud_openal.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/317bdccc
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/317bdccc/soloud_openal.o ../../ThirdParty/soloud/src/backend/openal/soloud_openal.cpp

${OBJECTDIR}/_ext/317bdccc/soloud_openal_dll.o: ../../ThirdParty/soloud/src/backend/openal/soloud_openal_dll.c
	${MKDIR} -p ${OBJECTDIR}/_ext/317bdccc
	${RM} "$@.d"
	$(COMPILE.c) -g -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/317bdccc/soloud_openal_dll.o ../../ThirdParty/soloud/src/backend/openal/soloud_openal_dll.c

${OBJECTDIR}/_ext/c2001528/soloud_opensles.o: ../../ThirdParty/soloud/src/backend/opensles/soloud_opensles.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/c2001528
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/c2001528/soloud_opensles.o ../../ThirdParty/soloud/src/backend/opensles/soloud_opensles.cpp

${OBJECTDIR}/_ext/f38aa198/soloud_oss.o: ../../ThirdParty/soloud/src/backend/oss/soloud_oss.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f38aa198
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f38aa198/soloud_oss.o ../../ThirdParty/soloud/src/backend/oss/soloud_oss.cpp

${OBJECTDIR}/_ext/635a53be/soloud_portaudio.o: ../../ThirdParty/soloud/src/backend/portaudio/soloud_portaudio.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/635a53be
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/635a53be/soloud_portaudio.o ../../ThirdParty/soloud/src/backend/portaudio/soloud_portaudio.cpp

${OBJECTDIR}/_ext/635a53be/soloud_portaudio_dll.o: ../../ThirdParty/soloud/src/backend/portaudio/soloud_portaudio_dll.c
	${MKDIR} -p ${OBJECTDIR}/_ext/635a53be
	${RM} "$@.d"
	$(COMPILE.c) -g -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/635a53be/soloud_portaudio_dll.o ../../ThirdParty/soloud/src/backend/portaudio/soloud_portaudio_dll.c

${OBJECTDIR}/_ext/f38aaec4/soloud_sdl1.o: ../../ThirdParty/soloud/src/backend/sdl/soloud_sdl1.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f38aaec4
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f38aaec4/soloud_sdl1.o ../../ThirdParty/soloud/src/backend/sdl/soloud_sdl1.cpp

${OBJECTDIR}/_ext/f38aaec4/soloud_sdl1_dll.o: ../../ThirdParty/soloud/src/backend/sdl/soloud_sdl1_dll.c
	${MKDIR} -p ${OBJECTDIR}/_ext/f38aaec4
	${RM} "$@.d"
	$(COMPILE.c) -g -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f38aaec4/soloud_sdl1_dll.o ../../ThirdParty/soloud/src/backend/sdl/soloud_sdl1_dll.c

${OBJECTDIR}/_ext/f38aaec4/soloud_sdl2.o: ../../ThirdParty/soloud/src/backend/sdl/soloud_sdl2.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f38aaec4
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f38aaec4/soloud_sdl2.o ../../ThirdParty/soloud/src/backend/sdl/soloud_sdl2.cpp

${OBJECTDIR}/_ext/f38aaec4/soloud_sdl2_dll.o: ../../ThirdParty/soloud/src/backend/sdl/soloud_sdl2_dll.c
	${MKDIR} -p ${OBJECTDIR}/_ext/f38aaec4
	${RM} "$@.d"
	$(COMPILE.c) -g -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f38aaec4/soloud_sdl2_dll.o ../../ThirdParty/soloud/src/backend/sdl/soloud_sdl2_dll.c

${OBJECTDIR}/_ext/879a39df/soloud_sdl2_static.o: ../../ThirdParty/soloud/src/backend/sdl2_static/soloud_sdl2_static.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/879a39df
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/879a39df/soloud_sdl2_static.o ../../ThirdParty/soloud/src/backend/sdl2_static/soloud_sdl2_static.cpp

${OBJECTDIR}/_ext/de59b849/soloud_sdl_static.o: ../../ThirdParty/soloud/src/backend/sdl_static/soloud_sdl_static.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/de59b849
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/de59b849/soloud_sdl_static.o ../../ThirdParty/soloud/src/backend/sdl_static/soloud_sdl_static.cpp

${OBJECTDIR}/_ext/3e556f68/soloud_wasapi.o: ../../ThirdParty/soloud/src/backend/wasapi/soloud_wasapi.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/3e556f68
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/3e556f68/soloud_wasapi.o ../../ThirdParty/soloud/src/backend/wasapi/soloud_wasapi.cpp

${OBJECTDIR}/_ext/3bd4c6c5/soloud_winmm.o: ../../ThirdParty/soloud/src/backend/winmm/soloud_winmm.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/3bd4c6c5
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/3bd4c6c5/soloud_winmm.o ../../ThirdParty/soloud/src/backend/winmm/soloud_winmm.cpp

${OBJECTDIR}/_ext/c15c2b9d/soloud_xaudio2.o: ../../ThirdParty/soloud/src/backend/xaudio2/soloud_xaudio2.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/c15c2b9d
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/c15c2b9d/soloud_xaudio2.o ../../ThirdParty/soloud/src/backend/xaudio2/soloud_xaudio2.cpp

${OBJECTDIR}/_ext/b5c86bc2/soloud_c.o: ../../ThirdParty/soloud/src/c_api/soloud_c.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/b5c86bc2
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/b5c86bc2/soloud_c.o ../../ThirdParty/soloud/src/c_api/soloud_c.cpp

${OBJECTDIR}/_ext/9240839b/soloud.o: ../../ThirdParty/soloud/src/core/soloud.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud.o ../../ThirdParty/soloud/src/core/soloud.cpp

${OBJECTDIR}/_ext/9240839b/soloud_audiosource.o: ../../ThirdParty/soloud/src/core/soloud_audiosource.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_audiosource.o ../../ThirdParty/soloud/src/core/soloud_audiosource.cpp

${OBJECTDIR}/_ext/9240839b/soloud_bus.o: ../../ThirdParty/soloud/src/core/soloud_bus.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_bus.o ../../ThirdParty/soloud/src/core/soloud_bus.cpp

${OBJECTDIR}/_ext/9240839b/soloud_core_3d.o: ../../ThirdParty/soloud/src/core/soloud_core_3d.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_core_3d.o ../../ThirdParty/soloud/src/core/soloud_core_3d.cpp

${OBJECTDIR}/_ext/9240839b/soloud_core_basicops.o: ../../ThirdParty/soloud/src/core/soloud_core_basicops.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_core_basicops.o ../../ThirdParty/soloud/src/core/soloud_core_basicops.cpp

${OBJECTDIR}/_ext/9240839b/soloud_core_faderops.o: ../../ThirdParty/soloud/src/core/soloud_core_faderops.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_core_faderops.o ../../ThirdParty/soloud/src/core/soloud_core_faderops.cpp

${OBJECTDIR}/_ext/9240839b/soloud_core_filterops.o: ../../ThirdParty/soloud/src/core/soloud_core_filterops.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_core_filterops.o ../../ThirdParty/soloud/src/core/soloud_core_filterops.cpp

${OBJECTDIR}/_ext/9240839b/soloud_core_getters.o: ../../ThirdParty/soloud/src/core/soloud_core_getters.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_core_getters.o ../../ThirdParty/soloud/src/core/soloud_core_getters.cpp

${OBJECTDIR}/_ext/9240839b/soloud_core_setters.o: ../../ThirdParty/soloud/src/core/soloud_core_setters.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_core_setters.o ../../ThirdParty/soloud/src/core/soloud_core_setters.cpp

${OBJECTDIR}/_ext/9240839b/soloud_core_voicegroup.o: ../../ThirdParty/soloud/src/core/soloud_core_voicegroup.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_core_voicegroup.o ../../ThirdParty/soloud/src/core/soloud_core_voicegroup.cpp

${OBJECTDIR}/_ext/9240839b/soloud_core_voiceops.o: ../../ThirdParty/soloud/src/core/soloud_core_voiceops.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_core_voiceops.o ../../ThirdParty/soloud/src/core/soloud_core_voiceops.cpp

${OBJECTDIR}/_ext/9240839b/soloud_fader.o: ../../ThirdParty/soloud/src/core/soloud_fader.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_fader.o ../../ThirdParty/soloud/src/core/soloud_fader.cpp

${OBJECTDIR}/_ext/9240839b/soloud_fft.o: ../../ThirdParty/soloud/src/core/soloud_fft.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_fft.o ../../ThirdParty/soloud/src/core/soloud_fft.cpp

${OBJECTDIR}/_ext/9240839b/soloud_fft_lut.o: ../../ThirdParty/soloud/src/core/soloud_fft_lut.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_fft_lut.o ../../ThirdParty/soloud/src/core/soloud_fft_lut.cpp

${OBJECTDIR}/_ext/9240839b/soloud_file.o: ../../ThirdParty/soloud/src/core/soloud_file.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_file.o ../../ThirdParty/soloud/src/core/soloud_file.cpp

${OBJECTDIR}/_ext/9240839b/soloud_filter.o: ../../ThirdParty/soloud/src/core/soloud_filter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_filter.o ../../ThirdParty/soloud/src/core/soloud_filter.cpp

${OBJECTDIR}/_ext/9240839b/soloud_misc.o: ../../ThirdParty/soloud/src/core/soloud_misc.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_misc.o ../../ThirdParty/soloud/src/core/soloud_misc.cpp

${OBJECTDIR}/_ext/9240839b/soloud_queue.o: ../../ThirdParty/soloud/src/core/soloud_queue.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_queue.o ../../ThirdParty/soloud/src/core/soloud_queue.cpp

${OBJECTDIR}/_ext/9240839b/soloud_thread.o: ../../ThirdParty/soloud/src/core/soloud_thread.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/9240839b
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/9240839b/soloud_thread.o ../../ThirdParty/soloud/src/core/soloud_thread.cpp

${OBJECTDIR}/_ext/8f59074/soloud_bassboostfilter.o: ../../ThirdParty/soloud/src/filter/soloud_bassboostfilter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/8f59074
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/8f59074/soloud_bassboostfilter.o ../../ThirdParty/soloud/src/filter/soloud_bassboostfilter.cpp

${OBJECTDIR}/_ext/8f59074/soloud_biquadresonantfilter.o: ../../ThirdParty/soloud/src/filter/soloud_biquadresonantfilter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/8f59074
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/8f59074/soloud_biquadresonantfilter.o ../../ThirdParty/soloud/src/filter/soloud_biquadresonantfilter.cpp

${OBJECTDIR}/_ext/8f59074/soloud_dcremovalfilter.o: ../../ThirdParty/soloud/src/filter/soloud_dcremovalfilter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/8f59074
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/8f59074/soloud_dcremovalfilter.o ../../ThirdParty/soloud/src/filter/soloud_dcremovalfilter.cpp

${OBJECTDIR}/_ext/8f59074/soloud_echofilter.o: ../../ThirdParty/soloud/src/filter/soloud_echofilter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/8f59074
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/8f59074/soloud_echofilter.o ../../ThirdParty/soloud/src/filter/soloud_echofilter.cpp

${OBJECTDIR}/_ext/8f59074/soloud_fftfilter.o: ../../ThirdParty/soloud/src/filter/soloud_fftfilter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/8f59074
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/8f59074/soloud_fftfilter.o ../../ThirdParty/soloud/src/filter/soloud_fftfilter.cpp

${OBJECTDIR}/_ext/8f59074/soloud_flangerfilter.o: ../../ThirdParty/soloud/src/filter/soloud_flangerfilter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/8f59074
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/8f59074/soloud_flangerfilter.o ../../ThirdParty/soloud/src/filter/soloud_flangerfilter.cpp

${OBJECTDIR}/_ext/8f59074/soloud_freeverbfilter.o: ../../ThirdParty/soloud/src/filter/soloud_freeverbfilter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/8f59074
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/8f59074/soloud_freeverbfilter.o ../../ThirdParty/soloud/src/filter/soloud_freeverbfilter.cpp

${OBJECTDIR}/_ext/8f59074/soloud_lofifilter.o: ../../ThirdParty/soloud/src/filter/soloud_lofifilter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/8f59074
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/8f59074/soloud_lofifilter.o ../../ThirdParty/soloud/src/filter/soloud_lofifilter.cpp

${OBJECTDIR}/_ext/8f59074/soloud_robotizefilter.o: ../../ThirdParty/soloud/src/filter/soloud_robotizefilter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/8f59074
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/8f59074/soloud_robotizefilter.o ../../ThirdParty/soloud/src/filter/soloud_robotizefilter.cpp

${OBJECTDIR}/_ext/8f59074/soloud_waveshaperfilter.o: ../../ThirdParty/soloud/src/filter/soloud_waveshaperfilter.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/8f59074
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../Source/Geist -I../../ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/8f59074/soloud_waveshaperfilter.o ../../ThirdParty/soloud/src/filter/soloud_waveshaperfilter.cpp

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r ${CND_BUILDDIR}/${CND_CONF}

# Subprojects
.clean-subprojects:

# Enable dependency checking
.dep.inc: .depcheck-impl

include .dep.inc
