
# Ultima VII: Revisited

Welcome to Ultima VII: Revisited, my attempt to write a replacement engine for Ultima VII: The Black Gate.

<a href="https://www.youtube.com/watch?v=2mbJcOEwKJ4">
  <img width="1280" height="720" alt="image" src="https://github.com/user-attachments/assets/c85f4858-9468-4a19-8698-f62361a0df4a" />
</a>
(Click for a preview of coming attractions.)

## Installation and Running the Engine

To run this program, you will need to copy the contents of your original DOS ULTIMA7 folder to `/Data/u7`.  This
will allow the replacement engine to read in the maps and graphics from the original files.

- Locate your Ultima 7 game files (eg. `C:\Program Files (x86)\GOG Galaxy\Games\Ultima 7`)
![Typical GoG U7 folder](./screenshots/install-1.png)

- Copy ALL of these files, folders and subfolders into `./Data/U7` (*hint: look for the `U7.txt` file*)
![Project U7 Data folder](./screenshots/install-2.png)


## Developer Installation Notes

- Clone the project into a local folder using whatever git interface you prefer
- Copy the entire contents of your original DOS ULTIMA7 directory to `$(SolutionDir)/Redist/Data/U7/`

### Building with Meson (Cross-platform)

- Make sure you have the [Meson Build system](https://mesonbuild.com/) installed
- Run `meson setup build`, or if you want to generate a Visual Studio project, `meson setup --backend vs build`
- Run `meson compile -C build` to build the project
- Go to `build/` directory and run the `u7revisited` program

### Building with CMake (Windows & Linux)

**Windows:**
1. Install CMake (3.15 or higher) - Visual Studio 2019+ includes CMake support that you can install via the Visual Studio Installer. See [CMake projects in Visual Studio](https://learn.microsoft.com/en-us/cpp/build/cmake-projects-in-visual-studio?view=msvc-170) for details.
2. You MUST open "Developer Command Prompt for VS 2019" to get a console with cmake on your path! A normal Powershell or cmd.exe will not work!
3. CD to the project folder, and configure and generate build files:
    ```bash
      cd U7Revisted
      cmake -S . -B build
    ```
4. Open the new solution file in Visual Studio 2019+: `build/U7Revisited.sln`
5. Build the project using Visual Studio (Ctrl+Shift+B or Build → Build Solution) or F5 to build & debug
6. The Release executable will be automatically copied to `Redist/u7revisited.exe` after building

**Linux:**
1. Install CMake and required dependencies:
   ```bash
   sudo apt-get install cmake build-essential libgl1-mesa-dev libx11-dev libxrandr-dev libxi-dev libxcursor-dev libxinerama-dev
   ```
2. Configure and generate build files: `cmake -S . -B build -DCMAKE_BUILD_TYPE=Release`
3. Build the project: `cmake --build build -j$(nproc)`
4. The Release executable will be automatically copied to `Redist/u7revisited` after building

## Controls:

- `WASD`:  Move around.
- `Q/E`:  Rotate left and right.
- `Mousewheel`:  Zoom in/Zoom out.
- To teleport to a location, left-click there in the minimap.
- Double-left-click on an NPC to attempt to talk to them (not all NPCs work yet)
- Double-right-click on a container to open it and view its contents (NPCs are considered containers)
- Press +/- on the keypad to slow down/speed up time.  Press Enter on the keypad to advance time one hour.
- Press `ESC` to exit.

This is an open source project, which means that you can grab the source files from github.com/viridiangames and
build it yourself!

## Sandbox Mode

Sandbox is the "debug" mode and has extra options available for building and testing the world. You can make changes and save them to work on the game from inside the game!  The red square in the upper left corner toggles NPC pathfinding.

- LMB - Clicking on objects, NPCs or floor prints debug info
- LDBL - Left double clicking calls Interact() on objects/NPCs
- F1 Toggles the Shape Editor Tool
- F7 Toggles black outline borders and dragging of static objects
- F9 Toggles debug bounding boxes
- F10 Toggles pathfind costs shown by coloring tiles
- F11 Toggles green highlights for scripted objects
- -> Right arrow skips ahead time to the next hour

**FEEDBACK IS WELCOME BOY HOWDY IS IT WELCOME!**

The best way to give feedback is to send it to my email address anthony.salter@gmail.com and put `Revisited` in
the subject line.

Have fun, and Rule Britannia.
