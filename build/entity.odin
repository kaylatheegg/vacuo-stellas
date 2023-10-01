package vacuostellas

//basically objects with a callback function. i'll update this to use an ECS later

stubCallback :: proc(this: ^entity, data: rawptr) {
	return
}

entity :: struct {
	object: ^object,
	callback: proc(this: ^entity, data: rawptr), 
	entityID: u32,
	data: rawptr,
}

addEntity :: proc(x, y, w, h: f32, angle: radian, name: string, texture_name: string, callback := stubCallback, data: $T) -> (id: u32) {
	if (resGetResourceIndex(entity) == -1) {
		addResource(entity)
	} 

	entity_id := uID()

	data_alloc := new(type_of(data))
	data_alloc^ = cast(type_of(data))data

	resAddElement(entity, name, (entity){getObjectByID(addObject(x,y,w,h,angle,name,texture_name)), //kinda nasty currying. try to clean this up
										 callback, entity_id, data_alloc})
	return entity_id
}

getEntity :: proc(id: u32) -> ^entity { 
	for entry in (getResource(entity)).elements {
		if (cast(^entity)entry.value).entityID == id {
			return (cast(^entity)entry.value)
		}
	}
	return nil
}

tickEntities :: proc() {
	if (resGetResourceIndex(entity) == -1) {
		//log("Entities not initialised yet!", .ERR, "Entity")
		return
	}

	for entry in (getResource(entity)).elements {
		(cast(^entity)entry.value)->callback((cast(^entity)entry.value).data)
	}
}


//really simple actually. im surprised that this is so much simpler than my C impl