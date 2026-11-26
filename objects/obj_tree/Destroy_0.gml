// Solta de 3 a 5 troncos em posições aleatórias num raio de 32 pixels
repeat (irandom_range(3, 5)) {
    var angle = random(360);
    var dist = random(32);
    instance_create_layer(x + lengthdir_x(dist, angle), y + lengthdir_y(dist, angle), "Instances", obj_log);
}
