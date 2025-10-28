// Desenha o inventário se estiver visível
if (show_inventory) {
    var back_x = inventory_x - 8;
    var back_y = inventory_y - 16;
    draw_sprite(spr_back_inventory, 0, back_x, back_y);
    draw_sprite(spr_close_button, 0, back_x + 632, back_y + 4);
    
    // Desenha a grade de slots e os itens
    for (var row = 0; row < inventory_rows; row++) {
        for (var col = 0; col < inventory_cols; col++) {
            var slot_x = inventory_x + col * slot_size;
            var slot_y = inventory_y + row * slot_size;
            draw_sprite(spr_inventory, 0, slot_x, slot_y);
            // Desenha o item se o slot não estiver vazio
            if (inventory_items[# col, row] != "") {
                draw_sprite(item_sprites[? inventory_items[# col, row]], 0, slot_x + 16, slot_y + 16);
                // Desenha a quantidade se maior que 1
                if (inventory_quantities[# col, row] > 1) {
                    draw_set_halign(fa_right);
                    draw_set_valign(fa_bottom);
                    draw_text(slot_x + 28, slot_y + 34, string(inventory_quantities[# col, row]));
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                }
            }
        }
    }
}