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
	${OBJECTDIR}/_ext/f512b6a4/BaseUnits.o \
	${OBJECTDIR}/_ext/f512b6a4/Config.o \
	${OBJECTDIR}/_ext/f512b6a4/Engine.o \
	${OBJECTDIR}/_ext/f512b6a4/GUIElements.o \
	${OBJECTDIR}/_ext/f512b6a4/Globals.o \
	${OBJECTDIR}/_ext/f512b6a4/Gui.o \
	${OBJECTDIR}/_ext/f512b6a4/IO.o \
	${OBJECTDIR}/_ext/f512b6a4/Logging.o \
	${OBJECTDIR}/_ext/f512b6a4/ParticleSystem.o \
	${OBJECTDIR}/_ext/f512b6a4/Primitives.o \
	${OBJECTDIR}/_ext/f512b6a4/RNG.o \
	${OBJECTDIR}/_ext/f512b6a4/ResourceManager.o \
	${OBJECTDIR}/_ext/f512b6a4/StateMachine.o \
	${OBJECTDIR}/_ext/f512b6a4/TooltipSystem.o \
	${OBJECTDIR}/_ext/5059b3e7/LoadingState.o \
	${OBJECTDIR}/_ext/5059b3e7/Main.o \
	${OBJECTDIR}/_ext/5059b3e7/MainState.o \
	${OBJECTDIR}/_ext/5059b3e7/ObjectEditorState.o \
	${OBJECTDIR}/_ext/5059b3e7/OptionsState.o \
	${OBJECTDIR}/_ext/5059b3e7/ShapeData.o \
	${OBJECTDIR}/_ext/5059b3e7/ShapeEditorState.o \
	${OBJECTDIR}/_ext/5059b3e7/Terrain.o \
	${OBJECTDIR}/_ext/5059b3e7/TitleState.o \
	${OBJECTDIR}/_ext/5059b3e7/U7Globals.o \
	${OBJECTDIR}/_ext/5059b3e7/U7Object.o \
	${OBJECTDIR}/_ext/5059b3e7/WorldEditorState.o


# C Compiler Flags
CFLAGS=

# CC Compiler Flags
CCFLAGS=
CXXFLAGS=

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
	${LINK.cc} -o ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited ${OBJECTFILES} ${LDLIBSOPTIONS}

${OBJECTDIR}/_ext/f512b6a4/BaseUnits.o: ../../game/src/Geist/BaseUnits.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/BaseUnits.o ../../game/src/Geist/BaseUnits.cpp

${OBJECTDIR}/_ext/f512b6a4/Config.o: ../../game/src/Geist/Config.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/Config.o ../../game/src/Geist/Config.cpp

${OBJECTDIR}/_ext/f512b6a4/Engine.o: ../../game/src/Geist/Engine.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/Engine.o ../../game/src/Geist/Engine.cpp

${OBJECTDIR}/_ext/f512b6a4/GUIElements.o: ../../game/src/Geist/GUIElements.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/GUIElements.o ../../game/src/Geist/GUIElements.cpp

${OBJECTDIR}/_ext/f512b6a4/Globals.o: ../../game/src/Geist/Globals.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/Globals.o ../../game/src/Geist/Globals.cpp

${OBJECTDIR}/_ext/f512b6a4/Gui.o: ../../game/src/Geist/Gui.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/Gui.o ../../game/src/Geist/Gui.cpp

${OBJECTDIR}/_ext/f512b6a4/IO.o: ../../game/src/Geist/IO.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/IO.o ../../game/src/Geist/IO.cpp

${OBJECTDIR}/_ext/f512b6a4/Logging.o: ../../game/src/Geist/Logging.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/Logging.o ../../game/src/Geist/Logging.cpp

${OBJECTDIR}/_ext/f512b6a4/ParticleSystem.o: ../../game/src/Geist/ParticleSystem.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/ParticleSystem.o ../../game/src/Geist/ParticleSystem.cpp

${OBJECTDIR}/_ext/f512b6a4/Primitives.o: ../../game/src/Geist/Primitives.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/Primitives.o ../../game/src/Geist/Primitives.cpp

${OBJECTDIR}/_ext/f512b6a4/RNG.o: ../../game/src/Geist/RNG.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/RNG.o ../../game/src/Geist/RNG.cpp

${OBJECTDIR}/_ext/f512b6a4/ResourceManager.o: ../../game/src/Geist/ResourceManager.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/ResourceManager.o ../../game/src/Geist/ResourceManager.cpp

${OBJECTDIR}/_ext/f512b6a4/StateMachine.o: ../../game/src/Geist/StateMachine.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/StateMachine.o ../../game/src/Geist/StateMachine.cpp

${OBJECTDIR}/_ext/f512b6a4/TooltipSystem.o: ../../game/src/Geist/TooltipSystem.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/f512b6a4
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/f512b6a4/TooltipSystem.o ../../game/src/Geist/TooltipSystem.cpp

${OBJECTDIR}/_ext/5059b3e7/LoadingState.o: ../../game/src/LoadingState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/LoadingState.o ../../game/src/LoadingState.cpp

${OBJECTDIR}/_ext/5059b3e7/Main.o: ../../game/src/Main.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/Main.o ../../game/src/Main.cpp

${OBJECTDIR}/_ext/5059b3e7/MainState.o: ../../game/src/MainState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/MainState.o ../../game/src/MainState.cpp

${OBJECTDIR}/_ext/5059b3e7/ObjectEditorState.o: ../../game/src/ObjectEditorState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/ObjectEditorState.o ../../game/src/ObjectEditorState.cpp

${OBJECTDIR}/_ext/5059b3e7/OptionsState.o: ../../game/src/OptionsState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/OptionsState.o ../../game/src/OptionsState.cpp

${OBJECTDIR}/_ext/5059b3e7/ShapeData.o: ../../game/src/ShapeData.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/ShapeData.o ../../game/src/ShapeData.cpp

${OBJECTDIR}/_ext/5059b3e7/ShapeEditorState.o: ../../game/src/ShapeEditorState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/ShapeEditorState.o ../../game/src/ShapeEditorState.cpp

${OBJECTDIR}/_ext/5059b3e7/Terrain.o: ../../game/src/Terrain.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/Terrain.o ../../game/src/Terrain.cpp

${OBJECTDIR}/_ext/5059b3e7/TitleState.o: ../../game/src/TitleState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/TitleState.o ../../game/src/TitleState.cpp

${OBJECTDIR}/_ext/5059b3e7/U7Globals.o: ../../game/src/U7Globals.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/U7Globals.o ../../game/src/U7Globals.cpp

${OBJECTDIR}/_ext/5059b3e7/U7Object.o: ../../game/src/U7Object.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/U7Object.o ../../game/src/U7Object.cpp

${OBJECTDIR}/_ext/5059b3e7/WorldEditorState.o: ../../game/src/WorldEditorState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/5059b3e7
	${RM} "$@.d"
	$(COMPILE.cc) -O2 -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/5059b3e7/WorldEditorState.o ../../game/src/WorldEditorState.cpp

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
