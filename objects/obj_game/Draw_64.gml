// Os textos não usam acentos porque a fonte padrão pode não exibi-los.
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

if (state == "playing") {
    var tax = get_tax(day);
    var seconds_left = ceil(day_timer / game_get_speed(gamespeed_fps));
    var secs = seconds_left mod 60;
    var time_text = string(seconds_left div 60) + ":" + ((secs < 10) ? "0" : "") + string(secs);

    // Painel do HUD
    draw_set_color(c_black);
    draw_set_alpha(0.55);
    draw_rectangle(16, 16, 292, 132, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_text_transformed(28, 24, "Dia " + string(day), 1.5, 1.5, 0);
    draw_text(28, 58, "Tempo: " + time_text);
    draw_text(28, 80, "Moedas: " + string(money));

    // Imposto de hoje: verde se já dá para pagar, vermelho se ainda falta dinheiro
    draw_set_color((money >= tax) ? c_lime : c_red);
    draw_text(28, 102, "Imposto de hoje: " + string(tax));
    draw_set_color(c_white);

    // Aviso temporário, com fade nos últimos 30 frames
    if (notice_timer > 0) {
        draw_set_alpha(min(1, notice_timer / 30));
        draw_set_halign(fa_center);
        draw_text_transformed(gui_w / 2, 24, notice_text, 1.5, 1.5, 0);
        draw_set_halign(fa_left);
        draw_set_alpha(1);
    }
} else {
    // Tela de fim de jogo
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(0, 0, gui_w, gui_h, false);
    draw_set_alpha(1);

    var cx = gui_w / 2;
    var cy = gui_h / 2;
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_color(c_red);
    draw_text_transformed(cx, cy - 90, "FIM DE JOGO", 3, 3, 0);

    draw_set_color(c_white);
    draw_text_transformed(cx, cy - 20, "Sem dinheiro para o imposto do dia " + string(day), 1.5, 1.5, 0);
    draw_text_transformed(cx, cy + 10, "Imposto: " + string(failed_tax) + "   Moedas: " + string(money), 1.5, 1.5, 0);
    draw_text_transformed(cx, cy + 50, "Dias sobrevividos: " + string(days_survived), 1.5, 1.5, 0);
    draw_text_transformed(cx, cy + 110, "Pressione R para reiniciar", 1.5, 1.5, 0);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

draw_set_color(c_white);
