package vacuostellas

//alright so we're gonna do a basic PBD ball system, and then add a shader on top to connect the balls together
//add colour support to it aswell :3

metaBallCallback :: proc(this: ^entity, data: rawptr) {
	ball_data := (cast(^ballData)data)
	int_stack := findStack("metaballs")

	if ball_data.pos.x > SCREEN_WIDTH || ball_data.pos.x < 0 {
		ball_data.vel.x *= -1
	}

	if ball_data.pos.y > SCREEN_HEIGHT || ball_data.pos.y < 0 {
		ball_data.vel.y *= -0.8
	}

	ball_data.pos.x += ball_data.vel.x
	ball_data.pos.y += ball_data.vel.y
	//ball_data.vel.y -= 0.5
 
	(cast(^ballData)int_stack.elements[ball_data.id])^ = (ballData){ball_data.radius, (vec2f){ball_data.pos.x, ball_data.pos.y}, (vec2f){0,0}, ball_data.id}
}

ballData :: struct #packed {
	radius : f32,
	pos: vec2f,
	vel: vec2f,
	id: i32,
}

createBall :: proc(pos: vec2f) {
	if (findStack("metaballs") == nil) {
		addStack(ballData, "metaballs")
		loadProgram("data/shaders/ball.fs", "data/shaders/ball.vs", "Metaball Renderer", metaBallRender)
	}

	int_stack := findStack("metaballs")
 
	//generate a random radius from 16-64, uniformly distributed so the average ball size is 40
	radius : f32 = 32
	data := (ballData){radius, (vec2f){pos.x, pos.y}, (vec2f){vfuRand(-3, 3), vfuRand(-2, 0)}, cast(i32)len(int_stack.elements)}
	
	addEntity(pos.x, pos.y, 0, 0, 0, "Ball", "DEFAULT", metaBallCallback, data)
	pushStack("metaballs", data)

}