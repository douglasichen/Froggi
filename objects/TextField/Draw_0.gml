///@desc TextField - Draw
if (!surface_exists(Surface) || Text_is_dirty) {
  draw_set_font(fnt_game);
  
  var sw = (string_width("W") * Text_width), sh = string_height("W"); 
  var fw = sw + 8, fh = sh + 6;
  var tx = 4, ty = 5;

  if (surface_exists(Surface) && surface_get_width(Surface) != fw || surface_get_height(Surface) != fh)
    surface_free(Surface);
    
  if (!surface_exists(Surface))
    Surface = surface_create(fw, fh);
  
  surface_set_target(Surface);
  draw_clear_alpha(Bg_color, 1.0);
    
  draw_sprite_stretched_ext(sPixel, 0,      0,      0, fw,      1, Border_color, 1.0);
  draw_sprite_stretched_ext(sPixel, 0,      0, fh - 1, fw,     fh, Border_color, 1.0);
  draw_sprite_stretched_ext(sPixel, 0,      0,      0,  1, fh - 1, Border_color, 1.0);
  draw_sprite_stretched_ext(sPixel, 0, fw - 1,      0, fw,     fh, Border_color, 1.0);

  // draw the text
  var col = draw_get_color();
  draw_set_color(Fg_color);
  draw_text(tx, ty, Text);
  draw_set_color(col);

  surface_reset_target();
  
  image_xscale = fw;
  image_yscale = fh;
  
  Text_is_dirty = false;
}

draw_surface(Surface, x, y);

if (global.__field_focus == id) {
  // draw the cursor 
  var time = floor(get_timer() / 1000000);
  if (time % 2 == 0) {
    var cx = 2 + string_width(Text) + 2;
    var cy = 2; ch = string_height("W") + 1;
  
    draw_sprite_ext(sprite_index, 0, x + cx, y + cy, 2, ch, 0, Fg_color, 1.0);
  }
}
