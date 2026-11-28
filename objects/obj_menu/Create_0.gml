// Menu inicial: Continuar, Criar novo jogo e Configurações.
// Também é o menu de pausa do jogo (in_game = true): Voltar ao jogo, Configurações e Sair.
// Os textos não usam acentos porque a fonte padrão pode não exibi-los.

// Dentro do jogo (pausa): o obj_game cria este objeto já com in_game = true
if (!variable_instance_exists(id, "in_game")) {
    in_game = false;
}

// Carrega as configurações (só na primeira vez) e aplica o vídeo e o som escolhidos
settings_init();

// A interface é desenhada em 1280x720 e a tela estica para qualquer janela
gui_w = BASE_WIDTH;
gui_h = BASE_HEIGHT;
display_set_gui_size(gui_w, gui_h);

// --- Título (o nome do jogo ainda vai mudar) ---
title_text = in_game ? "Pausado" : "Automation";
title_y = 150;

// --- Layout dos botões ---
button_w = 360;
button_h = 64;
button_gap = 20;
first_button_y = 300;  // Y do botão mais acima do menu principal

// --- Linhas da tela de configurações (legenda à esquerda e controle à direita) ---
row_x = gui_w / 2 + 20;
row_y = 215;
row_w = 260;
row_h = 40;
row_step = 48;

// --- Barra de volume ---
volume_bar_x = row_x;
volume_bar_y = row_y;
volume_bar_w = row_w;
volume_bar_h = row_h;
dragging_volume = false;  // true enquanto o jogador arrasta a barra

// --- Botão temporário para voltar à resolução padrão (aparece após mudar a resolução) ---
revert_duration = 5 * game_get_speed(gamespeed_fps);  // 5 segundos, em frames
revert_timer = 0;   // Frames restantes do botão (0 = escondido)
revert_w = 420;
revert_h = 70;
revert_x = (gui_w - revert_w) / 2;
revert_y = (gui_h - revert_h) / 2;

// --- Estado ---
screen = "main";         // "main", "new_game", "settings" ou "quit"
settings_tab = "controls";  // "controls", "video" ou "audio"
waiting_key = "";        // Ação que espera uma tecla nova (vazio = nenhuma)
buttons = [];            // Botões da tela atual (refeitos todo frame)
hover_index = -1;        // Botão sob o mouse (-1 = nenhum)
dropdown_open = false;   // Lista de resoluções aberta
input_delay = 2;         // Frames sem aceitar Esc (o Esc que pausou o jogo não pode já despausar)

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

/// Resoluções que o jogador pode escolher: 0 (automática) e as padrões 16:9 que cabem na tela
get_resolution_options = function() {
    var options = [0];
    var available = video_get_available_resolutions();
    for (var i = 0; i < array_length(available); i++) {
        array_push(options, available[i]);
    }
    return options;
};

/// Texto de uma resolução (0 = automática)
get_resolution_text = function(_width) {
    if (_width == 0) {
        return "Automatica";
    }
    return string(_width) + " x " + string(_width * 9 / 16);
};

/// Monta a lista de botões da tela atual
build_buttons = function() {
    var list = [];
    var cx = gui_w / 2;
    var left = cx - button_w / 2;
    var step = button_h + button_gap;

    if (screen == "main" && in_game) {
        // Pausa, de cima para baixo: voltar ao jogo, configurações, sair
        array_push(list, make_button("resume", "Voltar ao jogo", left, first_button_y, button_w, true, ""));
        array_push(list, make_button("settings", "Configuracoes", left, first_button_y + step, button_w, true, ""));
        array_push(list, make_button("quit", "Sair do jogo", left, first_button_y + step * 2, button_w, true, ""));
    }

    if (screen == "main" && !in_game) {
        // De cima para baixo: continuar, novo jogo, configurações, sair
        array_push(list, make_button("continue", "Continuar", left, first_button_y, button_w, has_save, ""));
        array_push(list, make_button("new_game", "Criar novo jogo", left, first_button_y + step, button_w, true, ""));
        array_push(list, make_button("settings", "Configuracoes", left, first_button_y + step * 2, button_w, true, ""));
        array_push(list, make_button("quit", "Sair do jogo", left, first_button_y + step * 3, button_w, true, ""));
    }

    if (screen == "quit") {
        // Sim e Não lado a lado, abaixo da pergunta
        var half_w = (button_w - button_gap) / 2;
        array_push(list, make_button("quit_yes", "Sim", left, 400, half_w, true, ""));
        array_push(list, make_button("quit_no", "Nao", left + half_w + button_gap, 400, half_w, true, ""));
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
        if (settings_tab == "controls") {
            for (var i = 0; i < array_length(control_actions); i++) {
                var action = control_actions[i];
                var key_text = key_get_name(global.settings.controls[$ action]);
                if (waiting_key == action) {
                    key_text = "Aperte uma tecla...";
                }
                var button = make_button("bind_" + action, key_text, row_x, row_y + row_step * i, row_w, true, control_labels[$ action]);
                button.h = row_h;
                array_push(list, button);
            }
            var reset_button = make_button("reset_controls", "Restaurar padroes", row_x, row_y + row_step * array_length(control_actions), row_w, true, "");
            reset_button.h = row_h;
            array_push(list, reset_button);
        }

        if (settings_tab == "video") {
            var video = global.settings.video;

            var fullscreen_button = make_button("toggle_fullscreen", video.fullscreen ? "Ligada" : "Desligada", row_x, row_y, row_w, true, "Tela cheia");

            // Resolução da janela: caixa com a resolução escolhida e uma setinha que abre a lista
            var resolution_button = make_button("res_toggle", get_resolution_text(video.window_width), row_x, row_y + row_step, row_w, !video.fullscreen, "Resolucao da janela");
            resolution_button.has_arrow = true;

            var vsync_button = make_button("toggle_vsync", video.vsync ? "Ligado" : "Desligado", row_x, row_y + row_step * 2, row_w, true, "Vsync");
            fullscreen_button.h = row_h;
            resolution_button.h = row_h;
            vsync_button.h = row_h;
            array_push(list, fullscreen_button);
            array_push(list, resolution_button);
            array_push(list, vsync_button);

            // Lista de resoluções aberta: entra por último, para ficar por cima dos botões de baixo
            if (dropdown_open) {
                var options = get_resolution_options();
                for (var i = 0; i < array_length(options); i++) {
                    var option_y = row_y + row_step + row_h + 2 + row_h * i;
                    var option_button = make_button("res_option_" + string(options[i]), get_resolution_text(options[i]), row_x, option_y, row_w, true, "");
                    option_button.h = row_h;
                    option_button.selected = (options[i] == video.window_width);
                    array_push(list, option_button);
                }
            }
        }

        // Aba de som: o volume é uma barra desenhada e tratada à parte (ver Step e Draw)

        array_push(list, make_button("back", "Voltar", left, 640, button_w, true, ""));
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

    // Itens da lista de resoluções: "res_option_<largura>" (0 = automática)
    if (string_pos("res_option_", _id) == 1) {
        var chosen_width = real(string_delete(_id, 1, 11));
        dropdown_open = false;

        // Só aplica (e oferece voltar ao padrão) se a resolução mudou
        if (chosen_width != video.window_width) {
            video.window_width = chosen_width;
            settings_apply_video();
            settings_save();
            revert_timer = revert_duration;
        }
        return;
    }

    switch (_id) {
        case "resume":
            // Volta ao jogo e fecha este menu de pausa
            with (obj_game) {
                resume_game();
            }
            instance_destroy();
            break;

        case "continue":
            // O obj_island recria o mundo salvo quando a sala começa
            global.continue_game = true;
            room_goto(Room1);
            break;

        case "quit":
            screen = "quit";
            break;

        case "quit_yes":
            game_end();
            break;

        case "quit_no":
            screen = "main";
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
            dropdown_open = false;
            break;

        case "back":
            if (screen == "settings") {
                settings_save();
            }
            waiting_key = "";
            dropdown_open = false;
            revert_timer = 0;
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
            dropdown_open = false;
            break;
        case "tab_audio":
            settings_tab = "audio";
            waiting_key = "";
            dropdown_open = false;
            break;

        case "reset_controls":
            settings_reset_controls();
            waiting_key = "";
            settings_save();
            break;

        case "toggle_fullscreen":
            video.fullscreen = !video.fullscreen;
            dropdown_open = false;
            settings_apply_video();
            settings_save();
            break;

        case "res_toggle":
            // Abre ou fecha a lista de resoluções
            dropdown_open = !dropdown_open;
            break;

        case "revert_resolution":
            // Volta à resolução padrão (automática)
            video.window_width = 0;
            settings_apply_video();
            settings_save();
            revert_timer = 0;
            break;

        case "toggle_vsync":
            video.vsync = !video.vsync;
            settings_apply_video();
            settings_save();
            break;
    }
};
