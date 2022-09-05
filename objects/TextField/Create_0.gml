///@desc TextField - Create
gml_pragma("global", "global.__field_focus = noone;");

Surface       = -1;
Has_focus     = false;
Text_is_dirty = false;

Text_width    = 20;
Fg_color      = c_white;
Bg_color      = c_gray;
Border_color  = c_black;
Default_color = c_ltgray;

On_lost_focus = noone;
On_focus      = noone;
On_submit     = noone;
On_cancel     = noone;
On_text       = noone;

Submit = vk_enter;
Cancel = vk_escape;

Text_pre_focus = "";  // cache the text before typing began.
Text           = "";
Default        = "";