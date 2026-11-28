// A resolução pode ter mudado: reposiciona o inventário
update_layout();

// Alterna o inventário com a tecla configurada (padrão: Q)
if (keyboard_check_pressed(global.settings.controls.inventory)) {
    show_inventory = !show_inventory;
}

// Fechar o inventário cancela o arrasto (o item volta ao lugar) e devolve o que está na mão
if (!show_inventory) {
    drag_slot = -1;
    return_held();
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

if (show_inventory && mouse_check_button_pressed(mb_left)) {
    // Fecha o inventário ao clicar no botão de fechar
    if (point_in_rectangle(mx, my, close_x, close_y, close_x + close_w, close_y + close_h)) {
        show_inventory = false;
    } else {
        // Clicar num item começa a arrastá-lo (não com itens na mão)
        var clicked_slot = get_slot_at(mx, my);
        if (clicked_slot != -1 && inventory[clicked_slot] != undefined && held == undefined) {
            drag_slot = clicked_slot;
        }
    }
}

// Soltou o botão: o item vai para o slot sob o mouse (troca de lugar se já houver um item lá)
if (drag_slot != -1 && !mouse_check_button(mb_left)) {
    var target_slot = get_slot_at(mx, my);

    // Solto fora da grade (ou no mesmo slot), ou o item já não existe mais: nada muda
    if (target_slot != -1 && target_slot != drag_slot && inventory[drag_slot] != undefined) {
        var moved_item = inventory[drag_slot];
        var target_item = inventory[target_slot];

        if (target_item != undefined && target_item.type == moved_item.type) {
            // Mesmo item: junta as pilhas no slot de destino, até o limite (o que sobrar fica na origem)
            var moved_qty = min(pack_size - target_item.qty, moved_item.qty);
            target_item.qty += moved_qty;
            moved_item.qty -= moved_qty;
            if (moved_item.qty <= 0) {
                inventory[drag_slot] = undefined;
            }
        } else {
            // Slot vazio ou outro item: troca de lugar
            inventory[drag_slot] = target_item;
            inventory[target_slot] = moved_item;
        }
    }
    drag_slot = -1;
}

// Botão direito
if (show_inventory && mouse_check_button_pressed(mb_right)) {
    var right_slot = get_slot_at(mx, my);

    if (right_slot != -1 && drag_slot != -1) {
        // Arrastando uma pilha (botão esquerdo): passa 1 item dela para o slot clicado
        var dragged_item = inventory[drag_slot];
        var right_item = inventory[right_slot];

        if (right_slot != drag_slot && dragged_item != undefined) {
            var can_add = false;

            if (right_item == undefined) {
                // Slot vazio: começa uma pilha com 1 item
                inventory[right_slot] = { type: dragged_item.type, qty: 1 };
                can_add = true;
            } else if (right_item.type == dragged_item.type && right_item.qty < pack_size) {
                // Mesmo item (e a pilha não está cheia): soma 1
                right_item.qty += 1;
                can_add = true;
            }

            if (can_add) {
                dragged_item.qty -= 1;
                if (dragged_item.qty <= 0) {
                    inventory[drag_slot] = undefined;
                    drag_slot = -1;
                }
            }
        }
    } else if (right_slot != -1 && held == undefined) {
        // Sem nada na mão: pega metade dos itens do slot (arredondando para cima)
        var slot_item = inventory[right_slot];
        if (slot_item != undefined) {
            var taken = ceil(slot_item.qty / 2);
            held = { type: slot_item.type, qty: taken };
            slot_item.qty -= taken;
            if (slot_item.qty <= 0) {
                inventory[right_slot] = undefined;
            }
        }
    } else if (right_slot != -1) {
        // Com itens na mão: solta 1 num slot vazio ou soma 1 num slot do mesmo item
        var target_item_right = inventory[right_slot];
        var placed = false;

        if (target_item_right == undefined) {
            inventory[right_slot] = { type: held.type, qty: 1 };
            placed = true;
        } else if (target_item_right.type == held.type && target_item_right.qty < pack_size) {
            target_item_right.qty += 1;
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
