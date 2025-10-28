// Verifica entrada do teclado
var move_right = keyboard_check(ord("D"));
var move_left = keyboard_check(ord("A"));
var move_down = keyboard_check(ord("S"));
var move_up = keyboard_check(ord("W"));

// Ajusta o espelhamento do sprite com base na entrada
if (move_right) {
    image_xscale = 1; // Olhando para a direita
} else if (move_left && !move_right) {
    image_xscale = -1; // Olhando para a esquerda
}

// Verifica se o botão direito do mouse foi pressionado e se o cooldown terminou
if (mouse_check_button_pressed(mb_right) && alarm[0] <= 0 && !dashing) {
    // Calcula a direção do dash em relação ao cursor do mouse
    dash_dir = point_direction(x, y, mouse_x, mouse_y);
    dashing = true;
    dash_timer = dash_duration;
    alarm[0] = dash_cooldown;
}

// Gerencia o dash
if (dashing) {
    // Move o jogador na direção do dash
    hspd = lengthdir_x(dash_speed, dash_dir);
    vspd = lengthdir_y(dash_speed, dash_dir);
    dash_timer -= 1;
    
    // Finaliza o dash quando o timer termina
    if (dash_timer <= 0) {
        dashing = false;
        hspd = 0;
        vspd = 0;
    }
} else {
	// Calcula a aceleração horizontal
	if (move_right) {
	    hspd = min(hspd + acc, spd);
	} else if (move_left) {
	    hspd = max(hspd - acc, -spd);
	} else {
	    // Desacelera quando não há entrada horizontal
	    if (hspd > 0) {
	        hspd = max(hspd - acc * 2, 0);
	    } else if (hspd < 0) {
	        hspd = min(hspd + acc * 2, 0);
	    }
	}

	// Calcula a aceleração vertical
	if (move_down) {
	    vspd = min(vspd + acc, spd);
	} else if (move_up) {
	    vspd = max(vspd - acc, -spd);
	} else {
	    // Desacelera quando não há entrada vertical
	    if (vspd > 0) {
	        vspd = max(vspd - acc, 0);
	    } else if (vspd < 0) {
	        vspd = min(vspd + acc, 0);
	    }
	}
}
// Aplica o movimento
x += hspd;
y += vspd;

// Limita a posição do jogador aos limites da sala
x = clamp(x, 0, room_width);
y = clamp(y, 0, room_height);