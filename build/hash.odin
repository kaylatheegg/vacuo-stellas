package vacuostellas

hash :: proc(input: []u8, max: u32) -> u32 {
	hash : u32 = 0
	for element in input {
		hash ~= hash * 61 + cast(u32)element * 89;
	}
	hash %= max;
	return hash;
}//generates a hash for a variable length input