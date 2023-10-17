package vacuostellas

import "core:slice"
import "core:fmt"

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
			if transmute([size_of(vsBody)]u8)bodyA == transmute([size_of(vsBody)]u8)bodyB { //i hate this
				continue
			}
			//determine intervals a and b
			b1 := bodyA.collider.bb.x
			b2 := b1 + bodyA.collider.bb.w
			a1 := bodyB.collider.bb.x
			a2 := a1 + bodyB.collider.bb.w
		
			if (a1 - b2) <= 0 && (b1 - a2) <= 0 {
				fmt.printf("collision between body {} and {}\n", bodyA.collider.bb, bodyB.collider.bb)
				append(&collidedBodies, ([2]vsBody){bodyA, bodyB})
			}
		}
		append(&active_intervals, bodyB)

	}

	return collidedBodies[:]
}