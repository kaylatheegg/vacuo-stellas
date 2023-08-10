package vacuostellas

import SDL "vendor:sdl2"
import SDL_IMG "vendor:sdl2/image"
import gl "vendor:OpenGL"

import "core:slice"
import "core:fmt"


texture :: struct {
	filename: string,
	texture: ^SDL.Surface,
}

atlas_entry :: struct {
	key: string,
	x,y: i32,
	w,h: i32,
}

atlas :: struct {
	entries: [dynamic]atlas_entry,
	size: u32,
	surface: ^SDL.Surface,
	atlasID: u32,
	w, h: i32,
}

textureatlas: atlas

registerTexture :: proc(filename: string, name: string) {
	if (regGetRegistryIndex(texture) == -1) {
		addRegistry(texture)
		gl.GenTextures(1, &textureatlas.atlasID);
		textureatlas.size = 256;
		//load in the default
		int_texture : texture
		int_texture.filename = "data/images/default.png"
		int_texture.texture = SDL_IMG.Load(cstring(raw_data(int_texture.filename)))

		if (int_texture.texture == nil) {
			log("Could not load DEFAULT texture, error: {}", .SVR, "Texture", SDL_IMG.GetError())
			crash()
		}

		regAddElement(texture, "DEFAULT", int_texture)
		append(&textureatlas.entries, (atlas_entry){"DEFAULT", 0, 0, int_texture.texture.w, int_texture.texture.h})
	}	
	int_texture : texture
	int_texture.filename = filename
	int_texture.texture = SDL_IMG.Load(cstring(raw_data(filename)))
	if (int_texture.texture == nil) {
		log("Could not load texture \"{}\", error: {}", .ERR, "Texture", filename, SDL_IMG.GetError())
		return
	}


	regAddElement(texture, name, int_texture)
	append(&textureatlas.entries, (atlas_entry){name, 0, 0, int_texture.texture.w, int_texture.texture.h})
	stitchAtlas()
}

getAtlasEntry :: proc(name: string) -> atlas_entry {
	for entry in textureatlas.entries {
		if (entry.key == name) {
			return entry
		}
	}
	return textureatlas.entries[0]
}

//atlas stitching
//gonna use a naive packing approach that is just stack right until full, then stack up
//if we're out of space? we double the atlas size, and then re-run the algorithm
//this is the shelf algorithm
//skip index 0 as that is the default.

sort_proc :: proc(a: atlas_entry, b: atlas_entry) -> bool {
	if a.h < b.h {
		return true
	}
	return false
}

stitchAtlas :: proc() {
	slice.sort_by(textureatlas.entries[1:], sort_proc)

	xPos, yPos, maxH, totalMaxH, totalMaxW : i32

	xPos = 64
	maxH = 64

	for entry, i in textureatlas.entries[1:] {
		if (xPos + textureatlas.entries[i].w) > cast(i32)textureatlas.size {
			yPos += maxH
			xPos = 0
			maxH = 0
		}

		if (yPos + textureatlas.entries[i].h) > cast(i32)textureatlas.size {
			//we're too small, we need to resize and reset.
			textureatlas.size *= 2
			i := 0 //this is hacky. figure out a better way of doing this
			xPos = 0
			yPos = 0
			maxH = 0
			break
		}

		textureatlas.entries[i].x = xPos
		textureatlas.entries[i].y = yPos

		xPos += textureatlas.entries[i].w

		if (textureatlas.entries[i].h > maxH) {
			maxH = textureatlas.entries[i].h
		}

		if (totalMaxH < (yPos + textureatlas.entries[i].h)) {
			totalMaxH = (yPos + textureatlas.entries[i].h) //this could cause too big of an atlas. look into this
		}

		if (totalMaxW < xPos) {
			totalMaxW = xPos
		}
	}

	if (textureatlas.surface != nil) {
		SDL.FreeSurface(textureatlas.surface)
	}

	//we've packed the atlas, now we need to blit it to a surface
	textureatlas.surface = SDL.CreateRGBSurface(0, totalMaxW, totalMaxH, 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000)
	for entry, index in textureatlas.entries {
		int_texture := regGetElement(texture, textureatlas.entries[index].key) //this WILL be a source of slowdown
		SDL.BlitSurface(int_texture.texture, nil, textureatlas.surface, &(SDL.Rect){entry.x, entry.y, entry.w, entry.h})
		//fmt.printf("key:{} index:{} x:{}, y:{}, w:{}, h:{}\n", textureatlas.entries[index].key, index, entry.x, entry.y, entry.w, entry.h)
	}

	textureatlas.w = totalMaxW
	textureatlas.h = totalMaxH // this could be optimised but im hoping llvm does it for me

	gl.BindTexture(gl.TEXTURE_2D, textureatlas.atlasID);

	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, textureatlas.w, textureatlas.h, 0, gl.RGBA, gl.UNSIGNED_BYTE, textureatlas.surface.pixels);

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
}