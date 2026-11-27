// Alterna o inventário com a tecla configurada (padrão: Q)
if (keyboard_check_pressed(global.settings.controls.inventory)) {
    show_inventory = !show_inventory;
}

// Fecha o inventário ao clicar no botão de fechar
if (show_inventory && mouse_check_button_pressed(mb_left)) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);

    if (point_in_rectangle(mx, my, close_x, close_y, close_x + close_w, close_y + close_h)) {
        show_inventory = false;
    }
}
