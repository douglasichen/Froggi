btn = new button(id, function() {
	obButtonPause.surface = undefined	
		
	obButtonPause.pause_instances(false)
	obButtonPause.pause = false
		
	obPauseMenu.menu.reveal = false
})
btn.text.val = "Continue"