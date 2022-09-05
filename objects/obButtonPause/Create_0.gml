pause = false
surface = undefined
surfaceScale = 1 / obCamera.zoom

function pause_instances(pause) {
	var layers = layer_get_all()
	if pause {
		for (var i = 0; i < array_length(layers); i++) {
			var l = layers[i]
			if layer_get_name(l) != "Gui" and layer_get_name(l) != "DiscordRichPresence" and layer_get_name(l) != "Invis" {
				instance_deactivate_layer(l)
			}
			else if layer_get_name(l) == "Gui" {
				var layerElements = layer_get_all_elements(l)
				for (var o = 0; o < array_length(layerElements); o++) {
					var element = layerElements[o]
					var instance = layer_instance_get_instance(element)
					if object_get_name(instance.object_index) != "obButtonPause" {
						if variable_instance_exists(instance, "btn") {
							instance.btn.enabled = false
						}
					}
				}
			}
		}
	}
	else {
		for (var i = 0; i < array_length(layers); i++) {
			var l = layers[i]
			if layer_get_name(l) != "Gui" and layer_get_name(l) != "DiscordRichPresence" and layer_get_name(l) != "Invis" {
				instance_activate_layer(l)
			}
			else if layer_get_name(l) == "Gui" {
				var layerElements = layer_get_all_elements(l)
				for (var o = 0; o < array_length(layerElements); o++) {
					var element = layerElements[o]
					var instance = layer_instance_get_instance(element)
					if variable_instance_exists(instance, "btn") {
						instance.btn.enabled = true
					}
				}
			}
		}
	}
}

btn = new button(id, function() {
	
	if obButtonPause.pause {
		obButtonPause.surface = undefined
		
		pause_instances(false)
		obButtonPause.pause = false
		
		obPauseMenu.menu.reveal = false
	}
	else {
		obButtonPause.surface = surface_create(display_get_width(), display_get_height())
		surface_copy(obButtonPause.surface, 0, 0, application_surface)
		
		pause_instances(true)
		obButtonPause.pause = true
		
		obPauseMenu.menu.reveal = true
	}
})

