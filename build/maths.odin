package vacuostellas

//maps interval [a,b] onto [A,B], with parameterisation value
//deriving this is annoying but i'll put a sparknotes ver here
//we map [a,b] to [0, 1], and then map that to [A, B]

PI  :: 3.1415926535
E_C :: 2.7182818285
D2R :: PI/180
R2D :: 180/PI


vsmap :: proc(value, a, b, A, B: f32) -> f32 {
	return A + (B-A)/(b-a) * (value - a)
}

vsmapArray :: proc(array: ^[]f32, a, b, A, B:f32) {
	for entry, index in array {
		array[index] = vsmap(array[index], a, b, A, B)
	}
}

vslerp :: proc(w, a, b: f32) -> f32 {
	if w < 0 {
		return a
	}

	if w > 1 {
		return b
	}

	return ((b-a) * w + a)
}

orientation :: enum {
	COLINEAR,
	CLOCKWISE,
	COUNTER_CLOCKWISE,
}

vsOrientation :: proc(a, b, c: vec2f) -> orientation { //outer product, discard the other elements. i dont understand how this works
	orientation := (b.y - a.y) * (c.x - b.x) -
				   (b.x - a.x) * (c.y - b.y)
	
	if orientation == 0 {
		return .COLINEAR
	}
	return (orientation > 0) ? .CLOCKWISE : .COUNTER_CLOCKWISE
}