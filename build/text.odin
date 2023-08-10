package vacuostellas

import "core:fmt"
import "core:os"
import "core:mem"


import SDL "vendor:sdl2"
import gl  "vendor:OpenGL"
import stbtt "vendor:stb/truetype"


character :: struct {
	texture: ^atlas_entry,
	ax, lsb: i32,
	bbox: vs_recti32,
	char: rune,
	//kerning: i32,
}

font :: struct {
	name: string,
	fontpath: string,
	info: stbtt.fontinfo,
	chars: [dynamic]character,
	ascent, descent, line_gap: i32,
	scale: f32,
	max_height: i32,
}

text_entry :: struct {
	pos: vec2i,
	text: string,
	font: string,
}

printText :: proc(pos: vec2i, text: string, font:= "DEFAULT") {
	pushStack("text", (text_entry){pos, text, font})
}

getFont :: proc(name: string) -> font {
	return regGetElement(font, name)
}

loadFont :: proc(path, name: string) {
	if regGetRegistryIndex(font) == -1 {
		addRegistry(font)
	}

	addStack(text_entry, "text")

	intFont: font
	intFont.fontpath = path
	intFont.name = name

	fonttext, err := os.read_entire_file(intFont.fontpath)
	if (!err) {
		log("Could not open file \"%s\"!", .ERR, "Text", intFont.fontpath)
		return
	}

	if cast(i32)stbtt.InitFont(&intFont.info, raw_data(fonttext), 0) == 0 {
		log("Error initialising the font {} at path {}!", .ERR, "Text", intFont.name, intFont.fontpath)
		crash()
	}

	intFont.scale = stbtt.ScaleForPixelHeight(&intFont.info, 64) //maybe do this differently?


	stbtt.GetFontVMetrics(&intFont.info, &intFont.ascent, &intFont.descent, &intFont.line_gap)

	intFont.ascent =  cast(i32)(cast(f32)intFont.ascent  * intFont.scale)
	intFont.descent = cast(i32)(cast(f32)intFont.descent * intFont.scale)
	intFont.max_height = 0

	for c:=0; c < 256; c+=1 {
		//create bitmap of symbol and create a character struct for it.
		intCharacter : character

		stbtt.GetCodepointHMetrics(&intFont.info, cast(rune)c, &intCharacter.ax, &intCharacter.lsb)

		c_x1, c_y1, c_x2, c_y2: i32 
		stbtt.GetCodepointBitmapBox(&intFont.info, cast(rune)c, intFont.scale, intFont.scale, &c_x1, &c_y1, &c_x2, &c_y2)

		intCharacter.bbox = (vs_recti32){cast(i32)(cast(f32)intCharacter.lsb * intFont.scale), c_y1,
															  c_x2 - c_x1, c_y2 - c_y1}
		width, height, xoff, yoff: i32
		data := stbtt.GetCodepointBitmap(&intFont.info, intFont.scale, intFont.scale, cast(rune)c, &width, &height, &xoff, &yoff)

		intCharacter.char = cast(rune)c
		append(&intFont.chars, intCharacter)

		char_name := fmt.aprintf("%s-%d", intFont.name, c)


		//add the offset to the data to ensure pitch is correct
		char_surface := SDL.CreateRGBSurface(0, intCharacter.bbox.w, intCharacter.bbox.h, 8, 0, 0, 0, 0)

		colours: [256]SDL.Colour
		for colour, index in colours {
			i := cast(u8)index
			colours[i] = (SDL.Colour){255 - i,255 - i,255 - i, i};
		}

		surface_palette := SDL.AllocPalette(256)
		SDL.SetPaletteColors(surface_palette, raw_data(colours[:]), 0, 256)

		SDL.SetSurfacePalette(char_surface, surface_palette)

		//copy bitmap data into surface
		for i:i32=0; i < intCharacter.bbox.h; i+=1 {
			for j:i32=0; j < intCharacter.bbox.w; j+=1 {
				(cast([^]u8)char_surface.pixels)[i * char_surface.pitch + j] = data[i*width + j]
			}
		}

		regAddElement(texture, char_name, (texture){char_name, char_surface})
		append(&textureatlas.entries, (atlas_entry){char_name, 0, 0, char_surface.w, char_surface.h})
	}
	regAddElement(font, intFont.name, intFont)
	stitchAtlas()
}

initText :: proc() {
	loadFont("data/fonts/URWGothic-Book.otf", "DEFAULT")

	loadProgram("data/shaders/text.fs", "data/shaders/text.vs", "Text Renderer", textRender) //text shader
}