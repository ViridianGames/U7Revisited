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
	${OBJECTDIR}/_ext/957bd1db/Archer.o \
	${OBJECTDIR}/_ext/957bd1db/Arrow.o \
	${OBJECTDIR}/_ext/957bd1db/Barbarian.o \
	${OBJECTDIR}/_ext/957bd1db/Bird.o \
	${OBJECTDIR}/_ext/957bd1db/Client.o \
	${OBJECTDIR}/_ext/957bd1db/ClientLobbyState.o \
	${OBJECTDIR}/_ext/957bd1db/Earthquake.o \
	${OBJECTDIR}/_ext/957bd1db/Flamering.o \
	${OBJECTDIR}/_ext/957bd1db/Flamestrike.o \
	${OBJECTDIR}/_ext/957bd1db/General.o \
	${OBJECTDIR}/_ext/957bd1db/GodPowers.o \
	${OBJECTDIR}/_ext/957bd1db/HealingLight.o \
	${OBJECTDIR}/_ext/957bd1db/Knight.o \
	${OBJECTDIR}/_ext/957bd1db/Lightning.o \
	${OBJECTDIR}/_ext/957bd1db/Main.o \
	${OBJECTDIR}/_ext/957bd1db/MainState.o \
	${OBJECTDIR}/_ext/957bd1db/Meteor.o \
	${OBJECTDIR}/_ext/957bd1db/OptionsState.o \
	${OBJECTDIR}/_ext/957bd1db/PlanitiaGlobals.o \
	${OBJECTDIR}/_ext/957bd1db/PlanitiaUnit.o \
	${OBJECTDIR}/_ext/957bd1db/Player.o \
	${OBJECTDIR}/_ext/957bd1db/Rock.o \
	${OBJECTDIR}/_ext/957bd1db/Server.o \
	${OBJECTDIR}/_ext/957bd1db/ServerLobbyState.o \
	${OBJECTDIR}/_ext/957bd1db/Sheep.o \
	${OBJECTDIR}/_ext/957bd1db/Terrain.o \
	${OBJECTDIR}/_ext/957bd1db/TitleState.o \
	${OBJECTDIR}/_ext/957bd1db/Tornado.o \
	${OBJECTDIR}/_ext/957bd1db/Tree.o \
	${OBJECTDIR}/_ext/957bd1db/Village.o \
	${OBJECTDIR}/_ext/957bd1db/Volcano.o \
	${OBJECTDIR}/_ext/957bd1db/Walker.o \
	${OBJECTDIR}/_ext/957bd1db/Warrior.o


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
LDLIBSOPTIONS=../../../../../Libraries/Framework/Linux/dist/Debug/GNU-Linux/framework.a

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-${CND_CONF}.mk ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/planitia

${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/planitia: ../../../../../Libraries/Framework/Linux/dist/Debug/GNU-Linux/framework.a

${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/planitia: ${OBJECTFILES}
	${MKDIR} -p ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}
	${LINK.cc} -o ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/planitia ${OBJECTFILES} ${LDLIBSOPTIONS} -lX11 -lGL -lGLU -lGLEW -lSDL2 -lSDL2_image -ldl -lpthread

${OBJECTDIR}/_ext/957bd1db/Archer.o: ../../Source/Archer.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Archer.o ../../Source/Archer.cpp

${OBJECTDIR}/_ext/957bd1db/Arrow.o: ../../Source/Arrow.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Arrow.o ../../Source/Arrow.cpp

${OBJECTDIR}/_ext/957bd1db/Barbarian.o: ../../Source/Barbarian.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Barbarian.o ../../Source/Barbarian.cpp

${OBJECTDIR}/_ext/957bd1db/Bird.o: ../../Source/Bird.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Bird.o ../../Source/Bird.cpp

${OBJECTDIR}/_ext/957bd1db/Client.o: ../../Source/Client.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Client.o ../../Source/Client.cpp

${OBJECTDIR}/_ext/957bd1db/ClientLobbyState.o: ../../Source/ClientLobbyState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/ClientLobbyState.o ../../Source/ClientLobbyState.cpp

${OBJECTDIR}/_ext/957bd1db/Earthquake.o: ../../Source/Earthquake.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Earthquake.o ../../Source/Earthquake.cpp

${OBJECTDIR}/_ext/957bd1db/Flamering.o: ../../Source/Flamering.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Flamering.o ../../Source/Flamering.cpp

${OBJECTDIR}/_ext/957bd1db/Flamestrike.o: ../../Source/Flamestrike.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Flamestrike.o ../../Source/Flamestrike.cpp

${OBJECTDIR}/_ext/957bd1db/General.o: ../../Source/General.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/General.o ../../Source/General.cpp

${OBJECTDIR}/_ext/957bd1db/GodPowers.o: ../../Source/GodPowers.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/GodPowers.o ../../Source/GodPowers.cpp

${OBJECTDIR}/_ext/957bd1db/HealingLight.o: ../../Source/HealingLight.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/HealingLight.o ../../Source/HealingLight.cpp

${OBJECTDIR}/_ext/957bd1db/Knight.o: ../../Source/Knight.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Knight.o ../../Source/Knight.cpp

${OBJECTDIR}/_ext/957bd1db/Lightning.o: ../../Source/Lightning.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Lightning.o ../../Source/Lightning.cpp

${OBJECTDIR}/_ext/957bd1db/Main.o: ../../Source/Main.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Main.o ../../Source/Main.cpp

${OBJECTDIR}/_ext/957bd1db/MainState.o: ../../Source/MainState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/MainState.o ../../Source/MainState.cpp

${OBJECTDIR}/_ext/957bd1db/Meteor.o: ../../Source/Meteor.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Meteor.o ../../Source/Meteor.cpp

${OBJECTDIR}/_ext/957bd1db/OptionsState.o: ../../Source/OptionsState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/OptionsState.o ../../Source/OptionsState.cpp

${OBJECTDIR}/_ext/957bd1db/PlanitiaGlobals.o: ../../Source/PlanitiaGlobals.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/PlanitiaGlobals.o ../../Source/PlanitiaGlobals.cpp

${OBJECTDIR}/_ext/957bd1db/PlanitiaUnit.o: ../../Source/PlanitiaUnit.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/PlanitiaUnit.o ../../Source/PlanitiaUnit.cpp

${OBJECTDIR}/_ext/957bd1db/Player.o: ../../Source/Player.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Player.o ../../Source/Player.cpp

${OBJECTDIR}/_ext/957bd1db/Rock.o: ../../Source/Rock.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Rock.o ../../Source/Rock.cpp

${OBJECTDIR}/_ext/957bd1db/Server.o: ../../Source/Server.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Server.o ../../Source/Server.cpp

${OBJECTDIR}/_ext/957bd1db/ServerLobbyState.o: ../../Source/ServerLobbyState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/ServerLobbyState.o ../../Source/ServerLobbyState.cpp

${OBJECTDIR}/_ext/957bd1db/Sheep.o: ../../Source/Sheep.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Sheep.o ../../Source/Sheep.cpp

${OBJECTDIR}/_ext/957bd1db/Terrain.o: ../../Source/Terrain.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Terrain.o ../../Source/Terrain.cpp

${OBJECTDIR}/_ext/957bd1db/TitleState.o: ../../Source/TitleState.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/TitleState.o ../../Source/TitleState.cpp

${OBJECTDIR}/_ext/957bd1db/Tornado.o: ../../Source/Tornado.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Tornado.o ../../Source/Tornado.cpp

${OBJECTDIR}/_ext/957bd1db/Tree.o: ../../Source/Tree.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Tree.o ../../Source/Tree.cpp

${OBJECTDIR}/_ext/957bd1db/Village.o: ../../Source/Village.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Village.o ../../Source/Village.cpp

${OBJECTDIR}/_ext/957bd1db/Volcano.o: ../../Source/Volcano.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Volcano.o ../../Source/Volcano.cpp

${OBJECTDIR}/_ext/957bd1db/Walker.o: ../../Source/Walker.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Walker.o ../../Source/Walker.cpp

${OBJECTDIR}/_ext/957bd1db/Warrior.o: ../../Source/Warrior.cpp
	${MKDIR} -p ${OBJECTDIR}/_ext/957bd1db
	${RM} "$@.d"
	$(COMPILE.cc) -g -DWITH_SDL2_STATIC -D_DEBUG -I/usr/include/SDL2 -I../../../../../Libraries/glm -I../../../../../Libraries/Framework/Source -I../../../../../Libraries/glew/include -I../../../../../Libraries/stb_truetype -I../../../../../Libraries/tinyxml2 -I../../../../../Libraries/steamworks/sdk/public/steam -I../../../../../Libraries/SoLoud/include -I../../Source -std=c++14 -MMD -MP -MF "$@.d" -o ${OBJECTDIR}/_ext/957bd1db/Warrior.o ../../Source/Warrior.cpp

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
