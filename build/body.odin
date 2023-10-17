package vacuostellas

import "core:fmt"
import "core:slice"

vsBody :: struct {
	mass: f32,
	inv_mass: f32,
	position: vec2f,
	trans_velocity: vec2f,
	trans_acceleration: vec2f,
	angular_velocity: f32,
	angular_acceleration: f32,
	collider: vsCollider,
	entity_ref: ^entity
}

vsc_type :: enum {
	NONE,
	BOUNDING_BOX,
	POLYGON,
	CIRCLE,
}

vsCollider :: struct {
	type: vsc_type,
	bb: vs_rectf32,
	points: [dynamic]vec2f,
	radius: f32,
}

vsPBodyNew :: proc(mass: f32, position, velocity, acceleration: vec2f, angular_velocity, angular_acceleration: f32, collider: vsCollider, entity_ref: ^entity) -> vsBody {
	if resGetResourceIndex(vsBody) == -1 {
		addResource(vsBody)
	}

	int_body := (vsBody){mass, 1/mass, position, velocity, acceleration, angular_velocity, angular_acceleration, collider, entity_ref}
	#partial switch int_body.collider.type {
		case .CIRCLE:
			int_body.collider.bb = vsPCircleToBB(int_body)
		case .POLYGON: 
			int_body.collider.bb = vsPPolyToBB(int_body)
	}
	body_uuid := fmt.aprintf("Body-{}", uID())
	resAddElement(vsBody, body_uuid, int_body)
	return int_body
}

vsPCCircleNew :: proc(value: f32) -> vsCollider {
	if resGetResourceIndex(vsCollider) == -1 {
		addResource(vsCollider)
	}

	int_collider: vsCollider
	int_collider = (vsCollider){type = .CIRCLE, radius = value}

	body_uuid := fmt.aprintf("Collider-{}", uID())
	resAddElement(vsCollider, body_uuid, int_collider)
	return int_collider
}

vsPCBBNew :: proc(value: vs_rectf32) -> vsCollider {
	if resGetResourceIndex(vsCollider) == -1 {
		addResource(vsCollider)
	}

	int_collider: vsCollider
	int_collider = (vsCollider){type = .BOUNDING_BOX, bb = value}

	body_uuid := fmt.aprintf("Collider-{}", uID())
	resAddElement(vsCollider, body_uuid, int_collider)
	return int_collider
}

vsPCPolyNew :: proc(value: []vec2f) -> vsCollider { //TODO: check for convexity
	if resGetResourceIndex(vsCollider) == -1 {
		addResource(vsCollider)
	}

	int_collider: vsCollider
	int_collider.type = .POLYGON
	append(&int_collider.points, ..value[:])

	body_uuid := fmt.aprintf("Collider-{}", uID())
	resAddElement(vsCollider, body_uuid, int_collider)
	return int_collider
}

hull_sort_x_proc :: proc(a, b: vec2f) -> bool {
	if a.x < b.x {
		return true
	}
	return false
}

hull_sort_y_proc :: proc(a, b: vec2f) -> bool {
	if a.y < b.y {
		return true
	}
	return false
}

vsPPolyToBB :: proc(body: vsBody) -> vs_rectf32 {
	//find center of polygon
	sum_point : vec2f

	for vertex in body.collider.points {
		sum_point += vertex
	}

	sum_point /= cast(f32)len(body.collider.points) //this is wrong.

	//use jarvis march algorithm, from https://iq.opengenus.org/gift-wrap-jarvis-march-algorithm-convex-hull/

	convex_hull: [dynamic]vec2f

	//find left most point in convex set
	left_most_point := body.collider.points[0]
	p_index := 0
	for point, index in body.collider.points {
		if point.x < left_most_point.x {
			left_most_point = point
			p_index = index
		}
	}

	append(&convex_hull, left_most_point)

	for i:=0; body.collider.points[i] != left_most_point; i+=1 {
		//find iteratively 3 points, p, x, r, that satisfy:
		//p, x, r are CCW for all x in points
		q_index := (p_index + 1) % len(body.collider.points)
		
		for test_point, index in body.collider.points {
			if vsOrientation(body.collider.points[p_index], test_point, body.collider.points[q_index]) == .COUNTER_CLOCKWISE {
				q_index = index
			}
		}
		append(&convex_hull, body.collider.points[q_index])
		p_index = q_index
	} 

	//calculated convex hull, now sort by x then y to determine the dimensions of the box
	slice.sort_by(convex_hull[:], hull_sort_x_proc)
	width := abs(convex_hull[0].x - convex_hull[len(convex_hull)].x)

	slice.sort_by(convex_hull[:], hull_sort_y_proc)
	height := abs(convex_hull[0].y - convex_hull[len(convex_hull)].y)

	clear(&convex_hull)

	return (vs_rectf32){sum_point.x, sum_point.y, width, height}
}

vsPCircleToBB :: proc(body: vsBody) -> vs_rectf32 {
	position := body.position
	radius := body.collider.radius
	return (vs_rectf32){radius, -radius, radius * 2, radius * 2} //relative to body
}