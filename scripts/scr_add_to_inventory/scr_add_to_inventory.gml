function scr_add_to_inventory(caller, item_type) {
    // Procura um slot com o mesmo item e quantidade < 99
    for (var row = 0; row < caller.inventory_rows; row++) {
        for (var col = 0; col < caller.inventory_cols; col++) {
            if (caller.inventory_items[# col, row] == item_type && caller.inventory_quantities[# col, row] < obj_draw_GUI.pack_size) {
                caller.inventory_quantities[# col, row] += 1;
                return true;
            }
        }
    }
    
    // Se não encontrou, procura o primeiro slot vazio (esquerda para direita, cima para baixo)
    for (var row = 0; row < caller.inventory_rows; row++) {
        for (var col = 0; col < caller.inventory_cols; col++) {
            if (caller.inventory_items[# col, row] == "") {
                caller.inventory_items[# col, row] = item_type;
                caller.inventory_quantities[# col, row] = 1;
                return true;
            }
        }
    }
    
    // Inventário cheio
    var new_item = instance_create_layer(other.x, other.y, "Instances", other.object_index);
    new_item.item_type = item_type;
    new_item.attraction = false;
    return false;
}