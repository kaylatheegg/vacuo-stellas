package vacuostellas

import "core:fmt"
import gl "vendor:OpenGL"
import SDL "vendor:sdl2"

/*
UI TODO:
percentage bar
dials?
better support for text in buttons*/

RGBA :: struct #raw_union {
	using elem: struct #packed {
		a, g, b, r: u8
	},
	rgba: u32,
}

