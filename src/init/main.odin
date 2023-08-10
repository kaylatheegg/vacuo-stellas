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
			change the vertices to internally use vec2s
			
		-Objects
			restitching the atlas could corrupt old object vertex texcoords. fix this

		-Entities
			Implement functionality via entity component system

		-Sound
			do this later
		-UI elements
			Port over the C UI element stuff
			redo text rendering to use a baked stb text atlas
			add a system to allow more than one font at a time

		-Debug UI via imgui
		-Utils
			See what odin doesnt have and implement our own 

		-TCRF
			Optimisations
			Multithreading
*/

import "core:fmt"
import "core:math/rand"
import "core:math"

testEntityProc :: proc(this: ^entity, data: rawptr) {
	(cast(^f32)data)^ += 0.01/3.14159
	this.object.angle = (cast(^f32)data)^
	objUpdate(this.object)
}

main :: proc() {
	log("Starting engine!", .INF, "Runtime");
	SDL.Init({.TIMER, .VIDEO, .EVENTS});

	running : bool = true

	initRender()

	registerTexture("data/images/sand.png", "sand")
	registerTexture("data/images/player.png", "sand1")
	registerTexture("data/images/water.png", "sand2")
	registerTexture("data/images/wall.png", "sand3")
	registerTexture("data/images/pistol.png", "sand4")

	initText()

	for i := 0; i < 100; i+=1 {
		createBall((vec2f){vfuRand(0, 800), vfuRand(0, 600)})
	}

	addEntity(400., 400., 64., 64., 0., "meow", "sand3", testEntityProc, 0)


	for running {
		event : SDL.Event

		for (SDL.PollEvent(&event)) {
			#partial switch event.type {
				case .QUIT: 
					running = false;
			}
		}
		
		tickEntities()
		render()

		SDL.Delay(17)
	}

	free_all()
	return;
}