///@desc 
draw_sprite_ext(sPixel, 0,                    x,                     y, sprite_width,             2, 0, Fg_color, 1.0);
draw_sprite_ext(sPixel, 0,                    x, y + sprite_height - 2, sprite_width,             2, 0, Fg_color, 1.0);
draw_sprite_ext(sPixel, 0,                    x,                     y,            2, sprite_height, 0, Fg_color, 1.0);
draw_sprite_ext(sPixel, 0, x + sprite_width - 2,                     y,            2, sprite_height, 0, Fg_color, 1.0);

if (Toggled)
  draw_sprite_ext(sCheck, 0, x, y, 2, 2, 0, c_white, 1.0);

var col = draw_get_color();
draw_set_color(Fg_color);
draw_text(x + sprite_width + 2, y + 2, Label);
draw_set_color(col);