// Gera um número aleatório entre 2 e 3 para a quantidade de obj_stone
var stone_count = irandom_range(2, 3);

// Cria os obj_stone em posições aleatórias dentro de um raio de 32 pixels
for (var i = 0; i < stone_count; i++) {
    // Gera um ângulo aleatório entre 0 e 360 graus
    var angle = random(360);

    // Gera uma distância aleatória entre 0 e 32 pixels
    var distance = random(32);

    // Calcula as coordenadas x e y usando lengthdir
    var stone_x = x + lengthdir_x(distance, angle);
    var stone_y = y + lengthdir_y(distance, angle);

    // Cria o obj_stone na posição calculada
    instance_create_layer(stone_x, stone_y, "Instances", obj_stone);
}
