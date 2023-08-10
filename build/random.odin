package vacuostellas

import "core:math/rand"
import "core:math"

//naming scheme for rands:
//v(T)(style)Rand, where T is the type and style is either uniform or normal or whatever

//alright so the calculation is done by sampling the inverse normal function:
/*
for the range (a,b) distributed normally,

       b+a    b-a ⌠ x    ⎛-t²⎞
F(x) = ⎻⎻⎻  + ⎻⎻⎻ ⎮   exp⎜⎻⎻⎻⎟ dt
		2     √̅2̅π ⌡-∞    ⎝ 2 ⎠

generate a random number from -√̅a to √̅a uniformly to sample

we can use the fact that the above integral is equivalent to
sqrt(pi/2) * erf(t/√̅2) to calculate this slightly easier

we can also approximate the error function as:

         2
erf(x) = ⎻ arctan(2t(1 + t⁴))
         π

this is accurate to within 2%

actual formula used:
       b+a   b-a ⎾2 2      
F(x) = ⎻⎻⎻ + ⎻⎻⎻ ⎮⎻ ⎻arctan(2t(1 + t⁴))
        2    √̅2̅π ⎷π π
*/

//do not trust these to be accurate.

vfnRand :: proc(start, end: f32) -> f32 {
	return inverseNormalDistribution(start, end, vfuRand(-math.sqrt(start), math.sqrt(start)))
}

inverseNormalDistribution :: proc(a, b, t: f32) -> f32 {
	//calculate integral with the error function
	integral := math.sqrt_f32(PI/2) * errorFunction(t/math.sqrt_f32(2))

	return (b+a)/2 + (b-a)/math.sqrt_f32(2 * PI) * integral
}

errorFunction :: proc(t: f32) -> f32 {
	//erf(t) approximated
	return 2/PI * math.atan(2 * t * (1 + math.pow(t, 4)))
}

vfuRand :: proc(start, end: f32) -> f32 {
	//generate a random number from start to end, distributed uniformly
	return rand.float32_range(start, end)
}

viuRand :: proc(start, end: i32) -> i32 {
	return cast(i32)vfuRand(cast(f32)start, cast(f32)end)
}

