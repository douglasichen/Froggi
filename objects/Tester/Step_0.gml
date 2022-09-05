///@desc 
if (TEST_DISABLED || keyboard_check_pressed(ord("E"))) {
	show_debug_message("Beginning Example");
	instance_create_depth(0, 0, 0, Example);
	instance_destroy(id);
}