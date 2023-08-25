package vacuostellas

daIterate :: proc(array: [dynamic]$T , func: proc(T, i32)) {
	//iterate over a dynamic array with the function func
	if (func == nil) {
		return
	}

	for i:int=0; i < len(array); i+=1 {
		func(array[i], cast(i32)i)
	}
}