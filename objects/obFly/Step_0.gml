if !captured.bool {
	if wander.intervalTime == 0 {
		if wander.pause {
			wander.pause = false
			wander.direction = vector_random(1)
		}
		else {
			wander.pause = true
		}
		wander.intervalTime = irandom_range(wander.intervalTimeRange.min, wander.intervalTimeRange.max)
	}
	else {
		wander.intervalTime--
	}
	
	wander.velocity = wander.direction.multiplied(wander.speed)
	if wander.pause {
		wander.velocity = new vector(0,0)
	}
	var goal = new vector(x + wander.velocity.x, y + wander.velocity.y)
	if goal.x <= 0 or goal.x >= room_width {
		wander.direction.x *= -1
	}
	if goal.y <= 0 or goal.y >= room_height {
		wander.direction.y *= -1
	}
	
	x += wander.velocity.x
	y += wander.velocity.y
}
