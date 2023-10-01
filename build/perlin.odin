package vacuostellas

import "core:math"

pNoise :: struct {
	size: u16,
	vecs: [dynamic]vec2f,
}

fNoise :: struct {
	noises: [dynamic]pNoise,
	octaves: u16,
	original_size: u16,
}

//coordinate system in the noise is from 0->1 in x and y, maps to that

pNoiseNew :: proc(size: u16) -> pNoise {
	int_noise : pNoise
	int_noise.size = size
	//generate random vectors
	for i :u32= 0; i < u32(size)*u32(size); i+=1 {
		append(&int_noise.vecs, vVec2fNormRand())
	}
	return int_noise
}

pNoiseGenerate :: proc(x, y: f32, noise: pNoise) -> f32 {
	x := x 
	y := y 
	if x > 1 {
		x = 1
	} else if x < 0 {
		x = 0
	} if y > 1 {
		y = 1
	} else if y < 0 {
		y = 0
	}

	//computing constants

	position := (vec2f){x, y}

	px := vsmap(x, 0, 1, 0, f32(noise.size))
	py := vsmap(y, 0, 1, 0, f32(noise.size))

	bx0 := math.floor(px)
	by0 := math.floor(py)
	bx1 := bx0 + 1
	by1 := by0 + 1 //coordinates for grid cell

	sx := bx0 - px
	sy := by0 - py //interpolation weights

	gradVec0 := noise.vecs[u16(by0) * noise.size + u16(bx0)]
	gradVec1 := noise.vecs[u16(by0) * noise.size + u16(bx1)]
	gradVec2 := noise.vecs[u16(by1) * noise.size + u16(bx0)]
	gradVec3 := noise.vecs[u16(by1) * noise.size + u16(bx1)]

	dot0 := vec2fDot(position - (vec2f){bx0, by0}, gradVec0)
	dot1 := vec2fDot(position - (vec2f){bx1, by0}, gradVec1)
	dot2 := vec2fDot(position - (vec2f){bx0, by1}, gradVec2)
	dot3 := vec2fDot(position - (vec2f){bx1, by1}, gradVec3)

	ix0 := vslerp(sx, dot0, dot1)
	ix1 := vslerp(sx, dot2, dot3)
	return (0.5 * vslerp(sy, ix0, ix1)) + 0.5

}

fNoiseNew :: proc(size, octave: u16) -> fNoise {
	noise : fNoise
	noise.original_size = size 
	noise.octaves = octave 
	
	int_size := size
	for i :u16= 0; i < octave; i+=1 {
		append(&noise.noises, pNoiseNew(int_size))
		int_size *= 2
	}	

	return noise
}

fNoiseGenerate :: proc(x, y: f32, noise: fNoise) -> f32 {
	sum: f32 = 0
	scale: f32 = 1
	for i :u16= 0; i < noise.octaves; i+=1 {
		sum += pNoiseGenerate(x, y, noise.noises[i]) * scale
		scale /= 2
	}
	return sum
}

/*

0--1
|  |
|  |
2--3

interpolate between 0,1 -> 4 (x)
interpolate between 2,3 -> 5 (x)
interpolate between 4,5 -> value (y)


*/
