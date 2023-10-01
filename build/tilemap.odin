package vacuostellas

tileTxMap := [tile_type][2]string {
	.NONE  = {"", ""},
	.GRASS = {"data/images/tiles/grass.png", "Grass"},
	.DIRT  = {"data/images/tiles/burnt.png", "Dirt"},
	.FIRE  = {"data/images/tiles/fire.png",  "Fire"},
	.WATER = {"data/images/tiles/water.png", "Water"}
}

tile_type :: enum {
	NONE,
	GRASS,
	DIRT,
	FIRE,
	WATER,
}