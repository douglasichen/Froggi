

//set vars
zoom = 1.3;
smoothness = 10;
maxSmooth = 50
//

camera = camera_create();


var near = 1, far = 10000;



resolution = new vector(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]))

camera_width = resolution.x/zoom;
camera_height = resolution.y/zoom;

display_set_gui_size(camera_width, camera_height)
//print(display_get_gui_height())

var vm = matrix_build_lookat(x,y,-10,x,y,0,0,1,0);
var pm = matrix_build_projection_ortho(camera_width, camera_height, near, far);


camera_set_view_mat(camera,vm);
camera_set_proj_mat(camera,pm);

view_set_camera(0, camera)


//target what?
target = noone
if (instance_exists(obFrog)) {
	target = obFrog;
	clmpx1 = camera_width/2; clmpx2 = room_width - camera_width/2;
	clmpy1 = camera_height/2; clmpy2 = room_height - camera_height/2;

	// initialize xto and yto
	xTo = clamp(target.x, clmpx1, clmpx2);
	yTo = clamp(target.y, clmpy1, clmpy2);
	//xTo = target.x
	//yTo = target.y
	x = xTo
	y = yTo
}
else {
	show_debug_message("no frog");
}

