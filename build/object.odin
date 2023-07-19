package vacuostellas

vs_rect :: struct {
	x, y, w, h: i32
}

object :: struct {
	x: int,
	y: int,
	w: int,
	h: int,
	name: string,
	txrect : vs_rect,
}


addObject :: proc(x, y, w, h: int, name: string, texture_name: string) {
	if (resGetResourceIndex(object) == -1) {
		addResource(object)
	}

	int_entry : atlas_entry

	int_entry = textureatlas.entries[0] //DEFAULT entry, as long as textures exist

	for entry in textureatlas.entries {
		if entry.key == texture_name {
			int_entry = entry
			break
		}
	}

	if (int_entry == textureatlas.entries[0] && texture_name != "DEFAULT") {
		log("Texture \"{}\" does not exist! Loading default.", .ERR, "Object", texture_name)
	}



	//assume this is fine. we could probably do better error checking cus odin is nice, but fuck it
	//it should default to the DEFAULT texture, anyway
	resAddElement(object, name, (object){x, y, w, h, name, (vs_rect){int_entry.x, int_entry.y, int_entry.w, int_entry.h}})
}