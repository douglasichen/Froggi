if !variable_global_exists("initRousrDissonance") {
	global.initRousrDissonance = false
}
if !global.initRousrDissonance {
	var key = "881289485529280543"

	rousr_dissonance_create(key)

	State_string   = "Happy Birthday";
	Details_string = "~from Douglas";
	Large_text = "";
	//Small_text = "by @babyjeans#7177 (@babyj3ans)";
	//Timestamp  = 10;

	rousr_dissonance_handler_on_ready(example_on_ready, id);
	rousr_dissonance_handler_on_disconnected(example_on_disconnected, id);
	rousr_dissonance_handler_on_error(example_on_error, id);
	//rousr_dissonance_handler_on_join(example_on_join, id);
	//rousr_dissonance_handler_on_spectate(example_on_spectate, id);
	//rousr_dissonance_handler_on_join_request(example_on_join_request, id);

	rousr_dissonance_set_details(Details_string);
	rousr_dissonance_set_state(State_string);
	rousr_dissonance_set_large_image("frog", Large_text);  // set images from your app dashboard here
	//rousr_dissonance_set_small_image("dissonance",       Small_text); // set images from your app dashboard here
	//rousr_dissonance_set_timestamps(0, Timestamp);
}