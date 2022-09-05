if (button_can_click() && 
    (image_index == downIndex && clickAction != noone))
  script_execute(clickAction);
  
image_index = upIndex;