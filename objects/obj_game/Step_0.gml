if (state == "game_over") {
    if (game_over_mode == "menu") {
        // R: novo mundo com uma seed aleatória
        if (keyboard_check_pressed(ord("R"))) {
            randomize();
            start_new_world(irandom_range(1, 999999999));
        }

        // M: volta ao menu inicial
        if (keyboard_check_pressed(ord("M"))) {
            go_to_menu();
        }

        // D: o jogador digita a seed
        if (keyboard_check_pressed(ord("D"))) {
            game_over_mode = "typing";
            seed_input = "";
            keyboard_string = "";
        }
    } else {
        // Mantém só os dígitos digitados, até o limite
        seed_input = string_copy(string_digits(keyboard_string), 1, seed_max_digits);
        keyboard_string = seed_input;

        // Enter: confirma a seed (só se digitou algo)
        if (keyboard_check_pressed(vk_enter) && seed_input != "") {
            start_new_world(real(seed_input));
        }

        // Esc: volta para a escolha
        if (keyboard_check_pressed(vk_escape)) {
            game_over_mode = "menu";
        }
    }
    exit;
}

// Jogo pausado: o menu de pausa (obj_menu) cuida dos botões e do Esc
if (state == "paused") {
    exit;
}

// Esc: pausa e salva
if (keyboard_check_pressed(vk_escape)) {
    pause_game();
    exit;
}

if (notice_timer > 0) notice_timer -= 1;

day_timer -= 1;
if (day_timer <= 0) end_day();
