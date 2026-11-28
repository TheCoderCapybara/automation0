// A área 1280x720 do menu fica centralizada na interface; o mouse é medido dentro dela
var ui_x = (display_get_gui_width() - gui_w) / 2;
var ui_y = (display_get_gui_height() - gui_h) / 2;
var mouse_gui_x = device_mouse_x_to_gui(0) - ui_x;
var mouse_gui_y = device_mouse_y_to_gui(0) - ui_y;

// Lista de resoluções aberta: a roda do mouse rola a lista
if (dropdown_open) {
    var scroll_max = max(0, array_length(get_resolution_options()) - dropdown_visible);
    dropdown_scroll = clamp(dropdown_scroll + mouse_wheel_down() - mouse_wheel_up(), 0, scroll_max);
}

// Botão temporário de voltar à resolução padrão
if (revert_timer > 0) {
    revert_timer -= 1;

    if (mouse_check_button_pressed(mb_left)) {
        if (point_in_rectangle(mouse_gui_x, mouse_gui_y, revert_x, revert_y, revert_x + revert_w, revert_y + revert_h)) {
            // Clicou no botão: volta ao padrão (e o clique não vale para mais nada)
            run_action("revert_resolution");
            exit;
        }

        // Clicou em qualquer outro lugar: o botão some e a resolução fica
        revert_timer = 0;
    }
}

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

// Atalhos de teclado (Esc fecha a lista, volta uma tela ou, na pausa, volta ao jogo)
if (input_delay > 0) {
    input_delay -= 1;
} else if (keyboard_check_pressed(vk_escape)) {
    if (dropdown_open) {
        dropdown_open = false;
    } else if (screen != "main") {
        run_action("back");
    } else if (in_game) {
        run_action("resume");
        exit;
    }
}
if (keyboard_check_pressed(vk_enter) && screen == "new_game") {
    run_action("start");
}

// Aba de som: clicar ou arrastar a barra muda o volume geral
if (screen == "settings" && settings_tab == "audio") {
    var over_bar = point_in_rectangle(mouse_gui_x, mouse_gui_y, volume_bar_x - 10, volume_bar_y, volume_bar_x + volume_bar_w + 10, volume_bar_y + volume_bar_h);
    if (mouse_check_button_pressed(mb_left) && over_bar) {
        dragging_volume = true;
    }

    if (dragging_volume) {
        if (mouse_check_button(mb_left)) {
            // Posição do mouse na barra vira o volume (de 0 a 1, em passos de 1%)
            var new_volume = clamp((mouse_gui_x - volume_bar_x) / volume_bar_w, 0, 1);
            global.settings.audio.master_volume = round(new_volume * 100) / 100;
            settings_apply_audio();
        } else {
            // Soltou o botão: grava
            dragging_volume = false;
            settings_save();
        }
    }
} else {
    dragging_volume = false;
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

// Clique
if (mouse_check_button_pressed(mb_left)) {
    // Com a lista de resoluções aberta, só ela e a caixa respondem; um clique fora só fecha a lista
    if (dropdown_open) {
        var clicked_id = (hover_index != -1) ? buttons[hover_index].id : "";
        if (clicked_id != "res_toggle" && string_pos("res_option_", clicked_id) != 1) {
            dropdown_open = false;
            hover_index = -1;
        }
    }

    if (hover_index != -1) {
        run_action(buttons[hover_index].id);
    }
}
