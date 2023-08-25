package vacuostellas
//id list of tiles

tile_type :: enum {
	GRASS,
	DIRT,
	FIRE,
	WATER,
}

createTile :: proc(x, y: i32, id: tile_type) {

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