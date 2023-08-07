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
	${OBJECTDIR}/_ext/957bd1db/Main.o \
	${OBJECTDIR}/_ext/957bd1db/MainState.o \
	${OBJECTDIR}/_ext/957bd1db/OptionsState.o \
	${OBJECTDIR}/_ext/957bd1db/Terrain.o \
	${OBJECTDIR}/_ext/957bd1db/TitleState.o \
	${OBJECTDIR}/_ext/957bd1db/U7Globals.o \
	${OBJECTDIR}/_ext/957bd1db/U7Unit.o \
	${OBJECTDIR}/_ext/957bd1db/model3d.o


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
LDLIBSOPTIONS=../../../Geist/Linux/dist/Debug/GNU-Linux/geist.a

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-${CND_CONF}.mk ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited

${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited: ../../../Geist/Linux/dist/Debug/GNU-Linux/geist.a

${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited: ${OBJECTFILES}
	${MKDIR} -p ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}
	${LINK.cc} -o ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/u7revisited ${OBJECTFILES} ${LDLIBSOPTIONS} -lX11 -lGL -lGLU -lSDL2 -lGLEW -ltinyxml2

${OBJECTDIR}/_ext/957bd1db/Main.o: ../../Source/Main.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Main.o ../../Source/Main.cpp

${OBJECTDIR}/_ext/957bd1db/MainState.o: ../../Source/MainState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/MainState.o ../../Source/MainState.cpp

${OBJECTDIR}/_ext/957bd1db/OptionsState.o: ../../Source/OptionsState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/OptionsState.o ../../Source/OptionsState.cpp

${OBJECTDIR}/_ext/957bd1db/Terrain.o: ../../Source/Terrain.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Terrain.o ../../Source/Terrain.cpp

${OBJECTDIR}/_ext/957bd1db/TitleState.o: ../../Source/TitleState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/TitleState.o ../../Source/TitleState.cpp

${OBJECTDIR}/_ext/957bd1db/U7Globals.o: ../../Source/U7Globals.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/U7Globals.o ../../Source/U7Globals.cpp

${OBJECTDIR}/_ext/957bd1db/U7Unit.o: ../../Source/U7Unit.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/U7Unit.o ../../Source/U7Unit.cpp

${OBJECTDIR}/_ext/957bd1db/model3d.o: ../../Source/model3d.cc
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I/usr/include/glm -I/usr/include/GL -I/usr/include/stb -I/usr/include/tinyxml2 -I../../../Geist/Source -I../../../Geist/ThirdParty/soloud/include -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/model3d.o ../../Source/model3d.cc

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
