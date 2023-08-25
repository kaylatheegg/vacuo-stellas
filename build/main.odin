package vacuostellas

import SDL "vendor:sdl2"


/*
	design to follow:
		functions should not need to have an initialiser called unless it is a big function like render,
		the initialisation should be handled in the first call to that function (e.g load shader)

	add unit tests

	fix the rendering issues where VAOs and other stuff is just being done completely wrong

	TODO:
		-Runtime
			Cleanup functions for EVERYTHING
			Add support for stacktraces

		-Render
			change the vertices to internally use vec2s
			add ordering to rendering "layers"
			
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
			text rendering needs to use the game engine's coordinate system. fix that

		-Debug UI via imgui
		-Utils
			See what odin doesnt have and implement our own 

		-TCRF
			Optimisations
			Multithreading
			memory leaks
*/

import "core:fmt"
import "core:math/rand"
import "core:math"

testEntityProc :: proc(this: ^entity, data: rawptr) {
	(cast(^f32)data)^ += 1 * D2R * targetFPS * deltaTime
	this.object.angle = (cast(^f32)data)^
	objUpdate(this.object)
}

deltaTime : f32 = 15

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

	for i := 0; i < 45; i+=1 {
		addEntity(vfuRand(0., 800.), vfuRand(0., 800.), 64., 64., 0, "meow", "sand3", testEntityProc, vfuRand(0., 360.))
	}
	//loadProgram("data/shaders/button.fs", "data/shaders/button.vs", "Button Renderer", buttonRender)
	//createButton((vs_rectf32){300, 400, 80, 60}, "test button", 0, nil, .FLAT, (RGBA){rgba = 0x12345678})
	
	

	addStack(f32, "fpsStack", .FIFO)

	for running {
		startFrameTime := SDL.GetPerformanceCounter()

		//move event stuff out to somewhere seperate
		event : SDL.Event

		for (SDL.PollEvent(&event)) {
			#partial switch event.type {
				case .QUIT: 
					running = false;
			}
		}
		
		tickEntities()
		render()
		//SDL.Delay(17)
		endFrameTime := SDL.GetPerformanceCounter()
		deltaTime = cast(f32)(endFrameTime - startFrameTime)/(cast(f32)SDL.GetPerformanceFrequency()) //get DT in ms
		
		//lock the fps, then remeasure
		SDL.Delay(cast(u32)(deltaTime > 1/targetFPS ? 0 : 1000/targetFPS - deltaTime * 1000)) //this has some weird interactions

		endFrameTime = SDL.GetPerformanceCounter()
		deltaTime = cast(f32)(endFrameTime - startFrameTime)/(cast(f32)SDL.GetPerformanceFrequency())

		fpsText()
	}

	free_all()
	return;
}

fpsText :: proc() {
	fpsStack := findStack("fpsStack")
	pushStack("fpsStack", deltaTime)
	sigmaDT : f32
	for i:=0; i < len(fpsStack.elements) - 1; i+=1 {
		sigmaDT += (cast(^f32)fpsStack.elements[i])^
		if (len(fpsStack.elements) > FPS_SAMPLES) {
			popStack("fpsStack")
		}

	} //sum up all elements in the list
	sigmaDT /= FPS_SAMPLES

	fpsString := fmt.aprintf("FPS: %.3f", 1/sigmaDT)
	//fmt.printf("{}\n", deltaTime)
	defer delete(fpsString)

	printText((vec2i){0, 800}, fpsString)
}