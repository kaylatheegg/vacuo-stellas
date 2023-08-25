package vacuostellas

import "core:fmt"
import gl "vendor:OpenGL"


/*
UI TODO:
buttons
percentage bar
dials?
better support for text in buttons*/

button_type :: enum {
	FLAT,
	GRADIENT,
	TEXTURE
}

RGBA :: struct #raw_union {
	using elem: struct #packed {
		a, g, b, r: u8
	},
	rgba: u32,
}

button :: struct {
	bb: vs_rectf32,
	name: string,

	data_type: typeid,
	data: rawptr,
	callback: proc(^button),

	button_type: button_type, //kinda ugly
	button_colours: [4]RGBA,
	txinfo: vs_recti32,
}

createButton :: proc(bb: vs_rectf32, name: string, data: $T, callback: proc(^button), type: button_type, args: ..any) {
	if resGetResourceIndex(button) == -1 {
		addResource(button)
		
	}

	if (type == .FLAT || type == .GRADIENT) && type_of(args[0]) == typeid_of(texture) {
		log("Attempted to create a colour button with a texture! Defaulting to black.", .ERR, "UI")
		args[0] = (RGBA){rgba = 0x000000FF}
	}

	if len(args) > 4 && type == .GRADIENT {
		log("Button gradient can only have 4 colours! Discarding the rest.", .ERR, "UI")
	}

	data_alloc := new(type_of(data))
	data_alloc^ = cast(type_of(data))data	

	colours: [4]RGBA

	if type != .TEXTURE {
		for _, i in args {
			colours[i] = (cast(^RGBA)args[i].data)^
		}
	}

	#partial switch type {
		case .FLAT:
			resAddElement(button, name, (button){bb, name, type_of(data), data_alloc, callback, type, colours, getAtlasEntry("DEFAULT")})
		case .GRADIENT:
			resAddElement(button, name, (button){bb, name, type_of(data), data_alloc, callback, type, colours, getAtlasEntry("DEFAULT")})
		case .TEXTURE:
			resAddElement(button, name, (button){bb, name, type_of(data), data_alloc, callback, type, colours, getAtlasEntry((cast(^string)args[0].data)^)})
	}
}