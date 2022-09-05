music = soMusic1

var musicInMenu = {
	volume : 0.4,
	time : 0,
}
musicInGame = {
	volume : 0.7,
	time : 2000
}


if room == rMenu {
	audio_sound_gain(music, musicInMenu.volume, musicInMenu.time)
}
else if room == rGame {
	//if variable_global_exists("gameVolumeScale") {
	//	musicInGame.volume *= global.gameVolumeScale
	//}
	audio_sound_gain(music, musicInGame.volume, musicInGame.time)
}
if !audio_is_playing(music) {
	PlaySound(music, true, 0)
}