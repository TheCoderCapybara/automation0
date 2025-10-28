x = mouse_x;
y = mouse_y;

var left_pressed = mouse_check_button(mb_left);

if (left_pressed){
	var target = instance_position(x, y, obj_parent_breakable);

	if (alarm[0] <= 0 && target != noone && point_distance(obj_player.x, obj_player.y, target.x, target.y) <= obj_player.range){
		target.hp -= obj_player.dmg;
		target.alarm[0] = target.health_bar_duration;
		alarm[0] = 40;
	}

	if (instance_exists(obj_draw_GUI)) {
	    var mouse_x_gui = device_mouse_x_to_gui(0);
	    var mouse_y_gui = device_mouse_y_to_gui(0);
	    if (point_in_rectangle(mouse_x_gui, mouse_y_gui, obj_draw_GUI.inventory_x + 624, obj_draw_GUI.inventory_y - 12, obj_draw_GUI.inventory_x + 624 + 24, obj_draw_GUI.inventory_y - 12 + 24)) {
	        obj_draw_GUI.show_inventory = false;
	    }
	}
}