package vacuostellas

registry :: distinct resource
registries : [dynamic]registry

addRegistry :: proc($type: typeid) {
	append(&registries, registry{type, new([dynamic]res_entry)^})
}

regGetRegistryIndex :: proc($type: typeid) -> int {
	for i := 0; i < len(registries); i += 1 {
		if (registries[i].type == type) {
			return i;
		}
	}
	return -1;
}

regPrintElement :: proc($type: typeid, key: string) {
	regIndex := regGetRegistryIndex(type)
	if (regIndex == -1) {
		log("Cannot find registry: %v", .ERR, "Registries", typeid_of(type));
		return;
	}

	intRegistry := registries[regIndex]
	for i := 0; i < len(intRegistry.elements); i += 1 {
		if intRegistry.elements[i].key == key {
			log("%v: {}", .INF, "Registries", typeid_of(type), (cast(^type)intRegistry.elements[i].value)^);
			return
		}
	}
	//didnt find element
	log("Could not find key \"%s\" in registry %v", .ERR, "Registries", key, typeid_of(type))
}

regGetElement :: proc($type: typeid, key: string) -> (value: type) {
	regIndex := regGetRegistryIndex(type)
	if (regIndex == -1) {
		log("Cannot find registry: %v", .ERR, "Registries", typeid_of(type));
		return;
	}
	for i := 0; i < len(registries[regIndex].elements); i+=1 {
		if registries[regIndex].elements[i].key == key {
			return (cast(^type)registries[regIndex].elements[i].value)^
		}
	}
	return;
}

regGetElementPointer :: proc($type: typeid, key: string) -> (value: ^type) {
	regIndex := regGetRegistryIndex(type)
	if (regIndex == -1) {
		//log("Cannot find registry: %v to get element pointer", .ERR, "Registries", typeid_of(type));
		return;
	}

	for i := 0; i < len(registries[regIndex].elements); i+=1 {
		if registries[regIndex].elements[i].key == key {
			return cast(^type)registries[regIndex].elements[i].value
		}
	}

	return;
}

regAddElement :: proc($type: typeid, key: string, value: $T) {
	value := value
	regIndex := regGetRegistryIndex(type)
	if (regIndex == -1) {
		log("Cannot find registry: %v to add element", .ERR, "Registries", typeid_of(type));
		return;
	}

	for i := 0; i < len(registries[regIndex].elements); i+=1 {
		if registries[regIndex].elements[i].key == key {
			log("Cannot add duplicate key \"%s\" to registry %v!", .ERR, "Registries", key, typeid_of(type))
			return
		}
	}

	value_copy := new(type) //leaky
	value_copy^ = cast(type)value
	append(&registries[regIndex].elements, res_entry{key, value_copy})
	//append(&resources[resIndex].elements, res_entry{key, value})
}

regRemoveElement :: proc($type: typeid, key: string) {
	regIndex := regGetRegistryIndex(type)
	if (regIndex == -1) {
		log("Cannot find registry: %v", .ERR, "Registries", typeid_of(type));
		return;
	}

	for i := 0; i < len(registries[regIndex].elements); i+=1 {
		if registries[regIndex].elements[i].key == key {
			//free(resources[resIndex].elements[i].value)
			unordered_remove(&registries[regIndex].elements, i)
			return
		}
	}

	log("Could not find key \"%s\" in registry %v", .ERR, "Registries", key, typeid_of(type))
}

getRegistry :: proc($type: typeid) -> registry {
	regIndex := regGetRegistryIndex(type)
	if (regIndex == -1) {
		log("Cannot find registry: %v", .ERR, "Registries", typeid_of(type));
		return registries[0];
	}
	return registries[regIndex]
}

destroyRegistry :: proc($type: typeid) {
	regIndex := regGetRegistryIndex(type)
	if (regIndex == -1) {
		log("Cannot find registry: %v", .ERR, "Registries", typeid_of(type));
		return;
	}

	intRegistry := registries[regIndex]
	for i := 0; i < len(intRegistry.elements); i+=1 {
		unordered_remove(&registries[regIndex].elements, i)
	}

	unordered_remove(&registries, regIndex)
}
