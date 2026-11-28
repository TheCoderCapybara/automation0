// A resolução pode ter mudado: reposiciona o inventário
update_layout();

// Alterna o inventário com a tecla configurada (padrão: Q)
if (keyboard_check_pressed(global.settings.controls.inventory)) {
    show_inventory = !show_inventory;
}

// Fechar o inventário devolve o que está na mão e fecha o espaço de venda
if (!show_inventory) {
    sell_open = false;
    left_pick = false;
    return_held();
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Botão esquerdo: pega a pilha inteira ou, com itens na mão, solta no slot clicado
if (show_inventory && mouse_check_button_pressed(mb_left)) {
    // Fecha o inventário ao clicar no botão de fechar
    if (point_in_rectangle(mx, my, close_x, close_y, close_x + close_w, close_y + close_h)) {
        show_inventory = false;
    } else {
        var clicked_slot = get_slot_at(mx, my);

        if (is_over_sell_slot(mx, my)) {
            // Clicar no espaço de venda com itens na mão vende a pilha toda
            sell_held(held == undefined ? 0 : held.qty);
        } else if (clicked_slot != -1) {
            if (held == undefined) {
                if (inventory[clicked_slot] != undefined) {
                    if (keyboard_check(vk_shift) && has_other_window()) {
                        // Shift + clique: move a pilha inteira para a outra janela
                        quick_transfer(clicked_slot, inventory[clicked_slot].qty);
                    } else {
                        // Pega a pilha inteira (segurar e arrastar também funciona: ver abaixo)
                        held = inventory[clicked_slot];
                        inventory[clicked_slot] = undefined;
                        held_from = clicked_slot;
                        left_pick = true;
                    }
                }
            } else {
                place_held_at(clicked_slot);
            }
        }
    }
}

// Soltou o botão esquerdo que pegou a pilha: se arrastou até outro slot, solta lá
if (left_pick && !mouse_check_button(mb_left)) {
    left_pick = false;

    if (held != undefined) {
        var release_slot = get_slot_at(mx, my);

        if (is_over_sell_slot(mx, my)) {
            // Arrastou até o espaço de venda: vende a pilha toda
            sell_held(held.qty);
        } else if (release_slot == held_from) {
            // Foi só um clique: continua com a pilha na mão
        } else if (release_slot != -1) {
            place_held_at(release_slot);
        } else {
            // Solto fora da grade: a pilha volta ao lugar
            return_held();
        }
    }
}

// Botão direito: sem nada na mão pega metade da pilha; com itens na mão passa 1 para o slot clicado
if (show_inventory && mouse_check_button_pressed(mb_right)) {
    var right_slot = get_slot_at(mx, my);

    if (is_over_sell_slot(mx, my)) {
        // No espaço de venda, o botão direito vende 1 item da mão
        sell_held(1);
    } else if (right_slot != -1) {
        var right_item = inventory[right_slot];

        if (held == undefined) {
            if (right_item != undefined) {
                var taken = ceil(right_item.qty / 2);

                if (keyboard_check(vk_shift) && has_other_window()) {
                    // Shift + clique direito: move metade da pilha para a outra janela
                    quick_transfer(right_slot, taken);
                } else {
                    // Pega metade dos itens do slot (arredondando para cima)
                    held = { type: right_item.type, qty: taken };
                    held_from = right_slot;
                    right_item.qty -= taken;
                    if (right_item.qty <= 0) {
                        inventory[right_slot] = undefined;
                    }
                }
            }
        } else {
            // Slot vazio: começa uma pilha com 1 item. Mesmo item (não cheio): soma 1
            var placed = false;
            if (right_item == undefined) {
                inventory[right_slot] = { type: held.type, qty: 1 };
                placed = true;
            } else if (right_item.type == held.type && right_item.qty < pack_size) {
                right_item.qty += 1;
                placed = true;
            }

            if (placed) {
                held.qty -= 1;
                if (held.qty <= 0) {
                    held = undefined;
                }
            }
        }
    }
}
