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
            window_width: 0,   // Largura da janela (a altura segue a proporção 16:9); 0 = automática
            vsync: true
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

        // Só aceita a automática (0) ou uma das resoluções padrão
        var window_width = saved_video[$ "window_width"];
        if (is_real(window_width) && (window_width == 0 || array_contains(video_get_resolutions(), window_width))) {
            global.settings.video.window_width = window_width;
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

/// @desc Larguras das resoluções padrão em 16:9 (a altura é a largura * 9 / 16), da menor para a maior.
function video_get_resolutions() {
    return [1024, 1280, 1600, 1920, 2560, 3840];
}

/// @desc Diz se uma janela com essa largura cabe na tela (com folga para a barra de título e a barra de tarefas).
/// @param {Real} _width Largura da janela
function video_resolution_fits(_width) {
    return (_width <= display_get_width() && _width * 9 / 16 <= display_get_height() - 80);
}

/// @desc Resoluções de janela que o jogador pode escolher: as padrão que cabem na tela (sempre há pelo menos uma).
function video_get_available_resolutions() {
    var resolutions = video_get_resolutions();
    var available = [];
    for (var i = 0; i < array_length(resolutions); i++) {
        if (video_resolution_fits(resolutions[i])) {
            array_push(available, resolutions[i]);
        }
    }

    // Em telas muito pequenas, ainda oferece a menor
    if (array_length(available) == 0) {
        array_push(available, resolutions[0]);
    }
    return available;
}

/// @desc Tamanho do jogo na tela, sempre em 16:9.
/// Tela cheia: encaixa na tela. Janela: a resolução escolhida (automática = a maior que cabe na tela).
/// @param {Bool} _fullscreen Se está em tela cheia
/// @returns {Struct} { w, h }
function video_get_size(_fullscreen) {
    // Tela cheia: o jogo ocupa o máximo da tela mantendo a proporção
    if (_fullscreen) {
        var fit = min(display_get_width() / BASE_WIDTH, display_get_height() / BASE_HEIGHT);
        return { w: floor(BASE_WIDTH * fit), h: floor(BASE_HEIGHT * fit) };
    }

    // Janela: a resolução escolhida, ou a maior que cabe quando ela não cabe (ou é automática)
    var available = video_get_available_resolutions();
    var width = available[array_length(available) - 1];
    var chosen = global.settings.video.window_width;
    if (chosen != 0 && array_contains(available, chosen)) {
        width = chosen;
    }
    return { w: width, h: width * 9 / 16 };
}

/// @desc Aplica tela cheia ou janela, resolução, superfície da aplicação e vsync.
function settings_apply_video() {
    var video = global.settings.video;

    // Alterna entre tela cheia e janela só se for diferente do estado atual
    if (window_get_fullscreen() != video.fullscreen) {
        window_set_fullscreen(video.fullscreen);
    }

    // Tamanho do jogo (em tela cheia o sistema cuida da janela)
    var size = video_get_size(video.fullscreen);

    // Em janela, ajusta o tamanho e centraliza
    if (!video.fullscreen) {
        window_set_size(size.w, size.h);
        window_center();
    }

    // A superfície da aplicação acompanha a resolução
    surface_resize(application_surface, size.w, size.h);

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
