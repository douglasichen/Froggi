// reset the sound volumes to preprare for rescaling
for (var soundId = ds_map_find_first(btn.initialSoundVolumes); !is_undefined(soundId); soundId = ds_map_find_next(btn.initialSoundVolumes, soundId)) {
	var initialVolume = ds_map_find_value(btn.initialSoundVolumes, soundId)
	audio_sound_gain(soundId, initialVolume, 0)
}