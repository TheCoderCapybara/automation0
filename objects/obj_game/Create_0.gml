// Controlador do jogo: dia, dinheiro, imposto e fim de jogo.

// --- Valores ajustáveis (placeholders de balanceamento) ---
day_length_seconds = 120;  // Duração de cada dia, em segundos
tax_base = 20;             // Imposto cobrado no fim do dia 1
tax_growth = 1.2;          // Multiplicador do imposto a cada dia (1.2 = +20%)
starting_money = 0;

// Preço de venda de cada tipo de item
item_prices = {};
item_prices[$ "log"] = 1;
item_prices[$ "stone"] = 2;

// --- Estado ---
state = "playing";  // "playing", "paused" ou "game_over"
day = 1;
day_length = day_length_seconds * game_get_speed(gamespeed_fps);  // Em frames
day_timer = day_length;
money = starting_money;
days_survived = 0;  // Dias completos (preenchido no fim de jogo)
failed_tax = 0;     // Imposto que não pôde ser pago (preenchido no fim de jogo)

// Aviso temporário na tela
notice_text = "";
notice_timer = 0;

// Tela de fim de jogo: escolha da seed do próximo mundo
game_over_mode = "menu";  // "menu" (escolher) ou "typing" (digitando a seed)
seed_input = "";          // Seed digitada pelo jogador
seed_max_digits = 9;      // Máximo de dígitos da seed

/// Pausa o jogo: salva, congela tudo (este controlador continua ativo) e abre o menu de pausa
pause_game = function() {
    save_game();
    state = "paused";
    instance_deactivate_all(true);
    instance_create_depth(0, 0, -100, obj_menu, { in_game: true });
};

/// Despausa o jogo (o menu de pausa se fecha sozinho)
resume_game = function() {
    instance_activate_all();
    state = "playing";
};

/// Volta ao menu inicial (usado na tela de fim de jogo; o save foi apagado ao morrer)
go_to_menu = function() {
    instance_activate_all();
    room_goto(rm_menu);
};

/// Imposto cobrado no fim do dia informado
get_tax = function(_day) {
    return round(tax_base * power(tax_growth, _day - 1));
};

/// Mostra um aviso por 3 segundos
show_notice = function(_text) {
    notice_text = _text;
    notice_timer = 3 * game_get_speed(gamespeed_fps);
};

/// Vende tudo o que o inventário tem e tem preço. Retorna o total ganho.
sell_inventory = function() {
    var gui = instance_find(obj_draw_GUI, 0);
    if (gui == noone) return 0;

    var total = 0;
    for (var i = 0; i < array_length(gui.inventory); i++) {
        var slot = gui.inventory[i];
        if (slot == undefined) continue;

        var price = item_prices[$ slot.type];
        if (price == undefined) continue;  // Item sem preço não é vendido

        total += price * slot.qty;
        gui.inventory[i] = undefined;
    }

    if (total > 0) {
        money += total;
        show_notice("Vendido: +" + string(total) + " moedas");
    } else {
        show_notice("Nada para vender");
    }
    return total;
};

/// Começa um novo mundo com a seed informada: a ilha é gerada de novo ao reiniciar a sala
start_new_world = function(_seed) {
    global.world_seed = _seed;
    global.continue_game = false;
    room_restart();
};

/// Cobra o imposto do dia: paga e começa o próximo dia, ou termina o jogo
end_day = function() {
    var tax = get_tax(day);

    if (money >= tax) {
        money -= tax;
        show_notice("Dia " + string(day) + " completo - imposto pago: " + string(tax));
        day += 1;
        day_timer = day_length;
        save_game();  // Salva automaticamente no começo de cada dia
    } else {
        state = "game_over";
        save_delete();  // Quem morre não pode continuar aquele jogo
        failed_tax = tax;
        days_survived = day - 1;
        instance_deactivate_all(true);  // Congela o jogo (este controlador continua ativo)
    }
};
