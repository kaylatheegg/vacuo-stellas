package vacuostellas

import "core:os"
import "core:fmt"
import gl "vendor:OpenGL"

shader_type :: enum {
	VERTEX_SHADER,
	FRAGMENT_SHADER,
}

shader :: struct {
	type: shader_type,
	text: []u8,
	id:   u32,	 
}

program :: struct {
	fragment_path:  string,
	vertex_path:    string,
	name: 		    string,
	VAO: 		    u32,
	VBO: 		    u32,
	EBO: 		    u32,
	fragment: 	    shader,
	vertex: 	    shader,
	program: 	    u32,
	renderCallback: proc(this: ^program)
}

loadProgram :: proc(fragment_path, vertex_path, name: string, callback: proc(this: ^program)) {
	if (resGetResourceIndex(program) == -1) {
		addResource(program)
	}
	intProgram : program
	intProgram.fragment = loadShader(fragment_path, .FRAGMENT_SHADER)
	intProgram.vertex = loadShader(vertex_path, .VERTEX_SHADER)
	intProgram.name = name
	intProgram.renderCallback = callback

	intProgram.program = gl.CreateProgram()
	gl.AttachShader(intProgram.program, intProgram.vertex.id)
	gl.AttachShader(intProgram.program, intProgram.fragment.id)
	gl.LinkProgram(intProgram.program)

	success : int
	info_log : [512]u8

	gl.GetProgramiv(intProgram.program, gl.LINK_STATUS, cast([^]i32)&success)
	if (success != 1) {
		gl.GetProgramInfoLog(intProgram.program, 512, nil, cast([^]u8)&info_log)
		//do the \n hack for removing new lines
		log("Program compilation error!", .ERR, "Render")
		log(transmute(string)info_log[:], .ERR, "Render")
		return
	}

	gl.UseProgram(intProgram.program);

	gl.GenVertexArrays(1, &intProgram.VAO); 
	gl.BindVertexArray(intProgram.VAO);

	gl.GenBuffers(1, &intProgram.VBO);

	gl.BindBuffer(gl.ARRAY_BUFFER, intProgram.VBO); 
	
	gl.GenBuffers(1, &intProgram.EBO);

	resAddElement(program, intProgram.name, intProgram)
}



loadShader :: proc(filename: string, type: shader_type) -> (intShader: shader) {
	if (resGetResourceIndex(shader) == -1) {
		//init shader resource
		addResource(shader)
	}

	shadertext, err := os.read_entire_file(filename)
	if (!err) {
		log("Could not open file \"%s\"!", .ERR, "Render", filename)
		return
	}

	shader_id : u32 = 0

	#partial switch type {
		case .FRAGMENT_SHADER:
			shader_id = gl.CreateShader(gl.FRAGMENT_SHADER)
		case .VERTEX_SHADER:
			shader_id = gl.CreateShader(gl.VERTEX_SHADER)
	}

	length := cast(i32)len(shadertext)
	shader_data_cstring := cstring(raw_data(shadertext))

	gl.ShaderSource(shader_id, 1, &shader_data_cstring, &length)
	gl.CompileShader(shader_id)

	success : int
	info_log : [512]u8

	gl.GetShaderiv(shader_id, gl.COMPILE_STATUS, cast([^]i32)&success)
	if (success != 1) {
		gl.GetShaderInfoLog(shader_id, 512, nil, cast([^]u8)&info_log)
		//do the \n hack for removing new lines
		log("%v compilation error!", .ERR, "Render", type)
		log(transmute(string)info_log[:], .ERR, "Render")
		return
	}

	intShader.type = type
	intShader.text = shadertext
	intShader.id = shader_id
	return
}

/*	glGetShaderiv(fragmentShaderID, GL_COMPILE_STATUS, &success);
	if (success != GL_TRUE) {
		glGetShaderInfoLog(fragmentShaderID, 512, NULL, infoLog);
		*(strchr(infoLog, '\n')) = ' '; //removes the newline opengl shoves in
		logtofile("Fragment shader compilation error!", ERR, "Render");
		logtofile(infoLog, ERR, "Render");
		printf("%s\n", intProgram->fragmentPath);
		return -1;
	}*/


/*loadShaderData :: proc(shadertext: []u8) -> (intShader: shader) {
	
	intShader.text = make([^]cstring, 1)
	intShader.line_count = 0;
	for i := 0; i < len(shadertext); i+=1 {
		if shadertext[i] == '\n' {
			append_elem(&intShader.text[intShader.line_count], 0)
			intShader.line_count += 1
		}
		append_elem(&intShader.text[intShader.line_count], shadertext[i]) 
	}
	return;
}*/

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