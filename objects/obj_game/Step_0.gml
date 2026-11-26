if (state == "game_over") {
    if (keyboard_check_pressed(ord("R"))) room_restart();
    exit;
}

if (notice_timer > 0) notice_timer -= 1;

day_timer -= 1;
if (day_timer <= 0) end_day();
