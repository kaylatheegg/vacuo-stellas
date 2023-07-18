package vacuostellas

import SDL "vendor:sdl2"

/*
	design to follow:
		functions should not need to have an initialiser called unless it is a big function like render,
		the initialisation should be handled in the first call to that function (e.g load shader)

	add unit tests


	TODO:
		-Runtime
			Cleanup functions for EVERYTHING
			Add support for stacktraces

		-Render
			Implement OGL renderer for objects (this is gonna be agonising)
		-Objects
			Copy impl from C game engine
		-Entities
			Implement functionality via entity component system

		-Sound
			do this later
		-UI elements
			Port over the C UI element stuff
		-Debug UI via imgui
		-Utils
			See what odin doesnt have and implement our own 

		-TCRF
			Optimisations
			Multithreading
*/

import "core:fmt"
import "core:math/rand"


main :: proc() {
	log("Starting engine!", .INF, "Runtime");
	SDL.Init({.TIMER, .VIDEO, .EVENTS});

	running : bool = true

	initRender()

	for i := 0; i < 100; i+=1 {
		addObject(rand.int_max(800 - 64), rand.int_max(600 - 64), 64, 64, "meow")
	}

	for running {
		event : SDL.Event

		for (SDL.PollEvent(&event)) {
			#partial switch event.type {
				case .QUIT: 
					running = false;
			}
		}

		render()

	}

	return;
}