// A resolução mudou (nas configurações): ajusta a visão à nova proporção
if (view_w != global.view_w || view_h != global.view_h) {
    view_w = global.view_w;
    view_h = global.view_h;
    camera_set_view_size(camera, view_w, view_h);
    view_wport[0] = global.screen_w;
    view_hport[0] = global.screen_h;
}

if (!instance_exists(obj_target)) exit;

// Segue o alvo suavemente
x = lerp(x, obj_target.x, follow_speed);
y = lerp(y, obj_target.y, follow_speed);

// Alinha a pixels inteiros e mantém a visão dentro da sala
var cam_x = clamp(floor(x - view_w / 2), 0, room_width - view_w);
var cam_y = clamp(floor(y - view_h / 2), 0, room_height - view_h);

camera_set_view_pos(camera, cam_x, cam_y);
