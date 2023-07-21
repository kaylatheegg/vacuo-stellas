package vacuostellas

import "core:fmt"
import math "core:math"

import gl   "vendor:OpenGL"
import SDL  "vendor:sdl2"

vertices : [dynamic]f32
elements : [dynamic]u32

render :: proc() {
	SDL.GL_SwapWindow(window)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	
	programs := getResource(program)

	for renderer in programs.elements {
		if (cast(^program)renderer.value).renderCallback == nil {
			continue
		}

		(cast(^program)renderer.value)->renderCallback()
	}


	return
}

objectRender :: proc(this: ^program) {
	gl.UseProgram(this.program)

	posAttrib := gl.GetAttribLocation(this.program, "position")
	gl.VertexAttribPointer(cast(u32)posAttrib, 2, gl.FLOAT, gl.FALSE, 4*size_of(f32), 0) 
	gl.EnableVertexAttribArray(cast(u32)posAttrib)

	texAttrib := gl.GetAttribLocation(this.program, "texcoord")
	gl.VertexAttribPointer(cast(u32)texAttrib, 2, gl.FLOAT, gl.FALSE, 4*size_of(f32), 2*size_of(f32)) 
	gl.EnableVertexAttribArray(cast(u32)texAttrib)

	gl.BindVertexArray(this.VAO)
	gl.BindBuffer(gl.ARRAY_BUFFER, this.VBO)
	gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(f32), raw_data(vertices), gl.DYNAMIC_DRAW)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.EBO)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(elements) * size_of(u32), raw_data(elements), gl.DYNAMIC_DRAW)

	gl.DrawElements(gl.TRIANGLES, cast(i32)len(elements), gl.UNSIGNED_INT, nil)
}



