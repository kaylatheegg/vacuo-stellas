package vacuostellas

import "core:runtime"

//handles resources that are commonly used (images, sounds, functions, components, e.t.c)

res_entry :: struct {
	key: string,
	value: ^any,
}

resource :: struct {
	type: typeid,
	elements: [dynamic]res_entry,
}

resources : [dynamic]resource 

addResource :: proc($type: typeid) -> int {
	append(&resources, resource{type, nil})
	return 0
}

resGetResourceIndex :: proc($type: typeid) -> int {
	for i := 0; i < len(resources); i += 1 {
		if (resources[i].type == type) {
			return i;
		}
	}
	return -1;
}

resPrintElement :: proc($type: typeid, key: string) {
	resIndex := resGetResourceIndex(type)
	if (resIndex == -1) {
		log("Cannot find resource: %v", .ERR, "Resources", typeid_of(type));
		return;
	}

	intResource := resources[resIndex]
	for i := 0; i < len(intResource.elements); i += 1 {
		if intResource.elements[i].key == key {
			log("%v: {}", .INF, "Resources", typeid_of(type), intResource.elements[i].value);
			return
		}
	}
	//didnt find element
	log("Could not find key \"%s\" in resource %v", .ERR, "Resources", key, typeid_of(type))
}

resAddElement :: proc($type: typeid, key: string, value: ^any) {
	resIndex := resGetResourceIndex(type)
	if (resIndex == -1) {
		log("Cannot find resource: %v", .ERR, "Resources", typeid_of(type));
		return;
	}

	for i := 0; i < len(resources[resIndex].elements); i+=1 {
		if resources[resIndex].elements[i].key == key {
			//log("Cannot add duplicate key \"%s\" to resource %v!", .ERR, "Resources", key, typeid_of(type))
			//return
		}
	}

	value_copy := new(type_of(value))
	runtime.mem_copy(value_copy, value, size_of(type_of(value)))
	append(&resources[resIndex].elements, res_entry{key, value_copy^})
}

resRemoveElement :: proc($type: typeid, key: string) {
	resIndex := resGetResourceIndex(type)
	if (resIndex == -1) {
		log("Cannot find resource: %v", .ERR, "Resources", typeid_of(type));
		return;
	}

	for i := 0; i < len(resources[resIndex].elements); i+=1 {
		if resources[resIndex].elements[i].key == key {
			delete(resources[resIndex].elements.value)
			unordered_remove(&resources[resIndex].elements, i)
			return
		}
	}

	log("Could not find key \"%s\" in resource %v", .ERR, "Resources", key, typeid_of(type))
}

destroyResource :: proc($type: typeid) {
	resIndex := resGetResourceIndex(type)
	if (resIndex == -1) {
		log("Cannot find resource: %v", .ERR, "Resources", typeid_of(type));
		return;
	}

	intResource := resources[resIndex]
	for i := 0; i < len(intResource.elements); i+=1 {
		unordered_remove(&resources[resIndex.elements], i)
	}

	delete(intResource)
}