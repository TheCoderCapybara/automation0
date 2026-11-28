// Sistema de save: guarda o jogo atual em save.json (pasta de dados do jogo).
// Há um único slot: o último jogo. O save guarda a seed, os tiles da ilha, o jogador,
// o inventário, o dia e o dinheiro, os recursos (com a vida de cada um) e os itens no chão.

#macro SAVE_FILE "save.json"
#macro SAVE_VERSION 1  // Aumentar quando o formato do save mudar

/// @desc Lê o save e confere se ele é válido.
/// @returns {Struct} Os dados do save, ou undefined se não existe ou está inválido
function save_read() {
    var data = json_file_read(SAVE_FILE);
    if (data == undefined) {
        return undefined;
    }

    // Só aceita saves da versão atual
    if (data[$ "version"] != SAVE_VERSION) {
        return undefined;
    }

    // Confere se todos os campos existem
    var required = ["seed", "tiles", "player", "game", "spawner", "inventory", "resources", "drops"];
    for (var i = 0; i < array_length(required); i++) {
        if (!variable_struct_exists(data, required[i])) {
            return undefined;
        }
    }

    return data;
}

/// @desc Apaga o save (usado quando o jogador morre).
function save_delete() {
    if (file_exists(SAVE_FILE)) {
        file_delete(SAVE_FILE);
    }
}

/// @desc Salva o jogo atual. Só funciona com o jogo rodando (não pausado nem em fim de jogo).
/// @returns {Bool} true se salvou
function save_game() {
    var game = instance_find(obj_game, 0);
    var player = instance_find(obj_player, 0);
    var gui = instance_find(obj_draw_GUI, 0);
    var spawner = instance_find(obj_spawner, 0);

    // Precisa de todas as partes do jogo presentes
    if (game == noone || player == noone || gui == noone || spawner == noone) {
        return false;
    }

    // Não salva depois do fim de jogo nem com o mundo congelado (pausa)
    if (game.state != "playing") {
        return false;
    }

    // Itens na mão (pegos com o botão direito) voltam ao inventário antes de salvar
    with (gui) {
        return_held();
    }

    // Tiles da ilha: x e y de cada tile de grama, um depois do outro
    var tiles = [];
    for (var i = 0; i < instance_number(obj_chao_grama); i++) {
        var tile = instance_find(obj_chao_grama, i);
        array_push(tiles, tile.x);
        array_push(tiles, tile.y);
    }

    // Inventário: só os slots ocupados
    var inventory = [];
    for (var i = 0; i < array_length(gui.inventory); i++) {
        var slot = gui.inventory[i];
        if (slot != undefined) {
            array_push(inventory, { slot: i, type: slot.type, qty: slot.qty });
        }
    }

    // Recursos (árvores, pedras...): tipo, posição e vida
    var resources = [];
    for (var i = 0; i < instance_number(obj_parent_breakable); i++) {
        var resource = instance_find(obj_parent_breakable, i);
        array_push(resources, {
            kind: object_get_name(resource.object_index),
            x: resource.x,
            y: resource.y,
            hp: resource.hp
        });
    }

    // Itens soltos no chão (troncos, pedras...)
    var drops = [];
    for (var i = 0; i < instance_number(obj_parent_drop_item); i++) {
        var drop = instance_find(obj_parent_drop_item, i);
        array_push(drops, {
            kind: object_get_name(drop.object_index),
            x: drop.x,
            y: drop.y,
            attraction: drop.attraction
        });
    }

    var data = {
        version: SAVE_VERSION,
        seed: global.world_seed,
        tiles: tiles,
        player: { x: player.x, y: player.y, facing: player.image_xscale },
        game: { day: game.day, day_timer: game.day_timer, money: game.money },
        spawner: { spawn_timer: spawner.spawn_timer },
        inventory: inventory,
        resources: resources,
        drops: drops
    };

    return json_file_write(SAVE_FILE, data);
}

/// @desc Recria o mundo salvo: ilha, jogador, inventário, dia, dinheiro, recursos e itens.
/// Deve ser chamado com a sala já criada (o obj_island chama 1 frame depois do início).
/// @param {Struct} _data Dados lidos por save_read()
function save_apply(_data) {
    // Seed do mundo (mostrada na tela de fim de jogo)
    global.world_seed = _data.seed;

    // Ilha: um tile de grama para cada par x, y salvo
    for (var i = 0; i + 1 < array_length(_data.tiles); i += 2) {
        instance_create_layer(_data.tiles[i], _data.tiles[i + 1], "Instances", obj_chao_grama);
    }

    // Jogador
    var player = instance_find(obj_player, 0);
    if (player != noone) {
        player.x = _data.player.x;
        player.y = _data.player.y;
        player.image_xscale = _data.player.facing;
    }

    // A câmera já começa no jogador, sem deslizar desde o ponto inicial
    var camera_object = instance_find(obj_camera, 0);
    if (camera_object != noone && player != noone) {
        camera_object.x = player.x;
        camera_object.y = player.y;
    }

    // Dia, tempo restante do dia e dinheiro
    var game = instance_find(obj_game, 0);
    if (game != noone) {
        game.day = _data.game.day;
        game.day_timer = _data.game.day_timer;
        game.money = _data.game.money;
    }

    // Contador do gerador de recursos
    var spawner = instance_find(obj_spawner, 0);
    if (spawner != noone) {
        spawner.spawn_timer = _data.spawner.spawn_timer;
    }

    // Inventário: esvazia todos os slots e preenche os salvos
    var gui = instance_find(obj_draw_GUI, 0);
    if (gui != noone) {
        for (var i = 0; i < array_length(gui.inventory); i++) {
            gui.inventory[i] = undefined;
        }
        for (var i = 0; i < array_length(_data.inventory); i++) {
            var saved_slot = _data.inventory[i];
            if (saved_slot.slot >= 0 && saved_slot.slot < array_length(gui.inventory)) {
                gui.inventory[saved_slot.slot] = { type: saved_slot.type, qty: saved_slot.qty };
            }
        }
    }

    // Recursos: recria cada um com a vida que tinha
    for (var i = 0; i < array_length(_data.resources); i++) {
        var saved_resource = _data.resources[i];
        var resource_object = asset_get_index(saved_resource.kind);

        // Ignora tipos que não existem mais
        if (resource_object == -1 || !object_exists(resource_object)) {
            continue;
        }

        var resource = instance_create_layer(saved_resource.x, saved_resource.y, "Instances", resource_object);
        resource.hp = saved_resource.hp;
    }

    // Itens no chão: recria parados e logo voltam a ser atraídos até o jogador
    for (var i = 0; i < array_length(_data.drops); i++) {
        var saved_drop = _data.drops[i];
        var drop_object = asset_get_index(saved_drop.kind);

        // Ignora tipos que não existem mais
        if (drop_object == -1 || !object_exists(drop_object)) {
            continue;
        }

        var drop = instance_create_layer(saved_drop.x, saved_drop.y, "Instances", drop_object);
        drop.phase = "towards";                  // Pula a fase de ser lançado e já volta para o jogador
        drop.timer = 40;
        drop.attraction = saved_drop.attraction; // false = inventário estava cheio (fica parado)
        drop.speed = saved_drop.attraction ? 2 : 0;
    }
}
