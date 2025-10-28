draw_self();

if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom) && point_distance(obj_player.x, obj_player.y, x, y) <= obj_player.range){
	var grid_x = floor(x / 64) * 64 + 32;
	var grid_y = floor(y / 64) * 64 + 32;
	draw_sprite(spr_select, 0, grid_x, grid_y);
}

// Desenha a barra de vida se ativa
if (alarm[0] > 0) {
    // Calcula a posição da barra acima do sprite
    var sprite_x = x - sprite_xoffset; // Canto superior-esquerdo do sprite
    var sprite_y = y - sprite_yoffset; // Canto superior-esquerdo do sprite
    var bar_x = sprite_x + sprite_width / 2 - 32; // Centraliza a barra (64 / 2)
    var bar_y = sprite_y - 6;
    
    // Desenha a borda da barra (spr_health_bar, 64x6)
    draw_sprite(spr_health_bar, 0, bar_x, bar_y);
    
    // Calcula a largura do preenchimento com base na vida
    var health_width = (hp / hp_max) * 64; // Proporção da vida para 64 pixels
    
    // Desenha o preenchimento (spr_health, 64x3) esticado proporcionalmente
    draw_sprite_stretched(spr_health, 0, bar_x, bar_y + 1.5, health_width, 3);
}