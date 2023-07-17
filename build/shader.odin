package vacuostellas

import "core:os"
import "core:fmt"
import gl "vendor:OpenGL"

shader_type :: enum {
	VERTEX_SHADER,
	FRAGMENT_SHADER,
}

shader :: struct {
	type : 		shader_type,
	text : 		[^]cstring,
	line_count: int,
}

program :: struct {
	fragment_path: string,
	vertex_path:   string,
	VAO: 		   u32,
	VBO: 		   u32,
	EBO: 		   u32,
	fragment: 	   shader,
	vertex: 	   shader,
}

loadProgram :: proc(intProgram: program) {
	if (resGetResourceIndex(program) == -1) {
		addResource(program)
	}

}



loadShader :: proc(filename: string, type: shader_type) {
	if (resGetResourceIndex(shader) == -1) {
		//init shader resource
		addResource(shader)
	}

	shadertext, err := os.read_entire_file(filename)
	if (!err) {
		log("Could not open file \"%s\"!", .ERR, "Render", filename)
		return
	}


}

loadShaderData :: proc(shadertext: []u8) -> (intShader: shader) {
	intShader.text = make([^]cstring)
	intShader.line_count = 0;
	//intShader.text[0]
	return;
}

/*	UNUSED(name);
	int chunkSize = 256;

	shader* intShader = gmalloc(sizeof(*intShader));
	intShader->code = gmalloc(sizeof(intShader->code));
	intShader->code[0] = gmalloc(sizeof(*intShader->code) * chunkSize);
	intShader->lineCount = 0;

	while(fgets(intShader->code[intShader->lineCount], chunkSize, fp) != NULL) {
		intShader->lineCount++;
		intShader->code = grealloc(intShader->code, sizeof(intShader->code) * (intShader->lineCount + 1));
		intShader->code[intShader->lineCount] = gmalloc(sizeof(*intShader->code) * chunkSize);
	}
	//addToDictionary(shaders, name, intShader);
	return intShader;*/