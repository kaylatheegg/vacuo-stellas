package vacuostellas

import "core:fmt"
import math "core:math"

import stbtt "vendor:stb/truetype"
import gl   "vendor:OpenGL"
import SDL  "vendor:sdl2"

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
	gl.BindVertexArray(this.VAO)

	if this.first_run == true {
		gl.BindVertexArray(this.VAO)
		gl.BindBuffer(gl.ARRAY_BUFFER, this.VBO)
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.EBO)
		posAttrib := gl.GetAttribLocation(this.program, "position")
		gl.VertexAttribPointer(cast(u32)posAttrib, 2, gl.FLOAT, gl.FALSE, 4*size_of(f32), 0) 
		gl.EnableVertexAttribArray(cast(u32)posAttrib)

		texAttrib := gl.GetAttribLocation(this.program, "texcoord")
		gl.VertexAttribPointer(cast(u32)texAttrib, 2, gl.FLOAT, gl.FALSE, 4*size_of(f32), 2*size_of(f32)) 
		gl.EnableVertexAttribArray(cast(u32)texAttrib)
		this.first_run = false
	}

	gl.Uniform2f(gl.GetUniformLocation(this.program, "cameraPos"), camera.x/f32(SCREEN_WIDTH), camera.y/f32(SCREEN_HEIGHT))



	gl.BindTexture(gl.TEXTURE_2D, textureatlas.atlasID);

	gl.BindBuffer(gl.ARRAY_BUFFER, this.VBO)
	gl.BufferData(gl.ARRAY_BUFFER, len(this.vertices) * size_of(f32), raw_data(this.vertices), gl.DYNAMIC_DRAW)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.EBO)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(this.elements) * size_of(u32), raw_data(this.elements), gl.DYNAMIC_DRAW)

	gl.DrawElements(gl.TRIANGLES, cast(i32)len(this.elements), gl.UNSIGNED_INT, nil)
}

buttonRender :: proc(this: ^program) {
	gl.UseProgram(this.program)
	gl.BindVertexArray(this.VAO)
	gl.BindTexture(gl.TEXTURE_2D, textureatlas.atlasID);
	
	if this.first_run == true {	
		gl.BindBuffer(gl.ARRAY_BUFFER, this.VBO)
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.EBO)
		posAttrib := gl.GetAttribLocation(this.program, "position")
		gl.VertexAttribPointer(cast(u32)posAttrib, 2, gl.FLOAT, gl.FALSE, 4*size_of(f32), 0) 
		gl.EnableVertexAttribArray(cast(u32)posAttrib)

		texAttrib := gl.GetAttribLocation(this.program, "texcoord")
		gl.VertexAttribPointer(cast(u32)texAttrib, 2, gl.FLOAT, gl.FALSE, 4*size_of(f32), 2*size_of(f32)) 
		gl.EnableVertexAttribArray(cast(u32)texAttrib)
		this.first_run = false
	}
	
	buttons := getResource(button)
	for buttonEntry in buttons.elements {
		entry := (cast(^button)buttonEntry.value)^
		//construct vertices
		rect := entry.bb
		tx_info := entry.txinfo

		int_vertices : [4][4]f32
		int_vertices[0][0] = vsmap(rect.x, 							 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		int_vertices[0][1] = vsmap(rect.y, 							 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
		int_vertices[0][2] = vsmap(cast(f32)(tx_info.x),			 0., cast(f32)textureatlas.w, 0., 1.)
		int_vertices[0][3] = vsmap(cast(f32)(tx_info.y),			 0., cast(f32)textureatlas.h, 0., 1.)

		int_vertices[1][0] = vsmap(rect.x + rect.w,					 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		int_vertices[1][1] = vsmap(rect.y, 							 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
		int_vertices[1][2] = vsmap(cast(f32)(tx_info.x + tx_info.w), 0., cast(f32)textureatlas.w, 0., 1.)
		int_vertices[1][3] = vsmap(cast(f32)(tx_info.y),			 0., cast(f32)textureatlas.h, 0., 1.)

		int_vertices[2][0] = vsmap(rect.x, 				 			 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		int_vertices[2][1] = vsmap(rect.y - rect.h, 				 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
		int_vertices[2][2] = vsmap(cast(f32)(tx_info.x),		 	 0., cast(f32)textureatlas.w, 0., 1.)
		int_vertices[2][3] = vsmap(cast(f32)(tx_info.y + tx_info.h), 0., cast(f32)textureatlas.h, 0., 1.)

		int_vertices[3][0] = vsmap(rect.x + rect.w, 				 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
		int_vertices[3][1] = vsmap(rect.y - rect.h, 				 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
		int_vertices[3][2] = vsmap(cast(f32)(tx_info.x + tx_info.w), 0., cast(f32)textureatlas.w, 0., 1.)
		int_vertices[3][3] = vsmap(cast(f32)(tx_info.y + tx_info.h), 0., cast(f32)textureatlas.h, 0., 1.)

		int_elements : [6]i32
		int_elements[0] = 0
		int_elements[1] = 1
		int_elements[2] = 3
		int_elements[3] = 0
		int_elements[4] = 3
		int_elements[5] = 2

		gl.Uniform1i(gl.GetUniformLocation(this.program, "type"), cast(i32)entry.button_type)

		colours_list : [16]f32
		for colour, i in entry.button_colours {
			colours_list[4 * i + 0] = cast(f32)colour.r
			colours_list[4 * i + 1] = cast(f32)colour.g
			colours_list[4 * i + 2] = cast(f32)colour.b
			colours_list[4 * i + 3] = cast(f32)colour.a
		}

		gl.Uniform4fv(gl.GetUniformLocation(this.program, "colours"), 4, raw_data(colours_list[:]))

		gl.BindVertexArray(this.VAO)
		gl.BindBuffer(gl.ARRAY_BUFFER, this.VBO)
		gl.BufferData(gl.ARRAY_BUFFER, 16 * size_of(f32), raw_data(int_vertices[:]), gl.DYNAMIC_DRAW)

		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.EBO)
		gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, 6 * size_of(u32), raw_data(int_elements[:]), gl.DYNAMIC_DRAW)

		gl.DrawElements(gl.TRIANGLES, cast(i32)6, gl.UNSIGNED_INT, nil)
	}
}

textRender :: proc(this: ^program) {
	if len(findStack("text").elements) == 0 {
		return
	}
	clear(&this.vertices)
	clear(&this.elements)

	gl.UseProgram(this.program)
	gl.BindVertexArray(this.VAO)
	gl.BindTexture(gl.TEXTURE_2D, textureatlas.atlasID)

	if this.first_run == true {
		gl.BindBuffer(gl.ARRAY_BUFFER, this.VBO)
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.EBO)
		posAttrib := gl.GetAttribLocation(this.program, "position")
		gl.VertexAttribPointer(cast(u32)posAttrib, 2, gl.FLOAT, gl.FALSE, 4*size_of(f32), 0) 
		gl.EnableVertexAttribArray(cast(u32)posAttrib)

		texAttrib := gl.GetAttribLocation(this.program, "texcoord")
		gl.VertexAttribPointer(cast(u32)texAttrib, 2, gl.FLOAT, gl.FALSE, 4*size_of(f32), 2*size_of(f32)) 
		gl.EnableVertexAttribArray(cast(u32)texAttrib)
		this.first_run = false
	}

	charcount: u32 = 0
	for i:=0; i < len(findStack("text").elements); i+=1 {
		entry_ptr := cast(^text_entry)popStack("text")
		entry := entry_ptr^
		free(entry_ptr)
		//print out the character at that location
		int_font := getFont(entry.font)
		x := entry.pos.x 
		y := entry.pos.y
		for char, index in entry.text {
			if char == '\n' {
				y -= int_font.ascent - int_font.descent
				x = entry.pos.x
				continue
			}

			if char == ' ' {
				x += 25
			}

			char_name := fmt.aprintf("%s-%d", int_font.name, cast(i32)char)
			defer delete(char_name)

			char_tx_entry := regGetElement(texture, char_name)
			char_atlas_entry := getAtlasEntry(char_name)

			rect := (vs_rectf32){cast(f32)x, cast(f32)y, cast(f32)char_tx_entry.texture.w, cast(f32)char_tx_entry.texture.h}
			tx_info := (vs_recti32){char_atlas_entry.x, char_atlas_entry.y,
									char_atlas_entry.w, char_atlas_entry.h}

			x += char_tx_entry.texture.w
			x += cast(i32)(cast(f32)stbtt.GetCodepointKernAdvance(&int_font.info, char, cast(rune)entry.text[index]) * 2. * int_font.scale)

			rect.y -= cast(f32)int_font.ascent + cast(f32)int_font.chars[char].bbox.y

			int_vertices : [4][4]f32
			int_vertices[0][0] = vsmap(rect.x, 							 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
			int_vertices[0][1] = vsmap(rect.y, 							 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
			int_vertices[0][2] = vsmap(cast(f32)(tx_info.x),			 0., cast(f32)textureatlas.w, 0., 1.)
			int_vertices[0][3] = vsmap(cast(f32)(tx_info.y),			 0., cast(f32)textureatlas.h, 0., 1.)

			int_vertices[1][0] = vsmap(rect.x + rect.w,					 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
			int_vertices[1][1] = vsmap(rect.y, 							 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
			int_vertices[1][2] = vsmap(cast(f32)(tx_info.x + tx_info.w), 0., cast(f32)textureatlas.w, 0., 1.)
			int_vertices[1][3] = vsmap(cast(f32)(tx_info.y),			 0., cast(f32)textureatlas.h, 0., 1.)

			int_vertices[2][0] = vsmap(rect.x, 				 			 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
			int_vertices[2][1] = vsmap(rect.y - rect.h, 				 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
			int_vertices[2][2] = vsmap(cast(f32)(tx_info.x),		 	 0., cast(f32)textureatlas.w, 0., 1.)
			int_vertices[2][3] = vsmap(cast(f32)(tx_info.y + tx_info.h), 0., cast(f32)textureatlas.h, 0., 1.)

			int_vertices[3][0] = vsmap(rect.x + rect.w, 				 0., cast(f32)SCREEN_WIDTH,  -1., 1.)
			int_vertices[3][1] = vsmap(rect.y - rect.h, 				 0., cast(f32)SCREEN_HEIGHT, -1., 1.)
			int_vertices[3][2] = vsmap(cast(f32)(tx_info.x + tx_info.w), 0., cast(f32)textureatlas.w, 0., 1.)
			int_vertices[3][3] = vsmap(cast(f32)(tx_info.y + tx_info.h), 0., cast(f32)textureatlas.h, 0., 1.)

			for i:=0; i<4;i+=1 {
				append(&this.vertices, ..int_vertices[i][:])
			}
			int_elements : [6]u32
			//use two tris, 013, 032. both triangles should have the same chirality
			int_elements[0] = charcount * 4 + 0
			int_elements[1] = charcount * 4 + 1
			int_elements[2] = charcount * 4 + 3
			int_elements[3] = charcount * 4 + 0
			int_elements[4] = charcount * 4 + 3
			int_elements[5] = charcount * 4 + 2
			append(&this.elements, ..int_elements[:])

			charcount+=1
		}
	}
	gl.BindVertexArray(this.VAO)
	gl.BindBuffer(gl.ARRAY_BUFFER, this.VBO)
	gl.BufferData(gl.ARRAY_BUFFER, len(this.vertices) * size_of(f32), raw_data(this.vertices[:]), gl.DYNAMIC_DRAW)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.EBO)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(this.elements) * size_of(u32), raw_data(this.elements[:]), gl.DYNAMIC_DRAW)

	gl.DrawElements(gl.TRIANGLES, cast(i32)len(this.elements), gl.UNSIGNED_INT, nil)	
}


metaBallRender :: proc(this: ^program) {
	gl.UseProgram(this.program)

	int_stack := findStack("metaballs")
	if int_stack == nil {
		return
	}

	/*
	0----1
	|\   |
	| \  |
	|  \ |
	|   \|
	2----3
	*/

	if (len(this.vertices) == 0) {
		resize(&this.vertices, 16)
		resize(&this.elements, 6)
	}


	this.vertices[0] = -1.0 //0
	this.vertices[1] = 1.0 
	this.vertices[2] = 0
	this.vertices[3] = 0

	this.vertices[4] = 1.0 //1
	this.vertices[5] = 1.0 
	this.vertices[6] = 0
	this.vertices[7] = 0

	this.vertices[8] = -1.0 //2
	this.vertices[9] = -1.0 
	this.vertices[10] = 0
	this.vertices[11] = 0

	this.vertices[12] = 1.0 //3
	this.vertices[13] = -1.0 
	this.vertices[14] = 0
	this.vertices[15] = 0

	this.elements[0] = 0
	this.elements[1] = 1
	this.elements[2] = 3
	this.elements[3] = 0
	this.elements[4] = 3
	this.elements[5] = 2

	info : [dynamic]f32

	for i:=0; i < len(int_stack.elements); i+=1 {
		append(&info, (cast(^ballData)int_stack.elements[i]).pos.x)
		append(&info, (cast(^ballData)int_stack.elements[i]).pos.y)
		append(&info, (cast(^ballData)int_stack.elements[i]).radius)
	}


	gl.Uniform1i(gl.GetUniformLocation(this.program, "ballCount"), cast(i32)len(int_stack.elements))

	gl.Uniform3fv(gl.GetUniformLocation(this.program, "ballInfo"), cast(i32)len(int_stack.elements), raw_data(info))


	gl.BindVertexArray(this.VAO)
	gl.BindBuffer(gl.ARRAY_BUFFER, this.VBO)
	gl.BufferData(gl.ARRAY_BUFFER, len(this.vertices) * size_of(f32), raw_data(this.vertices), gl.DYNAMIC_DRAW)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.EBO)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(this.elements) * size_of(u32), raw_data(this.elements), gl.DYNAMIC_DRAW)

	gl.DrawElements(gl.TRIANGLES, cast(i32)len(this.elements), gl.UNSIGNED_INT, nil)
	clear(&info)
}