/// @desc Adiciona 1 item ao inventário: empilha num slot do mesmo tipo ou usa o primeiro slot vazio.
/// @param {String} _item_type Tipo do item (ex.: "log", "stone")
/// @returns {Bool} true se o item foi adicionado; false se o inventário está cheio
function scr_add_to_inventory(_item_type) {
    var gui = instance_find(obj_draw_GUI, 0);
    if (gui == noone) return false;

    var slot_count = array_length(gui.inventory);

    // Empilha num slot que já tenha o mesmo item e ainda tenha espaço
    for (var i = 0; i < slot_count; i++) {
        var slot = gui.inventory[i];
        if (slot != undefined && slot.type == _item_type && slot.qty < gui.pack_size) {
            slot.qty += 1;
            return true;
        }
    }

    // Senão, usa o primeiro slot vazio
    for (var i = 0; i < slot_count; i++) {
        if (gui.inventory[i] == undefined) {
            gui.inventory[i] = { type: _item_type, qty: 1 };
            return true;
        }
    }

    return false;
}
