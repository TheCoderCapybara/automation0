// O item é lançado para longe do jogador (fase "away") e depois
// volta atraído até ele (fase "towards"). Ver o evento Step.
if (instance_exists(obj_player)) {
    direction = point_direction(obj_player.x, obj_player.y, x, y);
} else {
    direction = random(360);
}
speed = 12.5;
timer = 0;
phase = "away";
attraction = true;  // false: o item fica parado no chão (ex.: inventário cheio)

item_type = "noone";  // Definido pelos objetos filhos
