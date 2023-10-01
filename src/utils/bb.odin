package vacuostellas

pointInBB :: proc(bb: vs_rectf32, point: vec2f) -> bool {
	if bb.x <= point.x && point.x <= (bb.x + bb.w) &&
	   bb.y <= point.y && point.y <= (bb.y + bb.h) {
	   	return true
	} 
	return false
}
