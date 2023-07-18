package vacuostellas

import gl   "vendor:OpenGL"
import SDL  "vendor:sdl2"
import math "core:math"
render :: proc() {
	SDL.GL_SwapWindow(window)
	gl.Clear(gl.COLOR_BUFFER_BIT)

	//this is a bad solution. just for testing, generate the vertices
	objects : resource = resources[resGetResourceIndex(object)]
	for i := 0; i < len(objects.elements); i+=1 {
		intObject : object = (cast(^object)objects.elements[i].value)^
		//setup vertices like so:
		//where 0 is the x,y coord of the object 

		/*
		0----1
		|\   |
		| \  |
		|  \ |
		|   \|
		2----3
		*/

		vertices : [4][2]f32
		vertices[0][0] = math.remap(cast(f32)intObject.x, 				  0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		vertices[0][1] = math.remap(cast(f32)intObject.y, 				  0., cast(f32)SCREEN_HEIGHT, -1., 1.)

		vertices[1][0] = math.remap(cast(f32)(intObject.x + intObject.w), 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		vertices[1][1] = math.remap(cast(f32)intObject.y, 				  0., cast(f32)SCREEN_HEIGHT, -1., 1.)

		vertices[2][0] = math.remap(cast(f32)intObject.x, 				  0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		vertices[2][1] = math.remap(cast(f32)(intObject.y - intObject.h), 0., cast(f32)SCREEN_HEIGHT, -1., 1.)

		vertices[3][0] = math.remap(cast(f32)(intObject.x + intObject.w), 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		vertices[3][1] = math.remap(cast(f32)(intObject.y - intObject.h), 0., cast(f32)SCREEN_HEIGHT, -1., 1.)



	}
	return
}

//we need a map!!