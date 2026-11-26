if (!show_inventory) exit;

draw_sprite(spr_back_inventory, 0, panel_x, panel_y);
draw_sprite(spr_close_button, 0, close_x, close_y);

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

draw_set_halign(fa_left);
draw_set_valign(fa_top);
