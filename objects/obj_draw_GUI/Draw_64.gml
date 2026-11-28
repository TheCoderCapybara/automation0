if (!show_inventory) exit;

draw_sprite(spr_back_inventory, 0, panel_x, panel_y);
draw_sprite(spr_close_button, 0, close_x, close_y);

// Espaço de venda: painel à direita com 1 slot
if (sell_open) {
    draw_sprite(spr_back_venda, 0, sell_panel_x, sell_panel_y);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(sell_panel_x + sell_panel_w / 2, sell_panel_y + 18, "VENDA");
    draw_sprite(spr_inventory, 0, sell_slot_x, sell_slot_y);
    draw_text(sell_panel_x + sell_panel_w / 2, sell_panel_y + 88, "Solte aqui");
}

// Quantidades alinhadas ao canto inferior direito do slot
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);

for (var i = 0; i < inventory_cols * inventory_rows; i++) {
    var slot_x = inventory_x + (i mod inventory_cols) * slot_size;
    var slot_y = inventory_y + (i div inventory_cols) * slot_size;
    draw_sprite(spr_inventory, 0, slot_x, slot_y);

    var slot = inventory[i];
    if (slot == undefined) continue;

    // Os sprites dos itens têm origem no centro
    draw_sprite(item_sprites[$ slot.type], 0, slot_x + 16, slot_y + 16);

    if (slot.qty > 1) {
        draw_text(slot_x + 28, slot_y + 34, string(slot.qty));
    }
}

// A pilha da mão acompanha o mouse, por cima de tudo
if (held != undefined) {
    var held_x = device_mouse_x_to_gui(0);
    var held_y = device_mouse_y_to_gui(0);

    draw_sprite(item_sprites[$ held.type], 0, held_x, held_y);
    if (held.qty > 1) {
        draw_text(held_x + 12, held_y + 18, string(held.qty));
    }
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
