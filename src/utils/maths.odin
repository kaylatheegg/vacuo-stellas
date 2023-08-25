package vacuostellas

//maps interval [a,b] onto [A,B], with parameterisation value
//deriving this is annoying but i'll put a sparknotes ver here
//we map [a,b] to [0, 1], and then map that to [A, B]

PI :: 3.1415926535
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