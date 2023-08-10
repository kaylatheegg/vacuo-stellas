package vacuostellas

import "core:runtime"
import "core:c"

import glfw "vendor:glfw"
import gl   "vendor:OpenGL"
import SDL "vendor:sdl2"

window    : ^SDL.Window
glContext : SDL.GLContext 

/*
 	TODO:
 		add shader loading
 		add resource handling for textures
*/

initRender :: proc() {
	log("Initialising window", .INF, "Render"); 
	window = SDL.CreateWindow("Engine", SDL.WINDOWPOS_UNDEFINED, SDL.WINDOWPOS_UNDEFINED, cast(i32)SCREEN_WIDTH, cast(i32)SCREEN_HEIGHT, {.SHOWN, .OPENGL})
	if (window == nil) {
		log("Error creating window: {}", .SVR, "Render", SDL.GetError())
		crash()
	}

	glContext = initOpenGLContext()
}

initOpenGLContext :: proc() -> (intContext: SDL.GLContext) {

	SDL.GL_SetAttribute(.CONTEXT_PROFILE_MASK,  i32(SDL.GLprofile.CORE))
	SDL.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, 3)
	SDL.GL_SetAttribute(.CONTEXT_MINOR_VERSION, 3)
	//glfw.WindowHint(glfw.STENCIL_BITS, 8)

	

	intContext = SDL.GL_CreateContext(window)

	//SDL.GL_MakeCurrent(window, intContext)
	gl.load_up_to(3, 3, SDL.gl_set_proc_address)

	log("Initialising GLFW and the OGL context", .INF, "Render")
	

	gl.Viewport(0, 0, cast(i32)SCREEN_WIDTH, cast(i32)SCREEN_HEIGHT);
	//gl.Enable(gl.TEXTURE_2D);
	gl.Enable(gl.BLEND);  
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);  
	gl.ClearColor(1, 1, 1, 1);
	SDL.GL_SetSwapInterval(0);
	return
}
