// Povoamento inicial: completa árvores e pedras até o máximo

// Árvores que faltam na sala
var missing_trees = tree_max - instance_number(obj_tree);
for (var i = 0; i < missing_trees; i++) {
    spawn_resource(obj_tree);
}

// Pedras que faltam na sala
var missing_rocks = rock_max - instance_number(obj_rock);
for (var i = 0; i < missing_rocks; i++) {
    spawn_resource(obj_rock);
}
