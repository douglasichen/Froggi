btn = new button(id, function() {
	room_goto(rGame)
})
btn.drawSprite = false
btn.text.val = "Play"
btn.text.font = fSmallBold
btn.text.scale = new vector(1.2,1.2)