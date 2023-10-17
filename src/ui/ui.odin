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

button :: struct {
	ui_info: ^ui_element,
	callback: proc(^button),

	button_type: button_type, //kinda ugly
	button_colours: [4]RGBA,
	txinfo: vs_recti32,
}

ui_element :: struct {
	bb: vs_rectf32,
	name: string
	data_type: typeid,
	data: rawptr,
}

createUiElement :: proc(bb: vs_rectf32, name: string, data_type: typeid, data: rawptr) -> ^ui_element {
	data_alloc := new(type_of(data))
	data_alloc^ = cast(type_of(data))data	
}