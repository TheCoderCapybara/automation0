if (attraction && instance_exists(obj_player)) {
    timer += 1;

    if (phase == "away") {
        // Perde velocidade por 40 frames; depois muda para a fase de volta
        speed *= 0.9;
        if (timer >= 40) {
            phase = "towards";
            speed = point_distance(x, y, obj_player.x, obj_player.y) / 80;
        }
    } else {
        speed *= 1.05;
    }

    if (phase == "towards") {
        direction = point_direction(x, y, obj_player.x, obj_player.y);
    }
}

if (place_meeting(x, y, obj_player)) {
    if (scr_add_to_inventory(item_type)) {
        instance_destroy();
    } else {
        // Inventário cheio: o item fica no chão até haver espaço
        attraction = false;
        speed = 0;
    }
}
