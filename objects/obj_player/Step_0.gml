// Teclas de movimento (configuráveis no menu de configurações)
var controls = global.settings.controls;

// Entrada (-1, 0 ou 1 em cada eixo; teclas opostas se cancelam)
var move_x = keyboard_check(controls.right) - keyboard_check(controls.left);
var move_y = keyboard_check(controls.down) - keyboard_check(controls.up);

// Espelha o sprite conforme a direção horizontal
if (move_x != 0) {
    image_xscale = move_x;
}

// Acelera até a velocidade desejada; sem entrada, o alvo é 0 (desacelera)
hspd = approach(hspd, move_x * spd, (move_x != 0) ? acc : dec_h);
vspd = approach(vspd, move_y * spd, (move_y != 0) ? acc : dec_v);

// Na diagonal, limita a velocidade total para não passar de spd
var total_spd = point_distance(0, 0, hspd, vspd);
if (total_spd > spd) {
    hspd *= spd / total_spd;
    vspd *= spd / total_spd;
}

x += hspd;
y += vspd;

// Mantém o jogador dentro da sala
x = clamp(x, 0, room_width);
y = clamp(y, 0, room_height);
