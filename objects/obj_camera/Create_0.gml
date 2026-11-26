obj_target = obj_player;

// Resolução base da visão
view_w = 1280;
view_h = 720;

// Suavidade do seguimento por frame (0 = parado, 1 = instantâneo)
follow_speed = 0.05;

camera = camera_create();
camera_set_view_size(camera, view_w, view_h);
view_enabled = true;
view_visible[0] = true;
view_camera[0] = camera;

// Começa centralizada no alvo
if (instance_exists(obj_target)) {
    x = obj_target.x;
    y = obj_target.y;
} else {
    x = 0;
    y = 0;
}
camera_set_view_pos(camera, x - view_w / 2, y - view_h / 2);

// Janela e superfície em um múltiplo inteiro da resolução base que caiba na tela
var scale = max(1, min(display_get_width() div view_w, display_get_height() div view_h));
window_set_size(view_w * scale, view_h * scale);
surface_resize(application_surface, view_w * scale, view_h * scale);
window_center();
