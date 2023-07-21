package vacuostellas

import "core:runtime"
import "core:fmt"

//handles resources that are commonly used (images, sounds, functions, components, e.t.c)
//a resource is a pool that can have shared key names,
//while a registry is a pool that has to have unique key names.

res_entry :: struct {
	key: string,
	value: rawptr,
}

resource :: struct {
	type: typeid,
	elements: [dynamic]res_entry,
}

resources : [dynamic]resource 

addResource :: proc($type: typeid) -> int {
	//need to check for duplicates here
	append(&resources, resource{type, new([dynamic]res_entry)^})
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
			log("%v: {}", .INF, "Resources", typeid_of(type), (cast(^type)intResource.elements[i].value)^);
			return
		}
	}
	//didnt find element
	log("Could not find key \"%s\" in resource %v", .ERR, "Resources", key, typeid_of(type))
}

resGetElement :: proc($type: typeid, key: string) -> (value: type) {
	resIndex := resGetResourceIndex(type)
	if (resIndex == -1) {
		log("Cannot find resource: %v", .ERR, "Resources", typeid_of(type));
		return;
	}

	for i := 0; i < len(resources[resIndex].elements); i+=1 {
		if resources[resIndex].elements[i].key == key {
			return (cast(^type)resources[resIndex].elements[i].value)^
		}
	}

	assert(1==0, "THIS IS UNREACHABLE!")
	return;
}

resGetElementByID :: proc($type: typeid, id: u32) -> (value: type) {
	assert(1==0, "implement this!")
	resIndex := resGetResourceIndex(type)
	if (resIndex == -1) {
		log("Cannot find resource: %v", .ERR, "Resources", typeid_of(type));
		return;
	}
	return
} //stub, reimpl

resAddElement :: proc($type: typeid, key: string, value: $T) {
	value := value
	resIndex := resGetResourceIndex(type)
	if (resIndex == -1) {
		log("Cannot find resource: %v", .ERR, "Resources", typeid_of(type));
		return;
	}

	value_copy := new(type) //leaky
	value_copy^ = cast(type)value
	append(&resources[resIndex].elements, res_entry{key, value_copy})
	//append(&resources[resIndex].elements, res_entry{key, value})
}

resRemoveElement :: proc($type: typeid, key: string) {
	resIndex := resGetResourceIndex(type)
	if (resIndex == -1) {
		log("Cannot find resource: %v", .ERR, "Resources", typeid_of(type));
		return;
	}

	for i := 0; i < len(resources[resIndex].elements); i+=1 {
		if resources[resIndex].elements[i].key == key {
			//free(resources[resIndex].elements[i].value)
			unordered_remove(&resources[resIndex].elements, i)
			return
		}
	}

	log("Could not find key \"%s\" in resource %v", .ERR, "Resources", key, typeid_of(type))
}

getResource :: proc($type: typeid) -> resource {
	resIndex := resGetResourceIndex(type)
	if (resIndex == -1) {
		log("Cannot find resource: %v", .ERR, "Resources", typeid_of(type));
		return resources[0];
	}
	return resources[resIndex]
}

destroyResource :: proc($type: typeid) {
	resIndex := resGetResourceIndex(type)
	if (resIndex == -1) {
		log("Cannot find resource: %v", .ERR, "Resources", typeid_of(type));
		return;
	}

	intResource := resources[resIndex]
	for i := 0; i < len(intResource.elements); i+=1 {
		unordered_remove(&resources[resIndex].elements, i)
	}

	unordered_remove(&resources, resIndex)
}




/*example usage below
addResource(i32)
resAddElement(i32, "factorial of 5", 120)
resAddElement(i32, "pi to 4 digits", 3141)
resPrintElement(i32, "factorial of 5")
resRemoveElement(i32, "pi to 4 digits")
destroyResource(i32)


*/