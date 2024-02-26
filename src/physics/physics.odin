package vacuostellas

import "core:slice"
import "core:fmt"
import "core:math"
/*
	this physics engine is based on the course Physically Based Modeling: Principles and Practice,
	by David Baraff. link is https://www.cs.cmu.edu/~baraff/sigcourse/ , but im probably gonna
	download it to prevent linkrot destroying how this engine works at a higher level.
 */

vsPCheckCollision :: proc(a, b: vsCollider) -> ([]vec2f, bool) {
	return ([]vec2f){}, false
}

body_sort_proc :: proc(a,b: vsBody) -> bool {
	if a.position.x < b.position.x {
		return true
	}
	return false
}

collidedBodies: [dynamic][2]vsBody

vsPAABBCollision :: proc(a, b: vsBody) -> bool {
	//extract two bbs with modified positions
	//this formula assumes x,y at top left. we need to transform from body-space to world-space
	bbA : vs_rectf32;
	bbA.x = a.position.x + a.collider.bb.x - a.collider.bb.w/2
	bbA.w = a.collider.bb.w
	bbA.y = a.position.y - a.collider.bb.y + a.collider.bb.h/2
	bbA.h = a.collider.bb.h

	bbB : vs_rectf32;
	bbB.x = b.position.x + b.collider.bb.x - b.collider.bb.w/2
	bbB.w = b.collider.bb.w
	bbB.y = b.position.y - b.collider.bb.y + b.collider.bb.h/2
	bbB.h = b.collider.bb.h

	if bbA.x < bbB.x + bbB.w &&
	   bbA.x + bbA.w > bbB.x &&
	   bbA.y < bbB.y + bbB.h &&
	   bbA.y + bbA.h > bbB.y {
	   	return true
	}
	return false
}

vsPIterate :: proc() {
	//first, we numerically integrate to find all new entity positions and rotations.
	vsPSimulate()

	vsPBroadPhase()
	vsPNarrowResolvePhase()
}

vsPDeterminePenetration :: proc(bodyA, bodyB: vsBody) -> vec2f {
	a1x := bodyA.position.x + bodyA.collider.bb.x - bodyA.collider.bb.w/2
	a2x := bodyA.position.x + bodyA.collider.bb.x + bodyA.collider.bb.w/2
	b1x := bodyB.position.x + bodyB.collider.bb.x - bodyB.collider.bb.w/2
	b2x := bodyB.position.x + bodyB.collider.bb.x + bodyB.collider.bb.w/2
	penetration := (vec2f){0,0}
	if (a1x > b1x) {
		penetration.x = b2x - a1x
	} else {
		penetration.x = a2x - b1x
	}

	a1y := bodyA.position.y + bodyA.collider.bb.y - bodyA.collider.bb.h/2
	a2y := bodyA.position.y + bodyA.collider.bb.y + bodyA.collider.bb.h/2
	b1y := bodyB.position.y + bodyB.collider.bb.y - bodyB.collider.bb.h/2
	b2y := bodyB.position.y + bodyB.collider.bb.y + bodyB.collider.bb.h/2
	if (a1y > b1y) {
		penetration.y = b2y - a1y
	} else {
		penetration.y = a2y - b1y
	}
	return penetration
}

vsPCalculateCollisionNormal :: proc(a, b: vsBody, penetration: vec2f) -> vec2f {
	centerA := a.position
	centerB := b.position
	if centerA.x <= centerB.x && centerA.y <= centerB.y {
		if (penetration.x > penetration.y) { return (vec2f){0, -1}}
		if (penetration.y > penetration.x) { return (vec2f){-1, 0}}
		if (penetration.x == penetration.y){ return (vec2f){-1, -1}}
	} else if centerA.x >= centerB.x && centerA.y <= centerB.y {
		if (penetration.x > penetration.y) { return (vec2f){0, -1}}
		if (penetration.y > penetration.x) { return (vec2f){1, 0}}
		if (penetration.x == penetration.y){ return (vec2f){1, -1}}
	} else if centerA.x <= centerB.x && centerA.y >= centerB.y {
		if (penetration.x > penetration.y) { return (vec2f){0, 1}}
		if (penetration.y > penetration.x) { return (vec2f){-1, 0}}
		if (penetration.x == penetration.y){ return (vec2f){-1, 1}}
	} else { //bottom left case
		if (penetration.x > penetration.y) { return (vec2f){0, 1}}
		if (penetration.y > penetration.x) { return (vec2f){1, 0}}
		if (penetration.x == penetration.y){ return (vec2f){1, 1}}
	}
	return (vec2f){0,0}
}

vsPNarrowResolvePhase :: proc() {
	for _, index in collidedBodies {
		value : [2]^vsBody
		value[0] = collidedBodies[index][0].entity_ref.body_ptr
		value[1] = collidedBodies[index][1].entity_ref.body_ptr
		//extract the bodies, then ensure they are AABBs
		if (value[0].collider.type == .BOUNDING_BOX &&
		    value[1].collider.type == .BOUNDING_BOX) {

		   	//determine a collision has actually occured
		   	if vsPAABBCollision(value[0]^, value[1]^) == false { continue }

		   	//fmt.printf("WE COLLIDING MFS\n");

		   	//determine if either body is dynamic. if body 1 is static, and 0 is dynamic, swap them.
		   	if (value[1].locked == true) {
		   		//we swap the bodies.
		   		tempBody := value[0]
		   		value[0] = value[1]
		   		value[1] = tempBody
		   	}

		   	if value[0].locked == true {
		   		//single static in slot 0. we can now handle this
		   		//determine penetration time, then we work back in time to
		   		//un-penetrate the objects.
		   		
		   		penetration := vsPDeterminePenetration(value[0]^, value[1]^)
		   		//determine minimum penetration time
		   		
		   		delta_x : f32 = 9999999999;
		   		delta_y : f32 = 9999999999;

		   		if (value[1].trans_velocity.x != 0 && value[1].trans_velocity.y != 0) {
		   			delta_x = (penetration.x - value[1].position.x)/value[1].trans_velocity.x
		   			delta_y = (penetration.y - value[1].position.y)/value[1].trans_velocity.y
		   		} else if (value[1].trans_velocity.y == 0 && value[1].trans_velocity.x != 0) {
		   			delta_x = (penetration.x - value[1].position.x)/value[1].trans_velocity.x
		   		} else if (value[1].trans_velocity.x == 0 && value[1].trans_velocity.y != 0) { 
		   			delta_y = (penetration.y - value[1].position.y)/value[1].trans_velocity.y
		   		} else { //in the case of player controllers, velocities can be 0 for a dynamic object. we go to the fallback
		   			delta_x = 0;
		   			delta_y = 0;
		   		}

		   		fmt.printf("determined penetration: {}\n", penetration)
		   		fmt.printf("deltas: [{}, {}]\n", delta_x, delta_y)

		   		normal := vsPCalculateCollisionNormal(value[0]^, value[1]^, penetration)
		   		penetration *= -1
		   		fmt.printf("generated normal: {}\n", normal)
		   		fmt.printf("applied anti-penetration: {}\n", vec2fHadamardProduct(penetration, normal))
		   		fmt.printf("\n")
		   		//we now backwards-simulate

		   		value[1].position += vec2fHadamardProduct(penetration, normal)


		   	} else {
		   		//two dynamics. we handle this seperately
		   	}
		}
		vsPSyncBody(value[0]^)
		vsPSyncBody(value[1]^)
	}
}

vsPSyncBody :: proc(body: vsBody) {
	//syncs a body with its entity
	if body.entity_ref == nil { return }
	body.entity_ref.object.x = body.position.x;
	body.entity_ref.object.y = body.position.y;
	body.entity_ref.object.angle = body.rotation;
	objUpdate(body.entity_ref.object);
}

vsPdtAccumulator : f32 = 0

vsPSimulate :: proc() {
	if resGetResourceIndex(vsBody) == -1 { return; }
	bodies_resource := getResource(vsBody)
	for body_ptr in bodies_resource.elements {
		body := cast(^vsBody)body_ptr.value;
		//we use delta time in sec to integrate the objects
		//we start with rotations
		actualDt := deltaTime
		if (deltaTime > 1./cast(f32)targetFPS) {
			//we need to cap deltaTime at 1/targetFPS
			actualDt = 1./cast(f32)targetFPS
		}
		body.angular_velocity += body.angular_acceleration * actualDt;
		body.rotation += body.angular_velocity * actualDt;
		body.trans_velocity += body.trans_acceleration * actualDt;
		body.position += body.trans_velocity * actualDt;
		vsPSyncBody(body^)
	}
}

vsPBroadPhase :: proc() -> [][2]vsBody {
	clear(&collidedBodies)

	if resGetResourceIndex(vsBody) == -1 {
		return ([][2]vsBody){}
	}

	bodies_resource := getResource(vsBody)
	bodies: [dynamic]vsBody
	defer clear(&bodies)


	for body_ptr in bodies_resource.elements {
		body := (cast(^vsBody)body_ptr.value)^
		append(&bodies, body)
	}

	//this is sweep and prune/purge for the broad phase
	//narrow phase is gonna suck but w/e

	slice.sort_by(bodies[:], body_sort_proc) //sort by x value
	active_intervals: [dynamic]vsBody
	defer clear(&active_intervals)


	append(&active_intervals, bodies[0])

	for _, index in bodies {
		bodyB := bodies[index + 1]
		if bodyB.collider.type == .NONE {
			continue
		}

		for i:=0; i < len(active_intervals); i+=1 {
			active_bbA := active_intervals[i].collider.bb
			active_bbB := bodyB.collider.bb
			
			active_bbA.x += active_intervals[i].position.x
			active_bbA.y += active_intervals[i].position.y
			active_bbB.x += bodyB.position.x
			active_bbB.y += bodyB.position.y
			
			if active_bbB.x > (active_bbA.w + active_bbA.x) {
				unordered_remove(&active_intervals, i)
				i = 0
				continue
			} 
		}

		for bodyA in active_intervals {
			if bodyA.id == bodyB.id || (bodyA.locked && bodyB.locked) { continue }

			//determine intervals a and b
			b1 := bodyA.position.x + bodyA.collider.bb.x - bodyA.collider.bb.w/2
			b2 := bodyA.position.x + bodyA.collider.bb.x + bodyA.collider.bb.w/2
			a1 := bodyB.position.x + bodyB.collider.bb.x - bodyB.collider.bb.w/2
			a2 := bodyB.position.x + bodyB.collider.bb.x + bodyB.collider.bb.w/2
		
			if (a1 - b2) <= 0 && (b1 - a2) <= 0 {
				//fmt.printf("a1: {}, a2: {}, b1: {}, b2: {}\n", a1, a2, b1, b2);
				//fmt.printf("collision between body {} and {}\n", bodyA.entity_ref.object.name, bodyB.entity_ref.object.name)
				append(&collidedBodies, ([2]vsBody){bodyA, bodyB})
			}
		}
		append(&active_intervals, bodyB)

	}

	return collidedBodies[:]
}