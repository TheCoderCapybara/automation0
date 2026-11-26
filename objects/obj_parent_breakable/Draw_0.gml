draw_self();

// Destaca o objeto sob o cursor quando o jogador está ao alcance
// (x e y já estão centralizados no tile, ver obj_parent_centralize)
if (instance_exists(obj_player)
    && point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)
    && point_distance(obj_player.x, obj_player.y, x, y) <= obj_player.range) {
    draw_sprite(spr_select, 0, x, y);
}

// Barra de vida, visível enquanto o alarm[0] estiver ativo
if (alarm[0] > 0) {
    var bar_w = sprite_get_width(spr_health_bar);
    var bar_h = sprite_get_height(spr_health_bar);
    var fill_h = sprite_get_height(spr_health);

    // Centralizada acima do sprite
    var bar_x = x - sprite_xoffset + sprite_width / 2 - bar_w / 2;
    var bar_y = y - sprite_yoffset - 6;

    draw_sprite(spr_health_bar, 0, bar_x, bar_y);

    // Preenchimento proporcional à vida, centralizado verticalmente na borda
    var fill_w = clamp(hp / hp_max, 0, 1) * bar_w;
    draw_sprite_stretched(spr_health, 0, bar_x, bar_y + (bar_h - fill_h) / 2, fill_w, fill_h);
}
