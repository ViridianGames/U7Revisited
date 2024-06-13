# Extras
Optinal things to help with proejcts

## app_cpp
A simple C++ example for raylib, if you want to start with C++, simply replace the contents of the game folder with the contents of app_cpp

# example_library
A simple example of a user library. Has a header and a source file and a premake script that will build a static library. copy and rename the folder into the root with the name of your library and give it the code it needs.
Link your game to the library with the link_to("LIB_FOLDER_NAME") function in the premake5.lua script for the game.