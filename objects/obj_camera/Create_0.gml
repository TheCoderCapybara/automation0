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

// Carrega as configurações (só na primeira vez) e aplica o vídeo escolhido:
// tela cheia ou janela, escala e superfície da aplicação
settings_init();
settings_apply_video();
