enemiesElementIds = []
enemyPoints = 3
points = 0
pointsSpent = 0
wave = 0


var iniSaveFileName = "save.ini"
ini_open(iniSaveFileName)

global.gameVolumeScale = ini_read_real("Profile", "Volume", 1)

ini_close()


// this object has to be put in the scene after all gui buttons are for this to work
guiElements = layer_get_all_elements("Gui")
guiButtons = []
for (var i = 0; i < array_length(guiElements); i++) {
	var guiInstance = layer_instance_get_instance(guiElements[i])
	if variable_instance_exists(guiInstance, "btn") {
		array_push(guiButtons, guiInstance)
	}
}
