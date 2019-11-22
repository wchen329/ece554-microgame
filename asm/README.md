# Assembler

## General usage (Linux):
To build, just use make:
### `make`
Then, go launch the assembler *mgassemble*. In order to so an input file, through -i [filename] must be provided.
For example, to assemble, *file.s*, one could use the following command:
### `./mgassemble -i file.s`
Some other useful options include...
#### -g [sprite table file]: use the sprite table given
#### -f [mif or hexlist or bin]: assemble into either mif, hexlist, or binary file types
#### -o [output file name]: by default, this will output a.mif / a.hl / a.bin. Use this to specify a custom output name

An example of the layout of all instructions are int the tests folder (more details to arrive).

### Sprite Table Format
The Sprite Table is simply a list of associative pairs of Sprite Name and the Filename of that Sprite, with one pair per line:

`SPRITE_NAME: "filename.sprite"`

The filename is either an absolute path or a path relative to the sprite table with backslashes used to delineate between directories.

The Sprite name given (here `SPRITE_NAME`) is not important except for the fact that it can be used for load sprite
operations in programs. So for a sprite of sprite name `SPRITE_NAME`:

`
...
ls %1, 0, SPRITE_NAME
...
`

Would load the sprite of sprite name `SPRITE_NAME` into sprite register 1.
