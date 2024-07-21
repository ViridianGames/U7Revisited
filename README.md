# Ultima VII: Revisited

Welcome to Ultima VII: Revisited, my attempt to write a replacement engine for Ultima VII: The Black Gate.

## Installation and Building the Project Source Code (Windows)

This project is making use of Github submodules, so the easiest way to make sure all the project dependencies are installed is to:

- `git clone --recurse-submodules git@github.com:ViridianGames/U7Revisited.git`
- Copy the entire contents of your original DOS ULTIMA7 directory to `$(SolutionDir)/Resources/Data/U7`
- Open `./U7Revisited.sln` in Visual Studio (I'm currently using VS 2022)
- To run the Debugger, in the Project Properties for `U7Revisited` make sure the `Working Directory` is set to `$(SolutionDir)/Resources`
- Build the `U7Revisited` project in the solution
- Run the program

*More about Git Submodules here - https://git-scm.com/book/en/v2/Git-Tools-Submodules*

### Updating Submodule Dependencies

From time to time, you may wish to update the project submodule(s) during your own local development.

The `git submodule` command will help you with that

- `git submodule update --remote raylib`

## Project Installation and Running the Engine

To run this program, you will need to copy the contents of your original DOS ULTIMA7 folder to `/Data/u7`.  This
will allow the replacement engine to read in the maps and graphics from the original files.

- Locate your Ultima 7 game files (eg. `C:\Program Files (x86)\GOG Galaxy\Games\Ultima 7`)
![Typical GoG U7 folder](./screenshots/install-1.png)

- Copy ALL of these files, folders and subfolders into `./resources/Data/U7` (*hint: look for the `U7.txt` file*)
![Project U7 Data folder](./screenshots/install-2.png)


## Controls:

- `WASD`:  Move around.
- `Q/E`:  Rotate left and right.
- `Mousewheel`:  Zoom in/Zoom out.
- To teleport to a location, left-click there in the minimap.
- Press `ESC` to exit.

This is an open source project, which means that you can grab the source files from github.com/viridiangames and
build it yourself!

**FEEDBACK IS WELCOME BOY HOWDY IS IT WELCOME!** 

The best way to give feedback is to send it to my email address anthony.salter@gmail.com and put `Revisited` in
the subject line.

Have fun, and Rule Britannia.
