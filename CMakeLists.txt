cmake_minimum_required(VERSION 3.24...3.30)
project(u7revisited)

include(FetchContent)
include_directories(include)

# Generate compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 23)

# Dependencies
set(RAYLIB_VERSION 5.5)

#FetchContent_Declare(
#    raylib
#    DOWNLOAD_EXTRACT_TIMESTAMP OFF
#    URL https://github.com/raysan5/raylib/archive/refs/tags/${RAYLIB_VERSION}.tar.gz
#    FIND_PACKAGE_ARGS
#)

#FetchContent_MakeAvailable(raylib)
set(CMAKE_CXX_FLAGS_DEBUG_INIT "-Wall")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-Wall")
#set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_BUILD_TYPE Release)

# Our Project
add_executable(${PROJECT_NAME})
add_subdirectory(Source)

set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${PROJECT_NAME})

#set_property(TARGET ${PROJECT_NAME} PROPERTY VS_DEBUGGER_WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROJECT_NAME}>)

if ("${PLATFORM}" STREQUAL "Web")
    add_custom_command(
        TARGET ${PROJECT_NAME} PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/resources $<TARGET_FILE_DIR:${PROJECT_NAME}>/../resources
    )
    #DEPENDS ${PROJECT_NAME}
else()
    add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/resources $<TARGET_FILE_DIR:${PROJECT_NAME}>/resources
    )
    #DEPENDS ${PROJECT_NAME}
endif()

#set(raylib_VERBOSE 1)
#target_link_libraries(${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/glfw.lib)
target_link_libraries(${PROJECT_NAME} Winmm.lib)
target_link_libraries(${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/raylib.lib)
#target_link_libraries(${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/r3d.lib)
#target_link_libraries(${PROJECT_NAME} ${CMAKE_SOURCE_DIR}/lib/reactphysics3d.lib)

# Web Configurations
if ("${PLATFORM}" STREQUAL "Web")
    # Tell Emscripten to build an example.html file.
    set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX ".html")
    target_link_options(${PROJECT_NAME} PUBLIC -sUSE_GLFW=3 PUBLIC --preload-file resources)
endif()

# Checks if OSX and links appropriate frameworks (Only required on MacOS)
if (APPLE)
    target_link_libraries(${PROJECT_NAME} "-framework IOKit")
    target_link_libraries(${PROJECT_NAME} "-framework Cocoa")
    target_link_libraries(${PROJECT_NAME} "-framework OpenGL")
endif()
