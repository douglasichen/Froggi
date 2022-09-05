function entity(_obj) constructor {
	tag = ""
	obj = _obj
	gravity = 1.1
	friction = 0.3
	initialImageSpeed = obj.image_speed
	velocity = new vector(0,0)
	damageColors = [c_red, c_white]
	damageSound = soDamage1
	rotation = 0
	collide = true
	collideWith = ds_map_create()
	
	pause = false
	
	ds_map_add(collideWith, obCollide, true)
	//ds_map_add(collideWith, obOneWayCollide, false)
	with obOneWayCollide {
		ds_map_add(other.collideWith, id, false)
	}
	gravityEnabled = true
	life = {
		health : 3,
		initialHealth : 0,
		alive : true,
		deathRoll : {
			rollSpeed : 20,
			deathRotation : 90,
			rollDirection : 1,
		},
		fadeAway : false,
		fadeAwaySpeed : 0.01,
		damageStart : false,
		damageParam : {
			direction : 0,
			force : 0,
			damage : 0,
		},
		gettingDamaged : false,
		gettingDamagedTime : 0,
		gettingDamagedDuration : 30,
		damageColorTime : 3,
		damageColorSwitchTime : 3,
		damageColorIndex : 0,
	}
	static onOneWayCollide = function() {
		with obj {
			for (var i = ds_map_find_first(other.collideWith); !is_undefined(i); i = ds_map_find_next(other.collideWith, i)) {
				if i.object_index != obOneWayCollide continue
				if place_meeting(x, y+1, i) {
					return true
				}
			}
		}
		return false
	}
	static onGround = function() {
		with obj {
			for (var i = ds_map_find_first(other.collideWith); !is_undefined(i); i = ds_map_find_next(other.collideWith, i)) {
				if !ds_map_find_value(other.collideWith, i) continue
				if other.velocity.y == 0 and place_meeting(x,y + 1, i) {
					return true
				}
			}
		}
		return false
	}
	
	static addForce = function(_direction, _force) {
		var forceVector = new vector(_direction.x, _direction.y).multiplied(_force)
		//velocity = velocity.added(forceVector)
		velocity = forceVector
	}
	static damageEntity = function(_direction, _force, _damage) {
		if !life.gettingDamaged {
			PlaySound(damageSound, false, 0.2)
			life.damageParam.direction = _direction
			life.damageParam.force = _force
			life.damageParam.damage = _damage
			life.damageStart = true
		}
	}
	static damage = function() {
		function deathRoll() {
			if abs(rotation + life.deathRoll.rollSpeed * life.deathRoll.rollDirection) < life.deathRoll.deathRotation {
				rotation += life.deathRoll.rollSpeed * life.deathRoll.rollDirection
			}
			else {
				rotation = life.deathRoll.deathRotation * life.deathRoll.rollDirection
				life.fadeAway = true
			}
		}
		if life.gettingDamaged {
			if !life.alive {
				deathRoll()
			}
			if life.gettingDamagedTime < life.gettingDamagedDuration {
				life.gettingDamagedTime++
				if life.damageColorTime < life.damageColorSwitchTime {
					life.damageColorTime++
				}
				else {
					life.damageColorIndex = !life.damageColorIndex
					obj.image_blend = make_color_hsv(
						color_get_hue(damageColors[life.damageColorIndex]),
						color_get_saturation(damageColors[life.damageColorIndex]),
						color_get_value(damageColors[life.damageColorIndex])
					)
					life.damageColorTime = 0
				}
			}
			else {
				obj.image_blend = make_color_hsv(
						color_get_hue(c_white),
						color_get_saturation(c_white),
						color_get_value(c_white)
					)
				if life.alive {
					obj.image_speed = initialImageSpeed
					life.gettingDamagedTime = 0
					life.damageColorTime = life.damageColorSwitchTime
					life.gettingDamaged = false
				}
			}
		}
		else {
			if life.damageStart {
				life.gettingDamaged = true
				life.health -= life.damageParam.damage
				life.alive = life.health > 0
				if !life.alive {
					life.deathRoll.rollDirection = -life.damageParam.direction.x / abs(life.damageParam.direction.x)
					if obj.object_index != obFrog {
						obGame.points += round(life.initialHealth)
					}
				}
				addForce(life.damageParam.direction, life.damageParam.force)
				//velocity = velocity.clamped(velocity.divided(-2), velocity.divided(2)) // added because diagonals were weaker
				obj.image_index = 0
				obj.image_speed = 0
				life.damageStart = false
			}
		}
	}
	static operate = function() {
		// getting damage capability
		damage(life.damageParam.direction, life.damageParam.force, life.damageParam.damage)
		
		//gravity
		function addGravity() {
			velocity.y += gravity
		}

		// friction
		function addFriction() {
			if velocity.x != 0 {
				if velocity.x < 0 {
					if velocity.x + friction > 0 {
						velocity.x = 0
					}
					else {
						velocity.x += friction
					}
				}
				if velocity.x > 0 {
					if velocity.x - friction < 0 {
						velocity.x = 0
					}
					else {
						velocity.x -= friction
					}
				}
			}
		}
		// collision
		function collision() {
			for (var i = ds_map_find_first(collideWith); !is_undefined(i); i = ds_map_find_next(collideWith, i)) {
				var collider = i
				if !ds_map_find_value(collideWith, collider) {
					continue
				}
				with (obj) {
					if place_meeting(x, y + other.velocity.y, collider) {
						while (!place_meeting(x, y + sign(other.velocity.y), collider)){
							y += sign(other.velocity.y)
						}
						other.velocity.y = 0
					}
					//y += other.velocity.y
					if place_meeting(x + other.velocity.x, y, collider) {
						while (!place_meeting(x + sign(other.velocity.x), y, collider)){
							x += sign(other.velocity.x)
						}
						other.velocity.x = 0
					}
					//x += other.velocity.x
				}
			}
		}
		
		function oneWayCollision() {
			for (var i = ds_map_find_first(collideWith); !is_undefined(i); i = ds_map_find_next(collideWith, i)) {
				if i.object_index == obOneWayCollide {
					if i.bbox_top > obj.bbox_bottom {
						ds_map_set(collideWith, i, true)
						ds_map_set(collideWith, i, true)
					}
					else {
						ds_map_set(collideWith, i, false)
					}
				}
			}
		}
		
		if life.fadeAway {
			if obj.image_alpha - life.fadeAwaySpeed > 0 {
				obj.image_alpha -= life.fadeAwaySpeed
			}
			else {
				obj.image_alpha = 0
				instance_destroy(obj)
			}
		}
		if gravityEnabled {
			addGravity()
		}
		addFriction()
		
		if collide{
			oneWayCollision()
			with obj {
				if place_empty(x,y, obCollide) {
					other.collision() // fix glitch of getting stuck in wall by going through it if it happens
				}
			}
		}
		
		//if !collide {
		//	obj.y += velocity.y
		//	obj.x += velocity.x
		//}
		obj.y += velocity.y
		obj.x += velocity.x
		
	}
	static drawSelf = function() {
		draw_sprite_ext(obj.sprite_index, obj.image_index, obj.x, obj.y, obj.image_xscale, obj.image_yscale,
		rotation, make_color_rgb(color_get_red(obj.image_blend), color_get_green(obj.image_blend),
		color_get_blue(obj.image_blend)), obj.image_alpha)
	}
}

function frogEntity(_obj) : entity(_obj) constructor {
	spd = 6
	jumpHeight = 25
	damageForce = 20
	damageValue = 1
	damageSound = soFrogDamaged

	extraJumps = 0
	extraJumpCount = 0

	frogMidAir = {
		startRising : false,
		startFalling : false,
		endRisingIndex : 3,
		endFallingIndex : 7,
		endLandingIndex : 0
	}

	tongue = {
		startPoint : new vector(0,0),
		endPoint : new vector(0,0),
		
		width : 6,
		length : 0,
		maxLength : 100,
		direction : new vector(0,0),
		frames : 10,
		rawSpeed : 30,
		
		out : false,
		goingOut : false,
		goingIn : false,
		activateButton : mouse_check_button_pressed(mb_left),
		mouseOverButton : false,
		
		color1 : c_red,
		color2 : c_red,
		caughtEdible : noone,
	}

	animationSoundAdapter = {
		enterGround : false
	}

	sounds = {
		grassStep : soFrogGrass,
		tongueWhip : soFrogTongue,
		jump : soFrogJump,
		pitchVariety : 0.1,
	}

	static operateFrog = function() {
		keys = {
			left : keyboard_check(ord("A")) or keyboard_check(vk_left),
			right : keyboard_check(ord("D")) or keyboard_check(vk_right),
			jump : keyboard_check_pressed(ord("W")) or keyboard_check_pressed(vk_space),
			down : keyboard_check_pressed(ord("S")) or keyboard_check_pressed(vk_down),
		}
		function control() {
			velocity.x = (keys.right - keys.left) * spd
			//if keys.jump {
			//	if onGround() {
			//		PlaySound(sounds.grassStep, false, sounds.pitchVariety)
			//		addForce(new vector(0,-1), jumpHeight)
			//		frogMidAir.startRising = false
			//		frogMidAir.startFalling = false
			//	}
			//}
			if onGround() {
				extraJumpCount = 0
			}
			if keys.down {
				if onOneWayCollide() {
					obj.y += 1
				}
			}
			if keys.jump {
				if onGround() {
					PlaySound(sounds.jump, false, sounds.pitchVariety)
					PlaySound(sounds.grassStep, false, sounds.pitchVariety)
					addForce(new vector(0,-1), jumpHeight)
					frogMidAir.startRising = false
					frogMidAir.startFalling = false
				}
				else {
					if extraJumpCount < extraJumps {
						PlaySound(sounds.jump, false, sounds.pitchVariety)
						addForce(new vector(0,-1), jumpHeight)
						frogMidAir.startRising = false
						frogMidAir.startFalling = false
					}
					extraJumpCount++
				}
			}
			if velocity.x != 0 {
				obj.image_xscale = abs(obj.image_xscale) * (velocity.x / spd)
			}
		}
		function animate() {
			if velocity.y == 0 {
				if floor(obj.image_index) == frogMidAir.endLandingIndex {
					if velocity.x == 0 {
						if floor(obj.image_index) == 0 {
							obj.image_speed = 0
							obj.image_index = 0
						}
					}
					else {
						obj.image_speed = initialImageSpeed
					}
				}
				else {
					obj.image_speed = initialImageSpeed
				}
		
			}
			else if velocity.y < 0 {
				if frogMidAir.startRising {
					if floor(obj.image_index) == frogMidAir.endRisingIndex {
						obj.image_speed = 0
						obj.image_index = frogMidAir.endRisingIndex
					}
					else {
						obj.image_speed = initialImageSpeed
					}
				}
				else {
					frogMidAir.startRising = true
					obj.image_index = 0
				}
			}
			else {
				if floor(obj.image_index) == frogMidAir.endFallingIndex {
					obj.image_speed = 0
					obj.image_index = frogMidAir.endFallingIndex
				}
				else {
					obj.image_speed = initialImageSpeed
				}
			}
		}
		
		function soundWithAnimation(){
			if floor(obj.image_index) == 0 and velocity.y == 0 {
				if !animationSoundAdapter.enterGround {
					PlaySound(sounds.grassStep, false, sounds.pitchVariety)
					animationSoundAdapter.enterGround = true
				}
			}
			else {
				animationSoundAdapter.enterGround = false
			}
		}
		if life.alive {
			if !life.gettingDamaged {
				control()
			}
			animate()
		}
		else {
			obj.image_speed = 0
		}
		soundWithAnimation()
		with obj {
			move_wrap(true, false, 0)
		}
	}
	
	static drawTongue = function() {
		tonguePositionOffset = [
			new vector(10 * obj.image_xscale, -6 * obj.image_yscale),
			new vector(13 * obj.image_xscale, -9 * obj.image_yscale),
			new vector(14 * obj.image_xscale, -10 * obj.image_yscale),
			new vector(14 * obj.image_xscale, -12 * obj.image_yscale),
			new vector(12 * obj.image_xscale, -11 * obj.image_yscale),
			new vector(12 * obj.image_xscale, -9 * obj.image_yscale),
			new vector(12 * obj.image_xscale, -6 * obj.image_yscale),
			new vector(13 * obj.image_xscale, 1 * obj.image_yscale),
			new vector(12 * obj.image_xscale, -1 * obj.image_yscale),
		]
		function FoundEdible() {
			with all {
				if variable_instance_exists(self, "tag") {
					if self.tag == "frogEdible" {
						with other.obj {
							if place_meeting(frog.tongue.endPoint.x, frog.tongue.endPoint.y, other) {
								frog.tongue.caughtEdible = other
								frog.tongue.caughtEdible.captured.bool = true
								//tongue.caughtEdible.captured.offset = new vector(tongue.caughtEdible.x, tongue.caughtEdible.y).subtracted(tongue.location)
								return true
							}
						}
					}
				}
			}
			return false
		}
		function tongueDamageEnemies() {
			
			with obj {
				for (var i = 0; i < array_length(obGame.enemiesElementIds); i++) {
					var enemy = layer_instance_get_instance(obGame.enemiesElementIds[i])
					if place_meeting(other.tongue.endPoint.x, other.tongue.endPoint.y, enemy) {
						var damageDirection = new vector(enemy.x, enemy.y).subtracted(new vector(x,y)).normalized().added(new vector(0,-1)).normalized()
						enemy.enemy.damageEntity(damageDirection, other.damageForce, other.damageValue)
					}
				}
			}
		}
		tongue.startPoint = new vector(obj.x, obj.y).added(tonguePositionOffset[floor(obj.image_index)])
		tongue.endPoint = tongue.startPoint.added(tongue.direction.multiplied(tongue.length))

		tongue.activateButton = mouse_check_button_pressed(mb_left)
		if tongue.activateButton and !tongue.out and !life.gettingDamaged {
			tongue.mouseOverButton = false
			for (var i = 0; i < array_length(obGame.guiButtons); i++) {
				var guiButton = obGame.guiButtons[i]
				if guiButton.btn.hover.bool {
					tongue.mouseOverButton = true
					break
				}
			}
			
			if !tongue.mouseOverButton {
				tongue.rawSpeed = tongue.maxLength / tongue.frames
				PlaySound(sounds.tongueWhip, false, sounds.pitchVariety)
				tongue.out = true
				tongue.goingOut = true
				tongue.goingIn = false
				tongue.length = 0
				tongue.direction = new vector(mouse_x, mouse_y).subtracted(tongue.startPoint).normalized()
			}
		}

		if tongue.out {
			tongueDamageEnemies()
			if tongue.goingOut {
				if tongue.length < tongue.maxLength {
					if tongue.length + tongue.rawSpeed < tongue.maxLength {
						tongue.length += tongue.rawSpeed
					}
					else {
						tongue.length = tongue.maxLength
						tongue.goingOut = false
						tongue.goingIn = true
					}
				}		
				if FoundEdible() {
					tongue.goingOut = false
					tongue.goingIn = true
				}
			}
			else if tongue.goingIn {
				if tongue.caughtEdible != noone and tongue.caughtEdible != undefined {
					// MAYBE CHANGE for offset
					tongue.caughtEdible.x = tongue.endPoint.x// + tongue.caughtEdible.captured.offset.x
					tongue.caughtEdible.y = tongue.endPoint.y// + tongue.caughtEdible.captured.offset.y
				}
				if tongue.length > 0 {
					if tongue.length - tongue.rawSpeed > 0 {
						tongue.length -= tongue.rawSpeed
					}
					else {
						if tongue.caughtEdible != noone and tongue.caughtEdible !=undefined and instance_exists(tongue.caughtEdible) {
							obGame.points++
							instance_destroy(tongue.caughtEdible)
							tongue.caughtEdible = noone
						}
						tongue.length = 0
						tongue.goingIn = false
						tongue.out = false
					}
				}
			}
			draw_circle_color(tongue.startPoint.x, tongue.startPoint.y, tongue.width/2, tongue.color1, tongue.color2, false)
			draw_circle_color(tongue.endPoint.x, tongue.endPoint.y, tongue.width/2, tongue.color1, tongue.color2, false)
			draw_line_width_color(tongue.startPoint.x, tongue.startPoint.y, tongue.endPoint.x, tongue.endPoint.y, tongue.width, tongue.color1, tongue.color2)
			
		}
	}
}


function walkingEnemyEntity(_obj) : entity(_obj) constructor {
	healthExp = 0.4
	if room == rGame {
		life.health = floor(power(obGame.wave, healthExp) + life.health)
		life.initialHealth = life.health
	}
	
	enterWorld = {
		bool : obj.x > 0 and obj.x < room_width,
		direction : (room_width/2 - obj.x) / abs(room_width/2 - obj.x)
	}
	spd = 3
	damageForce = 30
	damageValue = 1
	
	switchDirectionObjectList = [obCollide, obEnemySwitchDirection]
	enemyWalkingSprites = [
		sWalkingEnemy1,
		//sWalkingEnemy2,
		sWalkingEnemy3,
		sWalkingEnemy4,
		sWalkingEnemy5,
	]
	obj.sprite_index = enemyWalkingSprites[irandom_range(0, array_length(enemyWalkingSprites)-1)]
	
	enemyDamageSounds = ds_map_create()
	ds_map_add(enemyDamageSounds, sWalkingEnemy1, soDamage1)
	ds_map_add(enemyDamageSounds, sWalkingEnemy3, soElephantDamaged)
	ds_map_add(enemyDamageSounds, sWalkingEnemy4, soOrangeDamaged)
	ds_map_add(enemyDamageSounds, sWalkingEnemy5, soGreenDamaged)
	damageSound = ds_map_find_value(enemyDamageSounds, obj.sprite_index)
	
	
	static operateEnemy = function() {
		function enterWorldMoveIn() {
			velocity.x = enterWorld.direction * spd
			obj.image_xscale = enterWorld.direction * abs(obj.image_xscale)
			if enterWorld.direction == 1 {
				if obj.bbox_right > 0 {
					enterWorld.bool = true
				}
			}
			else {
				if obj.bbox_left < room_width {
					enterWorld.bool = true
				}
			}
		}
		function move() {
			with obj {
				if multiPlaceMeeting(x + other.velocity.x, y, other.switchDirectionObjectList) {
					var tempBool = false
					for (var i = 0; i < array_length(other.switchDirectionObjectList); i++) {
						if !place_empty(x,y, other.switchDirectionObjectList[i]) {
							tempBool = true
						}
					}
					if !tempBool {
						image_xscale *= -1
					}
				}
			}
			velocity.x = spd * (obj.image_xscale / abs(obj.image_xscale))
		}
		
		
		function bounceOffBorders() {
			var goal = new vector(obj.x + velocity.x, obj.y + velocity.y)
			if goal.x <= 0 or goal.x >= room_width {
				velocity.x *= -1
			}
			if goal.y <= 0 or goal.y >= room_height {
				velocity.y *= -1
			}
		}
		
		if obj.y > room_height {
			instance_destroy(obj)
		}
		if enterWorld.bool {
			bounceOffBorders()
			if !life.gettingDamaged {
				move()
				if !instance_exists(obFrog) {
					return
				}
				with obj {
					if place_meeting(x,y, obFrog) {
						if !obFrog.frog.life.gettingDamaged {
							var damageDirection = new vector(obFrog.x, obFrog.y).subtracted(new vector(x, y)).normalized()
							obFrog.frog.damageEntity(damageDirection.added(new vector(0,-1)).normalized(), other.damageForce, other.damageValue)
						}
					}
				}
			}
		}
		else {
			enterWorldMoveIn()	
		}
	}
}

function flyingEnemyEntity(_obj) : entity(_obj) constructor {
	healthExp = 0.4
	if room == rGame {
		life.health = power(obGame.wave, healthExp) + life.health
		life.initialHealth = life.health
	}
	
	spd = 3
	damageForce = 10
	damageValue = 1
	attackRange = 300
	
	
	enemyFlyingSprites = [
		sFlyingEnemy1,
		sFlyingEnemy2,
		//sFlyingEnemy3,
	]
	obj.sprite_index = enemyFlyingSprites[irandom_range(0, array_length(enemyFlyingSprites)-1)]
	
	wanderParams = {
		bool : true,
		range : {
			min : 100,
			max : 200,
		},
		waitTime : {
			val : 0,
			waitTimeGoal : 100,
		},
		goal : new vector(obj.x, obj.y),
		reachedGoal : false
	}
	
	followFrogParams = {
		initialized : false,
		distanceRange : {
			val : 0,
			min : 120,
			max : 200,
		},
		maxFollowDistance : 400,
		lockedOn : false,
	}
	
	tongue = {
		startPoint : new vector(0,0),
		endPoint : new vector(0,0),
		width : 6,
		length : 0,
		maxLength : 200,
		direction : new vector(0,0),
		speed : 30,
		out : false,
		goingOut : false,
		goingIn : false,
		color1 : c_red,
		color2 : c_red,
		attack: {
			time : 0,
			cooldown : 60,
		},
		sound : soEnemyTongue,
	}
	
	spritesTonguePositionOffsets = ds_map_create()
	ds_map_add(spritesTonguePositionOffsets, sFlyingEnemy1, [
		new vector(11 * obj.image_xscale,	2 * obj.image_yscale),
		new vector(11 * obj.image_xscale,	3 * obj.image_yscale),
		new vector(10 * obj.image_xscale,	4 * obj.image_yscale),
		new vector(8 * obj.image_xscale,	5 * obj.image_yscale),
		new vector(7 * obj.image_xscale,	4 * obj.image_yscale),
		new vector(7 * obj.image_xscale,	4 * obj.image_yscale),
		new vector(8 * obj.image_xscale,	4 * obj.image_yscale),
		new vector(9 * obj.image_xscale,	5 * obj.image_yscale),
		new vector(12 * obj.image_xscale,	4 * obj.image_yscale),
		new vector(13 * obj.image_xscale,	5 * obj.image_yscale),
		new vector(14 * obj.image_xscale,	4 * obj.image_yscale),
		new vector(13 * obj.image_xscale,	1 * obj.image_yscale),
		new vector(13 * obj.image_xscale,	2 * obj.image_yscale),
		new vector(12 * obj.image_xscale,	2 * obj.image_yscale),
		
		new vector(13 * obj.image_xscale,	2 * obj.image_yscale),
        new vector(12 * obj.image_xscale,	3 * obj.image_yscale),
	])
	ds_map_add(spritesTonguePositionOffsets, sFlyingEnemy2, [
		new vector(2 * obj.image_xscale, 4 * obj.image_yscale),
	    new vector(2 * obj.image_xscale, 7 * obj.image_yscale),
	    new vector(2 * obj.image_xscale, 0 * obj.image_yscale),
	    new vector(2 * obj.image_xscale, 1 * obj.image_yscale),
	    new vector(2 * obj.image_xscale, 3 * obj.image_yscale),
	    new vector(2 * obj.image_xscale, 5 * obj.image_yscale),
	    new vector(2 * obj.image_xscale, 7 * obj.image_yscale),
	    new vector(2 * obj.image_xscale, 1 * obj.image_yscale),
	    new vector(2 * obj.image_xscale, 1 * obj.image_yscale),
	    new vector(2 * obj.image_xscale, 2 * obj.image_yscale),
	])
	//ds_map_add(spritesTonguePositionOffsets, sFlyingEnemy3, [
	//    new vector(0 * obj.image_xscale, 0 * obj.image_yscale),
	//    new vector(0 * obj.image_xscale, 1 * obj.image_yscale),
	//    new vector(0 * obj.image_xscale, 2 * obj.image_yscale),
	//    new vector(0 * obj.image_xscale, 2 * obj.image_yscale),
	//    new vector(0 * obj.image_xscale, 1 * obj.image_yscale),
	//    new vector(0 * obj.image_xscale, 0 * obj.image_yscale),
	//    new vector(0 * obj.image_xscale, -1 * obj.image_yscale),
	//    new vector(0 * obj.image_xscale, -1 * obj.image_yscale),
	//	new vector(0 * obj.image_xscale, -1 * obj.image_yscale),
	//])
	
	tonguePositionOffset = ds_map_find_value(spritesTonguePositionOffsets, obj.sprite_index)

	static drawTongue = function() {
		
		function tongueDamageFrog() {
			if !life.gettingDamaged {
				if !instance_exists(obFrog) {
					return
				}
				with obj {
					if place_meeting(other.tongue.endPoint.x, other.tongue.endPoint.y, obFrog) {
						var damageDirection = new vector(obFrog.x, obFrog.y).subtracted(new vector(x,y)).normalized().added(new vector(0,-1)).normalized()
						obFrog.frog.damageEntity(damageDirection, other.damageForce, other.damageValue)
					}
				}
			}
		}
			
		function operateTongue() {
			
			for (var i = 0; i < array_length(tonguePositionOffset); i++) {
				tonguePositionOffset[i].x *= (obj.image_xscale / abs(obj.image_xscale)) * (tonguePositionOffset[i].x / abs(tonguePositionOffset[i].x))
			}
			
			if !life.gettingDamaged {
				if tongue.goingOut {
					tongueDamageFrog()
					if tongue.length < tongue.maxLength {
						if tongue.length + tongue.speed < tongue.maxLength {
							tongue.length += tongue.speed
						}
						else {
							tongue.length = tongue.maxLength
							tongue.goingOut = false
							tongue.goingIn = true
						}
					}
				}
				else if tongue.goingIn {
					if tongue.length > 0 {
						if tongue.length - tongue.speed > 0 {
							tongue.length -= tongue.speed
						}
						else {
							tongue.length = 0
							tongue.goingIn = false
							tongue.out = false
						}
					}
				}
			}
			draw_circle_color(tongue.startPoint.x, tongue.startPoint.y, tongue.width/2 * life.alive, tongue.color1, tongue.color2, false)
			draw_circle_color(tongue.endPoint.x, tongue.endPoint.y, tongue.width/2 * life.alive, tongue.color1, tongue.color2, false)
			draw_line_width_color(tongue.startPoint.x, tongue.startPoint.y, tongue.endPoint.x, tongue.endPoint.y, tongue.width, tongue.color1, tongue.color2)
			
			
		}
		
		tongue.startPoint = new vector(obj.x, obj.y).added(tonguePositionOffset[floor(obj.image_index)])
		tongue.endPoint = tongue.startPoint.added(tongue.direction.multiplied(tongue.length))
		if instance_exists(obFrog) {
			if followFrogParams.lockedOn {
				if tongue.attack.time < tongue.attack.cooldown {
					tongue.attack.time++
				}
				else {
					PlaySound(tongue.sound, false, 0.2)
					tongue.out = true
					tongue.goingOut = true
					tongue.goingIn = false
					tongue.length = 0
					tongue.direction = new vector(obFrog.x, obFrog.y).subtracted(tongue.startPoint).normalized()
					tongue.attack.time = 0
				}
			}
			else {
				tongue.attack.time = 0
			}
		}
		
		if tongue.out {
			operateTongue()
		}
	}
	
	static operateEnemy = function() {
		position = new vector(obj.x, obj.y)
		function moveTo(location) {
			var goalDirection = location.subtracted(position).normalized()
			var newPosition = position.added(goalDirection.multiplied(spd))
			var newGoalDirection = location.subtracted(newPosition).normalized()
			if goalDirection.equal(newGoalDirection) {
				velocity = goalDirection.multiplied(spd)
			}
			else {
				var goalDistance = location.subtracted(position).get_magnitude()
				velocity = goalDirection.multiplied(goalDistance)
			}
		}
		function wander() {
			function findNewGoal() {
				var enemyWidth = obj.bbox_right - obj.bbox_left;
				var enemyHeight = obj.bbox_bottom - obj.bbox_top
				var circlePositionRange = {
					x : {
						min : wanderParams.range.max + enemyWidth / 2,
						max : room_width - wanderParams.range.max - enemyWidth / 2,
					},
					y : {
						min : wanderParams.range.max + enemyHeight / 2,
						max : room_height - wanderParams.range.max - enemyHeight / 2
					},
				}
				var circlePosition = new vector(random_range(circlePositionRange.x.min, circlePositionRange.x.max),
				clamp(obj.y, circlePositionRange.y.min, circlePositionRange.y.max))
				var randomDirectionVectorInWanderRange = vector_random(random_range(wanderParams.range.min, wanderParams.range.max))
				var positionInRangeCircle = circlePosition.added(randomDirectionVectorInWanderRange)
				return positionInRangeCircle
			}
		
			if velocity.x != 0 {
				obj.image_xscale *= (velocity.x / abs(velocity.x)) * (obj.image_xscale / abs(obj.image_xscale))
			}
			var distanceFromGoal = wanderParams.goal.subtracted(position).get_magnitude()
			if distanceFromGoal < 1 {
				wanderParams.reachedGoal = true
			}
			if wanderParams.reachedGoal {
				velocity = new vector(0,0)
				if wanderParams.waitTime.val < wanderParams.waitTime.waitTimeGoal {
					wanderParams.waitTime.val++
				}
				else {
					wanderParams.goal = findNewGoal()
					wanderParams.waitTime.val = 0
					wanderParams.reachedGoal = false
				}
			}
			else {
				moveTo(wanderParams.goal)
				//var goalDirection = wanderParams.goal.subtracted(position).normalized()
				//var newPosition = position.added(goalDirection.multiplied(spd))
				//var newGoalDirection = wanderParams.goal.subtracted(newPosition).normalized()
				//if goalDirection.equal(newGoalDirection) {
				//	velocity = goalDirection.multiplied(spd)
				//}
				//else {
				//	var goalDistance = wanderParams.goal.subtracted(position).get_magnitude()
				//	velocity = goalDirection.multiplied(goalDistance)
				//}
			}
		}
		
		
		function detectedFrog() {
			if !instance_exists(obFrog) return false
			var frogDistance = point_distance(obj.x, obj.y, obFrog.x, obFrog.y)
			return frogDistance <= attackRange
		}
		
		function followFrog() {
			if !instance_exists(obFrog) {
				return
			}
			var frogPosition = new vector(obFrog.x, obFrog.y)
			var vectorToFrogPosition = frogPosition.subtracted(position)
			if vectorToFrogPosition.x != 0 {
				obj.image_xscale *= (vectorToFrogPosition.x / abs(vectorToFrogPosition.x)) * (obj.image_xscale / abs(obj.image_xscale))
			}
			if followFrogParams.initialized {
				var frogDistance = point_distance(obj.x, obj.y, obFrog.x, obFrog.y)
				if frogDistance > followFrogParams.maxFollowDistance {
					followFrogParams.initialized = false
					followFrogParams.lockedOn = false
					wanderParams.bool = true
					wanderParams.goal = position
					wanderParams.waitTime.val = wanderParams.waitTime.waitTimeGoal
				}
				if followFrogParams.lockedOn {
					if frogDistance > followFrogParams.distanceRange.max {
						moveTo(new vector(obFrog.x, obFrog.y))
					}
					else if frogDistance < followFrogParams.distanceRange.min {
						
						var directionFromFrog = position.subtracted(frogPosition).normalized()
						var minDistancePositionFromFrog = frogPosition.added(directionFromFrog.multiplied(followFrogParams.distanceRange.val))
						moveTo(minDistancePositionFromFrog)
					}
					else {
						velocity = new vector(0,0)
					}
				}
				else {
					moveTo(new vector(obFrog.x, obFrog.y))
					if frogDistance <= followFrogParams.distanceRange.val  {
						followFrogParams.lockedOn = true
						velocity = new vector(0,0)
					}
				}
			}
			else {
				followFrogParams.distanceRange.val = random_range(followFrogParams.distanceRange.min, followFrogParams.distanceRange.max)
				followFrogParams.initialized = true
			}
		}
		

		if !life.gettingDamaged {
			if detectedFrog() {
				wanderParams.bool = false
			}
			if wanderParams.bool {
				wander()
			}
			else {
				followFrog()
			}
		}
		else {
			if !life.alive {
				gravityEnabled = true
				with obj {
					if !place_meeting(x, y, obCollide) {
						other.collide = true
					}
				}
			}
		}
	}
	
}


