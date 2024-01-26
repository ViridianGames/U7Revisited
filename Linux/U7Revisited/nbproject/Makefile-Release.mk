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
CND_CONF=Release
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
	${OBJECTDIR}/_ext/957bd1db/OptionsState.o \
	${OBJECTDIR}/_ext/957bd1db/Terrain.o \
	${OBJECTDIR}/_ext/957bd1db/TitleState.o \
	${OBJECTDIR}/_ext/957bd1db/U7Globals.o \
	${OBJECTDIR}/_ext/957bd1db/U7Object.o


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
LDLIBSOPTIONS=../../../Geist/Linux/dist/Release/GNU-Linux/geist.a

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-${CND_CONF}.mk ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited

${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited: ../../../Geist/Linux/dist/Release/GNU-Linux/geist.a

${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited: ${OBJECTFILES}
	${MKDIR} -p ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}
	${LINK.cc} -o ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited ${OBJECTFILES} ${LDLIBSOPTIONS} -lX11 -lGL -lGLU -lSDL2 -lGLEW -ltinyxml2

${OBJECTDIR}/_ext/d8db8d98/BaseUnits.o: ../../Source/Geist/BaseUnits.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/BaseUnits.o ../../Source/Geist/BaseUnits.cpp

${OBJECTDIR}/_ext/d8db8d98/Config.o: ../../Source/Geist/Config.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Config.o ../../Source/Geist/Config.cpp

${OBJECTDIR}/_ext/d8db8d98/Display.o: ../../Source/Geist/Display.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Display.o ../../Source/Geist/Display.cpp

${OBJECTDIR}/_ext/d8db8d98/Engine.o: ../../Source/Geist/Engine.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Engine.o ../../Source/Geist/Engine.cpp

${OBJECTDIR}/_ext/d8db8d98/Font.o: ../../Source/Geist/Font.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Font.o ../../Source/Geist/Font.cpp

${OBJECTDIR}/_ext/d8db8d98/GUIElements.o: ../../Source/Geist/GUIElements.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/GUIElements.o ../../Source/Geist/GUIElements.cpp

${OBJECTDIR}/_ext/d8db8d98/Globals.o: ../../Source/Geist/Globals.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Globals.o ../../Source/Geist/Globals.cpp

${OBJECTDIR}/_ext/d8db8d98/Gui.o: ../../Source/Geist/Gui.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Gui.o ../../Source/Geist/Gui.cpp

${OBJECTDIR}/_ext/d8db8d98/IO.o: ../../Source/Geist/IO.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/IO.o ../../Source/Geist/IO.cpp

${OBJECTDIR}/_ext/d8db8d98/Input.o: ../../Source/Geist/Input.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Input.o ../../Source/Geist/Input.cpp

${OBJECTDIR}/_ext/d8db8d98/Logging.o: ../../Source/Geist/Logging.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Logging.o ../../Source/Geist/Logging.cpp

${OBJECTDIR}/_ext/d8db8d98/MemoryManager.o: ../../Source/Geist/MemoryManager.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/MemoryManager.o ../../Source/Geist/MemoryManager.cpp

${OBJECTDIR}/_ext/d8db8d98/ParticleSystem.o: ../../Source/Geist/ParticleSystem.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/ParticleSystem.o ../../Source/Geist/ParticleSystem.cpp

${OBJECTDIR}/_ext/d8db8d98/Primitives.o: ../../Source/Geist/Primitives.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Primitives.o ../../Source/Geist/Primitives.cpp

${OBJECTDIR}/_ext/d8db8d98/RNG.o: ../../Source/Geist/RNG.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/RNG.o ../../Source/Geist/RNG.cpp

${OBJECTDIR}/_ext/d8db8d98/ResourceManager.o: ../../Source/Geist/ResourceManager.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/ResourceManager.o ../../Source/Geist/ResourceManager.cpp

${OBJECTDIR}/_ext/d8db8d98/Sound.o: ../../Source/Geist/Sound.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/Sound.o ../../Source/Geist/Sound.cpp

${OBJECTDIR}/_ext/d8db8d98/StateMachine.o: ../../Source/Geist/StateMachine.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/StateMachine.o ../../Source/Geist/StateMachine.cpp

${OBJECTDIR}/_ext/d8db8d98/TooltipSystem.o: ../../Source/Geist/TooltipSystem.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/d8db8d98
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/d8db8d98/TooltipSystem.o ../../Source/Geist/TooltipSystem.cpp

${OBJECTDIR}/_ext/957bd1db/LoadingState.o: ../../Source/LoadingState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/LoadingState.o ../../Source/LoadingState.cpp

${OBJECTDIR}/_ext/957bd1db/Main.o: ../../Source/Main.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Main.o ../../Source/Main.cpp

${OBJECTDIR}/_ext/957bd1db/MainState.o: ../../Source/MainState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/MainState.o ../../Source/MainState.cpp

${OBJECTDIR}/_ext/957bd1db/OptionsState.o: ../../Source/OptionsState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/OptionsState.o ../../Source/OptionsState.cpp

${OBJECTDIR}/_ext/957bd1db/Terrain.o: ../../Source/Terrain.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Terrain.o ../../Source/Terrain.cpp

${OBJECTDIR}/_ext/957bd1db/TitleState.o: ../../Source/TitleState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/TitleState.o ../../Source/TitleState.cpp

${OBJECTDIR}/_ext/957bd1db/U7Globals.o: ../../Source/U7Globals.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/U7Globals.o ../../Source/U7Globals.cpp

${OBJECTDIR}/_ext/957bd1db/U7Object.o: ../../Source/U7Object.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -DWITH_SDL2_STATIC -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/U7Object.o ../../Source/U7Object.cpp

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
