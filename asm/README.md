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

### Warning About Sprite Table
The Sprite Table currently does not parse whitespace in a flexible manner, nor does escaping. This will be added soon.
