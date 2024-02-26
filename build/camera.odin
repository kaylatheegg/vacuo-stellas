package vacuostellas

import SDL "vendor:sdl2"
import "core:fmt"
import "core:math"

camera: vec2f
zoom_level: f32 = 1

camera_angle: f32 = 0;

cameraCallback :: proc(this: ^entity, data: rawptr) {
	//speed := 5. * 1./zoom_level
	/*if keyboardState[SDL.Scancode.A] == 1 {
		camera.x -= speed;
	}
	if keyboardState[i32(SDL.Scancode.D)] == 1 {
		camera.x += speed;
	}
	if keyboardState[i32(SDL.Scancode.W)] == 1 {
		camera.y += speed;
	}
	if keyboardState[i32(SDL.Scancode.S)] == 1 {
		camera.y -= speed;
	}
	if keyboardState[i32(SDL.Scancode.O)] == 1 {
		zoom_level += 0.01*zoom_level;
	}
	if keyboardState[i32(SDL.Scancode.P)] == 1 {
		zoom_level -= 0.01*zoom_level;
	}
	if keyboardState[i32(SDL.Scancode.I)] == 1 {
		camera_angle += 2*D2R
	}*/

}