CC = g++
CFLAGS = -m64 -std=c++17
DEBUG_FLAGS = -g
RELEASE_FLAGS = -O2
INCLUDES = -I./Source/Geist -I./ThirdParty/raylib/include -I./ThirdParty/raylib/external -I./ThirdParty/lua/src
LIBS = ./ThirdParty/raylib/lib/libraylib.a ./ThirdParty/lua/src/liblua.a -lGL -lm -lpthread
SOURCES = $(wildcard Source/*.cpp Source/Geist/*.cpp)
OBJECTS = $(patsubst Source/%.cpp, Build/%.o, $(SOURCES))
DEPENDS = $(patsubst Source/%.cpp, Build/%.d, $(SOURCES))
DEBUG_TARGET = Redist/u7revisited_debug
RELEASE_TARGET = Redist/u7revisited
LUA_LIB = ThirdParty/lua/src/liblua.a
RAYLIB_LIB = ThirdParty/raylib/lib/libraylib.a

# Default target
all: debug

# Ensure Build and Redist directories exist
Build:
	@mkdir -p Build Build/Geist

Redist:
	@mkdir -p Redist

# Build liblua.a if needed
$(LUA_LIB):
	$(MAKE) -C ThirdParty/lua/src linux

# Debug target
debug: Build Redist $(LUA_LIB) $(RAYLIB_LIB) $(OBJECTS)
	$(CC) $(DEBUG_FLAGS) $(CFLAGS) $(OBJECTS) -o $(DEBUG_TARGET) $(LIBS)

# Release target
release: Build Redist $(LUA_LIB) $(RAYLIB_LIB) $(OBJECTS)
	$(CC) $(RELEASE_FLAGS) $(CFLAGS) $(OBJECTS) -o $(RELEASE_TARGET) $(LIBS)

# Compile source files to object files with dependency generation
Build/%.o: Source/%.cpp
	$(CC) $(DEBUG_FLAGS) $(CFLAGS) $(INCLUDES) -c $< -o $@ -MD -MP

# Include dependency files
-include $(DEPENDS)

# Clean up
clean:
	rm -rf Build $(DEBUG_TARGET) $(RELEASE_TARGET)

.PHONY: all debug release clean