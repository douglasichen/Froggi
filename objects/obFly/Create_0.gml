//print(asset_add_tags(obFly, "frogEdible", asset_object))
tag = "frogEdible"

captured = {
	bool : false,
	offset : new vector(0,0),
}

// pick random fly 
var flySprites = [
	sBug1,
	sBug2,
	sBug3,
	sBug4,
	sBug5
]
var scale = 1.2
image_xscale = scale
image_yscale = scale
sprite_index = flySprites[irandom_range(0, array_length(flySprites) - 1)]

// variables
wander = {
	direction : vector_random(1),
	speed : 3,
	velocity : new vector(0,0),
	pause : true,
	intervalTimeRange : {
		min : 20,
		max : 140,
	},
	intervalTime : 20
}
