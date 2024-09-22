# Ultima VII: Revisited

Welcome to Ultima VII: Revisited, my attempt to write a replacement engine for Ultima VII: The Black Gate.

## Running the Engine

To run this program, you will need to copy the contents of your original DOS ULTIMA7 folder to `/Data/u7`.  This will allow the replacement engine to read in the maps and graphics from the original files.

## Developer Installation Notes (Windows)

- Clone the project into a local folder using whatever git interface you prefer
- Copy the entire contents of your original DOS ULTIMA7 directory to `$(SolutionDir)/Redist/Data/U7`
- Open `./U7Revisited.sln` in Visual Studio (I'm currently using VS 2022)
- To run the Debugger, in the Project Properties for `U7Revisited` make sure the `Working Directory` is set to `$(SolutionDir)/Redist`
- Build the `U7Revisited` project in the solution
- Run the program

## Controls:

- `WASD`:  Move around.
- `Q/E`:  Rotate left and right.
- `Mousewheel`:  Zoom in/Zoom out.
- To teleport to a location, left-click there in the minimap.
- Press `ESC` to exit.

This is an open source project, which means that you can grab the source files from github.com/viridiangames and build it yourself!  You will need both the U7Revisited and the Geist projects to do this.  (Geist is the engine I make all my games on.)  Make sure they are in the same parent directory so you don't have to fix up a lot of paths.

FEEDBACK IS WELCOME BOY HOWDY IS IT WELCOME!  The best way to give feedback is to send it to my email address at anthony.salter@gmail.com and put `Revisited` in the subject line.

Have fun, and Rule Britannia.
