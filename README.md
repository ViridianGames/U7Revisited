# Raylib Setup using Premake5
This is a simplified set of instructions for how to setup a project using premake.

## Video Tutorial
A video covering this process is here
https://youtu.be/--gI9083QnU

# Download this repository
Download the game premake repository from 
https://github.com/raylib-extras/game-premake/
You can either download the zip file, or clone the repository.
If you clone the repository, you may want to remove the stored history. Simply delete the .git directory to do this.

Rename the directory whatever you want. This will be the name of your game.

# (Optional) Get Raylib
If you wish to use a specific version of raylib, follow the instructions below. If you want the current development version, skip this section and premake will download raylib for you.

## Download Raylib
Get the raylib sources from 
https://github.com/raysan5/raylib
Download the zip file, or clone the repository. It doesn't matter what one you use.
Put the raylib sources in a folder called raylib inside your game folder (The same folder this file is in). The folder must be named raylib, it can not be raylib-master. The raylib folder should contain all the sources from raylib (including the 'src' folder)

# Example app
This repository is pre-populated wit the raylib game template. It is a great starting point for your game.
https://github.com/raysan5/raylib-game-template

If you want to have a different starting point, simply replace the files in the game folder with your own files.

## Using C++
By default this process is setup to build a project using C. If you want to use C++, you can replace your files with you own cpp files. There is is a simple C++ file in the extras/app_cpp dir. The raylib template is designed for C, not C++, but the version in this repository has been modified to work as C++ if you choose to rename the files.

# Generate Projects
For windows users, there are two batch files you can use depending on what compiler you are using. For linux users you can simply use a terminal.
Only do ONE of these options depending on your compiler and platform.
## Windows Users
Visual Studio users should run

    premake-VisualStudio.bat
	
This will generate a Visual Studio project.
	
## MinGW-w64 Users
Please make sure you have a recent version of MinGW-W64. The older versons from mingw.org will not work.
We recomend the W64Devkit. It has everything needed to build raylib. It can be downloaded from here https://github.com/skeeto/w64devkit/releases

Once you have MinGW-W64
Run the batch file.

    premake-mingw.bat

This will generate a makefile for you
	
## Linux users
cd to the root folder and run

    ./premake5 gmake2

This will generate a makefile for you.

## macOS users
cd to the root folder and run

    ./premake5.osx gmake2
	
This will generate a makefile for you.

# Build your game
Only do ONE of these options depending on your compiler and platform.
## Windows Users
Double click the .sln file that was generated in the folder. From here you can use the project as normal.
	
## MinGW-w64 Users
Open your compiler terminal (w64devkit if you are using it), change to the game folder and type 

    make
	
This will build your game
	
## Linux/macOS users
Open your terminal, change to the root folder and type.

    make
	
This will build your starting game template
	
	
# Building for other OpenGL targets
If you need to build for a different OpenGL version than the default (OpenGL 3.3) you can specify an openGL version in your premake command line. Just modify the bat file or add the following to your command line

## For OpenGL 1.1
--graphics=opengl11

## For OpenGL 2.1
--graphics=opengl21

## For OpenGL 4.3
--graphics=opengl43

# Building extra libs
If you need to add a separate library to your game you can do that very easily.
Simply copy the extras/example_library folder and rename it to what you want your lib to be called.
Replace lib.c with the sources for your library (just copy them in the folder).
If you library has an include folder, copy that too.
Then go to the premake5.lua file in the game folder, and link your library by calling link_to with the folder name for the library.

link_to("LIB_FOLDER_NAME")

Rerun premake and it will build your library for you.
Note that by default link_to will add include dirs for your library folder and library/include. If you have other include needs you will have to add those to your premake file manually.

# License
Copyright (c) 2020-2024 Jeffery Myers

This software is provided "as-is", without any express or implied warranty. In no event 
will the authors be held liable for any damages arising from the use of this software.

Permission is granted to anyone to use this software for any purpose, including commercial 
applications, and to alter it and redistribute it freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not claim that you 
  wrote the original software. If you use this software in a product, an acknowledgment 
  in the product documentation would be appreciated but is not required.

  2. Altered source versions must be plainly marked as such, and must not be misrepresented
  as being the original software.

  3. This notice may not be removed or altered from any source distribution.
