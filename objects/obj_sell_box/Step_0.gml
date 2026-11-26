player_near = instance_exists(obj_player)
    && point_distance(obj_player.x, obj_player.y, x, y) <= interact_range;

// E vende tudo o que está no inventário
if (player_near && keyboard_check_pressed(ord("E"))) {
    var game = instance_find(obj_game, 0);
    if (game != noone) game.sell_inventory();
}
