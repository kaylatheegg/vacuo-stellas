package vacuostellas

import SDL "vendor:sdl2"
import "core:fmt"


camera: vec2f

cameraCallback :: proc(this: ^entity, data: rawptr) {
	if keyboardState[SDL.Scancode.A] == 1 {
		camera.x -= 5.;
	}
	if keyboardState[i32(SDL.Scancode.D)] == 1 {
		camera.x += 5.;
	}
	if keyboardState[i32(SDL.Scancode.W)] == 1 {
		camera.y += 5.;
	}
	if keyboardState[i32(SDL.Scancode.S)] == 1 {
		camera.y -= 5.;
	}


}