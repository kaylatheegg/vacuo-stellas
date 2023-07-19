package vacuostellas

import "core:fmt"
import math "core:math"

import gl   "vendor:OpenGL"
import SDL  "vendor:sdl2"


render :: proc() {
	SDL.GL_SwapWindow(window)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	gl.UseProgram(test_program.program)

	//setup position input

	posAttrib := gl.GetAttribLocation(test_program.program, "position")
	gl.VertexAttribPointer(cast(u32)posAttrib, 2, gl.FLOAT, gl.FALSE, 4*size_of(f32), 0) 
	gl.EnableVertexAttribArray(cast(u32)posAttrib)

	texAttrib := gl.GetAttribLocation(test_program.program, "texcoord")
	gl.VertexAttribPointer(cast(u32)texAttrib, 2, gl.FLOAT, gl.FALSE, 4*size_of(f32), 2*size_of(f32)) 
	gl.EnableVertexAttribArray(cast(u32)texAttrib)

	intTexture := regGetElement(texture, "DEFAULT")

	//this is a bad solution. just for testing, generate the vertices
	objects := getResource(object)
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

		/*UV map view
		 *23
		 *01
		 */

		vertices : [4][4]f32
		vertices[0][0] = vsmap(cast(f32)intObject.x, 									 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		vertices[0][1] = vsmap(cast(f32)intObject.y, 									 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
		vertices[0][2] = vsmap(cast(f32)(intObject.txrect.x),							 0., cast(f32)textureatlas.w, 0., 1.)
		vertices[0][3] = vsmap(cast(f32)(intObject.txrect.y),							 0., cast(f32)textureatlas.h, 0., 1.)

		vertices[1][0] = vsmap(cast(f32)(intObject.x + intObject.w),					 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		vertices[1][1] = vsmap(cast(f32)intObject.y, 									 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
		vertices[1][2] = vsmap(cast(f32)(intObject.txrect.x + intObject.txrect.w),		 0., cast(f32)textureatlas.w, 0., 1.)
		vertices[1][3] = vsmap(cast(f32)(intObject.txrect.y),							 0., cast(f32)textureatlas.h, 0., 1.)

		vertices[2][0] = vsmap(cast(f32)intObject.x, 				 					 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		vertices[2][1] = vsmap(cast(f32)(intObject.y - intObject.h), 					 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
		vertices[2][2] = vsmap(cast(f32)(intObject.txrect.x),		 					 0., cast(f32)textureatlas.w, 0., 1.)
		vertices[2][3] = vsmap(cast(f32)(intObject.txrect.y + intObject.txrect.h),		 0., cast(f32)textureatlas.h, 0., 1.)

		vertices[3][0] = vsmap(cast(f32)(intObject.x + intObject.w), 					 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		vertices[3][1] = vsmap(cast(f32)(intObject.y - intObject.h), 					 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
		vertices[3][2] = vsmap(cast(f32)(intObject.txrect.x + intObject.txrect.w),		 0., cast(f32)textureatlas.w, 0., 1.)
		vertices[3][3] = vsmap(cast(f32)(intObject.txrect.y + intObject.txrect.h),		 0., cast(f32)textureatlas.h, 0., 1.)

		//fmt.printf("1: {}, {}\n2: {}, {}\n3: {}, {}\n4: {}, {}\n", vertices[0][0], vertices[0][1], vertices[1][0], vertices[1][1], vertices[2][0], vertices[2][1], vertices[3][0], vertices[3][1])
		elements : [6]i32
		//use two tris, 013, 032. both triangles should have the same chirality

		elements[0] = 0
		elements[1] = 1
		elements[2] = 3
		elements[3] = 0
		elements[4] = 3
		elements[5] = 2

		gl.BindVertexArray(test_program.VAO)
		gl.BindBuffer(gl.ARRAY_BUFFER, test_program.VBO)
		gl.BufferData(gl.ARRAY_BUFFER, 16 * size_of(f32), transmute(rawptr)&vertices, gl.DYNAMIC_DRAW)

		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, test_program.EBO)
		gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, 6 * size_of(i32), transmute(rawptr)&elements, gl.DYNAMIC_DRAW)

		gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
	}
	return
}

//we need a map!!

//maps interval [a,b] onto [A,B], with parameterisation value
//deriving this is annoying but i'll put a sparknotes ver here
//we map [a,b] to [0, 1], and then map that to [A, B]


vsmap :: proc(value, a, b, A, B: f32) -> f32 {
	return A + (B-A)/(b-a) * (value - a)
}