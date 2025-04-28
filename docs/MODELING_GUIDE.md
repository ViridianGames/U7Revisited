# Ultima VII: Revisited 3D Modeling Guide

## Conventions for modeling

The project uses a right-handed coordinate system with Z axis pointing up.
Ie. X points east, Y points north, and Z points up.

Align any rotating object to the axis around which it would naturally rotate when modeling.
Characters that can turn to face different directions should be modeled around the vertical Z axis, and a rotating wheel standing upright should be modeled around the horizontal X axis.
Model characters initially facing the negative Y axis.

Use meters for the scale, 1.0 in model coordinates is 1 meter.
Assume 1 meter corresponds to 20 horizontal pixels or 10 vertical pixels in the original game art.

## Figuring out the scale

The art is not proportioned realistically, any small interesting object is drawn much larger than it would realistically be so that it will stand out in the bird's eye view perspective.
A good starting point for scaling it is looking at the human characters and assuming they should be about as tall as real-world humans.
Assume people are around 180 cm tall.
Looking at the graphics of humans lying down, they seem to be around 36 pixels tall, which gets us 1 pixel = 5 cm and 1 meter = 20 pixels.

```
                                ████
                              ██    ████
                          ████  ░░      ░░██
                    ██████░░░░  ▓▓░░░░░░  ░░
                  ██░░░░▓▓░░░░░░████████░░░░                              ██
                ██░░░░░░▓▓░░▓▓██        ██████▓▓▓▓████      ██████      ██░░
                ██░░░░▓▓▓▓░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓░░░░░░░░▓▓████░░░░
                ▓▓░░▓▓░░▓▓░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░▓▓        ▓▓▓▓▓▓░░░░
  ██▓▓▓▓████████▓▓░░░░░░░░      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓  ░░    ▓▓▓▓▓▓░░▓▓
████░░░░▓▓░░▓▓▓▓▓▓░░░░░░░░        ▓▓██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░██████
██▓▓░░  ▓▓░░░░▓▓▓▓▓▓░░░░░░░░      ▓▓██▓▓▓▓▓▓████████████
  ▓▓    ░░▓▓░░▓▓▓▓▓▓▓▓  ░░░░      ▓▓░░▓▓▓▓▓▓██▓▓▓▓██      ██████
██▓▓  ░░▓▓░░░░▓▓▓▓▓▓    ░░▓▓      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██▓▓▓▓██▓▓██████████
██▓▓░░░░▓▓░░▓▓▓▓▓▓░░    ░░▓▓    ░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓
████▓▓▓▓▓▓▓▓████  ░░  ░░░░▓▓  ░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██▓▓▓▓▓▓▓▓░░░░
  ████            ░░░░░░▓▓▓▓░░░░████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██▓▓████████████░░░░
                ░░░░░░▓▓▓▓▓▓▓▓████    ██████████████      ████          ░░░░
                ▓▓██░░░░▓▓░░░░▓▓▓▓▓▓██░░░░██                            ██░░
                    ████▓▓░░░░░░░░░░░░░░░░██                              ▓▓
                          ████░░░░░░░░▓▓██
                              ██████████

   | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -|
                  36 pixels: 180 cm (shape 447: wounded man)
```

The world geometry consists of "voxels" that are 8 pixels wide and extend from the ground by 4 pixels.
Assuming these are meant to be cubes, this gets us one vertical pixel being equal to two horizontal ones, and the voxels being 8 * 5 cm = 4 * 10 cm = 40 cm wide along all axes.

```
            ░░░░░░░░░░░░░░░░
            ░░░░░░░░░░░░░░░░▒▒
            ░░░░░░░░░░░░░░░░▒▒▒▒
            ░░░░░░░░░░░░░░░░▒▒▒▒▒▒
            ░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒
            ░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒
            ░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒
            ░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒
              ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▒▒▒▒▒▒
                ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▒▒▒▒
                  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▒▒
                    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░

             | - - - - - - -|- - - -|
8+4 pixels: 40 cm x 40 cm x 40 cm (shape 1016: floor)
```
