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
