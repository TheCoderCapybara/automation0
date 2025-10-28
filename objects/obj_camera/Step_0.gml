// Atualiza a posição da câmera para seguir o obj_target
if (instance_exists(obj_target)) {
    // Move suavemente para a posição do alvo
    x = lerp(x, obj_target.x, follow_speed);
    y = lerp(y, obj_target.y, follow_speed);
    
    // Garante que a posição da câmera esteja alinhada a pixels inteiros
    var cam_x = floor(x - view_w / 2);
    var cam_y = floor(y - view_h / 2);
	
	cam_x = clamp(cam_x, 0, room_width - view_w);
	cam_y = clamp(cam_y, 0, room_height - view_h);
    
    // Atualiza a posição da câmera
    camera_set_view_pos(camera, cam_x, cam_y);
}

// Ajusta a janela para diferentes resoluções
var display_w = display_get_width();
var display_h = display_get_height();
var scale = min(floor(display_w / view_w), floor(display_h / view_h));
if (scale < 1) scale = 1; // Garante escala mínima de 1x

// Redimensiona a janela para um múltiplo inteiro da resolução base
window_set_size(view_w * scale, view_h * scale);
surface_resize(application_surface, view_w * scale, view_h * scale);

// Centraliza a janela na tela
window_center();