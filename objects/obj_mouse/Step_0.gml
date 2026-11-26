x = mouse_x;
y = mouse_y;

// Com o inventário aberto, o clique não ataca o que está por baixo dele
var inventory_open = instance_exists(obj_draw_GUI) && obj_draw_GUI.show_inventory;

if (mouse_check_button(mb_left) && !inventory_open && alarm[0] <= 0 && instance_exists(obj_player)) {
    var target = instance_position(x, y, obj_parent_breakable);

    if (target != noone && point_distance(obj_player.x, obj_player.y, target.x, target.y) <= obj_player.range) {
        target.hp -= obj_player.dmg;
        target.alarm[0] = target.health_bar_duration;
        alarm[0] = obj_player.attack_cooldown;
    }
}
