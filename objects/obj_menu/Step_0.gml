// Posição do mouse na interface
var mouse_gui_x = device_mouse_x_to_gui(0);
var mouse_gui_y = device_mouse_y_to_gui(0);

// Esperando uma tecla nova para um controle
if (waiting_key != "") {
    if (keyboard_check_pressed(vk_anykey)) {
        var new_key = keyboard_lastkey;

        // Esc cancela; as outras teclas viram o controle
        if (new_key != vk_escape) {
            // Se outra ação já usa essa tecla, as duas trocam de tecla
            var controls = global.settings.controls;
            var old_key = controls[$ waiting_key];
            for (var i = 0; i < array_length(control_actions); i++) {
                var other_action = control_actions[i];
                if (other_action != waiting_key && controls[$ other_action] == new_key) {
                    controls[$ other_action] = old_key;
                }
            }
            controls[$ waiting_key] = new_key;
            settings_save();
        }
        waiting_key = "";
        keyboard_lastkey = 0;
    }
    buttons = build_buttons();
    exit;
}

// Tela de novo jogo: só dígitos, até o limite
if (screen == "new_game") {
    seed_input = string_copy(string_digits(keyboard_string), 1, seed_max_digits);
    keyboard_string = seed_input;
}

// Atalhos de teclado
if (keyboard_check_pressed(vk_escape) && screen != "main") {
    run_action("back");
}
if (keyboard_check_pressed(vk_enter) && screen == "new_game") {
    run_action("start");
}

// Botões da tela atual e qual está sob o mouse
buttons = build_buttons();
hover_index = -1;
for (var i = 0; i < array_length(buttons); i++) {
    var button = buttons[i];
    if (!button.enabled) continue;  // Botão desativado não reage

    if (point_in_rectangle(mouse_gui_x, mouse_gui_y, button.x, button.y, button.x + button.w, button.y + button.h)) {
        hover_index = i;
    }
}

// Clique no botão
if (hover_index != -1 && mouse_check_button_pressed(mb_left)) {
    run_action(buttons[hover_index].id);
}
