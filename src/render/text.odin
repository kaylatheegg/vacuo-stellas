package vacuostellas

import "core:fmt"

import SDL "vendor:sdl2"
import gl  "vendor:OpenGL"

character :: struct {
	surface: ^SDL.Surface,
	size, bearing: vec2i,
	advance: u32,
}

initText :: proc() {
	/*if FT_Init_FreeType(&ft) != 0 {
		log("Failed to initialise freetype library!", .ERR, "Text")
		crash()
	}

	if FT_New_Face(ft, cstring("data/fonts/URWGothic-Book.otf"), 0, &font) != 0 {
		log("Failed to load the font! error: {}", .ERR, "Text", FT_New_Face(ft, cstring("data/fonts/URWGothic-Book.otf"), 0, &font))
		crash()
	}

	FT_Set_Pixel_Sizes(font, 64, 128);

	addRegistry(character)

	for c:u64=0; c < 128; c+=1 {
		if FT_Load_Char(font, c, .Render) != 0 {
        	log("Failed to insert character %d, error:{}", .ERR, "Text", c, FT_Load_Char(font, c, .Render))
        	continue
    	}



    	FT_Load_Glyph(font, c, .Render)
    	//FT_Render_Glyph(font.glyph, .Normal)
		//gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1);
		char_name := fmt.aprintf("URWGothic-Book-%d", c)
    	char_surface := SDL.CreateRGBSurfaceFrom(font.glyph.bitmap.buffer, 
    		cast(i32)font.glyph.bitmap.width, 
    		cast(i32)font.glyph.bitmap.rows, 
    		8, 
    		font.glyph.bitmap.pitch, 
    		0, 0, 0, 0xFF)
		if char_surface == nil {
			log("Could not load char_surface for font on char {}, error:{}", .ERR, "Text", c, SDL.GetError())
			continue
		}
		fmt.printf("{}, {}\n", font.glyph.bitmap.width, font.glyph.bitmap.rows)
		regAddElement(character, char_name, (character){char_surface, (vec2i){cast(i32)font.glyph.bitmap.width, cast(i32)font.glyph.bitmap.rows},
																	  (vec2i){cast(i32)font.glyph.bitmap_left,  cast(i32)font.glyph.bitmap_top },
																	  cast(u32)font.glyph.advance.x})
		regAddElement(texture, char_name, (texture){char_name, char_surface})
		append(&textureatlas.entries, (atlas_entry){char_name, 0, 0, char_surface.w, char_surface.h})
	}*/
	stitchAtlas()
}