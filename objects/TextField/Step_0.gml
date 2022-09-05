///@desc TextField - Step

if (global.__field_focus == id) {
  // First - do we need to submit / cancel?
  if (Submit != undefined && keyboard_check_pressed(Submit)) {
    if (On_submit != noone) 
      script_execute(On_submit, id);
    global.__field_focus = noone;
  } else if (Cancel != undefined && keyboard_check_pressed(Cancel)) {
    if (On_cancel != noone) 
      script_execute(On_cancel, id);
    global.__field_focus = noone;
  } else {
    // Update the input
    var _input_text = keyboard_string; 
    keyboard_string = "";
    
    if (string_length(_input_text) > 0) {
      Text += _input_text;
      Text_is_dirty = true;
    }
    
    if (keyboard_check_pressed(vk_backspace)) {
      var len = string_length(Text) - 1;
      if (len >= 0) {
        Text = (len > 0) ? string_copy(Text, 1, string_length(Text) - 1) : "";
        Text_is_dirty = true;
      }
    }
  }
}

if (mouse_check_button_pressed(mb_left)) {
  if (mouse_x > x && mouse_x < x + image_xscale &&
      mouse_y > y && mouse_y < y + image_yscale) {
      
    var in_focus = global.__field_focus;
    global.__field_focus = id;

    with (in_focus) if (On_lost_focus != noone) script_execute(On_lost_focus, id); 
    if (On_focus != noone) script_execute(On_focus, id); 
    
  } else if (global.__field_focus == id) {
    global.__field_focus = noone;
    if (On_lost_focus != noone) script_execute(On_lost_focus, id); 
  }
}
