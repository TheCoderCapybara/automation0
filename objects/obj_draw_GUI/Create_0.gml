// Inventário
show_inventory = false;  // Visibilidade do inventário
slot_size = 32;          // Cada slot tem 32x32 pixels
inventory_cols = 10;
inventory_rows = 8;
pack_size = 50;          // Máximo de itens por slot

// Slots em ordem de leitura (esquerda para direita, cima para baixo).
// undefined = vazio; ocupado = { type: "log", qty: 3 }
inventory = array_create(inventory_cols * inventory_rows, undefined);

// Sprite exibido para cada tipo de item
item_sprites = {};
item_sprites[$ "log"] = spr_log;
item_sprites[$ "stone"] = spr_stone;

// Espaço de venda (da caixa de venda): 1 slot ao lado do inventário. O que é solto nele é vendido
sell_open = false;
sell_panel_w = sprite_get_width(spr_back_venda);
sell_panel_h = sprite_get_height(spr_back_venda);

// Outra janela com slots (baú, máquina...): array de slots como o inventário, ou undefined se não há.
// Com ela aberta, Shift + clique move pilhas do inventário para lá (a janela de venda usa sell_open)
other_slots = undefined;

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

    // Espaço de venda: à direita do painel do inventário, com o slot no meio
    sell_panel_x = panel_x + panel_w + 16;
    sell_panel_y = panel_y;
    sell_slot_x = sell_panel_x + (sell_panel_w - slot_size) / 2;
    sell_slot_y = sell_panel_y + 48;

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

/// Diz se a posição da GUI está sobre o slot de venda (só com o espaço de venda aberto)
is_over_sell_slot = function(_x, _y) {
    return sell_open && point_in_rectangle(_x, _y, sell_slot_x, sell_slot_y, sell_slot_x + slot_size - 1, sell_slot_y + slot_size - 1);
};

/// Vende itens da pilha da mão (preço definido no obj_game); só tira da mão o que foi vendido
sell_held = function(_amount) {
    if (held == undefined) return;

    var game = instance_find(obj_game, 0);
    if (game == noone) return;

    var sold_qty = min(_amount, held.qty);
    if (game.sell_item(held.type, sold_qty) > 0) {
        held.qty -= sold_qty;
        if (held.qty <= 0) {
            held = undefined;
        }
    }
};

/// Diz se há outra janela aberta para onde mover itens com Shift + clique
has_other_window = function() {
    return sell_open || other_slots != undefined;
};

/// Move itens de um slot do inventário para a outra janela (Shift + clique)
/// Venda: vende direto. Outra janela com slots: completa pilhas do mesmo item, depois usa slots vazios,
/// e o que não couber fica na mão do personagem
quick_transfer = function(_slot, _amount) {
    var item = inventory[_slot];
    if (item == undefined) return;

    var amount = min(_amount, item.qty);

    // Janela de venda: vende a quantidade
    if (sell_open) {
        var game = instance_find(obj_game, 0);
        if (game != noone && game.sell_item(item.type, amount) > 0) {
            item.qty -= amount;
            if (item.qty <= 0) {
                inventory[_slot] = undefined;
            }
        }
        return;
    }

    // Outra janela com slots
    var left = amount;

    // 1) Completa as pilhas do mesmo item que ainda têm espaço
    for (var i = 0; i < array_length(other_slots) && left > 0; i++) {
        var other_item = other_slots[i];
        if (other_item != undefined && other_item.type == item.type && other_item.qty < pack_size) {
            var added_qty = min(pack_size - other_item.qty, left);
            other_item.qty += added_qty;
            left -= added_qty;
        }
    }

    // 2) Usa os slots vazios
    for (var i = 0; i < array_length(other_slots) && left > 0; i++) {
        if (other_slots[i] == undefined) {
            var new_qty = min(pack_size, left);
            other_slots[i] = { type: item.type, qty: new_qty };
            left -= new_qty;
        }
    }

    // Tira do slot de origem tudo o que foi pedido; o que não coube fica na mão
    item.qty -= amount;
    if (item.qty <= 0) {
        inventory[_slot] = undefined;
    }
    if (left > 0) {
        held = { type: item.type, qty: left };
        held_from = _slot;
    }
};
