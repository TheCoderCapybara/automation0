player_near = instance_exists(obj_player)
    && point_distance(obj_player.x, obj_player.y, x, y) <= interact_range;

var gui = instance_find(obj_draw_GUI, 0);

if (gui != noone) {
    // A tecla de interação (padrão: E) abre o inventário junto com o espaço de venda (ou fecha os dois)
    if (player_near && keyboard_check_pressed(global.settings.controls.interact)) {
        gui.sell_open = !gui.sell_open;
        gui.show_inventory = gui.sell_open;
    }

    // Se o jogador se afastar, o espaço de venda fecha (o inventário continua aberto)
    if (!player_near) {
        gui.sell_open = false;
    }
}
