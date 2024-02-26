package vacuostellas

import SDL "vendor:sdl2"
/*
coordinate space
       -
       ^
       |
       |
       |
- <----+----> +
       |
       |
       |
       v
       +

 */




/*
	design to follow:
		functions should not need to have an initialiser called unless it is a big function like render,
		the initialisation should be handled in the first call to that function (e.g load shader)

	add unit tests

	fix the rendering issues where VAOs and other stuff is just being done completely wrong

	TODO:
		-Runtime
			
			return pointers from the resAddElement func
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
import "core:sort"

testEntityProc :: proc(this: ^entity, data: rawptr) {
	(cast(^f32)data)^ += 1 * D2R * targetFPS * deltaTime
	this.object.angle = (cast(^f32)data)^
	objUpdate(this.object)
}

deltaTime: f32 = 15
totalTime: f32 = 0; 

testButtion :: proc(this: ^button) {
	fmt.printf("TEST!!\n")
}

testObj :: proc(this: ^entity, data: rawptr) {
	if this.body_ptr == nil {
		vsPBodyNew(5, 0, (vec2f){this.object.x, this.object.y}, (vec2f){0, 0}, (vec2f){0,0}, 
		0, 0, vsPCBBNew((vs_rectf32){64/2, -64/2, 64, 64}), false, this);
	}

	speed : f32 = 50.0

	this.body_ptr.trans_velocity = (vec2f){0,0}

	if keyboardState[SDL.Scancode.A] == 1 {
		this.body_ptr.trans_velocity.x -= speed;
	}
	if keyboardState[i32(SDL.Scancode.D)] == 1 {
		this.body_ptr.trans_velocity.x += speed;
	}
	if keyboardState[i32(SDL.Scancode.W)] == 1 {
		this.body_ptr.trans_velocity.y += speed;
	}
	if keyboardState[i32(SDL.Scancode.S)] == 1 {
		this.body_ptr.trans_velocity.y -= speed;
	}

	camera.x = this.object.x - SCREEN_WIDTH/2
	camera.y = this.object.y - SCREEN_HEIGHT/2
	//fmt.printf("Current pos: {}\n", this.body_ptr.position);
}

keyboardState : [^]u8

main :: proc() {
	log("Starting engine!", .INF, "Runtime");
	SDL.Init({.TIMER, .VIDEO, .EVENTS});

	running : bool = true

	initRender()

	registerTexture("data/images/tiles/sand.png", "sand")

	addEntity(0, 0, 0, 0, 0, "camera", "DEFAULT", cameraCallback, 0)

	initText()

	addEntity(76, 120, 64, 64, 0, "testobj", "DEFAULT", testObj, 0)

	for i :i32= 0; i < 64; i+=1 {
		for j :i32= 0; j < 64; j+=1 {
			if (i*j) % 8 == 0 {
				createTile(j, i, .GRASS)
			}
		}		
	}

	

	//createButton((vs_rectf32){400, 400, 100, 50}, "test button", 0, nil, .FLAT, 0x9F2233FF)

	addStack(f32, "fpsStack", .FIFO)

	for running {
		startFrameTime := SDL.GetPerformanceCounter()

		//move event stuff out to somewhere seperate
		event : SDL.Event

		//read keyboard inputs

		for (SDL.PollEvent(&event)) {
			#partial switch event.type {
				case .QUIT: 
					running = false;
			}
		}

		keyboardState = SDL.GetKeyboardState(nil)
		
		tickEntities()
		render()
		//SDL.Delay(17)
		endFrameTime := SDL.GetPerformanceCounter()
		deltaTime = cast(f32)(endFrameTime - startFrameTime)/(cast(f32)SDL.GetPerformanceFrequency()) //get DT in ms
		
		//lock the fps, then remeasure
		SDL.Delay(cast(u32)(deltaTime > 1/targetFPS ? 0 : 1000/targetFPS - deltaTime * 1000)) //this has some weird interactions

		endFrameTime = SDL.GetPerformanceCounter()
		deltaTime = cast(f32)(endFrameTime - startFrameTime)/(cast(f32)SDL.GetPerformanceFrequency())
		totalTime += deltaTime;
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