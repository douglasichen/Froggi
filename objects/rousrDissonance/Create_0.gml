///@desc rousrDissonance - Create
if !variable_global_exists("initRousrDissonance") {
	global.initRousrDissonance = false
}
if !global.initRousrDissonance {
	rousrDissonance_event_create();
	global.initRousrDissonance = true
}

