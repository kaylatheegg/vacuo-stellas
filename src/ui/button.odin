package vacuostellas

import "core:fmt"
import gl "vendor:OpenGL"
import SDL "vendor:sdl2"

button_type :: enum {
	FLAT,
	GRADIENT,
	TEXTURE
}

button :: struct {
	ui_info: ^ui_element,
	callback: proc(^button),

	button_type: button_type, //kinda ugly
	button_colours: [4]RGBA,
	txinfo: vs_recti32,
}

buttonWatchdog :: proc(this: ^entity, data: rawptr) {
	if resGetResourceIndex(button) == -1 {
		log("Tried to get the button resource in the BW, this has failed!", .SVR, "UI")
		crash()
	}
	buttons := getResource(button)
	for i:=0; i < len(buttons.elements); i+=1 {
		int_button := (cast(^button)buttons.elements[i].value)^
		x,y : i32
		mouse_state := SDL.GetMouseState(&x, &y)
		if pointInBB(int_button.ui_info.bb, (vec2f){f32(x), f32(y)}) {
			if mouse_state & SDL.BUTTON_LMASK == 1 {
				int_button->callback()
			}
		}
	}
}

createButton :: proc(bb: vs_rectf32, name: string, data: $T, callback: proc(^button), type: button_type, args: ..any) {
	if resGetResourceIndex(button) == -1 {
		addResource(button)
		loadProgram("data/shaders/button.fs", "data/shaders/button.vs", "Button Renderer", buttonRender)
		addEntity(0, 0, 0., 0., 0, "Button Watchdog", "DEFAULT", buttonWatchdog, 0)
	}

	if (type == .FLAT || type == .GRADIENT) && type_of(args[0]) == typeid_of(texture) {
		log("Attempted to create a colour button with a texture! Defaulting to black.", .ERR, "UI")
		args[0] = (RGBA){rgba = 0x000000FF}
	}

	if len(args) > 4 && type == .GRADIENT {
		log("Button gradient can only have 4 colours! Discarding the rest.", .ERR, "UI")
	}

	colours: [4]RGBA

	if type != .TEXTURE {
		for _, i in args {
			if i >= 4 {
				break;
			}
			colours[i] = (cast(^RGBA)args[i].data)^
		}
	}

	#partial switch type {
		case .FLAT:
			resAddElement(button, name, (button){createUiElement(bb, name, type_of(data), data), callback, type, colours, getAtlasEntry("DEFAULT")})
		case .GRADIENT:
			resAddElement(button, name, (button){createUiElement(bb, name, type_of(data), data), callback, type, colours, getAtlasEntry("DEFAULT")})
		case .TEXTURE:
			resAddElement(button, name, (button){createUiElement(bb, name, type_of(data), data), callback, type, colours, getAtlasEntry((cast(^string)args[0].data)^)})
	}
}

