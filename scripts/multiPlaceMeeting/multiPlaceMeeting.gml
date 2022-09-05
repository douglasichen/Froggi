function multiPlaceMeeting(_x, _y, objects){
	for (var i = 0; i < array_length(objects); i++) {
		if place_meeting(_x,_y, objects[i]) return true
	}
	return false
}