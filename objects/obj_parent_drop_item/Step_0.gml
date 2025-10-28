if (instance_exists(obj_player) && attraction) {
    timer += 1;
    
    if (phase == "away" && timer <= 40) {
        speed *= 0.9;
        if (timer == 40) {
            phase = "towards";
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            speed = dist / 80;
            direction = point_direction(x, y, obj_player.x, obj_player.y);
        }
    } else {
        speed *= 1.05;
        direction = point_direction(x, y, obj_player.x, obj_player.y);
    }
}
if (!attraction) speed = 0;

if (place_meeting(x, y, obj_player)) {
    with (obj_draw_GUI) {
        scr_add_to_inventory(id, other.item_type); // Passa obj_draw_GUI como caller
    }
    instance_destroy();
}