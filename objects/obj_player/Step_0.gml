// Entrada (-1, 0 ou 1 em cada eixo; teclas opostas se cancelam)
var move_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var move_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));

// Espelha o sprite conforme a direção horizontal
if (move_x != 0) {
    image_xscale = move_x;
}

// Inicia o dash em direção ao cursor, se a recarga terminou
if (mouse_check_button_pressed(mb_right) && alarm[0] <= 0 && !dashing) {
    dash_dir = point_direction(x, y, mouse_x, mouse_y);
    dashing = true;
    dash_timer = dash_duration;
    alarm[0] = dash_cooldown;
}

if (dashing) {
    hspd = lengthdir_x(dash_speed, dash_dir);
    vspd = lengthdir_y(dash_speed, dash_dir);
    dash_timer -= 1;

    if (dash_timer <= 0) {
        dashing = false;
        hspd = 0;
        vspd = 0;
    }
} else {
    // Acelera até a velocidade desejada; sem entrada, o alvo é 0 (desacelera)
    hspd = approach(hspd, move_x * spd, (move_x != 0) ? acc : dec_h);
    vspd = approach(vspd, move_y * spd, (move_y != 0) ? acc : dec_v);

    // Na diagonal, limita a velocidade total para não passar de spd
    var total_spd = point_distance(0, 0, hspd, vspd);
    if (total_spd > spd) {
        hspd *= spd / total_spd;
        vspd *= spd / total_spd;
    }
}

x += hspd;
y += vspd;

// Mantém o jogador dentro da sala
x = clamp(x, 0, room_width);
y = clamp(y, 0, room_height);
