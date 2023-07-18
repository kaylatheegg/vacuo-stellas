package vacuostellas

object :: struct {
	x : int,
	y : int,
	w : int,
	h : int,
	name : string,
}


addObject :: proc(x, y, w, h: int, name: string) {
	if (resGetResourceIndex(object) == -1) {
		addResource(object)
	}

	resAddElement(object, name, cast(^any)&(object){x, y, w, h, name})
}