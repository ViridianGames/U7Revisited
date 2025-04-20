CC = g++
CFLAGS = -m64 -std=c++17
DEBUG_FLAGS = -g
RELEASE_FLAGS = -O2
INCLUDES = -I./Source/Geist -I./ThirdParty/raylib/include -I./ThirdParty/raylib/external -I./ThirdParty/lua/src
LIBS = ./ThirdParty/raylib/lib/libraylib.a ./ThirdParty/lua/src/liblua.a -lGL -lm -lpthread
SOURCES = Source/*.cpp Source/Geist/*.cpp
DEBUG_TARGET = Redist/u7revisited_debug
RELEASE_TARGET = Redist/u7revisited
LUA_LIB = ThirdParty/lua/src/liblua.a

all: debug

Redist:
	mkdir -p Redist
	$(LUA_LIB):
		$(MAKE) -C ThirdParty/lua/src linux

debug: Redist $(SOURCES)
	$(CC) $(DEBUG_FLAGS) $(CFLAGS) $(INCLUDES) $(SOURCES) -o $(DEBUG_TARGET) $(LIBS)

release: Redist $(SOURCES)
	$(CC) $(RELEASE_FLAGS) $(CFLAGS) $(INCLUDES) $(SOURCES) -o $(RELEASE_TARGET) $(LIBS)

clean:
	rm -f $(DEBUG_TARGET) $(RELEASE_TARGET)	