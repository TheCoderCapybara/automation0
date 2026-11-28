// Configurações do jogo: controles, vídeo e som.
// Ficam em global.settings e são gravadas em settings.json (na pasta de dados do jogo).

#macro SETTINGS_FILE "settings.json"

// Resolução base do jogo: a visão tem sempre 720 de altura (16:9 ou mais largo) ou 1280 de largura (mais alto)
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
            window_width: 0,   // Resolução da janela; 0 x 0 = automática
            window_height: 0,
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

        // Só aceita a automática (0 x 0) ou uma das resoluções da lista
        var window_width = saved_video[$ "window_width"];
        var window_height = saved_video[$ "window_height"];
        if (is_real(window_width) && is_real(window_height)) {
            if ((window_width == 0 && window_height == 0) || video_resolution_exists(window_width, window_height)) {
                global.settings.video.window_width = window_width;
                global.settings.video.window_height = window_height;
            }
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

/// @desc Resoluções padrão, agrupadas por proporção, da menor para a maior em cada grupo.
/// @returns {Array<Struct>} Lista de { w, h, ratio }
function video_get_resolutions() {
    return [
        { w: 1280, h: 720, ratio: "16:9" },
        { w: 1366, h: 768, ratio: "16:9" },
        { w: 1600, h: 900, ratio: "16:9" },
        { w: 1920, h: 1080, ratio: "16:9" },
        { w: 2560, h: 1440, ratio: "16:9" },
        { w: 3840, h: 2160, ratio: "16:9" },
        { w: 1280, h: 800, ratio: "16:10" },
        { w: 1440, h: 900, ratio: "16:10" },
        { w: 1680, h: 1050, ratio: "16:10" },
        { w: 1920, h: 1200, ratio: "16:10" },
        { w: 2560, h: 1600, ratio: "16:10" },
        { w: 2560, h: 1080, ratio: "21:9" },
        { w: 3440, h: 1440, ratio: "21:9" },
        { w: 3840, h: 1600, ratio: "21:9" },
        { w: 3840, h: 1080, ratio: "32:9" },
        { w: 5120, h: 1440, ratio: "32:9" }
    ];
}

/// @desc Diz se a resolução está na lista de resoluções padrão.
function video_resolution_exists(_width, _height) {
    var resolutions = video_get_resolutions();
    for (var i = 0; i < array_length(resolutions); i++) {
        if (resolutions[i].w == _width && resolutions[i].h == _height) {
            return true;
        }
    }
    return false;
}

/// @desc Diz se uma janela desse tamanho cabe na tela (com folga para a barra de título e a barra de tarefas).
function video_resolution_fits(_width, _height) {
    return (_width <= display_get_width() && _height <= display_get_height() - 80);
}

/// @desc Resoluções de janela que o jogador pode escolher: todas as da lista.
/// Uma maior que a tela é desenhada nessa resolução e reduzida para caber na janela.
function video_get_available_resolutions() {
    return video_get_resolutions();
}

/// @desc Texto de uma resolução, com a proporção (0 x 0 = automática).
function video_get_resolution_text(_width, _height) {
    if (_width == 0) {
        return "Automatica";
    }

    var resolutions = video_get_resolutions();
    for (var i = 0; i < array_length(resolutions); i++) {
        if (resolutions[i].w == _width && resolutions[i].h == _height) {
            return string(_width) + " x " + string(_height) + " (" + resolutions[i].ratio + ")";
        }
    }
    return string(_width) + " x " + string(_height);
}

/// @desc Tamanho do jogo na tela.
/// Tela cheia: a tela inteira. Janela: a resolução escolhida (automática = a maior 16:9 que cabe na tela).
/// @param {Bool} _fullscreen Se está em tela cheia
/// @returns {Struct} { w, h }
function video_get_size(_fullscreen) {
    // Tela cheia: o jogo ocupa a tela inteira, seja qual for a proporção
    if (_fullscreen) {
        return { w: display_get_width(), h: display_get_height() };
    }

    // Janela: a resolução escolhida, se ainda cabe na tela
    var available = video_get_available_resolutions();
    var chosen_width = global.settings.video.window_width;
    var chosen_height = global.settings.video.window_height;
    for (var i = 0; i < array_length(available); i++) {
        if (chosen_width != 0 && available[i].w == chosen_width && available[i].h == chosen_height) {
            return { w: chosen_width, h: chosen_height };
        }
    }

    // Automática: a maior resolução 16:9 que cabe na tela
    var auto_size = available[0];
    for (var i = 0; i < array_length(available); i++) {
        if (available[i].ratio == "16:9" && video_resolution_fits(available[i].w, available[i].h)) {
            auto_size = available[i];
        }
    }
    return { w: auto_size.w, h: auto_size.h };
}

/// @desc Tamanho da visão do jogo (em pixels do mundo) para uma tela com a proporção dada.
/// Telas mais largas que 16:9 mostram mais mapa nas laterais; mais altas, mais mapa em cima e embaixo.
/// @returns {Struct} { w, h }
function video_get_view_size(_screen_width, _screen_height) {
    var aspect = _screen_width / _screen_height;

    if (aspect >= BASE_WIDTH / BASE_HEIGHT) {
        return { w: round(BASE_HEIGHT * aspect), h: BASE_HEIGHT };
    }
    return { w: BASE_WIDTH, h: round(BASE_WIDTH / aspect) };
}

/// @desc Aplica tela cheia ou janela, resolução, visão, interface (GUI), superfície da aplicação e vsync.
function settings_apply_video() {
    var video = global.settings.video;

    // Alterna entre tela cheia e janela só se for diferente do estado atual
    if (window_get_fullscreen() != video.fullscreen) {
        window_set_fullscreen(video.fullscreen);
    }

    // Tamanho do jogo na tela
    var size = video_get_size(video.fullscreen);
    global.screen_w = size.w;
    global.screen_h = size.h;

    // Em janela, ajusta o tamanho e centraliza (em tela cheia o sistema cuida da janela).
    // Uma resolução maior que a tela é reduzida, mantendo a proporção, para a janela caber
    if (!video.fullscreen) {
        var fit = min(1, display_get_width() / size.w, (display_get_height() - 80) / size.h);
        window_set_size(max(1, round(size.w * fit)), max(1, round(size.h * fit)));
        window_center();
    }

    // A visão e a interface têm a proporção da tela (a câmera lê global.view_w e global.view_h)
    var view_size = video_get_view_size(size.w, size.h);
    global.view_w = view_size.w;
    global.view_h = view_size.h;
    display_set_gui_size(view_size.w, view_size.h);

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
