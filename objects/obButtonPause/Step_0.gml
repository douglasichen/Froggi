btn.operate()
btn.operateButton()


if instance_exists(obFrog) {
	if !obFrog.frog.life.alive {
		if btn.enabled {
			btn.enabled = false
			pause = false
		}
	}
}

