// Menu inicial: Continuar, Criar novo jogo e Configurações.
// Os textos não usam acentos porque a fonte padrão pode não exibi-los.

// Carrega as configurações (só na primeira vez) e aplica o vídeo e o som escolhidos
settings_init();

// A interface é desenhada em 1280x720 e a tela estica para qualquer janela
gui_w = BASE_WIDTH;
gui_h = BASE_HEIGHT;
display_set_gui_size(gui_w, gui_h);

// --- Título (o nome do jogo ainda vai mudar) ---
title_text = "Automation";
title_y = 150;

// --- Layout dos botões ---
button_w = 360;
button_h = 64;
button_gap = 20;
first_button_y = 300;  // Y do botão mais acima do menu principal

// --- Estado ---
screen = "main";         // "main", "new_game" ou "settings"
settings_tab = "controls";  // "controls", "video" ou "audio"
waiting_key = "";        // Ação que espera uma tecla nova (vazio = nenhuma)
buttons = [];            // Botões da tela atual (refeitos todo frame)
hover_index = -1;        // Botão sob o mouse (-1 = nenhum)

// --- Último jogo salvo ---
has_save = (save_read() != undefined);

// --- Tela de novo jogo: seed digitada ---
seed_input = "";
seed_max_digits = 9;

// Nomes das ações de controle, na ordem em que aparecem
control_actions = ["up", "down", "left", "right", "inventory", "interact"];
control_labels = {
    up: "Mover para cima",
    down: "Mover para baixo",
    left: "Mover para esquerda",
    right: "Mover para direita",
    inventory: "Abrir inventario",
    interact: "Interagir"
};

/// Cria um botão (struct) com posição, tamanho e texto
make_button = function(_id, _label, _x, _y, _w, _enabled, _caption) {
    return { id: _id, label: _label, x: _x, y: _y, w: _w, h: button_h, enabled: _enabled, caption: _caption };
};

/// Monta a lista de botões da tela atual
build_buttons = function() {
    var list = [];
    var cx = gui_w / 2;
    var left = cx - button_w / 2;
    var step = button_h + button_gap;

    if (screen == "main") {
        // De cima para baixo: continuar, novo jogo, configurações
        array_push(list, make_button("continue", "Continuar", left, first_button_y, button_w, has_save, ""));
        array_push(list, make_button("new_game", "Criar novo jogo", left, first_button_y + step, button_w, true, ""));
        array_push(list, make_button("settings", "Configuracoes", left, first_button_y + step * 2, button_w, true, ""));
    }

    if (screen == "new_game") {
        array_push(list, make_button("roll_seed", "Sortear seed", left, 400, button_w, true, ""));
        array_push(list, make_button("start", "Comecar", left, 400 + step, button_w, true, ""));
        array_push(list, make_button("back", "Voltar", left, 400 + step * 2, button_w, true, ""));
    }

    if (screen == "settings") {
        // Abas
        var tab_w = 200;
        var tab_x = cx - (tab_w * 3 + button_gap * 2) / 2;
        array_push(list, make_button("tab_controls", "Controles", tab_x, 130, tab_w, true, ""));
        array_push(list, make_button("tab_video", "Video", tab_x + tab_w + button_gap, 130, tab_w, true, ""));
        array_push(list, make_button("tab_audio", "Som", tab_x + (tab_w + button_gap) * 2, 130, tab_w, true, ""));

        // Linhas da aba atual: legenda à esquerda e botão à direita
        var row_x = cx + 20;
        var row_w = 260;
        var row_y = 230;
        var row_step = 54;

        if (settings_tab == "controls") {
            for (var i = 0; i < array_length(control_actions); i++) {
                var action = control_actions[i];
                var key_text = key_get_name(global.settings.controls[$ action]);
                if (waiting_key == action) {
                    key_text = "Aperte uma tecla...";
                }
                var button = make_button("bind_" + action, key_text, row_x, row_y + row_step * i, row_w, true, control_labels[$ action]);
                button.h = 44;
                array_push(list, button);
            }
            var reset_button = make_button("reset_controls", "Restaurar padroes", row_x, row_y + row_step * array_length(control_actions), row_w, true, "");
            reset_button.h = 44;
            array_push(list, reset_button);
        }

        if (settings_tab == "video") {
            var video = global.settings.video;
            var max_scale = video_get_max_scale();

            var scale_text = "Automatica";
            if (video.window_scale != 0) {
                scale_text = string(min(video.window_scale, max_scale)) + "x";
            }

            var fullscreen_button = make_button("toggle_fullscreen", video.fullscreen ? "Ligada" : "Desligada", row_x, row_y, row_w, true, "Tela cheia");
            var scale_button = make_button("cycle_scale", scale_text, row_x, row_y + row_step, row_w, !video.fullscreen, "Tamanho da janela");
            var vsync_button = make_button("toggle_vsync", video.vsync ? "Ligado" : "Desligado", row_x, row_y + row_step * 2, row_w, true, "Vsync");
            fullscreen_button.h = 44;
            scale_button.h = 44;
            vsync_button.h = 44;
            array_push(list, fullscreen_button);
            array_push(list, scale_button);
            array_push(list, vsync_button);
        }

        if (settings_tab == "audio") {
            var volume_text = string(round(global.settings.audio.master_volume * 100)) + "%";
            var down_button = make_button("volume_down", "-", row_x, row_y, 60, true, "Volume geral");
            var up_button = make_button("volume_up", "+", row_x + row_w - 60, row_y, 60, true, "");
            down_button.h = 44;
            up_button.h = 44;
            down_button.value_text = volume_text;
            array_push(list, down_button);
            array_push(list, up_button);
        }

        array_push(list, make_button("back", "Voltar", left, 620, button_w, true, ""));
    }

    return list;
};

/// Executa a ação de um botão
run_action = function(_id) {
    var video = global.settings.video;

    // Botões de tecla: "bind_<ação>" espera a próxima tecla apertada
    if (string_pos("bind_", _id) == 1) {
        waiting_key = string_delete(_id, 1, 5);
        return;
    }

    switch (_id) {
        case "continue":
            // O obj_island recria o mundo salvo quando a sala começa
            global.continue_game = true;
            room_goto(Room1);
            break;

        case "new_game":
            screen = "new_game";
            seed_input = "";
            keyboard_string = "";
            break;

        case "settings":
            screen = "settings";
            settings_tab = "controls";
            waiting_key = "";
            break;

        case "back":
            if (screen == "settings") {
                settings_save();
            }
            waiting_key = "";
            screen = "main";
            break;

        case "roll_seed":
            randomize();
            seed_input = string(irandom_range(1, 999999999));
            keyboard_string = seed_input;
            break;

        case "start":
            // Sem seed digitada, sorteia uma
            if (seed_input == "") {
                randomize();
                global.world_seed = irandom_range(1, 999999999);
            } else {
                global.world_seed = real(seed_input);
            }
            global.continue_game = false;
            room_goto(Room1);
            break;

        case "tab_controls":
            settings_tab = "controls";
            waiting_key = "";
            break;
        case "tab_video":
            settings_tab = "video";
            waiting_key = "";
            break;
        case "tab_audio":
            settings_tab = "audio";
            waiting_key = "";
            break;

        case "reset_controls":
            settings_reset_controls();
            waiting_key = "";
            settings_save();
            break;

        case "toggle_fullscreen":
            video.fullscreen = !video.fullscreen;
            settings_apply_video();
            settings_save();
            break;

        case "cycle_scale":
            // Automática -> 1x -> 2x ... até o máximo que cabe na tela -> automática
            var next_scale = min(video.window_scale, video_get_max_scale()) + 1;
            if (next_scale > video_get_max_scale()) {
                next_scale = 0;
            }
            video.window_scale = next_scale;
            settings_apply_video();
            settings_save();
            break;

        case "toggle_vsync":
            video.vsync = !video.vsync;
            settings_apply_video();
            settings_save();
            break;

        case "volume_down":
        case "volume_up":
            var change = (_id == "volume_up") ? 0.1 : -0.1;
            global.settings.audio.master_volume = clamp(round((global.settings.audio.master_volume + change) * 10) / 10, 0, 1);
            settings_apply_audio();
            settings_save();
            break;
    }
};
