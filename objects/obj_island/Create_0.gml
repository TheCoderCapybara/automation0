// Gerador de ilha: cria os tiles de grama a partir da seed do mundo.
// A mesma seed sempre gera a mesma ilha. O centro da ilha é o tile onde o jogador começa.

// Configurações
tile_size = 64;         // Tamanho de cada tile da ilha (pixels)
island_radius = 7;      // Raio médio da ilha (em tiles)
lobe_count_min = 4;     // Mínimo de lobos (o primeiro é o central)
lobe_count_max = 7;     // Máximo de lobos
edge_roughness = 0.25;  // Ondulação da borda (0 = círculos perfeitos)

// A ilha é gerada 1 frame depois, quando todas as instâncias da sala já existem
alarm[0] = 1;

/// Gera a ilha a partir da seed e cria os tiles de grama no mundo
generate_island = function(_seed) {
    // Sem jogador não há centro para a ilha
    if (!instance_exists(obj_player)) {
        return;
    }

    // Centro da ilha: o tile onde o jogador começa
    var center_tile_x = floor(obj_player.x / tile_size);
    var center_tile_y = floor(obj_player.y / tile_size);

    // Fixa a seed: todos os sorteios abaixo dependem só dela
    random_set_seed(_seed);

    // Sorteia os lobos (círculos que se juntam para formar a ilha)
    // As posições e os raios são medidos em tiles, a partir do centro
    var lobes = [];
    var lobe_count = irandom_range(lobe_count_min, lobe_count_max);

    // O primeiro lobo fica no centro e é o maior
    var main_radius = island_radius * random_range(0.6, 0.8);
    lobes[0] = {
        x: 0,
        y: 0,
        radius: main_radius,
        wobble_k: irandom_range(2, 4),   // Quantas ondulações a borda tem
        wobble_phase: random(360)        // Onde as ondulações começam
    };

    // Os outros lobos ficam dentro do central, então a ilha nunca se parte em pedaços
    for (var i = 1; i < lobe_count; i++) {
        // Posição do lobo: direção e distância aleatórias a partir do centro
        var angle = random(360);
        var distance = main_radius * random_range(0.4, 0.9);

        lobes[i] = {
            x: lengthdir_x(distance, angle),
            y: lengthdir_y(distance, angle),
            radius: island_radius * random_range(0.35, 0.6),
            wobble_k: irandom_range(2, 4),
            wobble_phase: random(360)
        };
    }

    // Área de teste: um quadrado de tiles em volta do centro, grande o bastante para os lobos
    var bound = ceil(island_radius * 2) + 1;
    var size = bound * 2 + 1;

    // Marca com true os tiles que são terra
    var land = [];
    for (var ix = 0; ix < size; ix++) {
        land[ix] = array_create(size, false);
    }

    for (var ix = 0; ix < size; ix++) {
        for (var iy = 0; iy < size; iy++) {
            // Posição do tile em relação ao centro
            var tile_dx = ix - bound;
            var tile_dy = iy - bound;

            // O tile é terra se estiver dentro de qualquer lobo
            for (var i = 0; i < lobe_count; i++) {
                var lobe = lobes[i];

                // O raio do lobo muda conforme a direção, para a borda não ser um círculo perfeito
                var angle_to_tile = point_direction(lobe.x, lobe.y, tile_dx, tile_dy);
                var wobble = 1 + edge_roughness * dsin(lobe.wobble_k * angle_to_tile + lobe.wobble_phase);
                var reach = lobe.radius * wobble;

                if (point_distance(lobe.x, lobe.y, tile_dx, tile_dy) < reach) {
                    land[ix][iy] = true;
                    break;
                }
            }
        }
    }

    // O tile do jogador (o centro) sempre é terra
    land[bound][bound] = true;

    // Mantém só a terra ligada ao centro (descarta pedaços soltos), buscando a partir do centro
    var connected = [];
    for (var ix = 0; ix < size; ix++) {
        connected[ix] = array_create(size, false);
    }

    connected[bound][bound] = true;
    var pending = [[bound, bound]];
    var directions = [[1, 0], [-1, 0], [0, 1], [0, -1]];

    while (array_length(pending) > 0) {
        var cell = array_pop(pending);

        // Visita os 4 vizinhos do tile
        for (var d = 0; d < 4; d++) {
            var next_x = cell[0] + directions[d][0];
            var next_y = cell[1] + directions[d][1];

            // Ignora o que está fora da área de teste
            if (next_x < 0 || next_x >= size || next_y < 0 || next_y >= size) {
                continue;
            }

            // Se for terra e ainda não foi visitado, marca e visita depois
            if (land[next_x][next_y] && !connected[next_x][next_y]) {
                connected[next_x][next_y] = true;
                array_push(pending, [next_x, next_y]);
            }
        }
    }

    // Tiles que nunca são removidos: o centro (onde o jogador começa) e os da caixa de venda
    var protected_tiles = [[bound, bound]];
    for (var i = 0; i < instance_number(obj_sell_box); i++) {
        var sell_box = instance_find(obj_sell_box, i);
        array_push(protected_tiles, [floor(sell_box.x / tile_size) - center_tile_x + bound, floor(sell_box.y / tile_size) - center_tile_y + bound]);
    }

    // Remove os bloquinhos: tiles com só 1 vizinho de terra (pontinhas para fora da ilha).
    // Repete até não sobrar nenhum, porque tirar uma pontinha pode deixar a próxima assim
    var removed_any = true;
    while (removed_any) {
        removed_any = false;

        for (var ix = 0; ix < size; ix++) {
            for (var iy = 0; iy < size; iy++) {
                if (!connected[ix][iy]) {
                    continue;
                }

                // Pula os tiles protegidos
                var is_protected = false;
                for (var i = 0; i < array_length(protected_tiles); i++) {
                    if (protected_tiles[i][0] == ix && protected_tiles[i][1] == iy) {
                        is_protected = true;
                    }
                }
                if (is_protected) {
                    continue;
                }

                // Conta os vizinhos de terra (4 lados)
                var neighbor_count = 0;
                for (var d = 0; d < 4; d++) {
                    var near_x = ix + directions[d][0];
                    var near_y = iy + directions[d][1];
                    if (near_x >= 0 && near_x < size && near_y >= 0 && near_y < size && connected[near_x][near_y]) {
                        neighbor_count += 1;
                    }
                }

                // Só 1 vizinho (ou nenhum): é um bloquinho
                if (neighbor_count <= 1) {
                    connected[ix][iy] = false;
                    removed_any = true;
                }
            }
        }
    }

    // Cria um tile de grama para cada tile de terra ligado ao centro
    island_tile_count = 0;
    for (var ix = 0; ix < size; ix++) {
        for (var iy = 0; iy < size; iy++) {
            if (!connected[ix][iy]) {
                continue;
            }

            // Posição do tile no mundo (a grama tem a origem no canto superior esquerdo)
            var world_x = (center_tile_x + ix - bound) * tile_size;
            var world_y = (center_tile_y + iy - bound) * tile_size;

            // Ignora o que ficaria fora da sala
            if (world_x < 0 || world_y < 0 || world_x + tile_size > room_width || world_y + tile_size > room_height) {
                continue;
            }

            instance_create_layer(world_x, world_y, "Instances", obj_chao_grama);
            island_tile_count += 1;
        }
    }

    // Garante grama sob a caixa de venda, mesmo que a configuração da ilha mude
    for (var i = 0; i < instance_number(obj_sell_box); i++) {
        var box = instance_find(obj_sell_box, i);
        if (!position_meeting(box.x, box.y, obj_chao_grama)) {
            var box_tile_x = floor(box.x / tile_size) * tile_size;
            var box_tile_y = floor(box.y / tile_size) * tile_size;
            instance_create_layer(box_tile_x, box_tile_y, "Instances", obj_chao_grama);
            island_tile_count += 1;
        }
    }

    // Devolve a aleatoriedade ao normal: o resto do jogo (drops, recursos) não depende da seed
    randomize();
};
