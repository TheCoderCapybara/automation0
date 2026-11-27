player_near = instance_exists(obj_player)
    && point_distance(obj_player.x, obj_player.y, x, y) <= interact_range;

// A tecla de interação (padrão: E) vende tudo o que está no inventário
if (player_near && keyboard_check_pressed(global.settings.controls.interact)) {
    var game = instance_find(obj_game, 0);
    if (game != noone) game.sell_inventory();
}
