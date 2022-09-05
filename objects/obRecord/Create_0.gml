guiObj = new guiObject(id)
guiObj.drawSprite = false

var iniSaveFileName = "save.ini"
ini_open(iniSaveFileName)

var waveRecord = ini_read_real("Profile", "BestRecord", 0)

var newWaveRecord = 0
if variable_global_exists("waveRecord") {
	newWaveRecord = global.waveRecord
}
if newWaveRecord > waveRecord {
	ini_write_real("Profile", "BestRecord", newWaveRecord)
	waveRecord = newWaveRecord
}
ini_close()
guiObj.text.val = "Best: Wave " + string(waveRecord)