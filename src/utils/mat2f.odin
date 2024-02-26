package vacuostellas

//defines various functions that use mat2x2f

import "core:math"


radian :: f32
vec2f  :: [2]f32
vec2i  :: [2]i32
mat2f  :: matrix[2,2]f32
mat4f  :: matrix[4,4]f32

vs_rectf32 :: struct {
	x, y, w, h: f32
}

vs_recti32 :: struct {
	x, y, w, h: i32
}

mat2Rotate :: proc(angle: radian) -> mat2f { //counter clockwise rotation 
	return mat2f {
		math.cos(angle), -math.sin(angle),
		math.sin(angle), math.cos(angle),
	} 
}

vec2RotatePoint :: proc(a: vec2f, origin: vec2f, angle: radian) -> vec2f {
	return origin + mat2Rotate(angle) * (a - origin) 
}

vec2ClipSpace :: proc(a: vec2f) -> vec2f {
	return vec2f {
		vsmap(a.x, 0., cast(f32)SCREEN_WIDTH,   -1., 1.),
		vsmap(a.y, 0., cast(f32)SCREEN_HEIGHT,  -1., 1.),
	}
}

vec2fHadamardProduct :: proc(a,b: vec2f) -> vec2f {
	return (vec2f){a.x * b.x, a.y * b.y}
}

vec2fDot :: proc (a, b: vec2f) -> f32 {
	return a.x * b.x + a.y * b.y
}

mat2Scale :: proc(scale: f32) -> mat2f {
	return mat2f {
		scale, 0,
		0,     scale,
	}
}

mat4frustrum :: proc(left, right, top, bottom, near, far: f32) -> mat4f {
	return mat4f {
		2.0 * near / (right - left), 0, 				           (right + left) / (right - left), 0,
		0, 				   	 		 2.0 * near / (top - bottom),  (top + bottom) / (top - bottom), 0,   
		0, 				     		 0, 				   		  -(far + near)   / (far - near),  -2.0 * far * near / (far - near),
		0, 				    		 0, 				  		  -1, 								0, 						                  
	}
}

mat4PerspectiveProjection :: proc(fovangle, aspectRatio, nearPlane, farPlane: f32) -> mat4f {
	scale := math.tan(fovangle * 0.5 * PI / 180.0) * nearPlane;
	r := aspectRatio * scale;
	l := -r;
	t := scale;
	b := -t;
	return mat4frustrum(l, r, t, b, nearPlane, farPlane);
}

mat4RotateAroundPoint :: proc(angle: f32, origin: vec2f) -> mat4f { //HORRIBLY BROKEN. DO NOT USE.
	sina := math.sin(angle)
	cosa := math.cos(angle)
	x := origin.x 
	y := origin.y
	return mat4f {
		sina, -cosa, 0, (sina*x - cosa*y - x),
		cosa, sina,  0, (cosa*x - sina*y - y),
		0,    0,     1, 0,
		0,    0,     0, 1,
	}
}
