// Gera um número aleatório entre 3 e 5 para a quantidade de obj_log
var log_count = irandom_range(3, 5);

// Cria os obj_log em posições aleatórias dentro de um raio de 16 pixels
for (var i = 0; i < log_count; i++) {
    // Gera um ângulo aleatório entre 0 e 360 graus
    var angle = random(360);
    
    // Gera uma distância aleatória entre 0 e 16 pixels
    var distance = random(32);
    
    // Calcula as coordenadas x e y usando lengthdir
    var log_x = x + lengthdir_x(distance, angle);
    var log_y = y + lengthdir_y(distance, angle);
    
    // Cria o obj_log na posição calculada
    instance_create_layer(log_x, log_y, "Instances", obj_log);
}