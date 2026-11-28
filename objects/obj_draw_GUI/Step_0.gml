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
        inventory[drag_slot] = inventory[target_slot];
        inventory[target_slot] = moved_item;
    }
    drag_slot = -1;
}

// Botão direito (sem arrastar com o esquerdo)
if (show_inventory && drag_slot == -1 && mouse_check_button_pressed(mb_right)) {
    var right_slot = get_slot_at(mx, my);

    if (right_slot != -1) {
        if (held == undefined) {
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
        } else if (inventory[right_slot] == undefined) {
            // Com itens na mão, num slot vazio: solta 1 item ali
            inventory[right_slot] = { type: held.type, qty: 1 };
            held.qty -= 1;
            if (held.qty <= 0) {
                held = undefined;
            }
        }
    }
}
