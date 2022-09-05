if target != noone and target != undefined and instance_exists(target) {
	xTo = clamp(target.x, clmpx1, clmpx2);
	yTo = clamp(target.y, clmpy1, clmpy2);
	var liveSmooth = smoothness - point_distance(x,y,target.x,target.y)/maxSmooth
	if liveSmooth < 1 {
		x = xTo
		y = yTo
	}
	else {
		x += (xTo - x)/liveSmooth
		y += (yTo - y)/liveSmooth
	}
	var vm = matrix_build_lookat(x,y,-10,x,y,0,0,1,0);
	
	camera_set_view_mat(camera,vm);
}
//else {
//	//print("target no")
//}
//if keyboard_check_pressed(ord("R")) {
//	game_restart()
//}
