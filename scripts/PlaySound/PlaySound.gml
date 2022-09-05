function PlaySound(_sound, _loop, _pitchVariety) {
	audio_sound_pitch(_sound, random_range(1 - _pitchVariety, 1 + _pitchVariety))
	//_sound.pitch = random_range(1 - _pitchVariety, 1 + _pitchVariety)
	audio_play_sound(_sound, 1, _loop)
	
}
