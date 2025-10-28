// Variáveis de inventário
show_inventory = false; // Controla visibilidade do inventário
slot_size = 32;         // Tamanho de cada slot (32x32 pixels)
inventory_cols = 10;    // 10 colunas
inventory_rows = 8;     // 8 linhas
pack_size = 99;

// Calcula a largura e altura total da grade de inventário
var inventory_width = inventory_cols * slot_size;
var inventory_height = inventory_rows * slot_size;

// Centraliza o inventário na tela de 1280x720
inventory_x = (960 - inventory_width) / 2;
inventory_y = (720 - inventory_height) / 2;

// Inicializa as estruturas de dados do inventário
inventory_items = ds_grid_create(inventory_cols, inventory_rows);
ds_grid_clear(inventory_items, "");
inventory_quantities = ds_grid_create(inventory_cols, inventory_rows);
ds_grid_clear(inventory_quantities, 0);
item_sprites = ds_map_create();
item_sprites[?"log"] = spr_log; // Substitua por spr_log_item se criado
item_sprites[?"stone"] = spr_stone; // Substitua por spr_log_item se criado