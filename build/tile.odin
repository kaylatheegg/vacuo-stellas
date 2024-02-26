package vacuostellas

import "core:fmt"
import "core:math"

//id list of tiles

tile :: struct {
	type: tile_type,
	x, y: i32,
	tile_ent: ^entity,
}

chunk :: struct {
	cx, cy: i32,
	tiles: [16][16]tile,
}

worldToChunkIds :: proc(x, y: i32) -> (i32, i32) {
	cx := (x & ~i32(0xF))/0x10
	cy := (y & ~i32(0xF))/0x10
	return cx, cy
}

worldToChunkName :: proc(x, y: i32) -> string {
	return fmt.aprintf("%d-%d", worldToChunkIds(x, y))
}

tileCallback :: proc(this: ^entity, data: rawptr) {
	return;
}

createTile :: proc(x, y: i32, id: tile_type) {
	int_chunk := findChunk(x, y)
	if (int_chunk == nil) {
		int_chunk = createChunk(x, y)
	}

	tx := x & 0xF
	ty := y & 0xF
	int_chunk.tiles[ty][tx] = (tile){type = id, x = tx, y = ty, tile_ent = getEntity(
		addEntity(f32(x*TILE_SIZE), f32(y*TILE_SIZE), TILE_SIZE, TILE_SIZE, 0., "Tile", tileTxMap[id][1], tileCallback, 0))}
	vsPBodyNew(50, 0, (vec2f){f32(x*TILE_SIZE), f32(y*TILE_SIZE)}, (vec2f){0,0}, (vec2f){0,0}, 
		0, 0, vsPCBBNew((vs_rectf32){TILE_SIZE/2, -TILE_SIZE/2, TILE_SIZE, TILE_SIZE}), true, int_chunk.tiles[ty][tx].tile_ent)
}

findChunk :: proc(x, y: i32) -> ^chunk {
	chunk_id := worldToChunkName(x, y)
	return regGetElementPointer(chunk, chunk_id)
}

createChunk :: proc(x, y: i32) -> ^chunk { //TODO: FIX THIS SLOW ASS FUNCTION
	if regGetRegistryIndex(chunk) == -1 {
		addRegistry(chunk)
		for type in tile_type {
			tileStrings := tileTxMap[type]
			registerTexture(tileStrings[0], tileStrings[1])
		}
	}

	//find correct chunk id
	int_chunk := findChunk(x, y)
	if int_chunk != nil {
		return int_chunk	
	}

	cx, cy := worldToChunkIds(x, y)

	regAddElement(chunk, worldToChunkName(x, y), (chunk){cx = cx, cy = cy})
	return regGetElementPointer(chunk, worldToChunkName(x, y))
}

/*
chunk layout for storing tiles
relative around 0,0, the chunk can be stored in a dictionary with a name of X-Y
     |
     |+++++
	|+++++
-----+-----
     |
     |
     |
determining the chunk can be used with a truncation with
&= 0xFFFFFFFF ^ 0b1111 (top 4 bits removed bitmask)
/= 0x10 (chunk size)
to determine a chunk id.
this allows a maximum backrooms world size of 2^32 chunks, and 2^36 blocks
during tile insertion, an x,y tile can be converted to X-Y coordinates to look up in the
dictionary. if it does not exist, then it can be created and added into the dictionary.

chunk origin is at the bottom left, with increasing X and Y according to the world
coordinate space.

*/