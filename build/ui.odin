package vacuostellas

import "core:fmt"
import gl "vendor:OpenGL"
import SDL "vendor:sdl2"

/*
UI TODO:
percentage bar
dials?
any support for text in buttons*/

RGBA :: struct #raw_union {
	using elem: struct #packed {
		a, g, b, r: u8
	},
	rgba: u32,
}

ui_element :: struct {
	bb: vs_rectf32,
	name: string,
	data_type: typeid,
	data: rawptr,
}

createUiElement :: proc(bb: vs_rectf32, name: string, data_type: typeid, data: $T) -> ^ui_element {
	data_alloc := new(type_of(data))
	data_alloc^ = cast(type_of(data))data
	if resGetResourceIndex(ui_element) == -1 {
		addResource(ui_element)
	}
	int_element : ui_element = (ui_element){bb, name, data_type, data_alloc}
	element_id := resAddElement(ui_element, name, int_element)
	return resGetElementPointerByID(ui_element, element_id)
}