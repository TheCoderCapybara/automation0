obj_target = obj_player;

camera = camera_create();
view_enabled = true;
view_visible[0] = true;
view_camera[0] = camera;

// Resolução base da visão
view_w = 1280; // Largura base
view_h = 720;  // Altura base

// Centraliza a câmera no obj_target
if (instance_exists(obj_target)) {
    x = obj_target.x;
    y = obj_target.y;
} else {
    x = 0;
    y = 0;
}

// Configura a visão inicial
camera_set_view_size(camera, view_w, view_h);
camera_set_view_pos(camera, x - view_w / 2, y - view_h / 2);

// Configura a janela para escalonamento inteiro
window_set_size(view_w, view_h);
surface_resize(application_surface, view_w, view_h);

// Variáveis para suavização do movimento
follow_speed = 0.05; // Suavidade do seguimento (0.1 = lento, 0.5 = rápido)