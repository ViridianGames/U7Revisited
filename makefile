CC = g++
CFLAGS = -m64 -std=c++17
DEBUG_FLAGS = -g -DDEBUG_MODE
RELEASE_FLAGS = -O2 -DRELEASE_MODE
INCLUDES = -I./Source/Geist -I./ThirdParty/raylib/include -I./ThirdParty/raylib/external -I./ThirdParty/lua/src
LIBS = ./ThirdParty/raylib/lib/libraylib.a ./ThirdParty/lua/src/liblua.a -lGL -lm -lpthread
SOURCES = $(wildcard Source/*.cpp Source/Geist/*.cpp)
DEBUG_OBJECTS = $(patsubst Source/%.cpp, Build/Debug/%.o, $(SOURCES))
RELEASE_OBJECTS = $(patsubst Source/%.cpp, Build/Release/%.o, $(SOURCES))
DEBUG_DEPENDS = $(patsubst Source/%.cpp, Build/Debug/%.d, $(SOURCES))
RELEASE_DEPENDS = $(patsubst Source/%.cpp, Build/Release/%.d, $(SOURCES))
DEBUG_TARGET = Redist/u7revisited_debug
RELEASE_TARGET = Redist/u7revisited
LUA_LIB = ThirdParty/lua/src/liblua.a
RAYLIB_LIB = ThirdParty/raylib/lib/libraylib.a

# Default target
all: debug

# Ensure Build and Redist directories exist
Build/Debug:
	@mkdir -p Build/Debug Build/Debug/Geist

Build/Release:
	@mkdir -p Build/Release Build/Release/Geist

Redist:
	@mkdir -p Redist

# Build liblua.a if needed
$(LUA_LIB):
	$(MAKE) -C ThirdParty/lua/src linux

# Build raylib.a if needed (optional)
$(RAYLIB_LIB):
	$(MAKE) -C ThirdParty/raylib/src

# Debug target
debug: Build/Debug Redist $(LUA_LIB) $(RAYLIB_LIB) $(DEBUG_OBJECTS)
	$(CC) $(DEBUG_FLAGS) $(CFLAGS) $(DEBUG_OBJECTS) -o $(DEBUG_TARGET) $(LIBS)

# Release target
release: Build/Release Redist $(LUA_LIB) $(RAYLIB_LIB) $(RELEASE_OBJECTS)
	$(CC) $(RELEASE_FLAGS) $(CFLAGS) $(RELEASE_OBJECTS) -o $(RELEASE_TARGET) $(LIBS)

# Compile source files to debug object files
Build/Debug/%.o: Source/%.cpp
	$(CC) $(DEBUG_FLAGS) $(CFLAGS) $(INCLUDES) -c $< -o $@ -MD -MP

# Compile source files to release object files
Build/Release/%.o: Source/%.cpp
	$(CC) $(RELEASE_FLAGS) $(CFLAGS) $(INCLUDES) -c $< -o $@ -MD -MP

# Include dependency files
-include $(DEBUG_DEPENDS)
-include $(RELEASE_DEPENDS)

# Clean up
clean:
	rm -rf Build $(DEBUG_TARGET) $(RELEASE_TARGET)

.PHONY: all debug release clean