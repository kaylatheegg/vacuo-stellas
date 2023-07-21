package vacuostellas

//short lived stack like data structure.
//works on one kind of datatype, like the resources and registries

/*FIFO:
push x | x
push o | x o
pop    | o

FILO:
push x | x
push o | x o
pop    | x*/



stack_type :: enum {
	FIFO, //technically a queue but fuck it.
	FILO,
}

stack :: struct {
	stack_type: stack_type, //auugh this is bad.
	type: typeid,
	elements: [dynamic]rawptr,
}

addStack :: proc ($type: typeid, name: string, s_type := stack_type.FILO) {
	if (resGetResourceIndex(stack) == -1) {
		addResource(stack)
	}

	resAddElement(stack, name, (stack){s_type, type, new([dynamic]rawptr)^})
}

findStack :: proc(name: string) -> ^stack {
	for entry in getResource(stack).elements {
		if entry.key == name {
			return cast(^stack)entry.value
		}
	}

	log("Could not find stack {}", .ERR, "Stack", name)
	return nil
}

popStack :: proc(name: string) -> (stack_value: $T) {
	int_stack := findStack(name)
	
	if int_stack == nil {
		return nil
	}

	if len(int_stack.elements) == 0 {
		return nil
	}

	#partial switch int_stack.stack_type {
		case .FIFO:
			value := int_stack[0]
			unordered_remove(&int_stack.elements, 0)
			return cast(int_stack.type)value
		case .FILO:
			value := int_stack[len(int_stack.elements) - 1]
			unordered_remove(&int_stack.elements, len(int_stack.elements) - 1)
			return cast(int_stack.type)value
	}
}

pushStack :: proc(name: string, value: $T) {
	int_stack := findStack(name)

	if int_stack == nil {
		return 
	}

	if int_stack.type != typeid_of(value) {
		log("Type mismatch in stack {}! Expected type: %v, recieved type: %v", .ERR, "Stack", name, int_stack.type, typeid_of(value))
		return
	}

	#partial switch int_stack.stack_type {
		case .FIFO: fallthrough
		case .FILO:
			int_value = make(typeid_of(value))
			^int_value = value
			append(&int_stack.elements, int_value)
		
	}


}