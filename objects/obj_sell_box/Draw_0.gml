// Caixa provisória desenhada por código (ainda sem sprite)
draw_set_color(make_color_rgb(139, 90, 43));
draw_rectangle(x - 24, y - 24, x + 24, y + 24, false);
draw_set_color(c_white);
draw_rectangle(x - 24, y - 24, x + 24, y + 24, true);

// Textos sem acentos porque a fonte padrão pode não exibi-los
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text(x, y - 28, "VENDA");
if (player_near) {
    draw_text(x, y - 46, "[E] Vender tudo");
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
