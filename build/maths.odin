package vacuostellas

//maps interval [a,b] onto [A,B], with parameterisation value
//deriving this is annoying but i'll put a sparknotes ver here
//we map [a,b] to [0, 1], and then map that to [A, B]

vsmap :: proc(value, a, b, A, B: f32) -> f32 {
	return A + (B-A)/(b-a) * (value - a)
}