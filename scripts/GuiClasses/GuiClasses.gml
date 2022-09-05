// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function guiObject(_obj) constructor {
	obj = _obj
	cameraZoom = 1
	if instance_exists(obCamera) {
		cameraZoom = obCamera.zoom
	}
	obj.image_xscale /= cameraZoom
	obj.image_yscale /= cameraZoom
	position = new vector(obj.x, obj.y).divided(cameraZoom)
	centerObjPosition = new vector(position.x + obj.sprite_width/2, position.y + obj.sprite_height/2)
	size = new vector(obj.sprite_width, obj.sprite_height)
	drawSprite = true
	
	text = {
		val : "",
		position : new vector(0,0),
		lineSeperation : 10,
		lineWidth : 1000,
		scale : new vector(1,1),
		angle : degtorad(0),
		color : c_white,
		alpha : 1,
		font : fSmall,
		size : new vector(0,0),
		maxSize : new vector(obj.sprite_width,obj.sprite_height),
	}
	
	static operate = function() {
		centerObjPosition = new vector(position.x + obj.sprite_width/2, position.y + obj.sprite_height/2)
		text.alpha = obj.image_alpha
		//position = new vector(obj.x, obj.y).divided(obCamera.zoom)
		//size = new vector(obj.sprite_width * obj.image_xscale, obj.sprite_height * obj.image_yscale).divided(obCamera.zoom)
	}
	
	static drawSelf = function() {
		if drawSprite {
			draw_sprite_ext(obj.sprite_index, obj.image_index, position.x, position.y, obj.image_xscale, obj.image_yscale, obj.image_angle, obj.image_blend, obj.image_alpha)
		}
		draw_set_font(text.font)
		// calculate text size after set font
		text.size.x = string_width(text.val) * text.scale.x
		text.size.y = string_height(text.val) * text.scale.y
		//print(font_get_name(draw_get_font()) + " vs " + font_get_name(text.font))
		//var centerTextOffset = new vector(string_width(text.val), string_height(text.val)).divided(2)
		var centerTextOffset = new vector(text.size.x / 2, text.size.y / 2)
		//draw_circle(centerObjPosition.x - centerTextOffset.x, centerObjPosition.y - centerTextOffset.y, 10, false)
		//draw_circle_color(centerObjPosition.x - centerTextOffset.x, centerObjPosition.y - centerTextOffset.y, 10, c_red, c_red, false)
		draw_text_ext_transformed_color(centerObjPosition.x - centerTextOffset.x + text.position.x, centerObjPosition.y - centerTextOffset.y + text.position.y, text.val, text.lineSeperation, text.lineWidth, text.scale.x, text.scale.y, text.angle, text.color, text.color, text.color, text.color, text.alpha)
	}
}

function button(_obj, _func) : guiObject(_obj) constructor {
	//sprite = sUpgradeMultiJump
	func = _func
	enabled = true
	hover = {
		bool : false,
		val : 0,
		speed : 0.1,
		initialColor : obj.image_blend,
		color : c_white,
	}
	button1 = mb_left
	click = false
	clickSound = soClick
	
	static operateButton = function() {
		static getHover = function() {
			var mousePosition = new vector(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0))
			//print(string(mousePosition) + " in between " + string(position) + " and " + string(position.added(size)))
			return point_in_rectangle(mousePosition.x, mousePosition.y, position.x, position.y, position.x + size.x, position.y + size.y)
		}
		if enabled {
			hover.bool = getHover()
			click = hover.bool && mouse_check_button_pressed(button1)
			if click {
				PlaySound(clickSound, false, 0.3)
				if !is_undefined(func) {
					func()
				}
			}
			hover.val = lerp(hover.val, hover.bool, hover.speed)
			obj.image_blend = merge_color(hover.initialColor, hover.color, hover.val)
		}
		else {
			hover.bool = false
			click = false
		}
	}
}

function upgradeButton(_obj) : button(_obj) constructor {
	level = 1
	text.color = c_white
	cost = {
		initial : 20,
		exp : 3,
		val : 0,
	}
	static updateCost = function() {
		cost.val = round(power(level, cost.exp) + cost.initial)
	}
	//updateCost()
	
	upgradeTypes = ds_map_create()
	ds_map_add(upgradeTypes, obButtonUpgradeMultiJump, {
		func : function(incr) {
			obFrog.frog.extraJumps += incr
		},
		incr : 1,
	})
	ds_map_add(upgradeTypes, obButtonUpgradeHealth, {
		func : function(incr) {
			obFrog.frog.life.health += incr
		},
		incr : 1,
	})
	ds_map_add(upgradeTypes, obButtonUpgradeTongueDamage, {
		func : function(incr) {
			obFrog.frog.damageValue += incr
		},
		incr : 1
	})
	ds_map_add(upgradeTypes, obButtonUpgradeTongueLength, {
		func : function(incr) {
			obFrog.frog.tongue.maxLength += incr
		},
		incr : 20,
	})
	text.position.y = 35
	
	static operateUpgradeButton = function() {
		if !instance_exists(obFrog) {
			return
		}
		updateCost()
		if text.size.x > text.maxSize.x {
			var textScaleChange = 0.01
			text.scale.x -= textScaleChange
			text.scale.y -= textScaleChange
		}
		
		if !obFrog.frog.life.alive {
			enabled = false
		}
		else {
			if obj.object_index == obButtonUpgradeHealth {
				level = obFrog.frog.life.health
				updateCost()
			}
		}
		text.val = "cost: " + string(cost.val)
		
		function buyUpgrade() {
			var upgradeType = ds_map_find_value(upgradeTypes, obj.object_index)
			var upgradeFunction = upgradeType.func
			upgradeFunction(upgradeType.incr)
			if obj.object_index != obButtonUpgradeHealth {
				level++
			}
			obGame.points -= cost.val
			obGame.pointsSpent += cost.val
			updateCost()
		}
		
		if click {
			if obGame.points - cost.val >= 0 {
				buyUpgrade()
			}
		}
	}
}
	
function deathMenu(_obj) : guiObject(_obj) constructor {
	moveMenu = {
		bool : false,
		initialYposition : position.y,
		lerpAmount : 0,
		speed : 0.01,
		goal : new vector(obCamera.camera_width / 2, obCamera.camera_height / 2),
		direction : -1,
	}
	moveMenu.direction = moveMenu.goal.subtracted(position).normalized().y
	
	// create a map of gui objects that are gonna be on top of the deathMenu
	guiObjects = ds_map_create()
	ds_map_add(guiObjects, obButtonPlayAgain, {
		positionOffset : obButtonPlayAgain.btn.position.subtracted(position)
	})
	ds_map_add(guiObjects, obButtonMenu, {
		positionOffset : obButtonMenu.btn.position.subtracted(position)
	})
	
	ds_map_add(guiObjects, obDeadText, {
		positionOffset : obDeadText.guiObj.position.subtracted(position)
	})
	ds_map_add(guiObjects, obWaveReached, {
		positionOffset : obWaveReached.guiObj.position.subtracted(position)
	})
	ds_map_add(guiObjects, obPointsAchieved, {
		positionOffset : obPointsAchieved.guiObj.position.subtracted(position)
	})
	ds_map_add(guiObjects, obPointsSpent, {
		positionOffset : obPointsSpent.guiObj.position.subtracted(position)
	})
	
	
	static operateDeathMenu = function() {
		function moveToGoal() {
			if moveMenu.lerpAmount <= 1 {
				position.y = lerp(moveMenu.initialYposition, moveMenu.goal.y, clamp(moveMenu.lerpAmount,0,1))
				moveMenu.lerpAmount += moveMenu.speed
				for (var _guiObject = ds_map_find_first(guiObjects); !is_undefined(_guiObject); _guiObject = ds_map_find_next(guiObjects, _guiObject)) {
					var val = ds_map_find_value(guiObjects, _guiObject)
					var posOffset = val.positionOffset
					if variable_instance_exists(_guiObject, "btn") {
						_guiObject.btn.position = position.added(posOffset)
					}
					else if variable_instance_exists(_guiObject, "guiObj") {
						_guiObject.guiObj.position = position.added(posOffset)
					}
				}
			}
			else {
				moveMenu.bool = false
			}
		}
		if instance_exists(obFrog) {
			if !obFrog.frog.life.alive {
				moveMenu.bool = true
			}
		}
		if moveMenu.bool {
			moveToGoal()
		}
		
		
	}
}

function nextWaveGuiObject(_obj) : guiObject(_obj) constructor {
	trigger = false
	transition = {
		speed : 0.01,
		breathingTime : 0,
		maxBreathingTIme : 30,
		
	}
	static operateNextWaveGuiObject = function() {
		if trigger {
			if variable_global_exists("waveRecord") {
				if obGame.wave > global.waveRecord {
					global.waveRecord = obGame.wave
				}
			}
			else {
				global.waveRecord = obGame.wave
			}
			if obj.image_alpha < 1 {
				if obj.image_alpha + transition.speed > 1 {
					obj.image_alpha = 1
				}
				else {
					obj.image_alpha += transition.speed
				}
			}
			else {
				if transition.breathingTime < transition.maxBreathingTIme {
					transition.breathingTime++
				}
				else {
					transition.breathingTime = 0
					trigger = false
				}
			}
		}
		else {
			if obj.image_alpha > 0 {
				if obj.image_alpha - transition.speed < 0 {
					obj.image_alpha = 0
				}
				else {
					obj.image_alpha -= transition.speed
				}
			}
		}
		
	}
}

function pauseMenu(_obj) : guiObject(_obj) constructor {
	reveal = false
	alpha = 1
	
	// create a map of gui objects that are gonna be on top of the deathMenu
	guiObjects = ds_map_create()
	ds_map_add(guiObjects, obPauseText, {
		positionOffset : obPauseText.guiObj.position.subtracted(position)
	})
	ds_map_add(guiObjects, obWaveText, {
		positionOffset : obWaveText.guiObj.position.subtracted(position)
	})
	ds_map_add(guiObjects, obButtonPauseToMenu, {
		positionOffset : obButtonPauseToMenu.btn.position.subtracted(position)
	})
	ds_map_add(guiObjects, obButtonContinue, {
		positionOffset : obButtonContinue.btn.position.subtracted(position)
	})
	ds_map_add(guiObjects, obVolume, {
		positionOffset : obVolume.btn.position.subtracted(position)
	})
	//ds_map_add(guiObjects, obButtonPlayAgain, {
	//	positionOffset : obButtonPlayAgain.btn.position.subtracted(position)
	//})
	//ds_map_add(guiObjects, obButtonMenu, {
	//	positionOffset : obButtonMenu.btn.position.subtracted(position)
	//})
	
	//ds_map_add(guiObjects, obDeadText, {
	//	positionOffset : obDeadText.guiObj.position.subtracted(position)
	//})
	//ds_map_add(guiObjects, obWaveReached, {
	//	positionOffset : obWaveReached.guiObj.position.subtracted(position)
	//})
	//ds_map_add(guiObjects, obPointsAchieved, {
	//	positionOffset : obPointsAchieved.guiObj.position.subtracted(position)
	//})
	//ds_map_add(guiObjects, obPointsSpent, {
	//	positionOffset : obPointsSpent.guiObj.position.subtracted(position)
	//})
	
	
	static operatePauseMenu = function() {
		if reveal {
			obj.image_alpha = alpha
			for (var _guiObject = ds_map_find_first(guiObjects); !is_undefined(_guiObject); _guiObject = ds_map_find_next(guiObjects, _guiObject)) {
				if variable_instance_exists(_guiObject, "btn") {
					_guiObject.btn.obj.image_alpha = alpha
					_guiObject.btn.enabled = true
				}
				else if variable_instance_exists(_guiObject, "guiObj") {
					_guiObject.guiObj.obj.image_alpha = alpha
				}
			}
		}
		else {
			obj.image_alpha = 0
			for (var _guiObject = ds_map_find_first(guiObjects); !is_undefined(_guiObject); _guiObject = ds_map_find_next(guiObjects, _guiObject)) {
				if variable_instance_exists(_guiObject, "btn") {
					_guiObject.btn.obj.image_alpha = 0
					_guiObject.btn.enabled = false
				}
				else if variable_instance_exists(_guiObject, "guiObj") {
					_guiObject.guiObj.obj.image_alpha = 0
				}
			}
		}
	}
}

function guiVolume(_obj, _funcPressed) : button(_obj, _funcPressed) constructor {
	
	initialSoundVolumes = ds_map_create()

	for (var audioId = 0; audio_exists(audioId); audioId++){
		ds_map_add(initialSoundVolumes, audioId, audio_sound_get_gain(audioId))
	}
	
	knob = {
		enabled : false,
		position : new vector(position.x + obj.sprite_width * global.gameVolumeScale, position.y + obj.sprite_height/2 - 1),
		color : c_black,
		size : 10,
		outline : false,
		range : {
			min : position.x,
			max : position.x + obj.sprite_width,
			length : obj.sprite_width
		},
	}
	
	func = function() {
		knob.enabled = true
	}
	static operateVolume = function() {
		//print(global.gameVolumeScale)
		if mouse_check_button_released(mb_left) {
			knob.enabled = false
		}
		if knob.enabled {
			knob.position.x = clamp(device_mouse_x_to_gui(0), knob.range.min, knob.range.max)
			var mouseOffset = device_mouse_x_to_gui(0) - position.x
			if mouseOffset > 0 {
				global.gameVolumeScale = clamp(mouseOffset / knob.range.length, 0, 1)
			}
			else {
				global.gameVolumeScale = 0
			}
			
			
			// save custom volume
			var iniSaveFileName = "save.ini"
			ini_open(iniSaveFileName)
			ini_write_real("Profile", "Volume", global.gameVolumeScale)
			ini_close()
		}
		for (var soundId = ds_map_find_first(initialSoundVolumes); !is_undefined(soundId); soundId = ds_map_find_next(initialSoundVolumes, soundId)) {
			var initialVolume = ds_map_find_value(initialSoundVolumes, soundId)
			if soundId == soMusic1 {
				initialVolume = obMusic.musicInGame.volume	
			}
			audio_sound_gain(soundId, initialVolume * global.gameVolumeScale, 0)
		}
	}
	
	static drawVolume = function() {
		var pastAlpha = draw_get_alpha()
		draw_set_alpha(obj.image_alpha)
		draw_circle_color(knob.position.x, knob.position.y, knob.size/2, knob.color, knob.color, knob.outline)
		draw_set_alpha(pastAlpha)
	}
}