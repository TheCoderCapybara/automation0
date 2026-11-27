// Continuar o último jogo: recria o mundo salvo em vez de gerar uma ilha nova
var continued = false;
if (variable_global_exists("continue_game") && global.continue_game) {
    var save_data = save_read();
    if (save_data != undefined) {
        save_apply(save_data);
        continued = true;
    }
    global.continue_game = false;
}

// Mundo novo: define a seed e gera a ilha
if (!continued) {
    // Na primeira vez do jogo (sem passar pelo menu), sorteia uma seed
    if (!variable_global_exists("world_seed")) {
        randomize();
        global.world_seed = irandom_range(1, 999999999);
    }

    // Gera a ilha com a seed do mundo
    generate_island(global.world_seed);

    // Primeiro save do mundo, para o botão Continuar já funcionar
    save_game();
}
