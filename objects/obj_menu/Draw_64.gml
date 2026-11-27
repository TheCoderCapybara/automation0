// Os textos não usam acentos porque a fonte padrão pode não exibi-los.
var cx = gui_w / 2;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Título do jogo
draw_set_color(c_white);
draw_text_transformed(cx, title_y, title_text, 5, 5, 0);

// Subtítulo da tela atual
if (screen == "new_game") {
    draw_text_transformed(cx, 250, "Novo jogo", 2, 2, 0);
}
if (screen == "settings") {
    draw_text_transformed(cx, 80, "Configuracoes", 2, 2, 0);
}

// Tela de novo jogo: campo da seed
if (screen == "new_game") {
    var cursor = ((current_time div 500) mod 2 == 0) ? "_" : " ";
    draw_text_transformed(cx, 310, "Seed do mundo (somente numeros). Vazio = aleatoria", 1.25, 1.25, 0);
    draw_set_color(c_black);
    draw_rectangle(cx - 180, 340, cx + 180, 385, false);
    draw_set_color(c_white);
    draw_rectangle(cx - 180, 340, cx + 180, 385, true);
    draw_text_transformed(cx, 363, seed_input + cursor, 1.5, 1.5, 0);

    // Aviso: o novo jogo substitui o save anterior
    if (has_save) {
        draw_set_color(c_yellow);
        draw_text(cx, 560, "Atencao: comecar um novo jogo substitui o jogo salvo");
        draw_set_color(c_white);
    }
}

// Aba de controles: dicas das teclas fixas
if (screen == "settings" && settings_tab == "controls") {
    draw_text(cx, 590, "Fixas: Esc pausa, M menu na pausa, clique esquerdo ataca");
}

// Botões
for (var i = 0; i < array_length(buttons); i++) {
    var button = buttons[i];

    // Botão desativado fica meio transparente
    draw_set_alpha(button.enabled ? 1 : 0.4);

    // Fundo (mais claro sob o mouse) e borda
    draw_set_color((i == hover_index) ? make_color_rgb(70, 110, 150) : make_color_rgb(35, 60, 90));
    draw_rectangle(button.x, button.y, button.x + button.w, button.y + button.h, false);
    draw_set_color(c_white);
    draw_rectangle(button.x, button.y, button.x + button.w, button.y + button.h, true);

    // Texto do botão (na tecla esperando, em amarelo)
    var is_waiting = (string_pos("bind_", button.id) == 1 && waiting_key != "" && button.id == "bind_" + waiting_key);
    if (is_waiting) draw_set_color(c_yellow);
    draw_text_transformed(button.x + button.w / 2, button.y + button.h / 2, button.label, 1.5, 1.5, 0);
    draw_set_color(c_white);

    // Legenda à esquerda do botão (linhas das configurações)
    if (button.caption != "") {
        draw_set_halign(fa_right);
        draw_text_transformed(button.x - 20, button.y + button.h / 2, button.caption, 1.5, 1.5, 0);
        draw_set_halign(fa_center);
    }

    // Valor do volume entre o - e o +
    if (variable_struct_exists(button, "value_text")) {
        draw_text_transformed(button.x + 130 + 30, button.y + button.h / 2, button.value_text, 1.5, 1.5, 0);
    }
}

// Restaura o estado do desenho
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
