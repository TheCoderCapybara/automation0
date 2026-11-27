// Configurações do jogo: controles, vídeo e som.
// Ficam em global.settings e são gravadas em settings.json (na pasta de dados do jogo).

#macro SETTINGS_FILE "settings.json"

// Resolução base do jogo (a janela e a superfície são múltiplos inteiros dela)
#macro BASE_WIDTH 1280
#macro BASE_HEIGHT 720

/// @desc Devolve as configurações padrão.
function settings_get_defaults() {
    return {
        // Código de tecla de cada ação
        controls: {
            up: ord("W"),
            down: ord("S"),
            left: ord("A"),
            right: ord("D"),
            inventory: ord("Q"),
            interact: ord("E")
        },
        video: {
            fullscreen: true,  // O projeto já começa em tela cheia
            window_scale: 0,   // 0 = automática (maior múltiplo inteiro que cabe na tela)
            vsync: false
        },
        audio: {
            master_volume: 1   // De 0 a 1
        }
    };
}

/// @desc Carrega e aplica as configurações. Só faz algo na primeira chamada.
function settings_init() {
    if (variable_global_exists("settings")) {
        return;
    }

    // Estado do vsync que o jogo já tem ao abrir (igual à opção do projeto)
    global.applied_vsync = false;

    global.settings = settings_get_defaults();
    settings_load();
    settings_apply();
}

/// @desc Lê settings.json e troca os valores padrão pelos salvos (ignora o que for inválido).
function settings_load() {
    var saved = json_file_read(SETTINGS_FILE);
    if (saved == undefined) {
        return;
    }

    // Controles: só as ações que existem, com um número (código da tecla)
    var saved_controls = saved[$ "controls"];
    if (is_struct(saved_controls)) {
        var actions = variable_struct_get_names(global.settings.controls);
        for (var i = 0; i < array_length(actions); i++) {
            var key_code = saved_controls[$ actions[i]];
            if (is_real(key_code)) {
                global.settings.controls[$ actions[i]] = key_code;
            }
        }
    }

    // Vídeo
    var saved_video = saved[$ "video"];
    if (is_struct(saved_video)) {
        var fullscreen = saved_video[$ "fullscreen"];
        if (is_bool(fullscreen) || is_real(fullscreen)) {
            global.settings.video.fullscreen = (fullscreen != 0);
        }

        var window_scale = saved_video[$ "window_scale"];
        if (is_real(window_scale)) {
            global.settings.video.window_scale = clamp(floor(window_scale), 0, 8);
        }

        var vsync = saved_video[$ "vsync"];
        if (is_bool(vsync) || is_real(vsync)) {
            global.settings.video.vsync = (vsync != 0);
        }
    }

    // Som
    var saved_audio = saved[$ "audio"];
    if (is_struct(saved_audio)) {
        var master_volume = saved_audio[$ "master_volume"];
        if (is_real(master_volume)) {
            global.settings.audio.master_volume = clamp(master_volume, 0, 1);
        }
    }
}

/// @desc Grava as configurações atuais em settings.json.
function settings_save() {
    json_file_write(SETTINGS_FILE, global.settings);
}

/// @desc Volta os controles ao padrão (não mexe em vídeo nem som).
function settings_reset_controls() {
    global.settings.controls = settings_get_defaults().controls;
}

/// @desc Aplica as configurações de vídeo e de som.
function settings_apply() {
    settings_apply_video();
    settings_apply_audio();
}

/// @desc Maior escala inteira da resolução base que cabe na tela.
function video_get_max_scale() {
    return max(1, min(display_get_width() div BASE_WIDTH, display_get_height() div BASE_HEIGHT));
}

/// @desc Aplica tela cheia ou janela, escala, superfície da aplicação e vsync.
function settings_apply_video() {
    var video = global.settings.video;

    // Alterna entre tela cheia e janela só se for diferente do estado atual
    if (window_get_fullscreen() != video.fullscreen) {
        window_set_fullscreen(video.fullscreen);
    }

    // Escala: 0 = automática; uma escala maior do que cabe na tela é reduzida
    var max_scale = video_get_max_scale();
    var scale = max_scale;
    if (video.window_scale != 0) {
        scale = min(video.window_scale, max_scale);
    }

    // Em janela, ajusta o tamanho e centraliza (em tela cheia o sistema cuida do tamanho)
    if (!video.fullscreen) {
        window_set_size(BASE_WIDTH * scale, BASE_HEIGHT * scale);
        window_center();
    }

    // A superfície da aplicação acompanha a escala, para os pixels ficarem nítidos
    surface_resize(application_surface, BASE_WIDTH * scale, BASE_HEIGHT * scale);

    // O vsync só é reaplicado quando muda (o display_reset recria a tela)
    if (global.applied_vsync != video.vsync) {
        display_reset(0, video.vsync);
        global.applied_vsync = video.vsync;
    }
}

/// @desc Aplica o volume geral.
function settings_apply_audio() {
    audio_set_master_gain(0, global.settings.audio.master_volume);
}

/// @desc Nome legível de uma tecla (sem acentos, porque a fonte padrão pode não exibi-los).
/// @param {Real} _key Código da tecla
function key_get_name(_key) {
    // Letras e números têm o mesmo código do caractere
    if ((_key >= ord("A") && _key <= ord("Z")) || (_key >= ord("0") && _key <= ord("9"))) {
        return chr(_key);
    }

    // Teclado numérico e teclas de função
    if (_key >= vk_numpad0 && _key <= vk_numpad9) {
        return "Num " + string(_key - vk_numpad0);
    }
    if (_key >= vk_f1 && _key <= vk_f12) {
        return "F" + string(_key - vk_f1 + 1);
    }

    // Teclas especiais
    switch (_key) {
        case vk_space: return "Espaco";
        case vk_enter: return "Enter";
        case vk_tab: return "Tab";
        case vk_backspace: return "Backspace";
        case vk_shift: return "Shift";
        case vk_lshift: return "Shift esq.";
        case vk_rshift: return "Shift dir.";
        case vk_control: return "Ctrl";
        case vk_lcontrol: return "Ctrl esq.";
        case vk_rcontrol: return "Ctrl dir.";
        case vk_alt: return "Alt";
        case vk_lalt: return "Alt esq.";
        case vk_ralt: return "Alt dir.";
        case vk_up: return "Seta cima";
        case vk_down: return "Seta baixo";
        case vk_left: return "Seta esquerda";
        case vk_right: return "Seta direita";
        case vk_insert: return "Insert";
        case vk_delete: return "Delete";
        case vk_home: return "Home";
        case vk_end: return "End";
        case vk_pageup: return "Page Up";
        case vk_pagedown: return "Page Down";
    }

    // Qualquer outra tecla aparece pelo código
    return "Tecla " + string(_key);
}
