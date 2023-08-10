package vacuostellas
//custom memory allocation function to get around odin's issues with non-constant runtime typeids.

import "core:intrinsics"

vsnew :: proc(T: typeid, loc:=#caller_location) -> (rawptr) {
	ret_val, err := context.allocator.procedure(context.allocator.data, .Alloc, size_of(T), align_of(T), nil, 0, loc)
	return transmute(rawptr)raw_data(ret_val)
}