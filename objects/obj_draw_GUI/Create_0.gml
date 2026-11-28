// Inventário
show_inventory = false;  // Visibilidade do inventário
slot_size = 32;          // Cada slot tem 32x32 pixels
inventory_cols = 10;
inventory_rows = 8;
pack_size = 99;          // Máximo de itens por slot

// Slots em ordem de leitura (esquerda para direita, cima para baixo).
// undefined = vazio; ocupado = { type: "log", qty: 3 }
inventory = array_create(inventory_cols * inventory_rows, undefined);

// Sprite exibido para cada tipo de item
item_sprites = {};
item_sprites[$ "log"] = spr_log;
item_sprites[$ "stone"] = spr_stone;

// Pilha na mão: { type, qty }, ou undefined se não segura nada.
// Clicar numa pilha pega ela inteira (esquerdo) ou metade (direito); clicar de novo solta
held = undefined;
held_from = -1;     // Slot de onde a pilha saiu (para ela voltar ao lugar)
left_pick = false;  // true enquanto o botão esquerdo que pegou a pilha ainda está apertado (arrastar)

// A GUI acompanha o tamanho do jogo na tela (definido em settings_apply_video)
// Painel do inventário centralizado na GUI e grade de slots, com a margem do painel
panel_w = sprite_get_width(spr_back_inventory);
panel_h = sprite_get_height(spr_back_inventory);
close_w = sprite_get_width(spr_close_button);
close_h = sprite_get_height(spr_close_button);

/// Posiciona o painel, os slots e o botão de fechar no centro da GUI atual
update_layout = function() {
    gui_w = display_get_gui_width();
    gui_h = display_get_gui_height();

    panel_x = (gui_w - panel_w) / 2;
    panel_y = (gui_h - panel_h) / 2;

    inventory_x = panel_x + 8;
    inventory_y = panel_y + 16;

    // Botão de fechar, no canto superior direito do painel
    close_x = panel_x + panel_w - close_w - 4;
    close_y = panel_y + 4;
};
update_layout();

/// Devolve o índice do slot sob a posição da GUI, ou -1 se estiver fora da grade
get_slot_at = function(_x, _y) {
    var col = floor((_x - inventory_x) / slot_size);
    var row = floor((_y - inventory_y) / slot_size);

    if (col < 0 || col >= inventory_cols || row < 0 || row >= inventory_rows) {
        return -1;
    }
    return row * inventory_cols + col;
};

/// Solta a pilha da mão no slot: slot vazio recebe tudo, mesmo item soma (até o limite) e outro item troca de lugar
place_held_at = function(_slot) {
    var target = inventory[_slot];

    if (target == undefined) {
        inventory[_slot] = held;
        held = undefined;
    } else if (target.type == held.type) {
        var moved_qty = min(pack_size - target.qty, held.qty);
        target.qty += moved_qty;
        held.qty -= moved_qty;
        if (held.qty <= 0) {
            held = undefined;
        }
    } else {
        // Outro item: ele vai para a mão e a pilha anterior fica no slot
        inventory[_slot] = held;
        held = target;
        held_from = _slot;
    }
};

/// Devolve a pilha da mão ao inventário: primeiro no slot de origem, o que sobrar em qualquer slot livre
return_held = function() {
    if (held == undefined) return;

    // Slot de origem (se estiver vazio ou com o mesmo item)
    if (held_from >= 0 && held_from < array_length(inventory)) {
        var origin = inventory[held_from];
        if (origin == undefined || origin.type == held.type) {
            place_held_at(held_from);
        }
    }

    // O resto vai item a item para qualquer lugar com espaço (o que não couber continua na mão)
    while (held != undefined && held.qty > 0) {
        if (!scr_add_to_inventory(held.type)) break;
        held.qty -= 1;
    }
    if (held != undefined && held.qty <= 0) {
        held = undefined;
    }
};
