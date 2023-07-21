package vacuostellas

//defines various functions that use mat2x2f

import "core:math"

vec2f :: [2]f32
vec2i :: [2]i32
mat2f :: matrix[2,2]f32


mat2Rotate :: proc(angle: radian) -> mat2f { //counter clockwise rotation 
	return mat2f {
		math.cos(angle), -math.sin(angle),
		math.sin(angle), math.cos(angle),
	} 
}

vec2RotatePoint :: proc(a: vec2f, origin: vec2f, angle: radian) -> vec2f {
	return origin + mat2Rotate(angle) * (a - origin) 
}
