// Define a seed do mundo: na primeira vez do jogo, sorteia uma nova
if (!variable_global_exists("world_seed")) {
    randomize();
    global.world_seed = irandom_range(1, 999999999);
}

// Gera a ilha com a seed do mundo
generate_island(global.world_seed);
