package vacuostellas

import "core:fmt"

vs_rectf32 :: struct {
	x, y, w, h: f32
}

vs_recti32 :: struct {
	x, y, w, h: i32
}

object :: struct {
	using pos: vs_rectf32,
	angle: radian,
	name: string,
	txrect: vs_recti32,
	vertexID: u32,
	objectID: u32,
}

getObjectByID :: proc(id : u32) -> ^object { //we need to find a better system of doing this. at the moment, this is O(n) and it should be O(1)
	if (resGetResourceIndex(object) == -1) {
		log("Objects not initialised yet!", .ERR, "Object")
		return nil
	}

	for entry in (getResource(object)).elements {
		if ((cast(^object)entry.value).objectID == id) {
			return cast(^object)entry.value
		}
	}

	return nil
}

addObject :: proc(x, y, w, h: f32, angle: radian, name: string, texture_name: string) -> (id: u32) {
	if (resGetResourceIndex(object) == -1) {
		addResource(object)
		loadProgram("data/shaders/shader.fs", "data/shaders/shader.vs", "Object Renderer", objectRender) //object shader
	}

	int_entry := getAtlasEntry(texture_name)

	if (int_entry == textureatlas.entries[0] && texture_name != "DEFAULT") {
		log("Texture \"{}\" does not exist! Loading default.", .ERR, "Object", texture_name)
	}

	objectID: u32 = uID()

	//assume this is fine. we could probably do better error checking cus odin is nice, but fuck it
	//it should default to the DEFAULT texture, anyway
	resAddElement(object, name, 
				(object){(vs_rectf32){x, y, w, h}, 
				angle, name, 
				(vs_recti32){int_entry.x, int_entry.y, int_entry.w, int_entry.h}, 
				objCreateVertices((vs_rectf32){x,y,w,h}, (vs_recti32){int_entry.x, int_entry.y, int_entry.w, int_entry.h}, angle), objectID})
	return objectID
}

objCreateVertices :: proc(rect: vs_rectf32, tx_info: vs_recti32, angle: radian) -> u32 {
	obj_program := resGetElementPointer(program, "Object Renderer")

	vertexalloc  := make([]f32, 16)
	elementalloc := make([]u32, 6)
	append(&obj_program.vertices, ..vertexalloc[:])
	append(&obj_program.elements, ..elementalloc[:])

	objUpdateVertices(cast(u32)(len(obj_program.vertices)/16) - 1, rect, tx_info, angle)
	return cast(u32)len(obj_program.vertices)/16 - 1
}

objUpdate :: proc(this: ^object) {
	objUpdateVertices(this.vertexID, this.pos, this.txrect, this.angle)
}

objUpdateVertices :: proc(id: u32, rect: vs_rectf32, tx_info: vs_recti32, angle: radian) {
	obj_program := resGetElementPointer(program, "Object Renderer")

	if (id > cast(u32)len(obj_program.vertices)/16) {
		log("Attempted to update vertex id which was out of the bounds of the vertex array! ID:{}", .ERR, "Render", id)
		return
	}
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

	if (angle != 0.) {
		new_origin := (vec2f){vsmap(rect.x + rect.w/2., 0., cast(f32)SCREEN_WIDTH,  -1., 1.),
							 vsmap(rect.y - rect.h/2., 0., cast(f32)SCREEN_HEIGHT, -1., 1.),}

		//fmt.printf("origin: {}, {}\n", new_origin[0], new_origin[1])
		for i:=0; i < 4; i+=1 {
			int_vec := (vec2f){int_vertices[i][0], int_vertices[i][1]}
			int_vec =  vec2RotatePoint(int_vec, new_origin, angle)
			int_vertices[i][0] = int_vec[0]
			int_vertices[i][1] = int_vec[1]
		}
	}
	

	//fmt.printf("1: {}, {}\n2: {}, {}\n3: {}, {}\n4: {}, {}\n", vertices[0][0], vertices[0][1], vertices[1][0], vertices[1][1], vertices[2][0], vertices[2][1], vertices[3][0], vertices[3][1])
	int_elements : [6]u32
	//use two tris, 013, 032. both triangles should have the same chirality
	int_elements[0] = id * 4 + 0
	int_elements[1] = id * 4 + 1
	int_elements[2] = id * 4 + 3
	int_elements[3] = id * 4 + 0
	int_elements[4] = id * 4 + 3
	int_elements[5] = id * 4 + 2

	for i:u32=0; i<4; i+=1 {
		for j:u32=0; j<4; j+=1 {
			obj_program.vertices[id * 16 + 4*i + j] = int_vertices[i][j]
		}
	}

	for i:u32=0; i<6; i+=1 {
		obj_program.elements[id * 6 + i] = int_elements[i]
	}
	
}